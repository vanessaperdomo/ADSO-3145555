-- Ficha técnica completa de cada venta
-- Incluye Cliente, Medicamento, Categoría y Proveedor
SELECT
    v.id AS "ID Venta",
    c.nombre || ' ' || c.apellido AS "Cliente",
    m.nombre AS "Medicamento",
    cat.nombre AS "Categoría",
    dv.cantidad AS "Cantidad",
    dv.precio_unitario AS "Precio Unitario",
    dv.subtotal AS "Subtotal",
    v.metodo_pago AS "Método de Pago",
    v.fecha_venta AS "Fecha"
FROM venta v
LEFT JOIN cliente c ON v.cliente_id = c.id
JOIN detalle_venta dv ON v.id = dv.venta_id
JOIN medicamento m ON dv.medicamento_id = m.id
JOIN categoria cat ON m.categoria_id = cat.id
ORDER BY v.fecha_venta DESC;
