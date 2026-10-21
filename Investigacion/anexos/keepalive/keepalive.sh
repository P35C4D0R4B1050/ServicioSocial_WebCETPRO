#!/usr/bin/env bash
# keepalive.sh - evita que Oracle clasifique la VM como "inactiva" (Always Free).
#
# Criterio oficial (7 días): inactiva si CPU p95 < 20 % Y red < 20 % Y (solo A1) memoria < 20 %.
# Basta con superar UNO de los tres. Este script supera el de CPU con margen:
#   - una ráfaga corta cada hora (BURST_MINUTES a BURST_CPU_LOAD %), a la prioridad más baja;
#   - se omite si la VM ya está ocupada con trabajo real;
#   - mide la CPU de la propia VM cada minuto y calcula el p95 local de los últimos 7 días;
#   - avisa a un monitor externo (Healthchecks.io) si el p95 local baja del umbral de alerta.
#
# Subcomandos: sample | burst | report
# Estado: BORRADOR sin probar en Oracle. Ver README.md.
set -euo pipefail

CONF="${KEEPALIVE_CONF:-/etc/keepalive.env}"
# shellcheck disable=SC1090
[ -f "$CONF" ] && . "$CONF"

: "${BURST_MINUTES:=7}"        # duración de cada ráfaga
: "${BURST_CPU_LOAD:=40}"      # % de CPU durante la ráfaga (> 20 con margen)
: "${HOLD_MEM_MB:=0}"          # 0 = no retener memoria; en A1 puede usarse p. ej. 1400
: "${SKIP_IF_BUSY_PCT:=50}"    # si la CPU ya está a este % o más, no se agrega carga
: "${TARGET_P95:=30}"          # alerta local si el p95 de 7 días baja de este valor
: "${WINDOW_DAYS:=7}"
: "${STATE_DIR:=/var/lib/keepalive}"
: "${HC_URL:=}"                # URL de ping de Healthchecks.io (opcional)

SAMPLES="$STATE_DIR/cpu.csv"
LAST="$STATE_DIR/last_stat"

log() { logger -t keepalive -- "$*" 2>/dev/null || echo "keepalive: $*" >&2; }

# Lee "total busy" acumulados de /proc/stat (busy = total - idle - iowait).
read_stat() {
    awk '/^cpu / { total=0; for (i=2;i<=9;i++) total+=$i; idle=$5+$6; print total, total-idle }' /proc/stat
}

mem_pct() {
    awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END { printf "%.1f", (t-a)*100/t }' /proc/meminfo
}

ping_hc() {  # $1 = "" | "/fail"
    [ -n "$HC_URL" ] || return 0
    curl -fsS -m 10 --retry 2 -o /dev/null "${HC_URL}${1:-}" || log "no se pudo avisar a Healthchecks"
}

cmd_sample() {
    mkdir -p "$STATE_DIR"
    local now cur total busy ptotal pbusy pct
    now=$(date +%s)
    cur=$(read_stat); total=${cur% *}; busy=${cur#* }
    if [ -f "$LAST" ]; then
        read -r ptotal pbusy < "$LAST"
        if [ "$total" -gt "$ptotal" ]; then
            pct=$(awk -v b="$((busy-pbusy))" -v t="$((total-ptotal))" 'BEGIN { printf "%.1f", b*100/t }')
            echo "$now,$pct,$(mem_pct)" >> "$SAMPLES"
        fi
    fi
    echo "$total $busy" > "$LAST"
    # Conserva solo la ventana de análisis más un día
    if [ -f "$SAMPLES" ] && [ $((now % 3600)) -lt 60 ]; then
        awk -F, -v since="$((now - (WINDOW_DAYS+1)*86400))" '$1>=since' "$SAMPLES" > "$SAMPLES.tmp" && mv "$SAMPLES.tmp" "$SAMPLES"
    fi
}

cpu_now() {  # % de CPU ocupada durante 3 s
    local a b ta ba tb bb
    a=$(read_stat); ta=${a% *}; ba=${a#* }
    sleep 3
    b=$(read_stat); tb=${b% *}; bb=${b#* }
    awk -v b="$((bb-ba))" -v t="$((tb-ta))" 'BEGIN { if (t<=0) print 0; else printf "%.1f", b*100/t }'
}

cmd_burst() {
    local busy
    busy=$(cpu_now)
    if awk -v b="$busy" -v s="$SKIP_IF_BUSY_PCT" 'BEGIN { exit !(b>=s) }'; then
        log "CPU ocupada (${busy} %), se omite la ráfaga"
        return 0
    fi
    command -v stress-ng >/dev/null || { log "falta stress-ng (apt install stress-ng)"; return 1; }
    log "ráfaga: ${BURST_CPU_LOAD} % de CPU durante ${BURST_MINUTES} min (CPU previa ${busy} %)"
    local mempid=""
    if [ "$HOLD_MEM_MB" -gt 0 ]; then
        python3 - "$HOLD_MEM_MB" "$((BURST_MINUTES*60))" <<'PY' &
import sys, time
mb, secs = int(sys.argv[1]), int(sys.argv[2])
b = bytearray(mb * 1024 * 1024)
for i in range(0, len(b), 4096):
    b[i] = 1          # toca cada página para que cuente como memoria usada
time.sleep(secs)
PY
        mempid=$!
    fi
    nice -n 19 ionice -c3 timeout "$((BURST_MINUTES*60+30))" \
        stress-ng --cpu 1 --cpu-load "$BURST_CPU_LOAD" --timeout "${BURST_MINUTES}m" --quiet || true
    [ -n "$mempid" ] && wait "$mempid" 2>/dev/null || true
}

p95_window() {  # imprime "p95 n"
    awk -F, -v since="$(date -d "-${WINDOW_DAYS} days" +%s)" '$1>=since { print $2 }' "$SAMPLES" 2>/dev/null \
        | sort -n \
        | awk '{ a[NR]=$1 } END {
              if (NR==0) { print "nan 0"; exit }
              i=0.95*NR; k=int(i); if (k<i) k++; if (k<1) k=1
              print a[k], NR }'
}

cmd_report() {
    local out p n expected
    out=$(p95_window); p=${out% *}; n=${out#* }
    expected=$((WINDOW_DAYS*1440))
    log "p95 de CPU (${WINDOW_DAYS} d) = ${p} %, muestras = ${n}/${expected}"
    echo "p95_cpu=${p} muestras=${n}/${expected} (alerta si < ${TARGET_P95})"
    if [ "$n" -lt $((expected/2)) ] && [ "$n" -ge 1 ]; then
        log "pocas muestras: ¿está corriendo keepalive-sample.timer?"
    fi
    if [ "$p" = "nan" ] || awk -v p="$p" -v t="$TARGET_P95" 'BEGIN { exit !(p<t) }'; then
        ping_hc "/fail"; return 1
    fi
    ping_hc ""
}

case "${1:-}" in
    sample) cmd_sample ;;
    burst)  cmd_burst ;;
    report) cmd_report ;;
    *) echo "uso: $0 {sample|burst|report}" >&2; exit 2 ;;
esac
