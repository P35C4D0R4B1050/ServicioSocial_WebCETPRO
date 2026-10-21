#!/usr/bin/env bash
# Instala keepalive en una VM Ubuntu (ejecutar como root). BORRADOR sin probar en Oracle.
set -euo pipefail
cd "$(dirname "$0")"

apt-get update -qq
apt-get install -y --no-install-recommends stress-ng python3 curl

install -m 0755 keepalive.sh /usr/local/bin/keepalive.sh
[ -f /etc/keepalive.env ] || install -m 0640 keepalive.env.example /etc/keepalive.env
install -m 0644 keepalive-sample.service keepalive-sample.timer \
                keepalive-burst.service  keepalive-burst.timer \
                keepalive-report.service keepalive-report.timer /etc/systemd/system/

systemctl daemon-reload
systemctl enable --now keepalive-sample.timer keepalive-burst.timer keepalive-report.timer
systemctl list-timers 'keepalive-*' --no-pager
echo "Listo. Edite /etc/keepalive.env (HC_URL, HOLD_MEM_MB) y revise: journalctl -t keepalive"
