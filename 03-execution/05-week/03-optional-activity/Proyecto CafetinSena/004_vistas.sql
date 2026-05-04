-- ==========================================
-- VISTA 1: Productos activos con categoría y proveedor
-- ==========================================
CREATE OR REPLACE VIEW vw_products_full AS
SELECT
    p.id, p.name, p.description, p.price, p.stock, p.image_url,
    c.name        AS category_name,
    s.name        AS supplier_name,
    st.name       AS status_name,
    p.created_at
FROM product p
JOIN category c  ON c.id = p.category_id
JOIN supplier s  ON s.id = p.supplier_id
LEFT JOIN status st ON st.id = p.status_id
WHERE p.deleted_at IS NULL;

-- ==========================================
-- VISTA 2: Stock bajo (menos de 10 unidades)
-- ==========================================
CREATE OR REPLACE VIEW vw_low_stock AS
SELECT
    p.id, p.name, p.stock,
    c.name  AS category_name,
    s.name  AS supplier_name,
    s.phone AS supplier_phone,
    s.email AS supplier_email
FROM product p
JOIN category c ON c.id = p.category_id
JOIN supplier s ON s.id = p.supplier_id
WHERE p.stock < 10 AND p.deleted_at IS NULL
ORDER BY p.stock ASC;

-- ==========================================
-- VISTA 3: Movimientos de inventario detallados
-- ==========================================
CREATE OR REPLACE VIEW vw_inventory_movements AS
SELECT
    im.id, im.movement_type, im.quantity,
    p.name        AS product_name,
    p.stock       AS current_stock,
    u.username    AS created_by_user,
    im.created_at
FROM inventory_movement im
JOIN product p ON p.id = im.product_id
JOIN users   u ON u.id = im.created_by
WHERE im.deleted_at IS NULL
ORDER BY im.created_at DESC;

-- ==========================================
-- VISTA 4: Clientes con datos personales
-- ==========================================
CREATE OR REPLACE VIEW vw_customers_full AS
SELECT
    cu.id        AS customer_id,
    pe.first_name, pe.last_name,
    pe.email, pe.phone, pe.document_number,
    td.name      AS document_type,
    ct.name      AS customer_type,
    st.name      AS status_name,
    cu.created_at
FROM customer cu
JOIN person        pe ON pe.id = cu.person_id
JOIN type_document td ON td.id = pe.type_document_id
JOIN customer_type ct ON ct.id = cu.customer_type_id
LEFT JOIN status   st ON st.id = cu.status_id
WHERE cu.deleted_at IS NULL;

-- ==========================================
-- VISTA 5: Órdenes con estado y cliente
-- ==========================================
CREATE OR REPLACE VIEW vw_orders_full AS
SELECT
    o.id          AS order_id,
    o.total_amount,
    os.name       AS order_status,
    pe.first_name || ' ' || pe.last_name AS customer_name,
    pe.email      AS customer_email,
    ct.name       AS customer_type,
    u.username    AS created_by_user,
    o.created_at
FROM orders o
JOIN order_status  os ON os.id = o.order_status_id
JOIN customer      cu ON cu.id = o.customer_id
JOIN person        pe ON pe.id = cu.person_id
JOIN customer_type ct ON ct.id = cu.customer_type_id
LEFT JOIN users     u ON u.id  = o.created_by
WHERE o.deleted_at IS NULL
ORDER BY o.created_at DESC;

-- ==========================================
-- VISTA 6: Detalle de ítems por orden
-- ==========================================
CREATE OR REPLACE VIEW vw_order_items_detail AS
SELECT
    oi.order_id,
    o.total_amount,
    p.name        AS product_name,
    c.name        AS category_name,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS subtotal,
    oi.created_at
FROM order_item oi
JOIN orders  o ON o.id  = oi.order_id
JOIN product p ON p.id  = oi.product_id
JOIN category c ON c.id = p.category_id
WHERE oi.deleted_at IS NULL;

-- ==========================================
-- VISTA 7: Facturas con datos de orden y cliente
-- ==========================================
CREATE OR REPLACE VIEW vw_invoices_full AS
SELECT
    i.id            AS invoice_id,
    i.invoice_number,
    i.total,
    os.name         AS order_status,
    pe.first_name || ' ' || pe.last_name AS customer_name,
    pe.email        AS customer_email,
    u.username      AS created_by_user,
    i.created_at
FROM invoice i
JOIN orders       o  ON o.id  = i.order_id
JOIN order_status os ON os.id = o.order_status_id
JOIN customer     cu ON cu.id = o.customer_id
JOIN person       pe ON pe.id = cu.person_id
LEFT JOIN users    u ON u.id  = i.created_by
WHERE i.deleted_at IS NULL
ORDER BY i.created_at DESC;

-- ==========================================
-- VISTA 8: Pagos con método y factura
-- ==========================================
CREATE OR REPLACE VIEW vw_payments_full AS
SELECT
    pa.id           AS payment_id,
    pa.amount_paid,
    mp.name         AS payment_method,
    i.invoice_number,
    i.total         AS invoice_total,
    pe.first_name || ' ' || pe.last_name AS customer_name,
    pa.paid_at,
    u.username      AS created_by_user
FROM payment pa
JOIN method_payment mp ON mp.id = pa.method_payment_id
JOIN invoice         i ON i.id  = pa.invoice_id
JOIN orders          o ON o.id  = i.order_id
JOIN customer       cu ON cu.id = o.customer_id
JOIN person         pe ON pe.id = cu.person_id
LEFT JOIN users      u ON u.id  = pa.created_by
WHERE pa.deleted_at IS NULL
ORDER BY pa.paid_at DESC;

-- ==========================================
-- VISTA 9: Resumen de ventas por cliente
-- ==========================================
CREATE OR REPLACE VIEW vw_sales_summary_by_customer AS
SELECT
    pe.first_name || ' ' || pe.last_name AS customer_name,
    pe.email,
    ct.name          AS customer_type,
    COUNT(o.id)      AS total_orders,
    SUM(o.total_amount) AS total_spent
FROM orders o
JOIN customer      cu ON cu.id = o.customer_id
JOIN person        pe ON pe.id = cu.person_id
JOIN customer_type ct ON ct.id = cu.customer_type_id
WHERE o.deleted_at IS NULL
GROUP BY pe.first_name, pe.last_name, pe.email, ct.name
ORDER BY total_spent DESC;

-- ==========================================
-- VISTA 10: Resumen de ventas por producto
-- ==========================================
CREATE OR REPLACE VIEW vw_sales_summary_by_product AS
SELECT
    p.name          AS product_name,
    c.name          AS category_name,
    SUM(oi.quantity)                    AS total_sold,
    SUM(oi.quantity * oi.unit_price)    AS total_revenue,
    AVG(oi.unit_price)                  AS avg_price
FROM order_item oi
JOIN product  p ON p.id = oi.product_id
JOIN category c ON c.id = p.category_id
WHERE oi.deleted_at IS NULL
GROUP BY p.name, c.name
ORDER BY total_revenue DESC;

-- ==========================================
-- VISTA 11: Usuarios con persona y roles
-- ==========================================
CREATE OR REPLACE VIEW vw_users_full AS
SELECT
    u.id          AS user_id,
    u.username,
    u.active,
    pe.first_name, pe.last_name, pe.email, pe.phone,
    td.name       AS document_type,
    pe.document_number,
    st.name       AS status_name,
    u.created_at
FROM users u
JOIN person        pe ON pe.id = u.person_id
JOIN type_document td ON td.id = pe.type_document_id
LEFT JOIN status   st ON st.id = u.status_id
WHERE u.deleted_at IS NULL;

-- ==========================================
-- VISTA 12: Roles con módulos asignados
-- ==========================================
CREATE OR REPLACE VIEW vw_roles_with_modules AS
SELECT
    r.id          AS role_id,
    r.role_name,
    r.description AS role_description,
    m.id          AS module_id,
    m.name        AS module_name,
    m.description AS module_description
FROM role r
JOIN role_module rm ON rm.role_id   = r.id
JOIN module      m  ON m.id         = rm.module_id
WHERE r.deleted_at IS NULL AND rm.deleted_at IS NULL
ORDER BY r.role_name, m.name;

-- ==========================================
-- VISTA 13: Personas con grupo académico y programa
-- ==========================================
CREATE OR REPLACE VIEW vw_persons_full AS
SELECT
    pe.id, pe.first_name, pe.last_name,
    pe.email, pe.phone, pe.document_number,
    td.name   AS document_type,
    sg.group_code,
    ap.program_name,
    st.name   AS status_name,
    pe.created_at
FROM person pe
JOIN type_document  td ON td.id = pe.type_document_id
LEFT JOIN study_group    sg ON sg.id = pe.study_group_id
LEFT JOIN academic_program ap ON ap.id = sg.academic_program_id
LEFT JOIN status     st ON st.id = pe.status_id
WHERE pe.deleted_at IS NULL;

-- ==========================================
-- VISTA 14: Ítems del juego de memoria con producto
-- ==========================================
CREATE OR REPLACE VIEW vw_memory_game_items AS
SELECT
    mg.id,
    mg.english_name,
    mg.image_url    AS game_image,
    p.name          AS product_name,
    p.price,
    p.stock,
    c.name          AS category_name,
    st.name         AS status_name
FROM memory_game_item mg
JOIN product  p  ON p.id  = mg.product_id
JOIN category c  ON c.id  = p.category_id
LEFT JOIN status st ON st.id = mg.status_id
WHERE mg.deleted_at IS NULL
ORDER BY mg.english_name;

-- ==========================================
-- VISTA 15: Reporte general de facturación
-- ==========================================
CREATE OR REPLACE VIEW vw_billing_report AS
SELECT
    i.invoice_number,
    i.total         AS invoice_total,
    pa.amount_paid,
    mp.name         AS payment_method,
    (i.total - COALESCE(pa.amount_paid, 0)) AS pending_balance,
    pe.first_name || ' ' || pe.last_name    AS customer_name,
    pe.email,
    os.name         AS order_status,
    i.created_at    AS invoice_date,
    pa.paid_at
FROM invoice i
JOIN orders        o  ON o.id  = i.order_id
JOIN order_status  os ON os.id = o.order_status_id
JOIN customer      cu ON cu.id = o.customer_id
JOIN person        pe ON pe.id = cu.person_id
LEFT JOIN payment      pa ON pa.invoice_id        = i.id AND pa.deleted_at IS NULL
LEFT JOIN method_payment mp ON mp.id = pa.method_payment_id
WHERE i.deleted_at IS NULL
ORDER BY i.created_at DESC;