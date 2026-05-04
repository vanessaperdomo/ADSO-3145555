-- TRIGGER 1: Actualiza updated_at automáticamente en la tabla vehicle
-- Se ejecuta antes de cada UPDATE para registrar la fecha de modificación
CREATE OR REPLACE FUNCTION trg_fn_vehicle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_vehicle_updated_at
BEFORE UPDATE ON vehicle
FOR EACH ROW EXECUTE FUNCTION trg_fn_vehicle_updated_at();


-- TRIGGER 2: Cambia el estado del vehículo a RENTED cuando la reserva se activa
-- Sincroniza vehicle_state con el ciclo de vida de la reserva
CREATE OR REPLACE FUNCTION trg_fn_reservation_vehicle_state()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.reservation_state = 'ACTIVE' AND OLD.reservation_state != 'ACTIVE' THEN
        UPDATE vehicle SET vehicle_state = 'RENTED', updated_at = NOW()
        WHERE id = NEW.vehicle_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_reservation_vehicle_state
AFTER UPDATE ON reservation
FOR EACH ROW EXECUTE FUNCTION trg_fn_reservation_vehicle_state();


-- TRIGGER 3: Restaura el vehículo a AVAILABLE cuando la reserva se completa o cancela
-- Garantiza que el vehículo quede disponible al cerrar el ciclo de la reserva
CREATE OR REPLACE FUNCTION trg_fn_reservation_release_vehicle()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.reservation_state IN ('COMPLETED','CANCELLED','NO_SHOW')
       AND OLD.reservation_state NOT IN ('COMPLETED','CANCELLED','NO_SHOW') THEN
        UPDATE vehicle SET vehicle_state = 'AVAILABLE', updated_at = NOW()
        WHERE id = NEW.vehicle_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_reservation_release_vehicle
AFTER UPDATE ON reservation
FOR EACH ROW EXECUTE FUNCTION trg_fn_reservation_release_vehicle();


-- TRIGGER 4: Cambia el vehículo a MAINTENANCE cuando se crea un mantenimiento PENDING o IN_PROGRESS
-- Bloquea la disponibilidad del vehículo mientras está en taller
CREATE OR REPLACE FUNCTION trg_fn_maintenance_block_vehicle()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.maintenance_state IN ('PENDING','IN_PROGRESS') THEN
        UPDATE vehicle SET vehicle_state = 'MAINTENANCE', updated_at = NOW()
        WHERE id = NEW.vehicle_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_maintenance_block_vehicle
AFTER INSERT ON maintenance
FOR EACH ROW EXECUTE FUNCTION trg_fn_maintenance_block_vehicle();


-- TRIGGER 5: Restaura el vehículo a AVAILABLE cuando el mantenimiento se completa
-- Libera el vehículo al finalizar cualquier tipo de mantenimiento
CREATE OR REPLACE FUNCTION trg_fn_maintenance_complete_vehicle()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.maintenance_state = 'COMPLETED' AND OLD.maintenance_state != 'COMPLETED' THEN
        UPDATE vehicle SET vehicle_state = 'AVAILABLE', updated_at = NOW()
        WHERE id = NEW.vehicle_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_maintenance_complete_vehicle
AFTER UPDATE ON maintenance
FOR EACH ROW EXECUTE FUNCTION trg_fn_maintenance_complete_vehicle();


-- TRIGGER 6: Bloquea el usuario después de 5 intentos fallidos de login
-- Protege la cuenta estableciendo blocked_until por 30 minutos
CREATE OR REPLACE FUNCTION trg_fn_block_user_on_failed_attempts()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.failed_attempts >= 5 AND OLD.failed_attempts < 5 THEN
        NEW.blocked_until = NOW() + INTERVAL '30 minutes';
        NEW.active = FALSE;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_block_user_on_failed_attempts
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION trg_fn_block_user_on_failed_attempts();


-- TRIGGER 7: Registra en audit_log cada cambio de estado de una reserva
-- Permite trazabilidad completa del ciclo de vida de la reserva
CREATE OR REPLACE FUNCTION trg_fn_audit_reservation_state()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.reservation_state IS DISTINCT FROM OLD.reservation_state THEN
        INSERT INTO audit_log (action, entity, entity_id, old_value, new_value, result)
        VALUES ('STATE_CHANGE', 'reservation', NEW.id,
                jsonb_build_object('state', OLD.reservation_state),
                jsonb_build_object('state', NEW.reservation_state),
                'SUCCESS');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_audit_reservation_state
AFTER UPDATE ON reservation
FOR EACH ROW EXECUTE FUNCTION trg_fn_audit_reservation_state();


-- TRIGGER 8: Actualiza el kilometraje actual del vehículo al completar la inspección de devolución
-- Mantiene actualizado mileage_current con el odómetro registrado en la inspección
CREATE OR REPLACE FUNCTION trg_fn_update_vehicle_mileage()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.inspection_type = 'RETURN' AND NEW.final_mileage IS NOT NULL THEN
        UPDATE vehicle SET mileage_current = NEW.final_mileage, updated_at = NOW()
        WHERE id = (SELECT vehicle_id FROM reservation WHERE id = NEW.reservation_id);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_vehicle_mileage
AFTER INSERT OR UPDATE ON vehicle_inspection
FOR EACH ROW EXECUTE FUNCTION trg_fn_update_vehicle_mileage();


-- TRIGGER 9: Genera automáticamente el código de reserva si no se provee
-- Crea un código único con prefijo RES y timestamp para identificar la reserva
CREATE OR REPLACE FUNCTION trg_fn_generate_reservation_code()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.reservation_code IS NULL OR NEW.reservation_code = '' THEN
        NEW.reservation_code = 'RES-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' ||
                               UPPER(SUBSTRING(NEW.id::TEXT, 1, 8));
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_generate_reservation_code
BEFORE INSERT ON reservation
FOR EACH ROW EXECUTE FUNCTION trg_fn_generate_reservation_code();


-- TRIGGER 10: Impide crear reservas sobre vehículos no disponibles
-- Valida que vehicle_state sea AVAILABLE antes de confirmar la reserva
CREATE OR REPLACE FUNCTION trg_fn_validate_vehicle_availability()
RETURNS TRIGGER AS $$
DECLARE
    v_state VARCHAR(30);
BEGIN
    SELECT vehicle_state INTO v_state FROM vehicle WHERE id = NEW.vehicle_id;
    IF v_state != 'AVAILABLE' THEN
        RAISE EXCEPTION 'El vehículo con id % no está disponible. Estado actual: %', NEW.vehicle_id, v_state;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_vehicle_availability
BEFORE INSERT ON reservation
FOR EACH ROW EXECUTE FUNCTION trg_fn_validate_vehicle_availability();


-- TRIGGER 11: Cierra automáticamente quejas sin respuesta después de 30 días
-- Marca auto_closed = TRUE y actualiza complaint_state a CLOSED por inactividad
CREATE OR REPLACE FUNCTION trg_fn_auto_close_complaint()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.complaint_state = 'PENDING' AND
       OLD.complaint_state = 'PENDING' AND
       NOW() > OLD.created_at + INTERVAL '30 days' THEN
        NEW.complaint_state = 'CLOSED';
        NEW.auto_closed    = TRUE;
        NEW.closed_at      = NOW();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auto_close_complaint
BEFORE UPDATE ON complaint
FOR EACH ROW EXECUTE FUNCTION trg_fn_auto_close_complaint();


-- TRIGGER 12: Impide eliminar físicamente un contrato firmado
-- Protege la integridad legal bloqueando hard-delete en contratos con estado SIGNED
CREATE OR REPLACE FUNCTION trg_fn_protect_signed_contract()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.contract_state = 'SIGNED' THEN
        RAISE EXCEPTION 'No se puede eliminar un contrato firmado (id: %). Use soft-delete.', OLD.id;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_protect_signed_contract
BEFORE DELETE ON contract
FOR EACH ROW EXECUTE FUNCTION trg_fn_protect_signed_contract();


-- TRIGGER 13: Resetea failed_attempts a 0 cuando el usuario vuelve a estar activo
-- Limpia el contador de intentos fallidos al reactivar manualmente una cuenta
CREATE OR REPLACE FUNCTION trg_fn_reset_failed_attempts()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.active = TRUE AND OLD.active = FALSE THEN
        NEW.failed_attempts = 0;
        NEW.blocked_until   = NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_reset_failed_attempts
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION trg_fn_reset_failed_attempts();


-- TRIGGER 14: Calcula automáticamente total_days al insertar o actualizar una reserva
-- Evita inconsistencias entre start_date, end_date y total_days
CREATE OR REPLACE FUNCTION trg_fn_calculate_total_days()
RETURNS TRIGGER AS $$
BEGIN
    NEW.total_days = (NEW.end_date - NEW.start_date);
    IF NEW.total_days <= 0 THEN
        RAISE EXCEPTION 'La fecha de fin debe ser posterior a la fecha de inicio.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calculate_total_days
BEFORE INSERT OR UPDATE ON reservation
FOR EACH ROW EXECUTE FUNCTION trg_fn_calculate_total_days();


-- TRIGGER 15: Registra en audit_log cada pago aprobado con su monto y referencia
-- Garantiza trazabilidad financiera de todas las transacciones completadas
CREATE OR REPLACE FUNCTION trg_fn_audit_approved_payment()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.payment_state = 'APPROVED' AND OLD.payment_state != 'APPROVED' THEN
        INSERT INTO audit_log (action, entity, entity_id, old_value, new_value, result)
        VALUES ('PAYMENT_APPROVED', 'payment', NEW.id,
                jsonb_build_object('state', OLD.payment_state),
                jsonb_build_object('state', NEW.payment_state,
                                   'amount', NEW.amount_paid,
                                   'reference', NEW.reference),
                'SUCCESS');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_audit_approved_payment
AFTER UPDATE ON payment
FOR EACH ROW EXECUTE FUNCTION trg_fn_audit_approved_payment();