-- ==========================================
-- TRIGGER 1: Actualizar updated_at en product
-- ==========================================
CREATE OR REPLACE FUNCTION trg_fn_product_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_product_updated_at
BEFORE UPDATE ON product
FOR EACH ROW EXECUTE FUNCTION trg_fn_product_updated_at();

-- ==========================================
-- TRIGGER 2: Actualizar updated_at en orders
-- ==========================================
CREATE OR REPLACE FUNCTION trg_fn_orders_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_orders_updated_at
BEFORE UPDATE ON orders
FOR EACH ROW EXECUTE FUNCTION trg_fn_orders_updated_at();

-- ==========================================
-- TRIGGER 3: Actualizar updated_at en invoice
-- ==========================================
CREATE OR REPLACE FUNCTION trg_fn_invoice_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_invoice_updated_at
BEFORE UPDATE ON invoice
FOR EACH ROW EXECUTE FUNCTION trg_fn_invoice_updated_at();

-- ==========================================
-- TRIGGER 4: Actualizar updated_at en users
-- ==========================================
CREATE OR REPLACE FUNCTION trg_fn_users_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION trg_fn_users_updated_at();

-- ==========================================
-- TRIGGER 5: Actualizar updated_at en person
-- ==========================================
CREATE OR REPLACE FUNCTION trg_fn_person_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_person_updated_at
BEFORE UPDATE ON person
FOR EACH ROW EXECUTE FUNCTION trg_fn_person_updated_at();

-- ==========================================
-- TRIGGER 6: Descontar stock al insertar order_item
-- ==========================================
CREATE OR REPLACE FUNCTION trg_fn_stock_on_order_item_insert()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE product
  SET stock = stock - NEW.quantity
  WHERE id = NEW.product_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_stock_on_order_item_insert
AFTER INSERT ON order_item
FOR EACH ROW EXECUTE FUNCTION trg_fn_stock_on_order_item_insert();

-- ==========================================
-- TRIGGER 7: Restaurar stock al eliminar order_item
-- ==========================================
CREATE OR REPLACE FUNCTION trg_fn_stock_on_order_item_delete()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE product
  SET stock = stock + OLD.quantity
  WHERE id = OLD.product_id;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_stock_on_order_item_delete
AFTER DELETE ON order_item
FOR EACH ROW EXECUTE FUNCTION trg_fn_stock_on_order_item_delete();

-- ==========================================
-- TRIGGER 8: Aplicar movimiento de inventario al stock
-- ==========================================
CREATE OR REPLACE FUNCTION trg_fn_apply_inventory_movement()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.movement_type = 'ENTRADA' THEN
    UPDATE product SET stock = stock + NEW.quantity WHERE id = NEW.product_id;
  ELSIF NEW.movement_type = 'SALIDA' THEN
    UPDATE product SET stock = stock - NEW.quantity WHERE id = NEW.product_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_apply_inventory_movement
AFTER INSERT ON inventory_movement
FOR EACH ROW EXECUTE FUNCTION trg_fn_apply_inventory_movement();

-- ==========================================
-- TRIGGER 9: Validar stock suficiente antes de SALIDA
-- ==========================================
CREATE OR REPLACE FUNCTION trg_fn_validate_stock_salida()
RETURNS TRIGGER AS $$
DECLARE v_stock INT;
BEGIN
  IF NEW.movement_type = 'SALIDA' THEN
    SELECT stock INTO v_stock FROM product WHERE id = NEW.product_id;
    IF v_stock < NEW.quantity THEN
      RAISE EXCEPTION 'Stock insuficiente. Disponible: %, solicitado: %', v_stock, NEW.quantity;
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_stock_salida
BEFORE INSERT ON inventory_movement
FOR EACH ROW EXECUTE FUNCTION trg_fn_validate_stock_salida();

-- ==========================================
-- TRIGGER 10: Recalcular total de orden al insertar order_item
-- ==========================================
CREATE OR REPLACE FUNCTION trg_fn_recalc_order_total()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE orders
  SET total_amount = (
    SELECT COALESCE(SUM(quantity * unit_price), 0)
    FROM order_item WHERE order_id = NEW.order_id AND deleted_at IS NULL
  )
  WHERE id = NEW.order_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_recalc_order_total
AFTER INSERT OR UPDATE ON order_item
FOR EACH ROW EXECUTE FUNCTION trg_fn_recalc_order_total();

-- ==========================================
-- TRIGGER 11: Sincronizar total de invoice con su orden
-- ==========================================
CREATE OR REPLACE FUNCTION trg_fn_sync_invoice_total()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE invoice
  SET total = NEW.total_amount, updated_at = NOW()
  WHERE order_id = NEW.id AND deleted_at IS NULL;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_sync_invoice_total
AFTER UPDATE OF total_amount ON orders
FOR EACH ROW EXECUTE FUNCTION trg_fn_sync_invoice_total();

-- ==========================================
-- TRIGGER 12: Validar email único en person antes de INSERT/UPDATE
-- ==========================================
CREATE OR REPLACE FUNCTION trg_fn_validate_person_email()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM person
    WHERE email = NEW.email AND id <> NEW.id AND deleted_at IS NULL
  ) THEN
    RAISE EXCEPTION 'El email % ya está registrado.', NEW.email;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_person_email
BEFORE INSERT OR UPDATE ON person
FOR EACH ROW EXECUTE FUNCTION trg_fn_validate_person_email();

-- ==========================================
-- TRIGGER 13: Impedir eliminar usuario con órdenes activas
-- ==========================================
CREATE OR REPLACE FUNCTION trg_fn_prevent_user_delete()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM orders WHERE created_by = OLD.id AND deleted_at IS NULL
  ) THEN
    RAISE EXCEPTION 'No se puede eliminar el usuario %. Tiene órdenes activas.', OLD.username;
  END IF;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_user_delete
BEFORE DELETE ON users
FOR EACH ROW EXECUTE FUNCTION trg_fn_prevent_user_delete();

-- ==========================================
-- TRIGGER 14: Registrar updated_at en payment
-- ==========================================
CREATE OR REPLACE FUNCTION trg_fn_payment_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_payment_updated_at
BEFORE UPDATE ON payment
FOR EACH ROW EXECUTE FUNCTION trg_fn_payment_updated_at();

-- ==========================================
-- TRIGGER 15: Validar que amount_paid no supere el total de la factura
-- ==========================================
CREATE OR REPLACE FUNCTION trg_fn_validate_payment_amount()
RETURNS TRIGGER AS $$
DECLARE v_total DECIMAL; v_paid DECIMAL;
BEGIN
  SELECT total INTO v_total FROM invoice WHERE id = NEW.invoice_id;
  SELECT COALESCE(SUM(amount_paid), 0) INTO v_paid
  FROM payment WHERE invoice_id = NEW.invoice_id AND deleted_at IS NULL;
  IF (v_paid + NEW.amount_paid) > v_total THEN
    RAISE EXCEPTION 'El pago supera el total de la factura. Total: %, Ya pagado: %, Nuevo pago: %',
      v_total, v_paid, NEW.amount_paid;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_payment_amount
BEFORE INSERT ON payment
FOR EACH ROW EXECUTE FUNCTION trg_fn_validate_payment_amount();