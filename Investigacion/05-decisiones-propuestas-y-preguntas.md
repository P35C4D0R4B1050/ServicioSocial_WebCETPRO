# Decisiones, parámetros, cambios y preguntas abiertas

Consolida los informes [01 marco legal](01-marco-legal-y-normativo.md), [02 seguridad y estándares](02-seguridad-y-estandares.md), [03 despliegue y continuidad](03-despliegue-y-continuidad-oracle.md) y [04 experiencia de usuario](04-ux-y-experiencia.md).

**Actualización 5.ª ronda.** Se redactaron el [ERS v1.1](../Entregables/Documento-de-Analisis-ERS-v1.1.md) y el [esquema SQL v1.1](../db/esquema_matricula_cetpro_v1.1.sql) (secciones 5 y 6, ahora **aplicadas**; el SQL **aún no se ejecutó**). Se dejó explícito el **límite del sistema**: AVANZA no ofrece API, su carga es manual y queda fuera. El desarrollo será con **SDD asistido por IA** (RC-07): nacen **AD-35** y **AD-36** y las preguntas Q26 y Q27. Se decidió **no renumerar** los identificadores del ERS (el cambio 14 de la sección 5 se invirtió) y las claves de la sección 4 pasaron a los nombres del SQL.

**Actualización 4.ª ronda.** La **carga en AVANZA queda fuera del sistema** y se respeta la forma de trabajo del CETPRO y las atribuciones de cada rol (ERS y entrevista). Se retira AD-33 (credenciales y registro de cargas) y la tabla `carga_avanza`; **AD-33 pasa a ser "atribuciones por rol"** y **nace AD-34 (alertas y recordatorios)**. Las plantillas Excel quedan pendientes y el equipo las conseguirá.

**Actualización 3.ª ronda.** Se leyó el **manual de AVANZA v3.5** y la **Ley 29733**. Q1 resuelta (el CETPRO es el responsable y el equipo técnico, el encargado), Q2 no bloquea, Q22 resuelta y Q24 parcial (Cloudflare sí; dominio pendiente). AD-24, AD-28, AD-30 y AD-18 cambiaron, y nacen AD-32 y AD-33.

**Actualización 20-oct-2026 (segunda ronda).** El equipo aportó el DS 016-2024-JUS, los lineamientos de nube, el Anexo 1 vigente y la entrevista, y respondió Q5, Q11, Q12 y Q14. Principio nuevo: **todo lo que no esté formalizado es un parámetro configurable** (sección 4).

## 1. Hallazgos que más condicionan la arquitectura

1. **Es una entidad pública**: debe tener **oficial de datos personales** (art. 37 del reglamento), **inscribir su banco de datos** y **comunicar el flujo transfronterizo** a la autoridad. Falta saber **quién es el responsable** (CETPRO, UGEL o DRE).
2. **La bitácora de lecturas, modificaciones, importaciones y exportaciones es obligación legal** y debe conservarse **2 años como mínimo** (art. 46). Los privilegios se revisan **al menos cada semestre**.
3. **Notificar incidentes en 48 horas es condicionado** (volumen, número de personas, datos sensibles o perjuicio evidente), y **todo incidente se documenta**. Corrige una afirmación previa.
4. **La RVM 188-2020 cambia el modelo**: código de matrícula = número de documento, ratificación por periodo de **18 semanas**, licencia y reincorporación, convalidación con resolución directoral.
5. **El destino del registro de matrícula es AVANZA** (Sistema de Gestión Docente, manual v3.5 leído), dentro del mes siguiente al inicio del periodo; **reportar tarde es infracción grave** para el CETPRO. **La carga queda fuera del sistema** y la gestiona el CETPRO como hoy. El registro es **por periodo lectivo, programa, módulo y periodo académico**, valida el DNI con RENIEC y **no admite celdas vacías**. Faltan las plantillas Excel exactas.
6. **Edad mínima: 16 por entrevista, 14 por norma**: parámetro configurable, valor inicial 16.
7. **Las becas por necesidad pueden revelar ingresos** y la **discapacidad es dato de salud**: se guardan solo resultados y una situación específica restringida, sin documentos.
8. **Oracle puede reclamar instancias inactivas**: `keepalive` calibrado, trabajo real, detección externa y recuperación por infraestructura como código.
9. **El mayor riesgo realista es interno** y la **falsificación de constancias**.
10. **El Registro de Notas sigue siendo obligación del CETPRO** (DL 1375, art. 45-C): el sistema solo cubre el de Matrícula y se documenta quién cubre las notas.

## 2. Decisiones del equipo

| ID | Decisión | Estado |
| :--- | :--- | :---: |
| D1 | **Módulos formativos y convalidación** dentro del alcance. Notas fuera. | **Aceptada** |
| D2 | **3 VM** (web, aplicación, BD) con estrategia anti-reclamación en capas. | **Aceptada** |
| D3 | Sistema de matrícula y web institucional **aislados**. | **Aceptada** |
| D4 | Documentación en **Markdown** en la carpeta principal `D:\Trabajo\SisJoaquin`. | **Aceptada** |
| D5 | Documentación de ejemplo solo como referencia. | **Aceptada** |
| D6 | **Costo cero**: nada de pago, incluido Pay As You Go. | **Aceptada** |
| D7 | **Edad mínima 16** (entrevista), **configurable**. | **Aceptada** |
| D8 | Matrícula **por programa y periodo** (según la LAG). | **Aceptada** |
| D9 | **No hay Reglamento Institucional**: las reglas propias son parámetros configurables. | **Aceptada** |
| D10 | **Se comprará un dominio** y lo asume el equipo. Único costo del proyecto. | **Aceptada** |

## 3. Decisiones arquitectónicas

| ID | Decisión | Alternativa descartada | Estado |
| :--- | :--- | :--- | :---: |
| AD-01 | **Monolito modular** con **Clean Architecture** (Domain, Application, Infrastructure, Web), módulos como carpetas verticales y **pruebas de arquitectura**. | Microservicios; capas sin reglas | Aceptada |
| AD-02 | **ASP.NET Core 10** (LTS hasta 14-nov-2028), **Razor Pages + HTMX**, CSS ligero. | SPA o Blazor | Aceptada |
| AD-03 | **PostgreSQL 18** (soporte hasta nov-2030), **EF Core 10 + Npgsql**; reglas críticas también en la BD. | PG 19; reglas solo en la aplicación | Aceptada |
| AD-04 | **ASP.NET Core Identity**, roles Administrador, Matrícula y Directivo, **MFA TOTP**, sin autorregistro; mostrar **último ingreso e intentos fallidos** (ISO 8.5). | Tabla `usuario` propia | Aceptada |
| AD-05 | **Subred privada** para la BD y **OCI Bastion**. | BD con IP pública | Aceptada |
| AD-06 | **Cloudflare, plan gratuito** (gestión de tráfico, DNS, TLS, seguridad, Tunnel) en el borde y **Caddy** detrás. **Dominio y registrador: pendientes** (el equipo evalúa alternativas y lo asumirá). | Subdominio gratuito | **Ajustada** |
| AD-07 | **Docker Compose** por VM, imágenes **multi-arquitectura**, CI/CD gratuito, **OpenTofu + cloud-init**. | Despliegue manual | Aceptada |
| AD-08 | **Respaldo diario cifrado** a Object Storage y **copia en el CETPRO**, con **clave custodiada por el CETPRO**, **copia de la bitácora** y prueba de restauración (DS art. 51 y 52; guía PCM). | Solo instantáneas | Aceptada |
| AD-09 | **Estrategia anti-reclamación P1 a P10** con **`keepalive` calibrado** ([anexo](anexos/keepalive/README.md)). | Pagar o aceptar el riesgo | **Ajustada** |
| AD-10 | **Privacidad desde el diseño**: sin copia del DNI, sin evidencia socioeconómica, sin documentos de discapacidad, **aviso con los diez elementos del art. 6**, registro de derechos, retención configurable. | Guardar todo "por si acaso" | Aceptada |
| AD-11 | **Constancia con código único y verificación por QR** mínima y con límite de tasa. | Constancia sin verificación | Aceptada |
| AD-12 | **Bitácora de solo inserción** con **sesión, lecturas, modificaciones, eliminaciones, importaciones y exportaciones**, **≥ 2 años** (DS art. 46). | Auditar solo escrituras | Aceptada |
| AD-13 | **ASVS 5.0 L2** como criterio; Top 10:2025 como lista de amenazas. | Solo L1 | Aceptada |
| AD-14 | **Sitio institucional estático**, sin ruta a la BD de matrícula. | Sitio dinámico con BD | Aceptada |
| AD-15 | **QuestPDF** y **ClosedXML** con celdas saneadas; **licencias por revisar**. | Otras | Aceptada |
| AD-16 | **Entornos separados y datos sintéticos**, con etiqueta visible del entorno. | Datos reales en pruebas | Aceptada |
| AD-17 | Hora **America/Lima** (UTC en BD); **identificadores internos opacos** en URL (nunca el documento). | URLs con DNI | Aceptada |
| AD-18 | **Documento de identidad** con **tipo** (DNI, carné de extranjería, pasaporte, **PTP**) y número; **código de matrícula = número de documento** (LAG 11.2.2). Se guardan **apellido paterno y materno**, nombres, fecha de nacimiento y sexo por separado, como en RENIEC y AVANZA. La constancia lleva además un código propio verificable. | Correlativo propio; apellidos en un solo campo | Propuesta |
| AD-19 | **Edad mínima configurable** (valor inicial 16; piso nacional 14), con la fecha de referencia también configurable. Se guarda el valor aplicado. | Constante en el código | Propuesta |
| AD-20 | **Periodo académico de 18 semanas** (configurable) con **ratificación por periodo**. Ciclos **Auxiliar Técnico** (≥ 40 créditos) y **Técnico** (≥ 80). | Periodo anual | Propuesta |
| AD-21 | Estados: **VIGENTE, ANULADA, RETIRADA, LICENCIA**; tipos: **NUEVO, RATIFICACIÓN, REINCORPORACIÓN, TRASLADADO, RETIRADO ANTERIORMENTE**. | Estados del Informe 004 | Propuesta |
| AD-22 | **Convalidación** con tipo, **resolución directoral**, justificación, **ruta complementaria** y similitud (≥ 80 %, configurable). | Solo "módulos convalidados" | Propuesta |
| AD-23 | **Grado de instrucción** y verificación del **certificado de estudios** para el ciclo Técnico (se registra que se verificó). | Sin control | Propuesta |
| AD-24 | **Exportación para AVANZA** en el **formato de sus plantillas Excel** (estudiantes y módulos, con el periodo y el programa predefinidos), más el **Anexo 1 en PDF** y la **nómina**; filtrables por programa, módulo, periodo y turno. El **mapeo de columnas es configurable** porque el Minedu cambia las plantillas. Valida **antes de exportar** que no falten datos (AVANZA no admite celdas vacías). **Alerta del plazo de registro** (un mes tras el inicio del periodo) que se atiende o se descarta a mano; la carga en AVANZA queda fuera del sistema. | Solo nómina | Propuesta |
| AD-25 | Lenguaje: **programa de estudios, módulo formativo, unidad didáctica, ciclo**; la constancia se rotula **constancia de estudios**. | "Especialidad" | Propuesta |
| AD-26 | **Alcance legal explícito**: solo el **Registro de Matrícula** (DL 1375, art. 45-C). | Alcance implícito | Propuesta |
| AD-27 | **Parámetros institucionales versionados** (`parametro_institucional`) con vigencia y auditoría; cada acto guarda el valor aplicado. | Constantes en el código | Propuesta |
| AD-28 | **Matrícula por oferta (programa + periodo lectivo + turno)** que incluye **el o los módulos que el estudiante cursa** y su **periodo académico**, porque así lo registran AVANZA y el Anexo 1; las **unidades didácticas se derivan del módulo** y las excepciones (subsanación, convalidada) se registran aparte. *(Refinada tras leer el manual de AVANZA.)* | Matrícula sin módulo; matrícula por unidad didáctica | Propuesta |
| AD-29 | **Situación específica** del estudiante (PIR, Transitabilidad, MOT, Discapacidad, otras) como **catálogo restringido** a roles autorizados, sin documentos. | Texto libre | Propuesta |
| AD-30 | **Dirección, ubigeo (región, provincia, distrito), correo, teléfono y celular**: AVANZA los pide y su plantilla no admite vacíos, así que el sistema los **solicita y avisa antes de exportar si faltan**; son configurables y la finalidad consta en el aviso (base: función pública, Ley art. 14.1). *(Cambia: antes eran opcionales.)* | Opcionales sin control | Propuesta |
| AD-31 | **Puertas de salida a producción** (lista de verificación): ODP designado por el CETPRO y publicado, banco inscrito, flujo transfronterizo comunicado, documento de seguridad con fecha cierta, acuerdo de encargo y confidencialidad con el equipo técnico, prueba de restauración. | Desplegar sin trámites | Propuesta |
| AD-32 | **Catálogo académico alineado con AVANZA**: el plan de estudios guarda la **resolución de autorización** (tipo, número y año) y el **periodo de aprobación**; se distinguen **periodo lectivo** (por ejemplo 2026-I) y **periodo académico** (ordinal del programa). Los módulos y unidades se cargan **antes** que los estudiantes, como exige AVANZA. | Catálogo libre | Propuesta |
| AD-33 | **Atribuciones por rol conforme al ERS y a la forma de trabajo del CETPRO**: **Personal de matrícula** (registra, edita, anula, emite y genera reportes), **Directivo** (consulta y reportes) y **Administrador** (usuarios y parámetros, sin acceso a datos de estudiantes por defecto). Permisos granulares con valores iniciales por rol, editables y auditados (matriz en el documento de arquitectura, 6.9). El sistema **no impone procesos externos** (quién carga en AVANZA) ni guarda credenciales de AVANZA. | Un solo rol; imponer quién carga | Propuesta |
| AD-34 | **Alertas y recordatorios dentro del sistema** (panel y contador por rol), **parametrizables**: plazo de registro de la matrícula, datos faltantes para exportar, ratificaciones pendientes, licencias por vencer, solicitudes de derechos con plazo, revisión semestral de privilegios, seguridad, respaldo y retención. Ciclo **Activa → Atendida o Descartada**. **Sin correo ni mensajería** en el MVP. | Correo o WhatsApp (costo y privacidad) | Propuesta |
| AD-35 | **Desarrollo con SDD asistido por IA**: la spec manda y el código la demuestra; `AGENTS.md` como constitución; criterios EARS `AC-<MÓDULO>-<NN>` trazados a pruebas; dos puertas humanas (aprobar spec y plan); `SpecCheck` y pruebas de arquitectura en CI; reutilizar el marco del equipo. Ver el documento de arquitectura, 10.5. | Pedir código a la IA sin spec | Propuesta |
| AD-36 | **La IA nunca ve datos personales reales** (ni en indicaciones, archivos, pruebas, registros, capturas ni repositorio); solo datos sintéticos; el agente no accede a producción ni a secretos; herramientas aprobadas con su retención revisada; el contenido externo es dato, no instrucción. | Probar con datos «anonimizados» | Propuesta |

## 4. Parámetros configurables

Principio: **lo que el CETPRO no tiene formalizado (no hay Reglamento Institucional) o lo que puede cambiar no se codifica: es un parámetro** administrable por el rol Administrador, con **historial, vigencia y auditoría**. Cada matrícula guarda el valor que se aplicó (por ejemplo, la edad mínima vigente ese día).

| Clave | Qué controla | Valor inicial | Fuente |
| :--- | :--- | :--- | :--- |
| `edad_minima` | Edad mínima para matricularse | **16** (piso nacional 14) | Entrevista; DL 1375 |
| `edad_referencia` | Fecha con la que se mide la edad: matrícula o inicio del periodo | Fecha de matrícula | A definir |
| `periodo_semanas` | Duración del periodo académico | **18** | LAG 19.1 |
| `periodos_por_anio` | Periodos por año | **2** | Derivado de créditos |
| `plazo_registro_matricula_dias` | Plazo para registrar la matrícula en AVANZA (alerta) | **30** días desde el inicio del periodo | LAG 17.1 |
| `cupo_referencial` | Cupo orientativo por oferta | **30**, **no es límite** | Entrevista |
| `turnos` | Turnos habilitados | Mañana, tarde | Entrevista |
| `ratificacion_obligatoria` | Exigir ratificación cada periodo | Sí. En el SQL v1.1 **no es parámetro**: es regla fija (RN-10) | LAG 11.2.2 |
| `plazo_reserva_licencia_dias` | Plazo máximo para reincorporarse | **Por definir** (la LAG remite al Reglamento Institucional) | LAG 11.3 y 11.4 |
| `convalidacion_similitud_minima` | % mínimo de contenido similar entre unidades | **80** | LAG 11.5 |
| `beca_porcentaje_maximo` | Tope de beca o exoneración | **50** | Entrevista |
| `derecho_inscripcion_monto` | Monto (el comprobante se registra en el pago) | **Por definir** | Entrevista |
| `campos_estudiante` | Obligatorios y opcionales | Obligatorios: tipo y número de documento, apellidos (paterno y materno), nombres, sexo, fecha de nacimiento, grado de instrucción, programa y módulo. **Requeridos para exportar a AVANZA**: ubigeo, dirección, correo, teléfono o celular | Anexo 1; manual de AVANZA |
| `avanza_mapeo_columnas` | Qué columna de la plantilla de AVANZA se llena con qué dato | Según las plantillas descargadas | Manual de AVANZA |
| `requisitos_matricula` | Lista de requisitos a verificar (ficha firmada, certificado de estudios para ciclo técnico, fotos, otros) | Según LAG 11.2.1 | LAG |
| `modalidad_servicio` y `modelo_educativo` | Valores del Anexo 1 (en el SQL son **tablas de catálogo**, no parámetros) | Presencial; modelo por definir | Anexo 1 |
| `retencion_bitacora_anios` | Retención de la bitácora | **2** (mínimo legal) | DS art. 46 |
| `retencion_matriculas_anios` | Retención de fichas y constancias | **Por definir con la UGEL** | ISO 5.33 |
| `revision_privilegios_meses` | Frecuencia de revisión de usuarios | **6** | DS art. 46 |
| `alertas` (en el SQL: `alerta_dias_antes_plazo_registro`, `alerta_dias_antes_licencia`) | Qué alertas se usan, con cuánta anticipación y a qué roles. Valores iniciales: plazo de registro 7 y 2 días antes; licencia 15 y 5 días antes; derechos a la mitad del plazo y 2 días antes; privilegios cada 6 meses | Ver el documento de arquitectura, 6.10 | LAG 17.1; DS arts. 46 y 69 |
| `permisos_por_rol` | Matriz de permisos por rol | Ver el documento de arquitectura, 6.9 | ERS; entrevista |
| `sesion_inactividad_min` y `sesion_maxima_horas` | Sesión web | 30 y 8 | Propuesta |
| `bloqueo_intentos` y `bloqueo_minutos` | Bloqueo por fallos | 5 y 15 | Propuesta |
| `password_minimo` | Longitud mínima | 15 (8 con MFA obligatoria, por decidir) | NIST 800-63B-4 |
| `institucion` | Nombre, código modular, DRE/GRE, UGEL, tipo de gestión, ubicación, director, logo | Del CETPRO | Anexo 1 |
| `aviso_privacidad` (tabla `aviso_privacidad_version`) y `oficial_datos` | Texto versionado y contacto del ODP | Por definir | DS arts. 6 y 37 |

## 5. Cambios propuestos al Documento de Análisis (ERS v1.1)

**Estado: aplicados** en el [ERS v1.1](../Entregables/Documento-de-Analisis-ERS-v1.1.md); su Anexo A traza cada ID. El cambio 14 se invirtió: **no se renumera**.

| # | Cambio |
| :--- | :--- |
| 1 | Reescribir §1.2, §2.1, RN-08 y RNF-01 a 04 para el modelo **web en la nube**; alinear con §10.2. |
| 2 | Eliminar la entidad **Nota** (§7.5) y los huecos de §4.3, RF-13 a 15, RF-18, CU-04, CU-07; corregir "tres funciones" a "dos". |
| 3 | **RN-01 (edad)**: parámetro (16 institucional; 14 piso nacional). |
| 4 | **RN-02 (DNI)**: documento con tipo; el número es el código de matrícula. |
| 5 | **RN-03 y §3.1**: usar **ciclo Auxiliar Técnico / Técnico**, programa de estudios y créditos; la lista de la entrevista mezcla oferta histórica y de 2026. |
| 6 | **RN-04**: cupo referencial configurable. |
| 7 | **RN-05 y RF-05**: tipos de convalidación y resolución directoral (LAG 11.5). |
| 8 | Añadir **ratificación, licencia y reincorporación** (RF nuevos). |
| 9 | **RF-16/CU-05**: constancia de estudios con código verificable. |
| 10 | **RF-17**: nómina y registro de matrícula (Anexo 1) para **AVANZA**, filtrable por módulo. |
| 11 | Añadir el rol **Administrador**, los RF de gestión de usuarios, el **módulo de parámetros**, la **matriz de permisos por rol** y las **alertas y recordatorios** (RF nuevos). Los roles Personal de matrícula y Directivo **conservan sus atribuciones actuales** (RF-20). |
| 12 | Añadir los **RNF-LEG-01 a 19** del informe 01 y RNF de disponibilidad, contingencia y respaldo. |
| 13 | Declarar el **alcance** (solo Registro de Matrícula, modalidad presencial) y quién cubre el **Registro de Notas**. |
| 14 | ~~Renumerar una sola vez~~ **No renumerar** (SDD): lo modificado conserva su ID, lo retirado no se reutiliza y lo nuevo se agrega al final (RF-21 en adelante, RN-09, RNF-08, CU-09). Se publica la trazabilidad v1.0 a v1.1. |

## 6. Cambios propuestos al esquema SQL (v1.1)

**Estado: aplicados** en [db/esquema_matricula_cetpro_v1.1.sql](../db/esquema_matricula_cetpro_v1.1.sql), con [pruebas de humo](../db/pruebas_esquema_v1.1.sql). **Ninguno de los dos se ha ejecutado todavía.** Dos ajustes respecto de esta lista: `plan_estudios` ya no guarda `periodo_aprobacion` y el periodo calendario se llama `periodo_lectivo`.

| Cambio | Motivo |
| :--- | :--- |
| `estudiante`: `tipo_documento` (DNI, CE, PASAPORTE, PTP) y `numero_documento` (en lugar de `dni CHAR(8)`); `apellido_paterno`, `apellido_materno`, `nombres`, `sexo`, `fecha_nacimiento` obligatoria; `grado_instruccion`; **ubigeo** (región, provincia, distrito), dirección, correo, teléfono fijo y celular (AVANZA los pide). | AD-18, AD-23, AD-30 |
| Nueva: `matricula_modulo` (matrícula, módulo, `periodo_academico_numero`). `plan_estudios` con `tipo_resolucion`, `numero_resolucion` y `anio_resolucion`. `periodo_academico` pasa a ser el **periodo lectivo** (`periodo_lectivo`, `2026-I`). | AD-28, AD-32 |
| Nuevas: `alerta` (tipo, destinatario o rol, estado Activa/Atendida/Descartada, atendida por, fecha) y `rol_permiso` (permisos granulares por rol). La exportación queda en la **bitácora**; **no** hay tabla de cargas a AVANZA. | AD-33, AD-34 |
| `matricula`: `codigo_matricula` = número de documento; `tipo_ingreso` con RATIFICACION y REINCORPORACION; estado `LICENCIA`; `matricula_anterior_id`; `edad_minima_aplicada`; `situacion_especifica` restringida. | AD-18, AD-21, AD-29 |
| `periodo_lectivo`: periodos de 18 semanas (`2026-I`, `2026-II`) con inicio y término de clases. | AD-20 |
| `especialidad` → **`programa_estudios`**; `modalidad` → `ciclo` (`AUXILIAR_TECNICO`, `TECNICO`); créditos mínimos 40 y 80. | AD-20, AD-25 |
| Nuevas: `plan_estudios`, `modulo_formativo`, `unidad_didactica` (créditos, horas, periodo sugerido), `matricula_excepcion_unidad` (SUBSANACION, CONVALIDADA). | D1, AD-28 |
| Nueva: `convalidacion` (tipo, `resolucion_directoral`, justificación, ruta complementaria, similitud) y `licencia_estudios` (desde, hasta, fecha límite de reincorporación). | AD-21, AD-22 |
| Nueva: `parametro_institucional` con historial. | AD-27 |
| Nuevas: `aviso_privacidad_version`, `solicitud_derechos` (tipo, estado, fecha límite), `incidente_seguridad`. | AD-10, AD-31 |
| `bitacora`: eventos de sesión, lectura, modificación, eliminación, importación y exportación; retención ≥ 2 años; solo inserción. | AD-12 |
| `documento_emitido`: código verificable, *hash*, fecha de revocación; tipos CONSTANCIA_ESTUDIOS, NOMINA y REGISTRO_MATRICULA. | AD-11, AD-24 |
| `pago_inscripcion` y `convenio`: solo porcentaje, convenio y referencia; sin evidencia de ingresos. | AD-10 |
| Sustituir `usuario` por **Identity**. | AD-04 |
| Cabecera: **PostgreSQL 18**; quitar "compatible con Supabase". | Coherencia |

## 7. Preguntas abiertas

> **Estado al 21-oct-2026.** El listado vigente de pendientes y puntos por puntualizar está en [docs/README.md](../docs/README.md#pendientes-y-puntos-por-puntualizar); esta tabla es el registro histórico de las preguntas y de cómo se resolvieron.

| # | Pregunta | A quién | Bloquea |
| :--- | :--- | :--- | :--- |
| Q1 | ~~¿Quién es el responsable?~~ **Resuelta**: el CETPRO; el equipo técnico es el encargado. Falta **formalizarlo** con resolución directoral y acuerdo de encargo. | Dirección | Puertas de salida |
| Q2 | ~~¿La UGEL/DRE tiene ODP?~~ **No bloquea**: el CETPRO designa el suyo. | — | — |
| Q7 | ¿Cuánto tiempo se conservan fichas, nóminas y constancias? | UGEL | Retención |
| Q8 | ¿La web institucional debe estar en gob.pe? | UGEL | Sistema 2 |
| Q9 | ¿Quién es titular del software y bajo qué licencia? | Tutora, Dirección | Entrega |
| Q10 | ~~¿El derecho de inscripción pasa por el sistema y con qué comprobante?~~ **Resuelta**: el sistema lo **registra** (monto, comprobante y fecha; RF-07) y no cobra. El monto sigue **por definir** (P-04). | — | — |
| Q13 | ~~¿Hay estudiantes extranjeros y con NEE?~~ **Resuelta con fuentes** (21-oct-2026): AVANZA admite DNI, CE, pasaporte y PTP; la LAG 11.2.1 pide certificado de discapacidad o informe del SAANEE, que se trata como requisito condicional sin guardar el documento. | — | — |
| Q15 | ¿Qué **correo institucional neutro** y quién será segundo administrador de Oracle? | Dirección, equipo | Continuidad |
| Q16 | ¿Contenido y frecuencia de cambio de la **web institucional**? | Dirección | AD-14 |
| Q17 | ¿Aceptan **RPO 24 h** (4 h en temporada) y **RTO 4 h**? | Dirección | AD-08 |
| Q18 | ¿Ficha física, **nómina** y **constancia** vigentes? **Parcial**: la ficha es el Anexo 1 oficial; quedan los formatos propios de nómina y constancia (P-08). | Dirección | Modelo, UX |
| Q21 | ~~Manual de AVANZA~~ **leído**. **Pendiente**: plantillas Excel (estudiantes y módulos); el equipo las conseguirá. **No bloquea** (mapeo de columnas configurable) | Equipo | AD-24 |
| Q25 | ~~¿Quién ejercerá el rol Administrador?~~ **Resuelta**: por ahora el equipo desarrollador y luego la Dirección. Falta validar la **matriz de permisos** inicial (P-03). | Dirección | AD-33 |
| Q22 | ~~Ley 29733~~ **leída** (copia SPIJ) | — | — |
| Q23 | Valores de **modalidad** y **modelo educativo** del Anexo 1: **fusionada con P-01** (salen de las listas de AVANZA). | Equipo | Parámetros |
| Q24 | **Cloudflare gratuito: decidido.** Pendiente: **dominio y registrador** | Equipo | AD-06 |
| Q26 | ~~¿Qué herramientas de IA usará el equipo?~~ **Resuelta**: Claude principalmente y, opcionalmente, las de opencode Go (se aclara antes al agente); retención y entrenamiento se revisan por herramienta (AD-36). | — | — |
| Q27 | ~~¿Formato del .docx?~~ **Resuelta**: como propuesta, con el formato de `Propuesta_Librería.pdf` (`Contexto/Referencia-de-formato/`). Generada en `Entregables/`. | — | — |

**Resueltas:** Q3 (becas: solo resultado), Q4 (Oracle: la guía PCM es orientadora; falta comunicar el flujo), Q5 (16 configurable), Q6 (el destino es AVANZA), Q11 (programa y periodo), Q12 (no hay Reglamento Institucional) y Q14 (el equipo compra el dominio).

## 8. Próximos pasos

1. Redactar el **documento de arquitectura** (hecho como borrador en `Entregables/Documento-de-Arquitectura-v0.4.md`).
2. El equipo revisa el borrador y responde Q1, Q2, Q21, Q24, Q26 y Q27.
3. ~~Preparar el ERS v1.1 y el SQL v1.1~~ **Hecho como borrador.** Falta **ejecutar** el SQL y sus pruebas en PostgreSQL.
4. Probar el `keepalive` en una VM de Oracle durante una semana y medir en el Metrics Explorer.
5. Revisar los prototipos de Figma con la lista del informe 04, sección 11.
6. Definir la **distribución de carpetas** de `docs/` según la arquitectura lógica.
