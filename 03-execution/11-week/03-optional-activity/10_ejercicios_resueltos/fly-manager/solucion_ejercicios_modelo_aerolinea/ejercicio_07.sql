-- ============================================================
-- EJERCICIO 07 - Asignación de asientos y registro de equipaje
--               por segmento ticketed
-- ============================================================

-- ► REQ 1: Consulta INNER JOIN (8 tablas)
-- Tablas: ticket, ticket_segment, flight_segment, flight,
--         seat_assignment, aircraft_seat, aircraft_cabin,
--         cabin_class, baggage
SELECT
    t.ticket_number                        AS numero_tiquete,
    ts.segment_sequence_no                 AS secuencia_segmento,
    f.flight_number                        AS numero_vuelo,
    cc.class_name                          AS cabina,
    ase.seat_row_number                    AS fila_asiento,
    ase.seat_column_code                   AS columna_asiento,
    sa.assignment_source                   AS fuente_asignacion,
    b.baggage_tag                          AS etiqueta_equipaje,
    b.baggage_type                         AS tipo_equipaje,
    b.baggage_status                       AS estado_equipaje,
    b.weight_kg                            AS peso_kg
FROM ticket t
INNER JOIN ticket_segment ts           ON ts.ticket_id = t.ticket_id
INNER JOIN flight_segment fs           ON fs.flight_segment_id = ts.flight_segment_id
INNER JOIN flight f                    ON f.flight_id = fs.flight_id
INNER JOIN seat_assignment sa          ON sa.ticket_segment_id = ts.ticket_segment_id
INNER JOIN aircraft_seat ase           ON ase.aircraft_seat_id = sa.aircraft_seat_id
INNER JOIN aircraft_cabin ac           ON ac.aircraft_cabin_id = ase.aircraft_cabin_id
INNER JOIN cabin_class cc              ON cc.cabin_class_id = ac.cabin_class_id
INNER JOIN baggage b                   ON b.ticket_segment_id = ts.ticket_segment_id
ORDER BY t.ticket_number, ts.segment_sequence_no;

-- ► REQ 2: Función del trigger
-- Cuando se registra un equipaje, actualiza updated_at del
-- ticket_segment para reflejar el cambio en el flujo aeroportuario
CREATE OR REPLACE FUNCTION fn_actualizar_segmento_por_equipaje()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE ticket_segment
    SET updated_at = now()
    WHERE ticket_segment_id = NEW.ticket_segment_id;

    RAISE NOTICE 'Equipaje % registrado para ticket_segment: %',
        NEW.baggage_tag, NEW.ticket_segment_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ► REQ 2: Trigger AFTER INSERT sobre baggage
CREATE OR REPLACE TRIGGER trg_after_baggage_insert
AFTER INSERT ON baggage
FOR EACH ROW
EXECUTE FUNCTION fn_actualizar_segmento_por_equipaje();

-- ► REQ 3: Procedimiento almacenado
-- Registra equipaje para un ticket_segment existente
CREATE OR REPLACE PROCEDURE sp_registrar_equipaje(
    p_ticket_segment_id  uuid,
    p_baggage_tag        varchar,
    p_baggage_type       varchar,
    p_weight_kg          numeric,
    p_checked_at         timestamptz
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Validar que el ticket_segment exista
    IF NOT EXISTS (
        SELECT 1 FROM ticket_segment
        WHERE ticket_segment_id = p_ticket_segment_id
    ) THEN
        RAISE EXCEPTION 'No existe ticket_segment con id: %', p_ticket_segment_id;
    END IF;

    -- Validar tipo de equipaje
    IF p_baggage_type NOT IN ('CHECKED', 'CARRY_ON', 'SPECIAL') THEN
        RAISE EXCEPTION 'Tipo inválido: %. Use CHECKED, CARRY_ON o SPECIAL', p_baggage_type;
    END IF;

    -- Validar peso
    IF p_weight_kg <= 0 THEN
        RAISE EXCEPTION 'El peso debe ser mayor a cero';
    END IF;

    -- Registrar el equipaje
    INSERT INTO baggage (
        ticket_segment_id,
        baggage_tag,
        baggage_type,
        baggage_status,
        weight_kg,
        checked_at
    )
    VALUES (
        p_ticket_segment_id,
        p_baggage_tag,
        p_baggage_type,
        'REGISTERED',
        p_weight_kg,
        p_checked_at
    );

    RAISE NOTICE 'Equipaje % registrado para ticket_segment: %',
        p_baggage_tag, p_ticket_segment_id;
END;
$$;

-- ► INVOCAR el procedimiento con IDs reales
DO $$
DECLARE
    v_ticket_segment_id uuid;
BEGIN
    SELECT ticket_segment_id INTO v_ticket_segment_id
    FROM ticket_segment
    LIMIT 1;

    CALL sp_registrar_equipaje(
        v_ticket_segment_id,
        'BAG-' || to_char(now(), 'YYYYMMDDHHMMSS'),
        'CHECKED',
        23.50,
        now()
    );
END;
$$;

-- ► VALIDACIÓN: Ver el equipaje registrado
SELECT
    b.baggage_id,
    b.ticket_segment_id,
    b.baggage_tag,
    b.baggage_type,
    b.baggage_status,
    b.weight_kg,
    b.checked_at
FROM baggage b
ORDER BY b.created_at DESC
LIMIT 3;

-- ► VALIDACIÓN: Ver que el trigger actualizó el ticket_segment
SELECT
    ticket_segment_id,
    segment_sequence_no,
    updated_at
FROM ticket_segment
ORDER BY updated_at DESC
LIMIT 3;