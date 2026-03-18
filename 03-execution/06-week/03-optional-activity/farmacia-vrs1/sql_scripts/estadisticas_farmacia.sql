-- Medicamentos más vendidos agrupados por categoría
SELECT
    c.nombre AS "Categoría",
    COUNT(dv.medicamento_id) AS "Total Ventas"
FROM categoria c
LEFT JOIN medicamento m ON c.id = m.categoria_id
LEFT JOIN detalle_venta dv ON m.id = dv.medicamento_id
GROUP BY c.nombre;
