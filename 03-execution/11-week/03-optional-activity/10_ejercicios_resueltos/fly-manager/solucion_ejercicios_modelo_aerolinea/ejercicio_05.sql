-- ============================================================
-- EJERCICIO 05 - Mantenimiento de aeronaves y
--               habilitación operativa
-- ============================================================

-- ► REQ 1: Consulta INNER JOIN (7 tablas)
-- Tablas: aircraft, airline, aircraft_model, aircraft_manufacturer,
--         maintenance_event, maintenance_type, maintenance_provider
SELECT
    a.registration_number              AS matricula_aeronave,
    al.airline_name                    AS aerolinea,
    am.model_name                      AS modelo,
    amf.manufacturer_name              AS fabricante,
    mt.type_name                       AS tipo_mantenimiento,
    mp.provider_name                   AS proveedor,
    me.status_code                     AS estado_evento,
    me.started_at                      AS fecha_inicio,
    me.completed_at                    AS fecha_finalizacion
FROM aircraft a
INNER JOIN airline al                    ON al.airline_id = a.airline_id
INNER JOIN aircraft_model am             ON am.aircraft_model_id = a.aircraft_model_id
INNER JOIN aircraft_manufacturer amf     ON amf.aircraft_manufacturer_id = am.aircraft_manufacturer_id
INNER JOIN maintenance_event me          ON me.aircraft_id = a.aircraft_id
INNER JOIN maintenance_type mt           ON mt.maintenance_type_id = me.maintenance_type_id
INNER JOIN maintenance_provider mp       ON mp.maintenance_provider_id = me.maintenance_provider_id
ORDER BY a.registration_number, me.started_at DESC;

-- ► REQ 2: Función del trigger
-- Cuando se inserta un evento de mantenimiento con status COMPLETED,
-- actualiza updated_at de la aeronave para reflejar el cambio operativo
CREATE OR REPLACE FUNCTION fn_log_mantenimiento_completado()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status_code = 'COMPLETED' THEN
        UPDATE aircraft
        SET updated_at = now()
        WHERE aircraft_id = NEW.aircraft_id;

        RAISE NOTICE 'Aeronave % habilitada operativamente tras mantenimiento completado.',
            NEW.aircraft_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ► REQ 2: Trigger AFTER INSERT sobre maintenance_event
CREATE OR REPLACE TRIGGER trg_after_maintenance_completed
AFTER INSERT ON maintenance_event
FOR EACH ROW
EXECUTE FUNCTION fn_log_mantenimiento_completado();

-- ► REQ 3: Procedimiento almacenado
-- Registra un nuevo evento de mantenimiento para una aeronave existente
CREATE OR REPLACE PROCEDURE sp_registrar_mantenimiento(
    p_aircraft_id              uuid,
    p_maintenance_type_id      uuid,
    p_maintenance_provider_id  uuid,
    p_status_code              varchar,
    p_started_at               timestamptz,
    p_notes                    text
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Validar que la aeronave exista
    IF NOT EXISTS (SELECT 1 FROM aircraft WHERE aircraft_id = p_aircraft_id) THEN
        RAISE EXCEPTION 'No existe aeronave con aircraft_id: %', p_aircraft_id;
    END IF;

    -- Validar el status_code
    IF p_status_code NOT IN ('PLANNED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED') THEN
        RAISE EXCEPTION 'Estado inválido: %. Use PLANNED, IN_PROGRESS, COMPLETED o CANCELLED', p_status_code;
    END IF;

    -- Registrar el evento de mantenimiento
    INSERT INTO maintenance_event (
        aircraft_id,
        maintenance_type_id,
        maintenance_provider_id,
        status_code,
        started_at,
        notes
    )
    VALUES (
        p_aircraft_id,
        p_maintenance_type_id,
        p_maintenance_provider_id,
        p_status_code,
        p_started_at,
        p_notes
    );

    RAISE NOTICE 'Evento de mantenimiento registrado para aeronave: %', p_aircraft_id;
END;
$$;

-- ► INVOCAR el procedimiento con IDs reales
DO $$
DECLARE
    v_aircraft_id             uuid;
    v_maintenance_type_id     uuid;
    v_maintenance_provider_id uuid;
BEGIN
    SELECT aircraft_id INTO v_aircraft_id
    FROM aircraft LIMIT 1;

    SELECT maintenance_type_id INTO v_maintenance_type_id
    FROM maintenance_type LIMIT 1;

    SELECT maintenance_provider_id INTO v_maintenance_provider_id
    FROM maintenance_provider LIMIT 1;

    CALL sp_registrar_mantenimiento(
        v_aircraft_id,
        v_maintenance_type_id,
        v_maintenance_provider_id,
        'COMPLETED',
        now(),
        'Revisión técnica de rutina completada exitosamente'
    );
END;
$$;

-- ► VALIDACIÓN: Ver el evento de mantenimiento registrado
SELECT
    me.maintenance_event_id,
    me.aircraft_id,
    me.status_code,
    me.started_at,
    me.completed_at,
    me.notes
FROM maintenance_event me
ORDER BY me.created_at DESC
LIMIT 3;

-- ► VALIDACIÓN: Ver que el trigger actualizó updated_at de la aeronave
SELECT
    aircraft_id,
    registration_number,
    updated_at
FROM aircraft
ORDER BY updated_at DESC
LIMIT 3;