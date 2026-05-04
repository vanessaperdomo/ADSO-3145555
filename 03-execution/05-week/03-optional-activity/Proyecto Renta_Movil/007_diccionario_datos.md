# Diccionario de Datos — Base de Datos: `renta_movil`

---

## Módulo 0: Estado Global

### `status`
Tabla central de estados reutilizada por todos los módulos del sistema.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único del estado |
| name | VARCHAR(50) | NOT NULL | Nombre del estado (ej: ACTIVO) |
| description | TEXT | | Descripción detallada del estado |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |

---

## Módulo 1: Parámetros Base

### `document_type`
Almacena los tipos de documento de identidad aceptados en el sistema.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único del tipo |
| name | VARCHAR(50) | NOT NULL | Nombre del tipo (ej: CÉDULA, NIT) |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

### `country`
Catálogo de países disponibles en el sistema.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único del país |
| name | VARCHAR(100) | NOT NULL | Nombre completo del país |
| code | VARCHAR(5) | NOT NULL | Código ISO del país (ej: CO, US) |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

### `city`
Catálogo de ciudades asociadas a un país.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único de la ciudad |
| name | VARCHAR(100) | NOT NULL | Nombre de la ciudad |
| country_id | UUID | FK → country | País al que pertenece la ciudad |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

### `language`
Idiomas disponibles para la configuración de preferencias de usuario.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único del idioma |
| name | VARCHAR(50) | NOT NULL | Nombre del idioma (ej: Español) |
| code | VARCHAR(10) | NOT NULL | Código del idioma (ej: es, en) |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

### `person`
Almacena la información personal y de contacto de cualquier individuo del sistema.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único de la persona |
| first_name | VARCHAR(100) | NOT NULL | Nombre(s) de la persona |
| last_name | VARCHAR(100) | NOT NULL | Apellido(s) de la persona |
| document_number | VARCHAR(30) | NOT NULL, UNIQUE | Número de documento de identidad |
| email | VARCHAR(150) | NOT NULL, UNIQUE | Correo electrónico de contacto |
| phone | VARCHAR(20) | | Número de teléfono de contacto |
| birth_date | DATE | NOT NULL | Fecha de nacimiento |
| nationality | VARCHAR(100) | | Nacionalidad de la persona |
| document_type_id | UUID | FK → document_type | Tipo de documento de identidad |
| city_id | UUID | FK → city | Ciudad de residencia |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

### `file`
Tabla polimórfica que centraliza todos los archivos del sistema (documentos, imágenes, contratos, etc.).

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único del archivo |
| file_name | VARCHAR(255) | NOT NULL | Nombre original del archivo |
| file_url | VARCHAR(500) | NOT NULL | URL de acceso al archivo almacenado |
| file_type | VARCHAR(50) | | Tipo MIME o extensión del archivo (ej: pdf, jpg) |
| entity_type | VARCHAR(50) | NOT NULL, CHECK | Entidad a la que pertenece (PERSON, MAINTENANCE, etc) |
| entity_id | UUID | NOT NULL | ID del registro al que pertenece el archivo |
| person_id | UUID | FK → person | Persona propietaria o relacionada al archivo |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

## Módulo 2: Seguridad

### `users`
Almacena las credenciales y configuración de seguridad de los usuarios del sistema.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único del usuario |
| username | VARCHAR(100) | NOT NULL | Nombre de usuario para inicio de sesión |
| password | VARCHAR(255) | NOT NULL | Contraseña encriptada del usuario |
| active | BOOLEAN | NOT NULL | Indica si el usuario está activo |
| failed_attempts | INT | NOT NULL | Contador de intentos fallidos de login |
| blocked_until | TIMESTAMPTZ | | Fecha hasta la que el usuario está bloqueado |
| last_login | TIMESTAMPTZ | | Fecha y hora del último inicio de sesión |
| two_factor_enabled | BOOLEAN | NOT NULL | Indica si tiene autenticación de dos factores |
| person_id | UUID | FK → person | Persona asociada al usuario |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

### `user_preference`
Preferencias de visualización e idioma configuradas por cada usuario.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único de la preferencia |
| theme | VARCHAR(20) | NOT NULL, CHECK | Tema visual (light o dark) |
| primary_color | VARCHAR(10) | | Color primario seleccionado (hex) |
| secondary_color | VARCHAR(10) | | Color secundario seleccionado (hex) |
| accent_color | VARCHAR(10) | | Color de acento seleccionado (hex) |
| preferred_language | UUID | FK → language | Idioma preferido del usuario |
| user_id | UUID | FK → users | Usuario dueño de las preferencias |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

### `user_session`
Registro de sesiones activas de usuarios con información del dispositivo y token.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único de la sesión |
| refresh_token | VARCHAR(500) | NOT NULL | Token de refresco para renovar la sesión |
| ip_address | VARCHAR(50) | | Dirección IP desde donde inició sesión |
| user_agent | TEXT | | Información del navegador o cliente usado |
| device | VARCHAR(100) | | Nombre o tipo de dispositivo |
| expires_at | TIMESTAMPTZ | NOT NULL | Fecha y hora de expiración de la sesión |
| revoked | BOOLEAN | NOT NULL | Indica si la sesión fue revocada |
| revoked_at | TIMESTAMPTZ | | Fecha y hora en que fue revocada |
| user_id | UUID | FK → users | Usuario propietario de la sesión |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| status_id | UUID | FK → status | Estado actual del registro |

---

### `role`
Roles del sistema que agrupan permisos y módulos para los usuarios.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único del rol |
| name | VARCHAR(50) | NOT NULL | Nombre del rol (ej: ADMIN, AGENT) |
| description | TEXT | | Descripción de las funciones |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

### `module`
Módulos funcionales del sistema a los que se puede asignar acceso por rol.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único del módulo |
| name | VARCHAR(100) | NOT NULL | Nombre del módulo |
| description | TEXT | | Descripción de la funcionalidad |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

### `view`
Vistas o pantallas del sistema asociadas directamente a un módulo.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único de la vista |
| name | VARCHAR(100) | NOT NULL | Nombre de la vista |
| route | VARCHAR(255) | | Ruta URL de la vista |
| description | TEXT | | Descripción de la funcionalidad |
| module_id | UUID | FK → module | Módulo al que pertenece la vista |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

### `user_role`
Tabla pivote que relaciona usuarios con sus roles asignados.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| user_id | UUID | PK, FK → users | Usuario al que se asigna el rol |
| role_id | UUID | PK, FK → role | Rol asignado al usuario |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de asignación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

### `role_module`
Tabla pivote que define qué módulos tiene acceso cada rol.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| role_id | UUID | PK, FK → role | Rol al que se le asigna el módulo |
| module_id | UUID | PK, FK → module | Módulo asignado al rol |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de asignación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

### `password_reset_token`
Tokens temporales generados para el proceso de recuperación de contraseña.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único del token |
| token | VARCHAR(255) | NOT NULL | Token de recuperación generado |
| expires_at | TIMESTAMPTZ | NOT NULL | Fecha y hora de expiración del token |
| used | BOOLEAN | NOT NULL | Indica si el token ya fue utilizado |
| user_id | UUID | FK → users | Usuario que solicitó la recuperación |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| status_id | UUID | FK → status | Estado actual del registro |

---

### `two_factor_code`
Códigos temporales de verificación para autenticación de dos factores.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único del código |
| code | VARCHAR(10) | NOT NULL | Código OTP generado para verificación |
| expires_at | TIMESTAMPTZ | NOT NULL | Fecha y hora de expiración del código |
| used | BOOLEAN | NOT NULL | Indica si el código ya fue usado |
| user_id | UUID | FK → users | Usuario al que pertenece el código |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| status_id | UUID | FK → status | Estado actual del registro |

---

## Módulo 3: Flota y Vehículos

### `vehicle_category`
Categorías de vehículos que definen la tarifa base de alquiler.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único de la categoría |
| name | VARCHAR(100) | NOT NULL | Nombre de la categoría (ej: SUV) |
| description | TEXT | | Descripción de la categoría |
| base_rate | DECIMAL(10,2) | NOT NULL | Tarifa base diaria de la categoría |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

### `branch`
Sucursales físicas de la empresa desde donde se entregan y reciben vehículos.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único de la sucursal |
| name | VARCHAR(150) | NOT NULL | Nombre de la sucursal |
| address | VARCHAR(255) | NOT NULL | Dirección física de la sucursal |
| phone | VARCHAR(20) | | Teléfono de contacto |
| email | VARCHAR(150) | | Correo electrónico de la sucursal |
| schedule | VARCHAR(255) | | Horario de atención |
| latitude | DECIMAL(10,7) | | Latitud geográfica de la sucursal |
| longitude | DECIMAL(10,7) | | Longitud geográfica de la sucursal |
| city_id | UUID | FK → city | Ciudad donde está ubicada la sucursal |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

### `fleet`
Agrupaciones lógicas de vehículos dentro de una sucursal.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único de la flota |
| name | VARCHAR(150) | NOT NULL | Nombre de la flota |
| code | VARCHAR(50) | NOT NULL | Código único identificador de flota |
| description | TEXT | | Descripción de la flota |
| branch_id | UUID | FK → branch | Sucursal a la que pertenece la flota |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

### `vehicle`
Vehículos disponibles en el sistema para ser alquilados por los clientes.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único del vehículo |
| brand | VARCHAR(100) | NOT NULL | Marca del vehículo (ej: Toyota, Renault) |
| model | VARCHAR(100) | NOT NULL | Modelo del vehículo (ej: Corolla, Sandero) |
| year | INT | NOT NULL | Año de fabricación del vehículo |
| plate | VARCHAR(20) | NOT NULL, UNIQUE | Placa de matrícula del vehículo |
| color | VARCHAR(50) | | Color del vehículo |
| fuel_type | VARCHAR(30) | NOT NULL, CHECK | Tipo de combustible (GASOLINE, DIESEL, etc.) |
| transmission | VARCHAR(20) | NOT NULL, CHECK | Tipo de transmisión (MANUAL o AUTOMATIC) |
| capacity | INT | NOT NULL | Número de pasajeros que puede transportar |
| daily_rate | DECIMAL(10,2) | NOT NULL | Tarifa de alquiler por día |
| mileage_current | INT | NOT NULL | Kilometraje actual registrado del vehículo |
| vin | VARCHAR(50) | | Número de identificación vehicular (VIN) |
| vehicle_state | VARCHAR(30) | NOT NULL, CHECK | Estado del vehículo (AVAILABLE, RENTED, etc.) |
| vehicle_category_id | UUID | FK → vehicle_category | Categoría a la que pertenece el vehículo |
| fleet_id | UUID | FK → fleet | Flota a la que pertenece el vehículo |
| branch_id | UUID | FK → branch | Sucursal donde está asignado el vehículo |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

### `vehicle_image`
Imágenes fotográficas asociadas a cada vehículo del catálogo.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único de la imagen |
| image_url | VARCHAR(500) | NOT NULL | URL de acceso a la imagen |
| is_main | BOOLEAN | NOT NULL | Indica si es la imagen principal |
| vehicle_id | UUID | FK → vehicle | Vehículo al que pertenece la imagen |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

### `insurance`
Pólizas de seguro registradas para los vehículos de la flota.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único del seguro |
| name | VARCHAR(100) | NOT NULL | Nombre descriptivo de la póliza |
| policy_number | VARCHAR(100) | NOT NULL | Número único de la póliza de seguro |
| provider | VARCHAR(150) | | Nombre de la aseguradora proveedora |
| coverage_type | VARCHAR(50) | NOT NULL, CHECK | Tipo de cobertura (SOAT, FULL, etc.) |
| expiration_date | DATE | NOT NULL | Fecha de vencimiento de la póliza |
| vehicle_id | UUID | FK → vehicle | Vehículo al que pertenece el seguro |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

### `maintenance`
Registro de trabajos de mantenimiento preventivo o correctivo sobre los vehículos.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único del mantenimiento |
| maintenance_type | VARCHAR(30) | NOT NULL, CHECK | Tipo (PREVENTIVE, CORRECTIVE, URGENT, AESTHETIC) |
| description | TEXT | NOT NULL | Descripción detallada del trabajo a realizar |
| cost | DECIMAL(10,2) | | Costo total del mantenimiento |
| responsible | VARCHAR(150) | | Nombre del técnico o taller responsable |
| scheduled_date | DATE | | Fecha programada para realizar el mantenimiento |
| completed_date | DATE | | Fecha en que se completó el mantenimiento |
| mileage_at_service | INT | | Kilometraje del vehículo al momento del servicio |
| maintenance_state | VARCHAR(20) | NOT NULL, CHECK | Estado del mantenimiento (PENDING, etc.) |
| vehicle_id | UUID | FK → vehicle | Vehículo al que corresponde el mantenimiento |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

### `additional_service`
Servicios opcionales que pueden añadirse a una reserva (GPS, silla bebé, etc.).

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único del servicio |
| name | VARCHAR(150) | NOT NULL | Nombre del servicio adicional |
| description | TEXT | | Descripción del servicio |
| price | DECIMAL(10,2) | NOT NULL | Precio del servicio adicional |
| available | BOOLEAN | NOT NULL | Indica si el servicio está activo |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

### `vehicle_additional_service`
Tabla pivote que asocia servicios adicionales disponibles para cada vehículo.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| vehicle_id | UUID | PK, FK → vehicle | Vehículo al que aplica el servicio |
| additional_service_id | UUID | PK, FK → additional_service | Servicio adicional disponible |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de asociación |
| status_id | UUID | FK → status | Estado actual del registro |

---

## Módulo 4: Clientes y Licencias

### `customer`
Clientes registrados en el sistema que pueden realizar reservas de vehículos.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único del cliente |
| customer_type | VARCHAR(30) | NOT NULL, CHECK | Tipo de cliente (REGULAR, CORPORATE, VIP) |
| person_id | UUID | FK → person | Información personal del cliente |
| user_id | UUID | FK → users | Cuenta de usuario del cliente |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

### `driver_license`
Licencias de conducción registradas y verificadas de los clientes.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único de la licencia |
| license_number | VARCHAR(50) | NOT NULL, UNIQUE | Número de la licencia de conducción |
| license_type | VARCHAR(50) | | Categoría de la licencia (A, B, C, etc.) |
| issue_date | DATE | NOT NULL | Fecha de expedición de la licencia |
| expiration_date | DATE | NOT NULL | Fecha de vencimiento de la licencia |
| front_url | VARCHAR(500) | NOT NULL | URL de la imagen frontal de la licencia |
| back_url | VARCHAR(500) | NOT NULL | URL de la imagen trasera de la licencia |
| review_notes | TEXT | | Notas del revisor durante la validación |
| license_state | VARCHAR(20) | NOT NULL, CHECK | Estado (PENDING, IN_REVIEW, APPROVED, etc.) |
| customer_id | UUID | FK → customer | Cliente propietario de la licencia |
| reviewed_by | UUID | FK → users | Usuario que realizó la revisión |
| reviewed_at | TIMESTAMPTZ | | Fecha y hora en que fue revisada |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

### `customer_favorite`
Vehículos marcados como favoritos por los clientes para consulta rápida.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| customer_id | UUID | PK, FK → customer | Cliente que marcó el favorito |
| vehicle_id | UUID | PK, FK → vehicle | Vehículo marcado como favorito |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora en que se marcó |
| status_id | UUID | FK → status | Estado actual del registro |

---

## Módulo 5: Reservas

### `coverage_plan`
Planes de cobertura de seguro disponibles para incluir en una reserva.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único del plan |
| name | VARCHAR(100) | NOT NULL | Nombre del plan de cobertura |
| description | TEXT | | Descripción de lo que cubre el plan |
| price | DECIMAL(10,2) | NOT NULL | Precio del plan de cobertura |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

### `mileage_plan`
Planes de kilometraje que definen los límites y costos por exceso en una reserva.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único del plan |
| name | VARCHAR(100) | NOT NULL | Nombre del plan de kilometraje |
| mileage_limit | INT | | Límite de kilómetros incluidos |
| excess_rate | DECIMAL(10,2) | | Tarifa por kilómetro excedido |
| is_unlimited | BOOLEAN | NOT NULL | Indica si el kilometraje es ilimitado |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

### `reservation`
Reservas de vehículos realizadas por los clientes con toda la información del alquiler.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único de la reserva |
| reservation_code | VARCHAR(50) | NOT NULL, UNIQUE | Código único legible de la reserva |
| start_date | DATE | NOT NULL | Fecha de inicio del alquiler |
| end_date | DATE | NOT NULL | Fecha de finalización del alquiler |
| pickup_branch_id | UUID | FK → branch | Sucursal de recogida del vehículo |
| return_branch_id | UUID | FK → branch | Sucursal de devolución del vehículo |
| total_days | INT | NOT NULL | Total de días de la reserva |
| daily_rate | DECIMAL(10,2) | NOT NULL | Tarifa diaria aplicada en la reserva |
| mileage_extra_cost | DECIMAL(10,2) | NOT NULL | Costo adicional por exceso de kilometraje |
| services_cost | DECIMAL(10,2) | NOT NULL | Costo total de los servicios adicionales |
| coverage_cost | DECIMAL(10,2) | NOT NULL | Costo del plan de cobertura seleccionado |
| total_amount | DECIMAL(10,2) | NOT NULL | Monto total a pagar por la reserva |
| cancellation_policy | TEXT | | Política de cancelación aplicada |
| reservation_state | VARCHAR(20) | NOT NULL, CHECK | Estado actual de la reserva |
| vehicle_id | UUID | FK → vehicle | Vehículo reservado |
| customer_id | UUID | FK → customer | Cliente que realizó la reserva |
| coverage_plan_id | UUID | FK → coverage_plan | Plan de cobertura seleccionado |
| mileage_plan_id | UUID | FK → mileage_plan | Plan de kilometraje seleccionado |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

### `reservation_additional_service`
Servicios adicionales seleccionados para una reserva específica con su precio.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| reservation_id | UUID | PK, FK → reservation | Reserva a la que aplica el servicio |
| additional_service_id | UUID | PK, FK → additional_service | Servicio adicional contratado |
| unit_price | DECIMAL(10,2) | NOT NULL | Precio unitario del servicio en la reserva |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de asociación |
| status_id | UUID | FK → status | Estado actual del registro |

---

## Módulo 6: Inspecciones

### `vehicle_inspection`
Inspecciones físicas del vehículo realizadas al momento de entrega y devolución.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único de la inspección |
| inspection_type | VARCHAR(20) | NOT NULL, CHECK | Tipo de inspección (PICKUP o RETURN) |
| body_condition | TEXT | | Descripción del estado físico de la carrocería |
| checklist | JSONB | | Lista de ítems inspeccionados en formato JSON |
| initial_mileage | INT | | Kilometraje al momento de la entrega |
| final_mileage | INT | | Kilometraje al momento de la devolución |
| customer_signature | VARCHAR(500) | | URL o datos de la firma digital del cliente |
| signed_at | TIMESTAMPTZ | | Fecha y hora en que el cliente firmó |
| notes | TEXT | | Observaciones adicionales del operador |
| reservation_id | UUID | FK → reservation | Reserva a la que corresponde la inspección |
| operator_id | UUID | FK → users | Operador que realizó la inspección |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

## Módulo 7: Contratos

### `contract`
Contratos de alquiler generados y firmados para cada reserva confirmada.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único del contrato |
| contract_number | VARCHAR(50) | NOT NULL, UNIQUE | Número único legible del contrato |
| content | TEXT | | Contenido textual completo del contrato |
| pdf_url | VARCHAR(500) | | URL del PDF generado del contrato |
| signature_url | VARCHAR(500) | | URL de la firma del cliente |
| signature_type | VARCHAR(20) | CHECK | Tipo de firma (DIGITAL o PHYSICAL) |
| signed_at | TIMESTAMPTZ | | Fecha y hora en que fue firmado |
| contract_state | VARCHAR(20) | NOT NULL, CHECK | Estado del contrato (PENDING, SIGNED, etc.) |
| reservation_id | UUID | FK → reservation | Reserva asociada al contrato (única) |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

## Módulo 8: Pagos

### `payment_method`
Métodos de pago disponibles en el sistema (PSE, tarjeta, efectivo, etc.).

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único del método |
| name | VARCHAR(50) | NOT NULL | Nombre del método de pago |
| provider | VARCHAR(50) | | Proveedor del servicio de pago |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

### `payment`
Registro de transacciones de pago realizadas para las reservas.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único del pago |
| amount_paid | DECIMAL(10,2) | NOT NULL | Monto total pagado en la transacción |
| reference | VARCHAR(100) | | Referencia interna del pago |
| wompi_transaction | VARCHAR(100) | | ID de transacción en la pasarela Wompi |
| payment_state | VARCHAR(20) | NOT NULL, CHECK | Estado del pago (PENDING, APPROVED, etc.) |
| paid_at | TIMESTAMPTZ | | Fecha y hora en que se realizó el pago |
| reservation_id | UUID | FK → reservation | Reserva a la que corresponde el pago |
| payment_method_id | UUID | FK → payment_method | Método de pago utilizado |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

## Módulo 9: Calificaciones y Soporte

### `rating`
Calificaciones dejadas por los clientes al finalizar una reserva.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único de la calificación |
| vehicle_score | INT | NOT NULL, CHECK | Puntuación del vehículo (1 a 5) |
| service_score | INT | NOT NULL, CHECK | Puntuación del servicio recibido (1 a 5) |
| comment | TEXT | | Comentario libre del cliente |
| is_approved | BOOLEAN | NOT NULL | Indica si fue aprobada por moderación |
| moderated_by | UUID | FK → users | Usuario que moderó la calificación |
| moderated_at | TIMESTAMPTZ | | Fecha y hora de la moderación |
| reservation_id | UUID | FK → reservation | Reserva a la que corresponde la calificación |
| customer_id | UUID | FK → customer | Cliente que realizó la calificación |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

### `complaint`
Quejas o reclamos formales registrados por los clientes sobre el servicio.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único de la queja |
| complaint_type | VARCHAR(50) | NOT NULL, CHECK | Tipo de queja (SERVICE, VEHICLE, BILLING, etc.) |
| description | TEXT | NOT NULL | Descripción detallada de la queja |
| admin_response | TEXT | | Respuesta oficial del administrador |
| auto_closed | BOOLEAN | NOT NULL | Indica si fue cerrada automáticamente |
| closed_at | TIMESTAMPTZ | | Fecha y hora en que fue cerrada |
| complaint_state | VARCHAR(20) | NOT NULL, CHECK | Estado de la queja (PENDING, RESOLVED, etc.) |
| customer_id | UUID | FK → customer | Cliente que registró la queja |
| responded_by | UUID | FK → users | Usuario que respondió la queja |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

### `support_ticket`
Tickets de soporte técnico o atención al cliente abiertos por los usuarios.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único del ticket |
| subject | VARCHAR(200) | NOT NULL | Asunto o título del ticket de soporte |
| message | TEXT | NOT NULL | Mensaje inicial enviado por el cliente |
| ticket_state | VARCHAR(20) | NOT NULL, CHECK | Estado del ticket (OPEN, IN_PROGRESS, etc.) |
| agent_response | TEXT | | Respuesta del agente de soporte |
| rating_score | INT | CHECK | Calificación del servicio de soporte (1-5) |
| closed_at | TIMESTAMPTZ | | Fecha y hora en que se cerró el ticket |
| customer_id | UUID | FK → customer | Cliente que abrió el ticket |
| assigned_to | UUID | FK → users | Agente asignado para atender el ticket |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

### `ticket_message`
Mensajes del hilo de conversación dentro de un ticket de soporte.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único del mensaje |
| message | TEXT | NOT NULL | Contenido del mensaje enviado |
| is_agent | BOOLEAN | NOT NULL | Indica si el mensaje fue enviado por el agente |
| ticket_id | UUID | FK → support_ticket | Ticket al que pertenece el mensaje |
| sender_id | UUID | FK → users | Usuario que envió el mensaje |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

## Módulo 10: Notificaciones

### `notification_type`
Tipos de notificación predefinidos con su plantilla de mensaje.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único del tipo |
| name | VARCHAR(100) | NOT NULL | Nombre del tipo de notificación |
| template | TEXT | | Plantilla del mensaje con variables |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

### `notification`
Notificaciones enviadas a los usuarios a través de distintos canales.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único de la notificación |
| channel | VARCHAR(20) | NOT NULL, CHECK | Canal usado (EMAIL, PUSH o SMS) |
| subject | VARCHAR(200) | | Asunto del mensaje (aplica para EMAIL) |
| body | TEXT | NOT NULL | Cuerpo o contenido de la notificación |
| sent | BOOLEAN | NOT NULL | Indica si la notificación fue enviada |
| sent_at | TIMESTAMPTZ | | Fecha y hora en que se envió |
| user_id | UUID | FK → users | Usuario destinatario de la notificación |
| notification_type_id | UUID | FK → notification_type | Tipo de notificación aplicado |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| created_by | UUID | FK → users | Usuario que creó el registro |
| updated_by | UUID | FK → users | Usuario que modificó el registro |
| deleted_by | UUID | FK → users | Usuario que eliminó el registro |
| status_id | UUID | FK → status | Estado actual del registro |

---

## Módulo 11: Auditoría

### `audit_log`
Registro inmutable de todas las acciones realizadas en el sistema para trazabilidad.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único del registro de auditoría |
| action | VARCHAR(100) | NOT NULL | Acción ejecutada (ej: CREATE, UPDATE, DELETE) |
| entity | VARCHAR(100) | NOT NULL | Nombre de la tabla o entidad afectada |
| entity_id | UUID | | ID del registro que fue afectado |
| old_value | JSONB | | Valores anteriores del registro modificado |
| new_value | JSONB | | Valores nuevos del registro modificado |
| ip_address | VARCHAR(50) | | Dirección IP desde donde se ejecutó la acción |
| user_agent | TEXT | | Información del cliente HTTP que hizo la acción |
| endpoint | VARCHAR(255) | | Endpoint de la API que fue invocado |
| result | VARCHAR(20) | NOT NULL, CHECK | Resultado de la acción (SUCCESS o FAILURE) |
| user_id | UUID | FK → users | Usuario que ejecutó la acción |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora en que se registró la acción |

---

## Módulo 12: Marca y Personalización

### `branding_config`
Configuración de identidad visual de la plataforma (colores y logotipos).

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único de la configuración |
| primary_color | VARCHAR(10) | | Color primario de la marca (hex) |
| secondary_color | VARCHAR(10) | | Color secundario de la marca (hex) |
| accent_color | VARCHAR(10) | | Color de acento de la marca (hex) |
| logo_url | VARCHAR(500) | | URL del logotipo en fondo claro |
| logo_dark_url | VARCHAR(500) | | URL del logotipo en fondo oscuro |
| updated_by | UUID | FK → users | Usuario que actualizó la configuración |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| status_id | UUID | FK → status | Estado actual del registro |

---

### `api_token`
Tokens de acceso a la API para integraciones externas o servicios de terceros.

| Campo | Tipo | Restricción | Descripción |
|---|---|---|---|
| id | UUID | PK, NOT NULL | Identificador único del token |
| token | VARCHAR(500) | NOT NULL | Valor del token de autenticación |
| description | VARCHAR(200) | | Descripción del uso o propósito del token |
| expires_at | TIMESTAMPTZ | | Fecha y hora de expiración del token |
| revoked | BOOLEAN | NOT NULL | Indica si el token ha sido revocado |
| created_by | UUID | FK → users | Usuario que generó el token |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Fecha y hora de creación |
| updated_at | TIMESTAMPTZ | | Fecha y hora de última modificación |
| deleted_at | TIMESTAMPTZ | | Fecha de eliminación lógica |
| status_id | UUID | FK → status | Estado actual del registro |