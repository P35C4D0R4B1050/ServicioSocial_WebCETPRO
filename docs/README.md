# Documentación del Sistema de Matrícula del CETPRO "Joaquín López Antay"

Esta carpeta es la **documentación viva** del sistema: la fuente de verdad que leerán las personas y los agentes de IA antes de escribir una especificación o una línea de código (SDD, RC-07). Se organiza en siete carpetas temáticas. El orden sugiere el camino de lectura: qué se necesita, cómo se estructura la solución, cómo se diseña, cómo se protege, cómo se usa y cómo se construye.

| Carpeta | Pregunta que responde | Documentos |
| :--- | :--- | :--- |
| [01-analisis-de-sistema](01-analisis-de-sistema/) | ¿Qué problema se resuelve y qué debe cumplir el sistema? | Necesidad del negocio (OB, NN), requisitos (RF, RN, RNF, RC), marco legal, atributos de calidad (AC), actores y permisos, procesos y casos de uso, modelo de dominio y **matriz de trazabilidad hacia las specs**. |
| [02-arquitectura-de-software](02-arquitectura-de-software/) | ¿Qué estructura global tiene y por qué? | Drivers (DA), decisiones (AD), estilo, escenarios y flujos, despliegue en Oracle, tácticas y presupuesto de recursos. |
| [03-diseno-de-software](03-diseno-de-software/) | ¿Cómo se ordena el código por dentro? | Clean Architecture, organización interna, patrones, módulos y contratos, modelo de datos, estados y concurrencia, mapeo a IEEE 1016. |
| [04-modelo-c4](04-modelo-c4/) | ¿Cómo se ve la arquitectura en distintos niveles de zoom? | Contexto (nivel 1), contenedores (nivel 2) y componentes por módulo (nivel 3). |
| [05-seguridad](05-seguridad/) | ¿Cómo se protege el sistema y sus datos? | Modelo de amenazas (AM), controles ASVS (CTL), autenticación y autorización, privacidad, integraciones, seguridad del desarrollo con IA, operación y mapeo a estándares. |
| [06-experiencia-de-usuario](06-experiencia-de-usuario/) | ¿Cómo se usa y se hace accesible? | Identidad y sistema de diseño, pantallas, estados, heurísticas, personas, accesibilidad WCAG, rendimiento percibido, mensajes y pruebas de usabilidad. |
| [07-proceso-de-desarrollo](07-proceso-de-desarrollo/) | ¿Cómo se construye y se verifica? | Flujo Spec-Driven Development asistido por IA, convenciones técnicas y estrategia de pruebas. |

Además: [glosario](glossary.md).

## Trazabilidad

`Necesidad (NN)` → `Requisito (RF, RN, RNF, RC)` → `Atributo de calidad (AC)` → `Driver (DA)` → `Decisión (AD)` → `Estilo y diseño` → `Spec` → `Prueba`

Reglas de los identificadores:

1. **Los existentes no se renumeran.** Lo modificado conserva su código; lo retirado no se reutiliza; lo nuevo se agrega al final de su serie.
2. Los requisitos conservan los códigos del ERS v1.1 con guion (`RF-01`, `RN-09`, `RNF-12`, `RNF-LEG-08`, `RC-07`, `CU-13`). Los atributos de calidad son `AC-01` a `AC-10`.
3. Los **criterios de aceptación** de una spec se escriben `AC-<MÓDULO>-<NN>` (por ejemplo `AC-MAT-01`) y **no** se confunden con los atributos de calidad.
4. Series propias de esta carpeta: `OB`, `NN` (negocio); `DA`, `AD` (arquitectura); `AM` (amenazas) y `CTL` (controles); `R` (riesgos); `P` (pendientes).

## Relación con los documentos de línea base

| Documento | Estado |
| :--- | :--- |
| [Documento de Análisis (ERS) v1.1](../Entregables/Documento-de-Analisis-ERS-v1.1.md) | **Línea base aprobada por el equipo.** Su contenido se distribuyó en `01-analisis-de-sistema`. |
| [Documento de Arquitectura v0.4](../Entregables/Documento-de-Arquitectura-v0.4.md) | **Línea base aprobada por el equipo.** Su contenido se distribuyó en `02` a `05` y `07`. |
| [Esquema SQL v1.1](../db/esquema_matricula_cetpro_v1.1.sql) | Referencia ejecutable del modelo de datos; probado en PostgreSQL por el equipo. |
| [`Investigacion/`](../Investigacion/README.md) | Borrador de trabajo con las fuentes y su nivel de verificación. |

**A partir de ahora, un cambio de comportamiento se hace aquí.** Los documentos de línea base no se editan (salvo el aviso de estado que remite a esta carpeta); si algo cambia, se actualiza `docs/` y se anota en el control de cambios del documento afectado. Esto evita tener dos fuentes de verdad.

## Adaptaciones respecto de la estructura de ejemplo

La estructura sigue la del proyecto de ejemplo del equipo (BabelHub), que se leyó solo como referencia. Tres archivos cambiaron porque el producto es distinto:

| Ejemplo | Aquí | Motivo |
| :--- | :--- | :--- |
| `05-seguridad/06-seguridad-del-asistente.md` | `05-seguridad/06-seguridad-del-desarrollo-con-ia.md` | El sistema no tiene un asistente con LLM; el riesgo de IA que sí existe es el **desarrollo asistido por IA** (AD-36). |
| `06-experiencia-de-usuario/07-rendimiento-y-movil.md` | `06-experiencia-de-usuario/07-rendimiento-percibido.md` | El uso es **solo de escritorio** (RNF-04); no hay diseño móvil. |
| `03-diseno-de-software/04-modulos-y-contratos.md` | Mismo nombre, otro contenido | Es un **monolito modular**: los contratos entre módulos son interfaces internas, no API REST entre servicios. |

## Convenciones de los documentos

- Español del Perú. Diagramas en Mermaid.
- Cada afirmación normativa indica su fuente; lo que no se verificó se marca **por verificar**. Nada de lo legal es asesoría.
- Lo que el CETPRO no tiene formalizado (no existe un Reglamento Institucional) es un **parámetro configurable** (RNF-11), no una regla fija.
- **Límites del sistema:** AVANZA no ofrece API; su carga es manual y queda fuera del sistema (ver [necesidad del negocio](01-analisis-de-sistema/01-necesidad-del-negocio.md), sección 3). Ninguna spec debe suponer lo contrario.
- No se diseñan pantallas finales: los prototipos de Figma son **referencia** y se afinarán con la propuesta final ([experiencia de usuario](06-experiencia-de-usuario/README.md)).

## Pendientes y puntos por puntualizar

**Regla (21-oct-2026):** no se consulta al equipo lo que una fuente ya responde. Cada punto se busca primero en la normativa (`Contexto/Normativa`), la entrevista, el manual de AVANZA, el ERS y los informes. Si una fuente lo responde, se aplica y se cita; si ninguna lo menciona, no se considera; si el tema existe pero ninguna fuente fija el valor, queda como **parámetro por definir** o como **punto por puntualizar**. La auditoría que originó esta lista está en [`progress/log/2026-10-21-auditoria-de-la-documentacion.md`](../progress/log/2026-10-21-auditoria-de-la-documentacion.md).

### Puntos por puntualizar (ninguna fuente fija el valor)

La última columna dice qué **hacen las specs mientras tanto**, para que ningún punto bloquee el trabajo.

| # | Punto | Qué se buscó | Quién lo cierra | Mientras tanto (en las specs) |
| :--- | :--- | :--- | :--- | :--- |
| P-01 | Plantillas Excel de AVANZA (estudiantes y módulos) y sus listas de valores (modalidad, modelo educativo, grado de instrucción) | El manual v3.5 describe el procedimiento y algunas columnas, no la plantilla completa; el Anexo 1 solo trae nombres de campo | Equipo (las descarga el Director desde AVANZA) | `docs-archivos-avanza` usa el mapeo como **dato configurable** (`avanza_mapeo_columnas` y las vistas `v_exportacion_avanza_*`, con columnas provisionales) y su criterio de cierre exige probar con la plantilla real |
| P-02 | Dominio y registrador | Ninguna fuente | Equipo | El dominio es una variable de despliegue; el desarrollo y las pruebas usan un nombre local |
| P-03 | Validar la matriz de permisos inicial; el Administrador es hoy el equipo desarrollador y luego la Dirección | La entrevista fija 3 personas de matrícula y 2 directivos; no habla del Administrador | Dirección | Rige la matriz inicial de [actores y permisos](01-analisis-de-sistema/05-actores-y-permisos.md) (editable con auditoría, RF-39); el Administrador actúa bajo el acuerdo de encargo |
| P-04 | Monto del derecho de inscripción y plazo de reserva de la licencia | Entrevista: «derecho de inscripción» sin monto; LAG 11.4: «plazo máximo determinado» sin valor | Dirección | Los parámetros quedan en `null`: leerlos da un **error explícito** (AD-27) y las specs `matricula-registro` y `matricula-ratificacion-licencia` escriben el criterio «si el parámetro está por definir» con su prueba; el sistema no inventa valores |
| P-05 | Plazos de retención de fichas y constancias | LAG 12.2.2: «serán registrados en el CETPRO»; ninguna norma leída fija plazos | UGEL y Dirección | `retencion_matriculas_anios` en `null`: **no se depura ni anonimiza** nada de estudiantes (RF-38 queda diferida); solo se depura la bitácora tras 2 años |
| P-08 | Formato propio de la nómina y de la constancia | LAG 12.1 solo define qué acredita la constancia; la ficha de matrícula es el Anexo 1 | Dirección | Formatos provisionales: la nómina sigue los campos del Anexo 1 y la constancia lleva programa, periodo, código y QR; se ajustan cuando la Dirección entregue los suyos |
| P-09 | Titularidad y licencia del software | Ninguna fuente | Tutoría y Dirección | No se agrega archivo `LICENSE`: sin licencia explícita rigen los derechos de autor por defecto |
| P-10 | ¿La web institucional debe estar en gob.pe? | DS 033-2018-PCM: no se pudo confirmar si una institución educativa pública está obligada | UGEL | Se asume un sitio estático propio; migrar a gob.pe no afecta a la matrícula porque están aislados |
| P-11 | Formalizar al responsable y al ODP, el acuerdo de encargo y las demás puertas de salida | DS arts. 37 a 45 | Dirección y equipo | No se opera con datos reales hasta cerrarlas; todo el desarrollo y las pruebas usan datos sintéticos |
| P-16 | Quién revoca una constancia emitida | AD-11 y CTL-14 prevén revocarla con motivo; ninguna fuente dice quién | Dirección, al validar la matriz (P-03) | `docs-constancia` especifica el permiso `CONSTANCIA_REVOCAR` para el Personal de matrícula, con motivo y bitácora |
### Resueltos o retirados

| # | Resultado |
| :--- | :--- |
| P-06 | **Resuelto con fuentes.** AVANZA admite DNI, carné de extranjería, pasaporte y PTP; la LAG 11.2.1 pide, para NEE asociadas a discapacidad, certificado de discapacidad o informe del SAANEE. Se trata como requisito condicional de la lista configurable y como situación específica restringida (ver [modelo de datos](03-diseno-de-software/05-modelo-de-datos.md#13-brechas-conocidas-del-esquema-v11), brecha 5). |
| P-07 | **Fusionado con P-01**: los valores de modalidad y modelo educativo salen de las listas de AVANZA. |
| P-12 | **Resuelto.** Herramientas de IA: Claude principalmente y, de forma opcional, las de opencode Go, aclarando antes al agente (AD-36). |
| P-13 | **Retirado.** La entrevista habla de mañana y tarde; ninguna fuente menciona turno noche. El turno es un catálogo configurable. |
| P-14 | **Retirado.** Los tipos de ingreso son los de la LAG y AVANZA (RF-04); «reingresante» no figura en ninguna fuente. |
| P-15 | **Pasa a la hoja de ruta.** Afinar el prototipo de Figma y redactar el documento de UI/UX y la identidad visual (ver [revisión del prototipo](06-experiencia-de-usuario/10-revision-del-prototipo.md)). No es una pregunta. |