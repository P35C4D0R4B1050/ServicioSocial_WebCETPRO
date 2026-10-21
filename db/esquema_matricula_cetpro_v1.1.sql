-- =====================================================================
-- Sistema de Gestión de Matrícula - CETPRO "Joaquín López Antay"
-- Esquema v1.1                 Motor objetivo: PostgreSQL 18
-- Estado: probado por el equipo en PostgreSQL (Docker) con db/pruebas_esquema_v1.1.sql:
--         0 comprobaciones fallidas (oct-2026). Referencia del modelo de datos;
--         las brechas conocidas están en docs/03-diseno-de-software/05-modelo-de-datos.md
--         (sección 13) y las cierran las specs (ver db/README.md).
--
-- Cambios respecto de la v1.0 (ver Entregables/Documento-de-Arquitectura-v0.4.md, 7, y
-- Investigacion/05, secciones 3 y 6):
--   * Se retira todo lo relacionado con notas.
--   * Documento de identidad con tipo (DNI, CE, PASAPORTE, PTP); el código
--     de matrícula es el número de documento (LAG 11.2.2).
--   * Periodo lectivo (2026-I), plan de estudios con resolución de
--     autorización, módulos y unidades didácticas (alineado con AVANZA).
--   * La matrícula incluye el módulo cursado (matricula_modulo).
--   * Ratificación, licencia de estudios, reincorporación y convalidación.
--   * Parámetros institucionales versionados: las reglas no formalizadas
--     (edad mínima, tope de beca, similitud mínima) se leen de la tabla
--     parametro_institucional, tanto en la aplicación como aquí (doble defensa).
--   * Identity (usuarios, roles) y permisos por rol.
--   * Bitácora de solo inserción (DS 016-2024-JUS, art. 46).
--   * Avisos de privacidad, solicitudes de derechos, incidentes y alertas.
--   * Vistas de reporte y de apoyo a la exportación para AVANZA.
--
-- Convenciones: snake_case en español; hora en timestamptz (UTC) y
-- presentación en America/Lima; identificadores públicos opacos (uid).
-- Las tablas auxiliares de ASP.NET Core Identity (claims, logins, tokens)
-- las crea la migración de EF Core; aquí solo se define lo que usa el
-- negocio.
-- =====================================================================

BEGIN;

CREATE SCHEMA IF NOT EXISTS identidad;
CREATE SCHEMA IF NOT EXISTS matricula;
CREATE SCHEMA IF NOT EXISTS auditoria;
SET LOCAL search_path TO matricula, identidad, auditoria, public;

-- ---------------------------------------------------------------------
-- 0. EXTENSIONES DE BÚSQUEDA (opcionales)
-- ---------------------------------------------------------------------
DO $ext$
BEGIN
    CREATE EXTENSION IF NOT EXISTS pg_trgm SCHEMA public;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Extensión pg_trgm no disponible (%). Se omite el índice de búsqueda por apellidos.', SQLERRM;
END
$ext$;

-- ---------------------------------------------------------------------
-- 1. TIPOS ENUMERADOS (conjuntos estables definidos por norma)
-- ---------------------------------------------------------------------
CREATE TYPE tipo_documento_identidad AS ENUM ('DNI', 'CE', 'PASAPORTE', 'PTP');
CREATE TYPE sexo                     AS ENUM ('M', 'F');
CREATE TYPE ciclo_formativo          AS ENUM ('AUXILIAR_TECNICO', 'TECNICO');
CREATE TYPE tipo_ingreso             AS ENUM ('NUEVO', 'RATIFICACION', 'REINCORPORACION', 'TRASLADADO', 'RETIRADO_ANTERIORMENTE');
CREATE TYPE estado_matricula         AS ENUM ('VIGENTE', 'ANULADA', 'RETIRADA', 'LICENCIA');
CREATE TYPE tipo_exoneracion         AS ENUM ('NINGUNA', 'BECA', 'EXONERACION');
CREATE TYPE tipo_convalidacion       AS ENUM ('APRENDIZAJES_PREVIOS', 'ENTRE_PLANES', 'UNIDADES_COMPETENCIA', 'EDUCACION_BASICA');
CREATE TYPE condicion_unidad         AS ENUM ('SUBSANACION', 'CONVALIDADA');
CREATE TYPE estado_licencia          AS ENUM ('VIGENTE', 'REINCORPORADO', 'VENCIDA');
CREATE TYPE tipo_documento_emitido   AS ENUM ('CONSTANCIA_ESTUDIOS', 'NOMINA_MATRICULADOS', 'REGISTRO_MATRICULA',
                                              'ARCHIVO_AVANZA_ESTUDIANTES', 'ARCHIVO_AVANZA_MODULOS');
CREATE TYPE tipo_solicitud_derecho   AS ENUM ('INFORMACION', 'ACCESO', 'RECTIFICACION', 'CANCELACION', 'OPOSICION');
CREATE TYPE estado_solicitud         AS ENUM ('RECIBIDA', 'EN_TRAMITE', 'RESPONDIDA', 'DENEGADA');
CREATE TYPE estado_alerta            AS ENUM ('ACTIVA', 'ATENDIDA', 'DESCARTADA');
CREATE TYPE tipo_parametro           AS ENUM ('ENTERO', 'DECIMAL', 'TEXTO', 'BOOLEANO', 'JSON');
CREATE TYPE auditoria.accion_auditoria AS ENUM (
    'LOGIN', 'LOGIN_FALLIDO', 'LOGOUT', 'LECTURA', 'CREACION', 'MODIFICACION', 'ELIMINACION', 'ANULACION',
    'IMPORTACION', 'EXPORTACION', 'CAMBIO_PERMISOS', 'CAMBIO_PARAMETRO', 'EVENTO_SEGURIDAD');

-- ---------------------------------------------------------------------
-- 2. IDENTIDAD (usuarios, roles y permisos)
-- ---------------------------------------------------------------------
CREATE TABLE identidad.usuario (
    id                      UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre_usuario          VARCHAR(40)  NOT NULL,
    nombre_normalizado      VARCHAR(40)  NOT NULL UNIQUE,
    hash_contrasena         VARCHAR(255) NOT NULL,
    sello_seguridad         VARCHAR(64),
    sello_concurrencia      VARCHAR(64),
    doble_factor_activo     BOOLEAN      NOT NULL DEFAULT FALSE,
    secreto_totp_cifrado    TEXT,
    bloqueo_habilitado      BOOLEAN      NOT NULL DEFAULT TRUE,
    bloqueado_hasta         TIMESTAMPTZ,
    intentos_fallidos       SMALLINT     NOT NULL DEFAULT 0,
    ultimo_intento_fallido  TIMESTAMPTZ,
    ultimo_acceso           TIMESTAMPTZ,
    nombres                 VARCHAR(80)  NOT NULL,
    apellidos               VARCHAR(80)  NOT NULL,
    activo                  BOOLEAN      NOT NULL DEFAULT TRUE,
    fecha_creacion          TIMESTAMPTZ  NOT NULL DEFAULT now(),
    CONSTRAINT ck_usuario_nombre   CHECK (nombre_usuario ~ '^[A-Za-z0-9._-]{4,40}$'),
    CONSTRAINT ck_usuario_intentos CHECK (intentos_fallidos >= 0)
);
COMMENT ON TABLE identidad.usuario IS 'Usuarios del personal. Sin autorregistro; alta y baja solo por el Administrador. Mapeada por ASP.NET Core Identity.';

CREATE TABLE identidad.rol (
    id          SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo      VARCHAR(30)  NOT NULL UNIQUE,
    nombre      VARCHAR(60)  NOT NULL,
    descripcion VARCHAR(200)
);

CREATE TABLE identidad.usuario_rol (
    id_usuario UUID     NOT NULL REFERENCES identidad.usuario (id) ON DELETE CASCADE,
    id_rol     SMALLINT NOT NULL REFERENCES identidad.rol (id),
    PRIMARY KEY (id_usuario, id_rol)
);

CREATE TABLE identidad.permiso (
    id          SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo      VARCHAR(50)  NOT NULL UNIQUE,
    descripcion VARCHAR(200) NOT NULL
);

CREATE TABLE identidad.rol_permiso (
    id_rol     SMALLINT NOT NULL REFERENCES identidad.rol (id) ON DELETE CASCADE,
    id_permiso SMALLINT NOT NULL REFERENCES identidad.permiso (id) ON DELETE CASCADE,
    PRIMARY KEY (id_rol, id_permiso)
);
COMMENT ON TABLE identidad.rol_permiso IS 'Matriz de permisos por rol (Documento de Arquitectura, 6.9). Editable por el Administrador con auditoría.';

-- ---------------------------------------------------------------------
-- 3. PARÁMETROS INSTITUCIONALES (reglas no formalizadas, configurables)
-- ---------------------------------------------------------------------
CREATE TABLE parametro_institucional (
    clave               VARCHAR(60)    PRIMARY KEY,
    tipo                tipo_parametro NOT NULL,
    valor               JSONB          NOT NULL,
    descripcion         VARCHAR(250)   NOT NULL,
    vigente_desde       TIMESTAMPTZ    NOT NULL DEFAULT now(),
    id_usuario_modifica UUID           REFERENCES identidad.usuario (id)
);
COMMENT ON TABLE parametro_institucional IS 'Valores configurables sin desplegar (AD-27). Un valor "null" significa "por definir".';

CREATE TABLE parametro_historial (
    id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    clave          VARCHAR(60)  NOT NULL REFERENCES parametro_institucional (clave),
    valor_anterior JSONB,
    valor_nuevo    JSONB        NOT NULL,
    cambiado_en    TIMESTAMPTZ  NOT NULL DEFAULT now(),
    id_usuario     UUID         REFERENCES identidad.usuario (id)
);

CREATE FUNCTION fn_param_json(p_clave text) RETURNS jsonb
LANGUAGE sql STABLE AS
$fn$
    SELECT valor FROM matricula.parametro_institucional WHERE clave = p_clave
$fn$;

CREATE FUNCTION fn_param_int(p_clave text) RETURNS integer
LANGUAGE plpgsql STABLE AS
$fn$
DECLARE v jsonb := matricula.fn_param_json(p_clave);
BEGIN
    IF v IS NULL OR jsonb_typeof(v) = 'null' THEN
        RAISE EXCEPTION 'El parámetro % no está definido', p_clave USING ERRCODE = 'no_data_found';
    END IF;
    RETURN (v #>> '{}')::integer;
END
$fn$;

CREATE FUNCTION fn_param_num(p_clave text) RETURNS numeric
LANGUAGE plpgsql STABLE AS
$fn$
DECLARE v jsonb := matricula.fn_param_json(p_clave);
BEGIN
    IF v IS NULL OR jsonb_typeof(v) = 'null' THEN
        RAISE EXCEPTION 'El parámetro % no está definido', p_clave USING ERRCODE = 'no_data_found';
    END IF;
    RETURN (v #>> '{}')::numeric;
END
$fn$;

CREATE FUNCTION fn_param_text(p_clave text) RETURNS text
LANGUAGE plpgsql STABLE AS
$fn$
DECLARE v jsonb := matricula.fn_param_json(p_clave);
BEGIN
    IF v IS NULL OR jsonb_typeof(v) = 'null' THEN
        RAISE EXCEPTION 'El parámetro % no está definido', p_clave USING ERRCODE = 'no_data_found';
    END IF;
    RETURN v #>> '{}';
END
$fn$;

CREATE FUNCTION fn_parametro_historial() RETURNS trigger
LANGUAGE plpgsql AS
$fn$
BEGIN
    IF NEW.valor IS DISTINCT FROM OLD.valor THEN
        NEW.vigente_desde := now();
        INSERT INTO matricula.parametro_historial (clave, valor_anterior, valor_nuevo, id_usuario)
        VALUES (OLD.clave, OLD.valor, NEW.valor, NEW.id_usuario_modifica);
    END IF;
    RETURN NEW;
END
$fn$;

CREATE TRIGGER trg_parametro_historial
    BEFORE UPDATE ON parametro_institucional
    FOR EACH ROW EXECUTE FUNCTION fn_parametro_historial();

-- ---------------------------------------------------------------------
-- 4. CATÁLOGOS DE APOYO
-- ---------------------------------------------------------------------
CREATE TABLE turno (
    id_turno SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo   VARCHAR(20) NOT NULL UNIQUE,
    nombre   VARCHAR(40) NOT NULL,
    activo   BOOLEAN     NOT NULL DEFAULT TRUE
);

CREATE TABLE grado_instruccion (
    id                       SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo                   VARCHAR(30) NOT NULL UNIQUE,
    nombre                   VARCHAR(80) NOT NULL,
    cumple_primaria_completa BOOLEAN     NOT NULL,
    orden                    SMALLINT    NOT NULL,
    activo                   BOOLEAN     NOT NULL DEFAULT TRUE
);
COMMENT ON TABLE grado_instruccion IS 'Valores iniciales por confirmar con la plantilla de AVANZA. cumple_primaria_completa sirve a RN-14 (ciclo Técnico).';

CREATE TABLE modalidad_servicio (
    id     SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo VARCHAR(30) NOT NULL UNIQUE,
    nombre VARCHAR(60) NOT NULL,
    activo BOOLEAN     NOT NULL DEFAULT TRUE
);

CREATE TABLE modelo_educativo (
    id     SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo VARCHAR(30) NOT NULL UNIQUE,
    nombre VARCHAR(60) NOT NULL,
    activo BOOLEAN     NOT NULL DEFAULT TRUE
);

CREATE TABLE situacion_especifica (
    id          SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo      VARCHAR(30) NOT NULL UNIQUE,
    nombre      VARCHAR(60) NOT NULL,
    es_sensible BOOLEAN     NOT NULL DEFAULT FALSE,
    activo      BOOLEAN     NOT NULL DEFAULT TRUE
);
COMMENT ON TABLE situacion_especifica IS 'Situaciones del Anexo 1 (PIR, Transitabilidad, MOT, Discapacidad, otras). Acceso restringido; sin documentos (RN-17).';

CREATE TABLE ubigeo (
    codigo       CHAR(6)      PRIMARY KEY,
    departamento VARCHAR(60)  NOT NULL,
    provincia    VARCHAR(60)  NOT NULL,
    distrito     VARCHAR(60)  NOT NULL,
    CONSTRAINT ck_ubigeo_codigo CHECK (codigo ~ '^[0-9]{6}$')
);
COMMENT ON TABLE ubigeo IS 'Códigos INEI. Los datos se cargan aparte (no se incluyen en este script).';

-- ---------------------------------------------------------------------
-- 5. CATÁLOGO ACADÉMICO
-- ---------------------------------------------------------------------
CREATE TABLE familia_profesional (
    id_familia SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre     VARCHAR(80) NOT NULL UNIQUE,
    activo     BOOLEAN     NOT NULL DEFAULT TRUE
);

CREATE TABLE programa_estudios (
    id_programa      SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_familia       SMALLINT        REFERENCES familia_profesional (id_familia),
    nombre           VARCHAR(120)    NOT NULL,
    ciclo            ciclo_formativo NOT NULL,
    creditos_minimos SMALLINT        NOT NULL,
    activo           BOOLEAN         NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_programa UNIQUE (nombre, ciclo),
    CONSTRAINT ck_creditos_ciclo CHECK (
        (ciclo = 'AUXILIAR_TECNICO' AND creditos_minimos >= 40) OR
        (ciclo = 'TECNICO'          AND creditos_minimos >= 80))
);
COMMENT ON TABLE programa_estudios IS 'Antes "especialidad". Ciclo Auxiliar Técnico (>= 40 créditos) o Técnico (>= 80), según el DL 1375 y la LAG.';

CREATE TABLE plan_estudios (
    id_plan              INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_programa          SMALLINT    NOT NULL REFERENCES programa_estudios (id_programa),
    tipo_resolucion      VARCHAR(30) NOT NULL,
    numero_resolucion    VARCHAR(30) NOT NULL,
    anio_resolucion      SMALLINT    NOT NULL,
    vigente              BOOLEAN     NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_plan UNIQUE (id_programa, tipo_resolucion, numero_resolucion, anio_resolucion),
    CONSTRAINT ck_plan_anio CHECK (anio_resolucion BETWEEN 2000 AND 2100)
);
COMMENT ON TABLE plan_estudios IS 'AVANZA exige la resolución de autorización (tipo, número y año) antes de registrar módulos.';

CREATE TABLE modulo_formativo (
    id_modulo INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_plan   INTEGER      NOT NULL REFERENCES plan_estudios (id_plan),
    nombre    VARCHAR(150) NOT NULL,
    orden     SMALLINT     NOT NULL DEFAULT 1,
    creditos  SMALLINT,
    horas     SMALLINT,
    activo    BOOLEAN      NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_modulo UNIQUE (id_plan, nombre),
    CONSTRAINT ck_modulo_cred_horas CHECK ((creditos IS NULL OR creditos > 0) AND (horas IS NULL OR horas > 0))
);

CREATE TABLE unidad_didactica (
    id_unidad                   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_modulo                   INTEGER      NOT NULL REFERENCES modulo_formativo (id_modulo),
    nombre                      VARCHAR(150) NOT NULL,
    creditos                    SMALLINT     NOT NULL,
    horas                       SMALLINT     NOT NULL,
    periodo_academico_sugerido  SMALLINT,
    activo                      BOOLEAN      NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_unidad UNIQUE (id_modulo, nombre),
    CONSTRAINT ck_unidad_cred_horas CHECK (creditos > 0 AND horas > 0)
);

CREATE TABLE periodo_lectivo (
    id_periodo    SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo        VARCHAR(10) NOT NULL UNIQUE,
    fecha_inicio  DATE        NOT NULL,
    fecha_fin     DATE        NOT NULL,
    inicio_clases DATE,
    fin_clases    DATE,
    vigente       BOOLEAN     NOT NULL DEFAULT FALSE,
    CONSTRAINT ck_periodo_fechas CHECK (fecha_fin > fecha_inicio),
    CONSTRAINT ck_periodo_clases CHECK (inicio_clases IS NULL OR fin_clases IS NULL OR fin_clases >= inicio_clases)
);
COMMENT ON TABLE periodo_lectivo IS 'Periodo calendario (por ejemplo 2026-I). No confundir con el periodo académico del estudiante (ordinal del programa).';
CREATE UNIQUE INDEX uq_periodo_unico_vigente ON periodo_lectivo (vigente) WHERE vigente;

CREATE TABLE docente (
    id_docente INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombres    VARCHAR(80) NOT NULL,
    apellidos  VARCHAR(80) NOT NULL,
    activo     BOOLEAN     NOT NULL DEFAULT TRUE
);
COMMENT ON TABLE docente IS 'Dato informativo de la oferta. No guarda documento: no se gestionan horarios ni planillas.';

CREATE TABLE oferta (
    id_oferta        INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_programa      SMALLINT NOT NULL REFERENCES programa_estudios (id_programa),
    id_periodo       SMALLINT NOT NULL REFERENCES periodo_lectivo (id_periodo),
    id_turno         SMALLINT NOT NULL REFERENCES turno (id_turno),
    id_docente       INTEGER           REFERENCES docente (id_docente),
    id_modalidad     SMALLINT          REFERENCES modalidad_servicio (id),
    id_modelo        SMALLINT          REFERENCES modelo_educativo (id),
    cupo_referencial SMALLINT NOT NULL DEFAULT 30,
    activa           BOOLEAN  NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_oferta UNIQUE (id_programa, id_periodo, id_turno),
    CONSTRAINT uq_oferta_clave_compuesta UNIQUE (id_oferta, id_programa, id_periodo),
    CONSTRAINT ck_cupo_positivo CHECK (cupo_referencial > 0)
);
COMMENT ON COLUMN oferta.cupo_referencial IS 'Referencia (30). NO es un límite: no hay tope de vacantes (RN-04).';

-- ---------------------------------------------------------------------
-- 6. ESTUDIANTE
-- ---------------------------------------------------------------------
CREATE TABLE estudiante (
    id_estudiante        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    uid                  UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    tipo_documento       tipo_documento_identidad NOT NULL,
    numero_documento     VARCHAR(15) NOT NULL,
    apellido_paterno     VARCHAR(60) NOT NULL,
    apellido_materno     VARCHAR(60),
    nombres              VARCHAR(80) NOT NULL,
    sexo                 sexo        NOT NULL,
    fecha_nacimiento     DATE        NOT NULL,
    id_grado_instruccion SMALLINT    NOT NULL REFERENCES grado_instruccion (id),
    ubigeo               CHAR(6)              REFERENCES ubigeo (codigo),
    direccion            VARCHAR(150),
    correo               VARCHAR(120),
    telefono_fijo        VARCHAR(15),
    celular              VARCHAR(15),
    fecha_registro       TIMESTAMPTZ NOT NULL DEFAULT now(),
    fecha_actualizacion  TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_estudiante_documento UNIQUE (tipo_documento, numero_documento),
    CONSTRAINT ck_estudiante_documento CHECK (
        (tipo_documento = 'DNI' AND numero_documento ~ '^[0-9]{8}$') OR
        (tipo_documento <> 'DNI' AND numero_documento ~ '^[A-Za-z0-9]{6,15}$')),
    CONSTRAINT ck_estudiante_nacimiento CHECK (fecha_nacimiento < CURRENT_DATE),
    CONSTRAINT ck_estudiante_correo   CHECK (correo IS NULL OR correo ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
    CONSTRAINT ck_estudiante_celular  CHECK (celular IS NULL OR celular ~ '^[0-9+ ]{7,15}$'),
    CONSTRAINT ck_estudiante_telefono CHECK (telefono_fijo IS NULL OR telefono_fijo ~ '^[0-9+ ()-]{6,15}$')
);
COMMENT ON TABLE estudiante IS 'Datos mínimos. Sin copia del DNI, sin evidencia socioeconómica y sin documentos de discapacidad (RN-17). Dirección, ubigeo, correo y teléfonos se piden porque AVANZA los exige.';
COMMENT ON COLUMN estudiante.uid IS 'Identificador opaco para URL y APIs. Nunca se usa el documento en una URL.';

CREATE INDEX ix_estudiante_apellidos ON estudiante (apellido_paterno, apellido_materno, nombres);

DO $idx$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_trgm') THEN
        EXECUTE 'CREATE INDEX ix_estudiante_busqueda ON matricula.estudiante USING gin (
                 (apellido_paterno || '' '' || coalesce(apellido_materno, '''') || '' '' || nombres) gin_trgm_ops)';
    END IF;
END
$idx$;

-- ---------------------------------------------------------------------
-- 7. AVISO DE PRIVACIDAD
-- ---------------------------------------------------------------------
CREATE TABLE aviso_privacidad_version (
    id_aviso      SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    version       VARCHAR(20) NOT NULL UNIQUE,
    texto         TEXT        NOT NULL,
    vigente_desde DATE        NOT NULL,
    vigente_hasta DATE,
    CONSTRAINT ck_aviso_fechas CHECK (vigente_hasta IS NULL OR vigente_hasta >= vigente_desde)
);
COMMENT ON TABLE aviso_privacidad_version IS 'Aviso con los diez elementos del art. 6 del DS 016-2024-JUS, en lenguaje claro. Versionado.';

-- ---------------------------------------------------------------------
-- 8. MATRÍCULA
-- ---------------------------------------------------------------------
CREATE TABLE matricula (
    id_matricula          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    uid                   UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    codigo_matricula      VARCHAR(15) NOT NULL,
    id_estudiante         BIGINT   NOT NULL REFERENCES estudiante (id_estudiante),
    id_oferta             INTEGER  NOT NULL,
    id_programa           SMALLINT NOT NULL,
    id_periodo            SMALLINT NOT NULL,
    tipo_ingreso          tipo_ingreso     NOT NULL DEFAULT 'NUEVO',
    estado                estado_matricula NOT NULL DEFAULT 'VIGENTE',
    id_matricula_anterior BIGINT   REFERENCES matricula (id_matricula),
    id_programa_origen    SMALLINT REFERENCES programa_estudios (id_programa),
    institucion_origen    VARCHAR(150),
    fecha_matricula       TIMESTAMPTZ NOT NULL DEFAULT now(),
    edad_minima_aplicada  SMALLINT    NOT NULL,
    edad_al_matricular    SMALLINT    NOT NULL,
    motivo_cambio_estado  VARCHAR(250),
    fecha_cambio_estado   TIMESTAMPTZ,
    requisitos_verificados JSONB      NOT NULL DEFAULT '{}'::jsonb,
    id_aviso_privacidad   SMALLINT REFERENCES aviso_privacidad_version (id_aviso),
    observaciones         VARCHAR(250),
    id_usuario_registra   UUID        NOT NULL REFERENCES identidad.usuario (id),
    fecha_actualizacion   TIMESTAMPTZ NOT NULL DEFAULT now(),
    version               INTEGER     NOT NULL DEFAULT 1,
    CONSTRAINT fk_matricula_oferta FOREIGN KEY (id_oferta, id_programa, id_periodo)
        REFERENCES oferta (id_oferta, id_programa, id_periodo),
    CONSTRAINT ck_traslado_origen CHECK (tipo_ingreso <> 'TRASLADADO' OR institucion_origen IS NOT NULL),
    CONSTRAINT ck_anulada_motivo  CHECK (estado <> 'ANULADA' OR motivo_cambio_estado IS NOT NULL)
);
COMMENT ON TABLE matricula IS 'Una matrícula por estudiante, programa y periodo lectivo. La ratificación y la reincorporación crean una matrícula nueva enlazada a la anterior.';
COMMENT ON COLUMN matricula.codigo_matricula IS 'Número de documento del estudiante (LAG 11.2.2). Lo fija el disparador.';
COMMENT ON COLUMN matricula.edad_minima_aplicada IS 'Valor del parámetro edad_minima con el que se validó (AD-19).';
COMMENT ON COLUMN matricula.version IS 'Control de concurrencia optimista: la aplicación actualiza con WHERE version = @version.';

-- RN-13: una sola matrícula vigente por estudiante, programa y periodo lectivo
CREATE UNIQUE INDEX uq_matricula_vigente ON matricula (id_estudiante, id_programa, id_periodo) WHERE estado = 'VIGENTE';
CREATE INDEX ix_matricula_oferta     ON matricula (id_oferta);
CREATE INDEX ix_matricula_estudiante ON matricula (id_estudiante);
CREATE INDEX ix_matricula_fecha      ON matricula (fecha_matricula);
CREATE INDEX ix_matricula_codigo     ON matricula (codigo_matricula);

CREATE TABLE matricula_modulo (
    id_matricula               BIGINT   NOT NULL REFERENCES matricula (id_matricula),
    id_modulo                  INTEGER  NOT NULL REFERENCES modulo_formativo (id_modulo),
    periodo_academico_numero   SMALLINT NOT NULL,
    PRIMARY KEY (id_matricula, id_modulo),
    CONSTRAINT ck_matricula_modulo_periodo CHECK (periodo_academico_numero > 0)
);
COMMENT ON TABLE matricula_modulo IS 'Módulo(s) que cursa el estudiante en la matrícula y su periodo académico, como en AVANZA y el Anexo 1.';

CREATE TABLE matricula_situacion (
    id_matricula BIGINT   NOT NULL REFERENCES matricula (id_matricula),
    id_situacion SMALLINT NOT NULL REFERENCES situacion_especifica (id),
    detalle      VARCHAR(150),
    PRIMARY KEY (id_matricula, id_situacion)
);
COMMENT ON TABLE matricula_situacion IS 'Acceso restringido (permiso SITUACION_ESPECIFICA_VER). Sin documentos ni diagnósticos.';

CREATE TABLE convalidacion (
    id_convalidacion              INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_matricula                  BIGINT NOT NULL REFERENCES matricula (id_matricula),
    tipo                          tipo_convalidacion NOT NULL,
    resolucion_directoral         VARCHAR(40)  NOT NULL,
    fecha_resolucion              DATE,
    justificacion                 VARCHAR(500) NOT NULL,
    ruta_formativa_complementaria VARCHAR(500),
    id_usuario_registra           UUID NOT NULL REFERENCES identidad.usuario (id),
    fecha_registro                TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE convalidacion IS 'LAG 11.5: se registra por resolución directoral, con justificación y ruta formativa complementaria.';

CREATE TABLE convalidacion_unidad (
    id_convalidacion INTEGER  NOT NULL REFERENCES convalidacion (id_convalidacion),
    id_unidad        INTEGER  NOT NULL REFERENCES unidad_didactica (id_unidad),
    similitud_pct    NUMERIC(5,2) NOT NULL,
    PRIMARY KEY (id_convalidacion, id_unidad),
    CONSTRAINT ck_similitud_rango CHECK (similitud_pct BETWEEN 0 AND 100)
);

CREATE TABLE matricula_excepcion_unidad (
    id_matricula     BIGINT   NOT NULL REFERENCES matricula (id_matricula),
    id_unidad        INTEGER  NOT NULL REFERENCES unidad_didactica (id_unidad),
    condicion        condicion_unidad NOT NULL,
    id_convalidacion INTEGER  REFERENCES convalidacion (id_convalidacion),
    PRIMARY KEY (id_matricula, id_unidad),
    CONSTRAINT ck_excepcion_convalidacion CHECK (
        (condicion = 'CONVALIDADA' AND id_convalidacion IS NOT NULL) OR
        (condicion = 'SUBSANACION'  AND id_convalidacion IS NULL))
);
COMMENT ON TABLE matricula_excepcion_unidad IS 'Solo las excepciones: las unidades del módulo se derivan del plan de estudios.';

CREATE TABLE licencia_estudios (
    id_licencia                    INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_matricula                   BIGINT NOT NULL REFERENCES matricula (id_matricula),
    fecha_inicio                   DATE   NOT NULL,
    fecha_fin_prevista             DATE,
    fecha_limite_reincorporacion   DATE,
    estado                         estado_licencia NOT NULL DEFAULT 'VIGENTE',
    id_matricula_reincorporacion   BIGINT REFERENCES matricula (id_matricula),
    id_usuario_registra            UUID NOT NULL REFERENCES identidad.usuario (id),
    fecha_registro                 TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT ck_licencia_fechas CHECK (
        (fecha_fin_prevista IS NULL OR fecha_fin_prevista >= fecha_inicio) AND
        (fecha_limite_reincorporacion IS NULL OR fecha_limite_reincorporacion >= fecha_inicio)),
    CONSTRAINT ck_licencia_reincorporada CHECK (estado <> 'REINCORPORADO' OR id_matricula_reincorporacion IS NOT NULL)
);
COMMENT ON TABLE licencia_estudios IS 'LAG 11.3 y 11.4. El plazo de reserva (plazo_reserva_licencia_dias) está por definir.';
CREATE UNIQUE INDEX uq_licencia_vigente ON licencia_estudios (id_matricula) WHERE estado = 'VIGENTE';

-- ---------------------------------------------------------------------
-- 9. CONVENIOS, BECAS Y DERECHO DE INSCRIPCIÓN
-- ---------------------------------------------------------------------
CREATE TABLE convenio (
    id_convenio       SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    institucion       VARCHAR(150) NOT NULL,
    descripcion       VARCHAR(250),
    porcentaje_maximo NUMERIC(5,2) NOT NULL DEFAULT 50.00,
    fecha_inicio      DATE,
    fecha_fin         DATE,
    activo            BOOLEAN      NOT NULL DEFAULT TRUE,
    CONSTRAINT ck_convenio_porcentaje CHECK (porcentaje_maximo > 0 AND porcentaje_maximo <= 100),
    CONSTRAINT ck_convenio_fechas CHECK (fecha_fin IS NULL OR fecha_inicio IS NULL OR fecha_fin >= fecha_inicio)
);
COMMENT ON TABLE convenio IS 'El tope real lo fija el parámetro beca_porcentaje_maximo (inicial 50). Se guarda solo el resultado, nunca evidencia de ingresos.';

CREATE TABLE pago_inscripcion (
    id_pago              INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_matricula         BIGINT NOT NULL UNIQUE REFERENCES matricula (id_matricula),
    id_convenio          SMALLINT REFERENCES convenio (id_convenio),
    monto_base           NUMERIC(8,2) NOT NULL,
    tipo_exoneracion     tipo_exoneracion NOT NULL DEFAULT 'NINGUNA',
    porcentaje_desc      NUMERIC(5,2) NOT NULL DEFAULT 0,
    monto_pagado         NUMERIC(8,2) NOT NULL,
    nro_comprobante      VARCHAR(30),
    referencia_resolucion VARCHAR(60),
    fecha_pago           DATE NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT ck_pago_monto_base   CHECK (monto_base >= 0),
    CONSTRAINT ck_pago_porcentaje   CHECK (porcentaje_desc >= 0 AND porcentaje_desc <= 100),
    CONSTRAINT ck_pago_monto_pagado CHECK (monto_pagado >= 0 AND monto_pagado <= monto_base),
    CONSTRAINT ck_pago_coherencia_desc CHECK (
        (tipo_exoneracion = 'NINGUNA' AND porcentaje_desc = 0) OR
        (tipo_exoneracion <> 'NINGUNA' AND porcentaje_desc > 0)),
    CONSTRAINT ck_pago_convenio_requerido CHECK (tipo_exoneracion = 'NINGUNA' OR id_convenio IS NOT NULL),
    CONSTRAINT ck_pago_calculo CHECK (monto_pagado = ROUND(monto_base * (1 - porcentaje_desc / 100.0), 2))
);
COMMENT ON TABLE pago_inscripcion IS 'Solo se registra el derecho de inscripción; no se cobra desde el sistema.';

-- ---------------------------------------------------------------------
-- 10. DOCUMENTOS EMITIDOS
-- ---------------------------------------------------------------------
CREATE TABLE documento_emitido (
    id_documento        INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tipo                tipo_documento_emitido NOT NULL,
    id_matricula        BIGINT REFERENCES matricula (id_matricula),
    id_usuario          UUID   NOT NULL REFERENCES identidad.usuario (id),
    codigo_documento    VARCHAR(30) NOT NULL UNIQUE,
    formato             VARCHAR(5)  NOT NULL,
    filtros             JSONB,
    hash_sha256         CHAR(64),
    fecha_emision       TIMESTAMPTZ NOT NULL DEFAULT now(),
    revocado_en         TIMESTAMPTZ,
    motivo_revocacion   VARCHAR(250),
    CONSTRAINT ck_doc_formato    CHECK (formato IN ('PDF', 'XLSX')),
    CONSTRAINT ck_doc_hash       CHECK (hash_sha256 IS NULL OR hash_sha256 ~ '^[0-9a-f]{64}$'),
    CONSTRAINT ck_doc_referencia CHECK (tipo <> 'CONSTANCIA_ESTUDIOS' OR id_matricula IS NOT NULL),
    CONSTRAINT ck_doc_revocacion CHECK (revocado_en IS NULL OR motivo_revocacion IS NOT NULL)
);
COMMENT ON TABLE documento_emitido IS 'La constancia lleva código único, hash y verificación pública por QR (AD-11). Toda exportación se registra además en la bitácora.';
CREATE INDEX ix_documento_matricula ON documento_emitido (id_matricula);

-- ---------------------------------------------------------------------
-- 11. CUMPLIMIENTO: DERECHOS, INCIDENTES Y ALERTAS
-- ---------------------------------------------------------------------
CREATE TABLE solicitud_derechos (
    id_solicitud        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_estudiante       BIGINT NOT NULL REFERENCES estudiante (id_estudiante),
    tipo                tipo_solicitud_derecho NOT NULL,
    estado              estado_solicitud NOT NULL DEFAULT 'RECIBIDA',
    fecha_recepcion     DATE NOT NULL DEFAULT CURRENT_DATE,
    plazo_dias_habiles  SMALLINT NOT NULL,
    fecha_limite        DATE NOT NULL,
    ampliado            BOOLEAN NOT NULL DEFAULT FALSE,
    detalle             VARCHAR(500),
    respuesta           VARCHAR(500),
    fecha_respuesta     DATE,
    id_usuario_registra UUID NOT NULL REFERENCES identidad.usuario (id),
    id_usuario_responde UUID REFERENCES identidad.usuario (id),
    CONSTRAINT ck_solicitud_plazo  CHECK (plazo_dias_habiles IN (8, 10, 20, 16, 40)),
    CONSTRAINT ck_solicitud_limite CHECK (fecha_limite >= fecha_recepcion)
);
COMMENT ON TABLE solicitud_derechos IS 'DS 016-2024-JUS arts. 66 a 71: información 8, acceso 20, rectificación/cancelación/oposición 10 días hábiles; ampliables una vez por igual plazo. El cálculo de días hábiles lo hace la aplicación.';

CREATE TABLE incidente_seguridad (
    id_incidente               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fecha_deteccion            TIMESTAMPTZ NOT NULL,
    descripcion                VARCHAR(1000) NOT NULL,
    tipos_datos                VARCHAR(250),
    personas_afectadas_aprox   INTEGER,
    afecta_datos_sensibles     BOOLEAN NOT NULL DEFAULT FALSE,
    perjuicio_evidente         BOOLEAN NOT NULL DEFAULT FALSE,
    requiere_notificacion      BOOLEAN NOT NULL DEFAULT FALSE,
    notificado_autoridad_en    TIMESTAMPTZ,
    notificado_titulares_en    TIMESTAMPTZ,
    notificado_cnsd_en         TIMESTAMPTZ,
    medidas_adoptadas          VARCHAR(1000),
    estado                     VARCHAR(20) NOT NULL DEFAULT 'ABIERTO',
    id_usuario_registra        UUID NOT NULL REFERENCES identidad.usuario (id),
    CONSTRAINT ck_incidente_estado CHECK (estado IN ('ABIERTO', 'CONTENIDO', 'CERRADO')),
    CONSTRAINT ck_incidente_notif  CHECK (notificado_autoridad_en IS NULL OR requiere_notificacion)
);
COMMENT ON TABLE incidente_seguridad IS 'DS 016-2024-JUS arts. 34 a 36: todo incidente se documenta; se notifica en 48 horas cuando expone grandes volúmenes, afecta a muchas personas, involucra datos sensibles o causa perjuicio evidente.';

CREATE TABLE alerta (
    id_alerta          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tipo               VARCHAR(40)  NOT NULL,
    clave_dedupe       VARCHAR(120) NOT NULL,
    titulo             VARCHAR(150) NOT NULL,
    detalle            JSONB,
    roles_destino      VARCHAR(30)[] NOT NULL,
    estado             estado_alerta NOT NULL DEFAULT 'ACTIVA',
    creada_en          TIMESTAMPTZ  NOT NULL DEFAULT now(),
    atendida_en        TIMESTAMPTZ,
    id_usuario_atiende UUID REFERENCES identidad.usuario (id),
    CONSTRAINT ck_alerta_cierre CHECK (estado = 'ACTIVA' OR atendida_en IS NOT NULL)
);
COMMENT ON TABLE alerta IS 'Alertas dentro del sistema (AD-34). Ciclo Activa -> Atendida o Descartada. Sin correo ni mensajería en el MVP.';
CREATE UNIQUE INDEX uq_alerta_activa_dedupe ON alerta (clave_dedupe) WHERE estado = 'ACTIVA';

-- ---------------------------------------------------------------------
-- 12. BITÁCORA (solo inserción)
-- ---------------------------------------------------------------------
CREATE TABLE auditoria.bitacora (
    id_bitacora BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_usuario  UUID REFERENCES identidad.usuario (id),
    accion      auditoria.accion_auditoria NOT NULL,
    entidad     VARCHAR(40) NOT NULL,
    id_registro VARCHAR(40),
    detalle     JSONB,
    ip_origen   INET,
    fecha_hora  TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE auditoria.bitacora IS 'DS 016-2024-JUS art. 46: sesión, lectura, modificación, eliminación, importación y exportación; conservar >= 2 años. Solo inserción. Nunca guarda contraseñas ni datos sensibles: solo nombres de columnas e identificadores.';
CREATE INDEX ix_bitacora_fecha   ON auditoria.bitacora (fecha_hora DESC);
CREATE INDEX ix_bitacora_usuario ON auditoria.bitacora (id_usuario);
CREATE INDEX ix_bitacora_entidad ON auditoria.bitacora (entidad, id_registro);

-- ---------------------------------------------------------------------
-- 13. FUNCIONES Y DISPARADORES DE NEGOCIO (segunda defensa)
-- ---------------------------------------------------------------------

-- 13.1 Bitácora inmutable (la depuración solo es posible por la función autorizada)
CREATE FUNCTION auditoria.fn_bitacora_inmutable() RETURNS trigger
LANGUAGE plpgsql AS
$fn$
BEGIN
    IF TG_OP = 'DELETE' THEN
        IF current_setting('cetpro.depuracion_autorizada', true) = 'on'
           AND OLD.fecha_hora < now() - make_interval(years => matricula.fn_param_int('retencion_bitacora_anios')) THEN
            RETURN OLD;
        END IF;
    END IF;
    RAISE EXCEPTION 'La bitácora es de solo inserción' USING ERRCODE = 'insufficient_privilege';
END
$fn$;

CREATE TRIGGER trg_bitacora_inmutable
    BEFORE UPDATE OR DELETE ON auditoria.bitacora
    FOR EACH ROW EXECUTE FUNCTION auditoria.fn_bitacora_inmutable();

CREATE TRIGGER trg_bitacora_sin_truncate
    BEFORE TRUNCATE ON auditoria.bitacora
    FOR EACH STATEMENT EXECUTE FUNCTION auditoria.fn_bitacora_inmutable();

CREATE FUNCTION auditoria.depurar_bitacora() RETURNS bigint
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = auditoria, matricula, pg_temp AS
$fn$
DECLARE n bigint;
BEGIN
    PERFORM set_config('cetpro.depuracion_autorizada', 'on', true);
    DELETE FROM auditoria.bitacora
     WHERE fecha_hora < now() - make_interval(years => matricula.fn_param_int('retencion_bitacora_anios'));
    GET DIAGNOSTICS n = ROW_COUNT;
    PERFORM set_config('cetpro.depuracion_autorizada', 'off', true);
    RETURN n;
END
$fn$;
REVOKE ALL ON FUNCTION auditoria.depurar_bitacora() FROM PUBLIC;
COMMENT ON FUNCTION auditoria.depurar_bitacora() IS 'Borra solo lo anterior al periodo de retención. Conceder únicamente al rol migrador/operación (RF-38, iteración 3).';

-- 13.2 Auditoría automática de cambios (nombres de columnas e identificadores, sin valores)
CREATE FUNCTION auditoria.fn_auditar_cambio() RETURNS trigger
LANGUAGE plpgsql AS
$fn$
DECLARE
    v_usuario uuid;
    v_ip      inet;
    v_accion  auditoria.accion_auditoria;
    v_id      text;
    v_cols    text[];
    v_fila    jsonb;
BEGIN
    BEGIN v_usuario := NULLIF(current_setting('cetpro.usuario_id', true), '')::uuid;
    EXCEPTION WHEN others THEN v_usuario := NULL; END;
    BEGIN v_ip := NULLIF(current_setting('cetpro.ip_origen', true), '')::inet;
    EXCEPTION WHEN others THEN v_ip := NULL; END;

    IF TG_OP = 'INSERT' THEN
        v_accion := 'CREACION';
        v_fila := to_jsonb(NEW);
    ELSIF TG_OP = 'UPDATE' THEN
        v_accion := 'MODIFICACION';
        v_fila := to_jsonb(NEW);
        SELECT array_agg(n.key ORDER BY n.key) INTO v_cols
          FROM jsonb_each(to_jsonb(NEW)) AS n(key, value)
          LEFT JOIN jsonb_each(to_jsonb(OLD)) AS o(key, value) ON o.key = n.key
         WHERE n.value IS DISTINCT FROM o.value
           AND n.key NOT IN ('version', 'fecha_actualizacion');
        IF v_cols IS NULL THEN
            RETURN NULL;
        END IF;
    ELSE
        v_accion := 'ELIMINACION';
        v_fila := to_jsonb(OLD);
    END IF;

    v_id := v_fila ->> TG_ARGV[0];
    INSERT INTO auditoria.bitacora (id_usuario, accion, entidad, id_registro, detalle, ip_origen)
    VALUES (v_usuario, v_accion, TG_TABLE_NAME, v_id,
            CASE WHEN v_cols IS NULL THEN NULL ELSE jsonb_build_object('columnas', to_jsonb(v_cols)) END,
            v_ip);
    RETURN NULL;
END
$fn$;
COMMENT ON FUNCTION auditoria.fn_auditar_cambio() IS 'La aplicación fija SET LOCAL cetpro.usuario_id y cetpro.ip_origen al abrir la transacción. Las lecturas y exportaciones las registra la aplicación.';

-- 13.3 Estudiante
CREATE FUNCTION fn_estudiante_actualizar() RETURNS trigger
LANGUAGE plpgsql AS
$fn$
BEGIN
    NEW.fecha_actualizacion := now();
    RETURN NEW;
END
$fn$;
CREATE TRIGGER trg_estudiante_actualizar BEFORE UPDATE ON estudiante
    FOR EACH ROW EXECUTE FUNCTION fn_estudiante_actualizar();

-- 13.4 Matrícula: validaciones al insertar (RN-01, RN-09, RN-14)
CREATE FUNCTION fn_matricula_antes_insertar() RETURNS trigger
LANGUAGE plpgsql AS
$fn$
DECLARE
    v_est        matricula.estudiante%ROWTYPE;
    v_ciclo      matricula.ciclo_formativo;
    v_min        integer;
    v_ref        text;
    v_fecha_ref  date;
    v_edad       integer;
    v_primaria   boolean;
BEGIN
    SELECT * INTO v_est FROM matricula.estudiante WHERE id_estudiante = NEW.id_estudiante;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'El estudiante % no existe.', NEW.id_estudiante USING ERRCODE = 'foreign_key_violation';
    END IF;

    -- RN-09: el código de matrícula es el número de documento
    NEW.codigo_matricula := v_est.numero_documento;
    IF NEW.fecha_matricula IS NULL THEN
        NEW.fecha_matricula := now();
    END IF;

    -- RN-01: edad mínima configurable, con fecha de referencia configurable
    v_min := matricula.fn_param_int('edad_minima');
    v_ref := matricula.fn_param_text('edad_referencia');
    IF v_ref = 'INICIO_PERIODO' THEN
        SELECT fecha_inicio INTO v_fecha_ref FROM matricula.periodo_lectivo WHERE id_periodo = NEW.id_periodo;
    ELSE
        v_fecha_ref := (NEW.fecha_matricula AT TIME ZONE 'America/Lima')::date;
    END IF;
    v_edad := date_part('year', age(v_fecha_ref, v_est.fecha_nacimiento))::integer;
    NEW.edad_minima_aplicada := v_min;
    NEW.edad_al_matricular   := v_edad;
    IF v_edad < v_min THEN
        RAISE EXCEPTION 'RN-01: el estudiante debe tener al menos % años (tiene %).', v_min, v_edad
            USING ERRCODE = 'check_violation';
    END IF;

    -- RN-14: el ciclo Técnico exige Primaria completa o ciclo intermedio de EBA
    SELECT p.ciclo INTO v_ciclo FROM matricula.programa_estudios p WHERE p.id_programa = NEW.id_programa;
    IF v_ciclo = 'TECNICO' THEN
        SELECT g.cumple_primaria_completa INTO v_primaria
          FROM matricula.grado_instruccion g WHERE g.id = v_est.id_grado_instruccion;
        IF NOT COALESCE(v_primaria, false) THEN
            RAISE EXCEPTION 'RN-14: el ciclo Técnico exige Primaria completa o el ciclo intermedio de EBA.'
                USING ERRCODE = 'check_violation';
        END IF;
    END IF;
    RETURN NEW;
END
$fn$;
CREATE TRIGGER trg_matricula_antes_insertar BEFORE INSERT ON matricula
    FOR EACH ROW EXECUTE FUNCTION fn_matricula_antes_insertar();

-- 13.5 Matrícula: máquina de estados y columnas inmutables (RN-15)
CREATE FUNCTION fn_matricula_antes_actualizar() RETURNS trigger
LANGUAGE plpgsql AS
$fn$
BEGIN
    IF NEW.id_estudiante IS DISTINCT FROM OLD.id_estudiante
       OR NEW.id_oferta IS DISTINCT FROM OLD.id_oferta
       OR NEW.id_programa IS DISTINCT FROM OLD.id_programa
       OR NEW.id_periodo IS DISTINCT FROM OLD.id_periodo
       OR NEW.codigo_matricula IS DISTINCT FROM OLD.codigo_matricula
       OR NEW.fecha_matricula IS DISTINCT FROM OLD.fecha_matricula
       OR NEW.edad_minima_aplicada IS DISTINCT FROM OLD.edad_minima_aplicada
       OR NEW.edad_al_matricular IS DISTINCT FROM OLD.edad_al_matricular THEN
        RAISE EXCEPTION 'La matrícula no permite cambiar el estudiante, la oferta, el código ni la edad aplicada; anule y registre una nueva.'
            USING ERRCODE = 'check_violation';
    END IF;

    IF NEW.estado IS DISTINCT FROM OLD.estado THEN
        IF NOT (
            (OLD.estado = 'VIGENTE' AND NEW.estado IN ('ANULADA', 'RETIRADA', 'LICENCIA')) OR
            (OLD.estado = 'LICENCIA' AND NEW.estado = 'RETIRADA')
        ) THEN
            RAISE EXCEPTION 'Transición de estado no permitida: % a %', OLD.estado, NEW.estado
                USING ERRCODE = 'check_violation';
        END IF;
        NEW.fecha_cambio_estado := now();
    END IF;

    NEW.version := OLD.version + 1;
    NEW.fecha_actualizacion := now();
    RETURN NEW;
END
$fn$;
CREATE TRIGGER trg_matricula_antes_actualizar BEFORE UPDATE ON matricula
    FOR EACH ROW EXECUTE FUNCTION fn_matricula_antes_actualizar();

-- 13.6 Módulo de la matrícula: debe pertenecer al programa de la oferta
CREATE FUNCTION fn_matricula_modulo_validar() RETURNS trigger
LANGUAGE plpgsql AS
$fn$
DECLARE v_ok boolean;
BEGIN
    SELECT EXISTS (
        SELECT 1
          FROM matricula.matricula m
          JOIN matricula.modulo_formativo mf ON mf.id_modulo = NEW.id_modulo
          JOIN matricula.plan_estudios pe ON pe.id_plan = mf.id_plan
         WHERE m.id_matricula = NEW.id_matricula
           AND pe.id_programa = m.id_programa
    ) INTO v_ok;
    IF NOT v_ok THEN
        RAISE EXCEPTION 'El módulo no pertenece al programa de estudios de la matrícula.'
            USING ERRCODE = 'check_violation';
    END IF;
    RETURN NEW;
END
$fn$;
CREATE TRIGGER trg_matricula_modulo_validar BEFORE INSERT OR UPDATE ON matricula_modulo
    FOR EACH ROW EXECUTE FUNCTION fn_matricula_modulo_validar();

-- 13.7 Pago: tope de beca configurable (RN-06)
CREATE FUNCTION fn_pago_validar() RETURNS trigger
LANGUAGE plpgsql AS
$fn$
DECLARE
    v_tope_param numeric;
    v_tope_conv  numeric;
BEGIN
    IF NEW.porcentaje_desc > 0 THEN
        v_tope_param := matricula.fn_param_num('beca_porcentaje_maximo');
        SELECT c.porcentaje_maximo INTO v_tope_conv FROM matricula.convenio c WHERE c.id_convenio = NEW.id_convenio;
        IF NEW.porcentaje_desc > v_tope_param THEN
            RAISE EXCEPTION 'RN-06: el descuento (%) supera el tope configurado (%).', NEW.porcentaje_desc, v_tope_param
                USING ERRCODE = 'check_violation';
        END IF;
        IF v_tope_conv IS NOT NULL AND NEW.porcentaje_desc > v_tope_conv THEN
            RAISE EXCEPTION 'RN-06: el descuento (%) supera el máximo del convenio (%).', NEW.porcentaje_desc, v_tope_conv
                USING ERRCODE = 'check_violation';
        END IF;
    END IF;
    RETURN NEW;
END
$fn$;
CREATE TRIGGER trg_pago_validar BEFORE INSERT OR UPDATE ON pago_inscripcion
    FOR EACH ROW EXECUTE FUNCTION fn_pago_validar();

-- 13.8 Convalidación entre planes: similitud mínima configurable (RN-12)
CREATE FUNCTION fn_convalidacion_unidad_validar() RETURNS trigger
LANGUAGE plpgsql AS
$fn$
DECLARE
    v_tipo   matricula.tipo_convalidacion;
    v_minimo numeric;
BEGIN
    SELECT tipo INTO v_tipo FROM matricula.convalidacion WHERE id_convalidacion = NEW.id_convalidacion;
    IF v_tipo = 'ENTRE_PLANES' THEN
        v_minimo := matricula.fn_param_num('convalidacion_similitud_minima');
        IF NEW.similitud_pct < v_minimo THEN
            RAISE EXCEPTION 'RN-12: la similitud (%) es menor al mínimo configurado (%).', NEW.similitud_pct, v_minimo
                USING ERRCODE = 'check_violation';
        END IF;
    END IF;
    RETURN NEW;
END
$fn$;
CREATE TRIGGER trg_convalidacion_unidad_validar BEFORE INSERT OR UPDATE ON convalidacion_unidad
    FOR EACH ROW EXECUTE FUNCTION fn_convalidacion_unidad_validar();

-- 13.9 Licencia: la matrícula pasa a LICENCIA al registrarla (RN-11)
CREATE FUNCTION fn_licencia_despues_insertar() RETURNS trigger
LANGUAGE plpgsql AS
$fn$
BEGIN
    UPDATE matricula.matricula SET estado = 'LICENCIA'
     WHERE id_matricula = NEW.id_matricula AND estado = 'VIGENTE';
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Solo una matrícula VIGENTE puede pasar a licencia de estudios.'
            USING ERRCODE = 'check_violation';
    END IF;
    RETURN NULL;
END
$fn$;
CREATE TRIGGER trg_licencia_despues_insertar AFTER INSERT ON licencia_estudios
    FOR EACH ROW EXECUTE FUNCTION fn_licencia_despues_insertar();

-- 13.10 Auditoría automática en las tablas sensibles
CREATE TRIGGER trg_auditar_estudiante  AFTER INSERT OR UPDATE OR DELETE ON estudiante
    FOR EACH ROW EXECUTE FUNCTION auditoria.fn_auditar_cambio('id_estudiante');
CREATE TRIGGER trg_auditar_matricula   AFTER INSERT OR UPDATE OR DELETE ON matricula
    FOR EACH ROW EXECUTE FUNCTION auditoria.fn_auditar_cambio('id_matricula');
CREATE TRIGGER trg_auditar_pago        AFTER INSERT OR UPDATE OR DELETE ON pago_inscripcion
    FOR EACH ROW EXECUTE FUNCTION auditoria.fn_auditar_cambio('id_pago');
CREATE TRIGGER trg_auditar_convenio    AFTER INSERT OR UPDATE OR DELETE ON convenio
    FOR EACH ROW EXECUTE FUNCTION auditoria.fn_auditar_cambio('id_convenio');
CREATE TRIGGER trg_auditar_convalidacion AFTER INSERT OR UPDATE OR DELETE ON convalidacion
    FOR EACH ROW EXECUTE FUNCTION auditoria.fn_auditar_cambio('id_convalidacion');
CREATE TRIGGER trg_auditar_licencia    AFTER INSERT OR UPDATE OR DELETE ON licencia_estudios
    FOR EACH ROW EXECUTE FUNCTION auditoria.fn_auditar_cambio('id_licencia');
CREATE TRIGGER trg_auditar_parametro   AFTER INSERT OR UPDATE OR DELETE ON parametro_institucional
    FOR EACH ROW EXECUTE FUNCTION auditoria.fn_auditar_cambio('clave');
CREATE TRIGGER trg_auditar_situacion   AFTER INSERT OR UPDATE OR DELETE ON matricula_situacion
    FOR EACH ROW EXECUTE FUNCTION auditoria.fn_auditar_cambio('id_matricula');
CREATE TRIGGER trg_auditar_solicitud   AFTER INSERT OR UPDATE OR DELETE ON solicitud_derechos
    FOR EACH ROW EXECUTE FUNCTION auditoria.fn_auditar_cambio('id_solicitud');
CREATE TRIGGER trg_auditar_incidente   AFTER INSERT OR UPDATE OR DELETE ON incidente_seguridad
    FOR EACH ROW EXECUTE FUNCTION auditoria.fn_auditar_cambio('id_incidente');
CREATE TRIGGER trg_auditar_rol_permiso AFTER INSERT OR UPDATE OR DELETE ON identidad.rol_permiso
    FOR EACH ROW EXECUTE FUNCTION auditoria.fn_auditar_cambio('id_rol');

-- ---------------------------------------------------------------------
-- 14. VISTAS DE REPORTE Y DE APOYO A LA EXPORTACIÓN PARA AVANZA
--     (las columnas de exportación son PROVISIONALES según el manual de
--      AVANZA v3.5; confirmar con las plantillas Excel vigentes)
-- ---------------------------------------------------------------------
CREATE VIEW v_nomina_matriculados AS
SELECT  pl.codigo                 AS periodo_lectivo,
        p.nombre                  AS programa,
        p.ciclo,
        mf.nombre                 AS modulo,
        mm.periodo_academico_numero,
        t.nombre                  AS turno,
        e.tipo_documento,
        e.numero_documento,
        e.apellido_paterno,
        e.apellido_materno,
        e.nombres,
        m.tipo_ingreso,
        m.codigo_matricula,
        (m.fecha_matricula AT TIME ZONE 'America/Lima')::date AS fecha_matricula
FROM    matricula m
JOIN    estudiante e          ON e.id_estudiante = m.id_estudiante
JOIN    oferta o              ON o.id_oferta     = m.id_oferta
JOIN    programa_estudios p   ON p.id_programa   = o.id_programa
JOIN    periodo_lectivo pl    ON pl.id_periodo   = o.id_periodo
JOIN    turno t               ON t.id_turno      = o.id_turno
LEFT JOIN matricula_modulo mm ON mm.id_matricula = m.id_matricula
LEFT JOIN modulo_formativo mf ON mf.id_modulo    = mm.id_modulo
WHERE   m.estado = 'VIGENTE';

CREATE VIEW v_matriculados_por_oferta AS
SELECT  pl.codigo AS periodo_lectivo,
        p.nombre  AS programa,
        t.nombre  AS turno,
        o.cupo_referencial,
        COUNT(m.id_matricula) FILTER (WHERE m.estado = 'VIGENTE') AS matriculados
FROM    oferta o
JOIN    programa_estudios p ON p.id_programa = o.id_programa
JOIN    periodo_lectivo pl  ON pl.id_periodo = o.id_periodo
JOIN    turno t             ON t.id_turno    = o.id_turno
LEFT JOIN matricula m       ON m.id_oferta   = o.id_oferta
GROUP BY pl.codigo, p.nombre, t.nombre, o.cupo_referencial;

-- Anexo 1: cabecera por matrícula y módulo
CREATE VIEW v_registro_matricula_cabecera AS
SELECT  m.id_matricula,
        i.valor ->> 'nombre'         AS nombre_cetpro,
        i.valor ->> 'codigo_modular' AS codigo_modular,
        i.valor ->> 'dre'            AS dre,
        i.valor ->> 'ugel'           AS ugel,
        i.valor ->> 'tipo_gestion'   AS tipo_gestion,
        i.valor ->> 'departamento'   AS departamento,
        i.valor ->> 'provincia'      AS provincia,
        i.valor ->> 'distrito'       AS distrito,
        pl.codigo                    AS periodo_lectivo,
        pl.inicio_clases,
        pl.fin_clases,
        mm.periodo_academico_numero  AS periodo_academico,
        p.nombre                     AS programa_estudios,
        mf.nombre                    AS modulo,
        p.ciclo,
        ms.nombre                    AS modalidad_servicio,
        me.nombre                    AS modelo_educativo,
        e.apellido_paterno, e.apellido_materno, e.nombres,
        e.tipo_documento, e.numero_documento,
        gi.nombre                    AS grado_instruccion,
        m.edad_al_matricular         AS edad
FROM    matricula m
JOIN    estudiante e          ON e.id_estudiante = m.id_estudiante
JOIN    grado_instruccion gi  ON gi.id = e.id_grado_instruccion
JOIN    oferta o              ON o.id_oferta = m.id_oferta
JOIN    programa_estudios p   ON p.id_programa = o.id_programa
JOIN    periodo_lectivo pl    ON pl.id_periodo = o.id_periodo
LEFT JOIN modalidad_servicio ms ON ms.id = o.id_modalidad
LEFT JOIN modelo_educativo me   ON me.id = o.id_modelo
LEFT JOIN matricula_modulo mm   ON mm.id_matricula = m.id_matricula
LEFT JOIN modulo_formativo mf   ON mf.id_modulo = mm.id_modulo
CROSS JOIN (SELECT valor FROM parametro_institucional WHERE clave = 'institucion') i
WHERE   m.estado = 'VIGENTE';

-- Anexo 1: unidades didácticas del módulo (derivadas del plan) con su condición
CREATE VIEW v_registro_matricula_unidades AS
SELECT  m.id_matricula,
        mf.nombre   AS modulo,
        ROW_NUMBER() OVER (PARTITION BY m.id_matricula, mf.id_modulo ORDER BY ud.id_unidad) AS numero,
        ud.nombre   AS unidad_didactica,
        ud.creditos,
        ud.horas,
        ex.condicion AS observacion
FROM    matricula m
JOIN    matricula_modulo mm      ON mm.id_matricula = m.id_matricula
JOIN    modulo_formativo mf      ON mf.id_modulo = mm.id_modulo
JOIN    unidad_didactica ud      ON ud.id_modulo = mf.id_modulo AND ud.activo
LEFT JOIN matricula_excepcion_unidad ex
                                 ON ex.id_matricula = m.id_matricula AND ex.id_unidad = ud.id_unidad
WHERE   m.estado = 'VIGENTE';

-- Exportación de estudiantes para AVANZA (columnas provisionales) con control de faltantes
CREATE VIEW v_exportacion_avanza_estudiantes AS
SELECT  pl.codigo                AS periodo_lectivo,
        p.nombre                 AS programa_estudios,
        mf.nombre                AS modulo,
        mm.periodo_academico_numero AS periodo_academico,
        e.tipo_documento,
        e.numero_documento,
        e.apellido_paterno,
        e.apellido_materno,
        e.nombres,
        e.fecha_nacimiento,
        e.sexo,
        ub.departamento          AS region,
        ub.provincia,
        ub.distrito,
        e.direccion,
        e.correo,
        e.telefono_fijo,
        e.celular,
        m.id_matricula,
        array_remove(ARRAY[
            CASE WHEN e.ubigeo    IS NULL THEN 'ubigeo' END,
            CASE WHEN e.direccion IS NULL THEN 'direccion' END,
            CASE WHEN e.correo    IS NULL THEN 'correo' END,
            CASE WHEN e.celular IS NULL AND e.telefono_fijo IS NULL THEN 'telefono_o_celular' END,
            CASE WHEN mf.id_modulo IS NULL THEN 'modulo' END
        ], NULL) AS campos_faltantes
FROM    matricula m
JOIN    estudiante e          ON e.id_estudiante = m.id_estudiante
JOIN    oferta o              ON o.id_oferta = m.id_oferta
JOIN    programa_estudios p   ON p.id_programa = o.id_programa
JOIN    periodo_lectivo pl    ON pl.id_periodo = o.id_periodo
LEFT JOIN ubigeo ub           ON ub.codigo = e.ubigeo
LEFT JOIN matricula_modulo mm ON mm.id_matricula = m.id_matricula
LEFT JOIN modulo_formativo mf ON mf.id_modulo = mm.id_modulo
WHERE   m.estado = 'VIGENTE';

CREATE VIEW v_datos_faltantes_exportacion AS
SELECT * FROM v_exportacion_avanza_estudiantes WHERE cardinality(campos_faltantes) > 0;

-- Módulos del plan para la plantilla de módulos de AVANZA
CREATE VIEW v_exportacion_avanza_modulos AS
SELECT  p.nombre AS programa_estudios,
        pe.tipo_resolucion, pe.numero_resolucion, pe.anio_resolucion,
        ROW_NUMBER() OVER (PARTITION BY p.id_programa, pe.id_plan ORDER BY mf.orden, mf.id_modulo) AS numero,
        mf.nombre AS modulo
FROM    modulo_formativo mf
JOIN    plan_estudios pe  ON pe.id_plan = mf.id_plan
JOIN    programa_estudios p ON p.id_programa = pe.id_programa
WHERE   mf.activo AND pe.vigente;

-- ---------------------------------------------------------------------
-- 15. DATOS INICIALES (catálogos y parámetros)
-- ---------------------------------------------------------------------
INSERT INTO turno (codigo, nombre) VALUES ('MANANA', 'Mañana'), ('TARDE', 'Tarde')
ON CONFLICT (codigo) DO NOTHING;

INSERT INTO grado_instruccion (codigo, nombre, cumple_primaria_completa, orden) VALUES
    ('SIN_NIVEL',             'Sin nivel',                 FALSE, 1),
    ('PRIMARIA_INCOMPLETA',   'Primaria incompleta',       FALSE, 2),
    ('PRIMARIA_COMPLETA',     'Primaria completa',         TRUE,  3),
    ('SECUNDARIA_INCOMPLETA', 'Secundaria incompleta',     TRUE,  4),
    ('SECUNDARIA_COMPLETA',   'Secundaria completa',       TRUE,  5),
    ('SUPERIOR_INCOMPLETA',   'Superior incompleta',       TRUE,  6),
    ('SUPERIOR_COMPLETA',     'Superior completa',         TRUE,  7)
ON CONFLICT (codigo) DO NOTHING;

INSERT INTO modalidad_servicio (codigo, nombre, activo) VALUES
    ('PRESENCIAL',     'Presencial',     TRUE),
    ('SEMIPRESENCIAL', 'Semipresencial', FALSE),
    ('A_DISTANCIA',    'A distancia',    FALSE)
ON CONFLICT (codigo) DO NOTHING;

INSERT INTO modelo_educativo (codigo, nombre, activo) VALUES
    ('POR_DEFINIR', 'Por definir con la Dirección', TRUE)
ON CONFLICT (codigo) DO NOTHING;

INSERT INTO situacion_especifica (codigo, nombre, es_sensible) VALUES
    ('PIR',           'PIR',                            FALSE),
    ('TRANSITABILIDAD','Transitabilidad',               FALSE),
    ('MOT',           'MOT',                            FALSE),
    ('DISCAPACIDAD',  'Discapacidad',                   TRUE),
    ('OTRA',          'Otra situación específica',      FALSE)
ON CONFLICT (codigo) DO NOTHING;

-- Oferta 2026 según la entrevista (revisar con la Dirección; sin familia ni plan)
INSERT INTO programa_estudios (nombre, ciclo, creditos_minimos) VALUES
    ('Estilismo',                                         'TECNICO',          80),
    ('Fabricación de prendas de vestir',                  'TECNICO',          80),
    ('Mantenimiento de sistemas electrónicos',            'TECNICO',          80),
    ('Soporte técnico y operación de centros de cómputo', 'AUXILIAR_TECNICO', 40),
    ('Apoyo administrativo',                              'AUXILIAR_TECNICO', 40),
    ('Servicios básicos gastronómicos',                   'AUXILIAR_TECNICO', 40),
    ('Panadería y pastelería',                            'AUXILIAR_TECNICO', 40),
    ('Mantenimiento básico de casas y edificios',         'AUXILIAR_TECNICO', 40),
    ('Cuidado de niños y adulto mayor',                   'AUXILIAR_TECNICO', 40),
    ('Soldadura metálica',                                'AUXILIAR_TECNICO', 40)
ON CONFLICT (nombre, ciclo) DO NOTHING;

INSERT INTO parametro_institucional (clave, tipo, valor, descripcion) VALUES
    ('edad_minima',                    'ENTERO',  '16',                'Edad mínima para matricularse (regla institucional; piso nacional 14).'),
    ('edad_referencia',                'TEXTO',   '"FECHA_MATRICULA"', 'Fecha con la que se mide la edad: FECHA_MATRICULA o INICIO_PERIODO.'),
    ('periodo_semanas',                'ENTERO',  '18',                'Duración del periodo académico en semanas (LAG 19.1).'),
    ('periodos_por_anio',              'ENTERO',  '2',                 'Periodos lectivos por año.'),
    ('plazo_registro_matricula_dias',  'ENTERO',  '30',                'Plazo para registrar la matrícula en AVANZA, desde el inicio del periodo (LAG 17.1).'),
    ('cupo_referencial',               'ENTERO',  '30',                'Cupo orientativo por oferta; no es un límite.'),
    ('beca_porcentaje_maximo',         'DECIMAL', '50',                'Tope de beca o exoneración (%).'),
    ('convalidacion_similitud_minima', 'DECIMAL', '80',                'Contenido similar mínimo entre unidades didácticas de planes distintos (%).'),
    ('plazo_reserva_licencia_dias',    'ENTERO',  'null',              'Plazo máximo para reincorporarse tras una licencia. POR DEFINIR.'),
    ('derecho_inscripcion_monto',      'DECIMAL', 'null',              'Monto del derecho de inscripción. POR DEFINIR.'),
    ('retencion_bitacora_anios',       'ENTERO',  '2',                 'Retención de la bitácora (mínimo legal, DS art. 46).'),
    ('retencion_matriculas_anios',     'ENTERO',  'null',              'Retención de fichas y constancias. POR DEFINIR con la UGEL.'),
    ('revision_privilegios_meses',     'ENTERO',  '6',                 'Frecuencia de revisión de privilegios (DS art. 46).'),
    ('alerta_dias_antes_plazo_registro','JSON',   '[7,2]',             'Días antes del vencimiento del plazo de registro en que salta la alerta.'),
    ('alerta_dias_antes_licencia',     'JSON',    '[15,5]',            'Días antes del vencimiento del plazo de reserva de la licencia.'),
    ('password_minimo',                'ENTERO',  '15',                'Longitud mínima de contraseña (NIST 800-63B-4).'),
    ('sesion_inactividad_min',         'ENTERO',  '30',                'Vencimiento de sesión por inactividad (minutos).'),
    ('sesion_maxima_horas',            'ENTERO',  '8',                 'Duración máxima absoluta de la sesión (horas).'),
    ('bloqueo_intentos',               'ENTERO',  '5',                 'Intentos fallidos antes del bloqueo temporal.'),
    ('bloqueo_minutos',                'ENTERO',  '15',                'Duración del bloqueo temporal (minutos).'),
    ('zona_horaria',                   'TEXTO',   '"America/Lima"',    'Zona horaria de presentación.'),
    ('institucion',                    'JSON',
        '{"nombre":"CETPRO Joaquín López Antay","codigo_modular":null,"dre":"DRE Ayacucho","ugel":"UGEL Huamanga","tipo_gestion":"Pública","departamento":"Ayacucho","provincia":"Huamanga","distrito":null}',
        'Datos del CETPRO para el Anexo 1 y las constancias. Completar el código modular.'),
    ('oficial_datos',                  'JSON',
        '{"nombre":null,"correo":null,"resolucion_designacion":null}',
        'Oficial de Datos Personales designado por el CETPRO. POR DEFINIR (puerta de salida, AD-31).'),
    ('campos_estudiante',              'JSON',
        '{"obligatorios":["tipo_documento","numero_documento","apellido_paterno","nombres","sexo","fecha_nacimiento","grado_instruccion"],"requeridos_para_exportar":["ubigeo","direccion","correo","telefono_o_celular"]}',
        'Campos del estudiante. Los requeridos para exportar los exige AVANZA.'),
    ('requisitos_matricula',           'JSON',
        '[{"codigo":"FICHA_FIRMADA","nombre":"Ficha de matrícula firmada","obligatorio":true},{"codigo":"CERTIFICADO_ESTUDIOS","nombre":"Certificado de estudios (ciclo Técnico)","obligatorio":true},{"codigo":"FOTOS","nombre":"Fotografías para el certificado modular","obligatorio":false}]',
        'Requisitos a verificar al matricular (LAG 11.2.1). Se registra que se verificaron, no los documentos.'),
    ('avanza_mapeo_columnas',          'JSON',    '{}',                'Mapeo de columnas hacia las plantillas de AVANZA. Pendiente de las plantillas.')
ON CONFLICT (clave) DO NOTHING;

INSERT INTO identidad.rol (codigo, nombre, descripcion) VALUES
    ('MATRICULA',     'Personal de matrícula', 'Registra, edita, anula y consulta matrículas; emite constancias y reportes.'),
    ('DIRECTIVO',     'Directivo',             'Consulta reportes y nóminas, sin editar.'),
    ('ADMINISTRADOR', 'Administrador',         'Usuarios, parámetros y tareas técnicas, sin acceso a datos de estudiantes por defecto.')
ON CONFLICT (codigo) DO NOTHING;

INSERT INTO identidad.permiso (codigo, descripcion) VALUES
    ('ESTUDIANTE_MATRICULA_ESCRIBIR', 'Registrar y editar estudiantes y matrículas'),
    ('MATRICULA_ANULAR',              'Anular una matrícula (con motivo)'),
    ('MATRICULA_RATIFICAR',           'Ratificar matrículas'),
    ('LICENCIA_REGISTRAR',            'Registrar licencia de estudios y reincorporación'),
    ('CONVALIDACION_REGISTRAR',       'Registrar convalidaciones'),
    ('BECA_PAGO_ESCRIBIR',            'Registrar becas y derecho de inscripción'),
    ('BECA_PAGO_CONSULTAR',           'Consultar becas y derecho de inscripción'),
    ('CATALOGO_ESCRIBIR',             'Editar programas, planes, módulos, unidades, periodos y ofertas'),
    ('CATALOGO_CONSULTAR',            'Consultar el catálogo académico'),
    ('MATRICULA_CONSULTAR',           'Consultar matrículas y matriculados'),
    ('CONSTANCIA_EMITIR',             'Emitir constancia de estudios'),
    ('REPORTE_GENERAR',               'Generar nómina, registro de matrícula y archivos para AVANZA'),
    ('SITUACION_ESPECIFICA_VER',      'Ver la situación específica del estudiante'),
    ('ALERTAS_VER',                   'Ver las alertas propias de su rol'),
    ('ALERTAS_TECNICAS_VER',          'Ver las alertas técnicas'),
    ('BITACORA_CONSULTAR',            'Consultar la bitácora'),
    ('BITACORA_TECNICA_CONSULTAR',    'Consultar la bitácora técnica, sin datos del estudiante'),
    ('USUARIOS_ADMINISTRAR',          'Altas, bajas, segundo factor y permisos de usuarios'),
    ('PRIVILEGIOS_APROBAR',           'Aprobar el informe semestral de privilegios'),
    ('PARAMETROS_CONSULTAR',          'Consultar parámetros institucionales'),
    ('PARAMETROS_EDITAR',             'Editar parámetros institucionales'),
    ('DERECHOS_REGISTRAR',            'Registrar solicitudes de derechos'),
    ('DERECHOS_RESPONDER',            'Responder solicitudes de derechos'),
    ('INCIDENTES_GESTIONAR',          'Registrar y gestionar incidentes de seguridad'),
    ('RESPALDOS_ADMINISTRAR',         'Administrar respaldos y restauraciones')
ON CONFLICT (codigo) DO NOTHING;

-- Matriz inicial de permisos (por validar con la Dirección)
INSERT INTO identidad.rol_permiso (id_rol, id_permiso)
SELECT r.id, p.id
  FROM (VALUES
        ('MATRICULA','ESTUDIANTE_MATRICULA_ESCRIBIR'), ('MATRICULA','MATRICULA_ANULAR'), ('MATRICULA','MATRICULA_RATIFICAR'),
        ('MATRICULA','LICENCIA_REGISTRAR'), ('MATRICULA','CONVALIDACION_REGISTRAR'), ('MATRICULA','BECA_PAGO_ESCRIBIR'),
        ('MATRICULA','BECA_PAGO_CONSULTAR'), ('MATRICULA','CATALOGO_ESCRIBIR'), ('MATRICULA','CATALOGO_CONSULTAR'),
        ('MATRICULA','MATRICULA_CONSULTAR'), ('MATRICULA','CONSTANCIA_EMITIR'), ('MATRICULA','REPORTE_GENERAR'),
        ('MATRICULA','SITUACION_ESPECIFICA_VER'), ('MATRICULA','ALERTAS_VER'), ('MATRICULA','PARAMETROS_CONSULTAR'),
        ('MATRICULA','DERECHOS_REGISTRAR'),
        ('DIRECTIVO','BECA_PAGO_CONSULTAR'), ('DIRECTIVO','CATALOGO_CONSULTAR'), ('DIRECTIVO','MATRICULA_CONSULTAR'),
        ('DIRECTIVO','REPORTE_GENERAR'), ('DIRECTIVO','ALERTAS_VER'), ('DIRECTIVO','BITACORA_CONSULTAR'),
        ('DIRECTIVO','PRIVILEGIOS_APROBAR'), ('DIRECTIVO','PARAMETROS_CONSULTAR'), ('DIRECTIVO','DERECHOS_RESPONDER'),
        ('DIRECTIVO','INCIDENTES_GESTIONAR'),
        ('ADMINISTRADOR','ALERTAS_TECNICAS_VER'), ('ADMINISTRADOR','BITACORA_TECNICA_CONSULTAR'),
        ('ADMINISTRADOR','USUARIOS_ADMINISTRAR'), ('ADMINISTRADOR','PARAMETROS_CONSULTAR'),
        ('ADMINISTRADOR','PARAMETROS_EDITAR'), ('ADMINISTRADOR','INCIDENTES_GESTIONAR'),
        ('ADMINISTRADOR','RESPALDOS_ADMINISTRAR')
       ) AS m (rol, permiso)
  JOIN identidad.rol r     ON r.codigo = m.rol
  JOIN identidad.permiso p ON p.codigo = m.permiso
ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------------
-- 16. ROL DE LA APLICACIÓN Y PRIVILEGIOS MÍNIMOS (AD-22)
--     La aplicación se conecta con cetpro_app (sin propietario, sin DDL).
--     El despliegue le asigna LOGIN y contraseña; aquí no se escribe ningún secreto.
--     Los respaldos y las migraciones usan otros roles, fuera de este script.
-- ---------------------------------------------------------------------
DO $grants$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'cetpro_app') THEN
        BEGIN
            CREATE ROLE cetpro_app NOLOGIN;
        EXCEPTION WHEN insufficient_privilege THEN
            RAISE NOTICE 'Sin permiso para crear el rol cetpro_app: cree el rol y ejecute de nuevo esta sección.';
            RETURN;
        END;
    END IF;

    GRANT USAGE ON SCHEMA matricula, identidad, auditoria TO cetpro_app;
    GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA matricula TO cetpro_app;
    GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA identidad TO cetpro_app;
    -- Sin DELETE general: las matrículas se anulan, no se borran. Solo tablas de relación.
    GRANT DELETE ON matricula.matricula_modulo, matricula.matricula_excepcion_unidad,
                    matricula.matricula_situacion, matricula.convalidacion_unidad,
                    identidad.usuario_rol, identidad.rol_permiso TO cetpro_app;
    -- Bitácora: solo insertar y leer (el disparador la hace inmutable de todos modos)
    GRANT SELECT, INSERT ON auditoria.bitacora TO cetpro_app;
    GRANT USAGE ON ALL SEQUENCES IN SCHEMA matricula, identidad, auditoria TO cetpro_app;
END
$grants$;

COMMIT;
