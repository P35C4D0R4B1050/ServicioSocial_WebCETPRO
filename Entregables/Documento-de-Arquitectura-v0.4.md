# Documento de Arquitectura de Software

**Sistema de Gestión de Matrícula y Registro Académico**
CETPRO "Joaquín López Antay", Ayacucho

| Campo | Valor |
| :--- | :--- |
| Versión | **0.4, borrador para revisión del equipo** (0.1: primera redacción; 0.2: manual de AVANZA y Ley 29733 leídos, matrícula con módulo, Cloudflare confirmado; 0.3: la carga en AVANZA queda fuera del sistema, roles y permisos según el ERS, alertas y recordatorios; 0.4: límites del sistema explícitos, desarrollo con SDD asistido por IA, alineación con el ERS v1.1 y el esquema SQL v1.1) |
| Fecha | 20 de octubre de 2026 |
| Fase | Formulación y diseño (servicio social UNSCH) |
| Estado | **Línea base aprobada por el equipo** (revisión de la v0.4). La documentación viva está en [`docs/`](../docs/README.md); un cambio de comportamiento se hace allí. Las decisiones marcadas *Propuesta* en este documento quedaron **aceptadas** en [`docs/02-arquitectura-de-software`](../docs/02-arquitectura-de-software/02-decisiones-arquitectonicas.md) |
| Fuentes | [ERS v1.1](Documento-de-Analisis-ERS-v1.1.md) (y v1.0), Informe 004, [esquema SQL v1.1](../db/esquema_matricula_cetpro_v1.1.sql) (y v1.0), entrevista al CETPRO, DL 1375, RVM 188-2020-MINEDU, DS 016-2024-JUS, lineamientos de nube de la PCM, ISO/IEC 27002:2022 y los cinco informes de la carpeta [`Investigacion`](../Investigacion/README.md) |
| Fuera de este documento | Diseño de interfaz (se esperan los prototipos de Figma) y distribución final de carpetas de `docs/` |

> **Advertencias.** Los aspectos legales no son asesoría legal. Las reglas que el CETPRO no tiene formalizadas (no existe un Reglamento Institucional) se tratan como **parámetros configurables**. Los datos de Oracle Free Tier deben confirmarse en la consola al crear la cuenta.

## Contenido

1. [Introducción](#1-introducción)
2. [Contexto y restricciones](#2-contexto-y-restricciones)
3. [Requisitos que condicionan la arquitectura](#3-requisitos-que-condicionan-la-arquitectura)
4. [Solución conceptual: módulos](#4-solución-conceptual-módulos)
5. [Estilo arquitectónico y decisiones](#5-estilo-arquitectónico-y-decisiones)
6. [Arquitectura lógica](#6-arquitectura-lógica)
7. [Datos](#7-datos)
8. [Arquitectura de despliegue](#8-arquitectura-de-despliegue)
9. [Seguridad y privacidad](#9-seguridad-y-privacidad)
10. [Calidad, pruebas y operación](#10-calidad-pruebas-y-operación)
11. [Riesgos y decisiones abiertas](#11-riesgos-y-decisiones-abiertas)
12. [Trazabilidad](#12-trazabilidad)
13. [Anexos](#13-anexos)

---

## 1. Introducción

### 1.1 Propósito

Este documento describe la arquitectura del Sistema de Gestión de Matrícula del CETPRO "Joaquín López Antay": qué problema resuelve, qué restricciones lo condicionan, cómo se organiza por dentro, dónde y cómo se despliega, y cómo se protege. Es la base para redactar el diseño detallado, las especificaciones y el código.

### 1.2 Alcance

| Dentro del alcance | Fuera del alcance |
| :--- | :--- |
| **Registro de Matrícula** del CETPRO público (DL 1375, art. 45-C): estudiantes, matrícula, ratificación por periodo, licencia, reincorporación, convalidación, becas y derecho de inscripción | **Registro de Notas** y certificados modulares (obligación del CETPRO que cubre otro medio) |
| Catálogo académico: programas de estudios, ciclos, módulos formativos, unidades didácticas, periodos, ofertas y docentes | Titulación, constancia de egreso, certificado de estudios |
| Documentos: **constancia de estudios**, **nómina de matriculados**, **registro de matrícula (Anexo 1)** y **archivos Excel con el formato de las plantillas de AVANZA** | Integración automática con AVANZA y **la carga en AVANZA**: el sistema solo **genera los archivos**; la carga **queda fuera del sistema** y la gestiona el CETPRO con su forma de trabajo |
| Seguridad, auditoría, privacidad y respaldos | Modalidades semipresencial y a distancia (solo **presencial**) |
| Un **segundo sistema aislado**: la **web institucional** estática | Aplicación móvil y diseño responsivo (uso exclusivo en escritorio) |

### 1.3 Convenciones

| Prefijo | Significado | Dónde se define |
| :--- | :--- | :--- |
| RF, RN, RNF, CU | Requisitos, reglas y casos de uso del **ERS v1.1**. **No se renumeran**: lo modificado conserva su código, lo retirado no se reutiliza y lo nuevo se agrega al final | ERS |
| RNF-LEG | Requisitos derivados del marco legal | ERS, sección 5.1; informe 01 |
| RC | Restricción del proyecto | ERS, sección 2.6; sección 2.3 |
| AC-\<MÓDULO\>-\<NN\> | **Criterio de aceptación** en EARS dentro de una spec (por ejemplo, AC-MAT-01). No confundir con los atributos de calidad AC-01 a AC-10 | Specs (sección 10.5) |
| DA | Driver arquitectónico | Sección 3 |
| AC | Atributo de calidad (ISO/IEC 25010:2023) | Sección 3 |
| AD | Decisión arquitectónica | Sección 5 |
| M | Módulo | Sección 4 |
| R | Riesgo | Sección 11 |

### 1.4 Glosario mínimo

| Término | Significado |
| :--- | :--- |
| CETPRO | Centro de Educación Técnico-Productiva |
| LAG | Lineamientos Académicos Generales (RVM 188-2020-MINEDU) |
| AVANZA | Sistema de Gestión Docente del Minedu donde los CETPRO registran nómina de matrícula y actas |
| Programa de estudios | Lo que el ERS llama "especialidad" |
| Ciclo | **Auxiliar Técnico** (≥ 40 créditos) o **Técnico** (≥ 80 créditos) |
| Oferta | Programa de estudios dictado en un periodo y turno |
| ODP | Oficial de Datos Personales |
| ANPD | Autoridad Nacional de Protección de Datos Personales |
| CNSD | Centro Nacional de Seguridad Digital |
| RPO / RTO | Pérdida máxima de datos aceptable / tiempo máximo para recuperar el servicio |
| SDD | *Spec-Driven Development*: la especificación aprobada manda y el código la demuestra |
| EARS | *Easy Approach to Requirements Syntax*: plantillas para redactar requisitos verificables |
| Spec | Especificación de una funcionalidad (`spec.md`), con criterios de aceptación en EARS |

### 1.5 Límites del sistema

El sistema **no es AVANZA, no lo reemplaza y no se integra con él**. AVANZA **no ofrece API** que permita una integración sencilla, así que su carga es **manual y ocurre fuera del sistema**. Es un **límite del proyecto**, no un problema por resolver con código. El detalle está en el [ERS v1.1, sección 2.5](Documento-de-Analisis-ERS-v1.1.md#25-límites-del-sistema); este es el resumen que deben tener presente las personas y los agentes de IA al escribir una spec:

| Frontera | Dentro del sistema | Fuera del sistema |
| :--- | :--- | :--- |
| **AVANZA** | Generar los archivos de apoyo (Excel con el formato de sus plantillas y Anexo 1 en PDF) | La carga, sus credenciales y quién la realiza; cualquier integración automática |
| **Notas, certificados y títulos** | — | Todo el registro de notas (DL 1375, art. 45-C) |
| **RENIEC** | Capturar nombres y apellidos tal como figuran en el documento | La validación (la hace AVANZA al cargar) |
| **Cobros** | Registrar el derecho de inscripción (monto, beca, comprobante) | Cobrar, pasarelas, comprobantes electrónicos |
| **Comunicaciones** | Alertas y recordatorios dentro del sistema | Correo, WhatsApp, SMS |
| **Firma digital** | Código único y verificación por QR de la constancia | Firma digital de documentos |
| **Dispositivos y modalidades** | Escritorio y modalidad presencial | Móviles, semipresencial y a distancia |
| **Docentes y horarios** | Docente como dato informativo de la oferta | Horarios, asistencia y planillas |
| **Web institucional** | Es un sistema aislado, sin acceso a esta base | Cualquier integración con la matrícula |
| **Procesos en papel** | Documentos imprimibles (ficha, constancia) | Firmas, archivo físico y otros trámites; el sistema no los impone |

**Regla para el desarrollo:** lo que está en la columna «Fuera» no se especifica ni se implementa mientras no cambie antes el ERS. Esta tabla forma parte del contexto obligatorio de `AGENTS.md` (sección 10.5).

---

## 2. Contexto y restricciones

### 2.1 Problema

Hoy el estudiante llena una ficha impresa y el personal la **vuelve a digitar en AVANZA** (entrevista). Esto genera doble trabajo, demoras y riesgo de error. No hay un registro propio de estudiantes ni emisión automática de constancias. Los procesos son manuales o locales y no existe un Reglamento Institucional que formalice las reglas.

### 2.2 Usuarios

| Rol | Cantidad | Qué hace |
| :--- | :---: | :--- |
| **Personal de matrícula** | 3 | Registra, edita, anula y consulta matrículas; emite constancias y reportes |
| **Directivo** | 2 | Consulta reportes y nóminas, sin editar (RF-20) |
| **Administrador** (por designar) | 1 o 2 | Gestiona usuarios, parámetros y catálogos |
| **Persona externa** | variable | Verifica una constancia por código QR (solo lectura mínima) |

### 2.3 Restricciones

| ID | Restricción | Origen |
| :--- | :--- | :--- |
| RC-01 | **Costo cero**, salvo el **dominio**, que compra y asume el equipo | Decisión D6 y D10 |
| RC-02 | Despliegue en **Oracle Cloud Free Tier**: 2 OCPU y 12 GB en Arm (A1), 2 VM x86 de 1 GB y 200 GB de disco en total; sin SLA; sin región en Perú | Oracle; informe 03 |
| RC-03 | Stack: **ASP.NET 10, C#, HTML/CSS/JS, PostgreSQL, Docker** | Equipo |
| RC-04 | **Dos sistemas aislados**: matrícula y web institucional; la BD separada de las aplicaciones | D3 |
| RC-05 | Equipo estudiantil pequeño, con tiempo limitado | Servicio social |
| RC-06 | Entidad pública: datos personales con **ODP**, banco inscrito, registros y notificación de incidentes | DS 016-2024-JUS |
| RC-07 | **Desarrollo con Spec-Driven Development asistido por IA**: las especificaciones mandan y el código las demuestra; **sin datos reales** en herramientas de IA, pruebas ni repositorio | Equipo; RNF-18 |
| RC-08 | Los textos oficiales mandan sobre la entrevista y el ERS cuando difieren | LAG, DL 1375 |

### 2.4 Supuestos

| ID | Supuesto | Qué pasa si no se cumple |
| :--- | :--- | :--- |
| S-01 | La **edad mínima** es 16 años (entrevista), configurable | Se cambia el parámetro sin desplegar |
| S-02 | La matrícula es **por programa y periodo**; módulos y unidades derivan del plan | Se extiende el modelo con `matricula_excepcion_unidad` |
| S-03 | **No hay Reglamento Institucional**; las reglas propias son parámetros | Se formalizan después y se ajustan los parámetros |
| S-04 | El destino del registro es **AVANZA** (manual v3.5) con plantillas Excel. **La carga queda fuera del sistema** y la hace el CETPRO como hoy | Se ajusta el **mapeo de columnas** configurable |
| S-05 | El CETPRO tiene **Internet suficiente** en el mostrador | Se activa el procedimiento de contingencia (sección 8.7) |
| S-06 | **Hay un ODP** (propio o de la UGEL) | Es condición para salir a producción (AD-31) |
| S-07 | El equipo trabaja con **IA asistente** bajo SDD y **jamás le entrega datos reales** | Se detiene el uso de la herramienta y se trata como incidente (AD-36) |

---

## 3. Requisitos que condicionan la arquitectura

### 3.1 Drivers arquitectónicos

| ID | Driver | Tipo | Origen | Consecuencia en el diseño | Decisiones |
| :--- | :--- | :--- | :--- | :--- | :--- |
| DA-01 | Cumplir el reglamento de datos personales como **entidad pública** (ODP, registro, transferencia, incidentes, bitácora, respaldos) | Legal | DS 016-2024-JUS arts. 21, 34 a 52 | Módulo de cumplimiento, bitácora de lecturas, retención, puertas de salida a producción | AD-10, AD-12, AD-31 |
| DA-02 | El **registro de matrícula** sigue la LAG y se carga en **AVANZA** (por periodo lectivo, programa, módulo y periodo académico; DNI validado con RENIEC; sin celdas vacías; reportar tarde es infracción grave) | Negocio y legal | LAG 11 y 17; Anexo 1; manual de AVANZA v3.5 | Modelo con periodo de 18 semanas, ratificación, licencia, código = documento y **módulo en la matrícula**; exportación a las plantillas de AVANZA con validación previa y alerta de plazo | AD-18 a AD-25, AD-28, AD-32, AD-33 |
| DA-03 | **Reglas sin formalizar** (edad, plazos, cupos, requisitos) | Negocio | Entrevista; no hay Reglamento | **Parámetros versionados** y reglas en el dominio, no en el código | AD-19, AD-27 |
| DA-04 | **Costo cero** y recursos limitados | Restricción | RC-01, RC-02 | Monolito, pocas piezas, imágenes multi-arquitectura, presupuesto de memoria | AD-01, AD-07 |
| DA-05 | **Riesgo de reclamación** de instancias y falta de SLA | Calidad | Informe 03 | `keepalive`, detección externa, infraestructura como código, respaldos fuera de Oracle | AD-08, AD-09 |
| DA-06 | **Exposición a Internet** de datos de adolescentes (y de discapacidad) | Calidad | DS arts. 22, 34, 46 | Zonas aisladas, MFA, bitácora, cifrado, cabeceras | AD-04, AD-05, AD-13 |
| DA-07 | **Aislar** el sitio institucional de la matrícula y de la BD | Seguridad | D3 | Tres VM y redes distintas | AD-05, AD-14 |
| DA-08 | **Pocos usuarios no técnicos**, solo escritorio | Calidad | RNF-03, RNF-04, RNF-07 | Interfaz simple renderizada en servidor; sin SPA | AD-02 |
| DA-09 | **Dependencia de Internet** del CETPRO | Riesgo | ERS §10.2 | Contingencia en papel, borradores guardados, copia local cifrada | AD-08 |
| DA-10 | **Trazabilidad** de todo cambio y consulta | Legal | RF-08; DS art. 46 | Bitácora de solo inserción en la aplicación y la BD | AD-12 |
| DA-11 | Plataformas **Arm64 y x86** | Restricción | Oracle | Imágenes multi-arquitectura | AD-07 |
| DA-12 | **Entrega y mantenimiento** por equipo estudiantil | Negocio | RC-05 | Documentación como código, pruebas de arquitectura, despliegue reproducible | AD-01, AD-07 |
| DA-13 | **Plazos legales y de reporte** (registro de matrícula, reincorporación, derechos de los titulares, revisión de privilegios) | Legal y negocio | LAG 11.4 y 17.1; DS arts. 46 y 69 | Módulo de **alertas** parametrizable, con ciclo de vida | AD-34 |
| DA-14 | **Respetar la forma de trabajo del CETPRO**: roles y atribuciones del ERS; lo que ocurre fuera del sistema (como la carga en AVANZA) no se impone | Negocio | ERS; entrevista | Permisos por rol según el ERS; sin procesos externos acoplados | AD-33 |
| DA-15 | **Desarrollo con SDD asistido por IA**: las especificaciones aprobadas son la fuente de verdad; los documentos (ERS, arquitectura, esquema) son **contexto de entrada** de las specs y de los agentes | Proceso | RC-07; RNF-10, RNF-18 | IDs estables, specs con criterios EARS trazados a pruebas, `AGENTS.md`, `SpecCheck`, puertas humanas, límites del sistema explícitos (1.5) | AD-35 |
| DA-16 | **Privacidad en el uso de IA**: ningún dato personal real llega a una herramienta de IA, a las pruebas ni al repositorio | Legal y seguridad | DS 016-2024-JUS; RNF-LEG-13 | Datos sintéticos, agente sin acceso a producción ni a secretos, escaneo de secretos, herramientas aprobadas | AD-16, AD-36 |

### 3.2 Atributos de calidad (ISO/IEC 25010:2023)

| ID | Característica | Escenario | Medida propuesta |
| :--- | :--- | :--- | :--- |
| AC-01 | **Adecuación funcional** | Se intenta matricular a una persona menor a la edad mínima, duplicar una matrícula vigente o aplicar una beca mayor al tope | Rechazo en la aplicación **y** en la BD; 0 violaciones en pruebas |
| AC-02 | **Seguridad** | Una persona intenta ver o exportar datos sin permiso; se prueban 200 ingresos fallidos | 100 % rechazado y registrado; MFA para todo el personal; bloqueo temporal |
| AC-03 | **Fiabilidad** | Falla la VM-DB o Oracle reclama una instancia | **RTO ≤ 4 h** y **RPO ≤ 24 h** (≤ 4 h en temporada); restauración probada |
| AC-04 | **Eficiencia de desempeño** | 3 personas matriculan a la vez en temporada alta | Pantallas de matrícula con p95 < 1 s; constancia PDF < 3 s |
| AC-05 | **Capacidad de interacción** | Personal sin formación técnica registra una matrícula con teclado | Tarea completada sin ayuda; **WCAG 2.2 AA**, 0 incumplimientos críticos en axe |
| AC-06 | **Mantenibilidad** | Cambia una regla de convalidación | Cambio en una capa, validado con pruebas; las dependencias entre capas las verifican pruebas de arquitectura |
| AC-07 | **Flexibilidad** | El CETPRO cambia la edad mínima o el plazo de reincorporación | Se cambia un parámetro **sin desplegar** y queda auditado |
| AC-08 | **Compatibilidad** | Uso en navegadores de escritorio actuales | Chrome, Edge y Firefox recientes |
| AC-09 | **Instalabilidad y portabilidad** | Se reconstruye una VM | Despliegue con un comando por VM, en Arm64 y x86-64 |
| AC-10 | **Recuperabilidad** (de AC-03) | Se pierde la cuenta de Oracle | El stack se reconstruye en otra VM desde Git y el respaldo cifrado |

### 3.3 Tensiones

| Tensión | Resolución |
| :--- | :--- |
| Costo cero frente a disponibilidad | Se acepta sin SLA, compensado con respaldo, infraestructura como código y contingencia en papel |
| Seguridad exigente frente a usuarios no técnicos | MFA con TOTP y códigos de respaldo, pero sin reglas de composición de contraseñas (NIST 800-63B-4) |
| Configurabilidad frente a simplicidad | Solo se parametrizan reglas no formalizadas o que pueden cambiar (sección 6.7) |
| Recomendación PCM de no gestionar usuarios en la nube frente a Identity en la app | Riesgo aceptado, mitigado con MFA y revisión semestral de privilegios |
| Velocidad de la IA frente a control de calidad y privacidad | Puertas humanas en la spec y el plan, pruebas primero, revisión independiente y datos sintéticos (sección 10.5) |

---

## 4. Solución conceptual: módulos

```mermaid
flowchart LR
subgraph SIS["Sistema de Matrícula (monolito modular)"]
  M1["M1 Identidad y accesos"]
  M2["M2 Parámetros institucionales"]
  M3["M3 Catálogo académico"]
  M4["M4 Matrícula"]
  M5["M5 Documentos y reportes"]
  M6["M6 Cumplimiento y auditoría"]
end
M4 --> M3
M4 --> M2
M5 --> M4
M5 --> M3
M1 --> M6
M4 --> M6
M5 --> M6
M2 --> M6
```

| Módulo | Responsabilidad | Casos de uso (ERS) | Datos principales |
| :--- | :--- | :--- | :--- |
| **M1 Identidad y accesos** | Autenticación con MFA, roles (Matrícula, Directivo, Administrador), altas y bajas, **revisión semestral de privilegios** | CU-08; RF-19, RF-20 | Usuarios, roles, intentos de ingreso |
| **M2 Parámetros institucionales** | Valores configurables y versionados (edad mínima, plazos, cupo, becas, textos, datos del CETPRO) | Nuevo | `parametro_institucional` |
| **M3 Catálogo académico** | Familias profesionales, **programas de estudios** con su **plan y resolución de autorización**, ciclos, **módulos formativos**, **unidades didácticas**, **periodos lectivos**, ofertas por turno, docentes | CU-02, CU-03; RF-09 a RF-11 | Programa, plan, módulo, unidad, periodo, oferta, docente |
| **M4 Matrícula** | Estudiantes (con documento, ubigeo y contacto), **matrícula con módulo**, **ratificación**, **licencia** y **reincorporación**, **convalidación**, convenios y becas, derecho de inscripción, anulación con motivo | CU-01; RF-01 a RF-08 | Estudiante, matrícula, matrícula por módulo, convalidación, licencia, pago, convenio |
| **M5 Documentos y reportes** | **Constancia de estudios** con código QR, **nómina**, **registro de matrícula (Anexo 1)**, **archivos Excel con el formato de AVANZA** (estudiantes y módulos) con validación previa y alerta de plazo, consultas por programa, módulo, periodo y turno, verificación pública; cada exportación queda en la **bitácora** | CU-05, CU-06; RF-12, RF-16, RF-17 | Documentos emitidos, vistas de reporte |
| **M6 Cumplimiento, auditoría y alertas** | **Bitácora** de solo inserción, aviso de privacidad versionado, solicitudes de derechos con plazo, registro de incidentes, retención y borrado, puertas de salida, **alertas y recordatorios** de plazos | RF-08; RNF-LEG | Bitácora, avisos, solicitudes, incidentes, alertas |

**Segundo sistema (aislado): Web institucional.** Sitio estático de información, **sin ninguna ruta hacia la BD ni la aplicación de matrícula**. Se despliega en su propia VM (AD-14).

---

## 5. Estilo arquitectónico y decisiones

### 5.1 Estilo

**Monolito modular con Clean Architecture**, desplegado como **un solo contenedor** de aplicación más una base PostgreSQL en otra VM.

- **Monolito**, porque hay 5 usuarios y un equipo pequeño: dividir en servicios sumaría coordinación, memoria y puntos de falla sin ventaja de escala (DA-04, DA-12).
- **Modular**, porque el dominio tiene límites claros (sección 4); cada módulo es una carpeta vertical con sus propios casos de uso, y los módulos se comunican solo por **contratos** de la capa de aplicación.
- **Clean Architecture**: las dependencias apuntan hacia el dominio. Las reglas de negocio no conocen la base de datos, la web ni las librerías de PDF.
- **Renderizado en servidor** (Razor Pages) con **HTMX** para actualizar fragmentos: simple de mantener, sin SPA, coherente con "HTML, CSS y JS".
- **Doble defensa**: las reglas críticas (edad mínima, matrícula única, tope de beca) se validan en el dominio **y** como restricciones o disparadores en PostgreSQL.

### 5.2 Decisiones

| ID | Decisión | Alternativa descartada | Estado |
| :--- | :--- | :--- | :---: |
| AD-01 | **Monolito modular** con Clean Architecture (Domain, Application, Infrastructure, Web), módulos como carpetas verticales y **pruebas de arquitectura** | Microservicios; capas sin reglas | Aceptada |
| AD-02 | **ASP.NET Core 10** (LTS hasta 14-nov-2028), **Razor Pages + HTMX**, CSS ligero | SPA o Blazor | Aceptada |
| AD-03 | **PostgreSQL 18** (soporte hasta nov-2030), **EF Core 10 + Npgsql**; reglas críticas también en la BD | PG 19; reglas solo en la aplicación | Aceptada |
| AD-04 | **ASP.NET Core Identity**, roles Administrador, Matrícula y Directivo, **MFA TOTP**, sin autoregistro; muestra **último ingreso e intentos fallidos** (ISO 27002, 8.5) | Tabla `usuario` propia | Aceptada |
| AD-05 | **Subred privada** para la BD y **OCI Bastion** para administrar | BD con IP pública | Aceptada |
| AD-06 | **Cloudflare, plan gratuito** (gestión de tráfico, DNS, TLS, seguridad, Tunnel) y **Caddy** detrás. **Dominio y registrador pendientes** (el equipo evalúa alternativas y lo asumirá) | Subdominio gratuito | Ajustada |
| AD-07 | **Docker Compose** por VM, imágenes **multi-arquitectura**, CI/CD gratuito, **OpenTofu + cloud-init** | Despliegue manual | Aceptada |
| AD-08 | **Respaldo diario cifrado** a Object Storage y **copia en el CETPRO**, **clave custodiada por el CETPRO**, **copia de la bitácora**, prueba de restauración | Solo instantáneas | Aceptada |
| AD-09 | **Estrategia anti-reclamación** en capas con **`keepalive` calibrado** | Pagar; aceptar el riesgo | Ajustada |
| AD-10 | **Privacidad desde el diseño**: sin copia del DNI, sin evidencia socioeconómica ni documentos de discapacidad, aviso con los diez elementos del art. 6, solicitudes de derechos, retención configurable | Guardar todo | Aceptada |
| AD-11 | **Constancia con código único y verificación por QR** mínima y con límite de tasa | Sin verificación | Aceptada |
| AD-12 | **Bitácora de solo inserción**: sesión, lecturas, modificaciones, eliminaciones, importaciones y exportaciones; **≥ 2 años** | Auditar solo escrituras | Aceptada |
| AD-13 | **ASVS 5.0 nivel 2** como criterio; **Top 10:2025** como lista de amenazas | Solo L1 | Aceptada |
| AD-14 | **Sitio institucional estático** en su propia VM, sin ruta a la BD | Sitio dinámico con BD | Aceptada |
| AD-15 | **QuestPDF** (PDF) y **ClosedXML** (Excel) con celdas saneadas; **licencias por revisar** | Otras | Aceptada |
| AD-16 | **Entornos separados**, **datos sintéticos** y etiqueta visible del entorno | Datos reales en pruebas | Aceptada |
| AD-17 | Hora **America/Lima** (UTC en BD); **identificadores internos opacos** en URL, **nunca el documento** | URL con DNI | Aceptada |
| AD-18 | **Documento de identidad** con tipo (DNI, carné de extranjería, pasaporte, **PTP**); **código de matrícula = número de documento** (LAG 11.2.2); apellido paterno y materno, nombres, fecha de nacimiento y sexo por separado, como en RENIEC y AVANZA | Correlativo propio | Propuesta |
| AD-19 | **Edad mínima configurable** (valor inicial 16; piso nacional 14); se guarda el valor aplicado | Constante | Propuesta |
| AD-20 | **Periodo de 18 semanas** con **ratificación por periodo**; ciclos Auxiliar Técnico y Técnico | Periodo anual | Propuesta |
| AD-21 | Estados **VIGENTE, ANULADA, RETIRADA, LICENCIA**; tipos **NUEVO, RATIFICACIÓN, REINCORPORACIÓN, TRASLADADO, RETIRADO ANTERIORMENTE** | Estados del Informe 004 | Propuesta |
| AD-22 | **Convalidación** con tipo, **resolución directoral**, justificación, ruta complementaria y similitud | Solo "módulos convalidados" | Propuesta |
| AD-23 | **Grado de instrucción** y verificación del certificado de estudios para el ciclo Técnico | Sin control | Propuesta |
| AD-24 | **Exportación para AVANZA** en el **formato de sus plantillas Excel** (estudiantes y módulos, con periodo y programa predefinidos), más el **Anexo 1 en PDF** y la **nómina**; filtrables por programa, módulo, periodo y turno; **mapeo de columnas configurable**; **validación previa** (sin celdas vacías) y **alerta del plazo** (un mes tras el inicio del periodo) | Solo nómina | Propuesta |
| AD-25 | Lenguaje oficial: **programa de estudios, módulo formativo, unidad didáctica, ciclo**; "constancia de estudios" | "Especialidad" | Propuesta |
| AD-26 | **Alcance legal explícito**: solo Registro de Matrícula | Implícito | Propuesta |
| AD-27 | **Parámetros institucionales versionados** con vigencia y auditoría | Constantes | Propuesta |
| AD-28 | **Matrícula por oferta** (programa + periodo lectivo + turno) que incluye **el o los módulos cursados** y su **periodo académico**, como en AVANZA y el Anexo 1; las **unidades didácticas se derivan del módulo** y las excepciones se registran aparte | Matrícula sin módulo; por unidad didáctica | Propuesta |
| AD-29 | **Situación específica** (PIR, Transitabilidad, MOT, Discapacidad, otras) como catálogo **restringido**, sin documentos | Texto libre | Propuesta |
| AD-30 | **Dirección, ubigeo, correo, teléfono y celular**: AVANZA los exige y su plantilla no admite vacíos; el sistema los solicita y **avisa antes de exportar si faltan**; son configurables y la finalidad consta en el aviso (base: función pública, Ley art. 14.1) | Opcionales sin control | Propuesta |
| AD-31 | **Puertas de salida a producción**: ODP designado por el CETPRO y publicado, banco inscrito, flujo transfronterizo comunicado, documento de seguridad con fecha cierta, acuerdo de encargo y confidencialidad con el equipo técnico, restauración probada | Desplegar sin trámites | Propuesta |
| AD-32 | **Catálogo alineado con AVANZA**: el plan de estudios guarda la **resolución de autorización** (tipo, número, año); se distinguen **periodo lectivo** (2026-I) y **periodo académico** (ordinal del programa); módulos y unidades se cargan **antes** que los estudiantes | Catálogo libre | Propuesta |
| AD-33 | **Atribuciones por rol conforme al ERS y a la forma de trabajo del CETPRO**: **Personal de matrícula** (registra, edita, anula, emite), **Directivo** (consulta y reportes) y **Administrador** (usuarios y parámetros, sin acceso a datos de estudiantes por defecto). Permisos granulares con valores iniciales por rol, auditados. El sistema **no impone procesos externos** (por ejemplo, quién carga en AVANZA) ni guarda credenciales de AVANZA | Un solo rol; imponer quién carga | Propuesta |
| AD-34 | **Alertas y recordatorios dentro del sistema**: panel y contador por rol, **parametrizables** (qué alerta, con cuánta anticipación y a quién); ciclo **Activa → Atendida o Descartada**, con quién y cuándo; **sin correo ni mensajería** en el MVP | Correo o WhatsApp (costo y privacidad) | Propuesta |
| AD-35 | **Desarrollo con SDD asistido por IA**: la spec manda y el código la demuestra. `AGENTS.md` como constitución; una spec por funcionalidad con **criterios EARS** de identificador estable (`AC-<MÓDULO>-<NN>`) trazados a pruebas; **dos puertas humanas** (aprobar la spec y aprobar el plan); `SpecCheck` y pruebas de arquitectura en CI; se **reutiliza y adapta el marco del equipo** (skills, agentes y validador). Detalle en la sección 10.5 | Pedir código a la IA sin spec; documentación posterior al código | Propuesta |
| AD-36 | **La IA nunca ve datos personales reales**: ni en indicaciones, archivos, pruebas, registros, capturas ni repositorio; solo datos sintéticos. El agente **no tiene acceso a producción ni a secretos**; solo herramientas aprobadas por el equipo, con su retención y uso para entrenamiento revisados; el contenido externo (páginas, PDF, correos) es **dato, no instrucción** | Probar con datos reales «anonimizados» | Propuesta |

### 5.3 Tácticas por atributo

| Atributo | Táctica | Dónde |
| :--- | :--- | :--- |
| AC-01 | Reglas en el dominio y restricciones en la BD; índices únicos parciales | M4, BD |
| AC-02 | MFA, bloqueo, autorización por rol y recurso, **denegar por defecto**, cabeceras de seguridad, límites de tasa | M1, Web |
| AC-03 | Respaldo cifrado, restauración probada, infraestructura como código, reinicio automático de contenedores | Despliegue |
| AC-04 | Índices, paginación con tope, consultas acotadas, sin dependencias pesadas | BD, Web |
| AC-05 | Renderizado en servidor, teclado primero, borradores guardados en servidor, mensajes claros | Web |
| AC-06 | Capas con regla de dependencia, pruebas de arquitectura, módulos con contratos | Solución |
| AC-07 | Tabla de parámetros con vigencia | M2 |
| AC-09 | Compose, imágenes multi-arquitectura, `cloud-init` | Despliegue |
| AC-01, AC-06 | Specs aprobadas con criterios EARS trazados a pruebas; `SpecCheck`, pruebas de arquitectura y puertas humanas en CI | Proceso (10.5) |

---

## 6. Arquitectura lógica

### 6.1 Contexto (C4, nivel 1)

```mermaid
flowchart TB
P1["Personal de matrícula<br/>3 personas"]
P2["Directivos<br/>2 personas"]
P3["Administrador"]
P4["Persona externa<br/>verifica una constancia"]
S["Sistema de Matrícula<br/>CETPRO Joaquín López Antay"]
W["Web institucional<br/>sitio estático aislado"]
AV["AVANZA (Minedu)<br/>carga manual de nómina"]
UG["UGEL Huamanga"]
OR["Oracle Cloud<br/>infraestructura"]
CF["Cloudflare y registrador<br/>dominio, DNS, TLS"]
HC["Monitoreo externo<br/>Healthchecks"]
P1 -->|"HTTPS"| S
P2 -->|"HTTPS"| S
P3 -->|"HTTPS"| S
P4 -->|"HTTPS, solo lectura mínima"| S
S -.->|"archivo Anexo 1 y nómina"| AV
S -.->|"informes"| UG
S --> OR
S --> CF
S -.->|"latido"| HC
W --> OR
```

### 6.2 Contenedores (C4, nivel 2)

```mermaid
flowchart TB
NAV["Navegador de escritorio"]
subgraph EDGE["Borde"]
  CFE["Cloudflare<br/>DNS, TLS, Tunnel"]
end
subgraph APP["VM-APP (Arm, 1 OCPU, 6 GB)"]
  CAD["Caddy<br/>proxy inverso"]
  WEB["Aplicación Matrícula<br/>ASP.NET Core 10<br/>Razor Pages y HTMX"]
  KA["keepalive y tareas"]
end
subgraph DB["VM-DB (Arm, 1 OCPU, 6 GB, privada)"]
  PG[("PostgreSQL 18")]
  BK["Respaldo cifrado"]
end
subgraph WEBVM["VM-WEB (x86, 1 GB)"]
  STA["Web institucional estática"]
end
OBJ[("Object Storage<br/>respaldos cifrados")]
CET[("Copia cifrada en el CETPRO")]
NAV --> CFE --> CAD
CAD --> WEB
CFE --> STA
WEB -->|"5432, TLS"| PG
PG --> BK --> OBJ
OBJ -.-> CET
```

### 6.3 Componentes y capas (C4, nivel 3)

```mermaid
flowchart TB
subgraph WEBL["Cetpro.Web (presentación)"]
  PAG["Páginas Razor y HTMX"]
  MID["Middleware: errores, cabeceras, límites de tasa, autorización"]
end
subgraph APPL["Cetpro.Application (casos de uso)"]
  UC["Casos de uso por módulo M1 a M6"]
  CON["Contratos (interfaces) entre módulos"]
  VAL["Validación y autorización"]
end
subgraph DOML["Cetpro.Domain (reglas)"]
  ENT["Entidades, valor y reglas"]
  POL["Políticas: edad, matrícula única, beca, convalidación"]
end
subgraph INFL["Cetpro.Infrastructure"]
  EF["EF Core y Npgsql"]
  DOC["PDF, Excel, QR"]
  ID["Identity y TOTP"]
  JOB["Tareas: retención, recordatorios"]
end
PAG --> UC
MID --> UC
UC --> ENT
UC --> POL
UC --> CON
INFL --> UC
INFL --> DOML
```

**Reglas de dependencia** (verificadas por pruebas de arquitectura):

1. `Domain` no depende de nada del proyecto.
2. `Application` depende solo de `Domain`.
3. `Infrastructure` implementa los contratos de `Application`.
4. `Web` depende de `Application`; nunca de `Infrastructure` salvo el registro de servicios.
5. Un módulo **no usa las entidades de otro**: se comunica por contratos de `Application`.
6. Ningún controlador o página accede directamente a `DbContext`.

### 6.4 Estructura propuesta de la solución

```text
SisJoaquin/
├─ AGENTS.md                  (constitución: reglas obligatorias para personas y agentes de IA)
├─ .claude/                   (skills y agentes del proyecto, adaptados del marco del equipo)
├─ specs/                     (una carpeta por spec: spec.md, plan.md, tasks.md, verificacion.md; TRACEABILITY.md)
├─ progress/                  (CHANGELOG, bloqueos y bitácora de sesiones)
├─ tools/SpecCheck/           (validador de specs)
├─ src/
│  ├─ Cetpro.Domain/          (Matricula, Catalogo, Identidad, Parametros, Documentos, Cumplimiento, Compartido)
│  ├─ Cetpro.Application/     (casos de uso por módulo y contratos)
│  ├─ Cetpro.Infrastructure/  (EF Core, Identity, PDF/Excel/QR, tareas)
│  └─ Cetpro.Web/             (Razor Pages, HTMX, estáticos)
├─ tests/
│  ├─ Cetpro.Domain.Tests/
│  ├─ Cetpro.Application.Tests/
│  ├─ Cetpro.Architecture.Tests/   (reglas de dependencia)
│  ├─ Cetpro.Integration.Tests/    (PostgreSQL con contenedor)
│  └─ Cetpro.E2E/                  (Playwright y axe)
├─ infra/                     (Compose, Caddy, OpenTofu, cloud-init, backup, keepalive)
├─ db/                        (esquema SQL de referencia, pruebas de humo y, luego, migraciones)
├─ docs/                      (documentación viva: 7 carpetas temáticas y glosario)
├─ Entregables/               (línea base del ERS y de este documento, y la propuesta en .docx)
└─ Contexto/  Investigacion/   (material de partida: solo referencia)
```

Los nombres de proyecto son una **propuesta**.

### 6.5 Flujo principal: registrar una matrícula

```mermaid
sequenceDiagram
actor U as Personal de matrícula
participant W as Web (Razor y HTMX)
participant A as Caso de uso RegistrarMatrícula
participant D as Dominio
participant B as PostgreSQL
participant L as Bitácora
U->>W: Ingresa el documento
W->>A: Buscar estudiante
A->>B: Consulta por documento
B-->>A: Existe o no
A-->>W: Datos reutilizables (reingreso) o ficha vacía
U->>W: Completa datos, programa, periodo, turno
W->>A: Registrar
A->>D: Validar (edad, matrícula única, requisitos, beca)
D-->>A: Válido o motivo de rechazo
A->>B: Guardar matrícula y pago (transacción)
B-->>A: Restricciones de la BD también verifican
A->>L: Registrar evento (usuario, acción, recurso)
A-->>W: Confirmación con código de matrícula
U->>W: Emitir constancia de estudios
W->>A: Generar PDF con QR
A->>L: Registrar emisión
```

### 6.6 Estados de la matrícula

```mermaid
stateDiagram-v2
[*] --> VIGENTE : registro o ratificación
VIGENTE --> ANULADA : error de registro con motivo
VIGENTE --> RETIRADA : deja los estudios
VIGENTE --> LICENCIA : licencia de estudios
LICENCIA --> RETIRADA : vence el plazo de reserva
LICENCIA --> [*] : reincorporación genera una nueva matrícula
ANULADA --> [*]
RETIRADA --> [*]
```

- La **ratificación** crea la matrícula del siguiente periodo con tipo RATIFICACIÓN y enlace a la anterior.
- Una **reincorporación** crea una matrícula nueva de tipo REINCORPORACIÓN.
- Solo las matrículas **VIGENTES** aparecen en la nómina.

### 6.7 Configurabilidad

Toda regla no formalizada o cambiante es un **parámetro** (M2) con valor, vigencia, responsable y auditoría. Cada matrícula guarda el valor aplicado (por ejemplo, `edad_minima_aplicada`). El catálogo completo está en el [informe 05](../Investigacion/05-decisiones-propuestas-y-preguntas.md#4-parámetros-configurables). Ejemplos: `edad_minima` (16), `periodo_semanas` (18), `cupo_referencial` (30, no es límite), `beca_porcentaje_maximo` (50), `retencion_bitacora_anios` (2, mínimo legal), `revision_privilegios_meses` (6), `alerta_dias_antes_plazo_registro` (7).

---

### 6.8 Exportación para AVANZA (la carga queda fuera del sistema)

AVANZA es el sistema del Minedu donde el CETPRO registra su información académica. **No hay API** y **la carga en AVANZA no forma parte de este sistema**: la gestiona el CETPRO con su forma de trabajo y sus responsables actuales. Nuestro sistema solo **prepara los archivos** (plantillas Excel y Anexo 1) para evitar el re-digitado. **No guarda credenciales de AVANZA ni impone quién debe cargar.**

```mermaid
flowchart LR
subgraph SIS["Sistema de Matrícula"]
  CAT["M3 Catálogo<br/>plan, módulos, unidades"]
  MAT["M4 Matrículas del periodo"]
  EXP["M5 Exportador<br/>mapeo de columnas, validación previa"]
  ALE["M6 Alertas<br/>plazo y datos faltantes"]
end
USR["Personal de matrícula y Directivos<br/>según sus permisos"]
AV["AVANZA (Minedu)<br/>fuera del sistema"]
CAT --> EXP
MAT --> EXP
USR -->|"solicita el archivo"| EXP
EXP -->|"Excel y Anexo 1"| USR
ALE -.->|"avisa plazos y faltantes"| USR
USR -.->|"carga según el procedimiento del CETPRO"| AV
```

**Orden de registro en AVANZA** (se muestra como lista de verificación **informativa**): 1) plan de estudios con la **resolución de autorización**; 2) **módulos**; 3) **unidades didácticas**; 4) **estudiantes** por periodo lectivo, programa, módulo y periodo académico; 5) notas (fuera de alcance).

**Reglas de la integración**

| Regla | Origen |
| :--- | :--- |
| El **mapeo de columnas** es configurable y se prueba con las plantillas vigentes | El Minedu cambia el sistema (manual v3.5) |
| **Validación previa**: AVANZA no admite celdas vacías ni documentos inválidos | Manual de AVANZA |
| **Alerta del plazo** (un mes después del inicio del periodo, parametrizable); reportar tarde es infracción grave. El sistema **no sabe** si se cargó: la alerta se **atiende o se descarta** a mano | LAG 17.1; manual; AD-34 |
| Si AVANZA impone un **tope de filas por archivo** (en notas es de 500), el exportador **divide** los archivos | Manual (caso 4); por confirmar con la plantilla |
| **Sin credenciales de AVANZA** en el sistema y **sin imponer quién carga** | AD-33 |
| Cada exportación queda en la **bitácora** (quién, qué, cuándo), como exige el reglamento | DS art. 46 |
| Si el CETPRO corrige datos tras un aviso de errores de RENIEC, el **Personal de matrícula** los edita y **regenera** el archivo | Manual |

### 6.9 Roles y permisos

Las atribuciones salen del ERS (RF-20, CU) y de la entrevista: **3 encargados de matrícula** y **2 directivos que ven reportes**. El rol **Administrador** es una propuesta para tareas técnicas (Informe 004). Los permisos son **granulares y editables** por el Administrador con auditoría, con estos **valores iniciales (por validar con la Dirección)**:

| Función | Personal de matrícula | Directivo | Administrador | Público |
| :--- | :---: | :---: | :---: | :---: |
| Registrar y editar estudiantes y matrículas (RF-01 a RF-04) | Sí | No | No | No |
| **Anular** una matrícula, con motivo obligatorio (RF-08) | Sí | No | No | No |
| Ratificar, licencia, reincorporación, convalidación (RF-05) | Sí | No | No | No |
| Becas y derecho de inscripción (RF-06, RF-07) | Sí | Consulta | No | No |
| Catálogo: programas, módulos, unidades, periodos, ofertas, docentes (CU-02, CU-03) | Sí | Consulta | No | No |
| Consultar matrículas y matriculados por programa y turno (RF-12) | Sí | Sí | No | No |
| Emitir **constancia de estudios** (RF-16, CU-05) | Sí | No | No | No |
| Generar **nómina**, **registro de matrícula (Anexo 1)** y **archivos para AVANZA** (RF-17, CU-06) | Sí | Sí | No | No |
| Ver la **situación específica** (por ejemplo discapacidad) | Sí | No | No | No |
| Verificar una constancia por QR (respuesta mínima) | — | — | — | Sí |
| Ver **alertas** | Las suyas | Las suyas | Las técnicas | No |
| Consultar la **bitácora** | No | Sí | Técnica, sin datos del estudiante | No |
| **Usuarios**: altas, bajas, MFA, informe semestral de privilegios | No | Aprueba el informe | Sí | No |
| **Parámetros institucionales** | Consulta | Consulta y recibe aviso de cambios | Edita | No |
| Solicitudes de derechos de los titulares (recepción y respuesta) | Registra | Responde | No | No |
| Respaldos, restauración y salud del servicio | No | No | Sí | No |

**Principios:** mínimo privilegio; denegar por defecto; el Administrador **no ve datos de estudiantes** salvo lo necesario y registrado; **el sistema no cambia la forma de trabajo del CETPRO fuera de él** (quién carga en AVANZA, cómo se firma la ficha en papel).

### 6.10 Alertas y recordatorios

Alertas **dentro del sistema** (panel y contador por rol), calculadas por una tarea programada ligera. Cada alerta tiene **ciclo de vida**: Activa → **Atendida** (quién y cuándo) o **Descartada**. Todo es **parametrizable**: qué alertas se usan, con cuánta anticipación y a qué roles. **No se envía correo ni mensajería** en el MVP.

| Alerta | Cuándo salta (valor inicial) | Destinatarios iniciales | Origen |
| :--- | :--- | :--- | :--- |
| **Plazo de registro de la matrícula** | 7 y 2 días antes de cumplirse un mes del inicio del periodo | Personal de matrícula y Directivo | LAG 17.1 |
| **Datos faltantes para exportar** | Al generar el archivo y al cerrar el periodo: estudiantes sin correo, celular, ubigeo o grado de instrucción | Personal de matrícula | AVANZA no admite vacíos |
| **Ratificaciones pendientes** | Al iniciar el periodo | Personal de matrícula y Directivo | LAG 11.2.2 |
| **Licencia por vencer** | 15 y 5 días antes de cumplirse el plazo de reserva (`plazo_reserva_licencia_dias`, por definir) | Personal de matrícula | LAG 11.3 y 11.4 |
| **Solicitud de derechos con plazo** | A la mitad y 2 días antes del plazo (8, 20 o 10 días hábiles) | Directivo (responsable) | DS arts. 66 a 71 |
| **Revisión semestral de privilegios** | Cada 6 meses | Administrador y Directivo | DS art. 46 |
| **Seguridad**: ingresos fallidos masivos, cuenta bloqueada, exportaciones inusuales | Por umbral | Administrador y Directivo | ISO 27002, 8.16 |
| **Respaldo fallido** o **restauración vencida** | Al fallar o a los 90 días sin prueba | Administrador | DS art. 51 |
| **Parámetro crítico modificado** | Al cambiar la edad mínima, un plazo o un tope | Directivo | AD-27 |
| **Retención**: datos por depurar | 30 días antes | Administrador y Directivo | DS arts. 46 y 69; ISO 5.33 |

## 7. Datos

### 7.1 Principios

1. **PostgreSQL 18**, esquema propio, **EF Core 10** para el acceso, con **migraciones versionadas**.
2. **Reglas críticas también en la BD** (restricciones, índices únicos parciales, disparadores) como segunda defensa.
3. **Minimización**: solo los datos necesarios; sin copia del DNI, sin evidencia de ingresos ni documentos de discapacidad.
4. **Identificadores internos opacos**; el documento del estudiante es dato, no clave de URL.
5. **Hora** en UTC con zona America/Lima en la presentación.
6. **Tres roles de BD**: migraciones (propietario), aplicación (`cetpro_app`: sin `DELETE` general y sin permiso de modificar la bitácora) y solo lectura para reportes y respaldos. El script de referencia crea solo `cetpro_app`, sin contraseña; el despliegue crea los otros dos y asigna los secretos.

### 7.2 Modelo conceptual

```mermaid
erDiagram
ESTUDIANTE ||--o{ MATRICULA : "tiene"
OFERTA ||--o{ MATRICULA : "agrupa"
PROGRAMA_ESTUDIOS ||--o{ OFERTA : "se dicta en"
PERIODO_LECTIVO ||--o{ OFERTA : "contiene"
DOCENTE ||--o{ OFERTA : "a cargo"
PLAN_ESTUDIOS ||--o{ MODULO_FORMATIVO : "se compone de"
MODULO_FORMATIVO ||--o{ UNIDAD_DIDACTICA : "se compone de"
MATRICULA ||--o| PAGO_INSCRIPCION : "genera"
CONVENIO ||--o{ PAGO_INSCRIPCION : "otorga beca"
MATRICULA ||--o{ CONVALIDACION : "puede tener"
MATRICULA ||--o{ LICENCIA_ESTUDIOS : "puede tener"
MATRICULA ||--o{ DOCUMENTO_EMITIDO : "emite"
MATRICULA }o--o| MATRICULA : "matricula anterior"
MATRICULA ||--o{ MATRICULA_MODULO : "cursa"
MODULO_FORMATIVO ||--o{ MATRICULA_MODULO : "referido"
PROGRAMA_ESTUDIOS ||--o{ PLAN_ESTUDIOS : "tiene"
USUARIO ||--o{ ALERTA : "atiende"
MATRICULA ||--o{ MATRICULA_EXCEPCION_UNIDAD : "subsanacion o convalidada"
UNIDAD_DIDACTICA ||--o{ MATRICULA_EXCEPCION_UNIDAD : "referida"
USUARIO ||--o{ BITACORA : "genera"
PARAMETRO_INSTITUCIONAL ||--o{ PARAMETRO_HISTORIAL : "versiona"
SOLICITUD_DERECHOS }o--|| ESTUDIANTE : "titular"
```

### 7.3 Cambios sobre el esquema SQL v1.0

Resumidos en el [informe 05, sección 6](../Investigacion/05-decisiones-propuestas-y-preguntas.md#6-cambios-propuestos-al-esquema-sql-v11). El resultado es el [esquema v1.1](../db/esquema_matricula_cetpro_v1.1.sql), con sus [pruebas de humo](../db/pruebas_esquema_v1.1.sql) y un [README de db](../db/README.md). **Ninguno de los dos scripts se ha ejecutado todavía en PostgreSQL**: correrlos es parte del cierre de la fase de diseño. Los principales cambios:

- Se retira todo lo relativo a **notas** (fuera de alcance).
- El periodo calendario se llama **periodo lectivo** (`periodo_lectivo`, por ejemplo 2026-I); el **periodo académico** es el ordinal del estudiante dentro del programa y vive en `matricula_modulo`.
- `dni` pasa a **`tipo_documento` + `numero_documento`** (hay extranjeros); `codigo_matricula` = número de documento.
- Periodo de **18 semanas** y **ratificación**; estado **LICENCIA**; matrícula anterior enlazada.
- `especialidad` → **`programa_estudios`**, con **ciclo** y **créditos**; nuevas tablas de **plan, módulo y unidad didáctica**.
- **Convalidación** con resolución directoral, justificación, ruta complementaria y similitud; **licencia de estudios**.
- **Parámetros** con historial; **aviso de privacidad**, **solicitudes de derechos** e **incidentes**.
- **Bitácora** ampliada a lecturas y exportaciones; **Identity** en lugar de `usuario`.
- **Módulo en la matrícula** (`matricula_modulo`), **plan de estudios con resolución de autorización**, **ubigeo** y contacto del estudiante, **alertas** (`alerta` con su ciclo de vida) y **permisos por rol** (`rol_permiso`).

### 7.4 Concurrencia e integridad

- **Matrícula vigente única** por estudiante, programa y periodo lectivo (RN-13; índice único parcial). La oferta incluye el turno, por eso no basta con la oferta.
- **Control de concurrencia optimista** al editar una matrícula entre dos personas.
- **Una sola persona matriculada con el mismo documento** (restricción única con validación por tipo).
- **Transacción única** al guardar matrícula, pago y evento de bitácora.

### 7.5 Retención

| Dato | Plazo | Estado |
| :--- | :--- | :--- |
| Bitácora | **≥ 2 años** (DS art. 46) | Parámetro |
| Fichas, matrículas y constancias | **Por definir con la UGEL** | Parámetro |
| Solicitudes de derechos | Por definir | Parámetro |
| Respaldos | Escalonada (diarios, semanales, mensuales), a confirmar | Propuesta |

---

## 8. Arquitectura de despliegue

Detalle y fuentes en el [informe 03](../Investigacion/03-despliegue-y-continuidad-oracle.md).

### 8.1 Topología

```mermaid
flowchart TD
USR["Usuarios"] -->|"HTTPS"| CF["Cloudflare (dominio propio)"]
PUB["Visitantes"] -->|"HTTPS"| CF
subgraph OCI["Oracle Cloud, región de origen, VCN"]
  subgraph PUBN["Subred pública"]
    WEB["VM-WEB<br/>x86, 1 GB<br/>sitio institucional"]
    APP["VM-APP<br/>Arm, 1 OCPU, 6 GB<br/>Caddy y Matrícula"]
  end
  subgraph PRIV["Subred privada"]
    DB[("VM-DB<br/>Arm, 1 OCPU, 6 GB<br/>PostgreSQL 18")]
  end
  BAS["OCI Bastion"]
end
OBJ[("Object Storage 20 GB")]
CET[("Copia en el CETPRO")]
HC["Healthchecks<br/>monitoreo externo"]
CF --> APP
CF --> WEB
APP -->|"5432 TLS"| DB
DB --> OBJ
OBJ -.-> CET
APP -.->|"latido"| HC
DB -.->|"latido"| HC
BAS -.->|"SSH"| APP
BAS -.->|"SSH"| DB
BAS -.->|"SSH"| WEB
```

### 8.2 Máquinas

| VM | Forma | Contenido | Pública |
| :--- | :--- | :--- | :---: |
| **VM-WEB** | AMD Micro, 1/8 OCPU, 1 GB | Servidor web mínimo con el sitio **estático** | Sí |
| **VM-APP** | A1, 1 OCPU, 6 GB | Caddy, aplicación de matrícula (contenedor) y `keepalive` | Sí |
| **VM-DB** | A1, 1 OCPU, 6 GB | PostgreSQL 18, respaldos y `keepalive` | **No** |

Disco: 3 VM de 50 GB usan 150 de los 200 GB. La VM-WEB casi siempre parecerá "inactiva" para Oracle: **no aloja nada crítico**.

### 8.3 Reglas de red

| Origen | Destino | Puerto | Estado |
| :--- | :--- | :--- | :--- |
| Internet | VM-WEB y VM-APP | 443 (o ninguno con túnel) | Permitido |
| VM-APP | VM-DB | 5432 | Permitido |
| Bastion | Las tres VM | 22 (llave) | Permitido |
| VM-WEB | VM-APP y VM-DB | todos | **Denegado** |
| Cualquier otro | VM-DB | todos | **Denegado** |

### 8.4 Presupuesto de recursos (a validar con mediciones)

| VM | Memoria estimada | Comentario |
| :--- | :--- | :--- |
| VM-APP (6 GB) | Sistema y Docker ~0,5 GB; aplicación .NET ~0,2 a 0,4 GB; proxy < 0,2 GB | Sobrada. La CPU de 1 OCPU basta para 5 usuarios |
| VM-DB (6 GB) | Sistema ~0,4 GB; PostgreSQL con `shared_buffers` de 1 a 1,5 GB | Buena |
| VM-WEB (1 GB) | < 200 MB | Suficiente para contenido estático |

Cada contenedor declara `mem_limit` y `cpus`.

### 8.5 Entregas y entornos

- **Entornos**: desarrollo (local), pruebas (local o VM efímera con **datos sintéticos**) y producción, con etiqueta visible del entorno.
- **CI** (GitHub Actions, cuotas gratuitas): compilación sin advertencias, pruebas, pruebas de arquitectura, CodeQL, dependencias vulnerables, Trivy, gitleaks y SBOM.
- **CD**: imágenes multi-arquitectura en un registro de contenedores, despliegue con **aprobación de un segundo integrante** y registro del cambio (ISO 27002, 8.31 y 8.32).
- **Infraestructura como código**: OpenTofu y `cloud-init`; **Compose** versionado en `infra/`.

### 8.6 Respaldo y recuperación

| Elemento | Decisión |
| :--- | :--- |
| Objetivos | **RPO ≤ 24 h** (≤ 4 h en temporada) y **RTO ≤ 4 h**, por validar con la Dirección |
| Frecuencia | Volcado **diario** (el reglamento exige mínimo semanal) |
| Cifrado | Antes de salir de la VM-DB; la **clave la custodia el CETPRO** |
| Destinos | Object Storage de Oracle (20 GB) **y** copia en el CETPRO; la bitácora se copia aparte |
| Prueba | Restauración completa **antes de cada despliegue mayor y cada trimestre**, comparada con el RTO |
| Integridad | *Checksum* de cada copia |

### 8.7 Continuidad y contingencia

- **Oracle reclama o apaga una VM**: `keepalive` calibrado (ráfaga de CPU de baja prioridad cada hora), trabajo real programado, latido a Healthchecks y reconstrucción desde Git y respaldo. Ver [anexo `keepalive`](../Investigacion/anexos/keepalive/README.md).
- **Cae el Internet del CETPRO**: **procedimiento en papel** con la ficha oficial y carga posterior; modo degradado local opcional con el mismo Compose y el último respaldo.
- **Pérdida de la cuenta de Oracle**: correo institucional neutro, **dos administradores**, MFA y respaldo fuera de Oracle.

### 8.8 Costo

| Concepto | Costo |
| :--- | :--- |
| Cómputo, disco, objetos, red | **0** (Always Free, dentro de los límites) |
| Cloudflare, Caddy, Let's Encrypt, GitHub, Healthchecks | **0** (planes gratuitos, cuotas por confirmar) |
| **Dominio** | **Asumido por el equipo** (costo anual por confirmar) |

No se pasa a Pay As You Go (no figura como exención de reclamación y la cuenta Free Tier no puede generar cargos).

---

## 9. Seguridad y privacidad

Detalle en el [informe 02](../Investigacion/02-seguridad-y-estandares.md) y el [informe 01](../Investigacion/01-marco-legal-y-normativo.md).

### 9.1 Zonas de confianza

```mermaid
flowchart LR
INT["Internet<br/>no confiable"] -->|"TLS"| EDGE["Borde<br/>Cloudflare"]
EDGE --> WEB["Zona pública<br/>VM-WEB institucional"]
EDGE --> APP["Zona de aplicación<br/>VM-APP matrícula"]
APP -->|"5432 con TLS"| DB[("Zona de datos<br/>VM-DB privada")]
DB -->|"cifrado"| BK[("Respaldos<br/>fuera de la VM")]
ADM["Administración<br/>Bastion y llave SSH"] -.-> APP
ADM -.-> DB
```

**La web institucional no tiene ningún camino a la base de datos.** Cada cruce de frontera exige autenticación o validación explícita.

### 9.2 OWASP Top 10:2025 aplicado

| Riesgo | Controles clave |
| :--- | :--- |
| A01 Control de acceso roto | Denegar por defecto; autorización por rol **y** recurso; identificadores opacos; pruebas por rol |
| A02 Configuración incorrecta | Contenedores sin privilegios; BD privada; cabeceras (HSTS, CSP, X-Content-Type-Options, Referrer-Policy); entorno de producción sin detalles de error |
| A03 Cadena de suministro | Versiones fijas; Dependabot; Trivy; SBOM; acciones de GitHub fijadas por *hash* |
| A04 Fallas criptográficas | TLS 1.2+; resumen de contraseñas robusto; **cifrado propio de los respaldos** con clave del CETPRO |
| A05 Inyección | EF Core con parámetros; codificación de Razor; **sanear celdas** de Excel; validación con límites |
| A06 Diseño inseguro | Modelo de amenazas; anulación con motivo; separación de funciones; límites de tasa; doble defensa |
| A07 Autenticación | **MFA para todo el personal**; sin autoregistro; bloqueo temporal; contraseña de 15 caracteres como mínimo (NIST 800-63B-4), sin reglas de composición |
| A08 Integridad | Imágenes por *digest*; ramas protegidas; **bitácora de solo inserción**; constancia con *hash* y QR |
| A09 Registro y alertas | **Bitácora legal (DS art. 46)**; alertas por umbral; sin datos sensibles en logs |
| A10 Condiciones excepcionales | Manejador global; **fallar cerrado**; transacciones atómicas; tiempos de espera |

### 9.3 Identidad y sesión

- **ASP.NET Core Identity** con roles; **TOTP** obligatorio para las 5 personas usuarias y códigos de respaldo.
- Cookie `HttpOnly`, `Secure`, `SameSite`; vencimiento por inactividad (30 min, configurable) con **aviso previo** y **borrador de la ficha guardado en el servidor**.
- Al ingresar se muestra la **fecha del último ingreso y los intentos fallidos** desde entonces (ISO 27002, 8.5).
- **Sin autoregistro**; alta y baja solo por el Administrador; **revisión de privilegios al menos cada semestre** (DS art. 46).

### 9.4 Bitácora y auditoría

Registra **sesión, lecturas, modificaciones, eliminaciones, importaciones y exportaciones** de datos personales, con usuario, fecha, recurso y origen. **Solo inserción**, conservación **≥ 2 años**, disponible de inmediato y con **copia periódica en el CETPRO**. El rol de aplicación de la BD no puede modificarla.

### 9.5 Privacidad desde el diseño

- **Aviso de privacidad** con los diez elementos del art. 6 del reglamento, en lenguaje claro para adolescentes, **versionado**, con evidencia de aceptación.
- **Sin copia del DNI**, sin evidencia socioeconómica y sin documentos de discapacidad; la **discapacidad** se guarda solo como **situación específica restringida**.
- **Solicitudes de derechos** con plazo (8, 20 y 10 días hábiles).
- Dirección, ubigeo, correo y celular: se solicitan porque AVANZA no admite celdas vacías (AD-30); la finalidad consta en el aviso y el sistema **avisa antes de exportar** si faltan.
- **Datos de prueba sintéticos**.

### 9.6 Incidentes de seguridad

1. **Documentar todo incidente** (hechos, efectos, medidas).
2. Evaluar si hay exposición de grandes volúmenes, muchas personas, datos sensibles o perjuicio evidente.
3. Si corresponde, **notificar a la ANPD en 48 horas** (y al titular si lo afecta; y al **CNSD** si es digital).
4. Contener, recuperar, corregir y aprender.

### 9.7 Puertas de salida a producción (AD-31)

| Condición | Responsable | Estado |
| :--- | :--- | :---: |
| **ODP** designado por el CETPRO y publicado (comunicado a la ANPD en 15 días); puede ser una persona con otras funciones o externa | Dirección | Pendiente |
| Banco de datos **inscrito** en el Registro Nacional (gratuito, aprobación automática) | Dirección | Pendiente |
| Resolución directoral que designa al **responsable** y al ODP | Dirección | Pendiente |
| **Flujo transfronterizo comunicado** (art. 21.2) y contrato de Oracle revisado | Responsable del tratamiento | Pendiente |
| **Documento de seguridad** con fecha cierta e inventario de datos | Equipo y responsable | Pendiente |
| **Acuerdo de encargo y confidencialidad** con el equipo técnico (el CETPRO es el responsable; el equipo, encargado) | Dirección y equipo | Pendiente |
| **Restauración** probada y medida contra el RTO | Equipo | Pendiente |
| Capacitación breve de las 5 personas usuarias | Equipo | Pendiente |

---

## 10. Calidad, pruebas y operación

### 10.1 Estrategia de pruebas

| Nivel | Qué verifica | Herramientas (propuesta) |
| :--- | :--- | :--- |
| Unitarias | Reglas del dominio: edad, matrícula única, beca, convalidación, estados | xUnit |
| Aplicación | Casos de uso con repositorios simulados | xUnit |
| **Arquitectura** | Reglas de dependencia entre capas y módulos | NetArchTest o similar |
| Integración | EF Core y restricciones de la BD con PostgreSQL real | Testcontainers |
| **E2E y accesibilidad** | Flujos de matrícula y constancia; WCAG 2.2 AA | Playwright y axe |
| Seguridad | Dependencias, imágenes, secretos, análisis estático y dinámico básico | CodeQL, Trivy, gitleaks, OWASP ZAP |
| **Restauración** | Respaldo y recuperación completos frente al RTO | Script de prueba |
| Carga ligera | 3 usuarios concurrentes con datos de temporada | k6 |
| **Especificaciones** | Estructura, calidad EARS, cobertura de requisitos, puertas del ciclo y criterios sin prueba | `SpecCheck` (adaptado del marco del equipo; 10.5) |
| **Esquema de BD** | Reglas en la base: edad, matrícula única, beca, convalidación, bitácora inmutable, permisos por rol | [Pruebas de humo SQL](../db/pruebas_esquema_v1.1.sql); luego Testcontainers |

### 10.2 Observabilidad

- **Logs estructurados** (Serilog) sin datos sensibles ni credenciales; hora sincronizada.
- **Chequeos de salud** de la aplicación y la BD; **latido** externo a Healthchecks y monitoreo de disponibilidad.
- Avisos técnicos al equipo (correo del servicio de monitoreo, **fuera del sistema**) ante caídas y fallos de respaldo. Las alertas de negocio y de seguridad para el personal se ven **dentro del sistema** (6.10), sin correo.

### 10.3 Operación

- **Manual de operación** (ISO 27002, 5.37): instalación, respaldo, restauración, contingencia, contactos y escalamiento.
- **Gestión de cambios** con aprobación y registro.
- **Revisión semestral** de privilegios y del inventario de datos.

### 10.4 Accesibilidad y rendimiento

- **WCAG 2.2 AA** como criterio de aceptación; foco visible, teclado completo, contraste, etiquetas, mensajes claros.
- Rendimiento percibido: pantallas principales **< 2,5 s**, interacción **< 200 ms**; pocas dependencias de JavaScript.

### 10.5 Desarrollo guiado por especificaciones (SDD) asistido por IA

El equipo desarrollará con **Spec-Driven Development asistido por IA** (RC-07, RNF-18, AD-35). No es un detalle de proceso: condiciona cómo se escriben los documentos, cómo se numeran los requisitos, qué puede entrar a una herramienta de IA y qué puede darse por terminado. El método sigue el flujo que el equipo ya usó en otro proyecto (la carpeta `DocumentacionEjemplo`, que es solo de referencia), a su vez inspirado en GitHub Spec Kit.

**Idea central: la spec manda y el código la demuestra.** Ninguna línea de producción existe sin una spec aprobada y un plan aprobado; ningún criterio de aceptación existe sin una prueba; ninguna funcionalidad se da por terminada sin una verificación que converge. **Dos decisiones las toma siempre una persona**: aprobar la spec y aprobar el plan.

#### 10.5.1 De los documentos al código

```mermaid
flowchart LR
NOR["Normativa oficial<br/>LAG, DL 1375, DS 016-2024-JUS"] --> ERS
ERS["ERS v1.1<br/>RF, RN, RNF, CU y límites"] --> SPEC["Spec<br/>criterios EARS AC-MOD-NN"]
ARQ["Arquitectura<br/>decisiones AD, capas, seguridad"] --> SPEC
SQL["Esquema SQL<br/>modelo y reglas de BD"] --> SPEC
SPEC -->|"aprueba una persona"| PLAN["Plan y tareas"]
PLAN -->|"aprueba una persona"| COD["Código y pruebas<br/>pruebas primero"]
COD --> VER["Verificación<br/>converge o no"]
VER --> HEC["Hecha y TRACEABILITY.md"]
AGT["AGENTS.md<br/>reglas para personas y agentes"] -.-> SPEC
AGT -.-> COD
```

| Artefacto | Qué contiene | Quién lo cambia |
| :--- | :--- | :--- |
| Normativa oficial | Lo obligatorio (LAG, DL 1375, DS 016-2024-JUS) | Nadie del equipo; se interpreta y se cita |
| **ERS v1.1** | Qué debe hacer: RF, RN, RNF, CU, límites del sistema (2.5) y pendientes | Equipo, validado con la Dirección |
| **Documento de Arquitectura** | Cómo se organiza: decisiones AD, módulos, capas, despliegue y seguridad | Equipo, con decisión registrada |
| **Esquema SQL de referencia** | Modelo de datos y reglas en la base | Equipo; las migraciones lo derivan |
| `AGENTS.md` | Reglas obligatorias para personas y agentes de IA | Equipo, con aprobación humana |
| **Spec** (`specs/<spec>/spec.md`) | Contrato de una funcionalidad: requisitos y criterios EARS | La IA propone, una persona aprueba |
| **Plan y tareas** | Cómo se construye: piezas por capa, decisiones locales, tareas atómicas | La IA propone, una persona aprueba |
| Código y pruebas | La demostración | La IA y el equipo, bajo las reglas |

**Precedencia si hay conflicto:** normativa oficial, ERS, arquitectura, spec, plan, código (RC-08). Si el código y la spec difieren, uno de los dos está mal y se decide; no se «ajusta en silencio». **Si el comportamiento cambia, la spec vuelve a Draft** y repite las puertas.

#### 10.5.2 Ciclo de una spec y puertas humanas

```mermaid
stateDiagram-v2
direction LR
[*] --> Draft : redactar la spec
Draft --> Draft : aclarar y auditar
Draft --> Approved : aprueba una persona
Approved --> Planned : plan y tareas, aprueba una persona
Planned --> InProgress : implementar
InProgress --> InProgress : tarea, prueba y commit
InProgress --> Done : la verificación converge
Approved --> Draft : cambia el comportamiento
Planned --> Draft : cambia el comportamiento
InProgress --> Draft : cambia el comportamiento
```

| Paso | Entrega | Quién decide |
| :---: | :--- | :--- |
| 1 | Borrador de la spec desde el ERS, la arquitectura y el esquema | IA |
| 2 | Spec sin ambigüedad ni preguntas abiertas, con **segunda opinión independiente** (agente de solo lectura en contexto aislado) | IA y persona (respuestas) |
| 3 | **Spec aprobada** (`aprobado_por`, `aprobado_en`) | **Persona** |
| 4 | Plan y decisiones locales; revisión de arquitectura y de seguridad y privacidad | IA |
| 5 | Tareas atómicas, con cada criterio cubierto | IA |
| 6 | **Plan aprobado** (`plan_aprobado_en`) | **Persona** |
| 7 | Código y pruebas: una tarea, una prueba y un commit pequeño a la vez; **pruebas primero** | IA, con revisión |
| 8 | `verificacion.md` con `Resultado: Converge` | IA, con reglas fijas |
| 9 | CHANGELOG, bitácora de sesiones y `TRACEABILITY.md` al día | IA |

- «Persona» es el integrante del equipo designado como responsable de esa spec.
- **Las decisiones de negocio no las toma la IA ni el equipo solo.** Un valor, plazo o texto legal que no esté en el ERS queda como **parámetro configurable** o como **pendiente** (P-xx del ERS) hasta que la Dirección lo defina. La IA pregunta; no supone.
- Las specs que tocan datos personales (EST, MAT, PRI, AUD, IDE) pasan además por **revisión de seguridad y privacidad** antes de aprobar el plan.

#### 10.5.3 Specs previstas y orden de trabajo

Las specs y los requisitos que cubren están en el [ERS v1.1, Anexo B](Documento-de-Analisis-ERS-v1.1.md#anexo-b-requerimientos-por-módulo-y-especificación-prevista). Orden propuesto, según dependencias:

| Fase | Specs (prefijo) | Depende de | Iteración |
| :---: | :--- | :--- | :---: |
| 0 | Marco SDD: `AGENTS.md`, plantillas, `SpecCheck`, CI y esqueleto de la solución | — | — |
| 1 | `transversal-auditoria` (AUD), luego `identidad-seguridad` (IDE) y `parametros-institucionales` (PAR) | AUD no depende de nadie; todas registran en bitácora | 1 |
| 2 | `catalogo-academico` (CAT), luego `periodos-ofertas` (OFE) | PAR, AUD | 1 |
| 3 | `estudiantes` (EST), luego `matricula-registro` (MAT) | CAT, OFE, IDE, PAR, AUD | 1 |
| 4 | `docs-constancia` (CST), `docs-reportes` (REP), `cumplimiento-privacidad` (PRI) y `web-base` (WEB) | MAT; WEB espera los prototipos de Figma | 1 (parcial) |
| 5 | `matricula-ratificacion-licencia` (RAT), `matricula-convalidacion` (CON), `matricula-becas` (BEC) | MAT | 2 |
| 6 | `docs-archivos-avanza` (AVZ), `transversal-alertas` (ALE) y los criterios pendientes de CST, REP y PRI | MAT, CAT, plantillas de AVANZA | 2 |
| 7 | Retención y depuración (PRI, RF-38) y mejoras | — | 3 |

- `operacion-despliegue` (OPS) **no depende de las demás** y puede avanzar en paralelo desde la fase 1 (respaldos, `keepalive`, infraestructura como código); debe estar lista antes de operar con datos reales.
- Algunas specs cruzan iteraciones (por ejemplo, CST cubre RF-16 en la iteración 1 y RF-28 en la 2). **Propuesta:** cada criterio lleva su iteración y `SpecCheck` exige prueba solo para los de la iteración en curso; la spec llega a Done al cerrarse su última iteración. Se decide al adaptar la plantilla.

#### 10.5.4 `AGENTS.md`: reglas obligatorias

Se redacta en la fase 0 y se aprueba como cualquier otro documento. Contenido mínimo propuesto:

1. **Contexto que se lee primero:** este documento, el ERS v1.1 (con los **límites del sistema**, 1.5) y la spec en curso. Lo que está «Fuera» no se especifica ni se implementa.
2. **Precedencia** (10.5.1) y **identificadores estables**: nunca se renumera ni se reutiliza un código del ERS.
3. **Sin código de producción sin spec aprobada y plan aprobado.** Ningún criterio sin prueba; la prueba se escribe primero y se marca con `[Trait("Criterio", "AC-MAT-01")]`.
4. **No suponer reglas de negocio.** Si el ERS no lo dice, se pregunta y, si sigue abierto, se vuelve parámetro o pendiente.
5. **Datos reales: prohibidos** en indicaciones, archivos, pruebas, registros, capturas y repositorio (10.5.5). Solo datos sintéticos.
6. **Seguridad por defecto:** denegar por defecto; autorización en cada punto de entrada; consultas parametrizadas; codificación de salida; **sin datos personales en registros**; ASVS 5.0 nivel 2 como criterio (AD-13).
7. **Capas:** el dominio no conoce la base, la web ni las librerías de PDF; ninguna página accede al `DbContext` (6.3). Las pruebas de arquitectura deben pasar.
8. **Dependencias:** verificar que el paquete existe, su licencia y su mantenimiento antes de agregarlo; versiones fijadas; una dependencia nueva exige decisión registrada.
9. **Citas normativas:** no se cita una norma sin fuente en `Investigacion/` o `Contexto/Normativa`; lo no verificado se marca «por verificar».
10. **Lenguaje:** vocabulario oficial (AD-25: programa de estudios, módulo formativo, unidad didáctica, ciclo, constancia de estudios); documentos e interfaz en español.
11. **Cambios pequeños:** una tarea, un commit; el pie del mensaje indica si fue asistido por IA.
12. **Definición de terminado** (10.5.7).

#### 10.5.5 IA y datos personales (AD-36)

Las herramientas de IA reciben texto del proyecto y lo procesan fuera del equipo. Por eso se separa lo que puede entrar de lo que no:

| Contenido | ¿Puede entrar a una herramienta de IA? |
| :--- | :---: |
| ERS, arquitectura, specs, código, normativa publicada, estructura de la base (sin filas) | Sí |
| Datos sintéticos claramente ficticios (por ejemplo, apellido «PRUEBA», nombres «SINTÉTICO») | Sí |
| Plantillas de AVANZA y la ficha **en blanco** | Sí |
| **Datos reales** de estudiantes, docentes o personal; capturas, volcados, respaldos o bitácoras de producción; la ficha llenada | **No** |
| **Credenciales**, claves, tokens, cadenas de conexión, secretos de Oracle o Cloudflare, usuario o contraseña de AVANZA | **No** |
| Contenido externo (páginas, PDF, correos) | Se lee como **dato**; las instrucciones que contenga no se ejecutan |

**Por qué.** Enviar datos personales reales a un proveedor de IA equivaldría a que un tercero los trate y, si está fuera del Perú, a un posible flujo transfronterizo (DS 016-2024-JUS, arts. 18 a 21 y 28 a 33). **Es una interpretación del equipo**: no se encontró criterio oficial sobre herramientas de IA; se evita por diseño en lugar de depender de esa interpretación.

**Controles propuestos**

- El agente trabaja **sin acceso a producción**: ni conexión a la base real, ni respaldos, ni secretos. Los entornos de desarrollo y pruebas usan **datos sintéticos** (AD-16).
- Repositorio **privado**; `gitleaks` en CI y en el commit; archivos de secretos fuera del repositorio (`.env.example` sin valores).
- Solo **herramientas de IA aprobadas por el equipo**. Para cada una se registra qué retiene y si usa el contenido para entrenar, y se desactiva lo que se pueda (Q26).
- El incumplimiento se trata como **incidente** (9.6): se registra, se evalúa y se contiene.

#### 10.5.6 Calidad de lo producido con IA

- **Pruebas primero:** la prueba falla antes y pasa después. La IA no «se califica a sí misma»: la revisión independiente la hace otro agente en contexto aislado y de solo lectura, y la decisión final es humana.
- **Validaciones en capas:** estructura y cobertura de las specs (`SpecCheck`); dependencias entre capas (pruebas de arquitectura); compilación estricta (`-warnaserror`); seguridad (CodeQL, gitleaks, Trivy); accesibilidad (axe); cobertura de Dominio y Aplicación ≥ 85 % (RNF-10).
- **Riesgos conocidos de la IA y su control:** paquetes inexistentes o con licencia dudosa (regla 8, R-12), normas inventadas (regla 9), reglas de negocio supuestas (regla 4) y fugas de datos (10.5.5).
- **Transparencia:** los commits asistidos por IA lo indican; la titularidad y la licencia del software resultante se resuelven en Q9.

#### 10.5.7 Reutilización del marco del equipo y definición de terminado

El equipo ya tiene un marco SDD en la carpeta `DocumentacionEjemplo` (**solo de referencia; no se modificó**). La copia y adaptación se hará en la fase 0.

| Pieza del marco | Adaptación para este proyecto |
| :--- | :--- |
| `tools/SpecCheck` (validador) | Prefijos propios (AUD, IDE, PAR, CAT, OFE, EST, MAT, RAT, CON, BEC, CST, REP, AVZ, PRI, ALE, OPS, WEB); orígenes RF, RN, RNF, RNF-LEG, CU y RC leídos del ERS; iteración por criterio |
| Skills de ciclo (`spec-new`, `spec-clarify`, `spec-plan`, `spec-tasks`, `spec-implement`, `spec-verify`, `progress-log`) | Español y vocabulario oficial |
| Skills y agentes de revisión (`arch-review`, `security-review`, `spec-auditor`, `arch-reviewer`, `security-reviewer`) | Un monolito modular (no varios servicios); se agregan privacidad (AD-36) y el marco legal peruano |
| `dotnet-feature` | Razor Pages, HTMX y EF Core |
| `ui-screen`, `ui-review` | Esperan los prototipos de Figma; no se usan antes |
| CI | Se agregan gitleaks, CodeQL y Trivy |

Las skills externas (por ejemplo, `dotnet/skills`) se **recomiendan, no se instalan** automáticamente: cambian el comportamiento del agente y conviene revisarlas antes.

**Una tarea está terminada** cuando compila sin advertencias, su prueba falló antes y pasa ahora, las pruebas de arquitectura y `SpecCheck` pasan, la tarea está marcada y hay un commit pequeño. **Una funcionalidad está terminada** cuando todas sus tareas están marcadas, cada criterio está nombrado en una prueba, `verificacion.md` dice `Converge`, la spec está en Done y `TRACEABILITY.md` y la bitácora están al día.

---

## 11. Riesgos y decisiones abiertas

### 11.1 Riesgos

| ID | Riesgo | Prob. | Impacto | Mitigación |
| :--- | :--- | :---: | :---: | :--- |
| R-01 | Oracle **reclama o apaga** una VM por inactividad | M | A | `keepalive`, trabajo real, latido externo, infraestructura como código, respaldos fuera de Oracle |
| R-02 | **Abuso interno** (consultas o exportaciones indebidas) | M | A | Bitácora de lecturas y exportaciones, mínimo privilegio, enmascarar documento en listados, revisión semestral |
| R-03 | **Falsificación de constancias** | M | A | Código único y verificación QR con límite de tasa |
| R-04 | **Pérdida de datos** por falla o ransomware | B | A | Respaldo cifrado en dos lugares, restauración probada |
| R-05 | **Sin Internet** en el CETPRO | M | M | Contingencia en papel y modo degradado local |
| R-06 | **Incumplimiento legal** (ODP, registro, flujo transfronterizo) | A | A | Puertas de salida (AD-31) antes de operar con datos reales |
| R-07 | **Reglas mal entendidas** por no haber Reglamento Institucional | A | M | Parámetros configurables y validación con la Dirección |
| R-08 | **Pérdida de la cuenta** de Oracle | B | A | Dos administradores, correo institucional neutro, MFA |
| R-09 | **Cuotas de Oracle cambian** | M | M | Diseño dentro del límite inferior documentado; stack portable |
| R-10 | **Fuga por una vulnerabilidad** de la aplicación | B | A | ASVS L2, pruebas de seguridad, BD privada, cuenta de BD de mínimo privilegio |
| R-11 | **El registro de notas** sigue digitándose a mano en AVANZA | A | M | Se documenta como fuera de alcance; posible segunda fase |
| R-12 | **Licencias** de QuestPDF o ClosedXML no aptas | B | M | Revisarlas antes de integrarlas; alternativa abierta |
| R-13 | **Dependencia de un proceso externo**: la carga en AVANZA queda fuera del sistema y la hace el CETPRO a su manera | M | M | El sistema solo genera archivos y alertas; no asume quién carga ni guarda credenciales de AVANZA (AD-33); el procedimiento del CETPRO se documenta aparte |
| R-14 | **Cambian las plantillas o reglas de AVANZA** (el manual ya tuvo versiones y casuística de errores) | M | M | Mapeo de columnas configurable, validación previa y pruebas con las plantillas vigentes |
| R-15 | **Reportar tarde** a AVANZA (infracción grave para el CETPRO) | M | A | **Alerta del plazo** de un mes tras el inicio del periodo para los roles configurados (atendible o descartable) |
| R-16 | **Nombres que RENIEC no valida** en AVANZA (archivo de errores) | M | B | Capturar nombres y apellidos tal como figuran en el documento; avisar diferencias frecuentes; consulta RENIEC por PIDE como mejora futura |
| R-17 | **Datos personales o secretos llegan a una herramienta de IA o al repositorio** | M | A | AD-36: datos sintéticos, agente sin acceso a producción ni a secretos, `gitleaks`, repositorio privado, herramientas aprobadas, tratamiento como incidente |
| R-18 | **Código o specs generados por IA con defectos**, dependencias inexistentes o licencias dudosas, o normas citadas sin fuente | M | M | Pruebas primero, revisión independiente, pruebas de arquitectura y de seguridad, verificación de paquetes y licencias, puertas humanas (AD-35) |
| R-19 | **Las specs asumen límites que el ERS no tiene** (por ejemplo, una integración con AVANZA) o se desfasan del ERS | M | M | Límites del sistema obligatorios en `AGENTS.md` (1.5), identificadores estables, `SpecCheck` contra el ERS, la spec vuelve a Draft si cambia el comportamiento |

### 11.2 Preguntas abiertas que condicionan el diseño

Detalle completo en el [informe 05](../Investigacion/05-decisiones-propuestas-y-preguntas.md#7-preguntas-abiertas).

| # | Pregunta | Bloquea |
| :--- | :--- | :--- |
| Q1 | **Resuelta**: el **CETPRO** es el responsable y el equipo técnico, el encargado. Falta **formalizarlo** (resolución directoral y acuerdo de encargo) | Puertas de salida |
| Q2 | **No bloquea**: el CETPRO designa su propio ODP | — |
| Q7 | **Retención** de fichas y constancias | Parámetro de retención |
| Q8 | ¿La web institucional debe estar en **gob.pe**? | Sistema 2 |
| Q9 | **Titularidad y licencia** del software | Entrega |
| Q13 | ¿Hay estudiantes **extranjeros** y con **NEE**? | Situación específica |
| Q21 | Manual de AVANZA **leído**. **Pendiente**: las plantillas Excel (estudiantes y módulos); el equipo las conseguirá. No bloquea esta versión: el mapeo de columnas es configurable | Formato exacto de exportación |
| Q22 | **Resuelta**: Ley 29733 leída (copia SPIJ) | — |
| Q24 | **Cloudflare gratuito decidido**; pendiente **dominio y registrador** | AD-06 |
| Q25 | ¿Quién ejercerá el rol **Administrador** (usuarios y parámetros)? Propuesta: una persona de apoyo técnico, sin acceso a datos de estudiantes por defecto | Permisos del rol |
| Q26 | ¿Qué **herramientas de IA** usará el equipo y con qué cuenta o plan? Hay que revisar qué retienen, si entrenan con el contenido y dónde lo procesan | AD-36, `AGENTS.md` |
| Q27 | ¿La propuesta en **.docx** debe seguir el formato de «Informe N.°» de la UNSCH o el de la propuesta de referencia (`Propuesta_Librería.pdf`)? | Entrega de la propuesta |

---

## 12. Trazabilidad

Del [ERS v1.1](Documento-de-Analisis-ERS-v1.1.md) a módulos, decisiones y atributos de calidad. **Los identificadores del ERS no se renumeran**; la correspondencia con las especificaciones está en el Anexo B del ERS y se mantendrá en `TRACEABILITY.md` (sección 10.5).

| Requisito (ERS v1.1) | Módulo | Decisión o parámetro | Atributo |
| :--- | :--- | :--- | :--- |
| RF-01 Registrar matrícula | M4 | AD-18, AD-28, AD-30 | AC-01 |
| RF-02 Validar edad mínima | M4, M2 | AD-19, parámetro `edad_minima` | AC-01, AC-07 |
| RF-03 Programa, periodo, turno y módulo | M3, M4 | AD-20, AD-28 | AC-01 |
| RF-04 Tipo de ingreso | M4 | AD-21 | AC-01 |
| RF-05 Convalidación | M4 | AD-22, parámetro `convalidacion_similitud_minima` | AC-01 |
| RF-06 Becas y exoneraciones | M4, M2 | AD-10, parámetro `beca_porcentaje_maximo` | AC-01 |
| RF-07 Derecho de inscripción | M4 | parámetro `derecho_inscripcion_monto` | AC-01 |
| RF-08 Editar y anular con trazabilidad | M4, M6 | AD-12, AD-21 | AC-02 |
| RF-09 a RF-11 Programas, módulos, familias | M3 | AD-25, AD-32 | AC-06 |
| RF-12 Matriculados por programa, módulo, periodo y turno | M5 | AD-24 | AC-04 |
| RF-16 Constancia con código QR | M5 | AD-11, AD-15 | AC-02, AC-04 |
| RF-17 Nómina de matriculados | M5 | AD-24 | AC-04 |
| RF-19, RF-20, RF-29, RF-30, RF-39 Acceso, roles y usuarios | M1 | AD-04, AD-33 | AC-02 |
| RF-21 Ratificación; RF-22 y RF-23 Licencia y reincorporación | M4 | AD-20, AD-21 | AC-01 |
| RF-24 Periodos y ofertas; RF-25 Plan de estudios y unidades | M3 | AD-28, AD-32 | AC-06 |
| RF-26 Anexo 1; RF-27 Archivos para AVANZA | M5 | AD-24, AD-32, sección 6.8 | AC-01 |
| RF-28 Verificación pública de la constancia | M5 | AD-11 | AC-02 |
| RF-32 Parámetros institucionales | M2 | AD-27 | AC-07 |
| RF-33 Alertas y recordatorios | M6 | AD-34, parámetros de alerta | AC-01 |
| RF-34 Bitácora | M6 | AD-12 | AC-02 |
| RF-35 a RF-38 Aviso, derechos, incidentes y retención | M6 | AD-10, AD-31 | AC-02 |
| RF-40 Situación específica | M4 | AD-29 | AC-02 |
| RF-41 a RF-43 Búsqueda, borrador y requisitos | M4 | AD-28; informe 04 | AC-05 |
| RN-01 Edad mínima | M4, M2 | AD-19 | AC-01 |
| RN-02 Documento y derecho de inscripción | M4 | AD-18 | AC-01 |
| RN-03 Oferta (programas y ciclos) | M3 | AD-20, AD-25 | AC-06 |
| RN-04 Cupo referencial | M2, M3 | parámetro `cupo_referencial` | AC-07 |
| RN-05 Reingreso, traslado y convalidación | M4 | AD-21, AD-22 | AC-01 |
| RN-06 Becas hasta el tope | M4, M2 | parámetro `beca_porcentaje_maximo` | AC-01 |
| RN-07 Acceso restringido con MFA | M1 | AD-04 | AC-02 |
| RN-08 Solo red local | **Retirada** | Reemplazada por RC-02 y RNF-08 | — |
| RN-09 Código de matrícula = documento | M4 | AD-18 | AC-01 |
| RN-10 Ratificación por periodo | M4 | AD-20 | AC-01 |
| RN-11 Licencia y reincorporación | M4 | AD-21 | AC-01 |
| RN-12 Convalidación por resolución directoral | M4 | AD-22 | AC-01 |
| RN-13 Una matrícula vigente por programa y periodo | M4 | AD-28; índice único parcial (7.4) | AC-01 |
| RN-14 Ciclo Técnico exige primaria | M4 | AD-23 | AC-01 |
| RN-15 Anular exige motivo; nunca se borra | M4, M6 | AD-12, AD-21 | AC-02 |
| RN-16 Plazo de registro en AVANZA y alerta | M6 | AD-24, AD-34 | AC-01 |
| RN-17 Datos solo para la función educativa | M6 | AD-10 | AC-02 |
| RNF-01 Rendimiento | Todos | — | AC-04 |
| RNF-02 Web en Oracle con Internet | Despliegue | RC-02, AD-06, sección 8.7 | AC-03 |
| RNF-03 Concurrencia de 5 usuarios | Todos | — | AC-04 |
| RNF-04 Solo escritorio | Web | AD-02 | AC-08 |
| RNF-05 Seguridad de acceso | M1, M6 | AD-04, AD-12 | AC-02 |
| RNF-06 Respaldo | Despliegue | AD-08 | AC-03 |
| RNF-07 Usabilidad | Web | AD-02 | AC-05 |
| RNF-08 Continuidad y anti-reclamación | Despliegue | AD-09, sección 8.7 | AC-03 |
| RNF-09 Portabilidad | Despliegue | AD-07 | AC-09 |
| RNF-10 Mantenibilidad y pruebas | Solución | AD-01, AD-35 | AC-06 |
| RNF-11 Configurabilidad | M2 | AD-27 | AC-07 |
| RNF-12 Auditabilidad | M6 | AD-12 | AC-02 |
| RNF-13 Costo cero | Despliegue | RC-01, sección 8.8 | — |
| RNF-14 Privacidad desde el diseño | M6 | AD-10 | AC-02 |
| RNF-15 ASVS 5.0 nivel 2 y Top 10:2025 | Transversal | AD-13 | AC-02 |
| RNF-16 Accesibilidad WCAG 2.2 AA | Web | sección 10.4 | AC-05 |
| RNF-17 Observabilidad | Despliegue | sección 10.2 | AC-03 |
| RNF-18 SDD asistido por IA, sin datos reales | Proceso | AD-35, AD-36 | AC-06 |
| RNF-LEG-01 a RNF-LEG-19 | M6 y transversal | AD-10, AD-12, AD-31 | AC-02 |
| Retirados: RF-13, RF-14, RF-15, RF-18, CU-04, CU-07 y la entidad Nota | — | Fuera de alcance (AD-26) | — |

---

## 13. Anexos

### Anexo A. Cómo se repartirá este documento en `docs/`

Se define **tras consolidar este documento**, siguiendo la estructura del ejemplo del equipo. Una correspondencia tentativa:

| Sección de este documento | Destino tentativo |
| :--- | :--- |
| 2, 3 | `01-analisis-de-sistema` (necesidad, requisitos, atributos de calidad, marco legal) |
| 3.1, 5 | `02-arquitectura-de-software` (drivers, decisiones, estilo, despliegue, tácticas, presupuesto de recursos) |
| 4, 6.3, 6.4, 7 | `03-diseno-de-software` (Clean Architecture, módulos y contratos, modelo de datos, estados) |
| 6.1 a 6.3 | `04-modelo-c4` |
| 9 | `05-seguridad` |
| 10 (incluye 10.5 SDD) | `07-proceso-de-desarrollo` (flujo SDD, estrategia de pruebas, convenciones) |
| Informe 04 | `06-experiencia-de-usuario` (cuando lleguen los prototipos) |

### Anexo B. Documentos de apoyo

- [Documento de Análisis de Requerimientos (ERS) v1.1](Documento-de-Analisis-ERS-v1.1.md): requisitos con identificadores estables, límites del sistema y mapeo a specs.
- [Esquema SQL v1.1](../db/esquema_matricula_cetpro_v1.1.sql), sus [pruebas de humo](../db/pruebas_esquema_v1.1.sql) y el [README de db](../db/README.md) (aún sin ejecutar en PostgreSQL).
- [Investigación previa a la arquitectura](../Investigacion/README.md): marco legal, seguridad y estándares, despliegue, experiencia de usuario, decisiones y parámetros.
- [Scripts `keepalive`](../Investigacion/anexos/keepalive/README.md).
- Textos oficiales aportados por el equipo en `Contexto/Normativa`.
