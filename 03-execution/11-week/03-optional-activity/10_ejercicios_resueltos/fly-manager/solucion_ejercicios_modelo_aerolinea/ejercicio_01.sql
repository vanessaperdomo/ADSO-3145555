-- ============================================================
-- EJERCICIO 01 - COMPLETO
-- ============================================================

-- ► REQ 1: Consulta INNER JOIN (7 tablas)
SELECT
    r.reservation_code                        AS codigo_reserva,
    f.flight_number                           AS numero_vuelo,
    f.service_date                            AS fecha_servicio,
    t.ticket_number                           AS numero_tiquete,
    rp.passenger_sequence_no                  AS secuencia_pasajero,
    p.first_name || ' ' || p.last_name        AS nombre_pasajero,
    fs.segment_number                         AS segmento_vuelo,
    fs.scheduled_departure_at                 AS hora_salida_programada
FROM reservation r
INNER JOIN reservation_passenger rp ON rp.reservation_id = r.reservation_id
INNER JOIN person p                  ON p.person_id = rp.person_id
INNER JOIN ticket t                  ON t.reservation_passenger_id = rp.reservation_passenger_id
INNER JOIN ticket_segment ts         ON ts.ticket_id = t.ticket_id
INNER JOIN flight_segment fs         ON fs.flight_segment_id = ts.flight_segment_id
INNER JOIN flight f                  ON f.flight_id = fs.flight_id
ORDER BY f.service_date, f.flight_number, rp.passenger_sequence_no;

-- ► REQ 2: Función del trigger
CREATE OR REPLACE FUNCTION fn_generar_boarding_pass()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO boarding_pass (
        check_in_id,
        boarding_pass_code,
        barcode_value,
        issued_at
    )
    VALUES (
        NEW.check_in_id,
        'BP-' || upper(substring(NEW.check_in_id::text, 1, 8)),
        'BC-' || upper(NEW.check_in_id::text),
        now()
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ► REQ 2: Trigger AFTER INSERT sobre check_in
CREATE OR REPLACE TRIGGER trg_after_checkin_boarding_pass
AFTER INSERT ON check_in
FOR EACH ROW
EXECUTE FUNCTION fn_generar_boarding_pass();

-- ► REQ 3: Procedimiento almacenado
CREATE OR REPLACE PROCEDURE sp_registrar_checkin(
    p_ticket_segment_id   uuid,
    p_check_in_status_id  uuid,
    p_boarding_group_id   uuid,
    p_user_account_id     uuid,
    p_checked_in_at       timestamptz
)
LANGUAGE plpgsql AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM check_in
        WHERE ticket_segment_id = p_ticket_segment_id
    ) THEN
        RAISE EXCEPTION 'Ya existe un check-in para el ticket_segment_id: %', p_ticket_segment_id;
    END IF;

    INSERT INTO check_in (
        ticket_segment_id,
        check_in_status_id,
        boarding_group_id,
        checked_in_by_user_id,
        checked_in_at
    )
    VALUES (
        p_ticket_segment_id,
        p_check_in_status_id,
        p_boarding_group_id,
        p_user_account_id,
        p_checked_in_at
    );

    RAISE NOTICE 'Check-in registrado para ticket_segment_id: %', p_ticket_segment_id;
END;
$$;

-- ► INVOCAR el procedimiento usando variables
DO $$
DECLARE
    v_ticket_segment_id   uuid;
    v_check_in_status_id  uuid;
    v_boarding_group_id   uuid;
    v_user_account_id     uuid;
BEGIN
    SELECT ticket_segment_id INTO v_ticket_segment_id
    FROM ticket_segment
    WHERE ticket_segment_id NOT IN (SELECT ticket_segment_id FROM check_in)
    LIMIT 1;

    SELECT check_in_status_id INTO v_check_in_status_id
    FROM check_in_status LIMIT 1;

    SELECT boarding_group_id INTO v_boarding_group_id
    FROM boarding_group LIMIT 1;

    SELECT user_account_id INTO v_user_account_id
    FROM user_account LIMIT 1;

    CALL sp_registrar_checkin(
        v_ticket_segment_id,
        v_check_in_status_id,
        v_boarding_group_id,
        v_user_account_id,
        now()
    );
END;
$$;

-- ► VALIDACIÓN: Ver el check-in creado
SELECT * FROM check_in ORDER BY created_at DESC LIMIT 3;

-- ► VALIDACIÓN: Ver el boarding_pass generado por el trigger
SELECT
    ci.check_in_id,
    ci.checked_in_at,
    bp.boarding_pass_code,
    bp.barcode_value,
    bp.issued_at
FROM check_in ci
INNER JOIN boarding_pass bp ON bp.check_in_id = ci.check_in_id
ORDER BY ci.created_at DESC
LIMIT 3;