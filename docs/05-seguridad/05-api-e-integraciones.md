# Superficie expuesta e integraciones

Cómo se protegen los puntos HTTP del sistema y las conexiones con servicios de terceros. El sistema **no tiene una API pública general ni se integra con AVANZA**: la interfaz es de servidor (Razor Pages y HTMX) y los únicos puntos no interactivos son la verificación pública de constancias y los *healthchecks*. Apoya RNF-15 y las decisiones AD-06, AD-11 y AD-13.

## 1. Principios

1. **Cada caso de uso protege su propia puerta**: que la página ya haya validado algo no exime de volver a validarlo.
2. **Nada que venga de fuera es confiable**: ni la entrada del usuario, ni la respuesta de un tercero.
3. **El contrato es estrecho.** Los formularios aceptan solo los campos esperados.
4. **Por defecto se niega.** Un error o una dependencia caída nunca abren un acceso.
5. **Los límites existen en dos niveles**: el borde (Cloudflare y Caddy) frena el ruido y la aplicación aplica reglas de negocio.

## 2. Puntos expuestos

| Punto | Quién | Autenticación | Riesgo principal | Control |
| :--- | :--- | :--- | :--- | :--- |
| Páginas de la aplicación | El personal (cinco personas) y el Administrador | Sesión con segundo factor | Acceso sin permiso, CSRF, XSS | Permisos por caso de uso; CSRF; CSP; codificación de salida |
| `/verificar/{codigo}` | Persona externa | Ninguna | Enumeración, falsificación | Respuesta mínima y uniforme; límite de tasa; códigos largos y aleatorios |
| `/salud/viva` y `/salud/lista` | Docker y monitoreo | Ninguna, sin datos | Fuga de información | Solo estado, sin versiones ni datos |
| Web institucional | Visitantes | Ninguna | Compromiso del sitio público | VM aparte, estática, sin ruta a la BD |
| SSH | Administración | Llave por OCI Bastion | Acceso al servidor | Sin SSH público |

## 3. Riesgos aplicados (OWASP Top 10:2025)

| Riesgo | Dónde aplica | Control |
| :--- | :--- | :--- |
| **A01 Control de acceso roto** | Páginas, descargas, verificación | Permiso por caso de uso; identificadores opacos; denegar por defecto (CTL-24, CTL-27). |
| **A02 Configuración incorrecta** | Cabeceras, errores, puertos | Cabeceras de seguridad; producción sin detalles de error; BD privada (CTL-05, CTL-31). |
| **A03 Cadena de suministro** | NuGet, imágenes, acciones | Versiones fijas, escaneo, SBOM (CTL-37). |
| **A05 Inyección** | Búsqueda, formularios, exportaciones | EF Core con parámetros; saneo de celdas; codificación (CTL-03, CTL-12). |
| **A06 Diseño inseguro** | Anulación, búsqueda, verificación pública | Anulación con motivo; límites de tasa; doble defensa (CTL-04, CTL-10). |
| **A07 Autenticación** | Ingreso, segundo factor | Política NIST, bloqueo temporal, TOTP (CTL-15 a CTL-19). |
| **A09 Registro y alertas** | Todo el sistema | Bitácora de solo inserción; alertas por umbral (CTL-38, CTL-40). |
| **A10 Condiciones excepcionales** | Errores, base caída | Fallar cerrado; mensajes genéricos con identificador (CTL-39). |

## 4. Reglas para las rutas

| Tema | Regla |
| :--- | :--- |
| Autenticación | Toda ruta, salvo el ingreso, la verificación pública y los *healthchecks*, exige sesión válida. |
| CORS | No se habilita CORS abierto; la interfaz y el servidor comparten origen. |
| Contenido | Los formularios llevan protección CSRF; las descargas devuelven el tipo adecuado y `Content-Disposition`. |
| Tamaño | Límite de cuerpo por ruta; sin carga de archivos de usuarios (el sistema no recibe archivos). |
| Paginación | Tope máximo de elementos por página; ordenamiento sobre campos permitidos. |
| Errores | Mensajes que dicen qué pasó y qué hacer; sin trazas; con identificador de seguimiento. |
| Registro | Se registra el identificador de la solicitud, la ruta, el usuario y el resultado; no se registran cuerpos con datos sensibles. |

## 5. Límites de uso

Los valores marcados con *(propuesta)* se confirman en la spec correspondiente.

| Operación | Límite | Nivel | Spec |
| :--- | :--- | :--- | :--- |
| Ingreso | 5 fallos y bloqueo de 15 minutos por cuenta | Aplicación | `identidad-seguridad` |
| Segundo factor | 5 códigos incorrectos en 15 minutos por cuenta y origen | Aplicación | `identidad-seguridad` *(propuesta)* |
| Verificación pública de constancias | 30 consultas por 10 minutos por origen | Borde y aplicación | `docs-constancia` *(propuesta)* |
| Exportaciones | Alerta ante exportaciones inusuales (volumen o frecuencia) | Aplicación | `transversal-alertas` *(propuesta)* |
| Búsqueda de estudiantes | Paginación con tope; resultados solo con sesión | Aplicación | `estudiantes` |
| Tráfico en general | Reglas de tasa de Cloudflare | Borde | `operacion-despliegue` |

**Respuesta uniforme:** al exceder un límite la respuesta tiene siempre la misma forma, incluye una espera sugerida y no revela información de cuentas. Cada exceso se registra como evento de seguridad.

## 6. Integraciones con terceros

| Integración | Dirección | Autenticación | Validación | Falla |
| :--- | :--- | :--- | :--- | :--- |
| **Cloudflare** | Entrante (tráfico) | Certificado/túnel | — | Se expone Caddy directamente como alternativa documentada. |
| **Oracle Object Storage** | Saliente (respaldos) | Llave en el entorno, permisos de solo escritura | *Checksum* de cada copia | Alerta técnica; se reintenta. |
| **Healthchecks** | Saliente (latido) | URL de ping secreta | — | El aviso externo avisa si el latido falta. |
| **Let's Encrypt (Caddy)** | Saliente | — | — | Caddy reintenta; revisar los límites de emisión. |
| **GitHub (CI/CD)** | Saliente | Secretos del repositorio | Acciones fijadas por *hash* | El despliegue no avanza. |
| **AVANZA** | **Ninguna** | — | — | Fuera del sistema. |
| **RENIEC** | **Ninguna** (mejora futura) | — | — | La valida AVANZA al cargar. |
| **Correo / mensajería** | **Ninguna** en el MVP | — | — | Las alertas son internas. |

## 7. Requisitos para cualquier integración futura

Si se agregara una integración (por ejemplo, consulta a RENIEC por PIDE), debe: (1) estar en el ERS antes de especificarse; (2) autenticarse con secreto fuera del repositorio; (3) usar tiempos de espera y tratar la respuesta como no confiable; (4) permitir solo una lista cerrada de destinos salientes; (5) documentar qué datos recibe el tercero; (6) pasar por el modelo de amenazas.
