# Estrategia de pruebas

Define qué se prueba, con qué herramienta, en qué capa y con qué umbrales. Parte de la regla del proyecto: **cada criterio de aceptación (`AC-XXX-NN`) tiene al menos una prueba que lo nombra** (RNF-10), y la lógica de negocio se prueba primero. Respalda AC-06 y AD-35.

## 1. Pirámide de pruebas

| Nivel | Qué prueba | Herramienta | Velocidad | Dónde |
| :--- | :--- | :--- | :---: | :--- |
| **Unitarias de Dominio** | Reglas del negocio sin base ni red: edad, ciclo Técnico, beca, estados, convalidación. | xUnit | Muy rápida | `Cetpro.Domain.Tests` |
| **Unitarias de Aplicación** | Casos de uso con puertos simulados: orquestación, permisos, parámetros por definir. | xUnit | Rápida | `Cetpro.Application.Tests` |
| **De arquitectura** | Reglas de referencias entre proyectos y módulos. | NetArchTest | Rápida | `Cetpro.Architecture.Tests` |
| **De la base (humo)** | Reglas en PostgreSQL: edad, matrícula única, beca, bitácora inmutable, permisos. | [`pruebas_esquema_v1.1.sql`](../../db/pruebas_esquema_v1.1.sql) | Rápida | `db/` |
| **De integración** | Infraestructura con la base real: migraciones, restricciones, disparadores, concurrencia. | xUnit + Testcontainers | Media | `Cetpro.Integration.Tests` |
| **De contrato** | Formato de errores y de los puntos no interactivos. | xUnit | Media | `Cetpro.Integration.Tests` |
| **E2E** | Recorridos completos en navegador, accesibilidad y cabeceras. | Playwright + axe | Lenta | `Cetpro.E2E` |
| **De carga ligera** | Rendimiento con 5 usuarios concurrentes. | k6 | Lenta | `tests/` |
| **De seguridad** | SAST, dependencias, imágenes, secretos y DAST básico. | CodeQL, Dependabot, Trivy, `gitleaks`, ZAP *baseline* | Variable | CI |
| **De usabilidad** | Tareas con las personas usuarias. | Sesiones moderadas | Manual | [pruebas de usabilidad](../06-experiencia-de-usuario/09-pruebas-de-usabilidad.md) |

La base de la pirámide (Dominio y Aplicación) es la más numerosa; las lentas se reservan para lo que solo ellas pueden demostrar.

## 2. Reglas

1. **Prueba primero para reglas de negocio:** se escribe la prueba que falla y luego el código, de adentro hacia afuera.
2. **Trazabilidad:** cada prueba de un criterio lleva `[Trait("Criterio", "AC-XXX-NN")]`; `SpecCheck` falla si un criterio no está nombrado en ninguna prueba cuando la spec está en `InProgress`.
3. **Nombres descriptivos** en español: `Registrar_MenorDeEdadMinima_Rechaza`.
4. **Sin red ni base** en Dominio y Aplicación; las pruebas de integración usan Testcontainers y necesitan Docker.
5. **Pruebas deterministas:** el tiempo, los identificadores y el azar se inyectan; ninguna prueba depende del reloj real ni del orden.
6. **No se debilitan pruebas ni validaciones para que algo pase.** Si falla la prueba de arquitectura, se corrige el código.
7. **Concurrencia real:** matrícula única, versión de la matrícula y bitácora se prueban con solicitudes simultáneas sobre la base real.
8. **Datos de prueba sintéticos, siempre.** Nunca datos reales; secretos de prueba generados y descartables.
9. **La IA no se califica a sí misma:** la revisión independiente la hace otro agente de solo lectura y la decisión es humana.

## 3. Umbrales de cobertura (RNF-10)

| Alcance | Meta | Qué mide |
| :--- | :---: | :--- |
| Dominio y Aplicación | **≥ 85 %** de líneas | Que las reglas estén probadas en profundidad. |
| Sistema completo | **≥ 70 %** de líneas | Evita zonas ciegas sin forzar pruebas de bajo valor. |
| Infraestructura y Web | Sin porcentaje; criterios cubiertos por pruebas de integración y E2E | La calidad se mide por criterios, no por líneas. |

La cobertura es una **señal, no el objetivo**: no se escriben pruebas vacías para subir el número. Opcionalmente, una pasada de pruebas de mutación sobre el Dominio (por ejemplo, con Stryker.NET) valida que las pruebas detecten errores reales.

## 4. Qué se prueba por tipo de requisito

| Tipo | Cómo se prueba | Ejemplos |
| :--- | :--- | :--- |
| **Reglas del negocio** | Unitarias de Dominio | Edad mínima con el parámetro vigente; ciclo Técnico; tope de beca; estados de la matrícula. |
| **Casos de uso** | Unitarias de Aplicación con puertos simulados | Un permiso faltante rechaza y registra; un parámetro por definir da un error claro. |
| **Persistencia y concurrencia** | Integración | Dos registros simultáneos de la misma matrícula; versión; índice único parcial. |
| **Reglas en la base** | Humo SQL e integración | Disparadores de edad, beca, convalidación, licencia; bitácora inmutable. |
| **Seguridad** | Integración, E2E y CI | Bloqueo tras 5 fallos; cabeceras; permisos por rol; escaneos. |
| **Documentos** | Integración | Constancia con código, *hash* y QR; Excel con celdas saneadas; archivo para AVANZA con datos faltantes. |
| **Interfaz** | E2E con axe | Registro de matrícula; accesibilidad; estados. |
| **Rendimiento** | k6 y Lighthouse | p95 de las pantallas de matrícula; constancia < 3 s. |
| **Abuso** | Casos de abuso | Enumeración de constancias; exportaciones masivas; intentos de editar la bitácora. |
| **Privacidad** | Revisión y pruebas | Ningún dato real en fixtures; el documento no aparece en la URL; la bitácora no guarda valores sensibles. |

## 5. Dobles de prueba para lo externo

| Externo | Doble | Fidelidad |
| :--- | :--- | :--- |
| PostgreSQL | Contenedor real (Testcontainers) | Alta; es la defensa final. |
| Healthchecks y Object Storage | Doble que registra las llamadas | Verifica el contenido enviado, no la red. |
| Reloj | `IReloj` fijo | Permite probar plazos y vencimientos. |
| Generadores de PDF y Excel | Reales en integración; simulados en Aplicación | Verifican contenido y celdas saneadas. |
| Identity y TOTP | Real en integración; simulado en Aplicación | Códigos de prueba descartables. |
| AVANZA | **Ninguno** (no hay integración) | Se prueba el **archivo generado**, no una carga. |

## 6. Orden de ejecución y puertas

| Puerta | Qué debe pasar |
| :--- | :--- |
| Antes de cada commit | `SpecCheck`; compilación sin advertencias; pruebas afectadas. |
| Integración continua | `SpecCheck`, compilación, todas las pruebas y arquitectura, humo SQL; análisis estático y escaneos. |
| Antes de pasar una spec a `Done` | `spec-verify` con resultado *Converge*; cobertura de criterios; revisión de arquitectura y de seguridad. |
| Antes de un despliegue mayor | Carga ligera con k6, ZAP *baseline*, restauración de respaldo y lista manual de accesibilidad. |
| Antes de operar con datos reales | Puertas de salida a producción cerradas ([marco legal](../01-analisis-de-sistema/03-marco-legal.md), sección 6). |

## 7. Riesgos de la estrategia

| Riesgo | Mitigación |
| :--- | :--- |
| Pruebas de integración lentas por Docker | Contenedores compartidos por clase de pruebas y categorías para ejecutar solo las afectadas. |
| Falsa seguridad por cobertura alta | Revisión de criterios, pruebas de mutación opcionales y casos de abuso explícitos. |
| Mantenimiento de E2E frágiles | Pocos recorridos largos, selectores estables por rol y etiqueta, datos sintéticos controlados. |
| Que el código generado por IA «pase» sin demostrar el criterio | Pruebas primero, revisión independiente, `spec-verify` y puerta humana. |
| Que una prueba use un dato real | Generador de datos sintéticos y revisión en CI de fixtures. |
