# Diccionario de Datos — Base de Datos `coffee-shop`

> **Motor:** PostgreSQL · **Extensión:** `uuid-ossp`
> **Convención de auditoría:** Todas las tablas incluyen `created_at`, `updated_at`, `deleted_at` (soft delete) y, cuando aplica, `created_by`, `updated_by`, `deleted_by` (UUID del usuario responsable) y `status_id` (referencia al estado global).

---

## Módulo 0 — Status Global

### Tabla: `status`

Catálogo global de estados reutilizados por todas las demás tablas del sistema.

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT `uuid_generate_v4()` | Identificador único del estado. |
| `name` | VARCHAR(50) | NOT NULL, UNIQUE | Nombre descriptivo del estado (ej. `Activo`, `Inactivo`, `Eliminado`). |
| `description` | TEXT | — | Descripción detallada del propósito del estado. |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación del registro. |
| `updated_at` | TIMESTAMPTZ | — | Fecha y hora de la última actualización. |
| `deleted_at` | TIMESTAMPTZ | — | Fecha y hora de eliminación lógica; `NULL` indica que el registro está activo. |

---

## Módulo 1 — Parámetros

### Tabla: `type_document`

Catálogo de tipos de documento de identidad aceptados por el sistema (ej. CC, TI, Pasaporte).

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT `uuid_generate_v4()` | Identificador único del tipo de documento. |
| `name` | VARCHAR(50) | NOT NULL, UNIQUE | Nombre del tipo de documento (ej. `Cédula de Ciudadanía`). |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación del registro. |
| `updated_at` | TIMESTAMPTZ | — | Fecha y hora de la última actualización. |
| `deleted_at` | TIMESTAMPTZ | — | Fecha de eliminación lógica. |
| `created_by` | UUID | — | ID del usuario que creó el registro (sin FK porque `users` aún no existe en este punto de migración). |
| `updated_by` | UUID | — | ID del usuario que realizó la última modificación. |
| `deleted_by` | UUID | — | ID del usuario que eliminó lógicamente el registro. |
| `status_id` | UUID | FK → `status(id)` | Estado actual del tipo de documento. |

---

### Tabla: `academic_program`

Catálogo de programas académicos de la institución (ej. Ingeniería de Sistemas, Administración).

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT `uuid_generate_v4()` | Identificador único del programa académico. |
| `program_name` | VARCHAR(150) | NOT NULL, UNIQUE | Nombre completo del programa académico. |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación del registro. |
| `updated_at` | TIMESTAMPTZ | — | Fecha y hora de la última actualización. |
| `deleted_at` | TIMESTAMPTZ | — | Fecha de eliminación lógica. |
| `created_by` | UUID | — | ID del usuario creador (sin FK en este módulo). |
| `updated_by` | UUID | — | ID del usuario que realizó la última modificación. |
| `deleted_by` | UUID | — | ID del usuario que eliminó lógicamente el registro. |
| `status_id` | UUID | FK → `status(id)` | Estado actual del programa académico. |

---

### Tabla: `study_group`

Grupos de estudio asociados a un programa académico (ej. Grupo A, Grupo B de un semestre).

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT `uuid_generate_v4()` | Identificador único del grupo de estudio. |
| `group_code` | VARCHAR(50) | NOT NULL, UNIQUE | Código identificador del grupo (ej. `INGE-2025-A`). |
| `academic_program_id` | UUID | NOT NULL, FK → `academic_program(id)` | Programa académico al que pertenece el grupo. |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación del registro. |
| `updated_at` | TIMESTAMPTZ | — | Fecha y hora de la última actualización. |
| `deleted_at` | TIMESTAMPTZ | — | Fecha de eliminación lógica. |
| `created_by` | UUID | — | ID del usuario creador (sin FK en este módulo). |
| `updated_by` | UUID | — | ID del usuario que realizó la última modificación. |
| `deleted_by` | UUID | — | ID del usuario que eliminó lógicamente el registro. |
| `status_id` | UUID | FK → `status(id)` | Estado actual del grupo. |

---

### Tabla: `person`

Información personal y de contacto de cualquier individuo registrado en el sistema (usuarios, clientes, etc.).

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT `uuid_generate_v4()` | Identificador único de la persona. |
| `first_name` | VARCHAR(100) | NOT NULL | Nombre(s) de la persona. |
| `last_name` | VARCHAR(100) | NOT NULL | Apellido(s) de la persona. |
| `document_number` | VARCHAR(20) | NOT NULL, UNIQUE | Número de documento de identidad único en el sistema. |
| `email` | VARCHAR(150) | NOT NULL, UNIQUE | Correo electrónico único de la persona. |
| `phone` | VARCHAR(20) | — | Número de teléfono de contacto (opcional). |
| `type_document_id` | UUID | NOT NULL, FK → `type_document(id)` | Tipo de documento de identidad de la persona. |
| `study_group_id` | UUID | FK → `study_group(id)` | Grupo de estudio al que pertenece la persona (opcional, aplica para estudiantes). |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación del registro. |
| `updated_at` | TIMESTAMPTZ | — | Fecha y hora de la última actualización. |
| `deleted_at` | TIMESTAMPTZ | — | Fecha de eliminación lógica. |
| `created_by` | UUID | — | ID del usuario creador (sin FK en este módulo). |
| `updated_by` | UUID | — | ID del usuario que realizó la última modificación. |
| `deleted_by` | UUID | — | ID del usuario que eliminó lógicamente el registro. |
| `status_id` | UUID | FK → `status(id)` | Estado actual del registro de la persona. |

---

### Tabla: `file`

Archivos digitales adjuntos a una persona (documentos, fotos de perfil, soportes, etc.).

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT `uuid_generate_v4()` | Identificador único del archivo. |
| `file_name` | VARCHAR(255) | NOT NULL | Nombre original del archivo (ej. `cedula_frente.jpg`). |
| `file_url` | VARCHAR(500) | NOT NULL | URL o ruta donde se encuentra almacenado el archivo. |
| `file_type` | VARCHAR(50) | — | Tipo MIME o extensión del archivo (ej. `image/jpeg`, `application/pdf`). |
| `person_id` | UUID | FK → `person(id)` | Persona a la que pertenece el archivo (opcional). |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación del registro. |
| `updated_at` | TIMESTAMPTZ | — | Fecha y hora de la última actualización. |
| `deleted_at` | TIMESTAMPTZ | — | Fecha de eliminación lógica. |
| `created_by` | UUID | — | ID del usuario creador (sin FK en este módulo). |
| `updated_by` | UUID | — | ID del usuario que realizó la última modificación. |
| `deleted_by` | UUID | — | ID del usuario que eliminó lógicamente el registro. |
| `status_id` | UUID | FK → `status(id)` | Estado actual del archivo. |

---

## Módulo 2 — Seguridad

### Tabla: `users`

Cuentas de acceso al sistema. Cada usuario está vinculado a una persona registrada.

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT `uuid_generate_v4()` | Identificador único del usuario. |
| `username` | VARCHAR(100) | NOT NULL, UNIQUE | Nombre de usuario para iniciar sesión. |
| `password` | VARCHAR(255) | NOT NULL | Contraseña cifrada del usuario. |
| `active` | BOOLEAN | NOT NULL, DEFAULT TRUE | Indica si la cuenta de usuario está habilitada. |
| `person_id` | UUID | NOT NULL, FK → `person(id)` | Persona física asociada a esta cuenta de usuario. |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación del registro. |
| `updated_at` | TIMESTAMPTZ | — | Fecha y hora de la última actualización. |
| `deleted_at` | TIMESTAMPTZ | — | Fecha de eliminación lógica. |
| `created_by` | UUID | FK → `users(id)` | Usuario que creó este registro. |
| `updated_by` | UUID | FK → `users(id)` | Usuario que realizó la última modificación. |
| `deleted_by` | UUID | FK → `users(id)` | Usuario que eliminó lógicamente el registro. |
| `status_id` | UUID | FK → `status(id)` | Estado actual del usuario. |

---

### Tabla: `role`

Roles del sistema que agrupan permisos de acceso (ej. Administrador, Cajero, Inventario).

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT `uuid_generate_v4()` | Identificador único del rol. |
| `role_name` | VARCHAR(50) | NOT NULL, UNIQUE | Nombre del rol (ej. `ADMIN`, `CASHIER`). |
| `description` | TEXT | — | Descripción del propósito y alcance del rol. |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación del registro. |
| `updated_at` | TIMESTAMPTZ | — | Fecha y hora de la última actualización. |
| `deleted_at` | TIMESTAMPTZ | — | Fecha de eliminación lógica. |
| `created_by` | UUID | FK → `users(id)` | Usuario que creó el rol. |
| `updated_by` | UUID | FK → `users(id)` | Usuario que realizó la última modificación. |
| `deleted_by` | UUID | FK → `users(id)` | Usuario que eliminó lógicamente el rol. |
| `status_id` | UUID | FK → `status(id)` | Estado actual del rol. |

---

### Tabla: `module`

Módulos funcionales del sistema (ej. Inventario, Ventas, Facturación).

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT `uuid_generate_v4()` | Identificador único del módulo. |
| `name` | VARCHAR(100) | NOT NULL, UNIQUE | Nombre del módulo del sistema. |
| `description` | TEXT | — | Descripción de las funcionalidades que agrupa el módulo. |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación del registro. |
| `updated_at` | TIMESTAMPTZ | — | Fecha y hora de la última actualización. |
| `deleted_at` | TIMESTAMPTZ | — | Fecha de eliminación lógica. |
| `created_by` | UUID | FK → `users(id)` | Usuario que creó el módulo. |
| `updated_by` | UUID | FK → `users(id)` | Usuario que realizó la última modificación. |
| `deleted_by` | UUID | FK → `users(id)` | Usuario que eliminó lógicamente el módulo. |
| `status_id` | UUID | FK → `status(id)` | Estado actual del módulo. |

---

### Tabla: `view`

Vistas o pantallas individuales de la aplicación, agrupadas dentro de módulos.

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT `uuid_generate_v4()` | Identificador único de la vista. |
| `name` | VARCHAR(100) | NOT NULL | Nombre descriptivo de la vista o pantalla. |
| `route` | VARCHAR(255) | — | Ruta URL de la vista en la aplicación (ej. `/inventory/products`). |
| `description` | TEXT | — | Descripción del contenido o función de la vista. |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación del registro. |
| `updated_at` | TIMESTAMPTZ | — | Fecha y hora de la última actualización. |
| `deleted_at` | TIMESTAMPTZ | — | Fecha de eliminación lógica. |
| `created_by` | UUID | FK → `users(id)` | Usuario que creó la vista. |
| `updated_by` | UUID | FK → `users(id)` | Usuario que realizó la última modificación. |
| `deleted_by` | UUID | FK → `users(id)` | Usuario que eliminó lógicamente la vista. |
| `status_id` | UUID | FK → `status(id)` | Estado actual de la vista. |

---

### Tabla: `user_role`

Tabla de relación many-to-many entre usuarios y roles. Define qué roles tiene asignado cada usuario.

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `user_id` | UUID | PK (compuesto), NOT NULL, FK → `users(id)` | Usuario al que se le asigna el rol. |
| `role_id` | UUID | PK (compuesto), NOT NULL, FK → `role(id)` | Rol asignado al usuario. |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora en que se asignó el rol. |
| `updated_at` | TIMESTAMPTZ | — | Fecha y hora de la última actualización. |
| `deleted_at` | TIMESTAMPTZ | — | Fecha de eliminación lógica (revocación del rol). |
| `created_by` | UUID | FK → `users(id)` | Usuario que realizó la asignación. |
| `updated_by` | UUID | FK → `users(id)` | Usuario que realizó la última modificación. |
| `deleted_by` | UUID | FK → `users(id)` | Usuario que revocó el rol. |
| `status_id` | UUID | FK → `status(id)` | Estado actual de la relación usuario-rol. |

---

### Tabla: `role_module`

Tabla de relación many-to-many entre roles y módulos. Define a qué módulos tiene acceso cada rol.

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `role_id` | UUID | PK (compuesto), NOT NULL, FK → `role(id)` | Rol al que se le concede acceso al módulo. |
| `module_id` | UUID | PK (compuesto), NOT NULL, FK → `module(id)` | Módulo al que tiene acceso el rol. |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora en que se concedió el acceso. |
| `updated_at` | TIMESTAMPTZ | — | Fecha y hora de la última actualización. |
| `deleted_at` | TIMESTAMPTZ | — | Fecha de eliminación lógica (revocación del acceso). |
| `created_by` | UUID | FK → `users(id)` | Usuario que configuró el acceso. |
| `updated_by` | UUID | FK → `users(id)` | Usuario que realizó la última modificación. |
| `deleted_by` | UUID | FK → `users(id)` | Usuario que revocó el acceso. |
| `status_id` | UUID | FK → `status(id)` | Estado actual de la relación rol-módulo. |

---

### Tabla: `module_view`

Tabla de relación many-to-many entre módulos y vistas. Determina qué vistas componen cada módulo.

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `module_id` | UUID | PK (compuesto), NOT NULL, FK → `module(id)` | Módulo al que pertenece la vista. |
| `view_id` | UUID | PK (compuesto), NOT NULL, FK → `view(id)` | Vista asociada al módulo. |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora en que se vinculó la vista al módulo. |
| `updated_at` | TIMESTAMPTZ | — | Fecha y hora de la última actualización. |
| `deleted_at` | TIMESTAMPTZ | — | Fecha de eliminación lógica. |
| `created_by` | UUID | FK → `users(id)` | Usuario que configuró la relación. |
| `updated_by` | UUID | FK → `users(id)` | Usuario que realizó la última modificación. |
| `deleted_by` | UUID | FK → `users(id)` | Usuario que eliminó lógicamente la relación. |
| `status_id` | UUID | FK → `status(id)` | Estado actual de la relación módulo-vista. |

---

## Módulo 3 — Inventario

### Tabla: `category`

Categorías que clasifican los productos del inventario (ej. Bebidas, Alimentos, Insumos).

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT `uuid_generate_v4()` | Identificador único de la categoría. |
| `name` | VARCHAR(100) | NOT NULL, UNIQUE | Nombre de la categoría de producto. |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación del registro. |
| `updated_at` | TIMESTAMPTZ | — | Fecha y hora de la última actualización. |
| `deleted_at` | TIMESTAMPTZ | — | Fecha de eliminación lógica. |
| `created_by` | UUID | FK → `users(id)` | Usuario que creó la categoría. |
| `updated_by` | UUID | FK → `users(id)` | Usuario que realizó la última modificación. |
| `deleted_by` | UUID | FK → `users(id)` | Usuario que eliminó lógicamente la categoría. |
| `status_id` | UUID | FK → `status(id)` | Estado actual de la categoría. |

---

### Tabla: `supplier`

Proveedores que suministran los productos al coffee shop.

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT `uuid_generate_v4()` | Identificador único del proveedor. |
| `name` | VARCHAR(150) | NOT NULL, UNIQUE | Razón social o nombre del proveedor. |
| `phone` | VARCHAR(20) | — | Teléfono de contacto del proveedor. |
| `email` | VARCHAR(150) | — | Correo electrónico de contacto del proveedor. |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación del registro. |
| `updated_at` | TIMESTAMPTZ | — | Fecha y hora de la última actualización. |
| `deleted_at` | TIMESTAMPTZ | — | Fecha de eliminación lógica. |
| `created_by` | UUID | FK → `users(id)` | Usuario que registró al proveedor. |
| `updated_by` | UUID | FK → `users(id)` | Usuario que realizó la última modificación. |
| `deleted_by` | UUID | FK → `users(id)` | Usuario que eliminó lógicamente el proveedor. |
| `status_id` | UUID | FK → `status(id)` | Estado actual del proveedor. |

---

### Tabla: `product`

Productos disponibles en el inventario del coffee shop para la venta o consumo interno.

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT `uuid_generate_v4()` | Identificador único del producto. |
| `name` | VARCHAR(150) | NOT NULL | Nombre del producto (ej. `Café Americano`, `Muffin de arándanos`). |
| `description` | TEXT | — | Descripción detallada del producto, ingredientes o características. |
| `price` | DECIMAL(10,2) | NOT NULL | Precio de venta del producto al público. |
| `stock` | INT | NOT NULL, DEFAULT 0 | Cantidad disponible en inventario al momento de la consulta. |
| `image_url` | VARCHAR(255) | — | URL de la imagen representativa del producto. |
| `category_id` | UUID | NOT NULL, FK → `category(id)` | Categoría a la que pertenece el producto. |
| `supplier_id` | UUID | NOT NULL, FK → `supplier(id)` | Proveedor que suministra el producto. |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación del registro. |
| `updated_at` | TIMESTAMPTZ | — | Fecha y hora de la última actualización. |
| `deleted_at` | TIMESTAMPTZ | — | Fecha de eliminación lógica. |
| `created_by` | UUID | FK → `users(id)` | Usuario que registró el producto. |
| `updated_by` | UUID | FK → `users(id)` | Usuario que realizó la última modificación. |
| `deleted_by` | UUID | FK → `users(id)` | Usuario que eliminó lógicamente el producto. |
| `status_id` | UUID | FK → `status(id)` | Estado actual del producto. |

---

### Tabla: `inventory_movement`

Registro de entradas y salidas de productos del inventario para trazabilidad y control de stock.

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT `uuid_generate_v4()` | Identificador único del movimiento de inventario. |
| `movement_type` | VARCHAR(20) | NOT NULL, CHECK IN ('ENTRADA','SALIDA') | Tipo de movimiento: `ENTRADA` (ingreso de stock) o `SALIDA` (consumo o venta). |
| `quantity` | INT | NOT NULL | Cantidad de unidades involucradas en el movimiento. |
| `product_id` | UUID | NOT NULL, FK → `product(id)` | Producto afectado por el movimiento. |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora en que se registró el movimiento. |
| `updated_at` | TIMESTAMPTZ | — | Fecha y hora de la última actualización. |
| `deleted_at` | TIMESTAMPTZ | — | Fecha de eliminación lógica del registro. |
| `created_by` | UUID | NOT NULL, FK → `users(id)` | Usuario que registró el movimiento (requerido). |
| `updated_by` | UUID | FK → `users(id)` | Usuario que realizó la última modificación. |
| `deleted_by` | UUID | FK → `users(id)` | Usuario que eliminó lógicamente el movimiento. |
| `status_id` | UUID | FK → `status(id)` | Estado actual del movimiento de inventario. |

---

### Tabla: `memory_game_item`

Ítems del juego educativo de memoria vinculados a productos del catálogo, usados para aprender los nombres en inglés.

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT `uuid_generate_v4()` | Identificador único del ítem del juego. |
| `english_name` | VARCHAR(100) | NOT NULL | Nombre del producto en inglés, utilizado como respuesta en el juego de memoria. |
| `image_url` | VARCHAR(255) | — | URL de la imagen del ítem usada como pista visual en el juego. |
| `product_id` | UUID | NOT NULL, FK → `product(id)` | Producto del catálogo asociado a este ítem del juego. |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación del registro. |
| `updated_at` | TIMESTAMPTZ | — | Fecha y hora de la última actualización. |
| `deleted_at` | TIMESTAMPTZ | — | Fecha de eliminación lógica. |
| `created_by` | UUID | FK → `users(id)` | Usuario que creó el ítem del juego. |
| `updated_by` | UUID | FK → `users(id)` | Usuario que realizó la última modificación. |
| `deleted_by` | UUID | FK → `users(id)` | Usuario que eliminó lógicamente el ítem. |
| `status_id` | UUID | FK → `status(id)` | Estado actual del ítem del juego. |

---

## Módulo 4 — Ventas

### Tabla: `customer_type`

Clasificación de los tipos de cliente (ej. Estudiante, Docente, Visitante externo).

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT `uuid_generate_v4()` | Identificador único del tipo de cliente. |
| `name` | VARCHAR(50) | NOT NULL, UNIQUE | Nombre del tipo de cliente. |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación del registro. |
| `updated_at` | TIMESTAMPTZ | — | Fecha y hora de la última actualización. |
| `deleted_at` | TIMESTAMPTZ | — | Fecha de eliminación lógica. |
| `created_by` | UUID | FK → `users(id)` | Usuario que creó el tipo de cliente. |
| `updated_by` | UUID | FK → `users(id)` | Usuario que realizó la última modificación. |
| `deleted_by` | UUID | FK → `users(id)` | Usuario que eliminó lógicamente el registro. |
| `status_id` | UUID | FK → `status(id)` | Estado actual del tipo de cliente. |

---

### Tabla: `customer`

Clientes registrados en el sistema, vinculados a una persona y clasificados por tipo.

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT `uuid_generate_v4()` | Identificador único del cliente. |
| `person_id` | UUID | NOT NULL, FK → `person(id)` | Datos personales del cliente (nombre, documento, contacto). |
| `customer_type_id` | UUID | NOT NULL, FK → `customer_type(id)` | Tipo de cliente al que pertenece. |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación del registro. |
| `updated_at` | TIMESTAMPTZ | — | Fecha y hora de la última actualización. |
| `deleted_at` | TIMESTAMPTZ | — | Fecha de eliminación lógica. |
| `created_by` | UUID | FK → `users(id)` | Usuario que registró al cliente. |
| `updated_by` | UUID | FK → `users(id)` | Usuario que realizó la última modificación. |
| `deleted_by` | UUID | FK → `users(id)` | Usuario que eliminó lógicamente el cliente. |
| `status_id` | UUID | FK → `status(id)` | Estado actual del cliente. |

---

### Tabla: `order_status`

Catálogo de estados posibles de un pedido (ej. Pendiente, En preparación, Entregado, Cancelado).

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT `uuid_generate_v4()` | Identificador único del estado de pedido. |
| `name` | VARCHAR(50) | NOT NULL, UNIQUE | Nombre del estado del pedido. |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación del registro. |
| `updated_at` | TIMESTAMPTZ | — | Fecha y hora de la última actualización. |
| `deleted_at` | TIMESTAMPTZ | — | Fecha de eliminación lógica. |
| `created_by` | UUID | FK → `users(id)` | Usuario que creó el estado. |
| `updated_by` | UUID | FK → `users(id)` | Usuario que realizó la última modificación. |
| `deleted_by` | UUID | FK → `users(id)` | Usuario que eliminó lógicamente el registro. |
| `status_id` | UUID | FK → `status(id)` | Estado actual del registro en el sistema. |

---

### Tabla: `orders`

Pedidos realizados por los clientes. Agrupa los ítems solicitados y registra el total a pagar.

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT `uuid_generate_v4()` | Identificador único del pedido. |
| `total_amount` | DECIMAL(10,2) | NOT NULL | Monto total del pedido, calculado como la suma de los ítems. |
| `order_status_id` | UUID | NOT NULL, FK → `order_status(id)` | Estado actual del pedido (ej. pendiente, entregado). |
| `customer_id` | UUID | NOT NULL, FK → `customer(id)` | Cliente que realizó el pedido. |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora en que se creó el pedido. |
| `updated_at` | TIMESTAMPTZ | — | Fecha y hora de la última actualización. |
| `deleted_at` | TIMESTAMPTZ | — | Fecha de eliminación lógica (cancelación). |
| `created_by` | UUID | FK → `users(id)` | Usuario (cajero/mesero) que tomó el pedido. |
| `updated_by` | UUID | FK → `users(id)` | Usuario que realizó la última modificación. |
| `deleted_by` | UUID | FK → `users(id)` | Usuario que canceló o eliminó el pedido. |
| `status_id` | UUID | FK → `status(id)` | Estado del registro en el sistema. |

---

### Tabla: `order_item`

Detalle de los productos incluidos en cada pedido, con cantidad y precio unitario al momento de la compra.

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT `uuid_generate_v4()` | Identificador único del ítem de pedido. |
| `order_id` | UUID | NOT NULL, FK → `orders(id)` | Pedido al que pertenece este ítem. |
| `product_id` | UUID | NOT NULL, FK → `product(id)` | Producto solicitado en el pedido. |
| `quantity` | INT | NOT NULL | Cantidad de unidades del producto solicitadas. |
| `unit_price` | DECIMAL(10,2) | NOT NULL | Precio unitario del producto en el momento del pedido (precio histórico). |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación del registro. |
| `updated_at` | TIMESTAMPTZ | — | Fecha y hora de la última actualización. |
| `deleted_at` | TIMESTAMPTZ | — | Fecha de eliminación lógica. |
| `created_by` | UUID | FK → `users(id)` | Usuario que agregó el ítem al pedido. |
| `updated_by` | UUID | FK → `users(id)` | Usuario que realizó la última modificación. |
| `deleted_by` | UUID | FK → `users(id)` | Usuario que eliminó lógicamente el ítem. |
| `status_id` | UUID | FK → `status(id)` | Estado actual del ítem del pedido. |

---

## Módulo 4 — Métodos de Pago

### Tabla: `method_payment`

Catálogo de métodos de pago aceptados (ej. Efectivo, Tarjeta débito, Tarjeta crédito, Transferencia).

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT `uuid_generate_v4()` | Identificador único del método de pago. |
| `name` | VARCHAR(50) | NOT NULL, UNIQUE | Nombre del método de pago. |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación del registro. |
| `updated_at` | TIMESTAMPTZ | — | Fecha y hora de la última actualización. |
| `deleted_at` | TIMESTAMPTZ | — | Fecha de eliminación lógica. |
| `created_by` | UUID | FK → `users(id)` | Usuario que registró el método de pago. |
| `updated_by` | UUID | FK → `users(id)` | Usuario que realizó la última modificación. |
| `deleted_by` | UUID | FK → `users(id)` | Usuario que eliminó lógicamente el registro. |
| `status_id` | UUID | FK → `status(id)` | Estado actual del método de pago. |

---

## Módulo 5 — Facturación

### Tabla: `invoice`

Facturas generadas a partir de los pedidos confirmados.

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT `uuid_generate_v4()` | Identificador único de la factura. |
| `invoice_number` | VARCHAR(50) | NOT NULL, UNIQUE | Número consecutivo único de la factura (ej. `FAC-2025-0001`). |
| `total` | DECIMAL(10,2) | NOT NULL | Monto total de la factura. |
| `order_id` | UUID | NOT NULL, FK → `orders(id)` | Pedido origen del cual se genera la factura. |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de emisión de la factura. |
| `updated_at` | TIMESTAMPTZ | — | Fecha y hora de la última actualización. |
| `deleted_at` | TIMESTAMPTZ | — | Fecha de eliminación lógica (anulación de factura). |
| `created_by` | UUID | FK → `users(id)` | Usuario que emitió la factura. |
| `updated_by` | UUID | FK → `users(id)` | Usuario que realizó la última modificación. |
| `deleted_by` | UUID | FK → `users(id)` | Usuario que anuló la factura. |
| `status_id` | UUID | FK → `status(id)` | Estado actual de la factura. |

---

### Tabla: `invoice_item`

Detalle de los productos facturados en cada factura, con cantidad y precio al momento de la facturación.

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT `uuid_generate_v4()` | Identificador único del ítem de factura. |
| `invoice_id` | UUID | NOT NULL, FK → `invoice(id)` | Factura a la que pertenece este ítem. |
| `product_id` | UUID | NOT NULL, FK → `product(id)` | Producto facturado. |
| `quantity` | INT | NOT NULL | Cantidad de unidades facturadas del producto. |
| `price` | DECIMAL(10,2) | NOT NULL | Precio unitario del producto al momento de la facturación (precio histórico). |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación del registro. |
| `updated_at` | TIMESTAMPTZ | — | Fecha y hora de la última actualización. |
| `deleted_at` | TIMESTAMPTZ | — | Fecha de eliminación lógica. |
| `created_by` | UUID | FK → `users(id)` | Usuario que registró el ítem de factura. |
| `updated_by` | UUID | FK → `users(id)` | Usuario que realizó la última modificación. |
| `deleted_by` | UUID | FK → `users(id)` | Usuario que eliminó lógicamente el ítem. |
| `status_id` | UUID | FK → `status(id)` | Estado actual del ítem de factura. |

---

### Tabla: `payment`

Registro de los pagos realizados contra una factura, incluyendo el método utilizado y el monto abonado.

| Campo | Tipo | Restricciones | Descripción |
|---|---|---|---|
| `id` | UUID | PK, DEFAULT `uuid_generate_v4()` | Identificador único del pago. |
| `amount_paid` | DECIMAL(10,2) | NOT NULL | Monto efectivamente pagado en esta transacción. |
| `invoice_id` | UUID | NOT NULL, FK → `invoice(id)` | Factura a la que se aplica el pago. |
| `method_payment_id` | UUID | NOT NULL, FK → `method_payment(id)` | Método de pago utilizado (efectivo, tarjeta, etc.). |
| `paid_at` | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora exacta en que se realizó el pago. |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación del registro en el sistema. |
| `updated_at` | TIMESTAMPTZ | — | Fecha y hora de la última actualización. |
| `deleted_at` | TIMESTAMPTZ | — | Fecha de eliminación lógica (reversión o anulación del pago). |
| `created_by` | UUID | FK → `users(id)` | Usuario que registró el pago. |
| `updated_by` | UUID | FK → `users(id)` | Usuario que realizó la última modificación. |
| `deleted_by` | UUID | FK → `users(id)` | Usuario que anuló el pago. |
| `status_id` | UUID | FK → `status(id)` | Estado actual del pago. |

---

## Resumen de Tablas

| # | Tabla | Módulo | Descripción breve |
|---|---|---|---|
| 1 | `status` | Global | Estados globales del sistema |
| 2 | `type_document` | Parámetros | Tipos de documento de identidad |
| 3 | `academic_program` | Parámetros | Programas académicos |
| 4 | `study_group` | Parámetros | Grupos de estudio |
| 5 | `person` | Parámetros | Datos personales |
| 6 | `file` | Parámetros | Archivos adjuntos a personas |
| 7 | `users` | Seguridad | Cuentas de usuario |
| 8 | `role` | Seguridad | Roles del sistema |
| 9 | `module` | Seguridad | Módulos funcionales |
| 10 | `view` | Seguridad | Vistas o pantallas |
| 11 | `user_role` | Seguridad | Relación usuario-rol |
| 12 | `role_module` | Seguridad | Relación rol-módulo |
| 13 | `module_view` | Seguridad | Relación módulo-vista |
| 14 | `category` | Inventario | Categorías de productos |
| 15 | `supplier` | Inventario | Proveedores |
| 16 | `product` | Inventario | Productos del catálogo |
| 17 | `inventory_movement` | Inventario | Movimientos de stock |
| 18 | `memory_game_item` | Inventario | Ítems del juego de memoria |
| 19 | `customer_type` | Ventas | Tipos de cliente |
| 20 | `customer` | Ventas | Clientes registrados |
| 21 | `order_status` | Ventas | Estados de pedido |
| 22 | `orders` | Ventas | Pedidos |
| 23 | `order_item` | Ventas | Detalle de pedidos |
| 24 | `method_payment` | Métodos de Pago | Métodos de pago aceptados |
| 25 | `invoice` | Facturación | Facturas |
| 26 | `invoice_item` | Facturación | Detalle de facturas |
| 27 | `payment` | Facturación | Pagos realizados |
