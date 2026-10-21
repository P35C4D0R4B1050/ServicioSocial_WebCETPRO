# Auditoría de la documentación (21-oct-2026)

Se revisó la documentación completa para encontrar incoherencias, vacíos e imprecisiones **antes de redactar specs**, y se corrigió lo corregible. Este registro dice qué se revisó, cómo, qué se encontró y qué se hizo con cada hallazgo. Los cambios están en `docs/`; las líneas base de `Entregables/` no se editaron.

## 1. Alcance y método

| Qué | Detalle |
| :--- | :--- |
| Documentos leídos de principio a fin | Los 50 de `docs/` (7 carpetas, `README.md` y `glossary.md`), `specs/README.md`, `db/README.md`, el esquema SQL v1.1 y sus datos iniciales, la tabla de preguntas de `Investigacion/05` y las secciones citadas de los dos documentos de línea base. |
| Fuentes de verdad contrastadas | Texto de `Contexto/Normativa`: DS 016-2024-JUS, LAG (RVM 188-2020), DL 1375, manual de AVANZA v3.5, lineamientos de nube de la PCM; y la entrevista (`Plantilla_Entrevista_Requisitos_CETPRO_V2.docx`). Las citas legales se comprobaron contra el texto (artículo por artículo), no contra los resúmenes. |
| Verificaciones automáticas | (1) **308 enlaces** internos y anclas, 0 rotos; (2) **57 diagramas** Mermaid, 57 con sintaxis válida; (3) recorrido de **identificadores** (RF, RN, RNF, RNF-LEG, RC, CU, OB, NN, AC, DA, AD, AM, CTL, R, P, Q): definidos, mencionados y huérfanos; (4) tabla AD ↔ DA en ambos sentidos; (5) **122 filas** con identificador comparadas entre la línea base y `docs/`; (6) permisos, parámetros, disparadores, vistas y estados de `docs/` contra el SQL. |
| Cobertura de la matriz nueva | Cada RF, RN, RNF, RNF-LEG, RC, CU, AD, AM y CTL vigente aparece en [la matriz de trazabilidad](../../docs/01-analisis-de-sistema/08-matriz-de-trazabilidad.md) (comprobado con un recorrido automático). |

## 2. Lo que se verificó y está bien

- Las cifras coinciden entre todos los documentos y con el SQL: edad 16 (piso 14), cupo 30, tope de beca 50 %, similitud 80 %, RPO 24 h (4 h en temporada) y RTO 4 h, bloqueo a los 5 fallos por 15 minutos, sesión de 30 minutos y máximo de 8 horas, 25 permisos, 26 parámetros, 11 tablas auditadas por disparador, 7 vistas, 17 specs, 36 AD, 16 DA, 22 AM, 40 CTL y 19 R.
- Los identificadores no se renumeraron: los retirados (RF-13, RF-14, RF-15, RF-18, CU-04, CU-07, RN-08) y el reservado (RF-31) están documentados.
- Las filas de `docs/` conservan el contenido de la línea base (122 filas; solo difieren condensaciones de estilo y tres matices que se restituyeron: C-12).
- Citas legales comprobadas contra el texto oficial: DS 016-2024-JUS (arts. III.5, III.8, 22, 34, 35, 36, 37, 46, 51, 66 a 71), LAG (11.2.1, 11.3, 11.4, 12.1, 12.2.2, 17.1 y 19.1), DL 1375 (art. 45-C y créditos) y manual de AVANZA v3.5 (edad desde los 14 años, plantillas sin celdas vacías).
- La entrevista coincide con lo documentado: 3 personas de matrícula y 2 directivos, turnos de mañana y tarde, cupo de unos 30, becas de hasta 50 %, edad mínima de 16.

## 3. Hallazgos

**Severidad:** *Alta* (impide o distorsiona la redacción de specs), *Media* (genera contradicciones o decisiones implícitas), *Baja* (precisión o forma). **Estado:** *Aplicada* (corregida en `docs/`), *Spec* (la cierra la spec indicada; quedó registrada) o *Puntualizar* (ninguna fuente la resuelve).

### A. Estructura y trazabilidad

| ID | Sev. | Hallazgo | Estado |
| :--- | :---: | :--- | :--- |
| A-01 | Alta | La asignación a specs solo cubría los **RF** (Anexo B del ERS). Las reglas (RN), los no funcionales, las restricciones, los casos de uso, las decisiones, las amenazas, los controles, los parámetros y los pendientes no tenían spec dueña; 6 AD, 6 AM y 10 CTL no se mencionaban fuera de su definición. | Aplicada: [matriz de trazabilidad](../../docs/01-analisis-de-sistema/08-matriz-de-trazabilidad.md) |
| A-02 | Alta | `web-base` estaba en la fase 4, pero `identidad-seguridad` y `transversal-auditoria` (fase 1) necesitan la estructura web (plantilla, sesión, errores, cabeceras y estados). | Aplicada: `web-base` pasa a la fase 1 con tokens provisionales; la identidad visual se incorpora después |
| A-03 | Alta | RF-12 (matriculados por programa, módulo, periodo y turno) estaba en `periodos-ofertas` (fase 2) pero lee matrículas, que se implementan en la fase 3. | Aplicada: pasa a `docs-reportes` |
| A-04 | Media | Dependencias entre specs incompletas: `identidad-seguridad` lee parámetros de seguridad; `transversal-alertas` consume eventos de MAT, RAT, PRI, IDE y OPS; PRI necesita EST; CON necesita CAT. | Aplicada: matriz y `specs/README.md` |
| A-05 | Media | El derecho de inscripción (RF-07) está en `matricula-registro` en las matrices, pero el modelo C4 lo asignaba a `matricula-becas`. | Aplicada |
| A-06 | Media | Dependencias entre módulos inconsistentes entre dos diagramas y el texto: M1 ↔ M6 formaban un ciclo (auditoría y destinatarios de alertas), y M1, M3 y M6 leen parámetros (M2) sin declararlo. | Aplicada: los módulos piden auditoría y alertas por puertos del kernel `Compartido`; M6 → M1 es la única dependencia de M6; se declara M2 como servicio base |
| A-07 | Baja | El prefijo de error `DOC-` no corresponde a ninguna spec. | Aplicada: el prefijo es el de la spec |
| A-08 | Media | La lista de specs y su mapeo vivía en cinco lugares (ERS Anexo B, requisitos §6, `specs/README.md`, clean architecture §9.3 y flujo SDD) con riesgo de divergir. | Aplicada: la matriz es la fuente y las demás remiten a ella |
| A-09 | Media | La trazabilidad decisión ↔ driver tenía 14 inconsistencias (por ejemplo AD-29 declaraba DA-01 y DA-06 y ninguno lo listaba). | Aplicada: 0 inconsistencias |
| A-10 | Baja | Las amenazas (AM) no citaban los controles (CTL) y los riesgos (R-01 a R-19) no se enlazaban con las amenazas. | Aplicada: controles en cada AM y amenaza en los riesgos que la tienen (R-01 a R-05, R-08, R-10, R-17 y R-18) |
| A-11 | Baja | RNF-02 y RNF-03 sin necesidad de origen; RNF-15 solo en NN-16; RNF-06 y RNF-08 no mostraban AC-10. | Aplicada |

### B. Contraste con las fuentes

| ID | Sev. | Hallazgo y fuente | Estado |
| :--- | :---: | :--- | :--- |
| B-01 | Alta | **DS art. 71.1**: la ampliación del plazo no aplica al derecho de información. Los documentos decían que todos los plazos son ampliables y el SQL admite 16 días. | Aplicada en `docs/`; el SQL queda como brecha 2 del modelo de datos (la cierra PRI) |
| B-02 | Media | **DS art. 66.4**: si la solicitud llega al encargado (el equipo), la traslada al responsable en un máximo de 3 días. No estaba. | Aplicada |
| B-03 | Media | **Manual de AVANZA v3.5**: la plantilla de estudiantes se descarga con el periodo lectivo y el programa ya elegidos, y la carga se rechaza por encima de 500 estudiantes (caso 4, notas). No estaba. | Aplicada (el límite queda «por verificar» para estudiantes) |
| B-04 | Media | **LAG 11.2.1**: para NEE se pide certificado de discapacidad o informe del SAANEE; la lista de requisitos del SQL no lo incluye. | Spec: MAT (brecha 5) |
| B-05 | Baja | Glosario: las 18 semanas son del **periodo académico** (LAG 19.1), no del periodo lectivo. | Aplicada |
| B-06 | Baja | DL 1375 dice «mayor de 14 años» y la LAG «edad mínima de catorce». | Aplicada: nota en el marco legal |
| B-07 | Baja | Marcas de verificación: DL 1705 figuraba ✔✔ pese a admitir discrepancia; RNF-LEG-10 omitía el art. 48. | Aplicada |
| B-08 | Info | La entrevista pide «subida de notas» y el registro de notas como función crítica. | Sin cambio: fuera de alcance por decisión del equipo (R-11) |

### C. Coherencia interna

| ID | Sev. | Hallazgo | Estado |
| :--- | :---: | :--- | :--- |
| C-01 | Alta | **RF-42 (borrador de la ficha) no tiene dónde guardarse**: no hay tabla ni entidad, y el borrador contiene datos personales. | Aplicada en el dominio; Spec: MAT (brecha 1) |
| C-02 | Media | La auditoría por disparador no cubre `identidad.usuario`, `identidad.usuario_rol`, el aviso de privacidad ni la emisión de documentos, pese a que los documentos dicen que las altas y bajas quedan en la bitácora. | Aplicada (aclarado quién registra); Spec: IDE y PRI (brecha 3) |
| C-03 | Media | La **revocación de constancias** existe en el modelo, el SQL, AD-11, CTL-14 y AM-02, pero sin permiso ni actor. | Puntualizar: P-16; Spec: CST (brecha 4) |
| C-04 | Media | Las alertas se dicen «parametrizables», pero el SQL solo tiene 2 parámetros de alertas; faltan 10 valores (mitad de plazo, 90 y 30 días, dos umbrales, límites de uso, aviso de sesión, vigencia del borrador y límite de filas). | Aplicada: catálogo de 26 parámetros y 10 propuestos (modelo de datos §12) |
| C-05 | Media | «Bloqueo por inactividad corta» contradecía la sesión de 30 minutos. | Aplicada |
| C-06 | Media | RNF-15 y AD-13 decían ASVS nivel 2 en todo; la lista de controles aplica nivel 2 solo en los capítulos de mayor riesgo. | Aplicada |
| C-07 | Media | El código de matrícula **es** el documento, pero solo el documento se enmascaraba en los listados. | Aplicada |
| C-08 | Media | La ficha no tenía el paso de aviso de privacidad (RF-35); el Personal de matrícula no tenía pantalla para registrar solicitudes de derechos ni para consultar parámetros. | Aplicada |
| C-09 | Baja | «Cinco usuarios» ignoraba las una o dos cuentas de Administrador. | Aplicada |
| C-10 | Baja | RNF-04 «solo escritorio» frente a la verificación pública, que se abre desde un QR. | Aplicada: excepción explícita |
| C-11 | Baja | Tras una reincorporación, la matrícula anterior queda en LICENCIA; no estaba explícito. El dominio omitía RF-42 y RF-43. | Aplicada |
| C-12 | Baja | Matices perdidos al condensar la línea base: RN-10 (requisito para mantener la condición de estudiante), RNF-11 (campos y alertas son parámetros) y AD-24 (plantillas con periodo y programa predefinidos). | Aplicada |
| C-13 | Baja | Detalles: `tests/load/` (k6) ausente del árbol, referencia a un «Informe de UX» inexistente, columna `observaciones` sin documentar, turno fijo en el glosario. | Aplicada |

### D. Preguntas y pendientes

| ID | Sev. | Hallazgo | Estado |
| :--- | :---: | :--- | :--- |
| D-01 | Media | La lista de preguntas pedía al equipo cosas que las fuentes resuelven o que ninguna fuente menciona: P-06 (extranjeros y NEE), P-13 (turno noche), P-14 («reingresante»), P-12 y Q25 a Q27 (ya respondidas). | Aplicada: [pendientes y puntos por puntualizar](../../docs/README.md#pendientes-y-puntos-por-puntualizar) (10 puntos sin fuente; 6 resueltos, fusionados o retirados) |

### E. Forma

| ID | Sev. | Hallazgo | Estado |
| :--- | :---: | :--- | :--- |
| E-01 | Baja | «Autoregistro» en lugar de «autorregistro» (13 archivos). | Aplicada |
| E-02 | Baja | El encabezado del SQL y `db/README.md` seguían diciendo «no ejecutado». | Aplicada (solo comentarios) |
| E-03 | Baja | La propuesta en Word decía 49 documentos y listaba P-06 y P-13. | Aplicada: regenerada |

## 4. Reorganización de carpetas

| Antes | Ahora |
| :--- | :--- |
| `Documento-de-Analisis-ERS-v1.1.md`, `Documento-de-Arquitectura.md` y la propuesta `.docx` en la raíz | `Entregables/` (el de arquitectura pasa a `Documento-de-Arquitectura-v0.4.md`) |
| Cuatro archivos sueltos en `Contexto/` | `Contexto/Antecedentes/` (documento de análisis v1.0, esquema v1.0 e Informe 004) y `Contexto/Referencia-de-formato/` (`Propuesta_Librería.pdf`) |
| `db/LEEME.md`, `Contexto/Prototipo/local/LEEME.md` | `README.md` en ambos |
| Sin índices | `README.md` en la raíz, `Entregables/` y `Contexto/` |

Los enlaces de los documentos movidos y de quienes los citan se actualizaron; `Contexto/DocumentacionEjemplo` no se tocó.

## 5. Brechas que quedan para las specs

No impiden redactarlas: están registradas con su spec dueña en el [modelo de datos, sección 13](../../docs/03-diseno-de-software/05-modelo-de-datos.md#13-brechas-conocidas-del-esquema-v11) (ocho brechas) y en la [matriz](../../docs/01-analisis-de-sistema/08-matriz-de-trazabilidad.md).

## 6. No se editó

- `Entregables/Documento-de-Analisis-ERS-v1.1.md` y `Entregables/Documento-de-Arquitectura-v0.4.md`: solo enlaces y el árbol de carpetas. Conservan «autoregistro», el RF-12 en OFE y las preguntas Q25 a Q27 como abiertas; mandan `docs/` y esta auditoría.
- El esquema SQL (salvo comentarios) y sus pruebas: probados por el equipo.
- `Contexto/`: no se modificó ningún archivo.

## 7. Siguiente paso

Revisar `docs/` (en especial la matriz, el catálogo de parámetros y las brechas) y, cuando esté aceptada, iniciar la **Fase 0** del SDD. La UI/UX y la identidad visual se redactan después; no bloquean las specs de la fase 1.
