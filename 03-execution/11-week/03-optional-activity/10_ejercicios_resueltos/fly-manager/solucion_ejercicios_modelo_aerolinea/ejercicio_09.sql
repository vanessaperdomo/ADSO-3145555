-- ============================================================
-- EJERCICIO 09 - Publicación de tarifas y análisis de reservas
-- ============================================================

-- ► REQ 1: INNER JOIN (9 tablas)
SELECT
    al.airline_name          AS aerolinea,
    f.fare_code              AS codigo_tarifa,
    fc.fare_class_code       AS clase_tarifaria,
    fc.fare_class_name       AS nombre_clase,
    ao.iata_code             AS aeropuerto_origen,
    ad.iata_code             AS aeropuerto_destino,
    cu.iso_currency_code     AS moneda,
    f.base_amount            AS monto_base,
    f.valid_from             AS vigencia_desde,
    f.valid_to               AS vigencia_hasta,
    r.reservation_code       AS codigo_reserva,
    s.sale_code              AS codigo_venta,
    t.ticket_number          AS numero_tiquete
FROM fare f
INNER JOIN airline al      ON al.airline_id = f.airline_id
INNER JOIN fare_class fc   ON fc.fare_class_id = f.fare_class_id
INNER JOIN airport ao      ON ao.airport_id = f.origin_airport_id
INNER JOIN airport ad      ON ad.airport_id = f.destination_airport_id
INNER JOIN currency cu     ON cu.currency_id = f.currency_id
INNER JOIN ticket t        ON t.fare_id = f.fare_id
INNER JOIN sale s          ON s.sale_id = t.sale_id
INNER JOIN reservation r   ON r.reservation_id = s.reservation_id
ORDER BY al.airline_name, f.fare_code;


-- ► REQ 2: Función y trigger AFTER INSERT sobre ticket
CREATE OR REPLACE FUNCTION fn_actualizar_tarifa_por_tiquete()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE fare SET updated_at = now() WHERE fare_id = NEW.fare_id;
    RAISE NOTICE 'Tiquete % emitido. Tarifa % actualizada.', NEW.ticket_number, NEW.fare_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_after_ticket_insert
AFTER INSERT ON ticket
FOR EACH ROW EXECUTE FUNCTION fn_actualizar_tarifa_por_tiquete();


-- ► REQ 3: Procedimiento almacenado
CREATE OR REPLACE PROCEDURE sp_publicar_tarifa(
    p_airline_id             uuid,
    p_origin_airport_id      uuid,
    p_destination_airport_id uuid,
    p_fare_class_id          uuid,
    p_currency_id            uuid,
    p_fare_code              varchar,
    p_base_amount            numeric,
    p_valid_from             date,
    p_valid_to               date,
    p_baggage_allowance_qty  integer DEFAULT 0
)
LANGUAGE plpgsql AS $$
BEGIN
    IF p_origin_airport_id = p_destination_airport_id THEN
        RAISE EXCEPTION 'Origen y destino no pueden ser el mismo.';
    END IF;
    IF p_base_amount < 0 THEN
        RAISE EXCEPTION 'El monto base no puede ser negativo.';
    END IF;
    IF p_valid_to IS NOT NULL AND p_valid_to <= p_valid_from THEN
        RAISE EXCEPTION 'valid_to debe ser posterior a valid_from.';
    END IF;

    INSERT INTO fare (
        airline_id, origin_airport_id, destination_airport_id,
        fare_class_id, currency_id, fare_code, base_amount,
        valid_from, valid_to, baggage_allowance_qty
    )
    VALUES (
        p_airline_id, p_origin_airport_id, p_destination_airport_id,
        p_fare_class_id, p_currency_id, p_fare_code, p_base_amount,
        p_valid_from, p_valid_to, p_baggage_allowance_qty
    );

    RAISE NOTICE 'Tarifa % publicada exitosamente.', p_fare_code;
END;
$$;


-- ► Script de uso del procedimiento
DO $$
DECLARE
    v_airline_id     uuid;
    v_origin_id      uuid;
    v_destination_id uuid;
    v_fare_class_id  uuid;
    v_currency_id    uuid;
BEGIN
    SELECT airline_id  INTO v_airline_id     FROM airline    LIMIT 1;
    SELECT airport_id  INTO v_origin_id      FROM airport    LIMIT 1;
    SELECT airport_id  INTO v_destination_id FROM airport    WHERE airport_id <> v_origin_id LIMIT 1;
    SELECT fare_class_id INTO v_fare_class_id FROM fare_class LIMIT 1;
    SELECT currency_id INTO v_currency_id    FROM currency   LIMIT 1;

    CALL sp_publicar_tarifa(
        v_airline_id, v_origin_id, v_destination_id,
        v_fare_class_id, v_currency_id,
        'EJ09-' || to_char(now(), 'MMDDHH24MISS'),
        350.00, CURRENT_DATE, (CURRENT_DATE + interval '180 days')::date, 1
    );
END;
$$;


-- ► Script que dispara el trigger
DO $$
DECLARE
    v_fare_id                  uuid;
    v_sale_id                  uuid;
    v_reservation_passenger_id uuid;
    v_ticket_status_id         uuid;
BEGIN
    SELECT fare_id                  INTO v_fare_id                  FROM fare               ORDER BY created_at DESC LIMIT 1;
    SELECT sale_id                  INTO v_sale_id                  FROM sale               LIMIT 1;
    SELECT reservation_passenger_id INTO v_reservation_passenger_id FROM reservation_passenger LIMIT 1;
    SELECT ticket_status_id         INTO v_ticket_status_id         FROM ticket_status      LIMIT 1;

    INSERT INTO ticket (sale_id, reservation_passenger_id, fare_id, ticket_status_id, ticket_number, issued_at)
    VALUES (v_sale_id, v_reservation_passenger_id, v_fare_id, v_ticket_status_id,
            'T09-' || to_char(now(), 'MMDDHH24MISS'), now());
END;
$$;


-- ► Validaciones
SELECT f.fare_code, al.airline_name, ao.iata_code AS origen, ad.iata_code AS destino,
       f.base_amount, f.created_at, f.updated_at
FROM fare f
INNER JOIN airline al  ON al.airline_id = f.airline_id
INNER JOIN airport ao  ON ao.airport_id = f.origin_airport_id
INNER JOIN airport ad  ON ad.airport_id = f.destination_airport_id
ORDER BY f.created_at DESC LIMIT 3;

SELECT t.ticket_number, t.issued_at, f.fare_code, f.updated_at AS tarifa_updated_at
FROM ticket t
INNER JOIN fare f ON f.fare_id = t.fare_id
ORDER BY t.created_at DESC LIMIT 3;