# Rendimiento percibido

El sistema se usa en **escritorio** con la persona delante (RNF-04), de modo que la **latencia del flujo de matrícula** pesa más que cualquier otra métrica. Este documento fija las metas de rendimiento, las técnicas para cumplirlas con una VM de 1 OCPU y cómo se mide. Respalda RNF-01, AC-04 y AD-02. No hay diseño ni pruebas móviles.

## 1. Metas

| Métrica | Meta | Pantallas | Condición de medición |
| :--- | :---: | :--- | :--- |
| Respuesta de las pantallas de matrícula | p95 < 1 s | Búsqueda, ficha, confirmación | 5 usuarios concurrentes (RNF-01) |
| Constancia PDF | < 3 s | Emisión | Un documento |
| Nómina o Anexo 1 de un módulo (hasta ~300 filas) | < 5 s | Reportes | Un módulo |
| Carga de pantallas principales | < 2,5 s | Inicio, listados | Conexión doméstica típica |
| Interacción (respuesta a un clic o tecla) | < 200 ms | Todas | Percentil 75 |
| Estabilidad visual (CLS) | ≤ 0,1 | Todas | Percentil 75 |

Los valores son metas iniciales y se validan en una VM de 1 OCPU.

## 2. Técnicas

| Área | Técnica |
| :--- | :--- |
| **HTML primero** | Razor Pages renderiza en el servidor; HTMX actualiza fragmentos; el contenido principal llega en el primer documento. |
| **Base de datos** | Índices de búsqueda por documento y apellidos; paginación con tope; sin consultas N+1; vistas de reporte acotadas. |
| **CSS** | Un solo archivo compilado y minificado; sin hojas de estilo de terceros bloqueantes. |
| **JavaScript** | Mínimo: HTMX y pocos scripts propios, con `defer`. |
| **Fuentes** | Autoalojadas o del sistema; `font-display: swap`; dos familias como máximo. |
| **Caché** | Recursos estáticos con huella en el nombre y caché larga; los datos de matrícula no se guardan en la caché del navegador compartido. |
| **Compresión** | Brotli o gzip en Caddy. |
| **Generación de documentos** | PDF y Excel se generan bajo demanda; los reportes grandes muestran progreso y no bloquean el resto. |
| **Doble envío** | El botón se desactiva tras el primer clic. |
| **Degradación** | Sin JavaScript, la navegación y los formularios siguen funcionando con formularios normales. |

## 3. Medición

| Herramienta | Uso | Cuándo |
| :--- | :--- | :--- |
| **Lighthouse en CI** | Puntaje y métricas de laboratorio con perfil de escritorio sobre inicio, listados y ficha. | Cada cambio de interfaz |
| **k6** | Carga ligera sobre las rutas críticas con 1 OCPU (5 usuarios). | Antes de cada despliegue mayor |
| **Observación en campo** | Una jornada real de matrícula (tiempo de una matrícula en papel frente al sistema). | Después del despliegue |

El laboratorio no sustituye al campo: si ambos difieren, manda la medición real.

## 4. Control de regresiones

El presupuesto es un criterio de la spec `web-base`. Un cambio que lo supera se corrige antes de integrarse; no se relaja la meta para que pase. Los hallazgos de rendimiento sin solución inmediata se registran como riesgo en los [drivers](../02-arquitectura-de-software/01-drivers-arquitectonicos.md).
