-- ============================================================
--  estadisticas_farmacia.sql
--  Consultas analíticas sobre la operación de la farmacia.
-- ============================================================


-- 1. Medicamentos con stock bajo (por debajo del mínimo)
SELECT
    m.nombre                                        AS "Medicamento",
    m.forma_farmaceutica                            AS "Forma",
    m.concentracion                                 AS "Concentración",
    m.stock                                         AS "Stock Actual",
    m.stock_minimo                                  AS "Stock Mínimo",
    m.stock_minimo - m.stock                        AS "Unidades Faltantes",
    p.nombre                                        AS "Proveedor"
FROM medicamento m
JOIN proveedor p ON m.proveedor_id = p.id
WHERE m.stock <= m.stock_minimo
  AND m.activo = TRUE
ORDER BY "Unidades Faltantes" DESC;


-- 2. Ventas por día con totales (últimos 30 días)
SELECT
    v.fecha_venta::date                             AS "Fecha",
    COUNT(v.id)                                     AS "Nro. Ventas",
    SUM(v.total)                                    AS "Ingresos del Día",
    AVG(v.total)                                    AS "Ticket Promedio",
    MODE() WITHIN GROUP (ORDER BY v.metodo_pago)    AS "Método Más Usado"
FROM venta v
WHERE v.estado = 'Completada'
  AND v.fecha_venta >= NOW() - INTERVAL '30 days'
GROUP BY v.fecha_venta::date
ORDER BY "Fecha" DESC;


-- 3. Top 5 medicamentos más vendidos (por unidades)
SELECT
    m.nombre                                        AS "Medicamento",
    m.forma_farmaceutica                            AS "Forma",
    c.nombre                                        AS "Categoría",
    SUM(dv.cantidad)                                AS "Unidades Vendidas",
    SUM(dv.subtotal)                                AS "Ingresos Totales"
FROM detalle_venta dv
JOIN medicamento m ON dv.medicamento_id = m.id
JOIN categoria   c ON m.categoria_id    = c.id
GROUP BY m.id, m.nombre, m.forma_farmaceutica, c.nombre
ORDER BY "Unidades Vendidas" DESC
LIMIT 5;


-- 4. Ingresos por categoría de medicamento
SELECT
    c.nombre                                        AS "Categoría",
    COUNT(DISTINCT dv.medicamento_id)               AS "Medicamentos Vendidos",
    SUM(dv.cantidad)                                AS "Unidades Totales",
    SUM(dv.subtotal)                                AS "Ingresos Totales",
    ROUND(SUM(dv.subtotal) * 100.0 /
        SUM(SUM(dv.subtotal)) OVER (), 1)           AS "% del Total"
FROM detalle_venta dv
JOIN medicamento m ON dv.medicamento_id = m.id
JOIN categoria   c ON m.categoria_id    = c.id
JOIN venta       v ON dv.venta_id       = v.id
WHERE v.estado = 'Completada'
GROUP BY c.id, c.nombre
ORDER BY "Ingresos Totales" DESC;


-- 5. Medicamentos próximos a vencer (en los próximos 90 días)
SELECT
    m.nombre                                        AS "Medicamento",
    m.concentracion                                 AS "Concentración",
    m.fecha_vencimiento                             AS "Vence el",
    m.fecha_vencimiento - CURRENT_DATE              AS "Días Restantes",
    m.stock                                         AS "Unidades en Stock",
    p.nombre                                        AS "Proveedor"
FROM medicamento m
JOIN proveedor p ON m.proveedor_id = p.id
WHERE m.fecha_vencimiento <= CURRENT_DATE + INTERVAL '90 days'
  AND m.fecha_vencimiento >= CURRENT_DATE
  AND m.activo = TRUE
ORDER BY "Días Restantes" ASC;


-- 6. Clientes con mayor gasto histórico
SELECT
    c.nombre || ' ' || c.apellido                   AS "Cliente",
    c.tipo_documento || ' ' || c.numero_documento   AS "Documento",
    COUNT(v.id)                                     AS "Total Compras",
    SUM(v.total)                                    AS "Gasto Total",
    AVG(v.total)                                    AS "Promedio por Compra",
    MAX(v.fecha_venta)                              AS "Última Compra"
FROM cliente c
JOIN venta v ON c.id = v.cliente_id
WHERE v.estado = 'Completada'
GROUP BY c.id, c.nombre, c.apellido, c.tipo_documento, c.numero_documento
ORDER BY "Gasto Total" DESC
LIMIT 10;
