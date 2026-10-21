# Marco legal y de cumplimiento

> **Esto no es asesoría legal.** Resume los textos oficiales que el equipo aportó y las fuentes públicas consultadas para saber qué diseñar. Antes de operar con datos reales, una persona abogada debe revisarlo y la UGEL Huamanga / DRE Ayacucho debe confirmar lo que dependa de ellas. El detalle y las citas completas están en [`Investigacion/01`](../../Investigacion/01-marco-legal-y-normativo.md).

**Marcas de verificación:** ✔✔ leído en el texto oficial aportado o coinciden dos o más fuentes; ✔ una sola fuente o fuente oficial citada indirectamente; ? no verificado.

## 1. Hechos del proyecto que determinan qué norma aplica

| Hecho | Consecuencia |
| :--- | :--- |
| El CETPRO es una **institución educativa pública** (UGEL Huamanga, DRE Ayacucho). | Aplican las normas para entidades públicas: **oficial de datos obligatorio**, gobierno y seguridad digital. |
| Se tratan datos de estudiantes desde los **14 años** (norma) o **16** (regla institucional); parte son menores de 18. | Consentimiento propio de 14 a 17 años con información en lenguaje comprensible (DS art. 22). |
| La ficha oficial pide la situación de **discapacidad**. | Es dato de salud y por tanto **sensible** (DS art. III.5). |
| Las **becas** se otorgan «según necesidades». | Los **ingresos económicos** son dato sensible (Ley art. 2.5). Se guarda solo el resultado, no la evidencia. |
| El sistema se aloja en **Oracle**, fuera del Perú. | Servicio tecnológico tercerizado (DS arts. 28 a 30) y **flujo transfronterizo** (arts. 18 a 21) que debe comunicarse a la autoridad. |
| Lo desarrolla un **equipo externo** (servicio social UNSCH). | El equipo es **encargado del tratamiento** (DS arts. 31 a 33): contrato, secreto y conservación máxima de 2 años tras el encargo. |
| El CETPRO es el **responsable** (titular del banco de datos). | Decide finalidad, contenido y seguridad (Ley art. 2). Debe formalizarlo con resolución directoral. |
| No hay Reglamento Institucional. | Las reglas propias son **parámetros** documentados como «por formalizar». |

## 2. Protección de datos personales

La **Ley 29733** sigue vigente. Lo derogado es su reglamento de 2013: el **DS 016-2024-JUS** (publicado el 30-nov-2024; vigente desde ≈ 30-mar-2025; para entidades públicas rige desde la vigencia general) lo reemplaza.

### 2.1 Ley 29733 (copia consolidada leída)

| Art. | Qué dice | Implicancia | Verif. |
| :--- | :--- | :--- | :---: |
| 2.5 | Son datos sensibles: biométricos, origen racial y étnico, **ingresos económicos**, opiniones, afiliación sindical, salud o vida sexual. | Becas y discapacidad se tratan con cuidado. | ✔✔ |
| 14.1 | No se requiere consentimiento cuando los datos se recopilan o transfieren **para el ejercicio de las funciones de las entidades públicas** en el ámbito de sus competencias. | La base legal de la matrícula es la **función pública**; el consentimiento queda para lo adicional (fotos, mensajería, difusión). | ✔✔ |
| 15 | Flujo transfronterizo solo a países con nivel adecuado; si no, el emisor garantiza el tratamiento. | Oracle: documentar garantías y comunicar. | ✔✔ |
| 16, 17 | Medidas técnicas, organizativas y legales; **confidencialidad** de titular, encargado y quien intervenga. | Acuerdos de confidencialidad con el equipo. | ✔✔ |
| 18 | Derecho de información: finalidad, destinatarios, banco, identidad del titular **y del encargado**, plazo de conservación, cómo ejercer derechos. | El aviso nombra al equipo técnico y a Oracle. | ✔✔ |
| 39 | Multas leves 0,5 a 5 UIT; graves hasta 50 UIT; muy graves hasta 100 UIT; sin perjuicio de sanciones disciplinarias al personal público. | El personal del CETPRO también responde. | ✔✔ |

### 2.2 DS 016-2024-JUS (texto oficial leído)

| Art. | Qué establece | Implicancia para el sistema | Verif. |
| :--- | :--- | :--- | :---: |
| 6 a 10 | Consentimiento informado, con lenguaje sencillo; **diez elementos** del aviso; para datos sensibles, por escrito; la prueba es del responsable; la revocación es gratuita (10 días). | **Aviso de privacidad** versionado con evidencia (RF-35). | ✔✔ |
| 18 a 21 | Flujo transfronterizo: nivel adecuado o garantías; **art. 21.2: debe ponerse en conocimiento de la autoridad**. | Comunicar el flujo hacia la región de Oracle. | ✔✔ |
| 22 a 25 | Menores: pueden consentir los **mayores de 14 y menores de 18** con información comprensible; no se recopilan datos de la familia salvo lo necesario. | Aviso en lenguaje claro; no pedir datos de padres. | ✔✔ |
| 28 a 30 | **Medios tecnológicos tercerizados**: informar subcontrataciones, mantener el control, exigir evidencia de destrucción al terminar. | Revisar el contrato de Oracle. | ✔✔ |
| 31 a 33 | **Encargo**: no transferir a terceros; conservar como máximo 2 años tras el último encargo. | Acuerdo con el equipo; sin copias de datos reales. | ✔✔ |
| 34 | **Incidentes**: notificar a la autoridad **en 48 horas** cuando expongan grandes volúmenes, afecten a muchas personas, involucren datos sensibles o causen perjuicio evidente; también al CNSD si es digital. | Condicionada, no para toda brecha. Con datos de adolescentes y discapacidad casi cualquier fuga relevante la activa. | ✔✔ |
| 35, 36 | Todo incidente se **documenta**; el encargado informa de inmediato. | Registro de incidentes (RF-37). | ✔✔ |
| 37 a 39 | **ODP obligatorio** para entidades públicas; puede tener otras funciones o ser externo; se publica su contacto y se comunica a la autoridad en 15 días. | Designar y publicar al ODP. | ✔✔ |
| 40 | Evaluación de impacto (facultativa), basada en NTP-ISO/IEC 27005 y NTP-ISO 31000. | EIPD breve. | ✔✔ |
| 42 a 45 | Las entidades públicas **inscriben sus bancos de datos** (gratuito, aprobación automática). | Inscribir «Estudiantes y matrículas». | ✔✔ |
| **46** | Accesos de alta a baja; **revisión de privilegios al menos semestral**; registros de sesión, **procesamiento, visualización, modificación, eliminación, importación y exportación**, conservados **≥ 2 años**. | La bitácora de lecturas y exportaciones es **obligación legal** (RF-34). | ✔✔ |
| 47 | **Documento de seguridad** con fecha cierta e inventario de datos y sistemas. | Se alimenta de esta carpeta (RNF-LEG-11). | ✔✔ |
| 48, 51, 52 | **Respaldos al menos semanales**, con verificación de integridad y recuperación; intercambio fuera de las instalaciones con autorización y cifrado, firma o *checksum*. | Respaldo diario cifrado supera el mínimo. | ✔✔ |
| 66 a 71 | **Plazos** (días hábiles, art. III.8): información 8, acceso 20, rectificación, cancelación y oposición 10, contados desde el día siguiente (art. 69). **Se amplían una sola vez y por igual plazo, salvo el de información** (art. 71.1). Si la solicitud llega al encargado, este la traslada al responsable en un máximo de 3 días (art. 66.4). | Registro de solicitudes con alerta (RF-36). El equipo técnico, como encargado, traslada lo que reciba en 3 días. | ✔✔ |
| 76.6 | La portabilidad no aplica al tratamiento necesario para competencias públicas. | No se implementa. | ✔✔ |
| 131 a 135 | Infracciones leves (no inscribir, no designar ODP, no comunicar el flujo, incumplir medidas) y graves (datos sensibles sin seguridad, no notificar incidentes). | Justifica los controles. | ✔✔ |

## 3. Educación Técnico-Productiva y registro de matrícula

| Norma | Qué establece | Implicancia | Verif. |
| :--- | :--- | :--- | :---: |
| **DL 1375**, art. 42 de la Ley 28044 | Se accede mayor de **14 años**. Ciclos **Auxiliar Técnico** (≥ 40 créditos) y **Técnico** (≥ 80; exige primaria completa o ciclo intermedio de EBA). | Edad mínima nacional 14; el 16 es regla institucional (parámetro). El DL dice «mayor de 14 años» y la LAG 11.2.1 «edad mínima de catorce (14) años»; manda la LAG (más específica) y AVANZA registra «a partir de los 14». | ✔✔ |
| DL 1375, art. 45-C | Los CETPRO implementan un Registro de **Matrícula**, de **Notas** y de **Certificados Modulares**, supervisado por la UGEL. | Este sistema cubre solo el de Matrícula. | ✔✔ |
| **LAG 11.2.1** (RVM 188-2020) | Requisitos: ficha firmada, certificado de estudios (ciclo técnico), fotos; NEE con certificado o informe del SAANEE. | Lista configurable; se registra que se verificó, no el documento. | ✔✔ |
| **LAG 11.2.2** | La matrícula se registra en la **ficha (Anexo 1)**. **El código es el número del documento.** La **ratificación** se hace en cada periodo académico. | RN-09, RN-10. | ✔✔ |
| LAG 11.1 | Las vacantes se determinan según la capacidad operativa. | Cupo referencial configurable. | ✔✔ |
| **LAG 11.3 y 11.4** | **Licencia de estudios** sin invocar causa; **reincorporación** dentro del plazo de reserva; si no, se pierde el derecho de matrícula. | RN-11; el plazo es un parámetro por definir. | ✔✔ |
| **LAG 11.5** | **Convalidación** por Resolución Directoral, con justificación y ruta formativa complementaria; entre unidades didácticas, ≥ 80 % de contenido similar. | RN-12. | ✔✔ |
| LAG 12 | Constancia de estudios, certificado de estudios, certificado modular; se registran en el CETPRO. | La «constancia de matrícula» de la entrevista es la **constancia de estudios**. | ✔✔ |
| **LAG 17.1** | **Registro de matrícula dentro del mes siguiente** al inicio del periodo; reporte al Minedu; mientras no exista el sistema, en soporte digital a la UGEL. | RN-16 y alerta del plazo. | ✔✔ |
| **LAG 19.1** | **Periodo académico de 18 semanas**, máximo 24 créditos, en CETPRO públicos. | Periodo semestral. | ✔✔ |
| **Manual de AVANZA v3.5** (oct. 2025) | Orden obligatorio: plan (con resolución de autorización), módulos, unidades, estudiantes, notas. Registro por periodo lectivo, programa, módulo y periodo académico; DNI validado con RENIEC; plantilla Excel **sin celdas vacías**; uso del Director. La plantilla de estudiantes se descarga con el periodo lectivo y el programa ya elegidos. El manual documenta (caso 4, notas) que la carga se rechaza por encima de **500 estudiantes** por archivo y se divide en partes. | El sistema genera archivos con ese formato; **la carga queda fuera**. Si un archivo supera el máximo, se divide en partes (el límite de 500 está **por verificar** para estudiantes). | ✔✔ |
| DS 004-2019-MINEDU (citado en el manual) | Registrar tarde es **infracción grave** para el CETPRO. | Alerta del plazo. | ✔ |
| DL 1705 (2026) | Reconocimiento de aprendizajes previos (la prensa y el texto oficial difieren; se toma el texto oficial). | Ya previsto como tipo de convalidación. | ✔ |

**Anexo 1 vigente (2025), campos de la ficha:** CETPRO, DRE/GRE, código modular, UGEL, departamento, tipo de gestión, provincia, distrito, periodo lectivo, periodo académico, programa de estudios, inicio y término de clases, módulo, ciclo, apellidos y nombres, número de documento, modalidad del servicio, grado de instrucción, modelo educativo y edad; tablas de unidades didácticas, unidades de subsanación y experiencias formativas; observaciones (PIR, Transitabilidad, MOT, Discapacidad).

## 4. Gobierno digital, nube y seguridad digital

| Norma | Qué establece | Implicancia | Verif. |
| :--- | :--- | :--- | :---: |
| **Lineamientos de nube de la PCM** (Res. SeGDi 001-2018-PCM/SEGDI) | **Orientadores, no imponen obligaciones**; la responsabilidad final es de la entidad. Recomienda cifrar antes de enviar con claves de la entidad, no gestionar altas y bajas de usuarios en la nube, conservar registros preferentemente en la entidad, proveedor con ISO 27001/27017/27018. | Se adoptan: respaldo cifrado con clave del CETPRO y copia de la bitácora en el CETPRO. La recomendación sobre usuarios **no se cumple** (Identity vive en la app) y se mitiga con MFA y revisión semestral. | ✔✔ |
| DL 1412 y DS 029-2021-PCM | Gobierno digital; nube primero; CSIRT institucional; SGSI. | Alinear con el comité de gobierno digital de la UGEL/DRE. | ✔✔ |
| DU 007-2020 | Confianza digital; registro de incidentes en el CNSD. | Un incidente digital se reporta además al CNSD. | ✔✔ |
| NTP-ISO/IEC 27001:2022 | SGSI de entidades públicas. | Alinear; no se exige certificar al CETPRO. | ✔ |
| DS 033-2018-PCM (gob.pe) | Migración de canales a gob.pe. | **No se pudo confirmar** si una IE pública está obligada: consultar a la UGEL antes de publicar la web institucional. | ✔ / ? |
| RM 126-2009-PCM; Ley 29973 | Portales públicos accesibles. | WCAG 2.2 AA (ISO/IEC 40500:2025). | ✔ |
| DL 1246 | Interoperabilidad; una fuente indica que se prohíbe exigir copia del DNI. | No se pide ni guarda copia del DNI. | ✔ |
| Archivos, transparencia, delitos informáticos | No verificados; no se hallaron plazos de conservación de fichas de matrícula. | Consultar a la UGEL. | ? |

## 5. Contraste con la entrevista

| Tema | Entrevista | Normativa | Decisión de diseño |
| :--- | :--- | :--- | :--- |
| Edad mínima | 16 años | 14 (DL 1375, LAG) | **Parámetro, valor inicial 16**; se guarda el valor aplicado. |
| Datos que se piden | Nombre, apellido, nacimiento, DNI, dirección, correo, celular, especialidad | AVANZA exige apellido paterno y materno, sexo, ubigeo, dirección, correo y teléfonos, sin celdas vacías | Obligatorios mínimos; los demás se piden porque AVANZA los exige y el sistema **avisa antes de exportar**. |
| Requisitos | Documento de identidad y derecho de inscripción | Además ficha firmada, certificado (ciclo técnico), fotos | Lista configurable; se registra que se verificó. |
| Especialidades | 13; en 2026, 3 de título técnico y 7 de auxiliar | Programa, ciclo, créditos | Catálogo configurable. |
| Turnos y cupos | Mañana y tarde, sin límite; referencia de 30 | Vacantes según capacidad operativa | Cupo **referencial**. |
| Becas | Convenios, hasta 50 % | No regulado en lo leído | Tope configurable; solo el resultado. |
| Reportes | Constancia PDF, nómina, reportes por módulo | Registro en AVANZA dentro del mes | Documentos filtrables por programa, módulo, periodo y turno. |
| Notas | Tercera función crítica | Obligación del CETPRO | **Fuera de alcance** (R-11). |
| Entorno | Red local, 3 PC | — | **Superado por Oracle**; riesgo de depender de Internet. |

## 6. Obligaciones previas a operar con datos reales (puertas de salida)

| Condición | Responsable | Estado |
| :--- | :--- | :---: |
| **ODP** designado por el CETPRO y publicado (comunicado a la autoridad en 15 días) | Dirección | Pendiente |
| Banco de datos **inscrito** en el Registro Nacional | Dirección | Pendiente |
| Resolución directoral que designa al **responsable** y al ODP | Dirección | Pendiente |
| **Flujo transfronterizo comunicado** (art. 21.2) y contrato de Oracle revisado | Responsable | Pendiente |
| **Documento de seguridad** con fecha cierta e inventario de datos | Equipo y responsable | Pendiente |
| **Acuerdo de encargo y confidencialidad** con el equipo técnico | Dirección y equipo | Pendiente |
| **Restauración** probada y medida contra el RTO | Equipo | Pendiente |
| Capacitación breve de las 5 personas usuarias | Equipo | Pendiente |

## 7. Documentos pendientes de conseguir

1. Plantillas Excel de AVANZA (estudiantes y módulos). No bloquea: el mapeo de columnas es configurable.
2. Formatos propios del CETPRO para la nómina y la constancia (la ficha de matrícula es el Anexo 1 oficial, ya incluido; la LAG 12 solo fija que la constancia de estudios acredita que el estudiante cursa un módulo o programa).
3. Constancia de inscripción del banco de datos y nombre del ODP, si existen.
4. Directivas de la UGEL/DRE sobre nube, seguridad digital y retención de archivos.
5. Condiciones del servicio social de la UNSCH sobre propiedad del software.

## 8. Fuentes

Textos oficiales aportados por el equipo (`Contexto/Normativa`): DS 016-2024-JUS, lineamientos de nube de la PCM y su resolución, DL 1375, RVM 188-2020-MINEDU, ISO/IEC 27002:2022, Anexo 1 vigente y el manual de AVANZA v3.5. La Ley 29733 se leyó en una copia consolidada de SPIJ. Las demás referencias, con enlace, están en `Investigacion/01`.
