-- ============================================================
-- EJERCICIO 03 - Facturación e integración entre venta,
--               impuestos y detalle facturable
-- ============================================================

-- ► REQ 1: Consulta INNER JOIN (6 tablas)
-- Tablas: sale, invoice, invoice_status, invoice_line, tax, currency
SELECT
    s.sale_code                        AS codigo_venta,
    i.invoice_number                   AS numero_factura,
    ist.status_name                    AS estado_factura,
    il.line_number                     AS linea_facturable,
    il.line_description                AS descripcion_linea,
    il.quantity                        AS cantidad,
    il.unit_price                      AS precio_unitario,
    t.tax_name                         AS impuesto_aplicado,
    t.rate_percentage                  AS porcentaje_impuesto,
    c.iso_currency_code                AS moneda
FROM sale s
INNER JOIN invoice i             ON i.sale_id = s.sale_id
INNER JOIN invoice_status ist    ON ist.invoice_status_id = i.invoice_status_id
INNER JOIN invoice_line il       ON il.invoice_id = i.invoice_id
INNER JOIN tax t                 ON t.tax_id = il.tax_id
INNER JOIN currency c            ON c.currency_id = i.currency_id
ORDER BY s.sale_code, i.invoice_number, il.line_number;

-- ► REQ 2: Función del trigger
-- Cuando se inserta una línea facturable, registra en el log
-- de la factura la cantidad de líneas acumuladas (usando notes)
CREATE OR REPLACE FUNCTION fn_actualizar_notas_factura()
RETURNS TRIGGER AS $$
DECLARE
    v_total_lineas integer;
BEGIN
    SELECT COUNT(*) INTO v_total_lineas
    FROM invoice_line
    WHERE invoice_id = NEW.invoice_id;

    UPDATE invoice
    SET notes = 'Total líneas registradas: ' || v_total_lineas::text,
        updated_at = now()
    WHERE invoice_id = NEW.invoice_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ► REQ 2: Trigger AFTER INSERT sobre invoice_line
CREATE OR REPLACE TRIGGER trg_after_invoice_line_insert
AFTER INSERT ON invoice_line
FOR EACH ROW
EXECUTE FUNCTION fn_actualizar_notas_factura();

-- ► REQ 3: Procedimiento almacenado
-- Registra una nueva línea facturable sobre una factura existente
CREATE OR REPLACE PROCEDURE sp_registrar_linea_factura(
    p_invoice_id       uuid,
    p_tax_id           uuid,
    p_line_description varchar,
    p_quantity         numeric,
    p_unit_price       numeric
)
LANGUAGE plpgsql AS $$
DECLARE
    v_next_line integer;
BEGIN
    -- Validar que la factura exista
    IF NOT EXISTS (SELECT 1 FROM invoice WHERE invoice_id = p_invoice_id) THEN
        RAISE EXCEPTION 'No existe una factura con invoice_id: %', p_invoice_id;
    END IF;

    -- Calcular el siguiente número de línea
    SELECT COALESCE(MAX(line_number), 0) + 1
    INTO v_next_line
    FROM invoice_line
    WHERE invoice_id = p_invoice_id;

    -- Insertar la línea facturable
    INSERT INTO invoice_line (
        invoice_id,
        tax_id,
        line_number,
        line_description,
        quantity,
        unit_price
    )
    VALUES (
        p_invoice_id,
        p_tax_id,
        v_next_line,
        p_line_description,
        p_quantity,
        p_unit_price
    );

    RAISE NOTICE 'Línea % registrada en factura: %', v_next_line, p_invoice_id;
END;
$$;

-- ► INVOCAR el procedimiento con IDs reales
DO $$
DECLARE
    v_invoice_id uuid;
    v_tax_id     uuid;
BEGIN
    SELECT invoice_id INTO v_invoice_id
    FROM invoice
    LIMIT 1;

    SELECT tax_id INTO v_tax_id
    FROM tax
    LIMIT 1;

    CALL sp_registrar_linea_factura(
        v_invoice_id,
        v_tax_id,
        'Tiquete aéreo - servicio de transporte',
        1,
        350.00
    );
END;
$$;

-- ► VALIDACIÓN: Ver la línea registrada
SELECT
    il.invoice_line_id,
    il.invoice_id,
    il.line_number,
    il.line_description,
    il.quantity,
    il.unit_price
FROM invoice_line il
ORDER BY il.created_at DESC
LIMIT 3;

-- ► VALIDACIÓN: Ver que el trigger actualizó notes en la factura
SELECT
    invoice_id,
    invoice_number,
    notes,
    updated_at
FROM invoice
ORDER BY updated_at DESC
LIMIT 3;