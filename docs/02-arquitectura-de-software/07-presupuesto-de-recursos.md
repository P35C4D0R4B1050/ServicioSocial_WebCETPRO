# Presupuesto de recursos

Los recursos gratuitos son el límite más estricto del proyecto (RC-01, RC-02). Este documento fija presupuestos por contenedor para que el despliegue entre en 2 OCPU y 12 GB de Arm y define cómo se comprueba. **Las cifras son metas iniciales** y se validan con mediciones y pruebas de carga ligeras (k6) antes de aprobar el despliegue.

## 1. Marco

| VM | Recursos | Contenido |
| :--- | :--- | :--- |
| **VM-APP** (Arm) | 1 OCPU y 6 GB | Caddy, aplicación de matrícula y `keepalive`. |
| **VM-DB** (Arm) | 1 OCPU y 6 GB | PostgreSQL 18, tareas de respaldo y `keepalive`. |
| **VM-WEB** (x86 micro) | 1/8 OCPU y 1 GB | Servidor web mínimo con el sitio institucional estático. |

Meta de uso sostenido: **memoria menor al 70 %** por VM (hasta ~4,2 GB en las de 6 GB). Una consideración especial: Oracle puede reclamar una A1 cuya memoria esté **por debajo del 20 %** (1,2 GB) durante siete días; si la memoria natural no la alcanza, el `keepalive` retiene memoria (`HOLD_MEM_MB`, por ejemplo 1.400 MB) para no parecer inactiva.

## 2. Memoria por contenedor

### 2.1 VM-APP (6 GB)

| Contenedor o proceso | Límite (`mem_limit`) | Uso esperado | Nota |
| :--- | :---: | :---: | :--- |
| Aplicación Matrícula (ASP.NET Core 10) | 768 MB | 250–450 MB | Razor Pages, HTMX, QuestPDF y ClosedXML; la generación de PDF y Excel es el pico. |
| Caddy | 64 MB | 20–40 MB | Proxy inverso y HTTPS automático. |
| `keepalive` y tareas (proceso del sistema) | 32 MB | < 20 MB | Ráfagas de CPU; la retención de memoria (`HOLD_MEM_MB`) es aparte y opcional. |
| Retención de memoria del `keepalive` | 1.400 MB opcional | — | Solo si la memoria natural queda bajo el 20 %. |
| Sistema y Docker | — | ~500 MB | |
| **Total** | ~0,9 GB de límites + retención | ~0,8–1,0 GB | Muy por debajo del 70 %; la retención sube el uso hasta ~2,4 GB. |

### 2.2 VM-DB (6 GB)

| Contenedor o proceso | Límite | Nota |
| :--- | :---: | :--- |
| PostgreSQL 18 | 3 GB | `shared_buffers` de 1 a 1,5 GB; `max_connections` moderado con agrupamiento de conexiones. |
| Tareas de respaldo | 256 MB | Volcado y cifrado secuenciales, fuera de horas pico. |
| `keepalive` | 32 MB | |
| Sistema | ~400 MB | |
| **Total** | ~3,7 GB de límites | Consumo esperado 2–3 GB; el resto lo usa el sistema como caché de disco. |

### 2.3 VM-WEB (1 GB)

| Elemento | Límite | Nota |
| :--- | :---: | :--- |
| Servidor web mínimo (sitio estático) | 128 MB | Menos de 200 MB en total con el sistema. |

## 3. CPU y concurrencia

La CPU de 1 OCPU basta para 5 usuarios; el cuello de botella previsto es la **generación de PDF y Excel** y la búsqueda de estudiantes.

| Medida | Meta | Cómo se verifica |
| :--- | :--- | :--- |
| Pantallas de matrícula | p95 < 1 s con 5 usuarios (RNF-01) | k6 sobre una VM con 1 OCPU |
| Constancia PDF | < 3 s | Prueba de carga ligera |
| Nómina o Anexo 1 de un módulo (hasta ~300 filas) | < 5 s | Prueba de carga ligera |
| CPU sostenida de VM-APP | < 70 % en la prueba | `docker stats` o métricas del sistema |
| Conexiones a la BD | Límite por la aplicación; sin crecimiento sin tope | Revisión de configuración |
| Trabajos de fondo | Alertas, retención y respaldos espaciados para no competir con el horario de matrícula | Revisión del plan |

## 4. Almacenamiento

| Elemento | Presupuesto | Nota |
| :--- | :---: | :--- |
| Volúmenes de arranque | ~50 GB por VM (3 VM = 150 GB de 200 GB) | Mínimo de Oracle. |
| Base de datos | < 5 GB al inicio | Estudiantes, matrículas y bitácora; la bitácora crece con las lecturas. |
| Registros de contenedores | Rotación (3 archivos de 10 MB por contenedor) | Evita llenar el disco. |
| Respaldos locales temporales | < 5 GB | Se suben a Object Storage y se borran. |
| Object Storage | ≤ 20 GB | Retención escalonada y compresión. |

## 5. Presupuesto de la interfaz

| Medida | Meta | Fuente |
| :--- | :---: | :--- |
| Carga de pantallas principales | < 2,5 s con conexión doméstica típica | [Rendimiento percibido](../06-experiencia-de-usuario/07-rendimiento-percibido.md) |
| Interacción | < 200 ms | [Rendimiento percibido](../06-experiencia-de-usuario/07-rendimiento-percibido.md) |
| JavaScript propio | Mínimo: HTMX y pocos scripts propios | AD-02 |

## 6. Control

- Cada contenedor del Compose declara `mem_limit` y, cuando corresponde, `cpus`.
- Un incumplimiento de las metas en la prueba de carga se registra como riesgo en [drivers](01-drivers-arquitectonicos.md) y se mitiga antes del despliegue.
- Si el uso de memoria supera el 70 % sostenido, se reduce el consumo antes de agregar recursos de pago (no hay recursos de pago).
