# 🛒 Carrito de Compras — Cafetín del SENA (Industria)

**Programa:** Tecnólogo en Análisis y Desarrollo de Software (ADSO)  
**Instructor:** Jesús Ariel  
**Institución:** SENA — Centro de la Industria, la Empresa y los Servicios  
**Lugar:** Neiva, Huila — 2026

**Integrantes:**
- Danna Valentina Barrios Penagos
- Laura Vanessa Perez Perdomo
- Emily Sharith Amézquita Saavedra

---

## 📋 Planteamiento del Problema

La problemática que afecta a los aprendices del Servicio Nacional de Aprendizaje (SENA), en el Centro de la Industria, la Empresa y los Servicios, se relaciona con la atención en la cafetería. Actualmente se presentan:

- **Largas filas** en la cafetería que generan demoras en la atención.
- **Falta de personal** para atender a los aprendices.
- **Errores frecuentes** en la toma de pedidos y en el proceso de pago.
- **Ausencia de imágenes** o menús visuales de los productos, lo que causa confusión y desinterés.
- **Estrés del personal**, que provoca equivocaciones en la entrega del cambio.
- **Reducción del tiempo de descanso** de los aprendices (franja 8:00–8:30 a.m.) debido a las demoras en la atención, afectando su bienestar.

---

## 🎯 Objetivo General

Proponer un sistema que permita clasificar a aprendices, instructores y visitantes, mediante el cual los usuarios puedan seleccionar productos, armar un carrito de compras, confirmar el pedido, y facilitar a la administración de la cafetería llevar control de las ventas de los productos por día. El sistema debe recibir los pedidos de forma ordenada, identificar cada producto y a quién pertenece, y gestionar la preparación y entrega respetando el orden de llegada.

---

## 🎯 Objetivos Específicos

1. Identificar y clasificar los tipos de usuarios de la cafetería (aprendices, instructores y visitantes) y sus productos de consumo.
2. Evaluar la eficiencia del proceso de atención y entrega de productos en la cafetería, considerando el tiempo de espera y la organización de los pedidos.
3. Diseñar y proponer un sistema que optimice la selección, registro y entrega de pedidos, asegurando un control básico del proceso y respetando el orden de los pedidos.

---

## 🔭 Alcance

Se analizará la atención en la cafetería del SENA y cómo los aprendices realizan pedidos durante su tiempo de descanso. Se beneficiarán aprendices, instructores y personal de la cafetería.

**Incluye:**
- Control básico del proceso de pedidos
- Clasificación de usuarios (aprendiz, instructor, visitante)
- Carrito de compras virtual
- Gestión de estados de pedido
- Inventario semanal básico basado en ventas registradas
- Registro de facturación de pedidos
- Integración con pasarela de pago (Wompi) para registro de pagos digitales
- Registro de pagos manuales realizados en el punto de venta

**No incluye:**
- Compatibilidad con iOS
- Versión web del sistema
- Modificación de productos después de ser preparados

---

## ✅ Requerimientos Funcionales (RF)

### 1. Registro y Clasificación de Usuarios

RF1 El sistema permitirá que los usuarios se registren como aprendices, instructores o visitantes. 
RF1.2 Durante el registro, el sistema mostrará una lista de fichas o programas disponibles para que el usuario seleccione a cuál pertenece. El administrador ingresa los programas, fichas, nombre del aprendiz y datos básicos. 
RF1.3 El sistema validará que los datos de registro estén completos antes de permitir el acceso. 
RF1.4 Los usuarios iniciarán sesión mediante una contraseña con requisitos mínimos: mínimo 8 caracteres, 1 letra mayúscula, 1 dato numérico y 1 carácter especial. 

### 2. Selección de Productos y Carrito

RF2.1 El sistema permitirá que los usuarios exploren el menú de productos disponibles en la cafetería. 
RF2.2 Los usuarios podrán agregar y eliminar productos del carrito de compras virtual antes de confirmar el pedido. 
RF2.3 El sistema mostrará el total de los productos seleccionados en el carrito antes de confirmar. 
RF2.4 El sistema permitirá filtrar productos por precio (menor a mayor / mayor a menor) y mostrará sugerencias automáticas de búsqueda con productos similares o coincidentes. 

### 3. Confirmación y Envío de Pedidos

RF3.1 El sistema permitirá que los usuarios confirmen el pedido, enviándolo automáticamente al personal de la cafetería. 
RF3.2 Los pedidos serán recibidos en el orden en que fueron realizados, respetando la prioridad de llegada. 
RF3.3 El sistema mostrará qué productos fueron solicitados y para quién en la pantalla del personal. 
RF3.4 El sistema generará una notificación interna emergente cuando el estado del pedido cambie a **"LISTO"**, informando al usuario que puede pasar a recoger su producto. 

### 4. Preparación y Entrega de Pedidos

RF4.1 El personal de la cafetería podrá marcar los pedidos como **"en preparación"** y luego como **"entregado"**. 
RF4.2 El sistema controlará el estado de cada pedido: pendiente, en preparación, listo y entregado.
RF4.3 El sistema incluirá un **juego interactivo tipo memoria** con imágenes de los productos de la cafetería y su traducción al inglés, para que los usuarios jueguen mientras esperan su pedido. 

### 5. Control y Registro Diario

RF5.1 El sistema llevará un inventario semanal básico. 
RF5.2 La administración podrá consultar un resumen de ventas diario, incluyendo el tipo de producto, cantidad y usuario que lo compró. 

## 6. Facturación y Pagos

RF6.1 El sistema generará una factura asociada a cada pedido confirmado.
RF6.2 El sistema registrará los productos incluidos en cada factura.
RF6.3 El sistema permitirá registrar pagos manuales realizados en efectivo u otros medios físicos.
RF6.4 El sistema permitirá registrar pagos digitales mediante integración con la pasarela de pagos Wompi.
RF6.5 El sistema permitirá consultar el historial de pagos asociados a cada factura.

---

## 🔒 Requerimientos No Funcionales (RNF)

- RNF1 Rendimiento: El sistema debe soportar al menos 50 pedidos simultáneos y responder en un tiempo máximo de 3 segundos al registrar un pedido.
- RNF2 Usabilidad: La interfaz debe ser intuitiva y fácil de usar, mostrando mensajes claros y un menú con imágenes de los productos.
- RNF3 Seguridad: Las contraseñas deben almacenarse de forma encriptada, validando el acceso y gestionando roles y permisos de usuario.
- RNF4 Integración y Pagos: El sistema debe integrarse con Wompi y garantizar la consistencia entre pedidos, facturas y pagos, tanto manuales como digitales.
- RNF5 Persistencia: El sistema debe asegurar que la información no se pierda y contar con respaldo básico de datos.
- RNF6 Disponibilidad: El sistema debe operar de forma continua en el horario de 07:00 AM a 6:00 PM.
- RNF7 Plataforma: La aplicación debe ser compatible con Android 10 o superior.
- RNF8 Escalabilidad: El sistema debe permitir el crecimiento en productos, usuarios y pedidos sin afectar su funcionamiento.
- RNF9 Mantenibilidad: El sistema debe estar diseñado de forma modular, permitiendo futuras mejoras.
---

## 📏 Reglas de Negocio (RN)

1. Cada pedido debe ser asignado a un solo usuario (aprendiz, instructor o visitante).
2. Los pedidos se atenderán en el **orden en que fueron realizados** (orden de llegada).
3. Solo se pueden vender productos que estén **disponibles en el menú del día**.
4. Cada usuario puede tener un **máximo de un pedido activo** al mismo tiempo.
5. El sistema debe generar un **registro de inventario semanal** de ventas para la administración.
6. Los productos solicitados **no se pueden modificar** una vez confirmados, salvo que el pedido no haya sido preparado aún.
7. Cada pedido confirmado debe generar una factura asociada.
8. Los pagos podrán realizarse de forma manual o digital mediante pasarela de pago.
9. Una factura puede tener uno o varios pagos asociados hasta completar el total.
10. El total de la factura debe corresponder a la suma de los productos registrados en el pedido.

---

## 📏 Priorización MoSCoW

### Must — Debe tener
1. Registro y clasificación de usuarios (aprendiz, instructor, visitante) — RF1
2. Inicio de sesión con contraseña segura (8 car., mayúscula, número, símbolo) — RF1.4
3. Exploración del menú y carrito de compras virtual — RF2.1 / RF2.2
4. Visualización del total antes de confirmar — RF2.3
5. Confirmación y envío automático de pedidos al personal — RF3.1
6. Atención de pedidos en orden de llegada — RF3.2
7. Visualización del pedido y usuario en pantalla del personal — RF3.3
8. Control de estados del pedido: pendiente, en preparación, entregado — RF4.2
9. Compatible únicamente con Android 10 o superior — RNF7  
10. Disponibilidad 07:00–18:00 sin caídas frecuentes — RNF6  
11. Generación de factura por pedido — RF6.1
12. Registro de pagos manuales — RF6.3
13. Integración con pasarela de pago (Wompi) — RF6.4

### Should — Debería tener
1. Notificación emergente cuando el pedido esté "LISTO" — RF3.4
2. Gestión de estados por el personal (en preparación / entregado) — RF4.1
3. Resumen de ventas diario para administración — RF5.2
4. Inventario semanal básico — RF5.1
5. Interfaz intuitiva sin necesidad de asistencia — RNF2.1
6. Mensajes de error y confirmación claramente visibles — RNF2.2
7. Protección de datos con contraseña mínima de seguridad — RNF5
8. Respaldo de pedidos y ventas ante cierre inesperado — RNF6

### Could — Podría tener
1. Filtro de productos por precio (menor a mayor / mayor a menor) — RF2.4
2. Sugerencias automáticas de búsqueda con productos similares — RF2.4
3. Juego interactivo tipo memoria con productos e inglés — RF4.3
4. Gestión simultánea de al menos 50 pedidos — RNF1.1
5. Escalabilidad para agregar productos o fichas en el futuro — RNF8
6. Selección de ficha o programa durante el registro — RF1.2

### Won't — No tendrá
1. Compatibilidad con iOS
2. Versión web del sistema
3. Modificación de productos una vez confirmado y en preparación
4. Más de un pedido activo por usuario al mismo tiempo — RN4

## 🎨 Mockup inicial (baja fidelidad)

El prototipo visual fue desarrollado en **Figma** e incluye las pantallas del MVP:

- Pantallas de registro e inicio de sesión
- Exploración del menú de productos
- Carrito de compras virtual con total
- Confirmación de pedido
- Panel del personal con estados (pendiente / en preparación / listo / entregado)
- Juego interactivo de memoria con productos
- Admin — Reporte Semanal de ventas e inventario

| Mockup inicial | [Ver en Figma](https://www.figma.com/proto/YAosTPAwhs1kzLwR0hVDFF/Untitled?node-id=2-34&t=4albUaYE4rg2pZnX-1) |


## Backlog / Plan de trabajo 
   - Historias de usuario con criterios de aceptación
   - Priorización y estimación simple

| 📋 Backlog (Trello) | [Ver en Trello](https://trello.com/invite/b/698c9af9b061c7a394e4955e/ATTI555a0a782b73835c0ed73d3584d525c940DFD856/scrum) |

## Modelo de datos (propuesto) -  listado estructurado

## Programa y usuarios

academic_program

Descripción: Programas de formación académica.

Campos

id (PK) — BIGINT
program_name — VARCHAR
study_group

Descripción: Fichas o grupos asociados a un programa.

Campos

id (PK) — BIGINT
group_code — VARCHAR
academic_program_id (FK) — BIGINT → academic_program.id
type_document

Descripción: Tipos de documento de identidad.

Campos

id (PK) — BIGINT
name — VARCHAR
users

Descripción: Credenciales del sistema.

Campos

id (PK) — BIGINT
username — VARCHAR
password — VARCHAR
email — VARCHAR
person

Descripción: Información personal del usuario.

Campos

id (PK) — BIGINT
first_name — VARCHAR
last_name — VARCHAR
document_number — VARCHAR
type_document_id (FK) → type_document.id
user_id (FK) → users.id
study_group_id (FK) → study_group.id
customer_type

Descripción: Clasificación del cliente.

Campos

id (PK) — BIGINT
name — VARCHAR
customer

Descripción: Cliente que realiza pedidos.

Campos

id (PK) — BIGINT
person_id (FK) → person.id
customer_type_id (FK) → customer_type.id

## Seguridad y Permisos
role

Descripción: Roles del sistema.

Campos

id (PK) — BIGINT
role_name — VARCHAR
user_role

Descripción: Relación usuarios–roles.

Campos

user_id (PK, FK) → users.id
role_id (PK, FK) → role.id
module

Descripción: Módulos del sistema.

Campos

id (PK) — BIGINT
name — VARCHAR
view

Descripción: Vistas o pantallas del sistema.

Campos

id (PK) — BIGINT
name — VARCHAR
route — VARCHAR
role_module

Descripción: Permisos de módulos por rol.

Campos

role_id (PK, FK) → role.id
module_id (PK, FK) → module.id
module_view

Descripción: Relación módulos y vistas.

Campos

module_id (PK, FK) → module.id
view_id (PK, FK) → view.id

## Productos e Inventario

category

Descripción: Categorías de productos.

Campos

id (PK) — BIGINT
name — VARCHAR
supplier

Descripción: Proveedores.

Campos

id (PK) — BIGINT
name — VARCHAR
product

Descripción: Productos del cafetín.

Campos

id (PK) — BIGINT
name — VARCHAR
description — TEXT
price — DECIMAL
stock_quantity — INT
image_url — VARCHAR
category_id (FK) → category.id
supplier_id (FK) → supplier.id
inventory

Descripción: Movimientos de inventario.

Campos

id (PK) — BIGINT
quantity_change — INT
movement_type — VARCHAR
product_id (FK) → product.id
created_by_user_id (FK) → users.id
created_at — TIMESTAMP
memory_game_item

Descripción: Elementos del juego educativo.

Campos

id (PK) — BIGINT
english_name — VARCHAR
image_url — VARCHAR
product_id (FK) → product.id

## Pedidos

order_status

Descripción: Estados del pedido.

Campos

id (PK) — BIGINT
name — VARCHAR
orders

Descripción: Pedido realizado por un cliente.

Campos

id (PK) — BIGINT
total_amount — DECIMAL
status_id (FK) → order_status.id
customer_id (FK) → customer.id
created_at — TIMESTAMP
order_status_history

Descripción: Historial de estados del pedido.

Campos

id (PK) — BIGINT
order_id (FK) → orders.id
status_id (FK) → order_status.id
changed_at — TIMESTAMP
order_item

Descripción: Productos incluidos en un pedido.

Campos

id (PK) — BIGINT
order_id (FK) → orders.id
product_id (FK) → product.id
quantity — INT
unit_price — DECIMAL

## Facturación y Pagos

invoice

Descripción: Factura generada por pedido.

Campos

id (PK) — BIGINT
invoice_number — VARCHAR
total — DECIMAL
order_id (FK) → orders.id
invoice_item

Descripción: Detalle de factura.

Campos

id (PK) — BIGINT
invoice_id (FK) → invoice.id
product_id (FK) → product.id
quantity — INT
price — DECIMAL
method_payment

Descripción: Métodos de pago.

Campos

id (PK) — BIGINT
name — VARCHAR
payment

Descripción: Pagos realizados.

Campos

id (PK) — BIGINT
invoice_id (FK) → invoice.id
method_payment_id (FK) → method_payment.id
amount_paid — DECIMAL

---

## Otros recursos del trabajo

| 🎬 Video metodologia Scrum | [Ver en YouTube](https://youtu.be/mrtQ4Y4C1wM?si=DwDM6kJgakKITd-A) |
| 🎬 Presentacion canva cafetinsena | [Ver en YouTube](https://www.pdffiller.com/s/bOL5SeMUc) |
