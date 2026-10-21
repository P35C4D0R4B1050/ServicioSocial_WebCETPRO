# Convenciones técnicas

Reglas transversales que toda la solución sigue. Complementan la regla de dependencia de [Clean Architecture](../03-diseno-de-software/01-clean-architecture.md). Lo marcado como **propuesta** se confirma en la spec que lo implementa o en la fase 0.

## 1. Git

**Mensajes de commit** *(propuesta)*: `tipo: descripción` en español, en imperativo y en minúsculas, sin punto final. Commits pequeños: cada uno hace una sola cosa y deja el proyecto compilando.

| Tipo | Para qué sirve | Ejemplo |
| :--- | :--- | :--- |
| `feat` | Nueva funcionalidad | `feat: agregar validación de edad mínima` |
| `fix` | Corrección de error | `fix: rechazar segunda matrícula vigente` |
| `chore` | Mantenimiento y configuración | `chore: agregar esqueleto de la solución` |
| `docs` | Documentación | `docs: actualizar el modelo de datos` |
| `test` | Pruebas | `test: agregar pruebas de la bitácora inmutable` |
| `refactor` | Mejorar el código sin cambiar su comportamiento | `refactor: simplificar la política de beca` |

Los commits asistidos por IA terminan con la línea `Co-Authored-By` correspondiente (transparencia, AD-36).

**Ramas** *(propuesta)*: `main` protegida; una rama por spec (`spec/<nombre>`) con fusión tras revisión y CI en verde. El despliegue a producción exige la aprobación de un segundo integrante.

**Qué no entra al repositorio** (lo hace cumplir el `.gitignore` de la raíz): secretos y archivos `.env`, claves y certificados, binarios (`bin/`, `obj/`), CSS generado, **datos personales reales**, respaldos y volcados, exportaciones con datos reales, estado de OpenTofu y material de terceros con derechos de autor. El repositorio remoto es público, por lo que se revisa lo preparado antes de cada commit. Se versionan `.env.example` (sin valores), `.gitignore` y `.gitattributes` (`eol=lf`). El repositorio es **privado**.

## 2. Idioma y nombres

| Elemento | Convención |
| :--- | :--- |
| Documentación, interfaz y mensajes al usuario | Español (es-PE). |
| Dominio y casos de uso | Español, con los términos de `docs/glossary.md` (`RegistrarMatricula`, `Estudiante`, `ProgramaEstudios`). |
| Elementos técnicos | Sufijos estándar en inglés (`Controller`, `Options`, `Handler`). |
| Proyectos | `Cetpro.<Capa>` (`Cetpro.Domain`, `Cetpro.Application`, `Cetpro.Infrastructure`, `Cetpro.Web`). |
| Tablas y columnas | `snake_case`, en español (`matricula`, `codigo_matricula`). |
| Identificadores de requisitos | Los del ERS con guion (`RF-01`, `RN-09`); criterios `AC-<MÓDULO>-<NN>`. |
| Pruebas | Nombres descriptivos en español: `Registrar_MenorDeEdadMinima_Rechaza`. |

## 3. Rutas y respuestas web

| Aspecto | Convención |
| :--- | :--- |
| Rutas | En español, minúsculas y con guiones (`/matriculas`, `/catalogo/programas`). |
| Identificadores | **Opacos** (`uid` UUID); **nunca** el documento en una URL (AD-17). |
| Formularios | Protección CSRF; el botón se desactiva tras el primer envío. |
| Paginación | `pagina` y `tamano` (máximo 50); la respuesta incluye el total. |
| Errores | Mensajes que dicen qué pasó y qué hacer; los puntos no interactivos usan `application/problem+json` (RFC 9457) con `code` estable y `traceId`. Nunca trazas. |
| Fechas y dinero | UTC en la base y hora de Lima en la presentación; soles con `numeric(8,2)`. |
| Correlación | Cabecera `X-Correlation-Id`: se genera si falta y aparece en cada registro técnico. |

| Código HTTP | Uso |
| :--- | :--- |
| 400 | Solicitud mal formada o con datos inválidos. |
| 401 | Sin sesión. |
| 403 | Autenticado, pero sin permiso (se registra). |
| 404 | El recurso no existe o no es visible. |
| 409 | Conflicto: versión de la matrícula, estado inválido. |
| 422 | Regla de negocio (edad mínima, ciclo Técnico, tope de beca). |
| 429 | Límite de uso. |
| 503 | Dependencia no disponible. |

## 4. Autenticación y autorización

- **ASP.NET Core Identity** con roles y permisos granulares; sesión de servidor con cookie `HttpOnly`, `Secure` y `SameSite`.
- Segundo factor TOTP obligatorio para todo el personal; bloqueo y vencimiento por parámetros.
- Cada caso de uso exige su permiso; por defecto se niega.
- Ver [autenticación y autorización](../05-seguridad/03-autenticacion-y-autorizacion.md).

## 5. Configuración y secretos

- `appsettings.json` solo contiene valores no sensibles. Los secretos (cadena de conexión, clave de cifrado de respaldos, URL de Healthchecks) vienen de variables de entorno con el prefijo `CETPRO__`.
- Se versiona `.env.example` con todas las variables y valores de ejemplo; el `.env` real está en `.gitignore`. En desarrollo se pueden usar los secretos de usuario de .NET.
- La aplicación falla al arrancar si falta una variable obligatoria.
- Los **parámetros institucionales** (edad mínima, plazos, topes) **no** son configuración de despliegue: viven en la tabla `parametro_institucional` y se editan en la aplicación.

## 6. Persistencia

| Aspecto | Convención |
| :--- | :--- |
| Acceso | EF Core con Npgsql. Esquemas `identidad`, `matricula` y `auditoria`. La aplicación se conecta con `cetpro_app` (mínimo privilegio). |
| Migraciones | Versionadas; en producción se aplican con una tarea explícita y una cuenta distinta (propietaria), no al arrancar la aplicación. |
| Tiempo | `timestamptz` en UTC; el reloj es un puerto (`IReloj`) para probar plazos y vencimientos. |
| Auditoría | Al abrir cada transacción: `SET LOCAL cetpro.usuario_id` y `SET LOCAL cetpro.ip_origen`. Los cambios los registran los disparadores; las lecturas y exportaciones las registra la aplicación. |
| Concurrencia | `matricula` se actualiza con `WHERE version = @version`. |
| Bitácora | Solo inserción; la aplicación no puede actualizarla ni borrarla. |
| Reglas críticas | Se validan en el dominio **y** en la base (doble defensa). |

## 7. Resiliencia y observabilidad

- **Salud:** `/salud/viva` y `/salud/lista`; Docker Compose los usa en `healthcheck` con `restart: unless-stopped`.
- **Logs:** estructurados (Serilog) en JSON hacia la consola, con `X-Correlation-Id`. **No** se registran contraseñas, códigos TOTP ni datos personales completos.
- **Latido:** el `keepalive` envía un latido a Healthchecks; el aviso externo avisa si falta.
- **Tiempos de espera** en toda llamada saliente (Healthchecks, Object Storage).

## 8. Pruebas

- Una prueba por criterio de aceptación de cada spec. Las pruebas llevan un rasgo (`Trait("Criterio", "AC-XXX-NN")`) para trazarlas.
- Las pruebas de integración usan Testcontainers (PostgreSQL) y necesitan Docker.
- Una prueba de arquitectura (NetArchTest) verifica la regla de dependencia.
- **Datos de prueba siempre sintéticos.** Ver [estrategia de pruebas](03-estrategia-de-pruebas.md).

## 9. Integración continua

GitHub Actions: compilar, ejecutar pruebas unitarias y de arquitectura en cada cambio; pruebas de integración y de humo SQL en `main`; escaneos (CodeQL, dependencias, Trivy, `gitleaks`); construcción de imágenes `linux/amd64` y `linux/arm64` con `buildx`. Los secretos se guardan en los secretos del repositorio, nunca en los flujos. Las acciones se fijan por *hash*.

## 10. Docker

- Un `Dockerfile` para la aplicación, en varias etapas, con imagen multi-arquitectura.
- Usuario sin privilegios, `healthcheck` y límites de memoria en Compose (ver [presupuesto de recursos](../02-arquitectura-de-software/07-presupuesto-de-recursos.md)).
- `infra/docker-compose.local.yml` levanta PostgreSQL y la aplicación con datos sintéticos. No necesita Oracle ni Cloudflare.

## 11. Datos sintéticos

Un conjunto sembrable para desarrollo, demostración y pruebas: estudiantes con apellido «PRUEBA» y nombres «SINTÉTICO», documentos ficticios, los programas de la oferta 2026, un plan con módulos y unidades por programa, periodos lectivos, ofertas, un usuario por rol y convenios de ejemplo. Las contraseñas de ejemplo solo existen en el archivo de ejemplo y nunca se usan fuera de desarrollo. El generador y su revisión en CI evitan que un dato real entre por error.

## 12. Definición de «terminado» de una tarea

1. Compila y las pruebas pasan, incluida la de arquitectura.
2. Cada criterio de la spec afectado tiene su prueba.
3. No hay secretos ni datos personales reales en el cambio.
4. La spec, el plan o `docs/` se actualizan si el comportamiento cambió.
5. Se registra en `progress/` (log de la sesión y `CHANGELOG`).
