# Experiencia de usuario

Cómo se usa y se hace accesible el Sistema de Matrícula. Parte de las restricciones de uso (escritorio, cinco personas, mostrador con la persona delante) y de los **prototipos de Figma**, que son una **referencia** y se **afinarán** en función de la propuesta final. Se mide con criterios verificables (RNF-01, RNF-07, RNF-16).

| Documento | Para qué sirve |
| :--- | :--- |
| [01 Identidad y sistema de diseño](01-identidad-y-sistema-de-diseno.md) | Principios, restricciones y lineamientos del sistema de diseño (la identidad visual definitiva sale de Figma). |
| [02 Pantallas y recorridos](02-pantallas-y-recorridos.md) | Mapa funcional de pantallas por rol y recorridos clave. |
| [03 Estados, accesibilidad y criterios](03-estados-accesibilidad-y-criterios.md) | Estados estándar, sesión y conexión, y criterios de aceptación visual. |
| [04 Principios y heurísticas](04-principios-y-heuristicas.md) | Proceso ISO 9241-210 y heurísticas de Nielsen. |
| [05 Personas y tareas](05-personas-y-tareas.md) | Perfiles de uso, tareas y metas. |
| [06 Accesibilidad (WCAG 2.2 AA)](06-accesibilidad-wcag.md) | Criterios aplicados y verificación. |
| [07 Rendimiento percibido](07-rendimiento-percibido.md) | Metas de velocidad en escritorio y técnicas. |
| [08 Contenido y mensajes](08-contenido-y-mensajes.md) | Tono, mensajes de error, de seguridad y de estado. |
| [09 Pruebas de usabilidad](09-pruebas-de-usabilidad.md) | Método, tareas y métricas (SUS, éxito, errores). |
| [10 Revisión del prototipo](10-revision-del-prototipo.md) | Qué se conserva del prototipo de Figma, qué cambia y hallazgos de accesibilidad. |

## Estado del prototipo de Figma

| Aspecto | Estado |
| :--- | :--- |
| Enlace | <https://sheet-slot-37176734.figma.site/> («Sistema de Matrícula \| CETPRO Joaquín López Antay») |
| Copia local | `Contexto/Prototipo` (exportación de Figma Make). Se ejecuta **sin Node** con `Contexto/Prototipo/local/` (ver su `README.md`). |
| Rol | **Referencia** de una versión anterior: no tiene por qué coincidir con esta documentación. La UI/UX definitiva y la identidad visual completa se redactan después de cerrar la documentación. |
| Contraste con esta documentación | **Hecho** el 21-oct-2026: ver [revisión del prototipo](10-revision-del-prototipo.md) (30 diferencias funcionales y 9 observaciones visuales). |
| Qué se toma del prototipo | Estructura por rol, ficha en secciones, filtros y listados, insignias de estado, pantalla de éxito, paleta azul institucional (con los contrastes corregidos). |
| Qué NO se toma sin revisión | Datos de demostración, rol Administrador con acceso total, ausencia de segundo factor, información económica en documentos, tamaños de texto y grises por debajo de contraste AA. |

## Skills relacionadas

`ui-screen` (construir una pantalla desde su prototipo) y `ui-review` (revisarla). Las specs de la interfaz son `web-base` y, para cada función, la pantalla se describe en el `plan.md` de su spec.
