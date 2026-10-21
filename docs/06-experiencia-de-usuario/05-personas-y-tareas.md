# Personas y tareas

Perfiles de uso construidos a partir de los actores y las necesidades del negocio y de la entrevista. Son **hipótesis de trabajo** (no resultados de una investigación formal) que se validan con las pruebas de usabilidad. Orientan decisiones de diseño y definen las tareas que se miden. Son perfiles por rol, sin nombres propios.

## 1. Personas

| Persona | Contexto | Necesidad principal | Dispositivo | Riesgo de UX |
| :--- | :--- | :--- | :--- | :--- |
| **Personal de matrícula** (3 personas) | Atiende en el mostrador, con papeles en la mano y la persona delante; picos al inicio de cada periodo. | Registrar rápido y sin error; no volver a digitar (NN-01, NN-02, NN-15). | PC de escritorio, teclado | Interrupciones; errores de digitación; perder lo escrito. |
| **Directivo** (2 personas, incluida la Dirección) | Supervisa; revisa reportes, alertas, solicitudes de derechos y privilegios. | Ver el estado y los plazos de un vistazo; responder lo que le toca (NN-03, NN-10). | PC de escritorio | Información sepultada; no saber qué es suyo. |
| **Administrador** (hoy, el equipo desarrollador) | Gestiona usuarios, parámetros y respaldos. | Control con trazabilidad (NN-06, NN-12, NN-13). | PC de escritorio | Operaciones sensibles sin confirmación clara. |
| **Persona externa** | Recibe una constancia y quiere comprobarla. | Saber si es auténtica (NN-14). | Cualquier navegador | Respuestas ambiguas; sospecha. |
| **Persona con discapacidad visual o motriz** (usuaria de personal) | Usa lector de pantalla, teclado o ampliación. | Completar sus tareas sin barreras (NN-15). | PC con tecnología de apoyo | Controles inalcanzables, foco perdido, contraste insuficiente. |

## 2. Tareas principales y metas

| ID | Tarea | Persona | Meta de éxito | Métrica |
| :--- | :--- | :--- | :--- | :--- |
| **T-01** | Registrar la matrícula de un estudiante nuevo y emitir su constancia. | Personal de matrícula | ≥ 90 % sin ayuda | Éxito, tiempo, errores |
| **T-02** | Registrar la matrícula de un estudiante que ya existe (reutilizando sus datos). | Personal de matrícula | ≥ 90 % sin ayuda | Éxito, tiempo |
| **T-03** | Corregir un dato de una matrícula y ver el historial. | Personal de matrícula | ≥ 90 % sin ayuda | Éxito, errores |
| **T-04** | Anular una matrícula con motivo. | Personal de matrícula | ≥ 90 % sin ayuda | Éxito, errores |
| **T-05** | Ratificar a varios estudiantes al inicio del periodo. | Personal de matrícula | ≥ 90 % sin ayuda | Éxito, tiempo |
| **T-06** | Registrar una licencia y una reincorporación. | Personal de matrícula | ≥ 90 % sin ayuda | Éxito, errores |
| **T-07** | Registrar una convalidación (reincorporado o trasladado). | Personal de matrícula | ≥ 90 % sin ayuda | Éxito, errores |
| **T-08** | Generar la nómina de un módulo y el archivo para AVANZA, corrigiendo lo que falta. | Personal de matrícula | ≥ 90 % sin ayuda | Éxito, errores |
| **T-09** | Ver los matriculados por programa y turno frente al cupo y atender una alerta. | Directivo | ≥ 90 % sin ayuda | Éxito |
| **T-10** | Responder una solicitud de derechos dentro del plazo. | Directivo | ≥ 90 % sin ayuda | Éxito, errores |
| **T-11** | Aprobar el informe semestral de privilegios. | Directivo | ≥ 90 % sin ayuda | Éxito |
| **T-12** | Dar de alta un usuario, configurar su segundo factor y cambiar un parámetro. | Administrador | ≥ 90 % sin ayuda | Éxito, errores |
| **T-13** | Verificar una constancia por su código QR. | Persona externa | ≥ 90 % sin ayuda | Éxito |
| **T-14** | Completar T-01 solo con teclado y lector de pantalla. | Persona con tecnología de apoyo | Sin bloqueos críticos | Lista de verificación |
| **T-15** | Configurar el segundo factor al primer ingreso y entrar con un código. | Todo el personal | ≥ 90 % sin ayuda | Éxito, errores |

Las metas globales: ≥ 90 % de éxito sin ayuda, SUS ≥ 68 y menos de un error por tarea en promedio.

## 3. Escenarios de contexto

| Escenario | Consecuencia de diseño |
| :--- | :--- |
| Temporada de matrícula con interrupciones constantes | El borrador se guarda solo; la ficha se retoma tras una interrupción o un corte. |
| Se corta el Internet a media ficha | Aviso visible y reintento; no se confirma como guardado lo que no lo está; contingencia en papel. |
| Equipo compartido en el mostrador | Sesión de 30 minutos de inactividad, aviso previo y bloqueo; documento parcial en los listados. |
| Estudiante que reingresa | El sistema detecta el documento y reutiliza los datos. |
| Estudiante menor de la edad mínima | El rechazo explica el motivo con el valor vigente del parámetro. |
| Faltan datos que AVANZA exige | Se puede guardar; el aviso muestra qué falta; se completa después. |
| Cambio de personal | El Administrador desactiva la cuenta; el historial se conserva. |
