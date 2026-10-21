# Base de datos: esquema v1.1

| Archivo | Para qué sirve |
| :--- | :--- |
| [esquema_matricula_cetpro_v1.1.sql](esquema_matricula_cetpro_v1.1.sql) | Crea los esquemas `identidad`, `matricula` y `auditoria`, las tablas, las reglas en la base de datos, las vistas y los datos iniciales (catálogos, parámetros, roles y permisos). |
| [pruebas_esquema_v1.1.sql](pruebas_esquema_v1.1.sql) | 49 comprobaciones de humo de las reglas de negocio (RN-01, 04, 06, 09, 11 a 15), la bitácora inmutable, las vistas y la matriz de permisos. Corre en una transacción que termina en `ROLLBACK`. |

## Estado

**Probados por el equipo en PostgreSQL (Docker), con 0 comprobaciones fallidas** (oct-2026). Siguen siendo la **referencia** del modelo: la aplicación crea el esquema con migraciones de EF Core y cada spec fija sus nombres definitivos. Las brechas conocidas de esta versión (borrador de la ficha, plazo ampliado del derecho de información, auditoría de usuarios, requisito de NEE, parámetros de alertas) están en [modelo de datos, sección 13](../docs/03-diseno-de-software/05-modelo-de-datos.md#13-brechas-conocidas-del-esquema-v11) y las cierran las specs correspondientes; no se corrigen aquí sin una versión nueva.

### Control de cambios

| Fecha | Cambio |
| :--- | :--- |
| oct-2026 | v1.1 probada. Solo comentarios: se corrigió el encabezado de estado y las rutas a los documentos movidos a `Entregables/`; se escribió «autorregistro». |

## Cómo probarlos (base de pruebas descartable)

Con Docker, en la carpeta principal del proyecto:

```bash
docker run --rm -d --name pg-prueba -e POSTGRES_PASSWORD=prueba -p 5433:5432 postgres:18
```

```bash
docker exec -i pg-prueba psql -U postgres -v ON_ERROR_STOP=1 < db/esquema_matricula_cetpro_v1.1.sql
```

```bash
docker exec -i pg-prueba psql -U postgres < db/pruebas_esquema_v1.1.sql
```

El resumen final debe mostrar `fallidas = 0`. Para retirar la base: `docker stop pg-prueba`.

El esquema usa solo funciones disponibles desde PostgreSQL 13 (`gen_random_uuid()`, índices parciales, columnas de identidad); se apunta a la versión 18 por decisión de arquitectura (AD-03).

## Qué es definitivo y qué es provisional

- **Definitivo (sujeto a revisión del equipo):** modelo de matrícula, ratificación, licencia, convalidación, beca y derecho de inscripción, parámetros, bitácora, permisos por rol.
- **Provisional hasta tener las plantillas Excel de AVANZA:** las columnas de `v_exportacion_avanza_estudiantes` y `v_exportacion_avanza_modulos`, y los valores de `grado_instruccion`. El mapeo definitivo irá en el parámetro `avanza_mapeo_columnas`.
- **Por definir con el CETPRO:** `plazo_reserva_licencia_dias`, `derecho_inscripcion_monto`, `retencion_matriculas_anios` y el `codigo_modular` de `institucion`. Mientras valgan `null`, leerlos produce un error explícito (no un valor inventado).
- **No incluido:** los datos de `ubigeo` (códigos INEI) y las tablas auxiliares de ASP.NET Core Identity (reclamos, inicios de sesión externos, fichas), que crea la migración de EF Core.

## Convenciones que la aplicación debe respetar

- Abrir cada transacción con `SET LOCAL cetpro.usuario_id = '<uuid>'` y `SET LOCAL cetpro.ip_origen = '<ip>'` para que la auditoría automática sepa quién hizo el cambio.
- Las lecturas y las exportaciones las registra la aplicación en `auditoria.bitacora` (la base solo ve los cambios).
- Actualizar `matricula` con `WHERE version = @version` (concurrencia optimista).
- La aplicación se conecta con el rol `cetpro_app` (sin `LOGIN` ni contraseña en el script: los asigna el despliegue). No es propietaria de las tablas ni puede borrar matrículas.
- Los datos de prueba son siempre sintéticos. No cargar datos reales de estudiantes en entornos de desarrollo ni de pruebas.
