# Atributos de calidad

Los atributos de calidad expresan **cómo** debe comportarse el sistema y se describen con escenarios (estímulo → respuesta → medida). Provienen de los requisitos no funcionales de [requisitos](02-requisitos.md) y se priorizan según el problema central: **registrar cada matrícula una sola vez, con datos correctos, y proteger a las personas cuyos datos se guardan**.

## 1. Atributos y escenarios

| ID | Atributo | Prioridad | Escenario de calidad | Medida | Requisitos | Justificación |
| :--- | :--- | :---: | :--- | :--- | :--- | :--- |
| **AC-01** | **Adecuación funcional** | Crítica | Se intenta matricular a una persona menor a la edad mínima, duplicar una matrícula vigente, matricular en ciclo Técnico a alguien sin primaria completa o aplicar una beca mayor al tope. | Rechazo en la aplicación **y** en la base de datos; 0 violaciones en pruebas. | RN-01, RN-06, RN-09, RN-13, RN-14, RN-15; RNF-LEG-14 | Es el problema que da origen al proyecto: datos correctos desde el primer registro. |
| **AC-02** | **Seguridad** | Crítica | Una persona intenta ver o exportar datos sin permiso; se prueban 200 ingresos fallidos; alguien intenta alterar la bitácora. | 100 % rechazado y registrado; MFA para todo el personal; bloqueo temporal; bitácora inmodificable. | RN-07, RNF-05, RNF-12, RNF-14, RNF-15 | Se tratan datos de menores y de discapacidad en un sistema expuesto a Internet. |
| **AC-03** | **Fiabilidad** | Alta | Falla la VM de la base de datos u Oracle reclama una instancia inactiva; se corta el Internet del CETPRO. | **RTO ≤ 4 h** y **RPO ≤ 24 h** (≤ 4 h en temporada); restauración probada; contingencia en papel. | RNF-02, RNF-06, RNF-08, RNF-17 | No hay SLA de Oracle Free Tier. |
| **AC-04** | **Eficiencia de desempeño** | Alta | Tres personas matriculan a la vez en temporada alta con la persona delante. | Pantallas de matrícula con p95 < 1 s; constancia PDF < 3 s. | RNF-01, RNF-03 | La latencia en el mostrador pesa más que cualquier otra métrica. |
| **AC-05** | **Capacidad de interacción** | Alta | Personal sin formación técnica registra una matrícula con teclado, sin ayuda. | Tarea completada sin ayuda; **WCAG 2.2 AA**; 0 incumplimientos críticos en axe. | RNF-07, RNF-16 | Cinco usuarios, uso diario y obligación de accesibilidad. |
| **AC-06** | **Mantenibilidad** | Alta | Cambia una regla de convalidación o se agrega una spec; el equipo es estudiantil y usa IA. | Cambio localizado en una capa, validado con pruebas; dependencias entre capas verificadas; cada criterio con prueba. | RNF-10, RNF-18 | Equipo pequeño; SDD exige trazabilidad. |
| **AC-07** | **Flexibilidad** | Alta | El CETPRO cambia la edad mínima, el plazo de reincorporación o el tope de beca. | Se cambia un parámetro **sin desplegar** y queda auditado. | RNF-11; RN-01, RN-06, RN-11, RN-12 | No existe un Reglamento Institucional. |
| **AC-08** | **Compatibilidad** | Media | Uso en navegadores de escritorio actuales. | Chrome, Edge y Firefox recientes. | RNF-04 | Solo escritorio. |
| **AC-09** | **Instalabilidad y portabilidad** | Media | Se reconstruye una VM o se migra a otro proveedor. | Despliegue con un comando por VM, en Arm64 y x86-64. | RNF-09 | Oracle mezcla arquitecturas y puede reclamar instancias. |
| **AC-10** | **Recuperabilidad** | Media | Se pierde la cuenta de Oracle. | El sistema se reconstruye en otra VM desde Git y el respaldo cifrado. | RNF-06, RNF-08 | Sin alta disponibilidad real, la recuperación es la defensa. |

## 2. Clasificación por ISO/IEC 25010:2023

Los atributos se agrupan por las características del modelo de calidad del producto de ISO/IEC 25010:2023 (el nombre exacto de cada característica debe confirmarse contra el estándar).

| Característica | Atributos |
| :--- | :--- |
| Adecuación funcional | AC-01 |
| Eficiencia de desempeño | AC-04 |
| Compatibilidad | AC-08 |
| Capacidad de interacción | AC-05 |
| Fiabilidad | AC-03, AC-10 |
| Seguridad | AC-02 |
| Mantenibilidad | AC-06 |
| Flexibilidad | AC-07, AC-09 |
| Seguridad funcional (*safety*) | No aplica |

## 3. Priorización

1. **AC-01 Adecuación funcional** y **AC-02 Seguridad** (críticas): condicionan el dominio, la base de datos con reglas de doble defensa y la estructura de despliegue.
2. **AC-03, AC-04, AC-05, AC-06 y AC-07** (altas): determinan la elección de monolito, renderizado en servidor, parámetros y estrategia de respaldo.
3. **AC-08, AC-09 y AC-10** (medias): se atienden con decisiones de bajo costo (navegadores soportados, Compose multi-arquitectura, infraestructura como código).

## 4. Tensiones

| Tensión | Resolución |
| :--- | :--- |
| Costo cero frente a disponibilidad | Se acepta sin SLA, compensado con respaldo, infraestructura como código y contingencia en papel. |
| Seguridad exigente frente a usuarios no técnicos | MFA con TOTP y códigos de respaldo, pero sin reglas de composición de contraseñas (NIST 800-63B-4). |
| Configurabilidad frente a simplicidad | Solo se parametrizan reglas no formalizadas o cambiantes. |
| Recomendación de la PCM de no gestionar usuarios en la nube frente a Identity en la aplicación | Riesgo aceptado, mitigado con MFA y revisión semestral de privilegios. |
| Velocidad de la IA frente a control de calidad y privacidad | Puertas humanas en la spec y el plan, pruebas primero, revisión independiente y datos sintéticos. |
| Aviso al usuario frente a minimización | Se piden dirección, correo y celular porque AVANZA los exige; se avisa antes de exportar si faltan y la finalidad consta en el aviso. |

La tensión principal (AC-03 frente al costo) se documenta como riesgo en [drivers arquitectónicos](../02-arquitectura-de-software/01-drivers-arquitectonicos.md).
