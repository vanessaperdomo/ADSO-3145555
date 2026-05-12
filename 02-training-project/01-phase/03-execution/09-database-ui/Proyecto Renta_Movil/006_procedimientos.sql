-- PROCEDIMIENTO 1: Registra un nuevo usuario junto con su persona asociada
CREATE OR REPLACE PROCEDURE sp_register_user(
    p_first_name VARCHAR, p_last_name VARCHAR, p_document_number VARCHAR,
    p_email VARCHAR, p_birth_date DATE, p_document_type_id UUID,
    p_username VARCHAR, p_password VARCHAR
)
LANGUAGE plpgsql AS $$
DECLARE
    v_person_id UUID;
BEGIN
    INSERT INTO person(first_name, last_name, document_number, email, birth_date, document_type_id)
    VALUES(p_first_name, p_last_name, p_document_number, p_email, p_birth_date, p_document_type_id)
    RETURNING id INTO v_person_id;
    INSERT INTO users(username, password, person_id) VALUES(p_username, p_password, v_person_id);
    RAISE NOTICE 'Usuario registrado correctamente';
END;
$$;


-- PROCEDIMIENTO 2: Crea una reserva validando disponibilidad del vehículo
CREATE OR REPLACE PROCEDURE sp_create_reservation(
    p_start_date DATE, p_end_date DATE, p_vehicle_id UUID,
    p_customer_id UUID, p_daily_rate DECIMAL,
    p_pickup_branch_id UUID, p_return_branch_id UUID
)
LANGUAGE plpgsql AS $$
DECLARE
    v_state VARCHAR;
BEGIN
    SELECT vehicle_state INTO v_state FROM vehicle WHERE id = p_vehicle_id;
    IF v_state != 'AVAILABLE' THEN
        RAISE EXCEPTION 'Vehículo no disponible. Estado: %', v_state;
    END IF;
    INSERT INTO reservation(reservation_code, start_date, end_date, total_days, daily_rate,
        total_amount, vehicle_id, customer_id, pickup_branch_id, return_branch_id)
    VALUES('RES-' || TO_CHAR(NOW(),'YYYYMMDD') || '-' || FLOOR(RANDOM()*9999)::TEXT,
        p_start_date, p_end_date, (p_end_date - p_start_date),
        p_daily_rate, (p_end_date - p_start_date) * p_daily_rate,
        p_vehicle_id, p_customer_id, p_pickup_branch_id, p_return_branch_id);
    RAISE NOTICE 'Reserva creada exitosamente';
END;
$$;


-- PROCEDIMIENTO 3: Procesa un pago y confirma la reserva asociada
CREATE OR REPLACE PROCEDURE sp_process_payment(
    p_reservation_id UUID, p_amount DECIMAL,
    p_method_id UUID, p_reference VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO payment(amount_paid, reference, payment_state, paid_at, reservation_id, payment_method_id)
    VALUES(p_amount, p_reference, 'APPROVED', NOW(), p_reservation_id, p_method_id);
    UPDATE reservation SET reservation_state = 'CONFIRMED', updated_at = NOW()
    WHERE id = p_reservation_id;
    RAISE NOTICE 'Pago procesado y reserva confirmada';
END;
$$;


-- PROCEDIMIENTO 4: Cancela una reserva y libera el vehículo
CREATE OR REPLACE PROCEDURE sp_cancel_reservation(
    p_reservation_id UUID, p_user_id UUID
)
LANGUAGE plpgsql AS $$
DECLARE
    v_vehicle_id UUID;
BEGIN
    SELECT vehicle_id INTO v_vehicle_id FROM reservation WHERE id = p_reservation_id;
    UPDATE reservation SET reservation_state = 'CANCELLED', updated_at = NOW(), deleted_by = p_user_id
    WHERE id = p_reservation_id;
    UPDATE vehicle SET vehicle_state = 'AVAILABLE', updated_at = NOW()
    WHERE id = v_vehicle_id;
    RAISE NOTICE 'Reserva cancelada y vehículo liberado';
END;
$$;


-- PROCEDIMIENTO 5: Registra un mantenimiento y bloquea el vehículo
CREATE OR REPLACE PROCEDURE sp_register_maintenance(
    p_vehicle_id UUID, p_type VARCHAR, p_description TEXT,
    p_scheduled_date DATE, p_created_by UUID
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO maintenance(vehicle_id, maintenance_type, description, scheduled_date, maintenance_state, created_by)
    VALUES(p_vehicle_id, p_type, p_description, p_scheduled_date, 'PENDING', p_created_by);
    UPDATE vehicle SET vehicle_state = 'MAINTENANCE', updated_at = NOW()
    WHERE id = p_vehicle_id;
    RAISE NOTICE 'Mantenimiento registrado y vehículo bloqueado';
END;
$$;


-- PROCEDIMIENTO 6: Completa un mantenimiento y libera el vehículo
CREATE OR REPLACE PROCEDURE sp_complete_maintenance(
    p_maintenance_id UUID, p_cost DECIMAL, p_completed_date DATE
)
LANGUAGE plpgsql AS $$
DECLARE
    v_vehicle_id UUID;
BEGIN
    SELECT vehicle_id INTO v_vehicle_id FROM maintenance WHERE id = p_maintenance_id;
    UPDATE maintenance SET maintenance_state = 'COMPLETED', cost = p_cost,
        completed_date = p_completed_date, updated_at = NOW()
    WHERE id = p_maintenance_id;
    UPDATE vehicle SET vehicle_state = 'AVAILABLE', updated_at = NOW()
    WHERE id = v_vehicle_id;
    RAISE NOTICE 'Mantenimiento completado y vehículo disponible';
END;
$$;


-- PROCEDIMIENTO 7: Registra la inspección de entrega o devolución de un vehículo
CREATE OR REPLACE PROCEDURE sp_register_inspection(
    p_reservation_id UUID, p_type VARCHAR, p_mileage INT,
    p_notes TEXT, p_operator_id UUID
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO vehicle_inspection(reservation_id, inspection_type, initial_mileage, notes, operator_id)
    VALUES(p_reservation_id, p_type, p_mileage, p_notes, p_operator_id);
    IF p_type = 'RETURN' THEN
        UPDATE reservation SET reservation_state = 'COMPLETED', updated_at = NOW()
        WHERE id = p_reservation_id;
    END IF;
    RAISE NOTICE 'Inspección registrada correctamente';
END;
$$;


-- PROCEDIMIENTO 8: Crea un contrato vinculado a una reserva confirmada
CREATE OR REPLACE PROCEDURE sp_create_contract(
    p_reservation_id UUID, p_content TEXT, p_signature_type VARCHAR
)
LANGUAGE plpgsql AS $$
DECLARE
    v_state VARCHAR;
BEGIN
    SELECT reservation_state INTO v_state FROM reservation WHERE id = p_reservation_id;
    IF v_state != 'CONFIRMED' THEN
        RAISE EXCEPTION 'Solo se puede crear contrato para reservas confirmadas';
    END IF;
    INSERT INTO contract(contract_number, content, signature_type, contract_state, reservation_id)
    VALUES('CON-' || TO_CHAR(NOW(),'YYYYMMDD') || '-' || FLOOR(RANDOM()*9999)::TEXT,
        p_content, p_signature_type, 'PENDING', p_reservation_id);
    RAISE NOTICE 'Contrato creado exitosamente';
END;
$$;


-- PROCEDIMIENTO 9: Registra la calificación de un cliente para una reserva completada
CREATE OR REPLACE PROCEDURE sp_submit_rating(
    p_reservation_id UUID, p_customer_id UUID,
    p_vehicle_score INT, p_service_score INT, p_comment TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    IF p_vehicle_score NOT BETWEEN 1 AND 5 OR p_service_score NOT BETWEEN 1 AND 5 THEN
        RAISE EXCEPTION 'Los puntajes deben estar entre 1 y 5';
    END IF;
    INSERT INTO rating(reservation_id, customer_id, vehicle_score, service_score, comment)
    VALUES(p_reservation_id, p_customer_id, p_vehicle_score, p_service_score, p_comment);
    RAISE NOTICE 'Calificación registrada correctamente';
END;
$$;


-- PROCEDIMIENTO 10: Crea una queja de un cliente con su descripción
CREATE OR REPLACE PROCEDURE sp_create_complaint(
    p_customer_id UUID, p_type VARCHAR, p_description TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    IF p_description IS NULL OR LENGTH(TRIM(p_description)) = 0 THEN
        RAISE EXCEPTION 'La descripción de la queja no puede estar vacía';
    END IF;
    INSERT INTO complaint(customer_id, complaint_type, description, complaint_state)
    VALUES(p_customer_id, p_type, p_description, 'PENDING');
    RAISE NOTICE 'Queja registrada correctamente';
END;
$$;


-- PROCEDIMIENTO 11: Responde una queja y cambia su estado a RESOLVED
CREATE OR REPLACE PROCEDURE sp_respond_complaint(
    p_complaint_id UUID, p_response TEXT, p_user_id UUID
)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE complaint
    SET admin_response = p_response, complaint_state = 'RESOLVED',
        responded_by = p_user_id, updated_at = NOW()
    WHERE id = p_complaint_id;
    RAISE NOTICE 'Queja respondida y marcada como resuelta';
END;
$$;


-- PROCEDIMIENTO 12: Abre un ticket de soporte para un cliente
CREATE OR REPLACE PROCEDURE sp_open_support_ticket(
    p_customer_id UUID, p_subject VARCHAR, p_message TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO support_ticket(customer_id, subject, message, ticket_state)
    VALUES(p_customer_id, p_subject, p_message, 'OPEN');
    RAISE NOTICE 'Ticket de soporte creado correctamente';
END;
$$;


-- PROCEDIMIENTO 13: Cierra un ticket de soporte con respuesta del agente
CREATE OR REPLACE PROCEDURE sp_close_support_ticket(
    p_ticket_id UUID, p_response TEXT, p_agent_id UUID, p_rating INT
)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE support_ticket
    SET ticket_state = 'CLOSED', agent_response = p_response,
        assigned_to = p_agent_id, rating_score = p_rating,
        closed_at = NOW(), updated_at = NOW()
    WHERE id = p_ticket_id;
    RAISE NOTICE 'Ticket cerrado con respuesta del agente';
END;
$$;


-- PROCEDIMIENTO 14: Envía una notificación a un usuario por canal específico
CREATE OR REPLACE PROCEDURE sp_send_notification(
    p_user_id UUID, p_type_id UUID,
    p_channel VARCHAR, p_subject VARCHAR, p_body TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    IF p_channel NOT IN ('EMAIL','PUSH','SMS') THEN
        RAISE EXCEPTION 'Canal inválido: %', p_channel;
    END IF;
    INSERT INTO notification(user_id, notification_type_id, channel, subject, body, sent, sent_at)
    VALUES(p_user_id, p_type_id, p_channel, p_subject, p_body, TRUE, NOW());
    RAISE NOTICE 'Notificación enviada por canal %', p_channel;
END;
$$;


-- PROCEDIMIENTO 15: Registra una licencia de conducción para un cliente
CREATE OR REPLACE PROCEDURE sp_register_driver_license(
    p_customer_id UUID, p_license_number VARCHAR, p_license_type VARCHAR,
    p_issue_date DATE, p_expiration_date DATE,
    p_front_url VARCHAR, p_back_url VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
    IF p_expiration_date <= CURRENT_DATE THEN
        RAISE EXCEPTION 'La licencia ya está vencida';
    END IF;
    INSERT INTO driver_license(customer_id, license_number, license_type,
        issue_date, expiration_date, front_url, back_url, license_state)
    VALUES(p_customer_id, p_license_number, p_license_type,
        p_issue_date, p_expiration_date, p_front_url, p_back_url, 'PENDING');
    RAISE NOTICE 'Licencia registrada y pendiente de revisión';
END;
$$;