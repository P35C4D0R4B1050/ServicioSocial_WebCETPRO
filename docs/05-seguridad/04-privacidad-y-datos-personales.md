# Privacidad y datos personales

Aplica la Ley N.° 29733 y su reglamento (DS 016-2024-JUS) al tratamiento de los datos de estudiantes. Este documento **no es asesoría legal**: ordena qué datos se tratan, para qué, por cuánto tiempo y quién los recibe, para diseñar con criterio de minimización. Respalda RNF-14, RNF-LEG-01 a RNF-LEG-11 y AD-10. El marco completo está en el [marco legal](../01-analisis-de-sistema/03-marco-legal.md).

## 1. Roles legales

| Rol | Quién | Base |
| :--- | :--- | :--- |
| **Titular del banco de datos / responsable** | El **CETPRO** (la Dirección). Decide finalidad, contenido y medidas de seguridad. | Ley art. 2 |
| **Encargado del tratamiento** | El **equipo técnico** (servicio social UNSCH), que trata datos por encargo. | DS arts. 31 a 33 |
| **Medio tecnológico tercerizado** | **Oracle Cloud** (infraestructura), con Cloudflare como intermediario de tránsito. | DS arts. 28 a 30 |
| **Oficial de Datos Personales (ODP)** | Lo designa el CETPRO (obligatorio para entidades públicas); puede tener otras funciones o ser externo. **Pendiente de designar** (P-11). | DS arts. 37 a 39 |
| **Titulares** | Los estudiantes (parte menores de 18 años). | — |

## 2. Inventario de datos personales

| Dato | Quién lo aporta | Finalidad | Base | Dónde vive | Quién lo ve | Retención |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| Tipo y número de documento | El estudiante | Identificar; es el código de matrícula | Función pública (Ley 14.1) | `estudiante`, `matricula` | Personal de matrícula; Directivo (enmascarado en listados) | `retencion_matriculas_anios` (por definir) |
| Apellidos, nombres, sexo, fecha de nacimiento | El estudiante | Identificar y validar edad; AVANZA los exige | Función pública | `estudiante` | Ídem | Ídem |
| Grado de instrucción | El estudiante | Validar el requisito del ciclo Técnico y la ficha | Función pública | `estudiante` | Ídem | Ídem |
| Ubigeo, dirección, correo, teléfono, celular | El estudiante | AVANZA los exige (sin celdas vacías) y contacto | Función pública | `estudiante` | Ídem | Ídem |
| Programa, periodo, turno, módulo, tipo de ingreso, estado | Personal de matrícula | Registrar la matrícula | Función pública | `matricula`, `matricula_modulo` | Personal de matrícula y Directivo | Ídem |
| Derecho de inscripción, convenio y descuento (solo el resultado) | Personal de matrícula | Registrar el pago y la beca | Función pública | `pago_inscripcion`, `convenio` | Personal de matrícula; Directivo (consulta) | Ídem |
| **Situación específica** (PIR, Transitabilidad, MOT, **Discapacidad**) | Personal de matrícula | Completar la ficha oficial (Anexo 1) | Función pública; **dato sensible** (salud) | `matricula_situacion` | **Solo Personal de matrícula** (permiso específico) | Ídem; sin documentos |
| Convalidación (resolución, justificación) | Personal de matrícula | LAG 11.5 | Función pública | `convalidacion` | Personal de matrícula | Ídem |
| Constancia emitida (código, *hash*) | Sistema | Verificación | Función pública | `documento_emitido` | Personal de matrícula; verificación mínima pública | Ídem |
| Usuarios del sistema (nombres, usuario, hash de contraseña, segundo factor) | Administrador | Autenticar | Ejecución de la función | `identidad.usuario` | Administrador; el propio usuario | Mientras esté activo |
| **Bitácora** (usuario, acción, entidad, identificador, origen) | Sistema | Trazabilidad legal (DS art. 46) | Obligación legal | `auditoria.bitacora` | Directivo; Administrador (técnica) | ≥ 2 años |
| Solicitudes de derechos | Titular o Personal de matrícula | Atender derechos | Obligación legal | `solicitud_derechos` | Directivo | Por definir |
| Incidentes de seguridad | Directivo / Administrador | Cumplir arts. 34 a 36 | Obligación legal | `incidente_seguridad` | Directivo; Administrador | Por definir |
| Respaldos | Sistema | Continuidad | Obligación legal (art. 51) | Object Storage y copia en el CETPRO, **cifrados** | Administrador (sin descifrar) | Escalonada |

**No se guarda:** copia del DNI, evidencia de ingresos ni de necesidad socioeconómica, documentos de discapacidad, datos de padres o tutores (salvo identidad y dirección cuando haga falta para obtener el consentimiento de un menor), ni datos de tarjeta.

## 3. Reglas de minimización

1. Se pide solo lo necesario. Dirección, ubigeo, correo y celular se piden **porque AVANZA los exige**; la finalidad consta en el aviso y el sistema avisa antes de exportar si faltan.
2. El campo `observaciones` tiene **advertencia y límite**: no se registra salud ni ingresos.
3. La **discapacidad** se guarda solo como situación específica, restringida y sin documentos.
4. Los documentos de identidad no se muestran completos en los listados; mostrarlos queda registrado. El **código de matrícula es el número de documento** (RN-09), así que se trata igual: parcial en los listados y completo en el detalle y en los documentos oficiales que lo exigen (Anexo 1, archivos para AVANZA), donde cada exportación queda en la bitácora.
5. Nunca se usa el documento en una URL.
6. Los registros técnicos y la bitácora no contienen contraseñas ni valores sensibles: solo nombres de columnas e identificadores.
7. Los mensajes y exportaciones evitan datos personales innecesarios.
8. Las pruebas, el desarrollo y las herramientas de IA usan **solo datos sintéticos**.

## 4. Aviso de privacidad y consentimiento

| Aspecto | Decisión |
| :--- | :--- |
| Base legal | La matrícula se trata en **ejercicio de la función pública** (Ley art. 14.1): no requiere consentimiento. El consentimiento se reserva para lo adicional (fotos, mensajería, difusión), que el sistema no usa. |
| Aviso | Texto con los **diez elementos** del art. 6 del DS, en lenguaje sencillo y comprensible para adolescentes (mayores de 14), que **nombra al equipo técnico y a Oracle** y menciona el flujo hacia el exterior. |
| Versionado | Cada versión se guarda en `aviso_privacidad_version`; la matrícula guarda con cuál se informó al estudiante. |
| Evidencia | Se registra que se informó (la ficha firmada en papel sigue siendo del CETPRO). |
| Menores | Se informa en lenguaje claro; no se piden datos de padres salvo cuando haga falta. |

## 5. Derechos de los titulares

| Derecho | Plazo (días hábiles) | Cómo se ejerce |
| :--- | :---: | :--- |
| **Información** | 8 | Solicitud registrada; respuesta del Directivo. |
| **Acceso** | 20 | Idem. |
| **Rectificación** | 10 | El Personal de matrícula corrige el dato con registro del cambio. |
| **Cancelación** | 10 | Se evalúa frente a la obligación legal de conservar; si procede, se suprime o anonimiza. |
| **Oposición** | 10 | Solicitud registrada con estado. |

Los plazos son ampliables **una sola vez** por igual plazo, con justificación, **salvo el del derecho de información** (DS art. 71.1), y la justificación se comunica al titular dentro del plazo que se amplía (71.2). Los plazos se cuentan desde el día siguiente de la presentación (art. 69). Si la solicitud llega al equipo técnico (encargado), este la traslada al CETPRO en un máximo de **3 días** (art. 66.4). El sistema registra la recepción, calcula la fecha límite y **alerta** a la mitad del plazo y dos días antes. La portabilidad no aplica al tratamiento necesario para competencias públicas (art. 76.6).

## 6. Transferencias y proveedores

| Proveedor | Datos que recibe | Ubicación probable | Observaciones |
| :--- | :--- | :--- | :--- |
| **Oracle Cloud** | Todos los datos del sistema (infraestructura). | Región de origen elegida; fuera del Perú | Servicio tercerizado (arts. 28 a 30); **comunicar el flujo transfronterizo** (art. 21.2); revisar el contrato. |
| **Cloudflare** | Tráfico (direcciones IP, cabeceras, contenido mientras viaja). | Red global | Intermediario de tránsito; no guarda datos. |
| **Healthchecks** | Solo latidos, sin datos personales. | Externa | Configuración sin datos. |
| **Object Storage (Oracle)** | Copias cifradas de la base y de la bitácora. | Región de origen | Cifrado por el CETPRO; sin datos en claro. |
| **UGEL / DRE** | Informes cuando correspondan. | Perú | Transferencia entre entidades públicas. |
| **AVANZA (Minedu)** | Lo que el CETPRO carga a mano. | Perú | El sistema no transmite; solo genera archivos. |
| **Herramientas de IA de desarrollo** | **Ningún dato personal real.** | Fuera del Perú (probable) | Regla de AD-36. |

## 7. Retención y borrado

| Dato | Plazo | Mecanismo |
| :--- | :--- | :--- |
| Bitácora | ≥ 2 años (`retencion_bitacora_anios`) | Depuración autorizada de lo anterior a la retención; copia en el CETPRO. |
| Fichas, matrículas y constancias | **Por definir con la UGEL/AGN** (`retencion_matriculas_anios`) | Anonimización o depuración con constancia (RF-38). |
| Solicitudes de derechos e incidentes | Por definir | Parámetro de retención. |
| Cuenta desactivada | Mientras sea necesario para la trazabilidad | Se conserva el historial; no se borra. |
| Respaldos | Escalonada (diarios, semanales, mensuales) | Un dato suprimido desaparece del respaldo cuando este rota. |

El encargado (el equipo) conserva datos como máximo **2 años** desde el último encargo y luego los devuelve (DS art. 32).

## 8. Incidentes de seguridad con datos personales

1. **Documentar todo incidente** (hechos, efectos y medidas): art. 35.
2. **Evaluar** si el incidente expone grandes volúmenes, afecta a muchas personas, involucra datos sensibles o causa perjuicio evidente.
3. Si corresponde, **notificar a la autoridad dentro de 48 horas** de conocido (y al titular si lo afecta; y al Centro Nacional de Seguridad Digital si es digital): art. 34. Si tarda más, se explican los motivos.
4. **Contener, recuperar, corregir y aprender.**
5. El encargado informa **de inmediato** al responsable (art. 36).

Con datos de adolescentes y de discapacidad, casi cualquier fuga relevante activa la notificación. No notificarla es infracción grave (art. 133.12).

## 9. Banco de datos, ODP y evaluación de impacto

| Obligación | Estado |
| :--- | :--- |
| Inscribir el banco «Estudiantes y matrículas» en el Registro Nacional (gratuito, aprobación automática) | Pendiente (Dirección) |
| Designar y publicar al ODP; comunicarlo en 15 días | Pendiente (Dirección) |
| Resolución directoral que designa al responsable y al ODP | Pendiente |
| Comunicar el flujo transfronterizo hacia la región de Oracle | Pendiente |
| Documento de seguridad con fecha cierta | Pendiente; se alimenta de esta carpeta |
| Acuerdo de encargo y confidencialidad con el equipo | Pendiente |
| Evaluación de impacto breve (facultativa; basada en NTP-ISO/IEC 27005 y NTP-ISO 31000) | Recomendada |
