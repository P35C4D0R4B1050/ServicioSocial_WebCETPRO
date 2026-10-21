# Tácticas arquitectónicas

Una **táctica** es una decisión de diseño que mejora un atributo de calidad concreto (Bass, Clements y Kazman, *Software Architecture in Practice*). Este documento recorre los atributos de calidad ([atributos de calidad](../01-analisis-de-sistema/04-atributos-de-calidad.md)), registra qué táctica se eligió, dónde vive y qué la respalda. Sirve para comprobar que cada atributo tiene respuesta y que no hay decisiones huérfanas.

## 1. Tácticas por atributo

| Atributo | Táctica | Dónde se aplica | Decisión o requisito |
| :--- | :--- | :--- | :--- |
| **AC-01 Adecuación funcional** | Reglas en el **dominio** y también como restricciones y disparadores en PostgreSQL (doble defensa). | M4 y BD | AD-03; RN-01, RN-06, RN-13, RN-14 |
| | Índices únicos parciales (una matrícula vigente por estudiante, programa y periodo; una licencia vigente por matrícula). | BD | RN-13 |
| | El **código de matrícula** lo fija la base (no la interfaz) a partir del documento. | BD | RN-09 |
| | La máquina de estados de la matrícula limita las transiciones (VIGENTE → ANULADA, RETIRADA, LICENCIA; LICENCIA → RETIRADA). | Dominio y BD | RN-15 |
| | La matrícula guarda el valor del parámetro aplicado (`edad_minima_aplicada`). | BD | AD-19 |
| **AC-02 Seguridad** | **Autenticación** con MFA TOTP, bloqueo temporal y sesión con vencimiento. | M1 | AD-04; RN-07 |
| | **Autorización** por permisos granulares, **denegar por defecto**, en cada caso de uso (no solo en la interfaz). | M1 y Application | AD-33 |
| | **Bitácora** de solo inserción, con disparadores que impiden actualizarla o borrarla. | BD y M6 | AD-12; RNF-12 |
| | Cabeceras de seguridad, límites de tasa en la verificación pública y en el ingreso. | Web | AD-13; AM-06 |
| | Cuenta de BD de mínimo privilegio (`cetpro_app`), sin `DELETE` general. | BD | AD-03 |
| | Identificadores opacos en la URL; **nunca el documento**. | Web | AD-17 |
| | Celdas de Excel saneadas contra inyección de fórmulas. | M5 | AD-15 |
| **AC-03 Fiabilidad** | Respaldo diario cifrado, restauración probada, infraestructura como código. | Despliegue | AD-08 |
| | Reinicio automático de contenedores y *healthchecks*. | Compose | RNF-17 |
| | `keepalive`, latido externo y trabajo real programado contra la reclamación. | Despliegue | AD-09 |
| | Contingencia en papel y modo degradado local. | Proceso | RNF-08 |
| **AC-04 Eficiencia** | Renderizado en servidor, índices, paginación con tope, consultas acotadas, pocas dependencias. | Web y BD | AD-02 |
| | Pantallas de matrícula con una consulta por dato maestro y sin cargas innecesarias. | Web | RNF-01 |
| **AC-05 Capacidad de interacción** | Interfaz simple por teclado, borradores guardados en el servidor, mensajes claros que dicen qué pasó y qué hacer. | Web | RNF-07; RF-42 |
| | Detección de documento duplicado antes de guardar y reutilización de datos. | M4 | RF-41 |
| **AC-06 Mantenibilidad** | Capas con regla de dependencia verificada por pruebas de arquitectura; módulos con contratos. | Solución | AD-01 |
| | Specs con criterios EARS trazados a pruebas; `SpecCheck` en CI; puertas humanas. | Proceso | AD-35 |
| **AC-07 Flexibilidad** | **Parámetros institucionales** versionados, con historial, leídos por el dominio y por la BD. | M2 y BD | AD-27; RNF-11 |
| | Catálogos (turno, grado de instrucción, modalidad, modelo, situación específica) como datos. | BD | AD-28 |
| **AC-08 Compatibilidad** | Mejora progresiva, sin dependencias de navegador no estándar. | Web | RNF-04 |
| **AC-09 Instalabilidad** | Compose por VM, imágenes multi-arquitectura, `cloud-init`. | Despliegue | AD-07 |
| **AC-10 Recuperabilidad** | Reconstrucción desde Git y respaldo cifrado en otra VM; dos administradores de la cuenta. | Despliegue | AD-08 |

## 2. Tácticas descartadas

| Táctica | Por qué no |
| :--- | :--- |
| Microservicios y bus de eventos | El volumen (5 usuarios) no lo justifica; el monolito basta (AD-01). |
| Réplicas y alta disponibilidad de bases | El Free Tier no ofrece recursos; se compensa con respaldo y restauración probada. |
| Pagar Oracle (Pay As You Go) | Contra la restricción de costo cero y sin exención confirmada. |
| Integración automática con AVANZA | No ofrece API; fuera del alcance. |
| Alertas por correo o WhatsApp | Costo y privacidad; las alertas son internas (AD-34). |
| SPA con API propia | Otro stack y más superficie de ataque (AD-02). |
| Borrado físico de matrículas | La anulación es un estado con motivo (RN-15). |

## 3. Compromisos entre tácticas

| Tensión | Resolución |
| :--- | :--- |
| Doble defensa (consistencia) frente a duplicación de reglas | Las reglas viven en el dominio y se repiten en la BD solo para las **críticas**; las pruebas de integración verifican que ambas coincidan. |
| Registro detallado (detección) frente a minimización (privacidad) | La bitácora guarda eventos, nombres de columnas e identificadores; **nunca** valores sensibles, contraseñas ni documentos completos. |
| Bloqueo estricto frente a usuarios legítimos | Bloqueo temporal (no definitivo), mensajes que explican el motivo sin dar pistas a un atacante, restablecimiento por el Administrador. |
| `keepalive` (carga artificial) frente a eficiencia | Costo ínfimo (~2,8 minutos de un núcleo por hora); prioridad mínima; se omite si la VM ya está ocupada. |
| Parámetros (flexibilidad) frente a simplicidad | Solo se parametrizan reglas no formalizadas o que pueden cambiar. |
| Respaldo diario (RPO) frente al límite de 20 GB de Object Storage | Retención escalonada y compresión; la copia en el CETPRO complementa. |
