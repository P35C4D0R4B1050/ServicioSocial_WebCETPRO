# Mapeo a IEEE 1016

La propuesta pide documentar con el modelo C4 e IEEE 1016. IEEE 1016 organiza un documento de diseño de software en **puntos de vista** (*viewpoints*). Este mapeo muestra dónde se cubre cada uno, para no duplicar contenido ni dejar vacíos. El modelo C4 está en [04-modelo-c4](../04-modelo-c4/README.md) (niveles 1 a 3).

> Los nombres de los puntos de vista se tomaron de la estructura habitual de la norma IEEE 1016-2009; antes de una entrega formal, se verifican contra el texto del estándar.

## 1. Puntos de vista

| Punto de vista (IEEE 1016) | Qué describe | Dónde se cubre |
| :--- | :--- | :--- |
| **Contexto** | Servicios, actores y límites del sistema | [Necesidad del negocio](../01-analisis-de-sistema/01-necesidad-del-negocio.md) (límites y diagrama de contexto), [actores y permisos](../01-analisis-de-sistema/05-actores-y-permisos.md); [C4 nivel 1](../04-modelo-c4/01-contexto-y-contenedores.md) |
| **Composición** | Partes en que se descompone el sistema | [Estilo arquitectónico](../02-arquitectura-de-software/03-estilo-arquitectonico.md), [módulos y contratos](04-modulos-y-contratos.md); C4 nivel 2 y nivel 3 ([componentes](../04-modelo-c4/02-componentes.md)) |
| **Lógico** | Clases, tipos y relaciones del dominio | [Modelo de dominio](../01-analisis-de-sistema/07-modelo-de-dominio.md), [organización interna](02-organizacion-interna.md) |
| **Dependencia** | Relaciones y dependencias entre partes | [Clean Architecture](01-clean-architecture.md) (regla de dependencia y matriz), pruebas de arquitectura |
| **Información** | Datos persistentes y su manejo | [Modelo de datos](05-modelo-de-datos.md), [privacidad](../05-seguridad/04-privacidad-y-datos-personales.md) |
| **Uso de patrones** | Patrones de diseño aplicados | [Principios y patrones](03-principios-y-patrones.md), [tácticas arquitectónicas](../02-arquitectura-de-software/06-tacticas-arquitectonicas.md) |
| **Interfaz** | Interfaces externas e internas | [Módulos y contratos](04-modulos-y-contratos.md), [integraciones y superficie expuesta](../05-seguridad/05-api-e-integraciones.md), [pantallas](../06-experiencia-de-usuario/02-pantallas-y-recorridos.md) |
| **Estructura** | Organización interna de partes | [Clean Architecture](01-clean-architecture.md) (mapa del repositorio), [organización interna](02-organizacion-interna.md) |
| **Interacción** | Colaboración entre partes en el tiempo | [Escenarios y flujos](../02-arquitectura-de-software/04-escenarios-y-flujos.md), [procesos de negocio](../01-analisis-de-sistema/06-procesos-de-negocio.md), [autenticación](../05-seguridad/03-autenticacion-y-autorizacion.md) |
| **Dinámica de estados** | Estados y transiciones | [Estados y concurrencia](06-estados-y-concurrencia.md) |
| **Algoritmo** | Lógica detallada de operaciones clave | Se define en el `plan.md` de cada spec (cálculo de la edad, plazo de solicitudes, exportación con el formato de AVANZA); la regla del dominio primero como prueba unitaria |
| **Recursos** | Uso de recursos y sus límites | [Presupuesto de recursos](../02-arquitectura-de-software/07-presupuesto-de-recursos.md), [despliegue](../02-arquitectura-de-software/05-despliegue.md) |

## 2. Preocupaciones transversales (*design concerns*)

| Preocupación | Dónde |
| :--- | :--- |
| Calidad y atributos | [Atributos de calidad](../01-analisis-de-sistema/04-atributos-de-calidad.md), [tácticas](../02-arquitectura-de-software/06-tacticas-arquitectonicas.md) |
| Seguridad y privacidad | [05-seguridad](../05-seguridad/README.md) |
| Experiencia de usuario y accesibilidad | [06-experiencia-de-usuario](../06-experiencia-de-usuario/README.md) |
| Decisiones y justificación | [Decisiones arquitectónicas](../02-arquitectura-de-software/02-decisiones-arquitectonicas.md) |
| Proceso de desarrollo | [07-proceso-de-desarrollo](../07-proceso-de-desarrollo/README.md) |
| Trazabilidad con requisitos | `specs/TRACEABILITY.md` (se genera con las specs) |

## 3. Vacíos conocidos

| Vacío | Plan |
| :--- | :--- |
| Modelo C4 nivel 4 (código) | No se elabora: lo cubren las specs, los planes y el código. |
| Algoritmos detallados | Se escriben en cada plan al aprobar la spec. |
| Diagramas de secuencia por caso de uso | Se agregan en los planes de las features críticas (registro de matrícula, ratificación y exportación). |
| Plantillas de AVANZA | Mapeo definitivo de columnas pendiente (P-01). |
| Diseño de pantallas finales | Pendiente de la afinación del prototipo de Figma. |
