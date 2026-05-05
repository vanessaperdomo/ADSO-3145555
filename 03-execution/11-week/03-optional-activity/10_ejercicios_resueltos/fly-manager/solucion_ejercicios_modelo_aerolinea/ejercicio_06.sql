-- ============================================================
-- EJERCICIO 06 - Retrasos operativos y análisis de impacto
--               por segmento de vuelo
-- ============================================================

-- ► REQ 1: Consulta INNER JOIN (8 tablas)
-- Tablas: airline, flight, flight_status, flight_segment,
--         airport (origen), airport (destino), flight_delay, delay_reason_type
SELECT
    al.airline_name                        AS aerolinea,
    f.flight_number                        AS numero_vuelo,
    f.service_date                         AS fecha_servicio,
    fs_status.status_name                  AS estado_vuelo,
    fs.segment_number                      AS segmento,
    ao.iata_code                           AS aeropuerto_origen,
    ad.iata_code                           AS aeropuerto_destino,
    fd.delay_minutes                       AS minutos_demora,
    drt.reason_name                        AS motivo_retraso,
    fd.reported_at                         AS fecha_reporte
FROM flight f
INNER JOIN airline al                      ON al.airline_id = f.airline_id
INNER JOIN flight_status fs_status         ON fs_status.flight_status_id = f.flight_status_id
INNER JOIN flight_segment fs               ON fs.flight_id = f.flight_id
INNER JOIN airport ao                      ON ao.airport_id = fs.origin_airport_id
INNER JOIN airport ad                      ON ad.airport_id = fs.destination_airport_id
INNER JOIN flight_delay fd                 ON fd.flight_segment_id = fs.flight_segment_id
INNER JOIN delay_reason_type drt           ON drt.delay_reason_type_id = fd.delay_reason_type_id
ORDER BY f.service_date, f.flight_number, fs.segment_number;

-- ► REQ 2: Función del trigger
-- Cuando se registra una demora, actualiza updated_at del
-- flight_segment afectado para reflejar el impacto operacional
CREATE OR REPLACE FUNCTION fn_actualizar_segmento_por_demora()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE flight_segment
    SET updated_at = now()
    WHERE flight_segment_id = NEW.flight_segment_id;

    RAISE NOTICE 'Segmento % impactado por demora de % minutos.',
        NEW.flight_segment_id, NEW.delay_minutes;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ► REQ 2: Trigger AFTER INSERT sobre flight_delay
CREATE OR REPLACE TRIGGER trg_after_flight_delay_insert
AFTER INSERT ON flight_delay
FOR EACH ROW
EXECUTE FUNCTION fn_actualizar_segmento_por_demora();

-- ► REQ 3: Procedimiento almacenado
-- Registra una demora para un flight_segment existente
CREATE OR REPLACE PROCEDURE sp_registrar_demora(
    p_flight_segment_id      uuid,
    p_delay_reason_type_id   uuid,
    p_reported_at            timestamptz,
    p_delay_minutes          integer,
    p_notes                  text
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Validar que el segmento exista
    IF NOT EXISTS (
        SELECT 1 FROM flight_segment
        WHERE flight_segment_id = p_flight_segment_id
    ) THEN
        RAISE EXCEPTION 'No existe segmento con flight_segment_id: %', p_flight_segment_id;
    END IF;

    -- Validar que los minutos sean positivos
    IF p_delay_minutes <= 0 THEN
        RAISE EXCEPTION 'Los minutos de demora deben ser mayores a cero';
    END IF;

    -- Registrar la demora
    INSERT INTO flight_delay (
        flight_segment_id,
        delay_reason_type_id,
        reported_at,
        delay_minutes,
        notes
    )
    VALUES (
        p_flight_segment_id,
        p_delay_reason_type_id,
        p_reported_at,
        p_delay_minutes,
        p_notes
    );

    RAISE NOTICE 'Demora de % minutos registrada para segmento: %',
        p_delay_minutes, p_flight_segment_id;
END;
$$;

-- ► INVOCAR el procedimiento con IDs reales
DO $$
DECLARE
    v_flight_segment_id    uuid;
    v_delay_reason_type_id uuid;
BEGIN
    SELECT fs.flight_segment_id INTO v_flight_segment_id
    FROM flight_segment fs
    LIMIT 1;

    SELECT delay_reason_type_id INTO v_delay_reason_type_id
    FROM delay_reason_type
    LIMIT 1;

    CALL sp_registrar_demora(
        v_flight_segment_id,
        v_delay_reason_type_id,
        now(),
        45,
        'Demora por condiciones climáticas en aeropuerto de origen'
    );
END;
$$;

-- ► VALIDACIÓN: Ver la demora registrada
SELECT
    fd.flight_delay_id,
    fd.flight_segment_id,
    drt.reason_name        AS motivo,
    fd.delay_minutes       AS minutos,
    fd.reported_at,
    fd.notes
FROM flight_delay fd
INNER JOIN delay_reason_type drt ON drt.delay_reason_type_id = fd.delay_reason_type_id
ORDER BY fd.created_at DESC
LIMIT 3;

-- ► VALIDACIÓN: Ver que el trigger actualizó el segmento
SELECT
    flight_segment_id,
    segment_number,
    scheduled_departure_at,
    updated_at
FROM flight_segment
ORDER BY updated_at DESC
LIMIT 3;