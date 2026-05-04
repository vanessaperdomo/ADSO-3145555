-- ==========================================
-- VISTA 1: Vehículos disponibles con detalle completo
-- ==========================================
CREATE OR REPLACE VIEW vw_available_vehicles AS
SELECT
    v.id, v.brand, v.model, v.year, v.plate, v.color,
    v.fuel_type, v.transmission, v.capacity, v.daily_rate,
    v.mileage_current, v.vehicle_state,
    vc.name        AS category_name,
    vc.base_rate,
    b.name         AS branch_name,
    c.name         AS city_name,
    f.name         AS fleet_name
FROM vehicle v
JOIN vehicle_category vc ON vc.id = v.vehicle_category_id
JOIN branch            b  ON b.id  = v.branch_id
JOIN city              c  ON c.id  = b.city_id
LEFT JOIN fleet        f  ON f.id  = v.fleet_id
WHERE v.vehicle_state = 'AVAILABLE' AND v.deleted_at IS NULL;

-- ==========================================
-- VISTA 2: Inventario completo de flota por sucursal
-- ==========================================
CREATE OR REPLACE VIEW vw_fleet_by_branch AS
SELECT
    b.name           AS branch_name,
    c.name           AS city_name,
    v.brand, v.model, v.plate, v.year,
    v.vehicle_state,
    vc.name          AS category,
    v.daily_rate,
    v.mileage_current,
    f.name           AS fleet_name
FROM vehicle v
JOIN branch         b  ON b.id  = v.branch_id
JOIN city           c  ON c.id  = b.city_id
JOIN vehicle_category vc ON vc.id = v.vehicle_category_id
LEFT JOIN fleet     f  ON f.id  = v.fleet_id
WHERE v.deleted_at IS NULL
ORDER BY b.name, v.vehicle_state;

-- ==========================================
-- VISTA 3: Seguros activos y por vencer
-- ==========================================
CREATE OR REPLACE VIEW vw_vehicle_insurance AS
SELECT
    v.plate, v.brand, v.model,
    i.name           AS insurance_name,
    i.policy_number,
    i.provider,
    i.coverage_type,
    i.expiration_date,
    (i.expiration_date - CURRENT_DATE) AS days_to_expire,
    CASE
        WHEN (i.expiration_date - CURRENT_DATE) <= 0  THEN 'EXPIRED'
        WHEN (i.expiration_date - CURRENT_DATE) <= 30 THEN 'EXPIRING_SOON'
        ELSE 'VALID'
    END AS insurance_alert,
    b.name           AS branch_name
FROM insurance i
JOIN vehicle v ON v.id = i.vehicle_id
JOIN branch  b ON b.id = v.branch_id
WHERE i.deleted_at IS NULL
ORDER BY i.expiration_date ASC;

-- ==========================================
-- VISTA 4: Historial de mantenimientos por vehículo
-- ==========================================
CREATE OR REPLACE VIEW vw_maintenance_history AS
SELECT
    v.plate, v.brand, v.model,
    m.maintenance_type, m.description,
    m.cost, m.responsible,
    m.scheduled_date, m.completed_date,
    m.mileage_at_service, m.maintenance_state,
    u.username AS registered_by,
    m.created_at
FROM maintenance m
JOIN vehicle v ON v.id = m.vehicle_id
JOIN users   u ON u.id = m.created_by
WHERE m.deleted_at IS NULL
ORDER BY m.scheduled_date DESC;

-- ==========================================
-- VISTA 5: Clientes con datos personales completos
-- ==========================================
CREATE OR REPLACE VIEW vw_customers_full AS
SELECT
    cu.id            AS customer_id,
    cu.customer_type,
    pe.first_name, pe.last_name,
    pe.email, pe.phone,
    pe.document_number,
    dt.name          AS document_type,
    pe.birth_date, pe.nationality,
    ci.name          AS city_name,
    co.name          AS country_name,
    u.username,
    cu.created_at
FROM customer      cu
JOIN person        pe ON pe.id = cu.person_id
JOIN document_type dt ON dt.id = pe.document_type_id
JOIN users          u ON u.id  = cu.user_id
LEFT JOIN city     ci ON ci.id = pe.city_id
LEFT JOIN country  co ON co.id = ci.country_id
WHERE cu.deleted_at IS NULL;

-- ==========================================
-- VISTA 6: Licencias de conducir con estado de revisión
-- ==========================================
CREATE OR REPLACE VIEW vw_driver_licenses AS
SELECT
    dl.id, dl.license_number, dl.license_type,
    dl.issue_date, dl.expiration_date,
    dl.license_state, dl.review_notes,
    (dl.expiration_date - CURRENT_DATE) AS days_to_expire,
    pe.first_name || ' ' || pe.last_name AS customer_name,
    pe.email,
    ur.username AS reviewed_by_user,
    dl.reviewed_at
FROM driver_license dl
JOIN customer   cu ON cu.id = dl.customer_id
JOIN person     pe ON pe.id = cu.person_id
LEFT JOIN users ur ON ur.id = dl.reviewed_by
WHERE dl.deleted_at IS NULL
ORDER BY dl.license_state, dl.expiration_date;

-- ==========================================
-- VISTA 7: Reservas completas con cliente y vehículo
-- ==========================================
CREATE OR REPLACE VIEW vw_reservations_full AS
SELECT
    r.id               AS reservation_id,
    r.reservation_code,
    r.start_date, r.end_date, r.total_days,
    r.daily_rate, r.total_amount, r.reservation_state,
    pe.first_name || ' ' || pe.last_name AS customer_name,
    pe.email           AS customer_email,
    cu.customer_type,
    v.brand || ' ' || v.model            AS vehicle,
    v.plate,
    bp.name            AS pickup_branch,
    br.name            AS return_branch,
    cp.name            AS coverage_plan,
    mp.name            AS mileage_plan,
    r.created_at
FROM reservation   r
JOIN customer      cu ON cu.id = r.customer_id
JOIN person        pe ON pe.id = cu.person_id
JOIN vehicle        v ON v.id  = r.vehicle_id
JOIN branch        bp ON bp.id = r.pickup_branch_id
JOIN branch        br ON br.id = r.return_branch_id
LEFT JOIN coverage_plan cp ON cp.id = r.coverage_plan_id
LEFT JOIN mileage_plan  mp ON mp.id = r.mileage_plan_id
WHERE r.deleted_at IS NULL
ORDER BY r.start_date DESC;

-- ==========================================
-- VISTA 8: Pagos con detalle de reserva y método
-- ==========================================
CREATE OR REPLACE VIEW vw_payments_full AS
SELECT
    p.id              AS payment_id,
    p.amount_paid, p.reference,
    p.wompi_transaction, p.payment_state, p.paid_at,
    pm.name           AS payment_method,
    pm.provider,
    r.reservation_code,
    r.total_amount    AS reservation_total,
    pe.first_name || ' ' || pe.last_name AS customer_name,
    pe.email,
    p.created_at
FROM payment       p
JOIN payment_method pm ON pm.id = p.payment_method_id
JOIN reservation    r  ON r.id  = p.reservation_id
JOIN customer      cu  ON cu.id = r.customer_id
JOIN person        pe  ON pe.id = cu.person_id
WHERE p.deleted_at IS NULL
ORDER BY p.paid_at DESC;

-- ==========================================
-- VISTA 9: Contratos con estado y datos de reserva
-- ==========================================
CREATE OR REPLACE VIEW vw_contracts_full AS
SELECT
    c.id              AS contract_id,
    c.contract_number,
    c.contract_state,
    c.signature_type, c.signed_at,
    r.reservation_code,
    r.start_date, r.end_date, r.total_amount,
    pe.first_name || ' ' || pe.last_name AS customer_name,
    pe.email,
    v.brand || ' ' || v.model            AS vehicle,
    v.plate,
    c.created_at
FROM contract      c
JOIN reservation   r  ON r.id  = c.reservation_id
JOIN customer     cu  ON cu.id = r.customer_id
JOIN person       pe  ON pe.id = cu.person_id
JOIN vehicle       v  ON v.id  = r.vehicle_id
WHERE c.deleted_at IS NULL
ORDER BY c.created_at DESC;

-- ==========================================
-- VISTA 10: Inspecciones de vehículos por reserva
-- ==========================================
CREATE OR REPLACE VIEW vw_vehicle_inspections AS
SELECT
    vi.id, vi.inspection_type,
    vi.body_condition, vi.notes,
    vi.initial_mileage, vi.final_mileage,
    (vi.final_mileage - vi.initial_mileage) AS mileage_used,
    vi.signed_at,
    r.reservation_code,
    v.plate, v.brand, v.model,
    pe.first_name || ' ' || pe.last_name AS customer_name,
    u.username AS operator,
    vi.created_at
FROM vehicle_inspection vi
JOIN reservation  r  ON r.id  = vi.reservation_id
JOIN vehicle      v  ON v.id  = r.vehicle_id
JOIN customer    cu  ON cu.id = r.customer_id
JOIN person      pe  ON pe.id = cu.person_id
JOIN users        u  ON u.id  = vi.operator_id
WHERE vi.deleted_at IS NULL
ORDER BY vi.created_at DESC;

-- ==========================================
-- VISTA 11: Calificaciones aprobadas con promedio
-- ==========================================
CREATE OR REPLACE VIEW vw_ratings_approved AS
SELECT
    rt.id,
    rt.vehicle_score, rt.service_score,
    ROUND((rt.vehicle_score + rt.service_score) / 2.0, 1) AS avg_score,
    rt.comment, rt.is_approved,
    r.reservation_code,
    v.brand || ' ' || v.model  AS vehicle,
    v.plate,
    pe.first_name || ' ' || pe.last_name AS customer_name,
    u.username AS moderated_by_user,
    rt.moderated_at
FROM rating      rt
JOIN reservation  r  ON r.id  = rt.reservation_id
JOIN vehicle      v  ON v.id  = r.vehicle_id
JOIN customer    cu  ON cu.id = rt.customer_id
JOIN person      pe  ON pe.id = cu.person_id
LEFT JOIN users   u  ON u.id  = rt.moderated_by
WHERE rt.deleted_at IS NULL
ORDER BY rt.created_at DESC;

-- ==========================================
-- VISTA 12: Quejas con estado y respuesta
-- ==========================================
CREATE OR REPLACE VIEW vw_complaints_full AS
SELECT
    c.id, c.complaint_type,
    c.description, c.admin_response,
    c.complaint_state, c.auto_closed, c.closed_at,
    pe.first_name || ' ' || pe.last_name AS customer_name,
    pe.email,
    u.username AS responded_by_user,
    c.created_at
FROM complaint   c
JOIN customer   cu ON cu.id = c.customer_id
JOIN person     pe ON pe.id = cu.person_id
LEFT JOIN users  u ON u.id  = c.responded_by
WHERE c.deleted_at IS NULL
ORDER BY c.created_at DESC;

-- ==========================================
-- VISTA 13: Tickets de soporte con mensajes y agente
-- ==========================================
CREATE OR REPLACE VIEW vw_support_tickets AS
SELECT
    st.id          AS ticket_id,
    st.subject, st.message,
    st.ticket_state, st.agent_response,
    st.rating_score, st.closed_at,
    pe.first_name || ' ' || pe.last_name AS customer_name,
    pe.email,
    ua.username    AS assigned_agent,
    (SELECT COUNT(*) FROM ticket_message tm
     WHERE tm.ticket_id = st.id AND tm.deleted_at IS NULL) AS total_messages,
    st.created_at
FROM support_ticket st
JOIN customer       cu ON cu.id = st.customer_id
JOIN person         pe ON pe.id = cu.person_id
LEFT JOIN users     ua ON ua.id = st.assigned_to
WHERE st.deleted_at IS NULL
ORDER BY st.created_at DESC;

-- ==========================================
-- VISTA 14: Resumen de ingresos por sucursal
-- ==========================================
CREATE OR REPLACE VIEW vw_revenue_by_branch AS
SELECT
    b.name                        AS branch_name,
    ci.name                       AS city_name,
    COUNT(r.id)                   AS total_reservations,
    SUM(r.total_amount)           AS total_revenue,
    AVG(r.total_amount)           AS avg_reservation_value,
    SUM(r.total_days)             AS total_days_rented,
    COUNT(DISTINCT r.customer_id) AS unique_customers
FROM reservation r
JOIN vehicle     v  ON v.id  = r.vehicle_id
JOIN branch      b  ON b.id  = v.branch_id
JOIN city        ci ON ci.id = b.city_id
WHERE r.reservation_state = 'COMPLETED'
  AND r.deleted_at IS NULL
GROUP BY b.name, ci.name
ORDER BY total_revenue DESC;

-- ==========================================
-- VISTA 15: Log de auditoría con datos de usuario
-- ==========================================
CREATE OR REPLACE VIEW vw_audit_log_full AS
SELECT
    al.id, al.action, al.entity,
    al.entity_id, al.result,
    al.ip_address, al.endpoint,
    al.old_value, al.new_value,
    u.username,
    pe.first_name || ' ' || pe.last_name AS full_name,
    pe.email,
    al.created_at
FROM audit_log   al
LEFT JOIN users   u  ON u.id  = al.user_id
LEFT JOIN person pe  ON pe.id = u.person_id
ORDER BY al.created_at DESC;