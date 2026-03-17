
TRUNCATE TABLE payment, invoice_item, invoice, order_item, orders, customer, inventory, product, memory_game_item, person, study_group, academic_program, user_role, role_module, module_view, users, view, module, role, type_document, category, supplier, method_payment, file RESTART IDENTITY CASCADE;

INSERT INTO role (role_name) VALUES
('Administrador'), ('Supervisor'), ('Aprendiz'), ('Gerente'),('Visitante'),
('Cajero'), ('Bodeguero'), ('Instructor'), ('Mantenimiento'), ('Auditor');

INSERT INTO module (name) VALUES
('Seguridad'), ('Parametros'), ('Inventario'), ('Ventas'),('Facturacion'),
('Reportes'), ('Clientes'), ('Proveedores'), ('Configuracion'), ('Juegos');

INSERT INTO view (name, route) VALUES 
('Usuarios', '/sec/users'), ('Roles', '/sec/roles'), ('Productos', '/inv/prod'),
('Stock', '/inv/stock'), ('Vender', '/sale/pos'), ('Historial', '/sale/list'),
('Facturas', '/bill/all'), ('Pagos', '/bill/pay'), ('Memoria', '/game/mem'),
('Perfil', '/user/me');

INSERT INTO users (username, password, email) VALUES 
('admin', 'p1', 'admin@mail.com'), ('cajero1', 'p2', 'c1@mail.com'), ('aprendiz1', 'p3', 'a1@mail.com'),
('instru1', 'p4', 'i1@mail.com'), ('visit1', 'p5', 'v1@mail.com'), ('sup01', 'p6', 's1@mail.com'),
('bodega', 'p7', 'b1@mail.com'), ('audi', 'p8', 'au@mail.com'), ('mante', 'p9', 'm1@mail.com'),
('gerente', 'p10', 'g1@mail.com');

INSERT INTO user_role ( user_id, role_id) VALUES
(1,1), (2,2), (3,3), (4,4), (5,5), (6,6), (7,7), (8,8), (9,9), (10,10);

INSERT INTO role_module (role_id, module_id) VALUES 
(1,1), (1,2), (1,3), (1,4), (1,5), (2,4), (2,5), (3,10), (7,3), (10,6);

INSERT INTO module_view (module_id, view_id) VALUES 
(1,1), (1,2), (3,3), (3,4), (4,5), (4,6), (5,7), (5,8), (10,9), (1,10);

INSERT INTO type_document (name) VALUES 
('Cédula de Ciudadanía'), ('Tarjeta de Identidad'), ('Cédula de Extranjería'), 
('Pasaporte'), ('Registro Civil'), ('NIT'), ('PEP'), ('PPT'), ('VISA'), ('DNI');

INSERT INTO academic_program (program_name) VALUES 
('ADSO'), ('Multimedia'), ('Contabilidad'), ('Gestión Empresarial'), ('Mecánica'),
('Cocina'), ('Enfermería'), ('Construcción'), ('Electricidad'), ('Soldadura');

INSERT INTO study_group (group_code, academic_program_id) VALUES 
('3145555',1), ('282008',1), ('190452',3), ('202021',4), ('212223',2),
('252627',6), ('303132',5), ('404142',7), ('505152',8), ('606162',9);

INSERT INTO person (first_name, last_name, document_number, type_document_id, user_id, study_group_id) VALUES 
('Laura', 'Perez', '101', 1, 1, NULL), ('Ana', 'Gomez', '102', 1, 2, NULL),
('Camilo', 'Penagos', '103', 2, 3, 1), ('Luisa', 'Diaz', '104', 1, 4, 3),
('Yubelly', 'Ruiz', '105', 3, 5, NULL), ('Sara', 'Vega', '106', 1, 6, NULL),
('Pedro', 'Gil', '107', 2, 7, 5), ('Danna', 'Cano', '108', 1, 8, NULL),
('Raul', 'Luz', '109', 1, 9, NULL), ('Eva', 'Sosa', '110', 1, 10, NULL);

INSERT INTO file (file_path) VALUES 
('/img/p1.jpg'), ('/img/p2.jpg'), ('/docs/manual.pdf'), ('/img/p3.jpg'), ('/img/p4.jpg'),
('/img/p5.jpg'), ('/img/p6.jpg'), ('/img/p7.jpg'), ('/img/p8.jpg'), ('/img/p9.jpg');

INSERT INTO category (name) VALUES 
('Cafe'), ('Te'), ('Panaderea'), ('Snacks'), ('Frutas'),
('Bebidas Frias'), ('Almuerzos'), ('Dulces'), ('Saludable'), ('Combos');

INSERT INTO supplier (name) VALUES 
('Alqueria'), ('Postobon'), ('Bimbo'), ('Colanta'), ('Nestle'),
('Frito Lay'), ('Nutresa'), ('Coca-Cola'), ('Sello Rojo'), ('Productor Local');

INSERT INTO product (name, descripcion, price, stock_quantity, category_id) VALUES 
('Tinto', 'Cafe negro', 1200, 100, 1), ('Muffin', 'Vainilla', 2500, 40, 3),
('Jugo Mora', 'Vaso 12oz', 3000, 50, 6), ('Empanada', 'Carne', 2000, 60, 4),
('Agua', 'Botella 500ml', 1500, 80, 6), ('Manzana', 'Roja', 1200, 30, 5),
('Gala', 'Ponqué miniatura', 1000, 100, 3), ('Papas', 'Margarita', 2200, 45, 4),
('Capuchino', 'Con espuma', 3500, 40, 1), ('Aromática', 'Frutos rojos', 1000, 90, 2);

INSERT INTO inventory (quantity_change, movement_type, product_id) VALUES 
(100, 'IN', 1), (40, 'IN', 2), (50, 'IN', 3), (60, 'IN', 4), (80, 'IN', 5),
(-5, 'OUT', 1), (-2, 'OUT', 2), (10, 'IN', 6), (100, 'IN', 7), (45, 'IN', 8);

INSERT INTO customer (customer_type, person_id) VALUES 
('Aprendiz', 3), ('Instructor', 4), ('Visitante', 5), ('Planta', 6), ('Aprendiz', 7),
('Instructor', 8), ('Egresado', 9), ('Directivo', 10), ('Aprendiz', 1), ('Aprendiz', 2);

INSERT INTO method_payment (name) VALUES 
('Efectivo'), ('Nequi'), ('Daviplata'), ('Bancolombia'), ('Visa'),
('Mastercard'), ('PSE'), ('Sodexo'), ('Bono'), ('Transferencia');

INSERT INTO orders (customer_id, total_amount, order_status) VALUES 
(1, 4500, 'Pagado'), (2, 2000, 'Pagado'), (3, 3000, 'Pagado'), (4, 1200, 'Pendiente'), (5, 5500, 'Pagado'),
(6, 1000, 'Pagado'), (7, 4700, 'Pagado'), (8, 3500, 'Cancelado'), (9, 2200, 'Pagado'), (10, 1500, 'Pagado');

INSERT INTO order_item (order_id, product_id, quantity, unit_price) VALUES 
(1,1,1,1200), (1,3,1,3300), (2,4,1,2000), (3,3,1,3000), (5,2,1,2500),
(5,3,1,3000), (6,10,1,1000), (7,8,1,2200), (7,2,1,2500), (9,8,1,2200);

INSERT INTO invoice (order_id, invoice_number, total) VALUES 
(1, 'F-001', 4500), (2, 'F-002', 2000), (3, 'F-003', 3000), (5, 'F-004', 5500), (6, 'F-005', 1000),
(7, 'F-006', 4700), (9, 'F-007', 2200), (10, 'F-008', 1500), (1, 'F-009', 4500), (2, 'F-010', 2000);

INSERT INTO invoice_item (invoice_id, product_name, quantity, price) VALUES 
(1, 'Tinto', 1, 1200), (1, 'Jugo Mora', 1, 3300), (2, 'Empanada', 1, 2000), (3, 'Jugo Mora', 1, 3000), (4, 'Muffin', 1, 2500),
(4, 'Jugo Mora', 1, 3000), (5, 'Aromática', 1, 1000), (6, 'Papas', 1, 2200), (7, 'Papas', 1, 2200), (8, 'Agua', 1, 1500);

INSERT INTO payment (invoice_id, method_payment_id, amount_paid) VALUES 
(1,1,5000), (2,2,2000), (3,1,3000), (4,3,5500), (5,1,1000),
(6,1,10000), (7,4,2200), (8,1,2000), (1,2,4500), (2,1,5000);

INSERT INTO memory_game_item (product_id, english_name) VALUES
(1, 'Coffee'), (2, 'Muffin'), (3, 'Blackberry Juice'), (4, 'Patty'), (5, 'Water'),
(6, 'Apple'), (7, 'Mini Cake'), (8, 'Chips'), (9, 'Cappuchino'), (10, 'Herbal tea');