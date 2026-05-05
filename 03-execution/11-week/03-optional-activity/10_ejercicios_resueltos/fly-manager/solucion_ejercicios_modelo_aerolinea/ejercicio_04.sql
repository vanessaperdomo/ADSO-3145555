-- ============================================================
-- EJERCICIO 04 - Acumulación de millas y actualización
--               del historial de nivel
-- ============================================================

-- ► REQ 1: Consulta INNER JOIN (7 tablas)
-- Tablas: customer, person, loyalty_account, loyalty_program,
--         loyalty_account_tier, loyalty_tier, sale
SELECT
    p.first_name || ' ' || p.last_name    AS nombre_cliente,
    la.account_number                      AS cuenta_fidelizacion,
    lp.program_name                        AS programa,
    lt.tier_name                           AS nivel,
    lat.assigned_at                        AS fecha_asignacion_nivel,
    s.sale_code                            AS venta_relacionada
FROM customer c
INNER JOIN person p                  ON p.person_id = c.person_id
INNER JOIN loyalty_account la        ON la.customer_id = c.customer_id
INNER JOIN loyalty_program lp        ON lp.loyalty_program_id = la.loyalty_program_id
INNER JOIN loyalty_account_tier lat  ON lat.loyalty_account_id = la.loyalty_account_id
INNER JOIN loyalty_tier lt           ON lt.loyalty_tier_id = lat.loyalty_tier_id
INNER JOIN reservation r             ON r.booked_by_customer_id = c.customer_id
INNER JOIN sale s                    ON s.reservation_id = r.reservation_id
ORDER BY p.last_name, la.account_number;

-- ► REQ 2: Función del trigger
-- Cuando se registra una transacción de millas tipo EARN,
-- actualiza el historial de nivel asignando el tier siguiente
-- si las millas acumuladas superan el mínimo requerido
CREATE OR REPLACE FUNCTION fn_actualizar_tier_por_millas()
RETURNS TRIGGER AS $$
DECLARE
    v_total_millas   integer;
    v_nuevo_tier_id  uuid;
    v_program_id     uuid;
BEGIN
    IF NEW.transaction_type = 'EARN' THEN

        -- Calcular total de millas acumuladas en la cuenta
        SELECT COALESCE(SUM(miles_delta), 0)
        INTO v_total_millas
        FROM miles_transaction
        WHERE loyalty_account_id = NEW.loyalty_account_id
          AND transaction_type = 'EARN';

        -- Obtener el programa de la cuenta
        SELECT loyalty_program_id INTO v_program_id
        FROM loyalty_account
        WHERE loyalty_account_id = NEW.loyalty_account_id;

        -- Buscar el tier más alto que el cliente puede alcanzar
        SELECT loyalty_tier_id INTO v_nuevo_tier_id
        FROM loyalty_tier
        WHERE loyalty_program_id = v_program_id
          AND required_miles <= v_total_millas
        ORDER BY required_miles DESC
        LIMIT 1;

        -- Registrar el nuevo nivel si encontró uno
        IF v_nuevo_tier_id IS NOT NULL THEN
            INSERT INTO loyalty_account_tier (
                loyalty_account_id,
                loyalty_tier_id,
                assigned_at
            )
            VALUES (
                NEW.loyalty_account_id,
                v_nuevo_tier_id,
                now()
            )
            ON CONFLICT (loyalty_account_id, assigned_at) DO NOTHING;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ► REQ 2: Trigger AFTER INSERT sobre miles_transaction
CREATE OR REPLACE TRIGGER trg_after_miles_earn_tier
AFTER INSERT ON miles_transaction
FOR EACH ROW
EXECUTE FUNCTION fn_actualizar_tier_por_millas();

-- ► REQ 3: Procedimiento almacenado
-- Registra una transacción de millas para una cuenta existente
CREATE OR REPLACE PROCEDURE sp_registrar_millas(
    p_loyalty_account_id  uuid,
    p_transaction_type    varchar,
    p_miles_delta         integer,
    p_occurred_at         timestamptz,
    p_reference_code      varchar,
    p_notes               text
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Validar que la cuenta exista
    IF NOT EXISTS (
        SELECT 1 FROM loyalty_account
        WHERE loyalty_account_id = p_loyalty_account_id
    ) THEN
        RAISE EXCEPTION 'No existe cuenta de fidelización con id: %', p_loyalty_account_id;
    END IF;

    -- Validar tipo de transacción
    IF p_transaction_type NOT IN ('EARN', 'REDEEM', 'ADJUST') THEN
        RAISE EXCEPTION 'Tipo de transacción inválido: %', p_transaction_type;
    END IF;

    -- Validar que miles_delta no sea cero
    IF p_miles_delta = 0 THEN
        RAISE EXCEPTION 'El delta de millas no puede ser cero';
    END IF;

    -- Registrar la transacción
    INSERT INTO miles_transaction (
        loyalty_account_id,
        transaction_type,
        miles_delta,
        occurred_at,
        reference_code,
        notes
    )
    VALUES (
        p_loyalty_account_id,
        p_transaction_type,
        p_miles_delta,
        p_occurred_at,
        p_reference_code,
        p_notes
    );

    RAISE NOTICE 'Transacción % de % millas registrada en cuenta: %',
        p_transaction_type, p_miles_delta, p_loyalty_account_id;
END;
$$;

-- ► INVOCAR el procedimiento con IDs reales
DO $$
DECLARE
    v_loyalty_account_id uuid;
BEGIN
    SELECT loyalty_account_id INTO v_loyalty_account_id
    FROM loyalty_account
    LIMIT 1;

    CALL sp_registrar_millas(
        v_loyalty_account_id,
        'EARN',
        5000,
        now(),
        'VUELO-FY210-20260304',
        'Millas acumuladas por vuelo FY210'
    );
END;
$$;

-- ► VALIDACIÓN: Ver la transacción de millas registrada
SELECT
    mt.miles_transaction_id,
    mt.loyalty_account_id,
    mt.transaction_type,
    mt.miles_delta,
    mt.occurred_at,
    mt.reference_code,
    mt.notes
FROM miles_transaction mt
ORDER BY mt.created_at DESC
LIMIT 3;

-- ► VALIDACIÓN: Ver el nivel asignado por el trigger
SELECT
    lat.loyalty_account_tier_id,
    lat.loyalty_account_id,
    lt.tier_name,
    lt.required_miles,
    lat.assigned_at
FROM loyalty_account_tier lat
INNER JOIN loyalty_tier lt ON lt.loyalty_tier_id = lat.loyalty_tier_id
ORDER BY lat.created_at DESC
LIMIT 3;