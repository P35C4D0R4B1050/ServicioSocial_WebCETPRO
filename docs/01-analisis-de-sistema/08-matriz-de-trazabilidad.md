# Matriz de trazabilidad hacia las specs

Es la **fuente que se usa para redactar cada spec**: dice, para cada una de las 17 especificaciones previstas, qué requisitos, reglas, casos de uso, decisiones, amenazas, controles, parámetros y pendientes debe cubrir, y de qué otras specs depende. La tabla de [requisitos, sección 6](02-requisitos.md#6-verificación-y-especificación-prevista) y el Anexo B del ERS solo listan los requisitos funcionales; esta matriz cubre **todos** los identificadores. Si una spec cambia de alcance, se corrige aquí en el mismo cambio. `TRACEABILITY.md` (en `specs/`) la extenderá hasta los criterios de aceptación y las pruebas.

**Convención de dependencias:** toda spec **de negocio** (CAT, OFE, EST, MAT, RAT, CON, BEC, CST, REP, AVZ, PRI y ALE) depende de `transversal-auditoria` (AUD) y de `identidad-seguridad` (IDE, por los permisos); en la tabla 1 solo se listan las dependencias **adicionales**. **Excepciones** (para evitar ciclos): AUD, PAR, WEB y OPS no dependen de IDE; IDE depende de PAR (lee los parámetros de seguridad) y de WEB. El permiso `PARAMETROS_EDITAR` lo aplica IDE sobre la pantalla de PAR, así que el criterio que lo exige se escribe en la spec IDE.

## 1. Specs, fases y dependencias

| Spec (prefijo) | Módulo | Fase | Iteración | Depende de (además de AUD e IDE) |
| :--- | :--- | :---: | :---: | :--- |
| `transversal-auditoria` (AUD) | M6 | 1 | 1 | — |
| `parametros-institucionales` (PAR) | M2 | 1 | 1 | AUD |
| `identidad-seguridad` (IDE) | M1 | 1 | 1 | PAR (lee los parámetros de seguridad), WEB |
| `web-base` (WEB) | Web | 1 | 1 | — (usa tokens de diseño provisionales; la identidad visual definitiva se incorpora después) |
| `operacion-despliegue` (OPS) | Plataforma | 1 (en paralelo) y 8 | 1 a 3 | — |
| `catalogo-academico` (CAT) | M3 | 2 | 1 | PAR |
| `periodos-ofertas` (OFE) | M3 | 2 | 1 | CAT, PAR |
| `estudiantes` (EST) | M4 | 3 | 1 y 2 | PAR |
| `matricula-registro` (MAT) | M4 | 3 | 1 y 2 | CAT, OFE, EST, PAR |
| `docs-constancia` (CST) | M5 | 4 y 6 | 1 y 2 | MAT, PAR |
| `docs-reportes` (REP) | M5 | 4 y 6 | 1 y 2 | MAT, CAT, OFE, PAR |
| `cumplimiento-privacidad` (PRI) | M6 | 4, 6 y 7 | 1 a 3 | EST, PAR |
| `matricula-ratificacion-licencia` (RAT) | M4 | 5 | 2 | MAT, PAR |
| `matricula-convalidacion` (CON) | M4 | 5 | 2 | MAT, CAT, PAR |
| `matricula-becas` (BEC) | M4 | 5 | 2 | MAT, PAR |
| `docs-archivos-avanza` (AVZ) | M5 | 6 | 2 | MAT, CAT, PAR; plantillas de AVANZA (P-01) |
| `transversal-alertas` (ALE) | M6 | 6 | 2 | PAR; consume eventos de MAT, RAT, PRI, IDE y OPS |

Las specs que cruzan iteraciones (EST, MAT, CST, REP, PRI) marcan en cada criterio su iteración; la spec llega a *Done* al cerrarse la última (ver [flujo SDD](../07-proceso-de-desarrollo/01-flujo-sdd.md), sección 6).

## 2. Requisitos, reglas y casos de uso por spec

| Spec | RF | RN | RNF y RNF-LEG | CU |
| :--- | :--- | :--- | :--- | :--- |
| AUD | RF-34 | — | RNF-12, RNF-LEG-08 | CU-20 (bitácora) |
| PAR | RF-32 | RN-01, RN-02, RN-04, RN-06, RN-11, RN-12, RN-16 (solo sus valores configurables; la regla la implementa la spec de cada una) | RNF-11, RNF-LEG-15 | CU-16 |
| IDE | RF-19, RF-20, RF-29, RF-30, RF-39 | RN-07 | RNF-05, RNF-LEG-09 | CU-08, CU-15, CU-20 (privilegios) |
| WEB | — | — | RNF-01, RNF-04, RNF-07, RNF-16, RNF-LEG-12 | — |
| OPS | — | — | RNF-02, RNF-03, RNF-06, RNF-08, RNF-09, RNF-13, RNF-17, RNF-LEG-10; RC-01, RC-02, RC-04 | — |
| CAT | RF-09, RF-10, RF-11, RF-25 | RN-03 | — | CU-02, CU-03 |
| OFE | RF-24 | RN-04 | — | — |
| EST | RF-40, RF-41 | RN-02 (tipos de documento), RN-17 | RNF-14, RNF-LEG-02, RNF-LEG-19 | CU-01 (parte estudiante) |
| MAT | RF-01, RF-02, RF-03, RF-04, RF-07, RF-08, RF-42, RF-43 | RN-01, RN-02, RN-09, RN-13, RN-14, RN-15 | RNF-LEG-14, RNF-LEG-15 | CU-01 |
| RAT | RF-21, RF-22, RF-23 | RN-10, RN-11 | RNF-LEG-16 | CU-09, CU-10, CU-11 |
| CON | RF-05 | RN-05, RN-12 | RNF-LEG-18 | CU-12 |
| BEC | RF-06 | RN-06 | — | — |
| CST | RF-16, RF-28 | — | — | CU-05, CU-14 |
| REP | RF-12, RF-17, RF-26 | — | — | CU-06, CU-13 (nómina y Anexo 1) |
| AVZ | RF-27 | RN-16 (archivos a tiempo) | RNF-LEG-17 | CU-13 (archivos para AVANZA) |
| PRI | RF-35, RF-36, RF-37, RF-38 | — | RNF-LEG-01, RNF-LEG-03, RNF-LEG-04, RNF-LEG-05 | CU-18, CU-19 |
| ALE | RF-33 | RN-16 (alerta del plazo) | RNF-LEG-03 y RNF-LEG-09 (las alertas) | CU-17 |

**Cambio respecto del Anexo B del ERS:** RF-12 (matriculados por programa, módulo, periodo y turno) pasa de OFE a REP. Lee matrículas (M4), que se implementan en la fase 3, y OFE se implementa antes (fase 2) y no debe depender de M4.

### 2.1 Alcance transversal (no es una spec de funcionalidad)

Estos requisitos los cumplen todas las specs y se verifican desde la Fase 0 (`AGENTS.md`, plantillas, `SpecCheck`, CI y esqueleto), no en una spec propia.

| Identificador | Qué es | Dónde se cumple |
| :--- | :--- | :--- |
| RNF-10 | Capas verificadas y cobertura de Dominio y Aplicación ≥ 85 % | Pruebas de arquitectura y CI |
| RNF-15 | OWASP ASVS 5.0 nivel 2 y Top 10:2025 | CI de seguridad (operación segura) y controles `CTL` de cada spec |
| RNF-18, RNF-LEG-13, RC-07 | SDD asistido por IA, datos sintéticos | `AGENTS.md`, `SpecCheck`, generador de datos sintéticos |
| RC-03, RC-05, RC-08 | Tecnología, equipo pequeño, precedencia de la normativa | `AGENTS.md` y flujo SDD |
| RNF-14 | Privacidad desde el diseño | EST, MAT y PRI (cada spec que toca datos personales pasa por revisión de privacidad) |

### 2.2 Puertas de salida a producción (no son specs de software)

Son condiciones que cierran la Dirección y el equipo antes de operar con datos reales; se siguen en el [marco legal, sección 6](03-marco-legal.md#6-obligaciones-previas-a-operar-con-datos-reales-puertas-de-salida) y en `operacion-despliegue` solo como lista de verificación.

| Identificador | Condición |
| :--- | :--- |
| RC-06 | Entidad pública: oficial de datos, banco inscrito, registros y notificación de incidentes |
| RNF-LEG-06 | Inscribir el banco, designar y publicar al ODP y comunicar el flujo transfronterizo |
| RNF-LEG-07 | Acuerdo de encargo y confidencialidad; revisión del contrato de Oracle |
| RNF-LEG-11 | Documento de seguridad con fecha cierta e inventario de datos |

### 2.3 Identificadores retirados o reservados

RF-13, RF-14, RF-15 y RF-18 (notas), CU-04 y CU-07 (notas) y RN-08 (red local) están **retirados**: ninguna spec los cubre y no se reutilizan. RF-31 está **reservado** (recuperación de acceso, cubierta por RF-29).

## 3. Decisiones, amenazas, controles, parámetros y pendientes por spec

| Spec | Decisiones (AD) | Amenazas (AM) | Controles (CTL) | Parámetros | Pendientes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| AUD | AD-12 | AM-01, AM-13, AM-20 | CTL-38 | `retencion_bitacora_anios` | — |
| PAR | AD-27 | — | — | todos (catálogo en [modelo de datos, sección 12](../03-diseno-de-software/05-modelo-de-datos.md#12-catálogo-de-parámetros-institucionales)) | — |
| IDE | AD-04, AD-33 | AM-01, AM-03, AM-12, AM-20, AM-22 | CTL-15 a CTL-19, CTL-22, CTL-23, CTL-24, CTL-26, CTL-30 | `password_minimo`, `sesion_inactividad_min`, `sesion_maxima_horas`, `bloqueo_intentos`, `bloqueo_minutos`, `revision_privilegios_meses` | P-03 |
| WEB | AD-02, AD-13, AD-17 | AM-07, AM-14 | CTL-01, CTL-02, CTL-05 a CTL-09, CTL-21, CTL-22 (aviso de sesión), CTL-27, CTL-39 | `zona_horaria` | — |
| OPS | AD-05 a AD-09, AD-14, AD-16, AD-31 | AM-04, AM-05, AM-08, AM-09, AM-10, AM-16 | CTL-20, CTL-28, CTL-29, CTL-31, CTL-32, CTL-35, CTL-36, CTL-37 | — | P-02, P-10, P-11 |
| CAT | AD-25, AD-28, AD-32 | — | — | — | — |
| OFE | AD-20, AD-32 | — | — | `cupo_referencial`, `periodo_semanas`, `periodos_por_anio` | — |
| EST | AD-10, AD-18, AD-29, AD-30 | AM-06, AM-21 | CTL-08, CTL-33 | `campos_estudiante` | P-01 (campos que AVANZA exige) |
| MAT | AD-03, AD-18, AD-19, AD-21, AD-23, AD-28 | — | CTL-01, CTL-04, CTL-33 | `edad_minima`, `edad_referencia`, `requisitos_matricula`, `derecho_inscripcion_monto` | P-04 |
| RAT | AD-20, AD-21 | — | CTL-04 | `plazo_reserva_licencia_dias`, `alerta_dias_antes_licencia` | P-04 |
| CON | AD-22 | — | CTL-04 | `convalidacion_similitud_minima` | — |
| BEC | AD-10 | — | CTL-04 | `beca_porcentaje_maximo` | — |
| CST | AD-11, AD-15 | AM-02, AM-06 | CTL-10, CTL-14 | `institucion` | P-08 |
| REP | AD-15, AD-24 | AM-01, AM-07 | CTL-12, CTL-13 | `institucion` | P-08 |
| AVZ | AD-15, AD-24, AD-30 | AM-07 | CTL-12 | `avanza_mapeo_columnas`, `institucion` | P-01 |
| PRI | AD-10, AD-31 | — | CTL-34 | `retencion_matriculas_anios`, `oficial_datos` | P-05, P-11 |
| ALE | AD-34 | AM-01 | CTL-40 | `plazo_registro_matricula_dias`, `alerta_dias_antes_plazo_registro`, `alerta_dias_antes_licencia` | — |
| Transversal (Fase 0) | AD-01, AD-25, AD-26, AD-35, AD-36 | AM-15, AM-17, AM-18, AM-19 | CTL-03, CTL-11, CTL-25 | — | P-09 |

Los controles CTL-03, CTL-11 y CTL-25 se concretan en el plan de cada spec que los toca (consultas con parámetros, modelos de entrada y respuestas uniformes). AM-11 (ingeniería social) se resuelve con un procedimiento del CETPRO y la capacitación, no con una spec.

## 4. Cobertura

La cobertura se comprobó el 21-oct-2026 con un recorrido automático de los identificadores: cada **RF**, **RN**, **RNF**, **RNF-LEG**, **RC** y **CU** vigente aparece en al menos una fila de las secciones 2 y 2.1 a 2.3; cada **AD** y cada **AM** aparece en la tabla 3; cada **CTL** aparece en la tabla 3. Al agregar un identificador nuevo se agrega aquí en el mismo cambio.
