# Actores y permisos

Este documento amplía los actores de la [necesidad del negocio](01-necesidad-del-negocio.md) con lo que cada uno puede hacer y hasta dónde llega. Es la base del control de acceso (RN-07, RF-20) y de los casos de abuso del [modelo de amenazas](../05-seguridad/01-modelo-de-amenazas.md). Las atribuciones salen del ERS y de la entrevista: **3 encargados de matrícula** y **2 directivos que ven reportes**. El rol Administrador es una **propuesta** para tareas técnicas.

**El sistema respeta la forma de trabajo actual del CETPRO**: no impone quién realiza tareas que ocurren fuera de él (por ejemplo, quién carga en AVANZA ni cómo se firma la ficha en papel).

## 1. Roles del sistema

| Rol | Cómo se identifica | Alcance | Segundo factor |
| :--- | :--- | :--- | :---: |
| **Personal de matrícula** | Cuenta creada por el Administrador. 3 personas. | Operación de matrícula, catálogo, documentos y reportes. | **Sí (TOTP)** |
| **Directivo** | Cuenta creada por el Administrador. 2 personas. | Consulta de reportes, nóminas y bitácora; respuesta a solicitudes de derechos; aprobación del informe de privilegios. Sin editar matrículas. | **Sí (TOTP)** |
| **Administrador** | Cuenta creada por el Administrador inicial. 1 o 2 personas. **Por ahora, el equipo desarrollador; luego, la Dirección.** | Usuarios, parámetros, respaldos y tareas técnicas. **Sin acceso a datos de estudiantes por defecto.** | **Sí (TOTP)** |
| **Persona externa** | Sin cuenta. | Verificar una constancia por su código QR (respuesta mínima y con límite de tasa). | No |

Cuentas previstas: **cinco del personal** (3 de matrícula y 2 directivos) y **una o dos de Administrador**; las cifras de uso concurrente (RNF-03) cuentan solo al personal. No hay autorregistro. Las altas, bajas y restablecimientos los hace el Administrador y quedan en la bitácora. Mientras el Administrador sea el equipo desarrollador, actúa como **encargado del tratamiento** (DS arts. 31 a 33): su acceso a datos queda sujeto al acuerdo de encargo y a la bitácora técnica.

## 2. Matriz de permisos por capacidad

**Convenciones:** ● permitido; ◐ solo consulta; — no permitido. Los valores son **iniciales**, editables por el Administrador con auditoría (RF-39) y por **validar con la Dirección** (P-03).

| Capacidad | Personal de matrícula | Directivo | Administrador | Público | Spec |
| :--- | :---: | :---: | :---: | :---: | :--- |
| Registrar y editar estudiantes y matrículas (RF-01 a RF-04) | ● | — | — | — | `estudiantes`, `matricula-registro` |
| **Anular** una matrícula, con motivo (RF-08) | ● | — | — | — | `matricula-registro` |
| Ratificar, licencia, reincorporación (RF-21 a RF-23) | ● | — | — | — | `matricula-ratificacion-licencia` |
| Convalidación (RF-05) | ● | — | — | — | `matricula-convalidacion` |
| Becas y derecho de inscripción (RF-06, RF-07) | ● | ◐ | — | — | `matricula-becas`, `matricula-registro` |
| Catálogo: programas, planes, módulos, unidades, periodos, ofertas, docentes | ● | ◐ | — | — | `catalogo-academico`, `periodos-ofertas` |
| Consultar matrículas y matriculados (RF-12) | ● | ● | — | — | `docs-reportes` |
| Emitir **constancia de estudios** (RF-16) | ● | — | — | — | `docs-constancia` |
| Generar **nómina**, **Anexo 1** y **archivos para AVANZA** (RF-17, RF-26, RF-27) | ● | ● | — | — | `docs-reportes`, `docs-archivos-avanza` |
| Ver la **situación específica** (por ejemplo discapacidad) | ● | — | — | — | `estudiantes` |
| Verificar una constancia por QR (respuesta mínima) | — | — | — | ● | `docs-constancia` |
| Ver **alertas** | Las suyas | Las suyas | Las técnicas | — | `transversal-alertas` |
| Consultar la **bitácora** | — | ● | Técnica, sin datos del estudiante | — | `transversal-auditoria` |
| **Usuarios**: altas, bajas, segundo factor, permisos | — | — | ● | — | `identidad-seguridad` |
| Aprobar el **informe semestral de privilegios** | — | ● | — | — | `identidad-seguridad` |
| **Parámetros institucionales** | ◐ | ◐ y recibe aviso de cambios | ● edita | — | `parametros-institucionales` |
| Solicitudes de derechos: registrar / responder | Registra | Responde | — | — | `cumplimiento-privacidad` |
| Incidentes de seguridad | — | ● | ● | — | `cumplimiento-privacidad` |
| Respaldos, restauración y salud del servicio | — | — | ● | — | `operacion-despliegue` |

## 3. Permisos granulares (valores iniciales de la base de datos)

La tabla `identidad.permiso` y su asignación inicial en `identidad.rol_permiso` están en el [esquema SQL v1.1](../../db/esquema_matricula_cetpro_v1.1.sql). La aplicación autoriza con estos códigos, no con el nombre del rol.

| Permiso | Personal de matrícula | Directivo | Administrador |
| :--- | :---: | :---: | :---: |
| `ESTUDIANTE_MATRICULA_ESCRIBIR` | ● | | |
| `MATRICULA_ANULAR` | ● | | |
| `MATRICULA_RATIFICAR` | ● | | |
| `LICENCIA_REGISTRAR` | ● | | |
| `CONVALIDACION_REGISTRAR` | ● | | |
| `BECA_PAGO_ESCRIBIR` | ● | | |
| `BECA_PAGO_CONSULTAR` | ● | ● | |
| `CATALOGO_ESCRIBIR` | ● | | |
| `CATALOGO_CONSULTAR` | ● | ● | |
| `MATRICULA_CONSULTAR` | ● | ● | |
| `CONSTANCIA_EMITIR` | ● | | |
| `REPORTE_GENERAR` | ● | ● | |
| `SITUACION_ESPECIFICA_VER` | ● | | |
| `ALERTAS_VER` | ● | ● | |
| `ALERTAS_TECNICAS_VER` | | | ● |
| `BITACORA_CONSULTAR` | | ● | |
| `BITACORA_TECNICA_CONSULTAR` | | | ● |
| `USUARIOS_ADMINISTRAR` | | | ● |
| `PRIVILEGIOS_APROBAR` | | ● | |
| `PARAMETROS_CONSULTAR` | ● | ● | ● |
| `PARAMETROS_EDITAR` | | | ● |
| `DERECHOS_REGISTRAR` | ● | | |
| `DERECHOS_RESPONDER` | | ● | |
| `INCIDENTES_GESTIONAR` | | ● | ● |
| `RESPALDOS_ADMINISTRAR` | | | ● |

## 4. Identidades que no son personas

| Identidad | Para qué | Cómo se protege |
| :--- | :--- | :--- |
| **Cuenta de aplicación en la base de datos (`cetpro_app`)** | La aplicación se conecta a PostgreSQL. | Mínimo privilegio: sin `DELETE` general, sin permiso de modificar la bitácora, sin propiedad de las tablas. |
| **Cuenta de migraciones** | Aplicar cambios de esquema. | Rol propietario, distinto de la aplicación; se usa solo en el despliegue. |
| **Cuenta de respaldo / solo lectura** | Respaldos y reportes. | Solo lectura; la clave de cifrado la custodia el CETPRO. |
| **Tareas programadas** | Alertas, retención, `keepalive`. | Corren dentro de la aplicación o la VM con permisos mínimos y registran su actividad. |
| **Agentes de IA de desarrollo** | Apoyan la escritura de specs y código. | **Sin acceso a producción ni a secretos**; solo datos sintéticos (AD-36). |

## 5. Actor malicioso

No es un rol: es un modelo para pensar en abusos. Se describe en el [modelo de amenazas](../05-seguridad/01-modelo-de-amenazas.md) con los casos más probables: abuso interno (consultar o vender listas de estudiantes), relleno de credenciales, falsificación de constancias y exfiltración por una vulnerabilidad.

## 6. Reglas

1. **Mínimo privilegio y denegar por defecto**: una función sin permiso explícito no está disponible.
2. El Directivo **nunca edita** matrículas ni datos de estudiantes.
3. El Administrador **no ve datos de estudiantes** salvo lo necesario y registrado.
4. La bitácora es de solo inserción: ningún rol, incluido el Administrador, puede modificarla ni borrarla (solo la depuración autorizada por retención).
5. Cambiar el rol o los permisos de un usuario se registra y surte efecto en la siguiente renovación de sesión.
6. Toda persona con acceso firma un **acuerdo de confidencialidad** (ISO 27002, 6.6).
7. Los privilegios se **revisan al menos cada seis meses** (DS art. 46); el Directivo aprueba el informe.
