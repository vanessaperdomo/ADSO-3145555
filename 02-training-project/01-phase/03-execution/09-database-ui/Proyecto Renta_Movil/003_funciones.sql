-- ==========================================
-- FUNCIÓN 1: Obtener vehículos disponibles por ciudad
-- ==========================================
CREATE OR REPLACE FUNCTION fn_get_available_vehicles(p_city_id UUID)
RETURNS TABLE(id UUID, brand VARCHAR, model VARCHAR, plate VARCHAR, daily_rate DECIMAL) AS $$
BEGIN
  RETURN QUERY
    SELECT v.id, v.brand, v.model, v.plate, v.daily_rate
    FROM vehicle v
    JOIN branch b ON b.id = v.branch_id
    WHERE v.vehicle_state = 'AVAILABLE'
      AND b.city_id = p_city_id
      AND v.deleted_at IS NULL
    ORDER BY v.daily_rate ASC;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- FUNCIÓN 2: Obtener vehículos por categoría
-- ==========================================
CREATE OR REPLACE FUNCTION fn_get_vehicles_by_category(p_category_id UUID)
RETURNS TABLE(id UUID, brand VARCHAR, model VARCHAR, plate VARCHAR, daily_rate DECIMAL, vehicle_state VARCHAR) AS $$
BEGIN
  RETURN QUERY
    SELECT v.id, v.brand, v.model, v.plate, v.daily_rate, v.vehicle_state
    FROM vehicle v
    WHERE v.vehicle_category_id = p_category_id
      AND v.deleted_at IS NULL
    ORDER BY v.brand, v.model;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- FUNCIÓN 3: Crear reserva
-- ==========================================
CREATE OR REPLACE FUNCTION fn_create_reservation(
  p_code VARCHAR, p_start DATE, p_end DATE,
  p_vehicle_id UUID, p_customer_id UUID,
  p_pickup_id UUID, p_return_id UUID, p_user_id UUID
) RETURNS UUID AS $$
DECLARE
  v_id UUID; v_days INT; v_rate DECIMAL;
BEGIN
  SELECT daily_rate INTO v_rate FROM vehicle WHERE id = p_vehicle_id;
  v_days := (p_end - p_start);
  INSERT INTO reservation(reservation_code, start_date, end_date, pickup_branch_id,
    return_branch_id, total_days, daily_rate, total_amount, vehicle_id, customer_id, created_by)
  VALUES (p_code, p_start, p_end, p_pickup_id, p_return_id,
    v_days, v_rate, v_days * v_rate, p_vehicle_id, p_customer_id, p_user_id)
  RETURNING id INTO v_id;
  RETURN v_id;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- FUNCIÓN 4: Cambiar estado de vehículo
-- ==========================================
CREATE OR REPLACE FUNCTION fn_update_vehicle_state(
  p_vehicle_id UUID, p_state VARCHAR, p_user_id UUID
) RETURNS VOID AS $$
BEGIN
  UPDATE vehicle
  SET vehicle_state = p_state,
      updated_at    = NOW(),
      updated_by    = p_user_id
  WHERE id = p_vehicle_id AND deleted_at IS NULL;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- FUNCIÓN 5: Obtener reservas activas de un cliente
-- ==========================================
CREATE OR REPLACE FUNCTION fn_get_customer_reservations(p_customer_id UUID)
RETURNS TABLE(reservation_id UUID, code VARCHAR, start_date DATE, end_date DATE,
              vehicle VARCHAR, total DECIMAL, state VARCHAR) AS $$
BEGIN
  RETURN QUERY
    SELECT r.id, r.reservation_code, r.start_date, r.end_date,
           (v.brand || ' ' || v.model), r.total_amount, r.reservation_state
    FROM reservation r
    JOIN vehicle v ON v.id = r.vehicle_id
    WHERE r.customer_id = p_customer_id AND r.deleted_at IS NULL
    ORDER BY r.start_date DESC;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- FUNCIÓN 6: Registrar pago de reserva
-- ==========================================
CREATE OR REPLACE FUNCTION fn_register_payment(
  p_reservation_id UUID, p_amount DECIMAL,
  p_method_id UUID, p_reference VARCHAR, p_user_id UUID
) RETURNS UUID AS $$
DECLARE v_id UUID;
BEGIN
  INSERT INTO payment(amount_paid, reference, reservation_id, payment_method_id,
                      payment_state, paid_at, created_by)
  VALUES (p_amount, p_reference, p_reservation_id, p_method_id,
          'APPROVED', NOW(), p_user_id)
  RETURNING id INTO v_id;
  RETURN v_id;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- FUNCIÓN 7: Registrar mantenimiento de vehículo
-- ==========================================
CREATE OR REPLACE FUNCTION fn_register_maintenance(
  p_vehicle_id UUID, p_type VARCHAR, p_description TEXT,
  p_cost DECIMAL, p_scheduled DATE, p_user_id UUID
) RETURNS UUID AS $$
DECLARE v_id UUID;
BEGIN
  INSERT INTO maintenance(vehicle_id, maintenance_type, description,
    cost, scheduled_date, maintenance_state, created_by)
  VALUES (p_vehicle_id, p_type, p_description, p_cost, p_scheduled, 'PENDING', p_user_id)
  RETURNING id INTO v_id;
  PERFORM fn_update_vehicle_state(p_vehicle_id, 'MAINTENANCE', p_user_id);
  RETURN v_id;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- FUNCIÓN 8: Aprobar licencia de conducir
-- ==========================================
CREATE OR REPLACE FUNCTION fn_approve_driver_license(
  p_license_id UUID, p_reviewer_id UUID, p_notes TEXT
) RETURNS VOID AS $$
BEGIN
  UPDATE driver_license
  SET license_state = 'APPROVED',
      reviewed_by   = p_reviewer_id,
      reviewed_at   = NOW(),
      review_notes  = p_notes,
      updated_at    = NOW(),
      updated_by    = p_reviewer_id
  WHERE id = p_license_id AND deleted_at IS NULL;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- FUNCIÓN 9: Registrar calificación de reserva
-- ==========================================
CREATE OR REPLACE FUNCTION fn_create_rating(
  p_reservation_id UUID, p_customer_id UUID,
  p_vehicle_score INT, p_service_score INT,
  p_comment TEXT, p_user_id UUID
) RETURNS UUID AS $$
DECLARE v_id UUID;
BEGIN
  INSERT INTO rating(reservation_id, customer_id, vehicle_score,
                     service_score, comment, created_by)
  VALUES (p_reservation_id, p_customer_id, p_vehicle_score,
          p_service_score, p_comment, p_user_id)
  RETURNING id INTO v_id;
  RETURN v_id;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- FUNCIÓN 10: Obtener historial de mantenimientos por vehículo
-- ==========================================
CREATE OR REPLACE FUNCTION fn_get_maintenance_history(p_vehicle_id UUID)
RETURNS TABLE(id UUID, mtype VARCHAR, description TEXT,
              cost DECIMAL, scheduled DATE, state VARCHAR) AS $$
BEGIN
  RETURN QUERY
    SELECT m.id, m.maintenance_type, m.description,
           m.cost, m.scheduled_date, m.maintenance_state
    FROM maintenance m
    WHERE m.vehicle_id = p_vehicle_id AND m.deleted_at IS NULL
    ORDER BY m.scheduled_date DESC;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- FUNCIÓN 11: Crear ticket de soporte
-- ==========================================
CREATE OR REPLACE FUNCTION fn_create_support_ticket(
  p_customer_id UUID, p_subject VARCHAR,
  p_message TEXT, p_user_id UUID
) RETURNS UUID AS $$
DECLARE v_id UUID;
BEGIN
  INSERT INTO support_ticket(customer_id, subject, message,
                             ticket_state, created_by)
  VALUES (p_customer_id, p_subject, p_message, 'OPEN', p_user_id)
  RETURNING id INTO v_id;
  RETURN v_id;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- FUNCIÓN 12: Obtener vehículos con seguro próximo a vencer (30 días)
-- ==========================================
CREATE OR REPLACE FUNCTION fn_get_expiring_insurances()
RETURNS TABLE(vehicle_id UUID, plate VARCHAR, brand VARCHAR,
              policy VARCHAR, expiration DATE, days_left INT) AS $$
BEGIN
  RETURN QUERY
    SELECT v.id, v.plate, v.brand,
           i.policy_number, i.expiration_date,
           (i.expiration_date - CURRENT_DATE)
    FROM insurance i
    JOIN vehicle v ON v.id = i.vehicle_id
    WHERE i.expiration_date <= (CURRENT_DATE + INTERVAL '30 days')
      AND i.deleted_at IS NULL
    ORDER BY i.expiration_date ASC;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- FUNCIÓN 13: Cancelar reserva
-- ==========================================
CREATE OR REPLACE FUNCTION fn_cancel_reservation(
  p_reservation_id UUID, p_user_id UUID
) RETURNS VOID AS $$
DECLARE v_vehicle_id UUID;
BEGIN
  SELECT vehicle_id INTO v_vehicle_id
  FROM reservation WHERE id = p_reservation_id;

  UPDATE reservation
  SET reservation_state = 'CANCELLED',
      updated_at = NOW(), updated_by = p_user_id
  WHERE id = p_reservation_id AND deleted_at IS NULL;

  PERFORM fn_update_vehicle_state(v_vehicle_id, 'AVAILABLE', p_user_id);
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- FUNCIÓN 14: Reporte de ingresos por sucursal en un período
-- ==========================================
CREATE OR REPLACE FUNCTION fn_revenue_by_branch(p_start DATE, p_end DATE)
RETURNS TABLE(branch_name VARCHAR, total_reservations BIGINT, total_revenue DECIMAL) AS $$
BEGIN
  RETURN QUERY
    SELECT b.name, COUNT(r.id), SUM(r.total_amount)
    FROM reservation r
    JOIN vehicle  v ON v.id = r.vehicle_id
    JOIN branch   b ON b.id = v.branch_id
    WHERE r.start_date BETWEEN p_start AND p_end
      AND r.reservation_state = 'COMPLETED'
      AND r.deleted_at IS NULL
    GROUP BY b.name ORDER BY 3 DESC;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- FUNCIÓN 15: Soft delete de usuario
-- ==========================================
CREATE OR REPLACE FUNCTION fn_soft_delete_user(
  p_user_id UUID, p_admin_id UUID
) RETURNS VOID AS $$
BEGIN
  UPDATE users
  SET deleted_at = NOW(),
      deleted_by = p_admin_id,
      active     = FALSE,
      updated_at = NOW(),
      updated_by = p_admin_id
  WHERE id = p_user_id AND deleted_at IS NULL;
END;
$$ LANGUAGE plpgsql;