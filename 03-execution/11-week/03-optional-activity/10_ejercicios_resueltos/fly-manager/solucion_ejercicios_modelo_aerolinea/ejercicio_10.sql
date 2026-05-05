-- ============================================================
-- EJERCICIO 10 - Identidad de pasajeros, documentos y contactos
-- ============================================================

-- ► REQ 1: INNER JOIN (8 tablas)
SELECT
    p.first_name || ' ' || p.last_name    AS pasajero,
    pt.type_name                           AS tipo_persona,
    dt.type_name                           AS tipo_documento,
    pd.document_number                     AS numero_documento,
    pd.expires_on                          AS vencimiento_documento,
    ct.type_name                           AS tipo_contacto,
    pc.contact_value                       AS valor_contacto,
    r.reservation_code                     AS codigo_reserva,
    rp.passenger_sequence_no               AS secuencia_pasajero,
    rp.passenger_type                      AS tipo_pasajero
FROM person p
INNER JOIN person_type pt           ON pt.person_type_id = p.person_type_id
INNER JOIN person_document pd       ON pd.person_id = p.person_id
INNER JOIN document_type dt         ON dt.document_type_id = pd.document_type_id
INNER JOIN person_contact pc        ON pc.person_id = p.person_id
INNER JOIN contact_type ct          ON ct.contact_type_id = pc.contact_type_id
INNER JOIN reservation_passenger rp ON rp.person_id = p.person_id
INNER JOIN reservation r            ON r.reservation_id = rp.reservation_id
ORDER BY p.last_name, p.first_name, pd.document_number;


-- ► REQ 2: Función y trigger AFTER INSERT sobre person_document
CREATE OR REPLACE FUNCTION fn_actualizar_persona_por_documento()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE person
    SET updated_at = now()
    WHERE person_id = NEW.person_id;

    RAISE NOTICE 'Documento % registrado. Persona % marcada como actualizada.',
        NEW.document_number, NEW.person_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_after_person_document_insert
AFTER INSERT ON person_document
FOR EACH ROW EXECUTE FUNCTION fn_actualizar_persona_por_documento();


-- ► REQ 3: Procedimiento almacenado
CREATE OR REPLACE PROCEDURE sp_registrar_documento(
    p_person_id          uuid,
    p_document_type_id   uuid,
    p_issuing_country_id uuid,
    p_document_number    varchar,
    p_issued_on          date DEFAULT NULL,
    p_expires_on         date DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM person WHERE person_id = p_person_id) THEN
        RAISE EXCEPTION 'No existe persona con id: %', p_person_id;
    END IF;

    IF p_expires_on IS NOT NULL AND p_issued_on IS NOT NULL
       AND p_expires_on < p_issued_on THEN
        RAISE EXCEPTION 'La fecha de vencimiento no puede ser anterior a la de emisión.';
    END IF;

    INSERT INTO person_document (
        person_id, document_type_id, issuing_country_id,
        document_number, issued_on, expires_on
    )
    VALUES (
        p_person_id, p_document_type_id, p_issuing_country_id,
        p_document_number, p_issued_on, p_expires_on
    );

    RAISE NOTICE 'Documento % registrado exitosamente para persona %.', p_document_number, p_person_id;
END;
$$;


-- ► Script de uso del procedimiento
DO $$
DECLARE
    v_person_id          uuid;
    v_document_type_id   uuid;
    v_issuing_country_id uuid;
BEGIN
    SELECT person_id        INTO v_person_id          FROM person        LIMIT 1;
    SELECT document_type_id INTO v_document_type_id   FROM document_type LIMIT 1;
    SELECT country_id       INTO v_issuing_country_id FROM country       LIMIT 1;

    CALL sp_registrar_documento(
        v_person_id,
        v_document_type_id,
        v_issuing_country_id,
        'EJ10-' || to_char(now(), 'MMDDHH24MISS'),
        (CURRENT_DATE - interval '2 years')::date,
        (CURRENT_DATE + interval '8 years')::date
    );
END;
$$;


-- ► Script que dispara el trigger
DO $$
DECLARE
    v_person_id             uuid;
    v_document_type_id      uuid;
    v_issuing_country_id    uuid;
    v_person_updated_before timestamptz;
    v_person_updated_after  timestamptz;
BEGIN
    SELECT person_id        INTO v_person_id          FROM person        LIMIT 1;
    SELECT document_type_id INTO v_document_type_id   FROM document_type LIMIT 1;
    SELECT country_id       INTO v_issuing_country_id FROM country       LIMIT 1;

    SELECT updated_at INTO v_person_updated_before
    FROM person WHERE person_id = v_person_id;

    RAISE NOTICE 'Person updated_at ANTES: %', v_person_updated_before;

    INSERT INTO person_document (
        person_id, document_type_id, issuing_country_id,
        document_number, issued_on, expires_on
    )
    VALUES (
        v_person_id, v_document_type_id, v_issuing_country_id,
        'TRG-' || to_char(now(), 'MMDDHH24MISS'),
        CURRENT_DATE,
        (CURRENT_DATE + interval '5 years')::date
    );

    SELECT updated_at INTO v_person_updated_after
    FROM person WHERE person_id = v_person_id;

    RAISE NOTICE 'Person updated_at DESPUÉS: %', v_person_updated_after;
    RAISE NOTICE 'Trigger ejecutado correctamente: %', v_person_updated_after > v_person_updated_before;
END;
$$;


-- ► Validaciones
SELECT
    p.first_name || ' ' || p.last_name AS pasajero,
    dt.type_name                        AS tipo_documento,
    pd.document_number,
    pd.issued_on,
    pd.expires_on,
    p.updated_at                        AS persona_updated_at
FROM person_document pd
INNER JOIN person        p  ON p.person_id = pd.person_id
INNER JOIN document_type dt ON dt.document_type_id = pd.document_type_id
ORDER BY pd.created_at DESC
LIMIT 5;

SELECT
    p.first_name || ' ' || p.last_name AS pasajero,
    ct.type_name                        AS tipo_contacto,
    pc.contact_value,
    pc.is_primary
FROM person_contact pc
INNER JOIN person       p  ON p.person_id = pc.person_id
INNER JOIN contact_type ct ON ct.contact_type_id = pc.contact_type_id
ORDER BY pc.created_at DESC
LIMIT 5;