# Glosario

Lenguaje común del dominio. El código, las specs y la interfaz usan estos términos. Si un término nuevo aparece en una spec, se agrega aquí. Los nombres oficiales (programa de estudios, módulo formativo, unidad didáctica, ciclo, constancia de estudios) vienen de la LAG y de AVANZA (AD-25).

## Académico

| Término | Definición | No confundir con |
| :--- | :--- | :--- |
| **Programa de estudios** | Lo que la entrevista llama «especialidad». Se ofrece en un ciclo y con un mínimo de créditos. | Familia profesional, que agrupa programas. |
| **Ciclo** | **Auxiliar Técnico** (≥ 40 créditos, un año) o **Técnico** (≥ 80 créditos, dos años; exige primaria completa). | «Modalidad», que en el Anexo 1 es presencial, semipresencial o a distancia. |
| **Familia profesional** | Agrupación de programas afines. | Programa. |
| **Plan de estudios** | Estructura autorizada de un programa: módulos y unidades. Lleva la **resolución de autorización** (tipo, número y año), que AVANZA exige antes de registrar módulos. | Programa. |
| **Módulo formativo** | Parte del plan con competencias propias. La matrícula indica el módulo que se cursa. | Unidad didáctica. |
| **Unidad didáctica** | Unidad mínima del plan, con créditos y horas. Se **deriva del módulo**; solo se registran sus excepciones. | Módulo. |
| **Periodo lectivo** | Periodo calendario habilitado en AVANZA para registrar la información, por ejemplo `2026-I` (con fechas de periodo y de clases). | Periodo académico. |
| **Periodo académico** | Unidad de tiempo del programa que reúne un conjunto de unidades didácticas; en los CETPRO públicos dura **18 semanas** y tiene como máximo 24 créditos (LAG 19.1). La matrícula se ratifica en cada uno. En la matrícula por módulo se guarda su número ordinal (primero, segundo…). | Periodo lectivo. |
| **Oferta** | Programa dictado en un periodo lectivo y un turno, con docente y cupo referencial. | Programa. |
| **Turno** | Catálogo configurable; hoy, mañana y tarde (entrevista). | Horario. |
| **Cupo referencial** | Cifra orientativa por oferta (inicialmente 30). **No es un límite**: no hay tope de vacantes. | Vacantes. |

## Matrícula

| Término | Definición | No confundir con |
| :--- | :--- | :--- |
| **Matrícula** | Inscripción de un estudiante en una oferta, con el módulo que cursa. Una sola vigente por estudiante, programa y periodo lectivo. | Ratificación. |
| **Código de matrícula** | El **número del documento** del estudiante (LAG 11.2.2). Lo asigna la base de datos. | Un correlativo propio. |
| **Documento de identidad** | DNI, carné de extranjería, pasaporte o PTP. | Copia del DNI, que **no se guarda**. |
| **Tipo de ingreso** | Nuevo, ratificación, reincorporación, trasladado o retirado anteriormente. | Estado. |
| **Estado de la matrícula** | Vigente, anulada, retirada o licencia. Anular es un estado, nunca un borrado. | Tipo de ingreso. |
| **Ratificación** | Confirmación de la matrícula en cada periodo académico; crea una matrícula nueva enlazada a la anterior. | Matrícula nueva. |
| **Licencia de estudios** | Reserva de la matrícula sin invocar causa, por un periodo no mayor a la duración del programa. | Retiro. |
| **Reincorporación** | Regreso dentro del plazo de reserva; crea una matrícula nueva. Si vence el plazo, se pierde el derecho de matrícula. | Ratificación. |
| **Convalidación** | Reconocimiento de aprendizajes por **resolución directoral**, con justificación y ruta formativa complementaria. Entre planes exige ≥ 80 % de contenido similar (parámetro). | Subsanación. |
| **Subsanación** | Unidad que el estudiante debe cursar o recuperar fuera del módulo regular. | Convalidación. |
| **Situación específica** | Dato restringido de la ficha (PIR, Transitabilidad, MOT, Discapacidad, otras). Sin documentos ni diagnósticos. | Observaciones libres. |
| **Derecho de inscripción** | Pago de inscripción. El sistema lo **registra**; no cobra. | Beca. |
| **Convenio, beca o exoneración** | Descuento por convenio institucional hasta un tope (parámetro, inicialmente 50 %). Se guarda el resultado, nunca la evidencia de ingresos. | Pago. |

## Documentos y AVANZA

| Término | Definición | No confundir con |
| :--- | :--- | :--- |
| **Constancia de estudios** | PDF con código único y QR de verificación; acredita que el estudiante cursa un módulo o programa (LAG 12.1). Es la «constancia de matrícula» de la entrevista. | Certificado de estudios (notas), fuera de alcance. |
| **Nómina de matriculados** | Lista de matriculados vigentes, filtrable por programa, módulo, periodo y turno. | Registro de matrícula. |
| **Registro de matrícula (Anexo 1)** | Ficha oficial de la RVM 188-2020, por programa, módulo y periodo. | Ficha impresa que firma el estudiante. |
| **AVANZA** | Sistema de Gestión Docente del Minedu. **No tiene API**; su carga es manual y queda **fuera del sistema**. | Una integración de este sistema. |
| **Archivo para AVANZA** | Excel con el formato de sus plantillas (estudiantes y módulos). El sistema lo **genera**; el CETPRO lo carga por su cuenta. | Carga en AVANZA. |
| **Datos faltantes** | Campos que AVANZA exige (no admite celdas vacías) y que el estudiante aún no tiene. El sistema avisa antes de exportar. | Error de RENIEC. |

## Seguridad, privacidad y cumplimiento

| Término | Definición | No confundir con |
| :--- | :--- | :--- |
| **Rol** | Personal de matrícula, Directivo, Administrador o Persona externa (solo verifica una constancia). | Permiso. |
| **Permiso** | Capacidad granular asignada a un rol (por ejemplo `MATRICULA_ANULAR`). | Rol. |
| **Segundo factor (TOTP)** | Código temporal de una aplicación, obligatorio para todo el personal. | Contraseña. |
| **Bitácora** | Registro de solo inserción de sesión, lecturas, modificaciones, eliminaciones, importaciones y exportaciones; conserva ≥ 2 años (DS art. 46). | Log técnico. |
| **Parámetro institucional** | Valor configurable y versionado para reglas no formalizadas (edad mínima, plazos, topes). Cada acto guarda el valor aplicado. | Constante del código. |
| **Alerta** | Aviso dentro del sistema, por rol, con ciclo Activa → Atendida o Descartada. No se envía por correo ni mensajería. | Aviso técnico al equipo. |
| **Aviso de privacidad** | Texto versionado con los diez elementos del art. 6 del DS 016-2024-JUS y evidencia de aceptación. | Política de cookies. |
| **Solicitud de derechos (ARCO)** | Información, acceso, rectificación, cancelación u oposición del titular, con plazo de 8, 20 o 10 días hábiles. | Reclamo. |
| **Incidente de seguridad** | Evento que afecta datos personales. Se documenta siempre; se notifica en 48 h si cumple las condiciones del art. 34. | Falla técnica sin datos. |
| **ODP** | Oficial de Datos Personales; obligatorio para entidades públicas. | Administrador del sistema. |
| **Responsable / Encargado** | El CETPRO es el **responsable** (titular del banco de datos); el equipo técnico es el **encargado**. | — |
| **Dato sintético** | Dato ficticio y reconocible (por ejemplo apellido «PRUEBA»). Es el único que puede usarse en desarrollo, pruebas e IA. | Dato real «anonimizado». |
| **Amenaza (AM)** | Escenario de abuso del modelo de amenazas (`AM-01`…). | Riesgo del proyecto (`R-`). |
| **Control (CTL)** | Verificación de seguridad basada en ASVS (`CTL-01`…). | Requisito de una spec. |

## Operación

| Término | Definición | No confundir con |
| :--- | :--- | :--- |
| **Reclamación de instancia** | Acción de Oracle sobre una instancia Always Free inactiva (siete días con CPU, red y memoria bajo 20 %). | Falla de la VM. |
| **`keepalive`** | Script calibrado que evita que una VM parezca inactiva. | Respaldo. |
| **Contingencia en papel** | Procedimiento con la ficha oficial y carga posterior cuando no hay Internet u Oracle falla. | Modo degradado local. |
| **RPO / RTO** | Pérdida máxima de datos aceptable / tiempo máximo para recuperar el servicio (≤ 24 h y ≤ 4 h). | — |

## Método

| Término | Definición |
| :--- | :--- |
| **SDD** | *Spec-Driven Development*: la especificación aprobada manda y el código la demuestra. |
| **Spec** | Descripción del comportamiento de una funcionalidad en EARS, sin tecnología. |
| **EARS** | *Easy Approach to Requirements Syntax*: plantillas ubicua, de evento, de estado, de comportamiento no deseado y opcional. |
| **Criterio de aceptación** | Escenario que cubre uno o más requisitos; se identifica como `AC-<MÓDULO>-<NN>` y tiene prueba. |
| **Puerta humana** | Decisión que siempre toma una persona: aprobar la spec y aprobar el plan. |
| **Puerto / Adaptador** | Interfaz definida en la Aplicación para algo externo / su implementación en Infraestructura. |
| **Convergencia** | Estado en que la spec, el código y las pruebas coinciden. |
| **`AGENTS.md`** | Constitución del proyecto: reglas obligatorias para personas y agentes de IA. |
