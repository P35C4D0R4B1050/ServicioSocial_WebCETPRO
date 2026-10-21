# Principios y patrones de diseño

Los patrones se usan **solo donde resuelven un problema real de este sistema**, siguiendo la regla de `AGENTS.md`: *sin sobreingeniería; un puerto solo si hay algo externo o una variación real; sin patrones que nadie pidió*. Este documento fija el vocabulario común y dice cuándo no aplicar cada patrón.

## 1. Principios

| Principio | Cómo se aplica |
| :--- | :--- |
| **Separación de responsabilidades** | Cuatro capas con regla de dependencia hacia el Dominio ([Clean Architecture](01-clean-architecture.md)). |
| **Inversión de dependencias** | La Aplicación define puertos; la Infraestructura los implementa. |
| **Responsabilidad única** | Un caso de uso por operación del negocio (*RegistrarMatrícula*, *AnularMatrícula*). |
| **Abierto a extensión, cerrado a modificación** | La política de convalidación y el mapeo de columnas de AVANZA se sustituyen sin tocar el contrato. |
| **Mínimo privilegio** | Cuentas de base y permisos con lo justo; la aplicación no puede alterar la bitácora. |
| **Fallar de forma segura** | Ante la duda, negar. Un parámetro por definir produce un error claro, no un valor inventado. |
| **Diseñar para probar** | El Dominio y la Aplicación se prueban sin base ni red. |
| **Explícito sobre implícito** | Dependencias por constructor, configuración por entorno, errores tipados. |
| **Doble defensa** | Las reglas críticas se validan en el dominio y en la base. |

## 2. Catálogo de patrones usados

| Patrón | Problema que resuelve | Dónde | Decisión |
| :--- | :--- | :--- | :--- |
| **Entidad y objeto de valor** | Reglas con identidad (Matrícula, Estudiante) o sin ella (Documento, Código de matrícula, Periodo). | Dominio | [modelo de dominio](../01-analisis-de-sistema/07-modelo-de-dominio.md) |
| **Política de dominio** | Reglas intercambiables o parametrizadas (edad, beca, similitud de convalidación). | Dominio | AD-19, AD-27 |
| **Repositorio** | Aislar el acceso a datos detrás de un puerto que habla el lenguaje del dominio. | Puerto en Aplicación; adaptador en Infraestructura | AD-01 |
| **Unidad de trabajo** | Cambio y bitácora en la misma transacción; fijar usuario y origen para la auditoría. | Aplicación e Infraestructura | AD-12 |
| **Caso de uso (comando)** | Un punto de entrada claro por operación. | Aplicación | AD-01 |
| **Máquina de estados** | Ciclos de vida con transiciones válidas (matrícula, licencia, alerta, solicitud). | Dominio y BD | [estados y concurrencia](06-estados-y-concurrencia.md) |
| **Adaptador (puerto y adaptador)** | Cambiar de librería de PDF, de Excel o de formato sin tocar el negocio. | Infraestructura | Puertos de [organización interna](02-organizacion-interna.md) |
| **Capa anticorrupción** | Que el formato de la plantilla de AVANZA no contamine el dominio. | Infraestructura, dentro del exportador | AD-24 |
| **Resultado explícito** | Errores de negocio como valores con `code` estable, no como excepciones de control. | Aplicación | — |
| **Control de concurrencia optimista** | Dos personas editan la misma matrícula (`version`). | BD e Infraestructura | AC-01 |
| **Parámetros tipados** | Leer `edad_minima`, `beca_porcentaje_maximo` con tipo y validación al arrancar. | Aplicación | AD-27 |
| **Política de autorización** | Reglas por permiso reutilizables. | Aplicación | AD-33 |
| **Opciones tipadas** | Configuración desde el entorno con validación al arrancar. | Web | `AGENTS.md` |
| **Bandeja de alertas con clave** | No duplicar una alerta activa; cerrarla a mano. | M6 y BD | AD-34 |
| **Sanear la salida** | Impedir inyección de fórmulas en Excel y HTML en campos libres. | Infraestructura | AD-15 |

## 3. Cuándo no usar cada patrón

| Patrón | No se usa cuando |
| :--- | :--- |
| Repositorio | El caso de uso es una consulta de solo lectura sencilla: se admite un lector específico (vista de reporte). |
| Máquina de estados | El estado es solo informativo y no condiciona transiciones. |
| Política de dominio | Solo hay una regla fija y nadie pidió variarla. |
| Puerto | Lo que se envuelve no es externo ni variable (el reloj se abstrae para probar, pero no una colección en memoria). |
| Eventos de dominio | No existe bus ni consumidores: se llama al caso de uso o se guarda un registro. |
| Mediador / librería de CQRS | Los casos de uso se invocan por inyección directa; no se agrega una librería sin necesidad. |

## 4. Reglas de codificación asociadas

1. Los nombres del dominio salen del [glosario](../glossary.md).
2. Una regla de negocio nueva se escribe primero como prueba unitaria.
3. Los casos de uso no conocen HTTP, SQL ni librerías de documentos.
4. Las excepciones se reservan para lo inesperado; los errores de negocio son resultados con un `code` estable.
5. Los constructores validan los invariantes: un objeto inválido no puede existir.
6. El tiempo y los identificadores se obtienen por abstracciones inyectadas, para probar vencimientos y plazos.
7. Nunca se usa un dato personal real en una prueba, un ejemplo ni una indicación a la IA.
