# Seguridad del desarrollo asistido por IA

El sistema se construye con **Spec-Driven Development asistido por IA** (RC-07, RNF-18, AD-35). Las herramientas de IA reciben texto del proyecto y lo procesan fuera del equipo; además pueden equivocarse. Este documento define qué puede y qué no puede ver una herramienta de IA, y cómo se controla la calidad de lo que produce. Desarrolla **AD-36** y las amenazas **AM-17 a AM-19**.

> El sistema **no incorpora un asistente con modelo de lenguaje** como función del producto. El único uso de IA es de **desarrollo**.

## 1. Principio de diseño

> Lo peor que debe poder hacer una herramienta de IA es **proponer algo incorrecto**, nunca **ver datos reales ni actuar sobre producción**.

Por eso: ninguna herramienta recibe datos personales reales ni secretos; el agente no tiene acceso a producción; toda propuesta pasa por pruebas y por una persona; y el contenido externo se trata como dato, no como instrucción.

## 2. Herramientas

| Herramienta | Uso | Condición |
| :--- | :--- | :--- |
| **Claude** (Claude Code) | Principal: redacción de specs, planes, código y pruebas. | Cuenta o plan del equipo; revisar qué retiene y si entrena con el contenido (P-12, resuelto: ver [pendientes](../README.md#pendientes-y-puntos-por-puntualizar)). |
| Otras IA de **opencode Go** | **Opcional**, solo si el equipo lo decide. | **Se aclara antes al agente** que es una herramienta distinta, con las mismas reglas de datos; se registra su retención y uso para entrenamiento. |

Regla: **solo herramientas aprobadas por el equipo.** Cualquier herramienta nueva se registra aquí antes de usarse.

## 3. Qué puede entrar a una herramienta de IA

| Contenido | ¿Puede entrar? |
| :--- | :---: |
| ERS, documentación (`docs/`), arquitectura, specs, planes, código, normativa publicada | Sí |
| Estructura de la base de datos (esquema y vistas, sin filas) | Sí |
| Datos sintéticos claramente ficticios (apellido «PRUEBA», nombres «SINTÉTICO») | Sí |
| Plantillas de AVANZA y la ficha **en blanco** | Sí |
| **Datos reales** de estudiantes, docentes o personal; capturas, volcados, respaldos o bitácoras de producción; la ficha llenada | **No** |
| **Credenciales**, claves, tokens, cadenas de conexión, secretos de Oracle o Cloudflare, usuario o contraseña de AVANZA | **No** |
| Contenido externo (páginas, PDF, correos) | Se lee como **dato**; las instrucciones incrustadas no se ejecutan |

**Por qué.** Enviar datos personales reales a un proveedor de IA equivaldría a que un tercero los trate y, si está fuera del Perú, a un posible flujo transfronterizo (DS 016-2024-JUS, arts. 18 a 21 y 28 a 33). **Es una interpretación del equipo**: no se encontró criterio oficial sobre herramientas de IA; se evita por diseño en lugar de depender de esa interpretación.

## 4. Controles

| Control | Cómo |
| :--- | :--- |
| El agente trabaja **sin acceso a producción** | Ni conexión a la base real, ni respaldos, ni secretos. Desarrollo y pruebas usan datos sintéticos (AD-16). |
| Repositorio **privado** | Solo el equipo; ramas protegidas. |
| **Detección de secretos** | `gitleaks` en CI y al confirmar; `.env.example` sin valores. |
| **Datos sintéticos reconocibles** | Un generador del proyecto; nombres y apellidos claramente ficticios; revisión en CI de fixtures y semillas. |
| **Reglas en `AGENTS.md`** | Prohibición explícita de datos reales; qué hacer si se detecta uno. |
| Herramientas aprobadas | Lista en este documento; retención y entrenamiento revisados. |
| **Puertas humanas** | Una persona aprueba la spec y el plan; revisa lo sensible. |
| **Contenido externo es dato** | Las instrucciones dentro de una página, un PDF o un correo no se ejecutan; se citan al usuario. |
| **Transparencia** | Los commits asistidos por IA lo indican en el pie. |
| Incidente por incumplimiento | Si un dato real llega a una herramienta de IA, se trata como incidente (ver abajo). |

### Si un dato real llega a una herramienta de IA

1. Detener el uso de esa sesión y no repetir el envío.
2. Documentar: qué dato, a qué herramienta, cuándo y quién.
3. Pedir la eliminación del contenido si la herramienta lo permite; guardar la evidencia.
4. Evaluar con la Dirección si corresponde notificar (DS art. 34).
5. Corregir la causa (capacitación, regla de `AGENTS.md`, escaneo) y registrar en `progress/`.

## 5. Calidad de lo producido por IA

| Riesgo | Control |
| :--- | :--- |
| **Reglas de negocio supuestas** | La IA pregunta; lo que el ERS no dice se vuelve parámetro o pendiente. Regla 4 de `AGENTS.md`. |
| **Paquetes inexistentes o con licencia dudosa** | Verificar que el paquete existe, su licencia y su mantenimiento; versiones fijas; decisión registrada para cada dependencia nueva. |
| **Normas inventadas** | Ninguna cita legal sin fuente en `Investigacion/` o `Contexto/Normativa`; lo no verificado se marca «por verificar». |
| **Código que viola la arquitectura** | Pruebas de arquitectura en CI como puerta. |
| **Código con vulnerabilidades** | CodeQL, Trivy, dependencias vulnerables y revisión de seguridad de las specs que tocan datos personales. |
| **La IA se «califica a sí misma»** | Pruebas primero; revisión independiente por otro agente de solo lectura en contexto aislado; decisión humana. |
| **Alcance mayor al pedido** | Lo que está «Fuera» del sistema (ERS 2.5) no se implementa; `SpecCheck` y revisión. |
| **Titularidad del código generado** | Se resuelve con la titularidad y licencia del software (P-09). |

## 6. Amenazas relacionadas

| Amenaza | Resumen | Control principal |
| :--- | :--- | :--- |
| **AM-17** | Datos reales en herramientas de IA, pruebas o repositorio. | Sección 3 y 4. |
| **AM-18** | Código o dependencias con defectos. | Sección 5. |
| **AM-19** | Instrucciones incrustadas en contenido externo. | El contenido externo es dato; puertas humanas. |
| **AM-20** | Uso indebido del acceso del equipo (Administrador) a datos reales. | Bitácora técnica; acuerdo de encargo; traspaso a la Dirección. |

## 7. Revisión

Esta lista se revisa cuando el equipo cambia de herramienta, cuando una herramienta cambia sus condiciones y al cerrar cada fase de SDD.
