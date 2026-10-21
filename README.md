# Sistema de Matrícula y Registro Académico — CETPRO "Joaquín López Antay"

Sistema web de **Registro de Matrícula** para el CETPRO público "Joaquín López Antay" (UGEL Huamanga, Ayacucho), desarrollado como servicio social de la UNSCH. Lo usan 3 personas de matrícula, 2 directivos y un administrador. El **Registro de Notas queda fuera** del alcance, y la **carga en AVANZA es manual y ocurre fuera del sistema** (AVANZA no ofrece API).

Stack: ASP.NET 10 (C#), PostgreSQL 18, Razor Pages y HTMX, Docker, Oracle Cloud Free Tier (3 VM aisladas) y Cloudflare gratuito. Costo recurrente cero, salvo el dominio.

## Estado

| Etapa | Estado |
| :--- | :--- |
| Análisis (ERS v1.1), arquitectura (v0.4) y esquema SQL v1.1 | **Línea base aprobada** por el equipo; el SQL se probó en PostgreSQL sin pruebas fallidas. |
| Documentación viva (`docs/`) | Redactada y **auditada** el 21-oct-2026 ([informe](progress/log/2026-10-21-auditoria-de-la-documentacion.md)); pendiente de la revisión del equipo. |
| Prototipo de interfaz (Figma) | Referencia de una versión anterior; la UI/UX definitiva y la identidad visual se trabajan después. |
| Fase 0 de SDD (`AGENTS.md`, plantillas, SpecCheck, esqueleto) | Pendiente; empieza cuando la documentación esté cerrada. |
| Specs (17 previstas) y código | Pendientes. |

## Mapa de carpetas

| Carpeta | Contenido | Se edita |
| :--- | :--- | :--- |
| [`docs/`](docs/README.md) | **Documentación viva**: fuente de verdad (7 carpetas temáticas y glosario). Un cambio de comportamiento se hace aquí. | Sí |
| [`specs/`](specs/README.md) | Especificaciones (una carpeta por spec) y trazabilidad. Vacía hasta cerrar la documentación. | Sí |
| [`progress/`](progress/README.md) | Cambios, bloqueos y bitácora de sesiones (informes de auditoría incluidos). | Sí |
| [`db/`](db/README.md) | Esquema SQL de referencia v1.1 y sus pruebas de humo. | Con control de cambios |
| [`Entregables/`](Entregables/README.md) | Línea base del ERS v1.1 y de la arquitectura v0.4, y la propuesta en `.docx`. | No (se congelan) |
| [`Investigacion/`](Investigacion/README.md) | Borrador de trabajo con las fuentes, su nivel de verificación y los anexos (`keepalive`). | No |
| [`Contexto/`](Contexto/README.md) | Material aportado por el equipo: normativa, antecedentes, prototipo y documentación de ejemplo. | No |

No existen todavía `src/`, `tests/`, `infra/`, `tools/`, `.claude/`, `AGENTS.md` ni `CLAUDE.md`: se crean en la Fase 0 (estructura prevista en [`docs/07-proceso-de-desarrollo/01-flujo-sdd.md`](docs/07-proceso-de-desarrollo/01-flujo-sdd.md)).

## Por dónde empezar a leer

1. [`docs/README.md`](docs/README.md): mapa de la documentación y reglas de los identificadores.
2. [`docs/01-analisis-de-sistema/01-necesidad-del-negocio.md`](docs/01-analisis-de-sistema/01-necesidad-del-negocio.md): problema, alcance y límites.
3. [`docs/01-analisis-de-sistema/02-requisitos.md`](docs/01-analisis-de-sistema/02-requisitos.md): requisitos (RF, RN, RNF, RC) y, para redactar specs, la [matriz de trazabilidad](docs/01-analisis-de-sistema/08-matriz-de-trazabilidad.md).
4. [`docs/02-arquitectura-de-software/02-decisiones-arquitectonicas.md`](docs/02-arquitectura-de-software/02-decisiones-arquitectonicas.md): decisiones (AD).
5. [`docs/07-proceso-de-desarrollo/01-flujo-sdd.md`](docs/07-proceso-de-desarrollo/01-flujo-sdd.md): cómo se construye.

## Repositorio

Remoto: <https://github.com/P35C4D0R4B1050/ServicioSocial_WebCETPRO> (rama `main`). El repositorio es **público**, así que **nada sensible entra**: el `.gitignore` excluye secretos y archivos `.env`, claves y certificados, respaldos y volcados de base de datos, exportaciones con datos reales, estado de OpenTofu, archivos de bloqueo de Word, estado local de las herramientas de IA y el material de terceros listado en `Contexto/README.md`. Reglas de commits y ramas: [convenciones técnicas](docs/07-proceso-de-desarrollo/02-convenciones-tecnicas.md).

## Reglas que no cambian

- **Los identificadores no se renumeran** (RF, RN, RNF, RC, CU, AD, DA, AC…): lo modificado conserva su código, lo retirado no se reutiliza y lo nuevo se agrega al final.
- **Datos reales nunca llegan a una herramienta de IA**, a las pruebas ni al repositorio (AD-36, RNF-18).
- **No se asume una integración con AVANZA.** Si una spec lo supone, está mal.
- Lo que el CETPRO no formalizó es un **parámetro configurable**; lo no verificado se marca «por verificar».
- Nada de lo legal es asesoría.
