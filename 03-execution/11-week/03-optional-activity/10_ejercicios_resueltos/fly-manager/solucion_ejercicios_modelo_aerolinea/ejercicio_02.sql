-- ============================================================
-- EJERCICIO 02 - Control de pagos y trazabilidad de
--               transacciones financieras
-- ============================================================

-- ► REQ 1: Consulta INNER JOIN (7 tablas)
-- Tablas: sale, reservation, payment, payment_status,
--         payment_method, payment_transaction, currency
SELECT
    s.sale_code                          AS codigo_venta,
    r.reservation_code                   AS codigo_reserva,
    p.payment_reference                  AS referencia_pago,
    ps.status_name                       AS estado_pago,
    pm.method_name                       AS metodo_pago,
    pt.transaction_reference             AS referencia_transaccion,
    pt.transaction_type                  AS tipo_transaccion,
    pt.transaction_amount                AS monto_procesado,
    c.iso_currency_code                  AS moneda
FROM sale s
INNER JOIN reservation r          ON r.reservation_id = s.reservation_id
INNER JOIN payment p              ON p.sale_id = s.sale_id
INNER JOIN payment_status ps      ON ps.payment_status_id = p.payment_status_id
INNER JOIN payment_method pm      ON pm.payment_method_id = p.payment_method_id
INNER JOIN payment_transaction pt ON pt.payment_id = p.payment_id
INNER JOIN currency c             ON c.currency_id = p.currency_id
ORDER BY s.sale_code, p.payment_reference, pt.processed_at;

-- ► REQ 2: Función del trigger
-- Cuando se inserta una transacción de tipo REVERSAL,
-- se genera automáticamente una devolución en refund
CREATE OR REPLACE FUNCTION fn_generar_refund_por_reversal()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.transaction_type = 'REVERSAL' THEN
        INSERT INTO refund (
            payment_id,
            refund_reference,
            amount,
            requested_at,
            refund_reason
        )
        VALUES (
            NEW.payment_id,
            'REF-' || upper(substring(NEW.payment_transaction_id::text, 1, 12)),
            NEW.transaction_amount,
            now(),
            'Reversión automática generada por transacción: ' || NEW.transaction_reference
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ► REQ 2: Trigger AFTER INSERT sobre payment_transaction
CREATE OR REPLACE TRIGGER trg_after_reversal_refund
AFTER INSERT ON payment_transaction
FOR EACH ROW
EXECUTE FUNCTION fn_generar_refund_por_reversal();

-- ► REQ 3: Procedimiento almacenado
-- Registra una transacción financiera sobre un pago existente
CREATE OR REPLACE PROCEDURE sp_registrar_transaccion_pago(
    p_payment_id            uuid,
    p_transaction_reference varchar,
    p_transaction_type      varchar,
    p_transaction_amount    numeric,
    p_processed_at          timestamptz,
    p_provider_message      text
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Validar que el pago exista
    IF NOT EXISTS (SELECT 1 FROM payment WHERE payment_id = p_payment_id) THEN
        RAISE EXCEPTION 'No existe un pago con payment_id: %', p_payment_id;
    END IF;

    -- Validar tipo de transacción
    IF p_transaction_type NOT IN ('AUTH', 'CAPTURE', 'VOID', 'REFUND', 'REVERSAL') THEN
        RAISE EXCEPTION 'Tipo de transacción inválido: %', p_transaction_type;
    END IF;

    -- Registrar la transacción
    INSERT INTO payment_transaction (
        payment_id,
        transaction_reference,
        transaction_type,
        transaction_amount,
        processed_at,
        provider_message
    )
    VALUES (
        p_payment_id,
        p_transaction_reference,
        p_transaction_type,
        p_transaction_amount,
        p_processed_at,
        p_provider_message
    );

    RAISE NOTICE 'Transacción % registrada para payment_id: %', p_transaction_type, p_payment_id;
END;
$$;

-- ► INVOCAR el procedimiento con IDs reales
-- Al usar tipo REVERSAL, el trigger genera el refund automáticamente
DO $$
DECLARE
    v_payment_id uuid;
BEGIN
    SELECT payment_id INTO v_payment_id
    FROM payment
    LIMIT 1;

    CALL sp_registrar_transaccion_pago(
        v_payment_id,
        'TXN-REV-' || to_char(now(), 'YYYYMMDDHHMMSS'),
        'REVERSAL',
        150.00,
        now(),
        'Reversión de prueba generada por procedimiento'
    );
END;
$$;

-- ► VALIDACIÓN: Ver la transacción registrada
SELECT
    pt.payment_transaction_id,
    pt.transaction_reference,
    pt.transaction_type,
    pt.transaction_amount,
    pt.processed_at,
    pt.provider_message
FROM payment_transaction pt
ORDER BY pt.created_at DESC
LIMIT 3;

-- ► VALIDACIÓN: Ver el refund generado automáticamente por el trigger
SELECT
    r.refund_id,
    r.payment_id,
    r.refund_reference,
    r.amount,
    r.requested_at,
    r.refund_reason
FROM refund r
ORDER BY r.created_at DESC
LIMIT 3;