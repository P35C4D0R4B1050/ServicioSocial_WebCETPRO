# Lista de verificación de controles (ASVS 5.0)

Traduce el **OWASP Application Security Verification Standard 5.0** a controles concretos del Sistema de Matrícula. El objetivo es el **nivel 2** en los capítulos de mayor riesgo (autenticación, sesión, control de acceso, datos personales, registro) y el nivel 1 en el resto (RNF-15, AD-13). No hay certificación: el estándar se usa como criterio objetivo.

> Los controles se identifican como `CTL-NN`. Se agrupan por capítulo del ASVS; antes de planificar una spec, se enlazan los números exactos de requisito del ASVS que le aplican y se verifican contra el texto 5.0.0 (hay un mapeo desde 4.0.3).

**Estado:** *Especificado* (hay requisito en una spec aprobada), *Decisión* (lo fija una decisión AD o una regla de negocio), *Pendiente* (falta definirlo en la spec indicada o en la infraestructura). **Nivel:** L1 siempre; L2 cuando se indica. Como todavía no hay specs aprobadas, ningún control está en *Especificado*.

## 1. Codificación, validación y lógica de negocio

| ID | Control | Nivel | Dónde se especifica | Verificación | Estado |
| :--- | :--- | :---: | :--- | :--- | :---: |
| **CTL-01** | Toda entrada se valida en el servidor (tipo, longitud, formato, rango); los campos de texto libre tienen límite y advertencia. | L1 | `web-base`, `matricula-registro` | Pruebas unitarias y de integración | Pendiente |
| **CTL-02** | Toda salida se codifica según su contexto; el contenido de usuario nunca se interpreta como código. | L1 | `web-base` | Pruebas E2E y revisión estática | Pendiente |
| **CTL-03** | Las consultas a la base usan parámetros (EF Core); no se arma SQL con texto del usuario. | L1 | AD-03 | Revisión estática y pruebas | Decisión |
| **CTL-04** | Las reglas críticas (edad, matrícula única, ciclo Técnico, beca, estados) se validan en el dominio **y** en la base; los flujos concurrentes son seguros. | L2 | AD-03; RN-01, RN-13 | Pruebas de integración y concurrencia | Decisión |

## 2. Frontend web

| ID | Control | Nivel | Dónde se especifica | Verificación | Estado |
| :--- | :--- | :---: | :--- | :--- | :---: |
| **CTL-05** | Política de contenido restrictiva, HSTS, `X-Content-Type-Options` y política de referencia limitada. | L1 | `web-base` | Prueba E2E de cabeceras y escáner | Pendiente |
| **CTL-06** | Los formularios llevan protección contra falsificación entre sitios (CSRF). | L1 | `web-base` | Prueba E2E | Pendiente |
| **CTL-07** | Sin scripts de terceros: los recursos (HTMX, fuentes) se sirven desde el propio origen. | L2 | AD-02 | Revisión de la política | Decisión |
| **CTL-08** | No hay datos personales en la URL (nunca el documento) ni en el historial; las fichas y reportes no se guardan en la caché del navegador compartido. | L1 | AD-17 | Pruebas y revisión | Decisión |

## 3. Superficie HTTP

| ID | Control | Nivel | Dónde se especifica | Verificación | Estado |
| :--- | :--- | :---: | :--- | :--- | :---: |
| **CTL-09** | Los errores usan un formato uniforme sin trazas ni datos internos; el entorno de producción no muestra detalles. | L1 | `web-base` | Pruebas de contrato | Pendiente |
| **CTL-10** | La verificación pública de constancias tiene límite de tasa por origen y respuesta uniforme. | L2 | `docs-constancia` | Pruebas de integración y carga ligera | Pendiente |
| **CTL-11** | Los formularios aceptan solo los campos esperados (sin asignación masiva); el modelo de la página no es la entidad de dominio. | L2 | Plan de cada spec | Pruebas de contrato | Pendiente |

## 4. Documentos y exportaciones

| ID | Control | Nivel | Dónde se especifica | Verificación | Estado |
| :--- | :--- | :---: | :--- | :--- | :---: |
| **CTL-12** | Las celdas de Excel se sanean contra la inyección de fórmulas (`=`, `+`, `-`, `@`); el PDF usa plantillas fijas. | L1 | AD-15 | Pruebas con valores hostiles | Decisión |
| **CTL-13** | Los archivos generados no se guardan en el servidor más allá de la descarga; no hay rutas públicas de documentos; el nombre no contiene datos personales. | L1 | `docs-reportes` | Pruebas de integración | Pendiente |
| **CTL-14** | La constancia lleva código único y *hash*; se puede revocar con motivo; la verificación no revela más que lo mínimo. | L2 | AD-11 | Pruebas de integración | Decisión |

## 5. Autenticación

| ID | Control | Nivel | Dónde se especifica | Verificación | Estado |
| :--- | :--- | :---: | :--- | :--- | :---: |
| **CTL-15** | Política de contraseñas: mínimo 15 caracteres (parámetro `password_minimo`), fuera de listas comunes o filtradas, sin reglas de composición ni vencimiento periódico. | L1 | NIST 800-63B-4; RNF-05 | Pruebas unitarias | Decisión |
| **CTL-16** | Las contraseñas se guardan con resumen robusto (PBKDF2 de Identity o Argon2id); nunca en claro. | L1 | `identidad-seguridad` | Inspección y pruebas | Pendiente |
| **CTL-17** | Bloqueo temporal tras 5 fallos (`bloqueo_intentos`, `bloqueo_minutos`); respuestas que no revelan si la cuenta existe; se muestra el último ingreso y los intentos fallidos. | L1 | ISO 27002 8.5; RF-19 | Pruebas de integración | Decisión |
| **CTL-18** | No hay autorregistro; las altas las hace el Administrador, que entrega una contraseña temporal y restablece el acceso con registro. | L1 | RF-29 | Pruebas de integración | Decisión |
| **CTL-19** | Segundo factor (TOTP) obligatorio para todo el personal, con códigos de respaldo; recuperar la contraseña no lo desactiva. | L2 | RN-07 | Pruebas de integración | Decisión |
| **CTL-20** | Las claves y los secretos salen del entorno, no del código ni del repositorio. | L1 | `operacion-despliegue` | Detección de secretos en CI | Pendiente |

## 6. Gestión de sesión

| ID | Control | Nivel | Dónde se especifica | Verificación | Estado |
| :--- | :--- | :---: | :--- | :--- | :---: |
| **CTL-21** | La cookie de sesión es `HttpOnly`, `Secure` y `SameSite`; el identificador cambia al ingresar y se invalida al cerrar. | L1 | `web-base` | Prueba E2E | Pendiente |
| **CTL-22** | Sesión con vencimiento por inactividad (`sesion_inactividad_min`, 30) y máximo absoluto (`sesion_maxima_horas`, 8), con aviso 2 minutos antes y el borrador conservado. | L1 | RNF-05 | Pruebas de integración | Decisión |
| **CTL-23** | Cambiar el rol o los permisos de un usuario surte efecto en la siguiente renovación de sesión y queda en la bitácora. | L2 | `identidad-seguridad` | Prueba de integración | Pendiente |

## 7. Autorización

| ID | Control | Nivel | Dónde se especifica | Verificación | Estado |
| :--- | :--- | :---: | :--- | :--- | :---: |
| **CTL-24** | Cada caso de uso exige su permiso (`MATRICULA_ANULAR`, `REPORTE_GENERAR`…), no solo la página; por defecto se niega. | L1 | AD-33 | Pruebas unitarias y de integración | Decisión |
| **CTL-25** | Un recurso al que no se tiene acceso responde igual que uno inexistente cuando revelar su existencia sería una fuga. | L2 | Plan de cada spec | Pruebas de integración | Pendiente |
| **CTL-26** | Las funciones administrativas (usuarios, parámetros, respaldos) exigen rol y segundo factor. | L1 | AD-33 | Pruebas de integración | Decisión |
| **CTL-27** | Los identificadores en la URL son opacos (UUID); el documento nunca es una clave de URL. | L1 | AD-17 | Pruebas de integración | Decisión |

## 8. Criptografía y comunicación segura

| ID | Control | Nivel | Dónde se especifica | Verificación | Estado |
| :--- | :--- | :---: | :--- | :--- | :---: |
| **CTL-28** | TLS 1.2 o superior hacia el exterior; HSTS; TLS entre la aplicación y la base. | L1 | AD-06, AD-05 | Escáner de configuración | Decisión |
| **CTL-29** | Los respaldos se cifran antes de salir de la VM-DB con una clave custodiada por el CETPRO, con *checksum*. | L2 | AD-08 | Inspección y prueba de restauración | Decisión |
| **CTL-30** | El secreto TOTP se guarda cifrado y los códigos de respaldo solo como resumen; las claves de cifrado se gestionan fuera de la VM. | L2 | `identidad-seguridad` | Inspección | Pendiente |

## 9. Configuración y protección de datos

| ID | Control | Nivel | Dónde se especifica | Verificación | Estado |
| :--- | :--- | :---: | :--- | :--- | :---: |
| **CTL-31** | La base de datos no tiene puerto expuesto a Internet; solo la VM-APP la alcanza; la administración es por Bastion. | L1 | AD-05 | Escaneo de puertos | Decisión |
| **CTL-32** | Contenedores sin privilegios, con límites de memoria y *healthcheck*; imágenes con versión fija. | L2 | `operacion-despliegue` | Revisión de Compose | Pendiente |
| **CTL-33** | No se guarda copia del DNI, evidencia socioeconómica ni documentos de discapacidad. | L1 | RN-17; AD-10 | Revisión y pruebas | Decisión |
| **CTL-34** | Los datos personales tienen inventario, base legal, retención y borrado o anonimización probados. | L2 | `cumplimiento-privacidad` | Inspección documental | Pendiente |
| **CTL-35** | Entornos separados con **datos sintéticos**; ninguna herramienta de IA recibe datos reales. | L1 | AD-16, AD-36 | Revisión y escaneo | Decisión |
| **CTL-36** | SSH solo con llave, por OCI Bastion; sin contraseña; el firewall del sistema refleja las reglas de red. | L1 | AD-05 | Revisión de la configuración | Decisión |

## 10. Código seguro, registro y manejo de errores

| ID | Control | Nivel | Dónde se especifica | Verificación | Estado |
| :--- | :--- | :---: | :--- | :--- | :---: |
| **CTL-37** | Las dependencias tienen versión fija y se escanean; el repositorio genera un inventario de componentes (SBOM). | L1 | `operacion-despliegue` | CI | Pendiente |
| **CTL-38** | Se registran sesión, lecturas, modificaciones, eliminaciones, importaciones y exportaciones, sin contraseñas ni datos sensibles; la bitácora es de solo inserción y se conserva ≥ 2 años. | L2 | AD-12; RF-34 | Pruebas | Decisión |
| **CTL-39** | Ante un error inesperado el sistema niega, no deja efectos parciales y no filtra detalles. | L1 | `web-base` | Pruebas | Pendiente |
| **CTL-40** | Hay alertas ante ingresos fallidos masivos, cuentas bloqueadas y exportaciones inusuales, y ante un respaldo fallido. | L2 | `transversal-alertas` | Pruebas | Pendiente |

## 11. Resumen

| Estado | Cantidad |
| :--- | :---: |
| Especificado | 0 |
| Decisión | 21 |
| Pendiente | 19 |

Los controles *Pendiente* se resuelven en los planes de las specs indicadas o en las tareas de infraestructura y CI. Ninguno bloquea la aprobación de una spec; sí bloquea el paso de esa spec a **Done**.
