-- =====================================================================
-- Sistema de Gestión de Matrícula - CETPRO "Joaquín López Antay"
-- Motor: PostgreSQL 14+ (compatible con Supabase)   |   Versión 1.0
-- Estado: PROPUESTA POR VALIDAR con el personal del CETPRO
-- Alcance: matrícula, especialidades, convenios/becas, usuarios y
--          constancias.  (Notas y módulos formativos: FUERA DE ALCANCE)
-- =====================================================================

BEGIN;

CREATE SCHEMA IF NOT EXISTS matricula;
SET search_path TO matricula, public;

-- ---------------------------------------------------------------------
-- 1. TIPOS ENUMERADOS
-- ---------------------------------------------------------------------
CREATE TYPE modalidad_formativa AS ENUM ('TITULO_TECNICO', 'AUXILIAR_TECNICO');
CREATE TYPE turno_clase         AS ENUM ('MANANA', 'TARDE');
CREATE TYPE tipo_ingreso        AS ENUM ('NUEVO', 'REINGRESANTE', 'TRASLADADO', 'RETIRADO_ANTERIORMENTE');
CREATE TYPE estado_matricula    AS ENUM ('VIGENTE', 'ANULADA', 'RETIRADA');
CREATE TYPE rol_usuario         AS ENUM ('ADMINISTRADOR', 'MATRICULA', 'DIRECTIVO');
CREATE TYPE tipo_exoneracion    AS ENUM ('NINGUNA', 'BECA', 'EXONERACION');
CREATE TYPE tipo_documento      AS ENUM ('CONSTANCIA_MATRICULA', 'NOMINA_MATRICULADOS');
CREATE TYPE accion_auditoria    AS ENUM ('INSERT', 'UPDATE', 'DELETE', 'LOGIN', 'LOGOUT', 'ANULACION');

-- ---------------------------------------------------------------------
-- 2. FAMILIA PROFESIONAL
-- ---------------------------------------------------------------------
CREATE TABLE familia_profesional (
    id_familia     SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre         VARCHAR(80) NOT NULL UNIQUE,
    activo         BOOLEAN     NOT NULL DEFAULT TRUE
);
COMMENT ON TABLE familia_profesional IS 'Agrupación de especialidades afines (ej. Electricidad y Electrónica).';

-- ---------------------------------------------------------------------
-- 3. ESPECIALIDAD (catálogo)
-- ---------------------------------------------------------------------
CREATE TABLE especialidad (
    id_especialidad  SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_familia       SMALLINT             REFERENCES familia_profesional(id_familia),
    nombre           VARCHAR(120)         NOT NULL,
    modalidad        modalidad_formativa  NOT NULL,
    duracion_anios   SMALLINT             NOT NULL,
    horas_dictado    SMALLINT,
    activa           BOOLEAN              NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_especialidad_nombre_modalidad UNIQUE (nombre, modalidad),
    CONSTRAINT ck_duracion_valida  CHECK (duracion_anios IN (1, 2)),
    CONSTRAINT ck_duracion_modalidad CHECK (
        (modalidad = 'TITULO_TECNICO'   AND duracion_anios = 2) OR
        (modalidad = 'AUXILIAR_TECNICO' AND duracion_anios = 1)),
    CONSTRAINT ck_horas_positivas  CHECK (horas_dictado IS NULL OR horas_dictado > 0)
);
COMMENT ON COLUMN especialidad.horas_dictado IS 'Horas de dictado de la especialidad (dato pedido en la entrevista).';

-- ---------------------------------------------------------------------
-- 4. PERIODO ACADÉMICO  (supuesto por validar)
-- ---------------------------------------------------------------------
CREATE TABLE periodo_academico (
    id_periodo     SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo         VARCHAR(10) NOT NULL UNIQUE,          -- ej. '2026'
    fecha_inicio   DATE        NOT NULL,
    fecha_fin      DATE        NOT NULL,
    vigente        BOOLEAN     NOT NULL DEFAULT FALSE,
    CONSTRAINT ck_periodo_fechas CHECK (fecha_fin > fecha_inicio)
);
-- Solo un periodo puede estar vigente a la vez
CREATE UNIQUE INDEX uq_periodo_unico_vigente ON periodo_academico (vigente) WHERE vigente;

-- ---------------------------------------------------------------------
-- 5. DOCENTE  (informativo: "docentes encargados de los turnos")
-- ---------------------------------------------------------------------
CREATE TABLE docente (
    id_docente   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    dni          CHAR(8)      UNIQUE,
    nombres      VARCHAR(80)  NOT NULL,
    apellidos    VARCHAR(80)  NOT NULL,
    activo       BOOLEAN      NOT NULL DEFAULT TRUE,
    CONSTRAINT ck_docente_dni CHECK (dni IS NULL OR dni ~ '^[0-9]{8}$')
);

-- ---------------------------------------------------------------------
-- 6. OFERTA (especialidad + periodo + turno)
-- ---------------------------------------------------------------------
CREATE TABLE oferta (
    id_oferta        INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_especialidad  SMALLINT   NOT NULL REFERENCES especialidad(id_especialidad),
    id_periodo       SMALLINT   NOT NULL REFERENCES periodo_academico(id_periodo),
    turno            turno_clase NOT NULL,
    id_docente       INTEGER             REFERENCES docente(id_docente),
    cupo_referencial SMALLINT   NOT NULL DEFAULT 30,
    activa           BOOLEAN    NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_oferta UNIQUE (id_especialidad, id_periodo, turno),
    CONSTRAINT ck_cupo_positivo CHECK (cupo_referencial > 0)
);
COMMENT ON COLUMN oferta.cupo_referencial IS 'Referencia (~30). NO es un límite estricto: la entrevista indica que no hay tope de vacantes.';

-- ---------------------------------------------------------------------
-- 7. ESTUDIANTE
-- ---------------------------------------------------------------------
CREATE TABLE estudiante (
    id_estudiante     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    dni               CHAR(8)      NOT NULL UNIQUE,
    nombres           VARCHAR(80)  NOT NULL,
    apellidos         VARCHAR(80)  NOT NULL,
    fecha_nacimiento  DATE         NOT NULL,
    direccion         VARCHAR(150),
    correo            VARCHAR(120),
    celular           VARCHAR(15),
    fecha_registro    TIMESTAMPTZ  NOT NULL DEFAULT now(),
    CONSTRAINT ck_estudiante_dni   CHECK (dni ~ '^[0-9]{8}$'),
    CONSTRAINT ck_estudiante_correo CHECK (correo IS NULL OR correo ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
    CONSTRAINT ck_estudiante_celular CHECK (celular IS NULL OR celular ~ '^[0-9+ ]{7,15}$'),
    CONSTRAINT ck_estudiante_nacimiento CHECK (fecha_nacimiento < CURRENT_DATE)
);
CREATE INDEX ix_estudiante_apellidos ON estudiante (apellidos, nombres);

-- ---------------------------------------------------------------------
-- 8. CONVENIO  (base de las becas / exoneraciones)
-- ---------------------------------------------------------------------
CREATE TABLE convenio (
    id_convenio          SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    institucion          VARCHAR(150) NOT NULL,
    descripcion          VARCHAR(250),
    porcentaje_maximo    NUMERIC(5,2) NOT NULL DEFAULT 50.00,
    fecha_inicio         DATE,
    fecha_fin            DATE,
    activo               BOOLEAN      NOT NULL DEFAULT TRUE,
    CONSTRAINT ck_convenio_porcentaje CHECK (porcentaje_maximo > 0 AND porcentaje_maximo <= 50),
    CONSTRAINT ck_convenio_fechas CHECK (fecha_fin IS NULL OR fecha_inicio IS NULL OR fecha_fin >= fecha_inicio)
);
COMMENT ON COLUMN convenio.porcentaje_maximo IS 'RN-07: beca o exoneración de hasta el 50 %.';

-- ---------------------------------------------------------------------
-- 9. USUARIO DEL SISTEMA
-- ---------------------------------------------------------------------
CREATE TABLE usuario (
    id_usuario       SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_usuario   VARCHAR(40)  NOT NULL UNIQUE,
    hash_contrasena  VARCHAR(255) NOT NULL,            -- hash con sal (nunca texto plano)
    nombres          VARCHAR(80)  NOT NULL,
    apellidos        VARCHAR(80)  NOT NULL,
    rol              rol_usuario  NOT NULL,
    activo           BOOLEAN      NOT NULL DEFAULT TRUE,
    intentos_fallidos SMALLINT    NOT NULL DEFAULT 0,
    bloqueado_hasta  TIMESTAMPTZ,
    ultimo_acceso    TIMESTAMPTZ,
    fecha_creacion   TIMESTAMPTZ  NOT NULL DEFAULT now(),
    CONSTRAINT ck_usuario_intentos CHECK (intentos_fallidos >= 0),
    CONSTRAINT ck_usuario_nombre   CHECK (nombre_usuario ~ '^[A-Za-z0-9._-]{4,40}$')
);

-- ---------------------------------------------------------------------
-- 10. MATRÍCULA
-- ---------------------------------------------------------------------
CREATE TABLE matricula (
    id_matricula          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo_matricula      VARCHAR(20)  NOT NULL UNIQUE,      -- ej. 2026-000123
    id_estudiante         INTEGER      NOT NULL REFERENCES estudiante(id_estudiante),
    id_oferta             INTEGER      NOT NULL REFERENCES oferta(id_oferta),
    id_usuario_registra   SMALLINT     NOT NULL REFERENCES usuario(id_usuario),
    tipo_ingreso          tipo_ingreso NOT NULL DEFAULT 'NUEVO',
    id_especialidad_origen SMALLINT             REFERENCES especialidad(id_especialidad),
    institucion_origen    VARCHAR(150),
    estado                estado_matricula NOT NULL DEFAULT 'VIGENTE',
    fecha_matricula       TIMESTAMPTZ  NOT NULL DEFAULT now(),
    observaciones         VARCHAR(250),
    -- Un estudiante no puede tener dos matrículas VIGENTES en la misma oferta
    CONSTRAINT ck_traslado_origen CHECK (
        tipo_ingreso <> 'TRASLADADO' OR institucion_origen IS NOT NULL)
);
-- Regla: un estudiante solo puede tener UNA matrícula vigente por oferta
CREATE UNIQUE INDEX uq_matricula_vigente_oferta
    ON matricula (id_estudiante, id_oferta) WHERE estado = 'VIGENTE';
CREATE INDEX ix_matricula_oferta     ON matricula (id_oferta);
CREATE INDEX ix_matricula_estudiante ON matricula (id_estudiante);
CREATE INDEX ix_matricula_fecha      ON matricula (fecha_matricula);

-- ---------------------------------------------------------------------
-- 11. PAGO (derecho de inscripción, con beca/exoneración)
-- ---------------------------------------------------------------------
CREATE TABLE pago_inscripcion (
    id_pago            INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_matricula       INTEGER       NOT NULL UNIQUE REFERENCES matricula(id_matricula) ON DELETE CASCADE,
    id_convenio        SMALLINT               REFERENCES convenio(id_convenio),
    monto_base         NUMERIC(8,2)  NOT NULL,
    tipo_exoneracion   tipo_exoneracion NOT NULL DEFAULT 'NINGUNA',
    porcentaje_desc    NUMERIC(5,2)  NOT NULL DEFAULT 0,
    monto_pagado       NUMERIC(8,2)  NOT NULL,
    nro_comprobante    VARCHAR(30),
    fecha_pago         DATE          NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT ck_pago_monto_base   CHECK (monto_base >= 0),
    CONSTRAINT ck_pago_porcentaje   CHECK (porcentaje_desc >= 0 AND porcentaje_desc <= 50),
    CONSTRAINT ck_pago_monto_pagado CHECK (monto_pagado >= 0 AND monto_pagado <= monto_base),
    CONSTRAINT ck_pago_coherencia_desc CHECK (
        (tipo_exoneracion = 'NINGUNA' AND porcentaje_desc = 0) OR
        (tipo_exoneracion <> 'NINGUNA' AND porcentaje_desc > 0)),
    CONSTRAINT ck_pago_convenio_requerido CHECK (
        tipo_exoneracion = 'NINGUNA' OR id_convenio IS NOT NULL),
    CONSTRAINT ck_pago_calculo CHECK (
        monto_pagado = ROUND(monto_base * (1 - porcentaje_desc / 100.0), 2))
);
COMMENT ON TABLE pago_inscripcion IS 'Derecho de inscripción. Beca/exoneración máximo 50 % (RN-07).';

-- ---------------------------------------------------------------------
-- 12. DOCUMENTO EMITIDO (constancias y nóminas: trazabilidad)
-- ---------------------------------------------------------------------
CREATE TABLE documento_emitido (
    id_documento     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tipo             tipo_documento NOT NULL,
    id_matricula     INTEGER        REFERENCES matricula(id_matricula),
    id_usuario       SMALLINT       NOT NULL REFERENCES usuario(id_usuario),
    codigo_documento VARCHAR(25)    NOT NULL UNIQUE,
    formato          VARCHAR(5)     NOT NULL,
    filtros          JSONB,
    fecha_emision    TIMESTAMPTZ    NOT NULL DEFAULT now(),
    CONSTRAINT ck_doc_formato   CHECK (formato IN ('PDF', 'XLSX')),
    -- La constancia siempre pertenece a una matrícula; la nómina no
    CONSTRAINT ck_doc_referencia CHECK (
        (tipo = 'CONSTANCIA_MATRICULA' AND id_matricula IS NOT NULL) OR
        (tipo = 'NOMINA_MATRICULADOS'  AND id_matricula IS NULL))
);
CREATE INDEX ix_documento_matricula ON documento_emitido (id_matricula);

-- ---------------------------------------------------------------------
-- 13. BITÁCORA DE AUDITORÍA (trazabilidad - RNF-05)
-- ---------------------------------------------------------------------
CREATE TABLE bitacora (
    id_bitacora   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_usuario    SMALLINT         REFERENCES usuario(id_usuario),
    accion        accion_auditoria NOT NULL,
    entidad       VARCHAR(40)      NOT NULL,
    id_registro   VARCHAR(30),
    detalle       JSONB,
    ip_origen     INET,
    fecha_hora    TIMESTAMPTZ      NOT NULL DEFAULT now()
);
CREATE INDEX ix_bitacora_fecha   ON bitacora (fecha_hora DESC);
CREATE INDEX ix_bitacora_usuario ON bitacora (id_usuario);

-- ---------------------------------------------------------------------
-- 14. REGLA RN-01: edad mínima de 16 años (trigger, pues depende de otra tabla)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_validar_edad_minima() RETURNS trigger AS $$
DECLARE
    v_nacimiento DATE;
BEGIN
    SELECT fecha_nacimiento INTO v_nacimiento
      FROM estudiante WHERE id_estudiante = NEW.id_estudiante;
    IF age(CURRENT_DATE, v_nacimiento) < INTERVAL '16 years' THEN
        RAISE EXCEPTION 'RN-01: el estudiante debe tener al menos 16 años para matricularse.'
            USING ERRCODE = 'check_violation';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_matricula_edad_minima
    BEFORE INSERT ON matricula
    FOR EACH ROW EXECUTE FUNCTION fn_validar_edad_minima();

-- ---------------------------------------------------------------------
-- 15. VISTAS DE REPORTE
-- ---------------------------------------------------------------------
-- Nómina de matriculados (reporte de fin de mes y SIAGIE/UGEL)
CREATE VIEW v_nomina_matriculados AS
SELECT  p.codigo               AS periodo,
        e.nombre               AS especialidad,
        e.modalidad,
        o.turno,
        s.dni,
        s.apellidos,
        s.nombres,
        m.tipo_ingreso,
        m.codigo_matricula,
        m.fecha_matricula::date AS fecha_matricula,
        m.estado
FROM    matricula m
JOIN    estudiante s          ON s.id_estudiante   = m.id_estudiante
JOIN    oferta o              ON o.id_oferta       = m.id_oferta
JOIN    especialidad e        ON e.id_especialidad = o.id_especialidad
JOIN    periodo_academico p   ON p.id_periodo      = o.id_periodo
WHERE   m.estado = 'VIGENTE';

-- Matriculados por especialidad y turno (RF-10)
CREATE VIEW v_matriculados_por_oferta AS
SELECT  p.codigo AS periodo, e.nombre AS especialidad, o.turno,
        o.cupo_referencial,
        COUNT(m.id_matricula) FILTER (WHERE m.estado = 'VIGENTE') AS matriculados
FROM    oferta o
JOIN    especialidad e       ON e.id_especialidad = o.id_especialidad
JOIN    periodo_academico p  ON p.id_periodo      = o.id_periodo
LEFT JOIN matricula m        ON m.id_oferta       = o.id_oferta
GROUP BY p.codigo, e.nombre, o.turno, o.cupo_referencial;

COMMIT;
