/*****************************
VIEW 1
Listado de usuarios con roles
*****************************/
CREATE OR REPLACE VIEW vw_users_roles AS
SELECT 
    u.id AS user_id,
    u.username,
    r.role_name
FROM users u
JOIN user_role ur ON u.id = ur.user_id
JOIN role r ON r.id = ur.role_id;


/*****************************
VIEW 2
Detalle completo de pedidos
*****************************/
CREATE OR REPLACE VIEW vw_orders_detail AS
SELECT
    o.id AS order_id,
    p.first_name,
    p.last_name,
    o.total_amount,
    o.order_status,
    o.created_at
FROM orders o
JOIN customer c ON o.customer_id = c.id
JOIN person p ON c.person_id = p.id;


/*****************************
VIEW 3
Inventario de productos
*****************************/
CREATE OR REPLACE VIEW vw_inventory_products AS
SELECT
    pr.id,
    pr.name AS product_name,
    c.name AS category,
    pr.price,
    pr.stock_quantity
FROM product pr
JOIN category c ON pr.category_id = c.id;