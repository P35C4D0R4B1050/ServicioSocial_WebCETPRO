# Módulos y contratos

Describe los módulos del monolito y la forma de sus contratos. Es un diseño de **nivel de módulo**: los nombres de clases, rutas exactas y esquemas se fijan en el `plan.md` de cada spec; aquí se establece el marco común. Al ser un **monolito modular**, los contratos entre módulos son **interfaces de la capa de Aplicación**, no APIs REST entre servicios. Solo hay un puñado de puntos HTTP públicos (sección 4).

## 1. Mapa de módulos

| Módulo | Casos de uso agrupados | Specs |
| :--- | :--- | :--- |
| **M1 Identidad y accesos** | Ingreso y segundo factor; usuarios y roles; permisos; informe semestral de privilegios; restablecimiento de acceso. | `identidad-seguridad` |
| **M2 Parámetros** | Consultar y editar parámetros; historial; aviso de cambios críticos. | `parametros-institucionales` |
| **M3 Catálogo académico** | Programas, familias, planes con resolución, módulos, unidades; periodos lectivos, ofertas y docentes. | `catalogo-academico`, `periodos-ofertas` |
| **M4 Matrícula** | Estudiantes y búsqueda; registrar, editar y anular matrícula; ratificar; licencia y reincorporación; convalidación; convenios, becas y derecho de inscripción; situación específica; borradores; requisitos. | `estudiantes`, `matricula-registro`, `matricula-ratificacion-licencia`, `matricula-convalidacion`, `matricula-becas` |
| **M5 Documentos y reportes** | Constancia con QR; verificación pública; nómina; Anexo 1; matriculados por oferta; archivos para AVANZA con validación previa. | `docs-constancia`, `docs-reportes`, `docs-archivos-avanza` |
| **M6 Cumplimiento, auditoría y alertas** | Bitácora (consulta); aviso de privacidad; solicitudes de derechos; incidentes; retención; alertas. | `transversal-auditoria`, `cumplimiento-privacidad`, `transversal-alertas` |
| **Plataforma** | Compose, respaldos, `keepalive`, infraestructura como código. | `operacion-despliegue` |
| **Web** | Estructura de la interfaz, sesión, errores, estados, cabeceras, accesibilidad. | `web-base` |

Cada módulo es una carpeta dentro de las capas Aplicación y Dominio; no es un proyecto aparte.

## 2. Contratos entre módulos

Un módulo **no usa las entidades de otro**. Se comunican por interfaces de Aplicación con datos simples. M2 es un servicio base: todos los módulos pueden leer parámetros por su puerto y M2 no depende de nadie (la auditoría de sus cambios pasa por `Compartido`).

| De → a | Contrato (ilustrativo) | Para qué |
| :--- | :--- | :--- |
| M4 → M3 | Consultar oferta activa, programa y su ciclo, módulos del programa, periodo lectivo vigente. | Validar la matrícula y derivar el módulo. |
| M4 → M2 | Leer `edad_minima`, `edad_referencia`, `beca_porcentaje_maximo`, `convalidacion_similitud_minima`, `requisitos_matricula`. | Aplicar las reglas configurables y guardar el valor aplicado. |
| M1 → M2 | Leer `password_minimo`, `sesion_inactividad_min`, `sesion_maxima_horas`, `bloqueo_intentos`, `bloqueo_minutos`, `revision_privilegios_meses`. | Aplicar las políticas de acceso. |
| M3 → M2 | Leer `cupo_referencial`, `periodo_semanas`, `periodos_por_anio`. | Oferta y periodos. |
| M6 → M2 | Leer `plazo_registro_matricula_dias`, `alerta_*`, `retencion_*`, `oficial_datos`. | Alertas, retención y aviso. |
| M5 → M4 | Consultar matrículas vigentes, estudiantes, módulos y campos faltantes. | Generar constancia, nómina, Anexo 1 y archivos. |
| M5 → M3 | Consultar programa, plan y módulo con su resolución. | Rotular documentos y archivos del plan. |
| M5 → M2 | Leer datos de `institucion` y el mapeo de columnas. | Encabezados del Anexo 1 y formato de AVANZA. |
| M1 a M5 → puertos de `Compartido` (los implementa M6) | Registrar evento de bitácora; crear o cerrar una alerta. | Auditoría y recordatorios, **sin que M1 a M5 dependan de M6**. |
| M6 → M1 | Consultar destinatarios por rol. | Dirigir alertas. Es la **única** dependencia de M6 hacia otro módulo. |

La base de datos es una sola, pero las lecturas de otro módulo se hacen por **vistas de reporte** o por su contrato, no por tablas ajenas. Las vistas están en el [esquema SQL](../../db/esquema_matricula_cetpro_v1.1.sql): `v_nomina_matriculados`, `v_matriculados_por_oferta`, `v_registro_matricula_cabecera`, `v_registro_matricula_unidades`, `v_exportacion_avanza_estudiantes`, `v_datos_faltantes_exportacion`, `v_exportacion_avanza_modulos`.

## 3. Convenciones de las rutas web

La interfaz se renderiza en servidor con Razor Pages y HTMX. No hay API pública general.

| Tema | Convención |
| :--- | :--- |
| Rutas | En español, en minúsculas y con guiones, por recurso: `/estudiantes`, `/matriculas`, `/catalogo/programas`, `/reportes`, `/administracion/usuarios`. |
| Identificadores | **Opacos** (`uid` UUID). **Nunca se usa el documento en una URL** (AD-17). |
| Verbos | `GET` para leer; `POST` para crear o ejecutar una acción con nombre (`/matriculas/{uid}/anular`); formularios con protección CSRF. |
| Fragmentos HTMX | Rutas bajo el mismo recurso con `?fragmento=` o encabezado `HX-Request`; devuelven HTML parcial. |
| Paginación | `?pagina=1&tamano=20` con tope; respuesta con el total. |
| Filtros y orden | `?q=`, `?programa=`, `?periodo=`, `?turno=`, `?orden=`; solo campos permitidos. |
| Concurrencia | El formulario envía `version`; un conflicto devuelve el aviso de «alguien modificó esta matrícula». |
| Idempotencia | Los botones se desactivan tras el primer envío; el servidor ignora el reenvío del mismo token. |
| Descargas | `Content-Disposition` con el nombre del documento; la exportación queda en la bitácora. |
| Trazabilidad | Identificador de seguimiento (`traceId`) en cada respuesta de error. |

## 4. Puntos HTTP no interactivos

| Ruta | Quién | Autenticación | Notas |
| :--- | :--- | :--- | :--- |
| `/verificar/{codigo}` | Persona externa | Ninguna | Respuesta **mínima y uniforme**, con límite de tasa por origen (RF-28). |
| `/salud/viva` y `/salud/lista` | Docker y monitoreo | Ninguna, sin datos | *Healthchecks* de la aplicación y de la BD. |
| Latido a Healthchecks | VM-APP y VM-DB | Saliente | Enviado por `keepalive`. |

## 5. Contrato de errores

Los errores de negocio se muestran en la interfaz con un mensaje que dice **qué pasó y qué hacer**. Los puntos no interactivos devuelven `application/problem+json`.

```json
{
  "type": "https://cetpro.local/errores/edad-minima",
  "title": "La edad mínima no se cumple",
  "status": 422,
  "code": "MAT-EDAD-MINIMA",
  "traceId": "00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01"
}
```

| Campo | Regla |
| :--- | :--- |
| `code` | Estable, en mayúsculas con guiones, con el **prefijo de la spec** que lo origina (`AUD-`, `PAR-`, `IDE-`, `WEB-`, `OPS-`, `CAT-`, `OFE-`, `EST-`, `MAT-`, `RAT-`, `CON-`, `BEC-`, `CST-`, `REP-`, `AVZ-`, `PRI-`, `ALE-`), por ejemplo `MAT-EDAD-MINIMA`. La interfaz y las pruebas dependen de él, no del texto. |
| `title` y mensaje | Genéricos y en español; sin trazas, rutas internas ni nombres de tablas. |
| `status` | 400 validación; 401 sin sesión; 403 sin permiso; 404 no existe o no visible; 409 conflicto de estado o concurrencia; 422 regla de negocio; 429 límite de uso; 503 dependencia no disponible. |
| Validación | Lista de campos inválidos con su motivo, sin eco del valor sensible. |

## 6. Datos que cruzan la frontera de la aplicación

| Dato | Entra por | Sale por | Regla |
| :--- | :--- | :--- | :--- |
| Ficha del estudiante | Formulario | Pantalla, constancia | Solo datos mínimos; sin copia del DNI. |
| Plantillas de AVANZA | Parámetro de mapeo | Archivo Excel | Celdas saneadas; sin credenciales de AVANZA. |
| Constancia | — | PDF con QR | Código único y *hash*. |
| Respaldo | — | Object Storage y copia en el CETPRO | Cifrado con clave del CETPRO. |
| Bitácora | Aplicación y disparadores | Consulta y copia en el CETPRO | Solo inserción. |

## 7. Evolución de contratos

1. Un cambio compatible (campo opcional nuevo) no exige aviso.
2. Un cambio de esquema se hace con una **migración versionada** y una prueba de integración.
3. Los campos retirados se marcan como obsoletos antes de eliminarse.
4. Cada contrato entre módulos tiene una prueba en el módulo que lo publica.
