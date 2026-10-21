-- =====================================================================
-- Pruebas de humo del esquema v1.1 (reglas de negocio en la base de datos)
--
-- Uso (en una base de PRUEBAS, después de crear el esquema):
--   psql -d cetpro_prueba -f db/esquema_matricula_cetpro_v1.1.sql
--   psql -d cetpro_prueba -f db/pruebas_esquema_v1.1.sql
--
-- Todo corre dentro de una transacción que termina en ROLLBACK: no deja
-- datos de prueba. Los datos son sintéticos (no usar datos reales de
-- estudiantes en pruebas, ver AGENTS.md y AD-36).
-- Resultado esperado: la columna "fallidas" del resumen en 0.
--
-- ESTADO: escrito pero NO ejecutado todavía (no había PostgreSQL en el
-- equipo donde se redactó). Un fallo puede estar en el esquema o en la
-- prueba; revisar el detalle antes de corregir.
-- =====================================================================

BEGIN;
SET LOCAL search_path TO matricula, identidad, auditoria, public;

CREATE TEMP TABLE resultado_pruebas (
    n       serial PRIMARY KEY,
    prueba  text    NOT NULL,
    ok      boolean NOT NULL,
    detalle text
) ON COMMIT DROP;

-- ---------------------------------------------------------------------
-- Ayudantes (viven solo en esta sesión: esquema pg_temp)
-- ---------------------------------------------------------------------
CREATE FUNCTION pg_temp.reg(p_prueba text, p_ok boolean, p_detalle text DEFAULT NULL) RETURNS void
LANGUAGE sql AS
$$ INSERT INTO resultado_pruebas (prueba, ok, detalle) VALUES (p_prueba, COALESCE(p_ok, false), p_detalle) $$;

-- Verdadero si la sentencia FALLA y el mensaje de error coincide con el patrón
CREATE FUNCTION pg_temp.espera_error(p_sql text, p_patron text) RETURNS boolean
LANGUAGE plpgsql AS
$$
BEGIN
    EXECUTE p_sql;
    RETURN false;
EXCEPTION WHEN others THEN
    RETURN SQLERRM ~* p_patron;
END
$$;

CREATE FUNCTION pg_temp.nuevo_estudiante(p_doc text, p_anios int, p_grado text, p_dias_extra int DEFAULT 0) RETURNS bigint
LANGUAGE sql AS
$$
    INSERT INTO matricula.estudiante (tipo_documento, numero_documento, apellido_paterno, apellido_materno,
                                      nombres, sexo, fecha_nacimiento, id_grado_instruccion)
    SELECT 'DNI', p_doc, 'PRUEBA', 'SINTETICO', 'ESTUDIANTE ' || p_doc, 'F',
           (CURRENT_DATE - make_interval(years => p_anios))::date + p_dias_extra,
           g.id
      FROM matricula.grado_instruccion g
     WHERE g.codigo = p_grado
    RETURNING id_estudiante
$$;

CREATE FUNCTION pg_temp.est(p_doc text) RETURNS bigint
LANGUAGE sql AS
$$ SELECT id_estudiante FROM matricula.estudiante WHERE numero_documento = p_doc $$;

CREATE FUNCTION pg_temp.oferta_de(p_programa text) RETURNS int
LANGUAGE sql AS
$$
    SELECT o.id_oferta
      FROM matricula.oferta o
      JOIN matricula.programa_estudios p ON p.id_programa = o.id_programa
      JOIN matricula.periodo_lectivo pl  ON pl.id_periodo = o.id_periodo
     WHERE p.nombre = p_programa AND pl.codigo = 'PRUEBA-I'
$$;

CREATE FUNCTION pg_temp.modulo_de(p_programa text) RETURNS int
LANGUAGE sql AS
$$
    SELECT mf.id_modulo
      FROM matricula.modulo_formativo mf
      JOIN matricula.plan_estudios pe    ON pe.id_plan = mf.id_plan
      JOIN matricula.programa_estudios p ON p.id_programa = pe.id_programa
     WHERE p.nombre = p_programa AND pe.numero_resolucion = 'PRUEBA-001'
$$;

CREATE FUNCTION pg_temp.unidad_de(p_programa text) RETURNS int
LANGUAGE sql AS
$$
    SELECT ud.id_unidad
      FROM matricula.unidad_didactica ud
     WHERE ud.id_modulo = pg_temp.modulo_de(p_programa)
     ORDER BY ud.id_unidad
     LIMIT 1
$$;

CREATE FUNCTION pg_temp.matricular(p_est bigint, p_oferta int) RETURNS bigint
LANGUAGE sql AS
$$
    INSERT INTO matricula.matricula (id_estudiante, id_oferta, id_programa, id_periodo, id_usuario_registra)
    SELECT p_est, o.id_oferta, o.id_programa, o.id_periodo, '00000000-0000-0000-0000-0000000000a1'::uuid
      FROM matricula.oferta o
     WHERE o.id_oferta = p_oferta
    RETURNING id_matricula
$$;

CREATE FUNCTION pg_temp.mat(p_doc text, p_programa text) RETURNS bigint
LANGUAGE sql AS
$$
    SELECT m.id_matricula
      FROM matricula.matricula m
      JOIN matricula.estudiante e        ON e.id_estudiante = m.id_estudiante
      JOIN matricula.programa_estudios p ON p.id_programa = m.id_programa
     WHERE e.numero_documento = p_doc AND p.nombre = p_programa AND m.estado = 'VIGENTE'
$$;

-- ---------------------------------------------------------------------
-- Grupo 0. Preparación (datos sintéticos)
-- ---------------------------------------------------------------------
DO $t$
BEGIN
    INSERT INTO identidad.usuario (id, nombre_usuario, nombre_normalizado, hash_contrasena, nombres, apellidos)
    VALUES ('00000000-0000-0000-0000-0000000000a1', 'usuario.prueba', 'USUARIO.PRUEBA',
            'no-es-un-hash-real', 'Usuario', 'De Prueba');

    INSERT INTO periodo_lectivo (codigo, fecha_inicio, fecha_fin, inicio_clases, fin_clases, vigente)
    VALUES ('PRUEBA-I', CURRENT_DATE, CURRENT_DATE + 126, CURRENT_DATE, CURRENT_DATE + 126, FALSE);

    INSERT INTO plan_estudios (id_programa, tipo_resolucion, numero_resolucion, anio_resolucion)
    SELECT id_programa, 'RD', 'PRUEBA-001', 2024
      FROM programa_estudios
     WHERE nombre IN ('Estilismo', 'Apoyo administrativo');

    INSERT INTO modulo_formativo (id_plan, nombre, orden)
    SELECT pe.id_plan, 'Módulo de prueba de ' || p.nombre, 1
      FROM plan_estudios pe
      JOIN programa_estudios p ON p.id_programa = pe.id_programa
     WHERE pe.numero_resolucion = 'PRUEBA-001';

    INSERT INTO unidad_didactica (id_modulo, nombre, creditos, horas)
    SELECT id_modulo, 'Unidad de prueba', 3, 60
      FROM modulo_formativo
     WHERE nombre LIKE 'Módulo de prueba%';

    INSERT INTO oferta (id_programa, id_periodo, id_turno)
    SELECT p.id_programa, pl.id_periodo, t.id_turno
      FROM programa_estudios p, periodo_lectivo pl, turno t
     WHERE p.nombre IN ('Estilismo', 'Apoyo administrativo')
       AND pl.codigo = 'PRUEBA-I'
       AND t.codigo = 'MANANA';

    PERFORM pg_temp.reg('Preparación: datos sintéticos creados',
        pg_temp.oferta_de('Estilismo') IS NOT NULL AND pg_temp.oferta_de('Apoyo administrativo') IS NOT NULL
        AND pg_temp.unidad_de('Estilismo') IS NOT NULL AND pg_temp.unidad_de('Apoyo administrativo') IS NOT NULL);
EXCEPTION WHEN others THEN
    PERFORM pg_temp.reg('Preparación: datos sintéticos creados', false, SQLERRM);
END
$t$;

-- ---------------------------------------------------------------------
-- Grupo 1. Edad mínima, código de matrícula, ciclo Técnico, matrícula única
-- ---------------------------------------------------------------------
DO $t$
DECLARE
    v_aux    int := pg_temp.oferta_de('Apoyo administrativo');
    v_tec    int := pg_temp.oferta_de('Estilismo');
    v_menor  bigint;
    v_16     bigint;
    v_17     bigint;
    v_prim   bigint;
    v_adulto bigint;
    v_m      bigint;
BEGIN
    -- RN-01: edad mínima 16 (parámetro)
    v_menor := pg_temp.nuevo_estudiante('70000002', 15, 'SECUNDARIA_COMPLETA');
    PERFORM pg_temp.reg('RN-01: rechaza a una persona de 15 años',
        pg_temp.espera_error(format('SELECT pg_temp.matricular(%s, %s)', v_menor, v_aux), 'RN-01'));

    v_16 := pg_temp.nuevo_estudiante('70000003', 16, 'SECUNDARIA_COMPLETA', -2);
    v_m  := pg_temp.matricular(v_16, v_aux);
    PERFORM pg_temp.reg('RN-01: acepta a una persona de 16 años y guarda la edad mínima aplicada',
        (SELECT edad_minima_aplicada = 16 AND edad_al_matricular = 16
           FROM matricula.matricula WHERE id_matricula = v_m));

    -- RN-09: el código de matrícula es el número de documento
    PERFORM pg_temp.reg('RN-09: código de matrícula = número de documento',
        (SELECT codigo_matricula = '70000003' FROM matricula.matricula WHERE id_matricula = v_m));

    -- El parámetro se lee en cada matrícula: subir el mínimo cambia el resultado
    v_17 := pg_temp.nuevo_estudiante('70000005', 17, 'SECUNDARIA_COMPLETA', -2);
    UPDATE parametro_institucional SET valor = '18' WHERE clave = 'edad_minima';
    PERFORM pg_temp.reg('Parámetro: con edad_minima=18 se rechaza a una persona de 17 años',
        pg_temp.espera_error(format('SELECT pg_temp.matricular(%s, %s)', v_17, v_aux), 'RN-01'));
    PERFORM pg_temp.reg('Parámetro: el cambio quedó en parametro_historial',
        EXISTS (SELECT 1 FROM parametro_historial WHERE clave = 'edad_minima' AND valor_nuevo = '18'::jsonb));
    UPDATE parametro_institucional SET valor = '16' WHERE clave = 'edad_minima';

    -- RN-14: el ciclo Técnico exige primaria completa
    v_prim := pg_temp.nuevo_estudiante('70000004', 25, 'PRIMARIA_INCOMPLETA');
    PERFORM pg_temp.reg('RN-14: rechaza el ciclo Técnico sin primaria completa',
        pg_temp.espera_error(format('SELECT pg_temp.matricular(%s, %s)', v_prim, v_tec), 'RN-14'));
    PERFORM pg_temp.reg('RN-14: permite el ciclo Auxiliar Técnico con primaria incompleta',
        pg_temp.matricular(v_prim, v_aux) IS NOT NULL);

    v_adulto := pg_temp.nuevo_estudiante('70000001', 30, 'SECUNDARIA_COMPLETA');
    PERFORM pg_temp.reg('RN-14: permite el ciclo Técnico con secundaria completa',
        pg_temp.matricular(v_adulto, v_tec) IS NOT NULL);

    -- RN-13: una sola matrícula vigente por programa y periodo
    PERFORM pg_temp.reg('RN-13: rechaza una segunda matrícula vigente en el mismo programa y periodo',
        pg_temp.espera_error(format('SELECT pg_temp.matricular(%s, %s)', v_16, v_aux), 'uq_matricula_vigente'));
EXCEPTION WHEN others THEN
    PERFORM pg_temp.reg('Grupo 1: error inesperado', false, SQLERRM);
END
$t$;

-- ---------------------------------------------------------------------
-- Grupo 2. Estados, concurrencia y cupo
-- ---------------------------------------------------------------------
DO $t$
DECLARE
    v_m  bigint := pg_temp.mat('70000004', 'Apoyo administrativo');
    v_m2 bigint := pg_temp.mat('70000003', 'Apoyo administrativo');
    v_v1 int;
    v_v2 int;
BEGIN
    -- RN-15: anular exige motivo y es un estado, no un borrado
    PERFORM pg_temp.reg('RN-15: anular sin motivo se rechaza',
        pg_temp.espera_error(format('UPDATE matricula.matricula SET estado = ''ANULADA'' WHERE id_matricula = %s', v_m),
                             'ck_anulada_motivo'));
    UPDATE matricula.matricula SET estado = 'ANULADA', motivo_cambio_estado = 'Prueba' WHERE id_matricula = v_m;
    PERFORM pg_temp.reg('RN-15: anular con motivo fija la fecha del cambio',
        (SELECT fecha_cambio_estado IS NOT NULL AND estado = 'ANULADA' FROM matricula.matricula WHERE id_matricula = v_m));
    PERFORM pg_temp.reg('Estados: ANULADA a VIGENTE no se permite',
        pg_temp.espera_error(format('UPDATE matricula.matricula SET estado = ''VIGENTE'' WHERE id_matricula = %s', v_m),
                             'Transici'));
    PERFORM pg_temp.reg('RN-13: tras anular, el estudiante puede matricularse de nuevo',
        pg_temp.matricular(pg_temp.est('70000004'), pg_temp.oferta_de('Apoyo administrativo')) IS NOT NULL);

    -- La matrícula es inmutable en estudiante y oferta; la versión sube en cada cambio
    PERFORM pg_temp.reg('Matrícula: no permite cambiar de estudiante',
        pg_temp.espera_error(format('UPDATE matricula.matricula SET id_estudiante = %s WHERE id_matricula = %s',
                                    pg_temp.est('70000001'), v_m2),
                             'no permite cambiar'));
    SELECT version INTO v_v1 FROM matricula.matricula WHERE id_matricula = v_m2;
    UPDATE matricula.matricula SET observaciones = 'Prueba' WHERE id_matricula = v_m2;
    SELECT version INTO v_v2 FROM matricula.matricula WHERE id_matricula = v_m2;
    PERFORM pg_temp.reg('Concurrencia: la versión sube en cada cambio', v_v2 = v_v1 + 1);

    -- RN-04: el cupo es referencial
    UPDATE oferta SET cupo_referencial = 1 WHERE id_oferta = pg_temp.oferta_de('Apoyo administrativo');
    PERFORM pg_temp.reg('RN-04: el cupo referencial no bloquea (hay más matriculados que el cupo)',
        (SELECT matriculados > cupo_referencial
           FROM v_matriculados_por_oferta
          WHERE programa = 'Apoyo administrativo' AND periodo_lectivo = 'PRUEBA-I'));
EXCEPTION WHEN others THEN
    PERFORM pg_temp.reg('Grupo 2: error inesperado', false, SQLERRM);
END
$t$;

-- ---------------------------------------------------------------------
-- Grupo 3. Módulos, pago, convalidación y licencia
-- ---------------------------------------------------------------------
DO $t$
DECLARE
    v_m    bigint := pg_temp.mat('70000003', 'Apoyo administrativo');
    v_mt   bigint := pg_temp.mat('70000001', 'Estilismo');
    v_conv int;
    v_c    int;
BEGIN
    -- Módulo de la matrícula
    PERFORM pg_temp.reg('Módulo: uno de otro programa se rechaza',
        pg_temp.espera_error(format('INSERT INTO matricula.matricula_modulo VALUES (%s, %s, 1)',
                                    v_m, pg_temp.modulo_de('Estilismo')),
                             'no pertenece'));
    INSERT INTO matricula_modulo VALUES (v_m, pg_temp.modulo_de('Apoyo administrativo'), 1);
    PERFORM pg_temp.reg('Módulo: uno del mismo programa se acepta',
        EXISTS (SELECT 1 FROM matricula_modulo WHERE id_matricula = v_m));

    -- RN-06: tope de beca (parámetro, inicial 50 %)
    INSERT INTO convenio (institucion, porcentaje_maximo) VALUES ('Convenio de prueba', 100)
    RETURNING id_convenio INTO v_conv;
    PERFORM pg_temp.reg('RN-06: un descuento mayor al tope configurado se rechaza',
        pg_temp.espera_error(format($q$INSERT INTO matricula.pago_inscripcion
            (id_matricula, id_convenio, monto_base, tipo_exoneracion, porcentaje_desc, monto_pagado)
            VALUES (%s, %s, 100, 'BECA', 60, 40)$q$, v_m, v_conv), 'RN-06'));
    INSERT INTO pago_inscripcion (id_matricula, id_convenio, monto_base, tipo_exoneracion, porcentaje_desc, monto_pagado)
    VALUES (v_m, v_conv, 100, 'BECA', 50, 50);
    PERFORM pg_temp.reg('RN-06: un descuento igual al tope se acepta',
        EXISTS (SELECT 1 FROM pago_inscripcion WHERE id_matricula = v_m AND monto_pagado = 50));
    PERFORM pg_temp.reg('Pago: un monto incoherente con el descuento se rechaza',
        pg_temp.espera_error(format($q$INSERT INTO matricula.pago_inscripcion
            (id_matricula, id_convenio, monto_base, tipo_exoneracion, porcentaje_desc, monto_pagado)
            VALUES (%s, %s, 100, 'BECA', 10, 95)$q$, v_mt, v_conv), 'ck_pago_calculo'));

    -- RN-12: similitud mínima entre planes (parámetro, inicial 80 %)
    INSERT INTO convalidacion (id_matricula, tipo, resolucion_directoral, justificacion, id_usuario_registra)
    VALUES (v_m, 'ENTRE_PLANES', 'RD-PRUEBA', 'Prueba sintética', '00000000-0000-0000-0000-0000000000a1')
    RETURNING id_convalidacion INTO v_c;
    PERFORM pg_temp.reg('RN-12: una similitud bajo el mínimo se rechaza',
        pg_temp.espera_error(format('INSERT INTO matricula.convalidacion_unidad VALUES (%s, %s, 70)',
                                    v_c, pg_temp.unidad_de('Apoyo administrativo')),
                             'RN-12'));
    INSERT INTO convalidacion_unidad VALUES (v_c, pg_temp.unidad_de('Apoyo administrativo'), 80);
    PERFORM pg_temp.reg('RN-12: una similitud igual al mínimo se acepta',
        EXISTS (SELECT 1 FROM convalidacion_unidad WHERE id_convalidacion = v_c));

    -- RN-11: licencia de estudios
    INSERT INTO licencia_estudios (id_matricula, fecha_inicio, id_usuario_registra)
    VALUES (v_mt, CURRENT_DATE, '00000000-0000-0000-0000-0000000000a1');
    PERFORM pg_temp.reg('RN-11: registrar la licencia pasa la matrícula a LICENCIA',
        (SELECT estado = 'LICENCIA' FROM matricula.matricula WHERE id_matricula = v_mt));
    PERFORM pg_temp.reg('RN-11: no se permite una segunda licencia vigente',
        pg_temp.espera_error(format($q$INSERT INTO matricula.licencia_estudios (id_matricula, fecha_inicio, id_usuario_registra)
            VALUES (%s, CURRENT_DATE, '00000000-0000-0000-0000-0000000000a1')$q$, v_mt),
            'uq_licencia_vigente|Solo una matr'));
EXCEPTION WHEN others THEN
    PERFORM pg_temp.reg('Grupo 3: error inesperado', false, SQLERRM);
END
$t$;

-- ---------------------------------------------------------------------
-- Grupo 4. Bitácora: auditoría automática e inmutabilidad
-- ---------------------------------------------------------------------
DO $t$
DECLARE
    v_id bigint := pg_temp.est('70000001');
    v_n  bigint;
BEGIN
    PERFORM set_config('cetpro.usuario_id', '00000000-0000-0000-0000-0000000000a1', true);
    UPDATE estudiante SET celular = '999888777' WHERE id_estudiante = v_id;

    PERFORM pg_temp.reg('Auditoría: el alta del estudiante quedó en la bitácora',
        EXISTS (SELECT 1 FROM auditoria.bitacora
                 WHERE entidad = 'estudiante' AND accion = 'CREACION' AND id_registro = v_id::text));
    PERFORM pg_temp.reg('Auditoría: la modificación guarda columnas y usuario, nunca valores',
        EXISTS (SELECT 1 FROM auditoria.bitacora
                 WHERE entidad = 'estudiante' AND accion = 'MODIFICACION' AND id_registro = v_id::text
                   AND detalle -> 'columnas' = '["celular"]'::jsonb
                   AND detalle::text NOT LIKE '%999888777%'
                   AND id_usuario = '00000000-0000-0000-0000-0000000000a1'::uuid));
    PERFORM pg_temp.reg('Auditoría: el cambio de parámetro quedó en la bitácora',
        EXISTS (SELECT 1 FROM auditoria.bitacora WHERE entidad = 'parametro_institucional' AND accion = 'MODIFICACION'));

    PERFORM pg_temp.reg('Bitácora: UPDATE se rechaza',
        pg_temp.espera_error($q$UPDATE auditoria.bitacora SET entidad = 'x'$q$, 'solo inserci'));
    PERFORM pg_temp.reg('Bitácora: DELETE se rechaza',
        pg_temp.espera_error($q$DELETE FROM auditoria.bitacora$q$, 'solo inserci'));
    PERFORM pg_temp.reg('Bitácora: TRUNCATE se rechaza',
        pg_temp.espera_error($q$TRUNCATE auditoria.bitacora$q$, 'solo inserci'));

    -- Depuración autorizada: borra solo lo anterior a la retención
    INSERT INTO auditoria.bitacora (accion, entidad, id_registro, fecha_hora)
    VALUES ('LECTURA', 'prueba', 'antigua', now() - interval '3 years');
    v_n := auditoria.depurar_bitacora();
    PERFORM pg_temp.reg('Bitácora: la depuración borra solo lo anterior a la retención',
        v_n >= 1
        AND NOT EXISTS (SELECT 1 FROM auditoria.bitacora WHERE entidad = 'prueba')
        AND EXISTS (SELECT 1 FROM auditoria.bitacora WHERE entidad = 'estudiante'));
    PERFORM pg_temp.reg('Bitácora: tras depurar, DELETE directo sigue rechazado',
        pg_temp.espera_error($q$DELETE FROM auditoria.bitacora$q$, 'solo inserci'));
EXCEPTION WHEN others THEN
    PERFORM pg_temp.reg('Grupo 4: error inesperado', false, SQLERRM);
END
$t$;

-- ---------------------------------------------------------------------
-- Grupo 5. Restricciones, parámetros, alertas, vistas y permisos
-- ---------------------------------------------------------------------
DO $t$
BEGIN
    -- Restricciones de datos
    PERFORM pg_temp.reg('Estudiante: un DNI de 7 dígitos se rechaza',
        pg_temp.espera_error($q$INSERT INTO matricula.estudiante
            (tipo_documento, numero_documento, apellido_paterno, nombres, sexo, fecha_nacimiento, id_grado_instruccion)
            SELECT 'DNI', '1234567', 'PRUEBA', 'X', 'M', DATE '2000-01-01', id
              FROM matricula.grado_instruccion WHERE codigo = 'SECUNDARIA_COMPLETA'$q$,
            'ck_estudiante_documento'));
    PERFORM pg_temp.reg('Estudiante: un correo sin arroba se rechaza',
        pg_temp.espera_error($q$INSERT INTO matricula.estudiante
            (tipo_documento, numero_documento, apellido_paterno, nombres, sexo, fecha_nacimiento, id_grado_instruccion, correo)
            SELECT 'DNI', '70000099', 'PRUEBA', 'X', 'M', DATE '2000-01-01', id, 'sin-arroba'
              FROM matricula.grado_instruccion WHERE codigo = 'SECUNDARIA_COMPLETA'$q$,
            'ck_estudiante_correo'));
    PERFORM pg_temp.reg('Estudiante: el documento repetido se rechaza',
        pg_temp.espera_error($q$INSERT INTO matricula.estudiante
            (tipo_documento, numero_documento, apellido_paterno, nombres, sexo, fecha_nacimiento, id_grado_instruccion)
            SELECT 'DNI', '70000001', 'PRUEBA', 'X', 'M', DATE '2000-01-01', id
              FROM matricula.grado_instruccion WHERE codigo = 'SECUNDARIA_COMPLETA'$q$,
            'uq_estudiante_documento'));

    -- Parámetros "por definir"
    PERFORM pg_temp.reg('Parámetro: uno por definir lanza error claro al leerlo',
        pg_temp.espera_error($q$SELECT matricula.fn_param_int('plazo_reserva_licencia_dias')$q$, 'no est.+ definido'));

    -- Alertas
    INSERT INTO alerta (tipo, clave_dedupe, titulo, roles_destino)
    VALUES ('PRUEBA', 'clave-prueba', 'Alerta de prueba', ARRAY['MATRICULA']);
    PERFORM pg_temp.reg('Alerta: no se duplica una alerta activa con la misma clave',
        pg_temp.espera_error($q$INSERT INTO matricula.alerta (tipo, clave_dedupe, titulo, roles_destino)
            VALUES ('PRUEBA', 'clave-prueba', 'Otra', ARRAY['MATRICULA'])$q$, 'uq_alerta_activa_dedupe'));
    PERFORM pg_temp.reg('Alerta: cerrar exige fecha de atención',
        pg_temp.espera_error($q$UPDATE matricula.alerta SET estado = 'ATENDIDA' WHERE clave_dedupe = 'clave-prueba'$q$,
                             'ck_alerta_cierre'));
    UPDATE alerta SET estado = 'ATENDIDA', atendida_en = now() WHERE clave_dedupe = 'clave-prueba';
    INSERT INTO alerta (tipo, clave_dedupe, titulo, roles_destino)
    VALUES ('PRUEBA', 'clave-prueba', 'Reaparece', ARRAY['MATRICULA']);
    PERFORM pg_temp.reg('Alerta: una atendida permite volver a avisar', true);

    -- Vistas
    PERFORM pg_temp.reg('Vista: la nómina incluye al matriculado vigente',
        EXISTS (SELECT 1 FROM v_nomina_matriculados WHERE numero_documento = '70000003' AND codigo_matricula = '70000003'));
    PERFORM pg_temp.reg('Vista: el registro de matrícula trae los datos del CETPRO y las unidades',
        EXISTS (SELECT 1 FROM v_registro_matricula_cabecera c
                 WHERE c.id_matricula = pg_temp.mat('70000003', 'Apoyo administrativo') AND c.nombre_cetpro IS NOT NULL)
        AND EXISTS (SELECT 1 FROM v_registro_matricula_unidades u
                     WHERE u.id_matricula = pg_temp.mat('70000003', 'Apoyo administrativo')));
    PERFORM pg_temp.reg('Vista: faltantes de exportación detecta el ubigeo vacío y no el módulo presente',
        EXISTS (SELECT 1 FROM v_datos_faltantes_exportacion
                 WHERE numero_documento = '70000003'
                   AND 'ubigeo' = ANY (campos_faltantes)
                   AND NOT ('modulo' = ANY (campos_faltantes))));
    PERFORM pg_temp.reg('Vista: la matrícula en licencia no aparece en la nómina de vigentes',
        NOT EXISTS (SELECT 1 FROM v_nomina_matriculados WHERE numero_documento = '70000001'));

    -- Matriz de permisos
    PERFORM pg_temp.reg('Permisos: ADMINISTRADOR no tiene acceso a datos de estudiantes',
        NOT EXISTS (SELECT 1 FROM rol_permiso rp
                      JOIN rol r ON r.id = rp.id_rol JOIN permiso p ON p.id = rp.id_permiso
                     WHERE r.codigo = 'ADMINISTRADOR'
                       AND p.codigo IN ('MATRICULA_CONSULTAR', 'SITUACION_ESPECIFICA_VER', 'ESTUDIANTE_MATRICULA_ESCRIBIR')));
    PERFORM pg_temp.reg('Permisos: DIRECTIVO es de solo consulta y reportes',
        NOT EXISTS (SELECT 1 FROM rol_permiso rp
                      JOIN rol r ON r.id = rp.id_rol JOIN permiso p ON p.id = rp.id_permiso
                     WHERE r.codigo = 'DIRECTIVO'
                       AND p.codigo IN ('ESTUDIANTE_MATRICULA_ESCRIBIR', 'MATRICULA_ANULAR', 'USUARIOS_ADMINISTRAR', 'PARAMETROS_EDITAR')));
    PERFORM pg_temp.reg('Permisos: MATRICULA no administra usuarios ni parámetros',
        NOT EXISTS (SELECT 1 FROM rol_permiso rp
                      JOIN rol r ON r.id = rp.id_rol JOIN permiso p ON p.id = rp.id_permiso
                     WHERE r.codigo = 'MATRICULA'
                       AND p.codigo IN ('USUARIOS_ADMINISTRAR', 'PARAMETROS_EDITAR', 'BITACORA_CONSULTAR')));
    PERFORM pg_temp.reg('Permisos: todo permiso está asignado al menos a un rol',
        NOT EXISTS (SELECT 1 FROM permiso p WHERE NOT EXISTS (SELECT 1 FROM rol_permiso rp WHERE rp.id_permiso = p.id)));
EXCEPTION WHEN others THEN
    PERFORM pg_temp.reg('Grupo 5: error inesperado', false, SQLERRM);
END
$t$;

-- ---------------------------------------------------------------------
-- Resultado
-- ---------------------------------------------------------------------
SELECT n, CASE WHEN ok THEN 'OK' ELSE 'FALLA' END AS resultado, prueba, detalle
  FROM resultado_pruebas
 ORDER BY n;

SELECT count(*) FILTER (WHERE ok)     AS aprobadas,
       count(*) FILTER (WHERE NOT ok) AS fallidas,
       count(*)                       AS total
  FROM resultado_pruebas;

ROLLBACK;
