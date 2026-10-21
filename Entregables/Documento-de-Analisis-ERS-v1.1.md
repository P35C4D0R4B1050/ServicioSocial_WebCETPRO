# Documento de Análisis de Requerimientos (ERS)

**Sistema de Gestión de Matrícula y Registro Académico**
CETPRO "Joaquín López Antay", Ayacucho

| Campo | Valor |
| :--- | :--- |
| Documento | Especificación de Requerimientos de Software (ERS) |
| Versión | **1.1, borrador para revisión** (sustituye a la v1.0 de setiembre de 2026) |
| Fecha | 20 de octubre de 2026 |
| Fase | Análisis |
| Fuentes | ERS v1.0, entrevista al personal administrativo y a la Dirección, DL 1375, RVM 188-2020-MINEDU (LAG), DS 016-2024-JUS, Ley 29733, manual de AVANZA v3.5, lineamientos de nube de la PCM, ISO/IEC 27002:2022 y los informes de `Investigacion/` |
| Documento relacionado | [Documento de Arquitectura](Documento-de-Arquitectura-v0.4.md) |
| Estado | **Línea base aprobada por el equipo.** La documentación viva está en [`docs/`](../docs/README.md); un cambio de comportamiento se hace allí. |

## Control de cambios

| Versión | Cambio |
| :--- | :--- |
| 1.0 | Versión inicial, basada en la entrevista. Incluía un módulo de notas |
| 1.1 | **Se retira todo lo relacionado con notas.** El sistema pasa de "local sin Internet" a **web en la nube**. Se incorporan la normativa (LAG, DL 1375, DS 016-2024-JUS), el formato de registro de AVANZA, los **límites del sistema**, los roles con sus permisos, las alertas y los parámetros configurables |

### Regla de identificadores (importante para el desarrollo con especificaciones)

El proyecto se desarrolla con **Spec-Driven Development asistido por IA**, así que los identificadores son contratos entre este documento, las especificaciones, el código y las pruebas:

1. **Los identificadores existentes no se renumeran.** Un requisito que cambia conserva su ID y se marca **Modificado**; uno que deja de aplicar se marca **Retirado** y su ID no se reutiliza.
2. **Los nuevos se agregan al final de su serie** (RF-21 en adelante, RN-09 en adelante, RNF-08 en adelante).
3. Estados posibles: **Vigente**, **Modificado**, **Nuevo**, **Retirado**.
4. La **trazabilidad** de v1.0 a v1.1 está en el [Anexo A](#anexo-a-trazabilidad-de-la-v10-a-la-v11).

*(Cambio respecto de lo propuesto antes: se había planteado renumerar una sola vez; con SDD conviene no renumerar para que las referencias ya escritas sigan siendo válidas.)*

## Contenido

1. [Introducción](#1-introducción)
2. [Descripción general](#2-descripción-general)
3. [Reglas de negocio](#3-reglas-de-negocio)
4. [Requerimientos funcionales](#4-requerimientos-funcionales)
5. [Requerimientos no funcionales](#5-requerimientos-no-funcionales)
6. [Casos de uso](#6-casos-de-uso)
7. [Modelo conceptual de datos](#7-modelo-conceptual-de-datos)
8. [Reportes y salidas](#8-reportes-y-salidas)
9. [Producto mínimo viable e iteraciones](#9-producto-mínimo-viable-e-iteraciones)
10. [Supuestos, restricciones y puntos pendientes](#10-supuestos-restricciones-y-puntos-pendientes)
11. [Anexos](#anexo-a-trazabilidad-de-la-v10-a-la-v11)

---

## 1. Introducción

### 1.1 Propósito

Establecer, a partir de la entrevista al personal administrativo y directivo del CETPRO "Joaquín López Antay" y de la normativa aplicable, los requerimientos funcionales y no funcionales, las reglas de negocio y los casos de uso del Sistema de Gestión de Matrícula y Registro Académico. Es la base formal de la fase de Análisis.

### 1.2 Alcance

El sistema abarca el **Registro de Matrícula** del CETPRO (DL 1375, art. 45-C): estudiantes, matrícula, ratificación por periodo, licencia de estudios, reincorporación y convalidación; el catálogo académico (programas de estudios, planes, módulos formativos, unidades didácticas, periodos y ofertas); convenios, becas y derecho de inscripción; la emisión de la **constancia de estudios**, la **nómina de matriculados**, el **registro de matrícula (Anexo 1)** y los **archivos en el formato de las plantillas de AVANZA**; y la seguridad, auditoría y privacidad de todo lo anterior.

El sistema es una **aplicación web alojada en la nube** (Oracle Cloud), usada desde computadoras de escritorio del CETPRO. No requiere diseño para móviles.

**Fuera del alcance:** ver los [límites del sistema](#25-límites-del-sistema).

### 1.3 Definiciones, siglas y abreviaturas

| Término | Descripción |
| :--- | :--- |
| CETPRO | Centro de Educación Técnico-Productiva |
| LAG | Lineamientos Académicos Generales de la ETP (RVM 188-2020-MINEDU) |
| AVANZA | Sistema de Gestión Docente del Minedu, donde el CETPRO registra su información académica |
| UGEL / DRE | Unidad de Gestión Educativa Local / Dirección Regional de Educación |
| Programa de estudios | Lo que la v1.0 llamaba "especialidad" |
| Ciclo | **Auxiliar Técnico** (≥ 40 créditos) o **Técnico** (≥ 80 créditos) |
| Módulo formativo | Unidad del plan de estudios con competencias propias |
| Unidad didáctica | Unidad mínima del plan de estudios, con créditos y horas |
| Periodo lectivo | Periodo calendario (por ejemplo 2026-I) |
| Periodo académico | Ordinal del programa que cursa el estudiante (primero, segundo…) |
| Oferta | Programa dictado en un periodo lectivo y turno |
| Ratificación | Confirmación de la matrícula en cada periodo académico |
| ODP | Oficial de Datos Personales |
| ERS / RF / RNF / RN / RC / CU | Especificación de requerimientos; requerimiento funcional, no funcional; regla de negocio; restricción; caso de uso |

### 1.4 Referencias

- Plantilla de entrevista aplicada al CETPRO (2026).
- DL 1375 (2018) y RVM 188-2020-MINEDU (Lineamientos Académicos Generales).
- Ley 29733 y DS 016-2024-JUS (reglamento).
- Manual de usuario del SGD AVANZA, módulo de Registro de Datos de CETPRO, v3.5 (octubre 2025).
- Lineamientos para el uso de servicios en la nube (PCM, Res. SeGDi 001-2018-PCM/SEGDI).
- ISO/IEC 27002:2022; OWASP Top 10:2025 y ASVS 5.0; WCAG 2.2.
- Informes de la carpeta `Investigacion/` y el [Documento de Arquitectura](Documento-de-Arquitectura-v0.4.md).

---

## 2. Descripción general

### 2.1 Perspectiva del producto

Aplicación web que digitaliza la matrícula del CETPRO, hoy hecha en fichas impresas y vuelta a digitar en AVANZA. Centraliza la información en una base de datos propia y genera automáticamente las constancias, la nómina, el Anexo 1 y los archivos para AVANZA. *(Cambio: la v1.0 la describía como aplicación de escritorio o local sin Internet.)*

### 2.2 Problemática identificada

Los estudiantes se matriculan en formato impreso y los datos se transcriben a AVANZA, con duplicidad de trabajo, demoras y riesgo de error. No existe un registro propio de estudiantes ni emisión automática de constancias. No hay Reglamento Institucional que formalice las reglas del CETPRO.

### 2.3 Objetivos

- Automatizar la matrícula y eliminar el doble registro en papel y en el sistema propio.
- Centralizar programas, módulos, unidades, periodos, ofertas y docentes.
- Generar constancias, nóminas y archivos de apoyo para el registro en AVANZA.
- Dar acceso diferenciado según el rol.
- Cumplir la normativa de protección de datos personales y dejar trazabilidad.

### 2.4 Usuarios del sistema

| Rol | N.º | Permisos principales |
| :--- | :---: | :--- |
| **Personal de matrícula** | 3 | Registrar, editar, anular y consultar matrículas; emitir constancias; generar nómina, registro y archivos de apoyo |
| **Directivo** | 2 | Consultar reportes y nóminas, **sin editar** |
| **Administrador** *(propuesta)* | 1 o 2 | Usuarios, parámetros y tareas técnicas, sin acceso a datos de estudiantes por defecto |
| **Persona externa** | — | Verificar una constancia por código QR (respuesta mínima) |

Ambos perfiles de personal requieren usuario y contraseña individuales. La **matriz de permisos** está en el [Documento de Arquitectura, 6.9](Documento-de-Arquitectura-v0.4.md#69-roles-y-permisos) y se valida con la Dirección. **El sistema respeta la forma de trabajo actual del CETPRO**: no impone quién realiza tareas que ocurren fuera de él.

### 2.5 Límites del sistema

| Frontera | Dentro del sistema | Fuera del sistema | Relación |
| :--- | :--- | :--- | :--- |
| **AVANZA** | Generar los archivos de apoyo (Excel con el formato de sus plantillas, Anexo 1 en PDF) | **La carga en AVANZA**, sus credenciales y quién la realiza. **AVANZA no ofrece API** que permita una integración sencilla | Manual: el CETPRO sube los archivos como hoy |
| Registro de **notas**, certificados modulares y títulos | — | Todo el módulo de notas (obligación del CETPRO, DL 1375 art. 45-C) | Lo cubre otro medio |
| **RENIEC** | Capturar nombres y apellidos tal como figuran en el documento | La validación (la hace AVANZA al cargar) | Ninguna; mejora futura por interoperabilidad, con convenio |
| **Cobros** | Registrar el derecho de inscripción (monto, beca, comprobante) | Cobrar, pasarelas de pago, comprobantes electrónicos | Manual |
| **Comunicaciones** | Alertas y recordatorios dentro del sistema | Correo, WhatsApp, SMS | Ninguna en el MVP |
| **Firma digital** | Código único y verificación por QR de la constancia | Firma digital de documentos | — |
| **Móviles** | — | Aplicación móvil y diseño responsivo | — |
| **Docentes y horarios** | Docente como dato informativo de la oferta | Gestión de horarios, asistencia y planillas | — |
| **Web institucional** | Sistema 2, **aislado**, sin acceso a esta base | Cualquier integración con la matrícula | Ninguna |
| **Procesos en papel** del CETPRO | Documentos imprimibles (ficha, constancia) | Firmas, archivo físico y otros trámites | No los reemplaza ni los impone |
| **Modalidades** | **Presencial** | Semipresencial y a distancia | — |

### 2.6 Restricciones

| ID | Restricción | Origen |
| :--- | :--- | :--- |
| RC-01 | **Costo cero**, salvo el dominio, que asume el equipo | Decisión del equipo |
| RC-02 | Despliegue en **Oracle Cloud Free Tier** (sin SLA, sin región en Perú) | Decisión del equipo |
| RC-03 | Tecnología: ASP.NET 10, C#, HTML/CSS/JS, PostgreSQL y Docker | Equipo |
| RC-04 | **Dos sistemas aislados** (matrícula y web institucional); BD separada de las aplicaciones | Equipo |
| RC-05 | Equipo estudiantil pequeño con tiempo limitado | Servicio social |
| RC-06 | Entidad pública: oficial de datos, banco inscrito, registros y notificación de incidentes | DS 016-2024-JUS |
| RC-07 | **Desarrollo con Spec-Driven Development asistido por IA**: las especificaciones mandan y el código las demuestra | Equipo |
| RC-08 | Los textos oficiales prevalecen sobre la entrevista cuando difieren | LAG, DL 1375 |

---

## 3. Reglas de negocio

| Cód. | Regla de negocio | Estado | Origen |
| :--- | :--- | :---: | :--- |
| RN-01 | La **edad mínima** para matricularse es un **parámetro** (`edad_minima`); valor inicial **16 años** (regla institucional); el piso nacional es 14 años. La fecha con la que se mide la edad también es configurable | Modificada | Entrevista; DL 1375; LAG 11.2.1 |
| RN-02 | Para matricularse se exige **documento de identidad** (DNI, carné de extranjería, pasaporte o PTP) y el **derecho de inscripción** (monto por definir) | Modificada | Entrevista; AVANZA |
| RN-03 | El CETPRO ofrece **programas de estudios** en dos ciclos: **Auxiliar Técnico** (≥ 40 créditos, 1 año) y **Técnico** (≥ 80 créditos, 2 años). Los programas se registran, activan y desactivan según la oferta de cada año | Modificada | LAG; entrevista |
| RN-04 | Cada programa se dicta en **turnos** (mañana y tarde). No hay límite estricto de vacantes; el **cupo referencial** (30) es un parámetro orientativo | Modificada | Entrevista; LAG 11.1 |
| RN-05 | El estudiante **reincorporado, trasladado o que se retiró antes** se matricula en el programa del que procede si sus módulos o plan son **convalidables**, según los tipos de la LAG 11.5 | Modificada | Entrevista; LAG |
| RN-06 | Los **convenios** institucionales pueden otorgar **becas o exoneraciones** hasta un **tope** (parámetro, inicial **50 %**). Solo se registra el resultado, **no la evidencia de ingresos** | Modificada | Entrevista; Ley 29733 art. 2 |
| RN-07 | El acceso está restringido a usuarios autorizados con **credenciales individuales y segundo factor** | Modificada | Entrevista; ISO 27002 |
| RN-08 | ~~El sistema operará únicamente en la red local, en un máximo de 3 equipos~~ **Retirada**: reemplazada por la restricción RC-02 (nube) y el RNF-08 | **Retirada** | Decisión del equipo |
| RN-09 | El **código de matrícula** es el **número del documento** del estudiante y es **único durante todo el programa** | Nueva | LAG 11.2.2 |
| RN-10 | La **matrícula se ratifica en cada periodo académico** (18 semanas en CETPRO públicos); es requisito para mantener la condición de estudiante | Nueva | LAG 11.2.2, 19.1 |
| RN-11 | El estudiante puede solicitar **licencia de estudios sin invocar causa**, por un periodo no mayor a la duración del programa. La **reincorporación** se hace dentro del plazo de reserva (parámetro, por definir); si vence, pierde el derecho de matrícula, pero puede volver a inscribirse | Nueva | LAG 11.3, 11.4 |
| RN-12 | La **convalidación** se registra mediante **resolución directoral**, con justificación y ruta formativa complementaria. Para unidades didácticas entre planes se exige **al menos 80 % de contenido similar** (parámetro) | Nueva | LAG 11.5 |
| RN-13 | Un estudiante tiene **una sola matrícula vigente** por programa y periodo lectivo | Nueva | Informe 004; diseño |
| RN-14 | El **ciclo Técnico** exige haber concluido **Primaria** o el ciclo intermedio de EBA; se verifica el certificado de estudios | Nueva | LAG 11.2.1 |
| RN-15 | **Anular** una matrícula exige **motivo**; la anulación es un estado, **nunca un borrado** | Nueva | RF-08; ISO 27002 |
| RN-16 | El **registro de matrícula debe registrarse en AVANZA dentro del mes** siguiente al inicio del periodo (obligación del CETPRO, cuyo incumplimiento es infracción grave). El sistema **alerta** el plazo | Nueva | LAG 17.1; manual de AVANZA |
| RN-17 | Los datos personales se usan **solo para la función educativa**; no se guarda copia del DNI ni evidencia socioeconómica ni documentos de discapacidad | Nueva | Ley 29733; DS 016-2024-JUS |

### 3.1 Catálogo de programas de estudios (oferta 2026, según la entrevista)

**Ciclo Técnico (2 años):** Estilismo; Fabricación de prendas de vestir; Mantenimiento de sistemas electrónicos.

**Ciclo Auxiliar Técnico (1 año):** Soporte técnico y operación de centros de cómputo; Apoyo administrativo; Servicios básicos gastronómicos; Panadería y pastelería; Mantenimiento básico de casas y edificios; Cuidado de niños y adulto mayor; Soldadura metálica.

**Oferta histórica** (registrable, activable o desactivable por el personal): Computación e Informática, Costura y Acabado, Gastronomía, Asistencia de Contabilidad, Electrónica, Peluquería y Barbería, Mantenimiento de casas. La entrevista habla de "13 especialidades" pero lista 10 mezclando oferta histórica y de 2026; **el catálogo es configurable**.

---

## 4. Requerimientos funcionales

**Prioridad:** **MVP** (iteración 1), **It. 2** y **It. 3**. **Estado:** V Vigente, M Modificado, N Nuevo, R Retirado. **Módulo** según el documento de arquitectura.

### 4.1 Matrícula (M4)

| Cód. | Requerimiento | Prior. | Est. | Origen |
| :--- | :--- | :---: | :---: | :--- |
| RF-01 | El sistema debe permitir **registrar una nueva matrícula** capturando como obligatorios: tipo y número de documento, apellido paterno y materno, nombres, sexo, fecha de nacimiento, grado de instrucción, programa de estudios, periodo lectivo, turno y módulo. Los demás datos (dirección, ubigeo, correo, teléfono, celular) se solicitan porque AVANZA los exige y son configurables | MVP | M | Entrevista; AVANZA |
| RF-02 | El sistema debe **validar la edad mínima** (`edad_minima`) antes de completar la matrícula y guardar el valor aplicado | MVP | M | RN-01 |
| RF-03 | El sistema debe permitir **seleccionar el programa, el periodo lectivo, el turno y el módulo** disponibles (activos) | MVP | M | RN-03, RN-04 |
| RF-04 | El sistema debe registrar el **tipo de ingreso**: nuevo, ratificación, reincorporación, trasladado o retirado anteriormente | MVP | M | RN-05 |
| RF-05 | Para estudiantes reincorporados o trasladados, el sistema debe permitir **registrar y validar la convalidación** con tipo, resolución directoral, justificación, ruta formativa complementaria y similitud | It. 2 | M | RN-05, RN-12 |
| RF-06 | El sistema debe permitir registrar **becas o exoneraciones** (hasta el tope) asociadas a convenios, guardando solo convenio, porcentaje y referencia | It. 2 | M | RN-06 |
| RF-07 | El sistema debe registrar el **derecho de inscripción** (monto, comprobante y fecha) asociado a la matrícula | MVP | V | RN-02 |
| RF-08 | El sistema debe permitir **editar y anular** una matrícula (con motivo obligatorio), dejando trazabilidad del cambio | MVP | M | RN-15 |
| RF-21 | El sistema debe permitir **ratificar la matrícula** de un estudiante para el siguiente periodo académico, reutilizando sus datos | It. 2 | N | RN-10 |
| RF-22 | El sistema debe permitir registrar la **licencia de estudios** de un estudiante, con fecha de inicio, duración y fecha límite de reincorporación | It. 2 | N | RN-11 |
| RF-23 | El sistema debe permitir registrar la **reincorporación** dentro del plazo y marcar como vencida la licencia que no se reincorpora | It. 2 | N | RN-11 |
| RF-40 | El sistema debe permitir registrar la **situación específica** del estudiante (PIR, Transitabilidad, MOT, Discapacidad, otras) como catálogo **restringido**, sin documentos | It. 2 | N | Anexo 1; RN-17 |
| RF-41 | El sistema debe **buscar estudiantes por documento o apellidos** y **avisar si el documento ya existe**, reutilizando sus datos | MVP | N | UX; RN-13 |
| RF-42 | El sistema debe **guardar un borrador** de la ficha para no perder el trabajo si se cierra la sesión o se corta la conexión | It. 2 | N | RNF-08 |
| RF-43 | El sistema debe permitir **verificar los requisitos de matrícula** (lista configurable: ficha firmada, certificado de estudios del ciclo técnico, fotos y otros), registrando **que se verificaron, no los documentos** | It. 2 | N | LAG 11.2.1 |

### 4.2 Catálogo académico (M3)

| Cód. | Requerimiento | Prior. | Est. | Origen |
| :--- | :--- | :---: | :---: | :--- |
| RF-09 | El sistema debe permitir **registrar, editar, activar y desactivar programas de estudios**, indicando ciclo y créditos | MVP | M | RN-03 |
| RF-10 | El sistema debe permitir registrar los **módulos formativos** de cada programa (nombre, orden, créditos y horas) y los **docentes** de la oferta | MVP | M | Entrevista; LAG |
| RF-11 | El sistema debe asociar cada programa a una **familia profesional** | MVP | V | ERS v1.0 |
| RF-12 | El sistema debe permitir **consultar el número de matriculados** por programa, módulo, periodo y turno | MVP | M | Entrevista |
| RF-24 | El sistema debe permitir registrar **periodos lectivos** (por ejemplo 2026-I, con inicio y fin de clases) y las **ofertas** (programa, periodo, turno y cupo referencial) | MVP | N | LAG 19.1 |
| RF-25 | El sistema debe permitir registrar el **plan de estudios** de cada programa con su **resolución de autorización** (tipo, número y año) y sus **unidades didácticas** (créditos y horas) | MVP | N | AVANZA; LAG |

### 4.3 *(Módulo de notas: retirado)*

| Cód. | Requerimiento | Estado |
| :--- | :--- | :---: |
| RF-13, RF-14, RF-15, RF-18 | Requerimientos de registro, edición y consulta de notas de la v1.0 | **Retirados** (fuera de alcance por decisión del equipo) |

### 4.4 Documentos y reportes (M5)

| Cód. | Requerimiento | Prior. | Est. | Origen |
| :--- | :--- | :---: | :---: | :--- |
| RF-16 | El sistema debe generar la **constancia de estudios** en PDF por estudiante, con código único y **código QR** de verificación | MVP | M | LAG 12 |
| RF-17 | El sistema debe generar la **nómina de matriculados**, filtrable por programa, módulo, periodo y turno, en PDF y Excel | MVP | M | Entrevista |
| RF-26 | El sistema debe generar el **registro de matrícula (Anexo 1)** en PDF por programa, módulo y periodo | It. 2 | N | LAG 17.1 |
| RF-27 | El sistema debe generar **archivos Excel con el formato de las plantillas de AVANZA** (estudiantes y módulos), **validar antes** que no falten datos y **avisar qué falta**. **La carga en AVANZA queda fuera del sistema** | It. 2 | N | AVANZA; RN-16 |
| RF-28 | El sistema debe permitir **verificar una constancia** por su código, mostrando solo una respuesta mínima y con límite de tasa | It. 2 | N | Riesgo de falsificación |

### 4.5 Seguridad y accesos (M1)

| Cód. | Requerimiento | Prior. | Est. | Origen |
| :--- | :--- | :---: | :---: | :--- |
| RF-19 | El sistema debe requerir **autenticación con usuario y contraseña individuales** más **segundo factor (TOTP)** para cualquier acceso, mostrando la fecha del último ingreso y los intentos fallidos | MVP | M | RN-07 |
| RF-20 | El sistema debe **restringir las funciones según el rol** (Personal de matrícula, Directivo, Administrador), con permisos granulares y valores iniciales según la matriz del documento de arquitectura | MVP | M | Entrevista |
| RF-29 | El sistema debe permitir al Administrador **dar de alta, desactivar y restablecer el acceso** de usuarios; no hay autoregistro | MVP | N | ISO 27002 |
| RF-30 | El sistema debe emitir un **informe semestral de privilegios** para su revisión | It. 2 | N | DS art. 46 |
| RF-39 | El sistema debe permitir al Administrador **editar la matriz de permisos por rol**, con auditoría | It. 2 | N | Configurabilidad |

### 4.6 Parámetros, alertas y cumplimiento (M2 y M6)

| Cód. | Requerimiento | Prior. | Est. | Origen |
| :--- | :--- | :---: | :---: | :--- |
| RF-31 | *(Reservado: recuperación de acceso, cubierto por RF-29)* | — | — | — |
| RF-32 | El sistema debe permitir administrar los **parámetros institucionales** con **valor, vigencia, historial y auditoría**, y guardar en cada acto el valor aplicado | MVP | N | AD-27 |
| RF-33 | El sistema debe mostrar **alertas y recordatorios** por rol (plazo de registro, datos faltantes, ratificaciones, licencias, derechos, privilegios, seguridad, respaldo, retención), **parametrizables** y con ciclo Activa → Atendida o Descartada | It. 2 | N | RN-16; DS |
| RF-34 | El sistema debe registrar en una **bitácora de solo inserción** la sesión, **visualización**, modificación, eliminación, importación y **exportación** de datos personales, **conservada al menos 2 años**, y permitir su consulta a quien corresponda | MVP | N | DS art. 46 |
| RF-35 | El sistema debe mostrar un **aviso de privacidad** en lenguaje claro (los diez elementos del art. 6), **versionado**, y guardar la evidencia de que se informó | MVP | N | DS arts. 6 a 9 |
| RF-36 | El sistema debe registrar las **solicitudes de derechos** de los titulares con su plazo (8, 20 o 10 días hábiles) y estado | It. 2 | N | DS arts. 66 a 71 |
| RF-37 | El sistema debe permitir registrar y documentar **incidentes de seguridad** y su notificación | It. 2 | N | DS arts. 34 a 36 |
| RF-38 | El sistema debe aplicar la **política de retención** y permitir depurar o anonimizar los datos vencidos, con constancia | It. 3 | N | DS; ISO 27002 8.10 |

*Nota:* RF-31 queda reservado para no dejar un hueco en la serie; se podrá usar para el restablecimiento de acceso si se separa de RF-29.

---

## 5. Requerimientos no funcionales

| Cód. | Categoría | Descripción | Meta | Est. |
| :--- | :--- | :--- | :--- | :---: |
| RNF-01 | Rendimiento | Respuesta ágil en las pantallas de matrícula y en la emisión de documentos | p95 < 1 s en pantallas de matrícula con 5 usuarios; constancia PDF < 3 s | M |
| RNF-02 | Entorno | El sistema es **web, alojado en Oracle Cloud y accesible por HTTPS** desde las computadoras del CETPRO; requiere conexión a Internet. *(Invierte el RNF-02 de la v1.0, que decía "solo red local, sin Internet")* | TLS en el 100 % del tráfico externo | M |
| RNF-03 | Concurrencia | Debe soportar el uso simultáneo del personal (3 de matrícula y 2 directivos) | 5 usuarios concurrentes sin degradación | M |
| RNF-04 | Dispositivos | Uso **exclusivo en computadoras de escritorio**; sin diseño móvil | Chrome, Edge y Firefox recientes | V |
| RNF-05 | Seguridad | Credenciales individuales, **MFA**, bloqueo temporal, sesión con vencimiento y trazabilidad de acciones | MFA para el 100 % del personal; bloqueo tras 5 fallos; contraseña de 15+ caracteres sin reglas de composición | M |
| RNF-06 | Respaldo | Copia **diaria cifrada** a dos destinos (Object Storage y el CETPRO), con **restauración probada** | RPO ≤ 24 h (≤ 4 h en temporada); RTO ≤ 4 h; prueba trimestral | M |
| RNF-07 | Usabilidad | Interfaz simple para personal sin formación técnica avanzada, operable por teclado, con mensajes claros y borradores guardados | Tarea de matrícula sin ayuda; WCAG 2.2 AA | M |
| RNF-08 | Continuidad | Procedimiento de **contingencia en papel** y recuperación ante caída de Oracle o de Internet; estrategia contra la reclamación de instancias inactivas | Documentado y probado | N |
| RNF-09 | Portabilidad | Despliegue reproducible con Docker Compose, imágenes **Arm64 y x86-64** e infraestructura como código | Un comando por VM | N |
| RNF-10 | Mantenibilidad y testabilidad | Capas con regla de dependencia verificada; cada criterio de aceptación con al menos una prueba | Pruebas de arquitectura en CI; cobertura de Dominio y Aplicación ≥ 85 % | N |
| RNF-11 | Configurabilidad | Las reglas no formalizadas (edad, plazos, cupos, tope de beca, campos, alertas) son **parámetros** modificables sin desplegar | Cambio auditado, con vigencia | N |
| RNF-12 | Auditabilidad | Todo cambio y consulta de datos personales queda registrado y no es modificable | Bitácora ≥ 2 años | N |
| RNF-13 | Costo | Operación sin costo recurrente, salvo el dominio | Dentro de Always Free | N |
| RNF-14 | Privacidad | Minimización y privacidad desde el diseño | Sin copia del DNI, sin evidencia socioeconómica | N |
| RNF-15 | Seguridad de la aplicación | Cumplir **OWASP ASVS 5.0 nivel 2** y atender el **Top 10:2025** | Pruebas de seguridad en CI | N |
| RNF-16 | Accesibilidad | **WCAG 2.2 AA** en todas las pantallas | 0 incumplimientos críticos en axe | N |
| RNF-17 | Observabilidad | Logs estructurados sin datos sensibles, chequeos de salud y monitoreo externo | Latido externo diario | N |
| RNF-18 | Desarrollo asistido por IA | Se trabaja con **SDD**: ninguna línea de producción sin especificación aprobada; **no se usan datos reales** en herramientas de IA, pruebas ni repositorio | Datos sintéticos; `SpecCheck` y revisión humana | N |

### 5.1 Requerimientos legales (RNF-LEG)

Derivados del marco legal (informe 01). Cada uno se especificará en la spec que lo implemente.

| Cód. | Requerimiento | Origen |
| :--- | :--- | :--- |
| RNF-LEG-01 | **Aviso de privacidad** en lenguaje claro con los diez elementos del art. 6, versionado y con evidencia de aceptación | DS arts. 6 a 9, 22 |
| RNF-LEG-02 | Solo se recolectan datos necesarios; sin copia del DNI, evidencia socioeconómica ni documentos de discapacidad | Proporcionalidad; DL 1246 |
| RNF-LEG-03 | Registro de solicitudes de derechos con plazo (8, 20 y 10 días hábiles) y alerta | DS arts. 66 a 71 |
| RNF-LEG-04 | Registro de incidentes y procedimiento de notificación en 48 horas cuando corresponda | DS arts. 34 a 36 |
| RNF-LEG-05 | Retención y eliminación por tipo de dato (configurable) | Principio de conservación |
| RNF-LEG-06 | **Inscribir el banco de datos**, **designar y publicar al ODP** y **comunicar el flujo transfronterizo** antes del despliegue | DS arts. 21, 37, 42 |
| RNF-LEG-07 | Acuerdo de **encargo y confidencialidad** con el equipo técnico y revisión del contrato de Oracle | DS arts. 28 a 33, 57; Ley art. 17 |
| RNF-LEG-08 | Bitácora de sesión, visualización, modificación, eliminación, importación y exportación, ≥ 2 años | DS art. 46 |
| RNF-LEG-09 | Revisión de privilegios al menos semestral | DS art. 46 |
| RNF-LEG-10 | Respaldo al menos semanal con verificación de integridad y restauración; transferencia cifrada | DS arts. 51, 52 |
| RNF-LEG-11 | Documento de seguridad con fecha cierta e inventario de datos | DS art. 47 |
| RNF-LEG-12 | WCAG 2.2 AA | RM 126-2009; ISO/IEC 40500:2025 |
| RNF-LEG-13 | Datos de prueba sintéticos | ISO 27002 8.33 |
| RNF-LEG-14 | Código de matrícula = número de documento | LAG 11.2.2 |
| RNF-LEG-15 | Edad mínima configurable (piso 14, valor inicial 16) | DL 1375; entrevista |
| RNF-LEG-16 | Ratificación de matrícula por periodo académico | LAG 11.2.2, 19.1 |
| RNF-LEG-17 | Archivos de apoyo para el registro en AVANZA dentro del mes del inicio del periodo (la carga es externa) | LAG 17.1 |
| RNF-LEG-18 | La convalidación guarda resolución directoral, justificación, ruta complementaria y similitud | LAG 11.5 |
| RNF-LEG-19 | La discapacidad se guarda solo como situación específica restringida, sin documentos | DS art. III.5; Anexo 1 |

---

## 6. Casos de uso

### 6.1 Actores

Personal de matrícula, Directivo, Administrador y persona externa (verificación).

### 6.2 Listado

| Cód. | Caso de uso | Actor principal | Est. |
| :--- | :--- | :--- | :---: |
| CU-01 | Registrar matrícula de estudiante | Personal de matrícula | M |
| CU-02 | Registrar o editar programa de estudios | Personal de matrícula | M |
| CU-03 | Registrar módulo formativo y unidades didácticas | Personal de matrícula | M |
| CU-04 | ~~Registrar notas~~ | — | **Retirado** |
| CU-05 | Emitir constancia de estudios | Personal de matrícula | M |
| CU-06 | Generar nómina de matriculados | Personal de matrícula y Directivo | M |
| CU-07 | ~~Reporte de notas~~ | — | **Retirado** |
| CU-08 | Autenticarse en el sistema | Todos los usuarios | M |
| CU-09 | Ratificar matrícula | Personal de matrícula | N |
| CU-10 | Registrar licencia de estudios | Personal de matrícula | N |
| CU-11 | Reincorporar a un estudiante | Personal de matrícula | N |
| CU-12 | Registrar convalidación | Personal de matrícula | N |
| CU-13 | Generar registro de matrícula (Anexo 1) y archivos para AVANZA | Personal de matrícula y Directivo | N |
| CU-14 | Verificar una constancia | Persona externa | N |
| CU-15 | Administrar usuarios y permisos | Administrador | N |
| CU-16 | Administrar parámetros institucionales | Administrador | N |
| CU-17 | Atender una alerta | Según rol | N |
| CU-18 | Atender una solicitud de derechos | Directivo | N |
| CU-19 | Registrar un incidente de seguridad | Directivo y Administrador | N |
| CU-20 | Revisar la bitácora y los privilegios | Directivo y Administrador | N |

### 6.3 CU-01: Registrar matrícula de estudiante

| Campo | Contenido |
| :--- | :--- |
| Actor | Personal de matrícula |
| Precondición | Sesión iniciada con segundo factor. La oferta (programa, periodo, turno) y el módulo están activos |
| Flujo principal | 1. El usuario elige "Nueva matrícula". 2. Ingresa el **documento**; el sistema avisa si el estudiante **ya existe** y reutiliza sus datos. 3. Completa o confirma los datos del estudiante. 4. Elige programa, periodo lectivo, turno y módulo. 5. Indica el tipo de ingreso. 6. El sistema **valida la edad mínima**, la matrícula única, el requisito del ciclo Técnico y los requisitos configurados. 7. Registra el derecho de inscripción y, de corresponder, la beca. 8. El sistema guarda la matrícula, la **bitácora** y muestra el código (número de documento). 9. El usuario emite la constancia de estudios |
| Flujos alternativos | **A1** (reincorporado o trasladado): se registra la convalidación antes de confirmar (CU-12). **A2** (faltan datos que AVANZA exige): el sistema permite guardar pero **alerta** los faltantes. **A3** (se corta la conexión): se conserva el borrador. **A4** (documento ya con matrícula vigente en ese programa y periodo): se rechaza |
| Postcondición | Matrícula registrada, bitácora actualizada y constancia emitible |

### 6.4 CU-13: Generar registro de matrícula y archivos para AVANZA

| Campo | Contenido |
| :--- | :--- |
| Actor | Personal de matrícula o Directivo |
| Precondición | Existen matrículas vigentes para el periodo |
| Flujo principal | 1. El usuario elige "Reportes" y el programa, módulo y periodo. 2. El sistema **valida** los datos que AVANZA exige y lista los faltantes. 3. Genera el Anexo 1 (PDF) y/o el Excel con el formato de la plantilla. 4. Registra la **exportación** en la bitácora. 5. El usuario descarga el archivo |
| Alternativo | Si faltan datos, muestra qué estudiantes y qué campos, y permite corregirlos (solo el Personal de matrícula) |
| Fuera del sistema | **La carga del archivo en AVANZA** |
| Postcondición | Archivo generado y exportación registrada |

---

## 7. Modelo conceptual de datos

Entidades principales (v1.1). El detalle físico está en `db/esquema_matricula_cetpro_v1.1.sql`.

| Entidad | Descripción | Estado |
| :--- | :--- | :---: |
| Estudiante | Documento (tipo y número), apellidos paterno y materno, nombres, sexo, fecha de nacimiento, grado de instrucción, ubigeo, dirección, correo, teléfonos | M |
| Programa de estudios | Nombre, ciclo, créditos mínimos, familia profesional, estado | M |
| Plan de estudios | Programa, **resolución de autorización** (tipo, número, año), periodo de aprobación | N |
| Módulo formativo / Unidad didáctica | Módulo del plan y sus unidades (créditos y horas) | N |
| Periodo lectivo / Oferta | Periodo (2026-I) y programa por turno con cupo referencial | M |
| Matrícula | Estudiante, oferta, tipo de ingreso, estado, código (= documento), edad aplicada, motivo de anulación | M |
| Matrícula por módulo | Módulos cursados y periodo académico | N |
| Convalidación / Licencia de estudios | Con resolución, justificación, plazos y estados | N |
| Convenio / Pago de inscripción | Becas y derecho de inscripción (solo resultado) | M |
| Documento emitido | Constancia, nómina, registro, archivos de apoyo, con código y *hash* | M |
| Usuario, rol, permiso | Identidad y permisos por rol | M |
| Parámetro institucional | Valor, vigencia e historial | N |
| Aviso de privacidad, solicitud de derechos, incidente, alerta | Cumplimiento y recordatorios | N |
| Bitácora | Eventos de solo inserción | M |
| ~~Nota~~ | **Retirada** | **R** |

---

## 8. Reportes y salidas

| Documento | Formato | Frecuencia o uso |
| :--- | :--- | :--- |
| **Constancia de estudios** (con QR) | PDF | Por estudiante, al matricular o a pedido |
| **Nómina de matriculados** | PDF y Excel | Por programa, módulo, periodo y turno; mensual o para reportes |
| **Registro de matrícula (Anexo 1)** | PDF | Por programa, módulo y periodo |
| **Archivos para AVANZA** (estudiantes y módulos) | Excel con el formato de sus plantillas | Al inicio de cada periodo; la carga es externa |
| **Informe semestral de privilegios** | PDF | Cada 6 meses |
| **Bitácora** (consulta) | Pantalla y exportación controlada | Revisión de seguridad |

---

## 9. Producto mínimo viable e iteraciones

La entrevista priorizó el **registro de matrícula** y el **almacenamiento estructurado en base de datos**; el registro de notas se retiró del alcance.

| Iteración | Contenido | Resultado verificable |
| :---: | :--- | :--- |
| **1 (MVP)** | Acceso con MFA y roles; parámetros; catálogo (programas, plan, módulos, periodos, ofertas); estudiantes y **matrícula** (registrar, editar, anular); derecho de inscripción; constancia de estudios; nómina; **bitácora** y aviso de privacidad | Matricular, anular y emitir constancia con trazabilidad |
| **2** | Ratificación, licencia y reincorporación, convalidación, becas, Anexo 1, **archivos para AVANZA**, verificación por QR, alertas, derechos de titulares, incidentes, informe de privilegios, permisos editables | Ciclo completo por periodo y exportación validada |
| **3** | Retención y depuración, mejoras de reportes y de rendimiento | Cumplimiento sostenido |

**Puertas de salida a producción con datos reales** (independientes de la iteración): ODP designado y publicado, banco inscrito, flujo transfronterizo comunicado, documento de seguridad con fecha cierta, acuerdo de encargo y confidencialidad, restauración probada.

---

## 10. Supuestos, restricciones y puntos pendientes

### 10.1 Supuestos

- La **edad mínima de 16 años** es regla institucional y se configura; la norma nacional fija 14.
- La matrícula es **por programa y periodo lectivo e incluye el módulo** que se cursa; las unidades didácticas se derivan del módulo.
- No existe Reglamento Institucional: las reglas propias se parametrizan y se documentan como "por formalizar".
- El CETPRO es el **responsable del tratamiento** y el equipo técnico, el **encargado**.
- La carga en AVANZA la hace el CETPRO con su forma de trabajo actual.

### 10.2 Puntos pendientes

| # | Pendiente | Responsable |
| :--- | :--- | :--- |
| P-01 | **Plantillas Excel de AVANZA** (estudiantes y módulos) con sus columnas exactas | Equipo |
| P-02 | **Dominio y registrador** (Cloudflare gratuito ya decidido) | Equipo |
| P-03 | Quién ejerce el rol **Administrador** y validar la **matriz de permisos** | Dirección |
| P-04 | **Monto y comprobante** del derecho de inscripción; plazo de reserva de la licencia | Dirección |
| P-05 | **Plazos de retención** de fichas y constancias | UGEL / Dirección |
| P-06 | Estudiantes **extranjeros** y con **NEE**: qué dato mínimo se necesita | Dirección |
| P-07 | Valores de **modalidad del servicio** y **modelo educativo** del Anexo 1 | Dirección |
| P-08 | **Ficha física**, ejemplos de nómina y constancia vigentes | Dirección |
| P-09 | **Titularidad y licencia** del software | Tutora y Dirección |
| P-10 | ¿La web institucional debe estar en gob.pe? | UGEL |
| P-11 | Formalizar al **responsable y al ODP** (resolución directoral) y el **acuerdo de encargo** | Dirección y equipo |

---

## Anexo A. Trazabilidad de la v1.0 a la v1.1

| ID v1.0 | Descripción v1.0 | Estado v1.1 | Cambio |
| :--- | :--- | :---: | :--- |
| RF-01 | Registrar matrícula con campos obligatorios | M | Campos según Anexo 1 y AVANZA; incluye módulo y periodo |
| RF-02 | Validar edad mínima 16 | M | Parámetro `edad_minima` |
| RF-03 | Seleccionar especialidad y turno | M | Programa, periodo, turno y módulo |
| RF-04 | Tipo de estudiante | M | Tipos de ingreso de la LAG |
| RF-05 | Convalidación de módulos | M | Tipos, resolución directoral, similitud |
| RF-06 | Becas hasta 50 % | M | Tope parametrizable; sin evidencia |
| RF-07 | Derecho de inscripción | V | Sin cambios |
| RF-08 | Editar y anular con trazabilidad | M | Motivo obligatorio; bitácora legal |
| RF-09 | Registrar especialidades | M | Programas y ciclos |
| RF-10 | Módulos formativos | M | Con créditos, horas y docentes |
| RF-11 | Familia profesional | V | Sin cambios |
| RF-12 | Consultar matriculados | M | Por módulo y periodo |
| RF-13, 14, 15 | (Notas, según huecos de la v1.0) | **R** | Fuera de alcance |
| RF-16 | Constancia de matrícula en PDF | M | Constancia de estudios con QR |
| RF-17 | Nómina filtrable | M | Por módulo; PDF y Excel |
| RF-18 | (Notas, hueco de la v1.0) | **R** | Fuera de alcance |
| RF-19 | Autenticación | M | MFA |
| RF-20 | Roles | M | Permisos granulares |
| RN-01 | Edad mínima 16 | M | Parámetro |
| RN-02 | DNI y pago | M | Tipos de documento |
| RN-03 | 13 especialidades, dos modalidades | M | Programas y ciclos oficiales |
| RN-04 | Turnos y cupo 30 | M | Cupo referencial configurable |
| RN-05 | Reingreso y convalidación | M | LAG 11.5 |
| RN-06 | Convenios hasta 50 % | M | Tope parametrizable |
| RN-07 | Acceso restringido | M | MFA |
| RN-08 | Solo red local, 3 equipos | **R** | Reemplazada por RC-02 y RNF-08 |
| RNF-01 | Respuesta inmediata | M | Metas medibles |
| RNF-02 | Solo red local sin Internet | M | Invertido: web en la nube |
| RNF-03 | 3 estaciones | M | 5 usuarios |
| RNF-04 | Solo escritorio | V | Sin cambios |
| RNF-05 | Seguridad | M | MFA y bitácora |
| RNF-06 | Respaldo | M | Diario cifrado, dos destinos |
| RNF-07 | Usabilidad | M | WCAG 2.2 AA |
| CU-01, 02, 03, 05, 06, 08 | Casos de uso vigentes | M | Ver sección 6 |
| CU-04, CU-07 | (Notas, huecos de la v1.0) | **R** | Fuera de alcance |
| Entidad Nota (§7.5) | Nota | **R** | Fuera de alcance |

## Anexo B. Requerimientos por módulo y especificación prevista

Las especificaciones (specs) se escribirán con el flujo SDD. Cada una cubrirá los requerimientos indicados y tendrá criterios de aceptación en EARS. Orden y fases en el [Documento de Arquitectura, sección 10.5](Documento-de-Arquitectura-v0.4.md#105-desarrollo-guiado-por-especificaciones-sdd-asistido-por-ia).

| Módulo | Spec prevista (prefijo) | Requerimientos |
| :--- | :--- | :--- |
| M6 | `transversal-auditoria` (AUD) | RF-34, RNF-12, RNF-LEG-08 |
| M1 | `identidad-seguridad` (IDE) | RF-19, RF-20, RF-29, RF-30, RF-39, RN-07 |
| M2 | `parametros-institucionales` (PAR) | RF-32, RNF-11 |
| M3 | `catalogo-academico` (CAT) | RF-09, RF-10, RF-11, RF-25 |
| M3 | `periodos-ofertas` (OFE) | RF-24, RF-12 |
| M4 | `estudiantes` (EST) | RF-41, RF-40 |
| M4 | `matricula-registro` (MAT) | RF-01, RF-02, RF-03, RF-04, RF-07, RF-08, RF-42, RF-43 |
| M4 | `matricula-ratificacion-licencia` (RAT) | RF-21, RF-22, RF-23 |
| M4 | `matricula-convalidacion` (CON) | RF-05 |
| M4 | `matricula-becas` (BEC) | RF-06 |
| M5 | `docs-constancia` (CST) | RF-16, RF-28 |
| M5 | `docs-reportes` (REP) | RF-17, RF-26 |
| M5 | `docs-archivos-avanza` (AVZ) | RF-27 |
| M6 | `cumplimiento-privacidad` (PRI) | RF-35, RF-36, RF-37, RF-38 |
| M6 | `transversal-alertas` (ALE) | RF-33 |
| Plataforma | `operacion-despliegue` (OPS) | RNF-06, RNF-08, RNF-09, RNF-17 |
| Web | `web-base` (WEB) | RNF-07, RNF-16 |
