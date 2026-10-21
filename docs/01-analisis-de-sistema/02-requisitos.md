# Requisitos

Los requisitos derivan de las necesidades de la [necesidad del negocio](01-necesidad-del-negocio.md). Conservan los códigos del ERS v1.1 (**no se renumeran**). Se dividen en reglas de negocio (RN), funcionales (RF), no funcionales (RNF, RNF-LEG) y restricciones (RC). Los casos de uso (CU) están en los [procesos de negocio](06-procesos-de-negocio.md).

**Estado:** V Vigente, M Modificado, N Nuevo, R Retirado. **Prioridad:** MVP (iteración 1), It. 2, It. 3.

## 1. Reglas de negocio

| Cód. | Regla de negocio | Estado | Origen |
| :--- | :--- | :---: | :--- |
| RN-01 | La **edad mínima** para matricularse es un **parámetro** (`edad_minima`); valor inicial **16 años** (regla institucional); el piso nacional es 14. La fecha con la que se mide la edad también es configurable. | M | Entrevista; DL 1375; LAG 11.2.1 |
| RN-02 | Para matricularse se exige **documento de identidad** (DNI, carné de extranjería, pasaporte o PTP) y el **derecho de inscripción** (monto por definir). | M | Entrevista; AVANZA |
| RN-03 | El CETPRO ofrece **programas de estudios** en dos ciclos: **Auxiliar Técnico** (≥ 40 créditos, un año) y **Técnico** (≥ 80 créditos, dos años). Los programas se registran, activan y desactivan según la oferta de cada año. | M | LAG; entrevista |
| RN-04 | Cada programa se dicta en **turnos** (catálogo configurable; hoy, mañana y tarde). No hay límite estricto de vacantes; el **cupo referencial** (30) es un parámetro orientativo. | M | Entrevista; LAG 11.1 |
| RN-05 | El estudiante **reincorporado, trasladado o que se retiró antes** se matricula en el programa del que procede si sus módulos o plan son **convalidables** (tipos de la LAG 11.5). | M | Entrevista; LAG |
| RN-06 | Los **convenios** pueden otorgar **becas o exoneraciones** hasta un **tope** (parámetro, inicial 50 %). Solo se registra el resultado, **no la evidencia de ingresos**. | M | Entrevista; Ley 29733 art. 2 |
| RN-07 | El acceso está restringido a usuarios autorizados con **credenciales individuales y segundo factor**. | M | Entrevista; ISO 27002 |
| RN-08 | ~~El sistema operará solo en la red local, en un máximo de 3 equipos.~~ Reemplazada por RC-02 (nube) y RNF-08. | R | Decisión del equipo |
| RN-09 | El **código de matrícula** es el **número del documento** del estudiante y es único durante todo el programa. | N | LAG 11.2.2 |
| RN-10 | La **matrícula se ratifica en cada periodo académico** (18 semanas en CETPRO públicos); es requisito para mantener la condición de estudiante. | N | LAG 11.2.2, 19.1 |
| RN-11 | El estudiante puede solicitar **licencia de estudios** sin invocar causa, por un periodo no mayor a la duración del programa. La **reincorporación** se hace dentro del plazo de reserva (parámetro, por definir); si vence, pierde el derecho de matrícula, pero puede volver a inscribirse. | N | LAG 11.3, 11.4 |
| RN-12 | La **convalidación** se registra por **resolución directoral**, con justificación y ruta formativa complementaria. Entre planes exige **≥ 80 % de contenido similar** (parámetro). | N | LAG 11.5 |
| RN-13 | Un estudiante tiene **una sola matrícula vigente** por programa y periodo lectivo. | N | Informe 004; diseño |
| RN-14 | El **ciclo Técnico** exige haber concluido **primaria** o el ciclo intermedio de EBA; se verifica el certificado de estudios. | N | LAG 11.2.1 |
| RN-15 | **Anular** una matrícula exige **motivo**; la anulación es un estado, **nunca un borrado**. | N | RF-08; ISO 27002 |
| RN-16 | El **registro de matrícula debe cargarse en AVANZA dentro del mes** siguiente al inicio del periodo (obligación del CETPRO; incumplirla es infracción grave). El sistema **alerta** el plazo. | N | LAG 17.1; manual de AVANZA |
| RN-17 | Los datos personales se usan **solo para la función educativa**; no se guarda copia del DNI, evidencia socioeconómica ni documentos de discapacidad. | N | Ley 29733; DS 016-2024-JUS |

### 1.1 Catálogo de programas de estudios (oferta 2026, según la entrevista)

**Ciclo Técnico (dos años):** Estilismo; Fabricación de prendas de vestir; Mantenimiento de sistemas electrónicos.

**Ciclo Auxiliar Técnico (un año):** Soporte técnico y operación de centros de cómputo; Apoyo administrativo; Servicios básicos gastronómicos; Panadería y pastelería; Mantenimiento básico de casas y edificios; Cuidado de niños y adulto mayor; Soldadura metálica.

**Oferta histórica** (registrable, activable o desactivable por el personal): Computación e Informática, Costura y Acabado, Gastronomía, Asistencia de Contabilidad, Electrónica, Peluquería y Barbería, Mantenimiento de casas. La entrevista habla de «13 especialidades» pero lista 10 mezclando la oferta histórica y la de 2026: **el catálogo es configurable**.

## 2. Requisitos funcionales

### 2.1 Matrícula (M4)

| Cód. | Requerimiento | Prior. | Est. | Necesidad |
| :--- | :--- | :---: | :---: | :--- |
| RF-01 | Permitir **registrar una nueva matrícula** con obligatorios: tipo y número de documento, apellido paterno y materno, nombres, sexo, fecha de nacimiento, grado de instrucción, programa, periodo lectivo, turno y módulo. Dirección, ubigeo, correo, teléfono y celular se solicitan porque AVANZA los exige y son configurables. | MVP | M | NN-01 |
| RF-02 | **Validar la edad mínima** (`edad_minima`) antes de completar la matrícula y guardar el valor aplicado. | MVP | M | NN-01, NN-12 |
| RF-03 | Permitir **seleccionar programa, periodo lectivo, turno y módulo** activos. | MVP | M | NN-01 |
| RF-04 | Registrar el **tipo de ingreso**: nuevo, ratificación, reincorporación, trasladado o retirado anteriormente. | MVP | M | NN-07 |
| RF-05 | Para reincorporados o trasladados, **registrar y validar la convalidación** con tipo, resolución directoral, justificación, ruta complementaria y similitud. | It. 2 | M | NN-07 |
| RF-06 | Registrar **becas o exoneraciones** (hasta el tope) asociadas a convenios, guardando solo convenio, porcentaje y referencia. | It. 2 | M | NN-08 |
| RF-07 | Registrar el **derecho de inscripción** (monto, comprobante y fecha) asociado a la matrícula. | MVP | V | NN-08 |
| RF-08 | **Editar y anular** una matrícula (con motivo obligatorio), dejando trazabilidad. | MVP | M | NN-01, NN-11 |
| RF-21 | **Ratificar la matrícula** para el siguiente periodo académico, reutilizando los datos. | It. 2 | N | NN-09 |
| RF-22 | Registrar la **licencia de estudios** con fecha de inicio, duración y fecha límite de reincorporación. | It. 2 | N | NN-07 |
| RF-23 | Registrar la **reincorporación** dentro del plazo y marcar como vencida la licencia que no se reincorpora. | It. 2 | N | NN-07 |
| RF-40 | Registrar la **situación específica** del estudiante (PIR, Transitabilidad, MOT, Discapacidad, otras) como catálogo **restringido**, sin documentos. | It. 2 | N | NN-11 |
| RF-41 | **Buscar estudiantes por documento o apellidos** y **avisar si el documento ya existe**, reutilizando sus datos. | MVP | N | NN-01, NN-15 |
| RF-42 | **Guardar un borrador** de la ficha para no perder el trabajo si se cierra la sesión o se corta la conexión. | It. 2 | N | NN-15 |
| RF-43 | **Verificar los requisitos de matrícula** (lista configurable: ficha firmada, certificado de estudios del ciclo técnico, fotos y otros), registrando **que se verificaron, no los documentos**. | It. 2 | N | NN-01 |

### 2.2 Catálogo académico (M3)

| Cód. | Requerimiento | Prior. | Est. | Necesidad |
| :--- | :--- | :---: | :---: | :--- |
| RF-09 | **Registrar, editar, activar y desactivar programas de estudios**, indicando ciclo y créditos. | MVP | M | NN-05 |
| RF-10 | Registrar los **módulos formativos** de cada programa (nombre, orden, créditos y horas) y los **docentes** de la oferta. | MVP | M | NN-05 |
| RF-11 | Asociar cada programa a una **familia profesional**. | MVP | V | NN-05 |
| RF-12 | **Consultar el número de matriculados** por programa, módulo, periodo y turno (lo implementa `docs-reportes`: lee matrículas, que se registran después del catálogo). | MVP | M | NN-03 |
| RF-24 | Registrar **periodos lectivos** (por ejemplo 2026-I, con inicio y fin de clases) y las **ofertas** (programa, periodo, turno y cupo referencial). | MVP | N | NN-05 |
| RF-25 | Registrar el **plan de estudios** de cada programa con su **resolución de autorización** (tipo, número y año) y sus **unidades didácticas** (créditos y horas). | MVP | N | NN-05 |

### 2.3 Notas (retirado)

| Cód. | Requerimiento | Estado |
| :--- | :--- | :---: |
| RF-13, RF-14, RF-15, RF-18 | Registro, edición y consulta de notas de la v1.0. **Fuera de alcance** por decisión del equipo. | R |

### 2.4 Documentos y reportes (M5)

| Cód. | Requerimiento | Prior. | Est. | Necesidad |
| :--- | :--- | :---: | :---: | :--- |
| RF-16 | Generar la **constancia de estudios** en PDF, con código único y **código QR** de verificación. | MVP | M | NN-02 |
| RF-17 | Generar la **nómina de matriculados**, filtrable por programa, módulo, periodo y turno, en PDF y Excel. | MVP | M | NN-03 |
| RF-26 | Generar el **registro de matrícula (Anexo 1)** en PDF por programa, módulo y periodo. | It. 2 | N | NN-03 |
| RF-27 | Generar **archivos Excel con el formato de las plantillas de AVANZA** (estudiantes y módulos), **validar antes** que no falten datos y **avisar qué falta**. **La carga en AVANZA queda fuera del sistema.** | It. 2 | N | NN-04 |
| RF-28 | **Verificar una constancia** por su código, con respuesta mínima y límite de tasa. | It. 2 | N | NN-14 |

### 2.5 Seguridad y accesos (M1)

| Cód. | Requerimiento | Prior. | Est. | Necesidad |
| :--- | :--- | :---: | :---: | :--- |
| RF-19 | **Autenticación con usuario y contraseña individuales** más **segundo factor (TOTP)**, mostrando la fecha del último ingreso y los intentos fallidos. | MVP | M | NN-06 |
| RF-20 | **Restringir las funciones según el rol** (Personal de matrícula, Directivo, Administrador), con permisos granulares y valores iniciales según la [matriz](05-actores-y-permisos.md). | MVP | M | NN-06 |
| RF-29 | Permitir al Administrador **dar de alta, desactivar y restablecer el acceso** de usuarios; no hay autorregistro. | MVP | N | NN-06 |
| RF-30 | Emitir un **informe semestral de privilegios** para su revisión. | It. 2 | N | NN-11 |
| RF-39 | Permitir al Administrador **editar la matriz de permisos por rol**, con auditoría. | It. 2 | N | NN-06, NN-12 |

### 2.6 Parámetros, alertas y cumplimiento (M2 y M6)

| Cód. | Requerimiento | Prior. | Est. | Necesidad |
| :--- | :--- | :---: | :---: | :--- |
| RF-31 | *(Reservado: recuperación de acceso, cubierta por RF-29.)* | — | — | — |
| RF-32 | Administrar los **parámetros institucionales** con **valor, vigencia, historial y auditoría**, y guardar en cada acto el valor aplicado. | MVP | N | NN-12 |
| RF-33 | Mostrar **alertas y recordatorios** por rol (plazo de registro, datos faltantes, ratificaciones, licencias, derechos, privilegios, seguridad, respaldo, retención), **parametrizables** y con ciclo Activa → Atendida o Descartada. | It. 2 | N | NN-10 |
| RF-34 | Registrar en una **bitácora de solo inserción** la sesión, **visualización**, modificación, eliminación, importación y **exportación** de datos personales, **conservada al menos 2 años**, y permitir su consulta. | MVP | N | NN-11 |
| RF-35 | Mostrar un **aviso de privacidad** en lenguaje claro (los diez elementos del art. 6), **versionado**, y guardar la evidencia de que se informó. | MVP | N | NN-11 |
| RF-36 | Registrar las **solicitudes de derechos** de los titulares con su plazo (8, 20 o 10 días hábiles; ampliable una sola vez, salvo información) y estado. | It. 2 | N | NN-11 |
| RF-37 | Registrar y documentar **incidentes de seguridad** y su notificación. | It. 2 | N | NN-11 |
| RF-38 | Aplicar la **política de retención** y permitir depurar o anonimizar los datos vencidos, con constancia. | It. 3 | N | NN-11 |

## 3. Requisitos no funcionales

| Cód. | Categoría | Descripción | Meta | Est. | Atributo |
| :--- | :--- | :--- | :--- | :---: | :---: |
| RNF-01 | Rendimiento | Respuesta ágil en pantallas de matrícula y emisión de documentos. | p95 < 1 s en matrícula con 5 usuarios; constancia PDF < 3 s. | M | AC-04 |
| RNF-02 | Entorno | **Web, alojada en Oracle Cloud y accesible por HTTPS** desde las computadoras del CETPRO; requiere Internet. *(Invierte el RNF-02 de la v1.0.)* | TLS en el 100 % del tráfico externo. | M | AC-03 |
| RNF-03 | Concurrencia | Uso simultáneo del personal (3 de matrícula y 2 directivos); el Administrador (1 o 2 personas) es adicional y de uso técnico. | 5 usuarios concurrentes sin degradación. | M | AC-04 |
| RNF-04 | Dispositivos | Uso **exclusivo en computadoras de escritorio**; sin diseño móvil. Única excepción: la página pública de verificación de constancias, que se abre desde un QR y se adapta a pantallas pequeñas. | Chrome, Edge y Firefox recientes; la verificación pública, sin desplazamiento horizontal a 320 px. | V | AC-08 |
| RNF-05 | Seguridad | Credenciales individuales, **MFA**, bloqueo temporal, sesión con vencimiento y trazabilidad. | MFA al 100 % del personal; bloqueo tras 5 fallos; contraseña de 15+ caracteres sin reglas de composición. | M | AC-02 |
| RNF-06 | Respaldo | Copia **diaria cifrada** a dos destinos (Object Storage y el CETPRO), con **restauración probada**. | RPO ≤ 24 h (≤ 4 h en temporada); RTO ≤ 4 h; prueba trimestral. | M | AC-03, AC-10 |
| RNF-07 | Usabilidad | Interfaz simple para personal sin formación técnica, operable por teclado, con mensajes claros y borradores guardados. | Tarea de matrícula sin ayuda; WCAG 2.2 AA. | M | AC-05 |
| RNF-08 | Continuidad | **Contingencia en papel**, recuperación ante caída de Oracle o Internet y estrategia contra la reclamación de instancias inactivas. | Documentado y probado. | N | AC-03, AC-10 |
| RNF-09 | Portabilidad | Despliegue reproducible con Docker Compose, imágenes **Arm64 y x86-64** e infraestructura como código. | Un comando por VM. | N | AC-09 |
| RNF-10 | Mantenibilidad y testabilidad | Capas con regla de dependencia verificada; cada criterio de aceptación con al menos una prueba. | Pruebas de arquitectura en CI; cobertura de Dominio y Aplicación ≥ 85 %. | N | AC-06 |
| RNF-11 | Configurabilidad | Las reglas no formalizadas (edad, plazos, cupos, tope de beca, campos, alertas) son **parámetros** modificables sin desplegar. | Cambio auditado, con vigencia. | N | AC-07 |
| RNF-12 | Auditabilidad | Todo cambio y consulta de datos personales queda registrado y no es modificable. | Bitácora ≥ 2 años. | N | AC-02 |
| RNF-13 | Costo | Operación sin costo recurrente, salvo el dominio. | Dentro de Always Free. | N | — |
| RNF-14 | Privacidad | Minimización y privacidad desde el diseño. | Sin copia del DNI ni evidencia socioeconómica. | N | AC-02 |
| RNF-15 | Seguridad de la aplicación | Cumplir **OWASP ASVS 5.0 nivel 2** en autenticación, sesión, autorización, datos personales y registro (nivel 1 en el resto) y atender el **Top 10:2025**. | Pruebas de seguridad en CI. | N | AC-02 |
| RNF-16 | Accesibilidad | **WCAG 2.2 AA** en todas las pantallas. | 0 incumplimientos críticos en axe. | N | AC-05 |
| RNF-17 | Observabilidad | Logs estructurados sin datos sensibles, chequeos de salud y monitoreo externo. | Latido externo diario. | N | AC-03 |
| RNF-18 | Desarrollo asistido por IA | **SDD**: ninguna línea de producción sin especificación aprobada; **sin datos reales** en herramientas de IA, pruebas ni repositorio. | Datos sintéticos; `SpecCheck` y revisión humana. | N | AC-06 |

### 3.1 Requisitos legales (RNF-LEG)

| Cód. | Requerimiento | Origen |
| :--- | :--- | :--- |
| RNF-LEG-01 | **Aviso de privacidad** en lenguaje claro con los diez elementos del art. 6, versionado y con evidencia de aceptación. | DS arts. 6 a 9, 22 |
| RNF-LEG-02 | Solo se recolectan datos necesarios; sin copia del DNI, evidencia socioeconómica ni documentos de discapacidad. | Proporcionalidad; DL 1246 |
| RNF-LEG-03 | Registro de solicitudes de derechos con plazo (8, 20 y 10 días hábiles; ampliable una sola vez, salvo el derecho de información) y alerta. El equipo técnico, como encargado, traslada al CETPRO en un máximo de 3 días la solicitud que reciba. | DS arts. 66 a 71 (66.4 y 71.1) |
| RNF-LEG-04 | Registro de incidentes y procedimiento de notificación en 48 horas cuando corresponda. | DS arts. 34 a 36 |
| RNF-LEG-05 | Retención y eliminación por tipo de dato (configurable). | Principio de conservación |
| RNF-LEG-06 | **Inscribir el banco de datos**, **designar y publicar al ODP** y **comunicar el flujo transfronterizo** antes del despliegue. | DS arts. 21, 37, 42 |
| RNF-LEG-07 | Acuerdo de **encargo y confidencialidad** con el equipo técnico y revisión del contrato de Oracle. | DS arts. 28 a 33, 57; Ley art. 17 |
| RNF-LEG-08 | Bitácora de sesión, visualización, modificación, eliminación, importación y exportación, ≥ 2 años. | DS art. 46 |
| RNF-LEG-09 | Revisión de privilegios al menos semestral. | DS art. 46 |
| RNF-LEG-10 | Respaldo al menos semanal con verificación de integridad y restauración; transferencia cifrada. | DS arts. 48, 51, 52 |
| RNF-LEG-11 | Documento de seguridad con fecha cierta e inventario de datos. | DS art. 47 |
| RNF-LEG-12 | WCAG 2.2 AA. | RM 126-2009; ISO/IEC 40500:2025 |
| RNF-LEG-13 | Datos de prueba sintéticos. | ISO 27002 8.33 |
| RNF-LEG-14 | Código de matrícula = número de documento. | LAG 11.2.2 |
| RNF-LEG-15 | Edad mínima configurable (piso 14, valor inicial 16). | DL 1375; entrevista |
| RNF-LEG-16 | Ratificación de matrícula por periodo académico. | LAG 11.2.2, 19.1 |
| RNF-LEG-17 | Archivos de apoyo para el registro en AVANZA dentro del mes del inicio del periodo (la carga es externa). | LAG 17.1 |
| RNF-LEG-18 | La convalidación guarda resolución directoral, justificación, ruta complementaria y similitud. | LAG 11.5 |
| RNF-LEG-19 | La discapacidad se guarda solo como situación específica restringida, sin documentos. | DS art. III.5; Anexo 1 |

## 4. Restricciones

| ID | Restricción | Justificación |
| :--- | :--- | :--- |
| RC-01 | **Costo cero**, salvo el dominio, que asume el equipo. | Decisión del equipo (NN-13). |
| RC-02 | Despliegue en **Oracle Cloud Free Tier** (sin SLA, sin región en Perú). | Decisión del equipo; ver [despliegue](../02-arquitectura-de-software/05-despliegue.md). |
| RC-03 | Tecnología: ASP.NET 10, C#, HTML/CSS/JS, PostgreSQL y Docker. | Equipo. |
| RC-04 | **Dos sistemas aislados** (matrícula y web institucional); BD separada de las aplicaciones. | Seguridad por aislamiento. |
| RC-05 | Equipo estudiantil pequeño con tiempo limitado. | Servicio social. |
| RC-06 | Entidad pública: oficial de datos, banco inscrito, registros y notificación de incidentes. | DS 016-2024-JUS. |
| RC-07 | **Desarrollo con Spec-Driven Development asistido por IA**: las especificaciones mandan y el código las demuestra. | Equipo; RNF-18. |
| RC-08 | Los textos oficiales prevalecen sobre la entrevista cuando difieren. | LAG, DL 1375. |

## 5. Trazabilidad necesidad → requisitos

| Necesidad | Requisitos funcionales | Reglas y no funcionales |
| :--- | :--- | :--- |
| NN-01 | RF-01, RF-02, RF-03, RF-08, RF-41, RF-43 | RN-01, RN-02, RN-09, RN-13, RN-14, RN-15; RNF-01 |
| NN-02 | RF-16 | RNF-01 |
| NN-03 | RF-12, RF-17, RF-26 | RN-16 |
| NN-04 | RF-27 | RN-16; RNF-LEG-17 |
| NN-05 | RF-09, RF-10, RF-11, RF-24, RF-25 | RN-03, RN-04 |
| NN-06 | RF-19, RF-20, RF-29, RF-39 | RN-07; RNF-05 |
| NN-07 | RF-04, RF-05, RF-22, RF-23 | RN-05, RN-11, RN-12 |
| NN-08 | RF-06, RF-07 | RN-06 |
| NN-09 | RF-21 | RN-10 |
| NN-10 | RF-33 | RN-16; RNF-LEG-03, RNF-LEG-09 |
| NN-11 | RF-34, RF-35, RF-36, RF-37, RF-38, RF-40, RF-30 | RN-17; RNF-12, RNF-14, RNF-15, RNF-LEG-01 a RNF-LEG-11, RNF-LEG-19 |
| NN-12 | RF-02, RF-32, RF-39 | RNF-11; RNF-LEG-15 |
| NN-13 | — | RNF-02, RNF-06, RNF-08, RNF-09, RNF-13, RNF-17; RC-01, RC-02 |
| NN-14 | RF-28 | — |
| NN-15 | RF-41, RF-42 | RNF-03, RNF-04, RNF-07, RNF-16 |
| NN-16 | — | RNF-10, RNF-15, RNF-18; RC-07 |

## 6. Verificación y especificación prevista

Cada requisito se verifica con pruebas que nombran los criterios de aceptación de su spec (ver [estrategia de pruebas](../07-proceso-de-desarrollo/03-estrategia-de-pruebas.md)). Esta tabla resume los **requisitos funcionales** de cada spec (es el Anexo B del ERS, salvo RF-12, que pasa de `periodos-ofertas` a `docs-reportes` porque lee matrículas); la asignación de las reglas (RN), los no funcionales (RNF y RNF-LEG), las restricciones (RC), los casos de uso, las decisiones, las amenazas, los controles, los parámetros y las dependencias está en la [matriz de trazabilidad](08-matriz-de-trazabilidad.md), que es la fuente para redactar cada spec.

| Módulo | Spec prevista (prefijo) | Requisitos |
| :--- | :--- | :--- |
| M6 | `transversal-auditoria` (AUD) | RF-34, RNF-12, RNF-LEG-08 |
| M1 | `identidad-seguridad` (IDE) | RF-19, RF-20, RF-29, RF-30, RF-39, RN-07 |
| M2 | `parametros-institucionales` (PAR) | RF-32, RNF-11 |
| M3 | `catalogo-academico` (CAT) | RF-09, RF-10, RF-11, RF-25 |
| M3 | `periodos-ofertas` (OFE) | RF-24 |
| M4 | `estudiantes` (EST) | RF-41, RF-40 |
| M4 | `matricula-registro` (MAT) | RF-01, RF-02, RF-03, RF-04, RF-07, RF-08, RF-42, RF-43 |
| M4 | `matricula-ratificacion-licencia` (RAT) | RF-21, RF-22, RF-23 |
| M4 | `matricula-convalidacion` (CON) | RF-05 |
| M4 | `matricula-becas` (BEC) | RF-06 |
| M5 | `docs-constancia` (CST) | RF-16, RF-28 |
| M5 | `docs-reportes` (REP) | RF-12, RF-17, RF-26 |
| M5 | `docs-archivos-avanza` (AVZ) | RF-27 |
| M6 | `cumplimiento-privacidad` (PRI) | RF-35, RF-36, RF-37, RF-38 |
| M6 | `transversal-alertas` (ALE) | RF-33 |
| Plataforma | `operacion-despliegue` (OPS) | RNF-06, RNF-08, RNF-09, RNF-17 |
| Web | `web-base` (WEB) | RNF-07, RNF-16 |

## 7. Trazabilidad con la v1.0

La correspondencia de cada requisito de la v1.0 con la v1.1 está en el Anexo A del [ERS v1.1](../../Entregables/Documento-de-Analisis-ERS-v1.1.md#anexo-a-trazabilidad-de-la-v10-a-la-v11).
