# Decisiones arquitectónicas

Cada decisión indica el driver que la motiva ([drivers arquitectónicos](01-drivers-arquitectonicos.md)), por qué se eligió y qué alternativa se descartó. Las decisiones de despliegue (AD-05 a AD-09, AD-14) se desarrollan con más detalle en [despliegue](05-despliegue.md).

**Estado:** todas fueron **aceptadas por el equipo** al revisar la arquitectura v0.4. Las que dependen de un dato pendiente lo indican en su nota.

## 1. Resumen de decisiones

| ID | Decisión | Alternativa descartada | Drivers |
| :--- | :--- | :--- | :--- |
| **AD-01** | **Monolito modular** con Clean Architecture (Domain, Application, Infrastructure, Web), módulos como carpetas verticales y **pruebas de arquitectura**. | Microservicios; capas sin reglas. | DA-04, DA-12 |
| **AD-02** | **ASP.NET Core 10** (LTS hasta 14-nov-2028), **Razor Pages + HTMX**, CSS ligero. | SPA o Blazor. | DA-04, DA-08 |
| **AD-03** | **PostgreSQL 18** (soporte hasta nov-2030), **EF Core 10 + Npgsql**; reglas críticas también en la BD. | PG 19; reglas solo en la aplicación. | DA-02, DA-10 |
| **AD-04** | **ASP.NET Core Identity**, roles Administrador, Matrícula y Directivo, **MFA TOTP**, sin autorregistro; muestra último ingreso e intentos fallidos (ISO 27002, 8.5). | Tabla `usuario` propia. | DA-06 |
| **AD-05** | **Subred privada** para la BD y **OCI Bastion** para administrar. | BD con IP pública. | DA-06, DA-07 |
| **AD-06** | **Cloudflare, plan gratuito** (gestión de tráfico, DNS, TLS, seguridad, Tunnel) y **Caddy** detrás. **Dominio y registrador pendientes** (P-02). | Subdominio gratuito. | DA-05, DA-06 |
| **AD-07** | **Docker Compose** por VM, imágenes **multi-arquitectura**, CI/CD gratuito, **OpenTofu + cloud-init**. | Despliegue manual. | DA-04, DA-11, DA-12 |
| **AD-08** | **Respaldo diario cifrado** a Object Storage y **copia en el CETPRO**, **clave custodiada por el CETPRO**, copia de la bitácora, prueba de restauración. | Solo instantáneas. | DA-05, DA-09 |
| **AD-09** | **Estrategia anti-reclamación** en capas con **`keepalive` calibrado**. | Pagar; aceptar el riesgo. | DA-05 |
| **AD-10** | **Privacidad desde el diseño**: sin copia del DNI, sin evidencia socioeconómica ni documentos de discapacidad, aviso con los diez elementos del art. 6, solicitudes de derechos, retención configurable. | Guardar todo. | DA-01 |
| **AD-11** | **Constancia con código único y verificación por QR** mínima y con límite de tasa. | Sin verificación. | DA-06 |
| **AD-12** | **Bitácora de solo inserción**: sesión, lecturas, modificaciones, eliminaciones, importaciones y exportaciones; **≥ 2 años**. | Auditar solo escrituras. | DA-01, DA-10 |
| **AD-13** | **ASVS 5.0 nivel 2** como criterio en los capítulos de mayor riesgo (nivel 1 en el resto, como en la [lista de controles](../05-seguridad/02-controles-asvs.md)); **Top 10:2025** como lista de amenazas. | Solo L1. | DA-06 |
| **AD-14** | **Sitio institucional estático** en su propia VM, sin ruta a la BD. | Sitio dinámico con BD. | DA-07 |
| **AD-15** | **QuestPDF** (PDF) y **ClosedXML** (Excel) con celdas saneadas; **licencias por revisar**. | Otras. | DA-04 |
| **AD-16** | **Entornos separados**, **datos sintéticos** y etiqueta visible del entorno. | Datos reales en pruebas. | DA-16 |
| **AD-17** | Hora **America/Lima** (UTC en BD); **identificadores internos opacos** en URL, **nunca el documento**. | URL con DNI. | DA-06 |
| **AD-18** | **Documento de identidad** con tipo (DNI, CE, pasaporte, PTP); **código de matrícula = número de documento**; apellido paterno y materno, nombres, fecha de nacimiento y sexo por separado, como en RENIEC y AVANZA. | Correlativo propio. | DA-02 |
| **AD-19** | **Edad mínima configurable** (valor inicial 16; piso nacional 14); se guarda el valor aplicado. | Constante. | DA-02, DA-03 |
| **AD-20** | **Periodo de 18 semanas** con **ratificación por periodo**; ciclos Auxiliar Técnico y Técnico. | Periodo anual. | DA-02 |
| **AD-21** | Estados **VIGENTE, ANULADA, RETIRADA, LICENCIA**; tipos **NUEVO, RATIFICACIÓN, REINCORPORACIÓN, TRASLADADO, RETIRADO ANTERIORMENTE**. | Estados del Informe 004. | DA-02 |
| **AD-22** | **Convalidación** con tipo, **resolución directoral**, justificación, ruta complementaria y similitud. | Solo «módulos convalidados». | DA-02 |
| **AD-23** | **Grado de instrucción** y verificación del certificado de estudios para el ciclo Técnico. | Sin control. | DA-02 |
| **AD-24** | **Exportación para AVANZA** en el formato de sus plantillas Excel (estudiantes y módulos, que se descargan con el periodo lectivo y el programa ya elegidos), más el **Anexo 1 en PDF** y la **nómina**; filtrables por programa, módulo, periodo y turno; **mapeo de columnas configurable**; **validación previa** y **alerta del plazo**. | Solo nómina. | DA-02, DA-13 |
| **AD-25** | Lenguaje oficial: **programa de estudios, módulo formativo, unidad didáctica, ciclo**; «constancia de estudios». | «Especialidad». | DA-02 |
| **AD-26** | **Alcance legal explícito**: solo Registro de Matrícula. | Implícito. | DA-02 |
| **AD-27** | **Parámetros institucionales versionados** con vigencia y auditoría. | Constantes. | DA-03 |
| **AD-28** | **Matrícula por oferta** (programa + periodo lectivo + turno) que incluye **el o los módulos cursados** y su **periodo académico**; las **unidades se derivan del módulo** y las excepciones se registran aparte. | Matrícula sin módulo; por unidad didáctica. | DA-02 |
| **AD-29** | **Situación específica** (PIR, Transitabilidad, MOT, Discapacidad, otras) como catálogo **restringido**, sin documentos. | Texto libre. | DA-01, DA-06 |
| **AD-30** | **Dirección, ubigeo, correo, teléfono y celular**: AVANZA los exige; el sistema los solicita y **avisa antes de exportar si faltan**; son configurables y la finalidad consta en el aviso (base: función pública, Ley art. 14.1). | Opcionales sin control. | DA-02 |
| **AD-31** | **Puertas de salida a producción**: ODP designado, banco inscrito, flujo transfronterizo comunicado, documento de seguridad con fecha cierta, acuerdo de encargo y confidencialidad, restauración probada. | Desplegar sin trámites. | DA-01 |
| **AD-32** | **Catálogo alineado con AVANZA**: el plan guarda la **resolución de autorización** (tipo, número, año); se distinguen **periodo lectivo** y **periodo académico**; módulos y unidades se cargan antes que los estudiantes. | Catálogo libre. | DA-02 |
| **AD-33** | **Atribuciones por rol conforme al ERS y a la forma de trabajo del CETPRO**: Personal de matrícula, Directivo y Administrador (sin acceso a datos de estudiantes por defecto). Permisos granulares auditados. El sistema **no impone procesos externos** ni guarda credenciales de AVANZA. | Un solo rol; imponer quién carga. | DA-14 |
| **AD-34** | **Alertas y recordatorios dentro del sistema**: panel y contador por rol, parametrizables; ciclo Activa → Atendida o Descartada; **sin correo ni mensajería** en el MVP. | Correo o WhatsApp. | DA-13 |
| **AD-35** | **Desarrollo con SDD asistido por IA**: la spec manda y el código la demuestra; `AGENTS.md` como constitución; criterios EARS `AC-<MÓDULO>-<NN>` trazados a pruebas; dos puertas humanas; `SpecCheck` y pruebas de arquitectura en CI; reutilizar el marco del equipo. | Pedir código a la IA sin spec. | DA-15 |
| **AD-36** | **La IA nunca ve datos personales reales** (ni en indicaciones, archivos, pruebas, registros, capturas ni repositorio); solo datos sintéticos; el agente no accede a producción ni a secretos; **herramientas aprobadas por el equipo** (principalmente Claude; otras de forma opcional y aclarada antes al agente), con retención y entrenamiento revisados; el contenido externo es **dato, no instrucción**. | Probar con datos «anonimizados». | DA-16 |

## 2. Decisiones en detalle

**Sobre AD-01 y AD-02.** Hay cinco usuarios y un equipo pequeño: dividir en servicios sumaría coordinación, memoria y puntos de falla sin ventaja de escala. El sistema es un monolito modular con seis módulos (M1 a M6) que se comunican solo por contratos de la capa de Aplicación. El renderizado en servidor con HTMX mantiene la interfaz simple, coherente con «HTML, CSS y JS» y sin SPA.

**Sobre AD-03 y la doble defensa.** Las reglas críticas (edad mínima, matrícula única, tope de beca, similitud de convalidación, bitácora inmutable) se validan en el dominio **y** como restricciones o disparadores en PostgreSQL. La aplicación entrega al motor el usuario y el origen mediante `SET LOCAL cetpro.usuario_id` y `cetpro.ip_origen` para que la auditoría automática sepa quién actúa. El esquema de referencia fue probado en PostgreSQL por el equipo (0 comprobaciones fallidas).

**Sobre AD-06 y el dominio.** El equipo comprará el dominio y lo asumirá (único costo). Cloudflare gratuito gestiona DNS, TLS y tráfico; Caddy detrás da HTTPS al origen. Si el equipo prefiere no depender de Cloudflare, Caddy queda como respaldo.

**Sobre AD-08 y AD-09.** Oracle puede reclamar instancias Always Free inactivas (siete días con CPU, red y memoria bajo 20 %). La estrategia es: `keepalive` calibrado, trabajo real programado (respaldos, pruebas de restauración), latido externo, infraestructura como código y respaldo cifrado en dos lugares. **No se pasa a Pay As You Go**: no figura como exención en la documentación oficial y la cuenta gratuita no puede generar cargos.

**Sobre AD-24 y el límite de AVANZA.** AVANZA no ofrece API. El sistema **genera archivos**; la carga es manual y queda fuera. No hay tabla de cargas ni credenciales de AVANZA. El mapeo de columnas es un parámetro y se ajusta cuando se consigan las plantillas (P-01).

**Sobre AD-27.** Un parámetro con valor `null` significa «por definir» y leerlo produce un error explícito, nunca un valor inventado. Parámetros por definir: `plazo_reserva_licencia_dias`, `derecho_inscripcion_monto`, `retencion_matriculas_anios`, `oficial_datos` y el `codigo_modular` y el `distrito` de `institucion`. El catálogo completo está en el [modelo de datos, sección 12](../03-diseno-de-software/05-modelo-de-datos.md#12-catálogo-de-parámetros-institucionales).

**Sobre AD-35 y AD-36.** Ver [flujo SDD](../07-proceso-de-desarrollo/01-flujo-sdd.md) y [seguridad del desarrollo con IA](../05-seguridad/06-seguridad-del-desarrollo-con-ia.md).
