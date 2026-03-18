-- ============================================================
--  reporte_maestro.sql
--  Ficha completa de cada venta: cliente, medicamentos,
--  cantidades, precios y método de pago.
-- ============================================================

SELECT
    -- Identificación de la venta
    v.id                                            AS "ID Venta",
    v.fecha_venta                                   AS "Fecha",
    v.estado                                        AS "Estado",
    v.metodo_pago                                   AS "Método Pago",

    -- Cliente
    COALESCE(c.nombre || ' ' || c.apellido,
             'Cliente Anónimo')                     AS "Cliente",
    COALESCE(c.tipo_documento || ' ' ||
             c.numero_documento, '-')               AS "Documento",
    COALESCE(c.telefono, '-')                       AS "Teléfono",

    -- Detalle del ítem
    m.nombre                                        AS "Medicamento",
    m.forma_farmaceutica                            AS "Forma",
    m.concentracion                                 AS "Concentración",
    cat.nombre                                      AS "Categoría",
    dv.cantidad                                     AS "Cantidad",
    dv.precio_unitario                              AS "Precio Unitario",
    dv.subtotal                                     AS "Subtotal Ítem",

    -- Total de la venta
    v.total                                         AS "Total Venta",
    v.observaciones                                 AS "Observaciones"

FROM venta v
LEFT JOIN cliente       c   ON v.cliente_id      = c.id
JOIN      detalle_venta dv  ON v.id              = dv.venta_id
JOIN      medicamento   m   ON dv.medicamento_id = m.id
JOIN      categoria     cat ON m.categoria_id    = cat.id

ORDER BY v.fecha_venta DESC, v.id ASC, dv.id ASC;
