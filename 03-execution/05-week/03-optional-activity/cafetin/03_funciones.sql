/*****************************
FUNCTION 1
Total de ventas por cliente
*****************************/
CREATE OR REPLACE FUNCTION fn_total_sales_by_customer(p_customer_id BIGINT)
RETURNS DECIMAL AS $$
DECLARE total_sales DECIMAL;
BEGIN
    SELECT COALESCE(SUM(total_amount),0)
    INTO total_sales
    FROM orders
    WHERE customer_id = p_customer_id;

    RETURN total_sales;
END;
$$ LANGUAGE plpgsql;


/*****************************
FUNCTION 2
Stock actual de un producto
*****************************/
CREATE OR REPLACE FUNCTION fn_product_stock(p_product_id BIGINT)
RETURNS INT AS $$
DECLARE stock INT;
BEGIN
    SELECT stock_quantity
    INTO stock
    FROM product
    WHERE id = p_product_id;

    RETURN stock;
END;
$$ LANGUAGE plpgsql;


/*****************************
FUNCTION 3
Cantidad de pedidos por usuario
*****************************/
CREATE OR REPLACE FUNCTION fn_orders_count_by_user(p_user_id BIGINT)
RETURNS INT AS $$
DECLARE total_orders INT;
BEGIN
    SELECT COUNT(o.id)
    INTO total_orders
    FROM orders o
    JOIN customer c ON o.customer_id = c.id
    JOIN person p ON c.person_id = p.id
    WHERE p.user_id = p_user_id;

    RETURN total_orders;
END;
$$ LANGUAGE plpgsql;