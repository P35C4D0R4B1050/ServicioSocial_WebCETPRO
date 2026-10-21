# Mapeo a estándares

Relaciona los controles del Sistema de Matrícula con los estándares de referencia (RNF-15). Es una **tabla de trazabilidad**, no una declaración de conformidad ni una certificación. Los nombres de las categorías se tomaron de las publicaciones de OWASP, NIST e ISO; antes de citar números exactos de requisito en un plan, se verifican contra el texto del estándar.

## 1. OWASP Top 10:2025

| Categoría | Cómo se atiende | Dónde |
| :--- | :--- | :--- |
| **A01 Control de acceso roto** | Permiso por caso de uso; denegar por defecto; identificadores opacos. | CTL-24 a CTL-27; AM-12 |
| **A02 Configuración incorrecta** | Cabeceras, puertos cerrados, contenedores sin privilegios, entornos separados. | CTL-05, CTL-31, CTL-32; [operación segura](07-operacion-segura.md) |
| **A03 Fallas en la cadena de suministro** | Versiones fijas, escaneo, SBOM, Dependabot, acciones fijadas por *hash*. | CTL-37; AM-08, AM-18 |
| **A04 Fallas criptográficas** | TLS 1.2+; resumen de contraseñas robusto; respaldos cifrados con clave del CETPRO. | CTL-16, CTL-28 a CTL-30 |
| **A05 Inyección** | EF Core con parámetros; codificación de salida; saneo de celdas de Excel. | CTL-02, CTL-03, CTL-12; AM-07, AM-15 |
| **A06 Diseño inseguro** | Modelo de amenazas; anulación con motivo; separación de funciones; límites de tasa; doble defensa. | [modelo de amenazas](01-modelo-de-amenazas.md); CTL-04, CTL-10 |
| **A07 Fallas de autenticación** | Política NIST; bloqueo; segundo factor obligatorio; sin autorregistro. | CTL-15 a CTL-19; AM-03 |
| **A08 Fallas de integridad de software y datos** | Bitácora de solo inserción; constancia con código y *hash*; despliegue con aprobación. | CTL-14, CTL-38; AM-02, AM-13 |
| **A09 Fallas de registro y alertas** | Eventos, alertas por umbral, sin datos sensibles. | CTL-38, CTL-40 |
| **A10 Manejo inadecuado de condiciones excepcionales** | Fallar cerrado; errores uniformes; transacciones atómicas. | CTL-09, CTL-39 |

## 2. ASVS 5.0

El nivel 2 en autenticación, sesión, autorización, datos personales y registro, y el nivel 1 en el resto, se detallan en la [lista de controles](02-controles-asvs.md) (CTL-01 a CTL-40), con su estado.

## 3. NIST SP 800-63B-4 (autenticación)

| Tema | Aplicación |
| :--- | :--- |
| Longitud y composición | Mínimo 15 caracteres como único factor; sin reglas de composición; acepta espacios y pegar. |
| Listas de contraseñas | Rechazar valores comunes o filtrados. |
| Vencimiento | Sin vencimiento periódico; cambio ante sospecha. |
| Segundo factor | TOTP para todo el personal, con códigos de respaldo. |

## 4. ISO/IEC 27002:2022 (referencia, sin certificación)

Se toman como orientación los controles más relevantes. Los números y nombres de control están verificados contra el texto en español aportado por el equipo.

| Control | Cómo se aborda | Dónde |
| :--- | :--- | :--- |
| 5.15 Control de acceso | Roles y permisos granulares. | [autenticación y autorización](03-autenticacion-y-autorizacion.md) |
| 5.17 Información de autenticación | Política de contraseñas y segundo factor. | CTL-15 a CTL-19 |
| 5.19 a 5.23 Proveedores y servicios en la nube | Política de uso de Oracle, región documentada, plan de salida. | [despliegue](../02-arquitectura-de-software/05-despliegue.md) |
| 5.24 a 5.28 Gestión de incidentes | Procedimiento y registro. | [operación segura](07-operacion-segura.md) |
| 5.29 y 5.30 Continuidad de las TIC | RTO y RPO; pruebas de restauración. | [despliegue](../02-arquitectura-de-software/05-despliegue.md) |
| 5.31 Requisitos legales | Registro de requisitos legales y revisión semestral. | [marco legal](../01-analisis-de-sistema/03-marco-legal.md) |
| 5.33 Protección de registros | Calendario de retención; constancias verificables. | [privacidad](04-privacidad-y-datos-personales.md) |
| 5.34 Privacidad y PII | ODP; inventario; derechos. | [privacidad](04-privacidad-y-datos-personales.md) |
| 5.37 Procedimientos operativos documentados | Manual de operación. | `operacion-despliegue` |
| 6.6 Acuerdos de confidencialidad | Con las cinco personas usuarias y con el equipo. | [actores y permisos](../01-analisis-de-sistema/05-actores-y-permisos.md) |
| 8.2 Derechos de acceso privilegiado | Segundo factor del personal. | CTL-19, CTL-26 |
| 8.5 Autenticación segura | Bloqueo, último ingreso e intentos fallidos. | CTL-17 |
| 8.10 Eliminación de información | Retención y borrado; evidencia. | CTL-34 |
| 8.11 Enmascaramiento de datos | Documento parcial en listados; nunca en la URL. | CTL-08, CTL-27 |
| 8.13 Copia de seguridad | Respaldo cifrado en dos lugares y prueba de restauración. | CTL-29 |
| 8.15 Registro | Bitácora de solo inserción; hora sincronizada. | CTL-38 |
| 8.25 a 8.29 Desarrollo seguro y pruebas | SDD, requisitos de seguridad en specs, SAST y pruebas por criterio. | [flujo SDD](../07-proceso-de-desarrollo/01-flujo-sdd.md) |
| 8.30 Desarrollo subcontratado | Titularidad y licencia; modelo de amenazas. | P-09 |
| 8.31 Separación de entornos | Etiqueta visible y datos sintéticos. | CTL-35 |
| 8.32 Gestión de cambios | Aprobación y registro. | [operación segura](07-operacion-segura.md) |
| 8.33 Información de prueba | Datos sintéticos siempre. | CTL-35; [seguridad del desarrollo con IA](06-seguridad-del-desarrollo-con-ia.md) |

## 5. ISO/IEC 25010:2023 (modelo de calidad)

Los atributos de calidad se clasifican por las características de este modelo en [atributos de calidad](../01-analisis-de-sistema/04-atributos-de-calidad.md). Seguridad corresponde a AC-02.

## 6. Privacidad

Ley N.° 29733 y DS 016-2024-JUS: [privacidad](04-privacidad-y-datos-personales.md) y [marco legal](../01-analisis-de-sistema/03-marco-legal.md). La EIPD facultativa del art. 40 se basa en NTP-ISO/IEC 27005 y NTP-ISO 31000.

## 7. Accesibilidad

WCAG 2.2 nivel AA (ISO/IEC 40500:2025, RM 126-2009-PCM): [accesibilidad](../06-experiencia-de-usuario/06-accesibilidad-wcag.md).
