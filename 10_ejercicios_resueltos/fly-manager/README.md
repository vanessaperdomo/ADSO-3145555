# Semana 11 — Sesión 1: Ejercicios Modelo Aerolínea
**Base de datos:** `flydb` | **Puerto:** `5435` | **Estudiante:** `vanessaperdomo`

---

## 🔐 Rol de usuario creado

Se creó un rol propio en PostgreSQL con las credenciales de GitHub de la estudiante, siguiendo buenas prácticas de seguridad y separación de responsabilidades.

```sql
CREATE ROLE vanessaperdomo
WITH LOGIN PASSWORD '********'
NOSUPERUSER NOCREATEDB NOCREATEROLE
INHERIT CONNECTION LIMIT -1;
```

### Permisos otorgados sobre `flydb`

| Permiso | Alcance |
|--------|---------|
| `CONNECT` | Base de datos `flydb` |
| `USAGE` | Esquema `public` |
| `SELECT, INSERT, UPDATE, DELETE` | Todas las tablas del esquema `public` |
| `USAGE, SELECT` | Todas las secuencias del esquema `public` |
| `EXECUTE` | Todas las funciones y procedimientos del esquema `public` |

> Todos los ejercicios fueron ejecutados conectado como `vanessaperdomo@flydb`, no como administrador.

---

## 📋 Cómo revisar el trabajo

### Opción 1 — Verificar en DBeaver

Conectarse a `flydb` en `localhost:5435` y ejecutar:

```sql
-- Ver los 10 triggers creados
SELECT trigger_name, event_object_table, event_manipulation
FROM information_schema.triggers
WHERE trigger_schema = 'public'
  AND trigger_name LIKE 'trg_ej%'
ORDER BY trigger_name;

-- Ver los 10 procedimientos almacenados
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name LIKE 'sp_ej%'
ORDER BY routine_name;

-- Ver las 10 funciones auxiliares
SELECT routine_name
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name LIKE 'fn_ej%'
ORDER BY routine_name;
```

### Opción 2 — Verificar datos insertados por cada ejercicio

```sql
-- EJ01: boarding passes generados automáticamente
SELECT ci.check_in_id, bp.boarding_pass_code, bp.barcode_value
FROM check_in ci INNER JOIN boarding_pass bp ON bp.check_in_id = ci.check_in_id
ORDER BY ci.checked_in_at DESC LIMIT 5;

-- EJ02: reembolsos automáticos generados
SELECT refund_reference, amount, requested_at, refund_reason
FROM refund ORDER BY requested_at DESC LIMIT 5;

-- EJ03: líneas facturables registradas
SELECT il.line_number, il.line_description, il.unit_price, inv.invoice_number
FROM invoice_line il INNER JOIN invoice inv ON inv.invoice_id = il.invoice_id
ORDER BY il.created_at DESC LIMIT 5;

-- EJ04: transacciones de millas registradas
SELECT mt.transaction_type, mt.miles_delta, mt.reference_code, la.account_number
FROM miles_transaction mt INNER JOIN loyalty_account la ON la.loyalty_account_id = mt.loyalty_account_id
ORDER BY mt.occurred_at DESC LIMIT 5;

-- EJ05: eventos de mantenimiento registrados
SELECT a.registration_number, mt.type_name, me.status_code, me.started_at
FROM maintenance_event me
INNER JOIN aircraft a ON a.aircraft_id = me.aircraft_id
INNER JOIN maintenance_type mt ON mt.maintenance_type_id = me.maintenance_type_id
ORDER BY me.started_at DESC LIMIT 5;

-- EJ06: demoras operativas registradas
SELECT fd.delay_minutes, fd.reported_at, drt.reason_name, f.flight_number
FROM flight_delay fd
INNER JOIN flight_segment fs ON fs.flight_segment_id = fd.flight_segment_id
INNER JOIN flight f ON f.flight_id = fs.flight_id
INNER JOIN delay_reason_type drt ON drt.delay_reason_type_id = fd.delay_reason_type_id
ORDER BY fd.reported_at DESC LIMIT 5;

-- EJ07: equipajes registrados
SELECT baggage_tag, baggage_type, weight_kg, baggage_status, checked_at
FROM baggage ORDER BY checked_at DESC LIMIT 5;

-- EJ08: roles asignados a usuarios
SELECT ua.username, sr.role_name, ur.assigned_at
FROM user_role ur
INNER JOIN user_account ua ON ua.user_account_id = ur.user_account_id
INNER JOIN security_role sr ON sr.security_role_id = ur.security_role_id
ORDER BY ur.assigned_at DESC LIMIT 5;

-- EJ09: tarifas publicadas
SELECT fare_code, base_amount, valid_from, valid_to
FROM fare ORDER BY created_at DESC LIMIT 5;

-- EJ10: documentos de identidad registrados
SELECT pd.document_number, dt.type_name, pd.issued_on, p.first_name || ' ' || p.last_name AS persona
FROM person_document pd
INNER JOIN person p ON p.person_id = pd.person_id
INNER JOIN document_type dt ON dt.document_type_id = pd.document_type_id
ORDER BY pd.created_at DESC LIMIT 5;
```

---

## 🗂️ Resumen de los 10 ejercicios

### Ejercicio 01 — Check-in y pase de abordar
- **Consulta:** Trazabilidad completa del pasajero desde reserva hasta vuelo (`reservation → reservation_passenger → person → ticket → ticket_segment → flight_segment → flight`)
- **Trigger:** `trg_ej01_generar_boarding_pass` — genera automáticamente el pase de abordar al registrar un check-in
- **SP:** `sp_ej01_registrar_checkin` — registra el check-in del pasajero con todos sus parámetros

---

### Ejercicio 02 — Pagos y transacciones financieras
- **Consulta:** Flujo completo de venta y pago (`sale → reservation → payment → payment_status → payment_method → payment_transaction → currency`)
- **Trigger:** `trg_ej02_refund_automatico` — genera un reembolso automático cuando el pago cambia a estado Cancelado, Fallido o Reembolsado
- **SP:** `sp_ej02_registrar_transaccion` — registra transacciones de pago (CAPTURE, AUTH, VOID, REFUND)

---

### Ejercicio 03 — Facturación
- **Consulta:** Factura con líneas e impuestos (`invoice → invoice_status → sale → invoice_line → tax → currency`)
- **Trigger:** `trg_ej03_log_linea_factura` — registra trazabilidad cada vez que se agrega una línea facturable
- **SP:** `sp_ej03_registrar_linea_factura` — registra una nueva línea facturable sobre una factura existente

---

### Ejercicio 04 — Millas y fidelización
- **Consulta:** Clientes con millas y niveles (`customer → loyalty_account → miles_transaction → loyalty_account_tier → loyalty_tier`)
- **Trigger:** `trg_ej04_revisar_nivel_millas` — calcula el total de millas EARN y determina el nivel correspondiente (Bronze, Silver, Gold)
- **SP:** `sp_ej04_registrar_millas` — registra una transacción de millas (EARN o REDEEM) con código de referencia

---

### Ejercicio 05 — Mantenimiento de aeronaves
- **Consulta:** Aeronaves con eventos de mantenimiento (`maintenance_event → aircraft → aircraft_model → maintenance_type → maintenance_provider`)
- **Trigger:** `trg_ej05_log_mantenimiento` — registra el ingreso y la finalización de eventos de mantenimiento
- **SP:** `sp_ej05_registrar_mantenimiento` — registra un nuevo evento de mantenimiento para una aeronave

---

### Ejercicio 06 — Retrasos operativos
- **Consulta:** Retrasos por segmento de vuelo (`flight_delay → flight_segment → flight → flight_status → delay_reason_type`)
- **Trigger:** `trg_ej06_vuelo_delayed` — actualiza automáticamente el estado del vuelo a "Demorado" al registrar una demora
- **SP:** `sp_ej06_registrar_demora` — registra una demora operacional con motivo y minutos de retraso

---

### Ejercicio 07 — Asientos y equipaje
- **Consulta:** Pasajeros con asientos y equipaje (`ticket_segment → ticket → reservation_passenger → person → seat_assignment → aircraft_seat → baggage`)
- **Trigger:** `trg_ej07_equipaje_registrado` — registra log del equipaje y genera alerta si el peso supera 23 kg
- **SP:** `sp_ej07_registrar_equipaje` — registra el equipaje de un pasajero con tag, tipo, estado y peso

---

### Ejercicio 08 — Roles y auditoría de acceso
- **Consulta:** Mapa de permisos por usuario (`user_account → user_role → security_role → role_permission → security_permission`)
- **Trigger:** `trg_ej08_auditar_rol` — registra en auditoría cada asignación de rol con usuario, rol y fecha
- **SP:** `sp_ej08_asignar_rol` — asigna un rol a un usuario verificando que no lo tenga ya asignado

---

### Ejercicio 09 — Tarifas comerciales
- **Consulta:** Tarifas por ruta usadas en tiquetes (`fare → fare_class → airport origen → airport destino → ticket → sale → reservation`)
- **Trigger:** `trg_ej09_publicar_tarifa` — registra la publicación de cada nueva tarifa con ruta, clase, monto y vigencia
- **SP:** `sp_ej09_publicar_tarifa` — publica una nueva tarifa con todos sus parámetros comerciales

---

### Ejercicio 10 — Identidad de pasajeros
- **Consulta:** Pasajeros con documentos y contactos (`person → person_type → person_document → document_type → person_contact → contact_type`)
- **Trigger:** `trg_ej10_auditar_documento` — audita la inserción y actualización de documentos de identidad
- **SP:** `sp_ej10_registrar_documento` — registra un nuevo documento de identidad para una persona

---

## ✅ Objetos creados en la base de datos

| Objeto | Nombre | Tabla principal |
|--------|--------|----------------|
| Función + Trigger | `trg_ej01_generar_boarding_pass` | `check_in` |
| Función + Trigger | `trg_ej02_refund_automatico` | `payment` |
| Función + Trigger | `trg_ej03_log_linea_factura` | `invoice_line` |
| Función + Trigger | `trg_ej04_revisar_nivel_millas` | `miles_transaction` |
| Función + Trigger | `trg_ej05_log_mantenimiento` | `maintenance_event` |
| Función + Trigger | `trg_ej06_vuelo_delayed` | `flight_delay` |
| Función + Trigger | `trg_ej07_equipaje_registrado` | `baggage` |
| Función + Trigger | `trg_ej08_auditar_rol` | `user_role` |
| Función + Trigger | `trg_ej09_publicar_tarifa` | `fare` |
| Función + Trigger | `trg_ej10_auditar_documento` | `person_document` |
| Procedimiento | `sp_ej01_registrar_checkin` | `check_in` |
| Procedimiento | `sp_ej02_registrar_transaccion` | `payment_transaction` |
| Procedimiento | `sp_ej03_registrar_linea_factura` | `invoice_line` |
| Procedimiento | `sp_ej04_registrar_millas` | `miles_transaction` |
| Procedimiento | `sp_ej05_registrar_mantenimiento` | `maintenance_event` |
| Procedimiento | `sp_ej06_registrar_demora` | `flight_delay` |
| Procedimiento | `sp_ej07_registrar_equipaje` | `baggage` |
| Procedimiento | `sp_ej08_asignar_rol` | `user_role` |
| Procedimiento | `sp_ej09_publicar_tarifa` | `fare` |
| Procedimiento | `sp_ej10_registrar_documento` | `person_document` |

---

> **Nota:** Todos los ejercicios se ejecutaron respetando estrictamente el modelo base sin alterar tablas, columnas ni relaciones existentes.