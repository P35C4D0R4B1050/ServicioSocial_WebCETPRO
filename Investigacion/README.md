# Investigación previa a la arquitectura

Carpeta de trabajo con la investigación legal, de seguridad, de despliegue y de experiencia de usuario del Sistema de Matrícula del CETPRO "Joaquín López Antay". Es un **borrador interno**: cuando se consolide el documento de arquitectura, su contenido se distribuye en `docs/` y esta carpeta se puede retirar.

| Documento | Para qué sirve |
| :--- | :--- |
| [01 Marco legal y normativo](01-marco-legal-y-normativo.md) | Normas peruanas aplicables a un CETPRO público, preguntas legales críticas y requisitos derivados. |
| [02 Seguridad y estándares](02-seguridad-y-estandares.md) | ISO, NIST y OWASP aplicados; OWASP Top 10:2025 mapeado al sistema; amenazas del dominio; operación segura. |
| [03 Despliegue y continuidad en Oracle](03-despliegue-y-continuidad-oracle.md) | Límites reales del Free Tier, riesgo de reclamación, estrategia en capas y topología de 3 VM. |
| [04 Experiencia de usuario](04-ux-y-experiencia.md) | Principios y patrones previos a la interfaz; accesibilidad WCAG 2.2; plan de pruebas. |
| [05 Decisiones, parámetros y preguntas](05-decisiones-propuestas-y-preguntas.md) | Decisiones (AD-01 a AD-34), **parámetros configurables**, cambios al ERS y al SQL, y preguntas abiertas. |
| [Anexo: keepalive](anexos/keepalive/README.md) | Scripts y temporizadores para evitar que Oracle reclame la VM por inactividad, sin costo. |

## Cómo leerlos

- Cada afirmación lleva una marca de verificación: **✔✔** (dos o más fuentes, o fuente oficial), **✔** (una fuente) o **?** (no verificado en esta ronda).
- Las citas legales no son asesoría. El texto oficial del reglamento de datos personales **no se pudo abrir**; se contrastó entre varias fuentes secundarias.
- **Actualización 20-oct-2026 (1.ª ronda):** se incorporaron el DL 1375, la RVM 188-2020 y la ISO/IEC 27002:2022 (`Contexto/Normativa`) y la restricción de **costo cero**.
- **Actualización 20-oct-2026 (2.ª ronda):** se leyó el **DS 016-2024-JUS** en texto oficial (se corrigieron afirmaciones), los **lineamientos de nube** de la PCM, el **Anexo 1 vigente** y la **entrevista**; se respondieron Q5, Q11, Q12 y Q14 y se añadió el catálogo de **parámetros configurables**.
- **Actualización 20-oct-2026 (5.ª ronda):** se redactaron el [ERS v1.1](../Entregables/Documento-de-Analisis-ERS-v1.1.md) y el [esquema SQL v1.1](../db/README.md) (este último **sin ejecutar todavía**), se dejaron explícitos los **límites del sistema** (AVANZA sin API; la carga es manual y externa) y se incorporó el **desarrollo con SDD asistido por IA** (AD-35 y AD-36; Documento de Arquitectura, 10.5).
- No se diseña interfaz: se esperan los prototipos de Figma.
- La documentación `Contexto/DocumentacionEjemplo` se leyó **solo como referencia** y no se modificó.
