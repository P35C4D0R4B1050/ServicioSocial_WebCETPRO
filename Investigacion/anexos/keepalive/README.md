# keepalive: evitar que Oracle reclame la VM por inactividad (100 % gratuito)

**Estado: borrador sin probar en una VM de Oracle.** La lógica del informe (percentil 95) se probó con datos sintéticos; el muestreo de `/proc/stat` y las ráfagas deben probarse en la VM real.

## Qué problema resuelve

Oracle puede reclamar una instancia Always Free si, **durante 7 días**, se cumplen **las tres** condiciones: CPU p95 menor a 20 %, red menor a 20 % y (solo en las Arm A1) memoria menor a 20 % ([documentación oficial](https://docs.oracle.com/en-us/iaas/Content/FreeTier/resourceref.htm)). Basta con superar **una** para no ser "inactiva". Un sistema para 5 usuarios queda casi siempre por debajo de los tres umbrales.

## Estrategia

1. **CPU**: una ráfaga de 7 minutos al 40 % cada hora (≈ 12 % del tiempo por encima del 20 %; el p95 exige más del 5 %). El coste real es de ~2,8 minutos de un núcleo por hora.
2. **Memoria (solo A1, opcional)**: retener 1,4 GB durante la ráfaga si el uso natural queda bajo el 20 % de 6 GB.
3. **Prioridad mínima**: `nice 19`, `ionice` clase 3, `CPUWeight=1`. Si hay trabajo real, la ráfaga se cede o se omite.
4. **Verificación local**: se mide la CPU cada minuto y se calcula el p95 de 7 días (`keepalive.sh report`).
5. **Aviso externo**: si el p95 local baja del umbral de alerta, o la VM deja de enviar señal, [Healthchecks.io](https://healthchecks.io) avisa por correo (plan gratuito; límites actuales no verificados).
6. **Trabajo útil primero**: el respaldo, la prueba de restauración y los escaneos nocturnos también suben la CPU. Las ráfagas completan lo que falte.

## Instalación

```bash
sudo ./install.sh        # instala stress-ng, copia scripts y activa los tres temporizadores
sudo nano /etc/keepalive.env
journalctl -t keepalive -f
```

## Comprobar que funciona (hacer siempre)

1. En la consola de Oracle, abrir **Observability → Metrics Explorer** y consultar `CpuUtilization[1m].percentile(0.95)` de la instancia en los últimos 7 días. Debe superar **20 %** con margen. Para las A1, hacer lo mismo con `MemoryUtilization`.
2. Confirmar que el **Oracle Cloud Agent** tiene activado el complemento de monitoreo de la instancia (sin él no hay métricas de memoria).
3. Comparar el `report` local con lo que muestra Oracle durante la primera semana.

## Límites y riesgos (honestos)

- Es una **inferencia a partir del criterio publicado**: Oracle no garantiza que esto evite la reclamación ni que el criterio no cambie. Si cambia el umbral o la forma de medir, hay que recalibrar.
- La métrica de CPU en las VM **AMD Micro** (1/8 de OCPU) puede medirse distinto; verificar en el Metrics Explorer.
- No se genera tráfico de red artificial.
- **No se verificó** si los términos de uso de Oracle restringen el uso de carga artificial. La carga es pequeña, de baja prioridad y se combina con trabajo real.
- Complementar siempre con **respaldos cifrados fuera de Oracle** y **monitoreo externo**: si la VM se detiene, el sistema debe poder reconstruirse (infraestructura como código).
