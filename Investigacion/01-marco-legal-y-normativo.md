# Marco legal y normativo del Sistema de Matrícula

> **Esto no es asesoría legal.** Es una investigación técnica para saber qué debe diseñarse. Antes de operar con datos reales debe revisarlo una persona abogada y confirmarlo la UGEL Huamanga / DRE Ayacucho.

**Fecha:** 20-oct-2026 (segunda versión). **Estado:** borrador para revisión del equipo.

**Actualización posterior (3.ª ronda).** Se leyó el **manual de AVANZA v3.5** (octubre 2025) y el texto consolidado de la **Ley 29733**. Se resolvieron Q1 y Q22, Q2 pasó a "no bloquea" y se detalló el formato de carga a AVANZA.

**Novedad de la 2.ª versión.** El equipo aportó el texto oficial del **DS 016-2024-JUS**, los **Lineamientos de nube de la PCM** (con su resolución), el **Anexo 1 vigente** de la ficha de matrícula y la **entrevista** al CETPRO. Lo que antes salía de fuentes secundarias ahora está leído en el texto oficial y **se corrigieron afirmaciones** (la notificación de incidentes en 48 horas es condicionada, y el oficial de datos personales ya es exigible a las entidades públicas).

## Leyenda de verificación

| Marca | Significado |
| :---: | :--- |
| ✔✔ | Leído en el texto oficial aportado por el equipo, o coinciden dos o más fuentes. |
| ✔ | Una sola fuente secundaria, o fuente oficial citada indirectamente. |
| ? | No verificado (conocimiento general). Debe comprobarse antes de citarlo. |

## 1. Contexto institucional que condiciona qué ley aplica

| Hecho del proyecto | Consecuencia legal / normativa |
| :--- | :--- |
| El CETPRO "Joaquín López Antay" es una **institución educativa pública** (UGEL Huamanga, DRE Ayacucho). | Aplican normas para entidades públicas: protección de datos con oficial de datos obligatorio, gobierno digital, seguridad digital, interoperabilidad. |
| Se tratan datos de estudiantes desde los **14 años** (norma) o **16** (regla institucional); parte son menores de 18. | Consentimiento propio de 14 a 17 años con lenguaje comprensible (art. 22 del reglamento). |
| Las **becas y exoneraciones** se otorgan "según necesidades" (entrevista). | Los **ingresos económicos** figuran como dato sensible en la Ley 29733 (según la guía de la PCM, que cita la Ley). El reglamento de 2024 define los sensibles de otra forma y no los lista. **Criterio prudente: tratarlos como sensibles.** |
| La ficha oficial pide la situación de **discapacidad** (observaciones). | Es **dato de salud** (art. III.5 del reglamento: incluye el grado de discapacidad) y por tanto sensible. |
| El sistema se aloja en **Oracle**, fuera del Perú. | Servicio tecnológico tercerizado (arts. 28 a 30) y **flujo transfronterizo** (arts. 18 a 21) que debe comunicarse a la autoridad. |
| Lo desarrolla un **equipo externo** (servicio social UNSCH). | Si el equipo interviene de forma humana es **encargado del tratamiento** (arts. 31 a 33): contrato, secreto y conservación máxima de 2 años tras el encargo. |
| Los procesos del CETPRO hoy son **manuales o locales** (sin Reglamento Institucional). | Las reglas propias deben ser **configurables** y quedar documentadas como "por formalizar". |

## 2. Matriz normativa

### 2.1 Protección de datos personales: DS 016-2024-JUS (texto oficial leído)

Publicado el 30-nov-2024 (El Peruano). **Entra en vigencia a los 120 días calendario** (≈ 30-mar-2025) y deroga el DS 003-2013-JUS. El cronograma escalonado de la primera disposición final **solo aplica al oficial de datos de empresas privadas** (numerales 2 y 3 del art. 37.1); **para las entidades públicas rige desde la entrada en vigencia general**.

| Art. | Qué establece | Implicancia para el sistema | Verif. |
| :--- | :--- | :--- | :---: |
| III.4, III.5, III.6 | Definiciones. **Datos de salud** incluyen el grado de discapacidad. **Datos sensibles** (reglamento): genéticos, biométricos, neuronales, morales o emocionales, vida afectiva o familiar, hábitos íntimos, afiliación sindical, salud física o mental y análogos. | Tratar discapacidad como sensible. Los ingresos económicos: criterio prudente (ver sección 1). | ✔✔ |
| 1 a 5 | El consentimiento es **libre, previo, expreso e inequívoco e informado**; se exige salvo los supuestos del art. 14 de la **Ley** (el reglamento aclara que incluye la **interoperabilidad entre entidades públicas**). Otras finalidades exigen consentimiento. | Los datos de la matrícula se tratan en ejercicio de la función pública; WhatsApp, fotos o difusión requerirían consentimiento. **Confirmar con el texto de la Ley.** | ✔✔ / ? |
| 6 | **Consentimiento informado, con lenguaje sencillo**: identidad y domicilio del responsable, finalidades, destinatarios, banco de datos, carácter obligatorio o facultativo de cada dato, consecuencias, **transferencias nacionales e internacionales**, decisiones automatizadas, **plazo de conservación** y mecanismos de derechos. | **Aviso de privacidad** con esos diez elementos; debe mencionar a Oracle y el flujo al exterior. | ✔✔ |
| 7 a 10 | La política de privacidad **no exime** del consentimiento; para **datos sensibles** el consentimiento es **por escrito** (firma manuscrita, digital o electrónica); **la prueba del consentimiento es del responsable**; la revocación es gratuita, sencilla y se atiende en máximo 10 días. | Guardar versión del aviso y evidencia de aceptación. | ✔✔ |
| 12 a 16 | Toda transferencia requiere consentimiento salvo excepciones, se limita a su finalidad y **la carga de la prueba es del emisor**. | Documentar a quién se comunican datos (UGEL, AVANZA, Oracle). | ✔✔ |
| **18 a 21** | **Flujo transfronterizo**: solo a países con **nivel adecuado** o con **garantías** (cláusulas contractuales modelo u otros instrumentos). **Art. 21.2: en todo caso debe ponerse en conocimiento de la autoridad y se inscribe en el Registro Nacional.** No comunicarlo es infracción leve (art. 132.8). | **Comunicar el flujo hacia la región de Oracle** y revisar sus cláusulas. | ✔✔ |
| **22 a 25** | **Menores**: el consentimiento es de quienes ejercen la patria potestad, pero los **mayores de 14 y menores de 18 pueden consentir** según su capacidad, si la información se les da en **lenguaje comprensible**. No se recopilan datos de la familia (salvo identidad y dirección de padres o tutores para obtener el consentimiento). Las entidades públicas deben fomentar la protección. En servicios digitales se hacen esfuerzos razonables para **verificar la identidad** de quien consiente. | Aviso en lenguaje claro para adolescentes; **no pedir datos de padres** salvo cuando haga falta. | ✔✔ |
| **28 a 30** | **Medios tecnológicos tercerizados** (servicios, aplicaciones, infraestructura con procesamiento automático): el responsable **informa a los titulares las subcontrataciones**, no cede la titularidad, garantiza confidencialidad, integridad y disponibilidad, **mantiene el control** y exige **evidencia de la destrucción** de los datos al terminar. El prestador avisa cambios de condiciones, permite limitar el tratamiento, mantiene medidas de seguridad y evidencia la supresión. | Oracle como proveedor: revisar contrato, subencargados y borrado; informar en el aviso. | ✔✔ |
| **31 a 33** | **Encargo y subcontratación** (con intervención humana): el encargado **no transfiere a terceros**; conserva los datos **como máximo 2 años** desde el último encargo y luego los devuelve; el subcontratado asume las mismas obligaciones. | Contrato con el equipo desarrollador; sin copias de datos reales. | ✔✔ |
| **34** | **Incidentes de seguridad**: se notifica a la autoridad **dentro de 48 horas** de conocido **cuando el incidente** exponga **grandes volúmenes** de datos, afecte a **muchas personas**, involucre **datos sensibles** o cause **perjuicio evidente** a derechos del titular (aunque ya esté resuelto). Si se tarda más, se explican los motivos. Se informa al titular en 48 horas **si lo afecta** en sus derechos; si no hubo afectación y se superó totalmente, no se comunica. Si ocurre en el entorno digital, **también al Centro Nacional de Seguridad Digital**. | **Corrige lo anterior**: la obligación es condicionada, no para toda brecha. Con datos de adolescentes y de discapacidad, casi cualquier fuga relevante la activa. No notificar es infracción grave (art. 133.12). | ✔✔ |
| **35 y 36** | **Todo incidente** se documenta (hechos, efectos y medidas). El encargado informa **de inmediato** al responsable. | Registro de incidentes y canal inmediato con el equipo. | ✔✔ |
| **37 a 39** | **Oficial de datos personales (ODP)**: **obligatorio cuando el tratamiento lo lleva una entidad pública** (art. 37.1.1). Una autoridad pública puede **designar un único ODP para varias entidades** (37.3); puede ser alguien con otras funciones o externo (38.2). Se **publican sus datos de contacto** y se **comunica a la autoridad en 15 días** (37.4 y 37.5). No designarlo es infracción leve (132.9). | **El CETPRO (o la UGEL/DRE por él) debe tener ODP.** Confirmar quién. Publicar el contacto en el sistema. | ✔✔ |
| 40 | **Evaluación de impacto**: facultativa, especialmente con **datos sensibles, adolescentes o personas con discapacidad**; puede basarse en **NTP-ISO/IEC 27005** y **NTP-ISO 31000**. | Hacer una EIPD breve (corrige la mención anterior a ISO 29134). | ✔✔ |
| 42 a 45 | **Registro Nacional**: las **entidades públicas** deben inscribir, mantener actualizados y cancelar sus bancos de datos; es **gratuito y de aprobación automática**. No inscribir es infracción leve (132.4). | Inscribir el banco "Estudiantes y matrículas". | ✔✔ |
| **46** | Los sistemas digitales deben tener **documentado e implementado**: gestión de accesos de alta a baja, autenticación, **revisión de privilegios al menos semestral**, monitoreo y capacitación, **registros de las interacciones** (inicio y cierre de sesión y **procesamiento, visualización, modificación, eliminación, importación y exportación** de datos personales) conservados **mínimo 2 años**, de generación continua y disponibles de inmediato, y medidas contra copias no autorizadas. | **La bitácora de lecturas y exportaciones es obligación legal**, no solo buena práctica. Revisión semestral de usuarios como tarea del sistema. | ✔✔ |
| **47** | **Documento de seguridad** aprobado formalmente, con **fecha cierta**, con gestión de accesos y privilegios, **inventario de datos y sistemas** (marcando los sensibles); puede referirse a la NTP-ISO/IEC 27001. En entidades públicas aplican las normas de gobierno y seguridad digital. | El documento de arquitectura y el informe 02 alimentan este documento. | ✔✔ |
| **48, 51, 52** | **Respaldos con frecuencia mínima semanal** (salvo que no haya cambios), con **verificación de integridad y recuperación completa**; el intercambio de datos hacia fuera de las instalaciones requiere **autorización del titular del banco y cifrado, firma o *checksum***. | El respaldo diario cifrado supera el mínimo. La copia fuera de Oracle exige autorización y cifrado. | ✔✔ |
| 57.2 | Con personal ajeno sin acceso a datos, el contrato lo **prohíbe** y exige **secreto**. | Cláusula para el equipo y terceros. | ✔✔ |
| **69 a 71** | **Plazos (días hábiles)**: información **8**, acceso **20**, rectificación, cancelación y oposición **10**; ampliables **una vez** por igual plazo, con justificación. Debe dejarse constancia de la recepción (art. 66). | Registro de solicitudes con plazo y alerta. | ✔✔ |
| 76.6 | La **portabilidad no aplica** al tratamiento necesario para las competencias de entidades públicas. | No se implementa portabilidad. | ✔✔ |
| 131 a 135 | **Infracciones leves** (incluye tratar datos no necesarios, no suprimir, no inscribir, **incumplir medidas de seguridad**, no comunicar el flujo transfronterizo, no designar ODP) y **graves** (sin consentimiento cuando corresponde, medidas de seguridad con perjuicio, **datos sensibles sin seguridad**, usar datos para otra finalidad, no notificar incidentes). Multas según la Ley (hasta 100 UIT según fuentes secundarias). | Justifica los controles. | ✔✔ |
| Disposición 2.ª | La autoridad emitirá lineamientos sobre la **notificación de incidentes**. | Vigilar su publicación. | ✔✔ |

**¿Hace falta la directiva del oficial de datos?** Es la que (según fuentes secundarias) el Minjus emitió en diciembre de 2025 para **designar y definir las funciones del ODP**. No regula el tratamiento de datos. **No es necesaria**: el reglamento ya fija cuándo hay que designarlo (art. 37), sus funciones (39) y el perfil (38).

**La Ley 29733 sigue vigente; lo derogado es el reglamento de 2013.** El DS 016-2024-JUS es el **reglamento** que reemplaza al DS 003-2013-JUS (disposición derogatoria única). Los textos del 2013 ya no sirven. La **Ley** (2011, modificada por el DL 1353 de 2017) no fue derogada y el reglamento remite a sus artículos. No hizo falta que la aportaran: descargué una copia consolidada de SPIJ y leí los artículos pertinentes.

| Art. de la Ley 29733 | Qué dice (texto leído) | Implicancia | Verif. |
| :--- | :--- | :--- | :---: |
| **2 num. 5** | Son **datos sensibles**: biométricos que identifican, origen racial y étnico, **ingresos económicos**, opiniones o convicciones, afiliación sindical y **salud o vida sexual**. | **Confirmado**: los ingresos económicos son dato sensible. Tratarlos con cuidado (becas). | ✔✔ |
| 2 nums. 3, 15 y 6 | **Titular del banco de datos**: entidad pública que **determina la finalidad, el contenido, el tratamiento y las medidas de seguridad**. **Encargado**: quien trata por encargo del titular. | **Q1**: el CETPRO es el titular; el equipo técnico es el encargado. | ✔✔ |
| **13.5 y 13.6** | Consentimiento previo, informado, expreso e inequívoco; **por escrito** para datos sensibles; los sensibles pueden tratarse sin consentimiento **cuando la ley lo autorice por motivos importantes de interés público**. | Aviso y consentimiento para lo que no sea función pública. | ✔✔ |
| **14.1** | **No se requiere consentimiento** cuando los datos se recopilen o transfieran **para el ejercicio de las funciones de las entidades públicas en el ámbito de sus competencias**. | **Confirmado**: la base legal de la matrícula es la **función pública**. El consentimiento queda para lo adicional (fotos, mensajería, difusión). | ✔✔ |
| **15** | Flujo transfronterizo **solo si el país destinatario tiene nivel adecuado**; si no, **el emisor debe garantizar** el tratamiento conforme a la Ley. Excepciones (tratados, relación contractual, consentimiento, entre otras). | Oracle: documentar garantías y comunicar (reglamento art. 21.2). | ✔✔ |
| **16 y 17** | El titular adopta medidas técnicas, organizativas y legales; **queda prohibido tratar datos en bancos que no reúnan las condiciones de seguridad**. **Confidencialidad** de titular, encargado y cualquiera que intervenga; subsiste tras terminar la relación. | **Acuerdos de confidencialidad** con el equipo técnico. | ✔✔ |
| **18** | **Derecho de información**: finalidad, destinatarios, banco, identidad del titular y **del encargado**, carácter obligatorio o facultativo, transferencia, consecuencias, plazo de conservación y cómo ejercer derechos. Si un encargado se incorpora después, el titular lo informa. | Aviso de privacidad que **nombre al equipo técnico y a Oracle**. | ✔✔ |
| **39** | Multas: leves **0,5 a 5 UIT**, graves **más de 5 hasta 50 UIT**, muy graves **más de 50 hasta 100 UIT**, con tope del 10 % de los ingresos anuales; **sin perjuicio de sanciones disciplinarias al personal de las entidades públicas**. | El personal del CETPRO también responde disciplinariamente. | ✔✔ |

*Nota:* la copia leída recoge las modificaciones del DL 1353 (2017). Pudo haber cambios posteriores que no figuren ahí.

### 2.2 Educación Técnico-Productiva y matrícula (texto oficial)

Fuentes: **DL 1375** (El Peruano, 13-ago-2018), **RVM 188-2020-MINEDU** (Lineamientos Académicos Generales, LAG) y el **Anexo 1 vigente** que aportó el equipo (versión 2025).

| Norma | Qué establece (texto oficial) | Implicancia | Verif. |
| :--- | :--- | :--- | :---: |
| **DL 1375**, art. 42 de la Ley 28044 | "Se accede a estos ciclos siendo **mayor de 14 años**." Dos ciclos: **Auxiliar Técnico** (≥ 40 créditos) y **Técnico** (≥ 80 créditos; exige Primaria completa o ciclo intermedio de EBA). | Edad mínima nacional **14**. | ✔✔ |
| **LAG 11.2.1** | Edad mínima **14 años**; haber cursado o no algún nivel formal. Documentos: **ficha de matrícula** suscrita por el estudiante o quien ejerza la patria potestad; **certificado de estudios** (solo ciclo técnico); haber aprobado las unidades didácticas del módulo anterior, cuando corresponda; **fotografías** para el certificado modular. Estudiantes con NEE: certificado de discapacidad o informe psicopedagógico del SAANEE. | **El 16 de la entrevista es una regla institucional más estricta.** Parámetro configurable. | ✔✔ |
| **LAG 11.2.2** | La matrícula se registra en la **Ficha de registro de matrícula (Anexo 1)** y en los sistemas del Minedu. **El código de matrícula es el número del DNI** (extranjeros: carné de extranjería o pasaporte), único durante el programa. **La ratificación de matrícula se hace en cada periodo académico.** | Documento con tipo; código = número de documento; ratificación por periodo. | ✔✔ |
| LAG 11.1 | Las vacantes se determinan según la **capacidad operativa**. | Cupo referencial configurable (30). | ✔✔ |
| **LAG 11.3 y 11.4** | **Licencia de estudios** sin invocar causa, por un periodo que no exceda la duración del programa. **Reincorporación** dentro del plazo de reserva; en un CETPRO público, quien no se reincorpora en el plazo **pierde el derecho de matrícula** (puede volver a inscribirse). | Estados LICENCIA y reincorporación con fecha límite. | ✔✔ |
| **LAG 11.5** | **Convalidación**: aprendizajes previos, entre planes, por unidades de competencia, con Educación Básica. **Se registra por Resolución Directoral** con datos del estudiante, unidades convalidadas, justificación y **ruta formativa complementaria**. Para unidades didácticas: **≥ 80 % de contenido similar**. | Modelo de convalidación con resolución, justificación y similitud. | ✔✔ |
| **LAG 12** | Constancia de egreso, **constancia de estudios**, certificado de estudios (notas), certificado modular. Las constancias y certificados **se registran en el CETPRO**. | La "constancia de matrícula" equivale a la **constancia de estudios**. | ✔✔ |
| **LAG 17.1, 20.5** | **Registro de matrícula dentro del mes siguiente** al inicio del periodo; evaluación a 30 días hábiles; consolidado de notas; certificados y títulos. Se reporta al Minedu por el **Sistema de Información Académica**; **mientras no exista, en soporte digital a la UGEL**. | Exportación del registro con los campos del Anexo 1. | ✔✔ |
| **AVANZA** (Manual de usuario v3.5, octubre 2025, DIGEST-Minedu; **leído**) | Es el **Sistema de Gestión Docente** del Minedu; el módulo "Registro de Datos" es de uso del **Director** (único tipo de usuario: ingresa con su DNI, contraseña y captcha). Orden obligatorio: **1)** plan de estudios (con la **resolución de autorización**: tipo, número y año), **2)** módulos, **3)** unidades didácticas, **4)** estudiantes, **5)** notas. Los estudiantes se registran por **periodo lectivo, programa, módulo y periodo académico**, uno a uno (el DNI se valida con **RENIEC**: nombres, apellidos, fecha de nacimiento y sexo) o **en forma masiva con una plantilla Excel** (`PLANTILLA-REGISTRO-ESTUDIANTE`) que el sistema entrega ya predefinida con el periodo y el programa. Extranjeros: **carné de extranjería, pasaporte o PTP**, con datos manuales. Datos que se completan: región, provincia, distrito, **dirección, correo, teléfono fijo y celular**. **La plantilla no admite celdas vacías.** Un archivo de errores marca lo que RENIEC no validó. Se registra **desde los 14 años**. Las notas usan otra plantilla (`PLANTILLA-REGISTRO-UNIDADEVAL`), con tope de **500 estudiantes por archivo**. Los reportes de nómina y actas **aún no existen** en AVANZA. | La nómina oficial **es el registro de estudiantes en AVANZA**. Nuestro sistema debe **generar los Excel con el formato de AVANZA** y llevar un catálogo alineado (plan con resolución, módulos, unidades). **La carga en AVANZA queda fuera de nuestro sistema**: la gestiona el CETPRO con su forma de trabajo y sus responsables (la entrevista asigna tareas a distintos actores). El sistema solo prepara los archivos, no guarda credenciales de AVANZA y no impone quién carga. | ✔✔ |
| **DS 004-2019-MINEDU** (citado en el manual de AVANZA) | Art. 94: la información académica oficial del CETPRO son los **registros de matrícula, de evaluación y notas, y de títulos y certificados modulares**. Art. 104.1.l: el CETPRO registra esa información en el Sistema de Información Académica. Su anexo tipifica como **infracción grave** no remitir la información obligatoria en los plazos. | **Reportar tarde es una infracción grave para el CETPRO**: el sistema debe alertar los plazos de carga. | ✔ |
| **LAG 19.1** | **Periodo académico de 18 semanas**, máximo 24 créditos, en CETPRO públicos. | Periodo semestral. Auxiliar (≥ 40 créditos) ≈ 2 periodos; Técnico (≥ 80) ≈ 4. | ✔✔ |
| **DL 1375**, art. 45-C | Los CETPRO implementan un **Registro de Matrícula, de Notas y de Certificados Modulares**, supervisado por la UGEL. | El sistema cubre solo el de **Matrícula**. | ✔✔ |
| **DL 1705** (2026) | Los CETPRO pueden o deben reconocer aprendizajes previos (la prensa y el texto oficial difieren). | Ya previsto como tipo de convalidación. | ✔✔ |

**Anexo 1 vigente (2025), campos de la ficha.** CETPRO, DRE/GRE, código modular, UGEL, departamento, tipo de gestión, provincia, distrito, periodo lectivo, periodo académico, programa de estudios, inicio y término de clases, **módulo**, **ciclo**, **apellidos y nombres**, **número de documento de identidad**, **modalidad del servicio educativo**, **grado de instrucción**, **modelo educativo**, **edad**. Tablas de **unidades didácticas** (número, nombre, créditos, horas, observaciones), **unidades de subsanación** y **experiencias formativas en situaciones reales de trabajo**. Nota: las observaciones recogen situaciones como **PIR, Transitabilidad, MOT y Discapacidad**. Firman Director, Coordinador Académico y Estudiante. **La ficha vigente sí pide la edad y el grado de instrucción**, lo que corrige la lectura de la versión de 2020.

### 2.3 Gobierno digital, nube y seguridad digital

| Norma | Qué establece | Implicancia | Verif. |
| :--- | :--- | :--- | :---: |
| **Lineamientos para el uso de servicios en la nube** (Res. SeGDi 001-2018-PCM/SEGDI) | **Sí es el documento correcto.** El anexo tiene 43 páginas. Alcance: entidades del Sistema Nacional de Informática, y las demás **de forma voluntaria**. Es **orientador** y "no impone obligaciones". La responsabilidad final **sigue siendo de la entidad**. Recomienda: **cifrar antes de enviar** y custodiar las claves la entidad; **no gestionar altas y bajas de usuarios en la nube**; **conservar los registros de actividad preferentemente en la propia entidad**; el proveedor debe tener **ISO 27001, 27017 y 27018 o equivalente**; la entidad elige la **localización** de los datos; ante flujo transfronterizo, nivel de protección equiparable; contratos con acuerdo de nivel de servicio; documentar un **uso aceptable**. Las entidades en alcance **informan trimestralmente** a la SeGDi sus servicios en la nube. | Es **una guía, no una prohibición**. Adoptar sus recomendaciones: copias cifradas con claves del CETPRO, **copia de la bitácora en el CETPRO**, uso aceptable. **Verificar las certificaciones de Oracle.** | ✔✔ |
| **DL 1412** y **DS 029-2021-PCM** | Gobierno digital; **nube primero**; CSIRT institucional (arts. 104 y 105); SGSI (art. 109); el art. 68.6 remite al ODP. | Alinear con el CSIRT y el comité de gobierno digital de la UGEL/DRE. | ✔✔ |
| **DU 007-2020** | Marco de confianza digital; **registro de incidentes** en el CNSD. | El incidente digital se reporta además al CNSD. | ✔✔ |
| **NTP-ISO/IEC 27001:2022** y RSGTD 003-2023-PCM/SGTD | Estándar nacional para el SGSI de entidades públicas. | Alinear con ISO 27001/27002; no se exige certificar al CETPRO. | ✔ |
| **DS 033-2018-PCM** (gob.pe) | Migración progresiva de canales a gob.pe para entidades de la Administración Pública. | **No pude confirmar si una IE pública está obligada.** Consultar a la UGEL antes de publicar la web institucional. | ✔ / ? |
| **Accesibilidad**: RM 126-2009-PCM; Sello de Accesibilidad Digital; Ley 29973 | Portales públicos accesibles. | **WCAG 2.2 AA** (ISO/IEC 40500:2025). | ✔ |
| **DL 1246** (simplificación; PIDE) | Interoperabilidad sin costo; una fuente indica que se **prohíbe exigir copia del DNI** (art. 5). | No pedir ni guardar copia del DNI. Evaluar validar contra RENIEC por PIDE. | ✔ |
| **Archivos, transparencia (Ley 27806), delitos informáticos (Ley 30096)** | No verificadas. No encontré plazos de conservación de fichas de matrícula. | Consultar a la UGEL. | ? |

## 3. Contraste con la entrevista al CETPRO

La entrevista (directora y dos administrativos) se usó como fuente del ERS. Estos son los puntos donde la normativa matiza o cambia lo que se dijo.

| Tema | Entrevista | Normativa | Decisión de diseño |
| :--- | :--- | :--- | :--- |
| Edad mínima | 16 años | 14 años (DL 1375, LAG) | **Parámetro configurable, valor inicial 16** (decisión del equipo, Q5). Se registra el valor con el que se validó. |
| Datos que se piden | Nombre, apellido, fecha de nacimiento, DNI, dirección, correo, celular, especialidad | Anexo 1: documento, nombres, **edad**, **grado de instrucción**, programa, módulo, ciclo. **AVANZA**: apellido paterno y materno, sexo, región, provincia, distrito, **dirección, correo, teléfono fijo y celular**, y la plantilla **no admite celdas vacías** | Obligatorios: documento, apellidos (paterno y materno), nombres, fecha de nacimiento, sexo, grado de instrucción, programa, módulo. **Dirección, ubigeo, correo y celular: se piden porque AVANZA los exige**; el sistema avisa antes de exportar si faltan y la finalidad consta en el aviso (base: función pública, Ley art. 14.1). |
| Obligatorios en el sistema | DNI, nombres y apellidos, especialidad | Idem | Idem. |
| Requisitos de matrícula | Documento de identidad y derecho de inscripción | Además: ficha firmada, certificado de estudios (ciclo técnico), fotos, documentos de NEE | Lista de requisitos verificados configurable; **se registra que se verificó, no el documento**. |
| Especialidades | 13 especialidades; en 2026: 3 de título técnico (2 años) y 7 de auxiliar técnico (1 año) | **Programa de estudios**, **ciclo** Auxiliar Técnico o Técnico, créditos | Catálogo **configurable** (alta, baja y activación); la lista de la entrevista mezcla oferta histórica y 2026. |
| Turnos y cupos | Mañana y tarde, sin límite, referencia de 30 | Vacantes según capacidad operativa (LAG 11.1) | Turnos y **cupo referencial configurables**. |
| Reingresante o de otro CETPRO | Se matricula en la especialidad de procedencia si el plan coincide | Licencia, reincorporación, convalidación con RD | Tipos de ingreso y estados de la LAG; reglas en parámetros. |
| Becas | Convenios, exoneración de hasta 50 % según necesidades | No regulado en lo leído | **Porcentaje máximo configurable**; guardar solo convenio y resultado, **sin evidencia de ingresos**. |
| Reportes | Constancia PDF; **nómina de matriculados**; reportes **por módulo** | Registro de matrícula en AVANZA dentro del mes; Anexo 1 por módulo | Nómina y registro **filtrables por programa, módulo, periodo y turno**; exportación para AVANZA. |
| Notas | "Registro de notas" era la tercera función crítica y se pide un Excel para AVANZA | Registro de Notas es obligación del CETPRO | **Fuera del alcance** por decisión del equipo; se documenta el riesgo (el re-digitado de notas continúa). |
| Entorno | "Red local, 3 PC" | — | **Superado por la decisión de Oracle**; riesgo de depender de Internet (contingencia en papel y modo degradado local). |
| Respaldo | Pide contraseña y copias | DS art. 51: semanal como mínimo | Diario cifrado. |

## 4. Preguntas críticas (estado)

| # | Pregunta | Estado | Respuesta o siguiente paso |
| :--- | :--- | :--- | :--- |
| Q1 | ¿Quién es el **responsable del tratamiento**? | **Resuelta** | **El CETPRO** (titular del banco: decide finalidad, contenido y seguridad; Ley art. 2.15). El **equipo técnico** que lo apoya es **encargado** (reglamento arts. 31 a 33) y **Oracle** es medio tecnológico tercerizado (arts. 28 a 30). Formalizar con una resolución directoral que designe al Director como responsable y al ODP, y con un acuerdo de encargo con el equipo. |
| Q2 | ¿La UGEL/DRE ya tiene **ODP y CSIRT**? | **No bloquea** | No afecta al diseño ni a la operación del sistema. **El CETPRO designa su propio ODP** (puede ser una persona con otras funciones o externa, art. 38.2); compartir uno con la UGEL (art. 37.3) es solo una opción. Se informa a la UGEL por oficio porque supervisa al CETPRO. Pasa a ser una tarea de la puerta de salida a producción. |
| Q3 | ¿Qué se registra de una beca? | Propuesta | Solo convenio, porcentaje y referencia. Confirmar con Dirección. |
| Q4 | ¿Se acepta alojar datos de estudiantes en un proveedor extranjero? | Parcial | Las guías PCM lo permiten (son orientadoras). **Falta comunicar el flujo a la autoridad** y revisar contrato. |
| Q5 | Edad mínima | **Resuelta** | **16, configurable** (valor de la entrevista; piso nacional 14). |
| Q6 | Formato digital para la UGEL | Parcial | El destino es **AVANZA**. Falta el formato y manual. |
| Q7 | Retención de fichas y constancias | Abierta | Proponer plazo configurable; consultar a la UGEL/AGN. |
| Q8 | ¿La web institucional debe estar en gob.pe? | Abierta | Consultar a la UGEL. |
| Q9 | Titularidad y licencia del software | Abierta | Tutora y Dirección. |
| Q10 | Derecho de inscripción y comprobante | Abierta | Dirección. |
| Q11 | ¿Matrícula por programa y periodo o por unidades didácticas? | **Resuelta** | Por **programa y periodo** (oferta), con módulo y unidades **derivados del plan de estudios**; las excepciones (subsanación, convalidada) se registran aparte. Configurable. |
| Q12 | ¿Reglamento Institucional? | **Resuelta** | **No existe**; procesos manuales. Todas las reglas propias son **parámetros configurables** y se documentan como "por formalizar". |
| Q13 | ¿Extranjeros y NEE? | Abierta | Tipo de documento ya contempla extranjeros. NEE: guardar solo una **situación específica** restringida, sin documentos. |
| Q14 | Subdominio | **Resuelta** | **No hay**. El equipo **comprará un dominio** y lo asumirá. |
| Q21 | **Manual y plantillas de AVANZA** | **Parcial** | El **manual v3.5 ya está leído**. **Pendiente**: las plantillas Excel (`PLANTILLA-REGISTRO-ESTUDIANTE`, `PLANTILLA-REGISTRO-MODULOS`) con sus columnas exactas; el equipo las conseguirá. No bloquea: el mapeo de columnas es configurable. La carga en AVANZA queda fuera del sistema. |
| Q22 | **Texto de la Ley 29733** | **Resuelta** | Leída en una copia consolidada de SPIJ (arts. 2, 13 a 18 y 39). No hace falta que la aporten. |
| Q24 | Dominio y Cloudflare | **Parcial** | **Cloudflare, plan gratuito**, para gestión de tráfico y seguridad (decisión del equipo). **Dominio y registrador: pendientes** mientras evalúan alternativas. |
| Q23 | ¿Qué valores se usan en **modalidad del servicio educativo** y **modelo educativo** (Anexo 1)? | Nueva | Presencial / otros. Catálogo configurable. |

## 5. Requisitos derivados propuestos (para el ERS v1.1)

| ID propuesto | Requisito | Origen |
| :--- | :--- | :--- |
| RNF-LEG-01 | **Aviso de privacidad** en lenguaje claro con los diez elementos del art. 6, versionado y con evidencia de aceptación. | DS arts. 6 a 9, 22 |
| RNF-LEG-02 | Solo se recolectan datos necesarios; **sin copia del DNI** ni evidencia socioeconómica ni documentos de discapacidad. | Proporcionalidad; DL 1246 |
| RNF-LEG-03 | Registro de **solicitudes de derechos** con plazo (8, 20 y 10 días hábiles) y alerta. | DS arts. 66 a 71 |
| RNF-LEG-04 | **Registro de incidentes** y procedimiento de notificación en 48 horas (autoridad, titular y CNSD). | DS arts. 34 a 36 |
| RNF-LEG-05 | Retención y eliminación por tipo de dato (configurable). | Principio de conservación |
| RNF-LEG-06 | **Inscribir el banco de datos**, **designar y publicar al ODP** y **comunicar el flujo transfronterizo** antes del despliegue. | DS arts. 21, 37, 42 |
| RNF-LEG-07 | Contrato de **encargo** con el equipo y revisión del contrato de Oracle. | DS arts. 28 a 33, 57 |
| RNF-LEG-08 | **Bitácora** de sesión, visualización, modificación, eliminación, importación y exportación, **≥ 2 años**, continua y disponible. | DS art. 46 |
| RNF-LEG-09 | **Revisión semestral de privilegios** de usuarios. | DS art. 46 |
| RNF-LEG-10 | **Respaldo al menos semanal** con verificación de integridad y restauración; transferencia cifrada. | DS arts. 51 y 52 |
| RNF-LEG-11 | **Documento de seguridad** con fecha cierta e inventario de datos. | DS art. 47 |
| RNF-LEG-12 | **WCAG 2.2 AA**. | RM 126-2009; ISO/IEC 40500:2025 |
| RNF-LEG-13 | **Datos de prueba sintéticos**. | ISO 27002 8.33 |
| RNF-LEG-14 | Código de matrícula = **número de documento** (DNI, carné de extranjería o pasaporte), único durante el programa. | LAG 11.2.2 |
| RNF-LEG-15 | **Edad mínima configurable** (piso 14, valor inicial 16). | DL 1375; entrevista |
| RNF-LEG-16 | **Ratificación de matrícula** por periodo académico. | LAG 11.2.2 y 19.1 |
| RNF-LEG-17 | Exportación del **registro de matrícula** (Anexo 1) para **AVANZA** dentro del mes del inicio del periodo. | LAG 17.1 |
| RNF-LEG-18 | La convalidación guarda **resolución directoral, justificación, ruta complementaria y similitud**. | LAG 11.5 |
| RNF-LEG-19 | La **discapacidad** se guarda solo como situación específica restringida, sin documentos. | DS art. III.5; Anexo 1 |

## 6. Documentos pendientes de conseguir

1. Las **plantillas Excel de AVANZA** (estudiantes y módulos), que el equipo conseguirá. El manual ya está leído. **Pendiente, no bloquea.**
2. ~~Ley 29733~~: leída (copia SPIJ). ~~DS 003-2013-JUS~~: derogado, no se necesita.
3. **Ficha física** de matrícula y ejemplos de **nómina y constancia** vigentes.
4. Constancia de **inscripción del banco de datos** y nombre del ODP (si existen).
5. Directivas de la UGEL/DRE sobre nube, seguridad digital y retención de archivos.
6. Condiciones del servicio social de la UNSCH sobre propiedad del software.

## Fuentes

- **Textos oficiales aportados por el equipo** (`Contexto/Normativa`): DS 016-2024-JUS (El Peruano, 30-nov-2024, 24 páginas con texto), `Lineamientos_Nube.pdf` (43 páginas) y `RS_segdi_N_001_2018_PCM.pdf` (El Peruano, 12-ene-2018), DL 1375 (13-ago-2018), RVM 188-2020-MINEDU (61 páginas, leída con OCR), Anexo 1 vigente (imagen) y la plantilla de entrevista (`Plantilla_Entrevista_Requisitos_CETPRO_V2.docx`).
- **Manual de usuario del SGD AVANZA, módulo de Registro de Datos de CETPRO, v3.5** (DIGEST-Minedu, octubre 2025), aportado por el equipo (`Contexto/Normativa/pdf-manual-del-sistema-avanza-modulo-registro_compress.pdf`, 35 páginas).
- [Ley 29733, copia consolidada de SPIJ (Interseguro)](https://www.interseguro.pe/wp-content/uploads/2019/10/Ley-de-protección-de-datos-personales.pdf).
- [Oficios de UGEL sobre el uso de AVANZA (UGEL 05)](https://cdn.www.gob.pe/uploads/document/file/7205638/6169138-oficio_multiple-00140-2024-minedu-vmgi-drelm-ugel05-dir-agebatp-pdf-para-cetpro.pdf) y [UGEL 07](https://cdn.www.gob.pe/uploads/document/file/7328259/6256379-oficio_multiple-00321-2024-minedu-vmgi-drelm-ugel07-dir-agebatp.pdf), citados por una búsqueda y no abiertos.
- [Ley 29733 actualizada (LP Derecho)](https://lpderecho.pe/ley-proteccion-datos-personales-ley-29733-actualizada/), citada por búsqueda.
- [DL 1705 (LP Derecho)](https://lpderecho.pe/cetpro-reconocer-aprendizajes-previos-facilitar-ingreso-continuidad-estudios-dl-1705/), [DS 029-2021-PCM citado en una resolución UNALM](https://www.lamolina.edu.pe/osi/normativas/TR_0200-2025-R-UNALM.pdf), [DS 033-2018-PCM (El Peruano)](https://busquedas.elperuano.pe/normaslegales/decreto-supremo-que-crea-la-plataforma-digital-unica-del-est-decreto-supremo-n-033-2018-pcm-1629595-1/), [RM 126-2009-PCM](https://www.bn.com.pe/accesibilidad/RM-126-2009.pdf), [DL 1246](https://appddpadigital.agn.gob.pe/ddpa/wp-content/uploads/2024/12/DL-N°-1246.pdf).
