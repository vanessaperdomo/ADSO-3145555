-- ==========================================
-- FUNCIÓN 1: Obtener productos activos
-- ==========================================
CREATE OR REPLACE FUNCTION fn_get_active_products()
RETURNS TABLE(id UUID, name VARCHAR, price DECIMAL, stock INT) AS $$
BEGIN
  RETURN QUERY
    SELECT p.id, p.name, p.price, p.stock
    FROM product p
    WHERE p.deleted_at IS NULL
    ORDER BY p.name;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- FUNCIÓN 2: Productos con stock bajo
-- ==========================================
CREATE OR REPLACE FUNCTION fn_get_low_stock(p_min INT)
RETURNS TABLE(id UUID, name VARCHAR, stock INT, supplier VARCHAR) AS $$
BEGIN
  RETURN QUERY
    SELECT p.id, p.name, p.stock, s.name
    FROM product p
    JOIN supplier s ON s.id = p.supplier_id
    WHERE p.stock <= p_min AND p.deleted_at IS NULL
    ORDER BY p.stock ASC;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- FUNCIÓN 3: Actualizar stock (ENTRADA/SALIDA)
-- ==========================================
CREATE OR REPLACE FUNCTION fn_update_stock(
  p_product_id UUID, p_qty INT, p_type VARCHAR, p_user_id UUID
) RETURNS VOID AS $$
BEGIN
  IF p_type = 'ENTRADA' THEN
    UPDATE product SET stock = stock + p_qty, updated_at = NOW(), updated_by = p_user_id
    WHERE id = p_product_id;
  ELSIF p_type = 'SALIDA' THEN
    UPDATE product SET stock = stock - p_qty, updated_at = NOW(), updated_by = p_user_id
    WHERE id = p_product_id;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- FUNCIÓN 4: Registrar movimiento de inventario
-- ==========================================
CREATE OR REPLACE FUNCTION fn_register_movement(
  p_product_id UUID, p_qty INT, p_type VARCHAR, p_user_id UUID
) RETURNS UUID AS $$
DECLARE v_id UUID;
BEGIN
  INSERT INTO inventory_movement(movement_type, quantity, product_id, created_by)
  VALUES (p_type, p_qty, p_product_id, p_user_id)
  RETURNING id INTO v_id;
  PERFORM fn_update_stock(p_product_id, p_qty, p_type, p_user_id);
  RETURN v_id;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- FUNCIÓN 5: Productos por categoría
-- ==========================================
CREATE OR REPLACE FUNCTION fn_get_products_by_category(p_category_id UUID)
RETURNS TABLE(id UUID, name VARCHAR, price DECIMAL, stock INT) AS $$
BEGIN
  RETURN QUERY
    SELECT p.id, p.name, p.price, p.stock
    FROM product p
    WHERE p.category_id = p_category_id AND p.deleted_at IS NULL
    ORDER BY p.name;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- FUNCIÓN 6: Crear orden
-- ==========================================
CREATE OR REPLACE FUNCTION fn_create_order(
  p_customer_id UUID, p_status_id UUID, p_total DECIMAL, p_user_id UUID
) RETURNS UUID AS $$
DECLARE v_id UUID;
BEGIN
  INSERT INTO orders(total_amount, order_status_id, customer_id, created_by)
  VALUES (p_total, p_status_id, p_customer_id, p_user_id)
  RETURNING id INTO v_id;
  RETURN v_id;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- FUNCIÓN 7: Detalle de una orden
-- ==========================================
CREATE OR REPLACE FUNCTION fn_get_order_detail(p_order_id UUID)
RETURNS TABLE(product_name VARCHAR, quantity INT, unit_price DECIMAL, subtotal DECIMAL) AS $$
BEGIN
  RETURN QUERY
    SELECT p.name, oi.quantity, oi.unit_price,
           (oi.quantity * oi.unit_price)
    FROM order_item oi
    JOIN product p ON p.id = oi.product_id
    WHERE oi.order_id = p_order_id AND oi.deleted_at IS NULL;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- FUNCIÓN 8: Órdenes por cliente
-- ==========================================
CREATE OR REPLACE FUNCTION fn_get_orders_by_customer(p_customer_id UUID)
RETURNS TABLE(order_id UUID, total DECIMAL, status VARCHAR, created_at TIMESTAMPTZ) AS $$
BEGIN
  RETURN QUERY
    SELECT o.id, o.total_amount, os.name, o.created_at
    FROM orders o
    JOIN order_status os ON os.id = o.order_status_id
    WHERE o.customer_id = p_customer_id AND o.deleted_at IS NULL
    ORDER BY o.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- FUNCIÓN 9: Top productos más vendidos
-- ==========================================
CREATE OR REPLACE FUNCTION fn_top_selling_products(p_limit INT)
RETURNS TABLE(product_name VARCHAR, total_qty BIGINT, total_revenue DECIMAL) AS $$
BEGIN
  RETURN QUERY
    SELECT p.name, SUM(oi.quantity), SUM(oi.quantity * oi.unit_price)
    FROM order_item oi
    JOIN product p ON p.id = oi.product_id
    WHERE oi.deleted_at IS NULL
    GROUP BY p.name ORDER BY 2 DESC LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- FUNCIÓN 10: Ventas por período
-- ==========================================
CREATE OR REPLACE FUNCTION fn_get_sales_by_period(p_start DATE, p_end DATE)
RETURNS TABLE(order_id UUID, customer TEXT, total DECIMAL, created_at TIMESTAMPTZ) AS $$
BEGIN
  RETURN QUERY
    SELECT o.id, (pe.first_name || ' ' || pe.last_name),
           o.total_amount, o.created_at
    FROM orders o
    JOIN customer c ON c.id = o.customer_id
    JOIN person pe ON pe.id = c.person_id
    WHERE o.created_at::DATE BETWEEN p_start AND p_end AND o.deleted_at IS NULL;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- FUNCIÓN 11: Crear factura desde orden
-- ==========================================
CREATE OR REPLACE FUNCTION fn_create_invoice(
  p_order_id UUID, p_number VARCHAR, p_user_id UUID
) RETURNS UUID AS $$
DECLARE v_total DECIMAL; v_id UUID;
BEGIN
  SELECT total_amount INTO v_total FROM orders WHERE id = p_order_id;
  INSERT INTO invoice(invoice_number, total, order_id, created_by)
  VALUES (p_number, v_total, p_order_id, p_user_id)
  RETURNING id INTO v_id;
  RETURN v_id;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- FUNCIÓN 12: Registrar pago
-- ==========================================
CREATE OR REPLACE FUNCTION fn_register_payment(
  p_invoice_id UUID, p_amount DECIMAL, p_method_id UUID, p_user_id UUID
) RETURNS UUID AS $$
DECLARE v_id UUID;
BEGIN
  INSERT INTO payment(amount_paid, invoice_id, method_payment_id, created_by)
  VALUES (p_amount, p_invoice_id, p_method_id, p_user_id)
  RETURNING id INTO v_id;
  RETURN v_id;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- FUNCIÓN 13: Pagos de una factura
-- ==========================================
CREATE OR REPLACE FUNCTION fn_get_invoice_payments(p_invoice_id UUID)
RETURNS TABLE(payment_id UUID, amount DECIMAL, method VARCHAR, paid_at TIMESTAMPTZ) AS $$
BEGIN
  RETURN QUERY
    SELECT p.id, p.amount_paid, mp.name, p.paid_at
    FROM payment p
    JOIN method_payment mp ON mp.id = p.method_payment_id
    WHERE p.invoice_id = p_invoice_id AND p.deleted_at IS NULL
    ORDER BY p.paid_at;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- FUNCIÓN 14: Roles de un usuario
-- ==========================================
CREATE OR REPLACE FUNCTION fn_get_user_roles(p_user_id UUID)
RETURNS TABLE(role_id UUID, role_name VARCHAR) AS $$
BEGIN
  RETURN QUERY
    SELECT r.id, r.role_name
    FROM user_role ur
    JOIN role r ON r.id = ur.role_id
    WHERE ur.user_id = p_user_id AND ur.deleted_at IS NULL;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- FUNCIÓN 15: Soft delete genérico para person
-- ==========================================
CREATE OR REPLACE FUNCTION fn_soft_delete_person(
  p_person_id UUID, p_user_id UUID
) RETURNS VOID AS $$
BEGIN
  UPDATE person
  SET deleted_at = NOW(), deleted_by = p_user_id, updated_at = NOW()
  WHERE id = p_person_id AND deleted_at IS NULL;
END;
$$ LANGUAGE plpgsql;