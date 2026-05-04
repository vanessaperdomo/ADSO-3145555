-- ==========================================
-- SP 1: Crear persona
-- ==========================================
CREATE OR REPLACE PROCEDURE sp_create_person(
  p_first_name VARCHAR, p_last_name VARCHAR, p_document VARCHAR,
  p_email VARCHAR, p_phone VARCHAR, p_type_doc_id UUID, p_status_id UUID
)
LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO person(first_name, last_name, document_number, email, phone, type_document_id, status_id)
  VALUES (p_first_name, p_last_name, p_document, p_email, p_phone, p_type_doc_id, p_status_id);
END;
$$;

-- ==========================================
-- SP 2: Actualizar persona
-- ==========================================
CREATE OR REPLACE PROCEDURE sp_update_person(
  p_id UUID, p_first_name VARCHAR, p_last_name VARCHAR,
  p_email VARCHAR, p_phone VARCHAR, p_user_id UUID
)
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE person
  SET first_name = p_first_name, last_name = p_last_name,
      email = p_email, phone = p_phone,
      updated_at = NOW(), updated_by = p_user_id
  WHERE id = p_id AND deleted_at IS NULL;
END;
$$;

-- ==========================================
-- SP 3: Soft delete persona
-- ==========================================
CREATE OR REPLACE PROCEDURE sp_delete_person(
  p_id UUID, p_user_id UUID
)
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE person
  SET deleted_at = NOW(), deleted_by = p_user_id
  WHERE id = p_id AND deleted_at IS NULL;
END;
$$;

-- ==========================================
-- SP 4: Crear usuario
-- ==========================================
CREATE OR REPLACE PROCEDURE sp_create_user(
  p_username VARCHAR, p_password VARCHAR,
  p_person_id UUID, p_status_id UUID
)
LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO users(username, password, person_id, status_id)
  VALUES (p_username, p_password, p_person_id, p_status_id);
END;
$$;

-- ==========================================
-- SP 5: Asignar rol a usuario
-- ==========================================
CREATE OR REPLACE PROCEDURE sp_assign_role(
  p_user_id UUID, p_role_id UUID, p_created_by UUID
)
LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO user_role(user_id, role_id, created_by)
  VALUES (p_user_id, p_role_id, p_created_by)
  ON CONFLICT (user_id, role_id) DO NOTHING;
END;
$$;

-- ==========================================
-- SP 6: Crear producto
-- ==========================================
CREATE OR REPLACE PROCEDURE sp_create_product(
  p_name VARCHAR, p_description TEXT, p_price DECIMAL,
  p_stock INT, p_category_id UUID, p_supplier_id UUID, p_user_id UUID
)
LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO product(name, description, price, stock, category_id, supplier_id, created_by)
  VALUES (p_name, p_description, p_price, p_stock, p_category_id, p_supplier_id, p_user_id);
END;
$$;

-- ==========================================
-- SP 7: Actualizar precio y stock de producto
-- ==========================================
CREATE OR REPLACE PROCEDURE sp_update_product(
  p_id UUID, p_price DECIMAL, p_stock INT, p_user_id UUID
)
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE product
  SET price = p_price, stock = p_stock,
      updated_at = NOW(), updated_by = p_user_id
  WHERE id = p_id AND deleted_at IS NULL;
END;
$$;

-- ==========================================
-- SP 8: Crear cliente
-- ==========================================
CREATE OR REPLACE PROCEDURE sp_create_customer(
  p_person_id UUID, p_customer_type_id UUID,
  p_status_id UUID, p_user_id UUID
)
LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO customer(person_id, customer_type_id, status_id, created_by)
  VALUES (p_person_id, p_customer_type_id, p_status_id, p_user_id);
END;
$$;

-- ==========================================
-- SP 9: Crear orden con un ítem
-- ==========================================
CREATE OR REPLACE PROCEDURE sp_create_order(
  p_customer_id UUID, p_status_id UUID, p_product_id UUID,
  p_quantity INT, p_unit_price DECIMAL, p_user_id UUID
)
LANGUAGE plpgsql AS $$
DECLARE v_order_id UUID;
BEGIN
  INSERT INTO orders(total_amount, order_status_id, customer_id, created_by)
  VALUES (p_quantity * p_unit_price, p_status_id, p_customer_id, p_user_id)
  RETURNING id INTO v_order_id;

  INSERT INTO order_item(order_id, product_id, quantity, unit_price, created_by)
  VALUES (v_order_id, p_product_id, p_quantity, p_unit_price, p_user_id);
END;
$$;

-- ==========================================
-- SP 10: Agregar ítem a orden existente
-- ==========================================
CREATE OR REPLACE PROCEDURE sp_add_order_item(
  p_order_id UUID, p_product_id UUID,
  p_quantity INT, p_unit_price DECIMAL, p_user_id UUID
)
LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO order_item(order_id, product_id, quantity, unit_price, created_by)
  VALUES (p_order_id, p_product_id, p_quantity, p_unit_price, p_user_id);
END;
$$;

-- ==========================================
-- SP 11: Cambiar estado de una orden
-- ==========================================
CREATE OR REPLACE PROCEDURE sp_update_order_status(
  p_order_id UUID, p_status_id UUID, p_user_id UUID
)
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE orders
  SET order_status_id = p_status_id,
      updated_at = NOW(), updated_by = p_user_id
  WHERE id = p_order_id AND deleted_at IS NULL;
END;
$$;

-- ==========================================
-- SP 12: Crear factura desde orden
-- ==========================================
CREATE OR REPLACE PROCEDURE sp_create_invoice(
  p_order_id UUID, p_invoice_number VARCHAR, p_user_id UUID
)
LANGUAGE plpgsql AS $$
DECLARE v_total DECIMAL;
BEGIN
  SELECT total_amount INTO v_total FROM orders WHERE id = p_order_id;
  INSERT INTO invoice(invoice_number, total, order_id, created_by)
  VALUES (p_invoice_number, v_total, p_order_id, p_user_id);
END;
$$;

-- ==========================================
-- SP 13: Registrar pago de factura
-- ==========================================
CREATE OR REPLACE PROCEDURE sp_register_payment(
  p_invoice_id UUID, p_amount DECIMAL,
  p_method_id UUID, p_user_id UUID
)
LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO payment(amount_paid, invoice_id, method_payment_id, created_by)
  VALUES (p_amount, p_invoice_id, p_method_id, p_user_id);
END;
$$;

-- ==========================================
-- SP 14: Soft delete genérico en product
-- ==========================================
CREATE OR REPLACE PROCEDURE sp_delete_product(
  p_id UUID, p_user_id UUID
)
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE product
  SET deleted_at = NOW(), deleted_by = p_user_id
  WHERE id = p_id AND deleted_at IS NULL;
END;
$$;

-- ==========================================
-- SP 15: Desactivar usuario
-- ==========================================
CREATE OR REPLACE PROCEDURE sp_deactivate_user(
  p_user_id UUID, p_admin_id UUID
)
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE users
  SET active = FALSE, updated_at = NOW(), updated_by = p_admin_id
  WHERE id = p_user_id AND deleted_at IS NULL;
END;
$$;