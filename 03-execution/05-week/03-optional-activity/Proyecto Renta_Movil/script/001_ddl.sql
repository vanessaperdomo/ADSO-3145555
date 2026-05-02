-- ==========================================
-- DATABASE: renta_movil
-- ==========================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==========================================
-- MODULE 0: ESTADO GLOBAL
-- ==========================================

CREATE TABLE status ( -- Estado
    id          UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ
);

-- ==========================================
-- MODULE 1: PARÁMETROS
-- Nota: created_by/updated_by/deleted_by sin FK
-- porque users aún no existe en este punto.
-- ==========================================

CREATE TABLE document_type ( -- Tipo de documento
    id          UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        VARCHAR(50) NOT NULL UNIQUE,
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ,
    created_by  UUID,
    updated_by  UUID,
    deleted_by  UUID,
    status_id   UUID        REFERENCES status(id)
);

CREATE TABLE country ( -- País
    id          UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        VARCHAR(100) NOT NULL UNIQUE,
    code        VARCHAR(5)   NOT NULL UNIQUE,
    created_at  TIMESTAMPTZ  DEFAULT NOW(),
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ,
    created_by  UUID,
    updated_by  UUID,
    deleted_by  UUID,
    status_id   UUID         REFERENCES status(id)
);

CREATE TABLE city ( -- Ciudad
    id          UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        VARCHAR(100) NOT NULL,
    country_id  UUID         NOT NULL REFERENCES country(id),
    created_at  TIMESTAMPTZ  DEFAULT NOW(),
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ,
    created_by  UUID,
    updated_by  UUID,
    deleted_by  UUID,
    status_id   UUID         REFERENCES status(id)
);

CREATE TABLE language ( -- Idioma
    id          UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        VARCHAR(50) NOT NULL UNIQUE,
    code        VARCHAR(10) NOT NULL UNIQUE,
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ,
    created_by  UUID,
    updated_by  UUID,
    deleted_by  UUID,
    status_id   UUID        REFERENCES status(id)
);

CREATE TABLE person ( -- Persona
    id               UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    first_name       VARCHAR(100) NOT NULL,
    last_name        VARCHAR(100) NOT NULL,
    document_number  VARCHAR(30)  NOT NULL UNIQUE,
    email            VARCHAR(150) NOT NULL UNIQUE,
    phone            VARCHAR(20),
    birth_date       DATE         NOT NULL,
    nationality      VARCHAR(100),
    document_type_id UUID         NOT NULL REFERENCES document_type(id),
    city_id          UUID         REFERENCES city(id),
    created_at       TIMESTAMPTZ  DEFAULT NOW(),
    updated_at       TIMESTAMPTZ,
    deleted_at       TIMESTAMPTZ,
    created_by       UUID,
    updated_by       UUID,
    deleted_by       UUID,
    status_id        UUID         REFERENCES status(id)
);

CREATE TABLE file ( -- Archivo
    id          UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    file_name   VARCHAR(255) NOT NULL,
    file_url    VARCHAR(500) NOT NULL,
    file_type   VARCHAR(50),
    person_id   UUID         REFERENCES person(id),
    created_at  TIMESTAMPTZ  DEFAULT NOW(),
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ,
    created_by  UUID,
    updated_by  UUID,
    deleted_by  UUID,
    status_id   UUID         REFERENCES status(id)
);

-- ==========================================
-- MODULE 2: SEGURIDAD
-- Desde aquí users existe; todas las FK de auditoría se declaran inline.
-- ==========================================

CREATE TABLE users ( -- Usuarios
    id                 UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    username           VARCHAR(100) NOT NULL UNIQUE,
    password           VARCHAR(255) NOT NULL,
    active             BOOLEAN      NOT NULL DEFAULT TRUE,
    failed_attempts    INT          NOT NULL DEFAULT 0,
    blocked_until      TIMESTAMPTZ,
    last_login         TIMESTAMPTZ,
    two_factor_enabled BOOLEAN      NOT NULL DEFAULT FALSE,
    person_id          UUID         NOT NULL REFERENCES person(id),
    created_at         TIMESTAMPTZ  DEFAULT NOW(),
    updated_at         TIMESTAMPTZ,
    deleted_at         TIMESTAMPTZ,
    created_by         UUID         REFERENCES users(id),
    updated_by         UUID         REFERENCES users(id),
    deleted_by         UUID         REFERENCES users(id),
    status_id          UUID         REFERENCES status(id)
);

CREATE TABLE user_preference ( -- Preferencias del usuario
    id                 UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    theme              VARCHAR(20) NOT NULL DEFAULT 'light'
                           CHECK (theme IN ('light', 'dark')),
    primary_color      VARCHAR(10),
    secondary_color    VARCHAR(10),
    accent_color       VARCHAR(10),
    preferred_language UUID        REFERENCES language(id),
    user_id            UUID        NOT NULL UNIQUE REFERENCES users(id),
    created_at         TIMESTAMPTZ DEFAULT NOW(),
    updated_at         TIMESTAMPTZ,
    deleted_at         TIMESTAMPTZ,
    created_by         UUID        REFERENCES users(id),
    updated_by         UUID        REFERENCES users(id),
    deleted_by         UUID        REFERENCES users(id),
    status_id          UUID        REFERENCES status(id)
);

CREATE TABLE user_session ( -- Sesión de usuario
    id            UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    refresh_token VARCHAR(500) NOT NULL UNIQUE,
    ip_address    VARCHAR(50),
    user_agent    TEXT,
    device        VARCHAR(100),
    expires_at    TIMESTAMPTZ  NOT NULL,
    revoked       BOOLEAN      NOT NULL DEFAULT FALSE,
    revoked_at    TIMESTAMPTZ,
    user_id       UUID         NOT NULL REFERENCES users(id),
    created_at    TIMESTAMPTZ  DEFAULT NOW(),
    updated_at    TIMESTAMPTZ,
    deleted_at    TIMESTAMPTZ,
    status_id     UUID         REFERENCES status(id)
);

CREATE TABLE role ( -- Rol
    id          UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ,
    created_by  UUID        REFERENCES users(id),
    updated_by  UUID        REFERENCES users(id),
    deleted_by  UUID        REFERENCES users(id),
    status_id   UUID        REFERENCES status(id)
);

CREATE TABLE module ( -- Módulo
    id          UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at  TIMESTAMPTZ  DEFAULT NOW(),
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ,
    created_by  UUID         REFERENCES users(id),
    updated_by  UUID         REFERENCES users(id),
    deleted_by  UUID         REFERENCES users(id),
    status_id   UUID         REFERENCES status(id)
);

CREATE TABLE view ( -- Vista
    id          UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        VARCHAR(100) NOT NULL,
    route       VARCHAR(255),
    description TEXT,
    created_at  TIMESTAMPTZ  DEFAULT NOW(),
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ,
    created_by  UUID         REFERENCES users(id),
    updated_by  UUID         REFERENCES users(id),
    deleted_by  UUID         REFERENCES users(id),
    status_id   UUID         REFERENCES status(id)
);

CREATE TABLE user_role ( -- Rol del usuario
    user_id    UUID        NOT NULL REFERENCES users(id),
    role_id    UUID        NOT NULL REFERENCES role(id),
    PRIMARY KEY (user_id, role_id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID        REFERENCES users(id),
    updated_by UUID        REFERENCES users(id),
    deleted_by UUID        REFERENCES users(id),
    status_id  UUID        REFERENCES status(id)
);

CREATE TABLE role_module ( -- Módulo del rol
    role_id    UUID        NOT NULL REFERENCES role(id),
    module_id  UUID        NOT NULL REFERENCES module(id),
    PRIMARY KEY (role_id, module_id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID        REFERENCES users(id),
    updated_by UUID        REFERENCES users(id),
    deleted_by UUID        REFERENCES users(id),
    status_id  UUID        REFERENCES status(id)
);

CREATE TABLE module_view ( -- Vista del módulo
    module_id  UUID        NOT NULL REFERENCES module(id),
    view_id    UUID        NOT NULL REFERENCES view(id),
    PRIMARY KEY (module_id, view_id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID        REFERENCES users(id),
    updated_by UUID        REFERENCES users(id),
    deleted_by UUID        REFERENCES users(id),
    status_id  UUID        REFERENCES status(id)
);

CREATE TABLE password_reset_token ( -- Token de restablecimiento de contraseña
    id         UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    token      VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ  NOT NULL,
    used       BOOLEAN      NOT NULL DEFAULT FALSE,
    user_id    UUID         NOT NULL REFERENCES users(id),
    created_at TIMESTAMPTZ  DEFAULT NOW(),
    status_id  UUID         REFERENCES status(id)
);

CREATE TABLE two_factor_code ( -- Código de doble factor
    id         UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    code       VARCHAR(10) NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    used       BOOLEAN     NOT NULL DEFAULT FALSE,
    user_id    UUID        NOT NULL REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    status_id  UUID        REFERENCES status(id)
);

-- ==========================================
-- MODULE 3: FLOTA Y VEHÍCULOS
-- ==========================================

CREATE TABLE vehicle_category ( -- Categoría de vehículo
    id          UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        VARCHAR(100)  NOT NULL UNIQUE,
    description TEXT,
    base_rate   DECIMAL(10,2) NOT NULL,
    created_at  TIMESTAMPTZ   DEFAULT NOW(),
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ,
    created_by  UUID          REFERENCES users(id),
    updated_by  UUID          REFERENCES users(id),
    deleted_by  UUID          REFERENCES users(id),
    status_id   UUID          REFERENCES status(id)
);

CREATE TABLE branch ( -- Sucursal
    id         UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    name       VARCHAR(150) NOT NULL UNIQUE,
    address    VARCHAR(255) NOT NULL,
    phone      VARCHAR(20),
    email      VARCHAR(150),
    schedule   VARCHAR(255),
    latitude   DECIMAL(10,7),
    longitude  DECIMAL(10,7),
    city_id    UUID         NOT NULL REFERENCES city(id),
    created_at TIMESTAMPTZ  DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID         REFERENCES users(id),
    updated_by UUID         REFERENCES users(id),
    deleted_by UUID         REFERENCES users(id),
    status_id  UUID         REFERENCES status(id)
);

CREATE TABLE fleet ( -- Flota
    id          UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        VARCHAR(150) NOT NULL,
    code        VARCHAR(50)  NOT NULL UNIQUE,
    description TEXT,
    branch_id   UUID         NOT NULL REFERENCES branch(id),
    created_at  TIMESTAMPTZ  DEFAULT NOW(),
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ,
    created_by  UUID         REFERENCES users(id),
    updated_by  UUID         REFERENCES users(id),
    deleted_by  UUID         REFERENCES users(id),
    status_id   UUID         REFERENCES status(id)
);

CREATE TABLE vehicle ( -- Vehículo
    id                  UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
    brand               VARCHAR(100)  NOT NULL,
    model               VARCHAR(100)  NOT NULL,
    year                INT           NOT NULL,
    plate               VARCHAR(20)   NOT NULL UNIQUE,
    color               VARCHAR(50),
    fuel_type           VARCHAR(30)   NOT NULL CHECK (fuel_type IN ('GASOLINE','DIESEL','ELECTRIC','HYBRID')),
    transmission        VARCHAR(20)   NOT NULL CHECK (transmission IN ('MANUAL','AUTOMATIC')),
    capacity            INT           NOT NULL,
    daily_rate          DECIMAL(10,2) NOT NULL,
    mileage_current     INT           NOT NULL DEFAULT 0,
    vin                 VARCHAR(50),
    vehicle_state       VARCHAR(30)   NOT NULL DEFAULT 'AVAILABLE'
                            CHECK (vehicle_state IN ('AVAILABLE','RENTED','MAINTENANCE','INACTIVE')),
    vehicle_category_id UUID          NOT NULL REFERENCES vehicle_category(id),
    fleet_id            UUID          REFERENCES fleet(id),
    branch_id           UUID          NOT NULL REFERENCES branch(id),
    created_at          TIMESTAMPTZ   DEFAULT NOW(),
    updated_at          TIMESTAMPTZ,
    deleted_at          TIMESTAMPTZ,
    created_by          UUID          REFERENCES users(id),
    updated_by          UUID          REFERENCES users(id),
    deleted_by          UUID          REFERENCES users(id),
    status_id           UUID          REFERENCES status(id)
);

CREATE TABLE vehicle_image ( -- Imagen del vehículo
    id         UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    image_url  VARCHAR(500) NOT NULL,
    is_main    BOOLEAN      NOT NULL DEFAULT FALSE,
    vehicle_id UUID         NOT NULL REFERENCES vehicle(id),
    created_at TIMESTAMPTZ  DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID         REFERENCES users(id),
    updated_by UUID         REFERENCES users(id),
    deleted_by UUID         REFERENCES users(id),
    status_id  UUID         REFERENCES status(id)
);

CREATE TABLE insurance ( -- Seguro
    id              UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            VARCHAR(100) NOT NULL,
    policy_number   VARCHAR(100) NOT NULL UNIQUE,
    provider        VARCHAR(150),
    coverage_type   VARCHAR(50)  NOT NULL CHECK (coverage_type IN ('SOAT','FULL','ADDITIONAL')),
    expiration_date DATE         NOT NULL,
    vehicle_id      UUID         NOT NULL REFERENCES vehicle(id),
    created_at      TIMESTAMPTZ  DEFAULT NOW(),
    updated_at      TIMESTAMPTZ,
    deleted_at      TIMESTAMPTZ,
    created_by      UUID         REFERENCES users(id),
    updated_by      UUID         REFERENCES users(id),
    deleted_by      UUID         REFERENCES users(id),
    status_id       UUID         REFERENCES status(id)
);

CREATE TABLE maintenance ( -- Mantenimiento
    id                 UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
    maintenance_type   VARCHAR(30)   NOT NULL CHECK (maintenance_type IN ('PREVENTIVE','CORRECTIVE','URGENT','AESTHETIC')),
    description        TEXT          NOT NULL,
    cost               DECIMAL(10,2),
    responsible        VARCHAR(150),
    scheduled_date     DATE,
    completed_date     DATE,
    mileage_at_service INT,
    maintenance_state  VARCHAR(20)   NOT NULL DEFAULT 'PENDING'
                           CHECK (maintenance_state IN ('PENDING','IN_PROGRESS','COMPLETED')),
    vehicle_id         UUID          NOT NULL REFERENCES vehicle(id),
    created_at         TIMESTAMPTZ   DEFAULT NOW(),
    updated_at         TIMESTAMPTZ,
    deleted_at         TIMESTAMPTZ,
    created_by         UUID          NOT NULL REFERENCES users(id),
    updated_by         UUID          REFERENCES users(id),
    deleted_by         UUID          REFERENCES users(id),
    status_id          UUID          REFERENCES status(id)
);

CREATE TABLE maintenance_file ( -- Archivo de mantenimiento
    id             UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    file_url       VARCHAR(500) NOT NULL,
    file_type      VARCHAR(50),
    maintenance_id UUID         NOT NULL REFERENCES maintenance(id),
    created_at     TIMESTAMPTZ  DEFAULT NOW(),
    updated_at     TIMESTAMPTZ,
    deleted_at     TIMESTAMPTZ,
    created_by     UUID         REFERENCES users(id),
    updated_by     UUID         REFERENCES users(id),
    deleted_by     UUID         REFERENCES users(id),
    status_id      UUID         REFERENCES status(id)
);

CREATE TABLE additional_service ( -- Servicio adicional
    id          UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        VARCHAR(150)  NOT NULL,
    description TEXT,
    price       DECIMAL(10,2) NOT NULL,
    available   BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ   DEFAULT NOW(),
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ,
    created_by  UUID          REFERENCES users(id),
    updated_by  UUID          REFERENCES users(id),
    deleted_by  UUID          REFERENCES users(id),
    status_id   UUID          REFERENCES status(id)
);

CREATE TABLE vehicle_additional_service ( -- Servicio adicional del vehículo
    vehicle_id            UUID NOT NULL REFERENCES vehicle(id),
    additional_service_id UUID NOT NULL REFERENCES additional_service(id),
    PRIMARY KEY (vehicle_id, additional_service_id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    status_id  UUID        REFERENCES status(id)
);

-- ==========================================
-- MODULE 4: CLIENTES Y VALIDACIÓN DE LICENCIA
-- ==========================================

CREATE TABLE customer_type ( -- Tipo de cliente
    id         UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    name       VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID        REFERENCES users(id),
    updated_by UUID        REFERENCES users(id),
    deleted_by UUID        REFERENCES users(id),
    status_id  UUID        REFERENCES status(id)
);

CREATE TABLE customer ( -- Cliente
    id               UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    person_id        UUID        NOT NULL REFERENCES person(id),
    user_id          UUID        NOT NULL REFERENCES users(id),
    customer_type_id UUID        NOT NULL REFERENCES customer_type(id),
    created_at       TIMESTAMPTZ DEFAULT NOW(),
    updated_at       TIMESTAMPTZ,
    deleted_at       TIMESTAMPTZ,
    created_by       UUID        REFERENCES users(id),
    updated_by       UUID        REFERENCES users(id),
    deleted_by       UUID        REFERENCES users(id),
    status_id        UUID        REFERENCES status(id)
);

CREATE TABLE driver_license ( -- Licencia de conducción
    id              UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    license_number  VARCHAR(50)  NOT NULL UNIQUE,
    license_type    VARCHAR(50),
    issue_date      DATE         NOT NULL,
    expiration_date DATE         NOT NULL,
    front_url       VARCHAR(500) NOT NULL,
    back_url        VARCHAR(500) NOT NULL,
    review_notes    TEXT,
    license_state   VARCHAR(20)  NOT NULL DEFAULT 'PENDING'
                        CHECK (license_state IN ('PENDING','IN_REVIEW','APPROVED','REJECTED')),
    customer_id     UUID         NOT NULL REFERENCES customer(id),
    reviewed_by     UUID         REFERENCES users(id),
    reviewed_at     TIMESTAMPTZ,
    created_at      TIMESTAMPTZ  DEFAULT NOW(),
    updated_at      TIMESTAMPTZ,
    deleted_at      TIMESTAMPTZ,
    created_by      UUID         REFERENCES users(id),
    updated_by      UUID         REFERENCES users(id),
    deleted_by      UUID         REFERENCES users(id),
    status_id       UUID         REFERENCES status(id)
);

CREATE TABLE customer_favorite ( -- Vehículo favorito del cliente
    customer_id UUID NOT NULL REFERENCES customer(id),
    vehicle_id  UUID NOT NULL REFERENCES vehicle(id),
    PRIMARY KEY (customer_id, vehicle_id),
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    status_id   UUID        REFERENCES status(id)
);

-- ==========================================
-- MODULE 5: RESERVAS
-- ==========================================

CREATE TABLE coverage_plan ( -- Plan de cobertura
    id          UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        VARCHAR(100)  NOT NULL UNIQUE,
    description TEXT,
    price       DECIMAL(10,2) NOT NULL,
    created_at  TIMESTAMPTZ   DEFAULT NOW(),
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ,
    created_by  UUID          REFERENCES users(id),
    updated_by  UUID          REFERENCES users(id),
    deleted_by  UUID          REFERENCES users(id),
    status_id   UUID          REFERENCES status(id)
);

CREATE TABLE mileage_plan ( -- Plan de kilometraje
    id            UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
    name          VARCHAR(100)  NOT NULL UNIQUE,
    mileage_limit INT,
    excess_rate   DECIMAL(10,2),
    is_unlimited  BOOLEAN       NOT NULL DEFAULT FALSE,
    created_at    TIMESTAMPTZ   DEFAULT NOW(),
    updated_at    TIMESTAMPTZ,
    deleted_at    TIMESTAMPTZ,
    created_by    UUID          REFERENCES users(id),
    updated_by    UUID          REFERENCES users(id),
    deleted_by    UUID          REFERENCES users(id),
    status_id     UUID          REFERENCES status(id)
);

CREATE TABLE reservation_status ( -- Estado de la reserva
    id         UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    name       VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID        REFERENCES users(id),
    updated_by UUID        REFERENCES users(id),
    deleted_by UUID        REFERENCES users(id),
    status_id  UUID        REFERENCES status(id)
);

CREATE TABLE reservation ( -- Reserva
    id                    UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
    reservation_code      VARCHAR(50)   NOT NULL UNIQUE,
    start_date            DATE          NOT NULL,
    end_date              DATE          NOT NULL,
    pickup_branch_id      UUID          NOT NULL REFERENCES branch(id),
    total_days            INT           NOT NULL,
    daily_rate            DECIMAL(10,2) NOT NULL,
    mileage_extra_cost    DECIMAL(10,2) NOT NULL DEFAULT 0,
    services_cost         DECIMAL(10,2) NOT NULL DEFAULT 0,
    coverage_cost         DECIMAL(10,2) NOT NULL DEFAULT 0,
    total_amount          DECIMAL(10,2) NOT NULL,
    cancellation_policy   TEXT,
    vehicle_id            UUID          NOT NULL REFERENCES vehicle(id),
    customer_id           UUID          NOT NULL REFERENCES customer(id),
    coverage_plan_id      UUID          REFERENCES coverage_plan(id),
    mileage_plan_id       UUID          REFERENCES mileage_plan(id),
    reservation_status_id UUID          NOT NULL REFERENCES reservation_status(id),
    created_at            TIMESTAMPTZ   DEFAULT NOW(),
    updated_at            TIMESTAMPTZ,
    deleted_at            TIMESTAMPTZ,
    created_by            UUID          REFERENCES users(id),
    updated_by            UUID          REFERENCES users(id),
    deleted_by            UUID          REFERENCES users(id),
    status_id             UUID          REFERENCES status(id)
);

CREATE TABLE reservation_additional_service ( -- Servicio adicional de la reserva
    reservation_id        UUID          NOT NULL REFERENCES reservation(id),
    additional_service_id UUID          NOT NULL REFERENCES additional_service(id),
    PRIMARY KEY (reservation_id, additional_service_id),
    unit_price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMPTZ   DEFAULT NOW(),
    status_id  UUID          REFERENCES status(id)
);

-- ==========================================
-- MODULE 6: INSPECCIONES
-- ==========================================

CREATE TABLE vehicle_inspection ( -- Inspección del vehículo
    id                 UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    inspection_type    VARCHAR(20)  NOT NULL CHECK (inspection_type IN ('PICKUP','RETURN')),
    body_condition     TEXT,
    checklist          JSONB,
    initial_mileage    INT,
    final_mileage      INT,
    customer_signature VARCHAR(500),
    signed_at          TIMESTAMPTZ,
    notes              TEXT,
    reservation_id     UUID         NOT NULL REFERENCES reservation(id),
    operator_id        UUID         NOT NULL REFERENCES users(id),
    created_at         TIMESTAMPTZ  DEFAULT NOW(),
    updated_at         TIMESTAMPTZ,
    deleted_at         TIMESTAMPTZ,
    created_by         UUID         REFERENCES users(id),
    updated_by         UUID         REFERENCES users(id),
    deleted_by         UUID         REFERENCES users(id),
    status_id          UUID         REFERENCES status(id)
);

-- ==========================================
-- MODULE 7: CONTRATOS
-- ==========================================

CREATE TABLE contract ( -- Contrato
    id              UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    contract_number VARCHAR(50)  NOT NULL UNIQUE,
    content         TEXT,
    pdf_url         VARCHAR(500),
    signature_url   VARCHAR(500),
    signature_type  VARCHAR(20)  CHECK (signature_type IN ('DIGITAL','PHYSICAL')),
    signed_at       TIMESTAMPTZ,
    contract_state  VARCHAR(20)  NOT NULL DEFAULT 'PENDING'
                        CHECK (contract_state IN ('PENDING','SIGNED','CANCELLED')),
    reservation_id  UUID         NOT NULL REFERENCES reservation(id),
    created_at      TIMESTAMPTZ  DEFAULT NOW(),
    updated_at      TIMESTAMPTZ,
    deleted_at      TIMESTAMPTZ,
    created_by      UUID         REFERENCES users(id),
    updated_by      UUID         REFERENCES users(id),
    deleted_by      UUID         REFERENCES users(id),
    status_id       UUID         REFERENCES status(id)
);

-- ==========================================
-- MODULE 8: PAGOS
-- ==========================================

CREATE TABLE payment_method ( -- Método de pago
    id         UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    name       VARCHAR(50) NOT NULL UNIQUE,
    provider   VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID        REFERENCES users(id),
    updated_by UUID        REFERENCES users(id),
    deleted_by UUID        REFERENCES users(id),
    status_id  UUID        REFERENCES status(id)
);

CREATE TABLE payment ( -- Pago
    id                UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
    amount_paid       DECIMAL(10,2) NOT NULL,
    reference         VARCHAR(100),
    wompi_transaction VARCHAR(100),
    payment_state     VARCHAR(20)   NOT NULL DEFAULT 'PENDING'
                          CHECK (payment_state IN ('PENDING','APPROVED','REJECTED','CANCELLED')),
    paid_at           TIMESTAMPTZ,
    reservation_id    UUID          NOT NULL REFERENCES reservation(id),
    payment_method_id UUID          NOT NULL REFERENCES payment_method(id),
    created_at        TIMESTAMPTZ   DEFAULT NOW(),
    updated_at        TIMESTAMPTZ,
    deleted_at        TIMESTAMPTZ,
    created_by        UUID          REFERENCES users(id),
    updated_by        UUID          REFERENCES users(id),
    deleted_by        UUID          REFERENCES users(id),
    status_id         UUID          REFERENCES status(id)
);

-- ==========================================
-- MODULE 9: CALIFICACIONES Y SOPORTE
-- ==========================================

CREATE TABLE rating ( -- Calificación
    id             UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    vehicle_score  INT         NOT NULL CHECK (vehicle_score BETWEEN 1 AND 5),
    service_score  INT         NOT NULL CHECK (service_score BETWEEN 1 AND 5),
    comment        TEXT,
    is_approved    BOOLEAN     NOT NULL DEFAULT FALSE,
    moderated_by   UUID        REFERENCES users(id),
    moderated_at   TIMESTAMPTZ,
    reservation_id UUID        NOT NULL UNIQUE REFERENCES reservation(id),
    customer_id    UUID        NOT NULL REFERENCES customer(id),
    created_at     TIMESTAMPTZ DEFAULT NOW(),
    updated_at     TIMESTAMPTZ,
    deleted_at     TIMESTAMPTZ,
    created_by     UUID        REFERENCES users(id),
    updated_by     UUID        REFERENCES users(id),
    deleted_by     UUID        REFERENCES users(id),
    status_id      UUID        REFERENCES status(id)
);

CREATE TABLE complaint_type ( -- Tipo de queja
    id         UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    name       VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID        REFERENCES users(id),
    updated_by UUID        REFERENCES users(id),
    deleted_by UUID        REFERENCES users(id),
    status_id  UUID        REFERENCES status(id)
);

CREATE TABLE complaint ( -- Queja
    id                UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    description       TEXT        NOT NULL,
    admin_response    TEXT,
    auto_closed       BOOLEAN     NOT NULL DEFAULT FALSE,
    closed_at         TIMESTAMPTZ,
    complaint_state   VARCHAR(20) NOT NULL DEFAULT 'PENDING'
                          CHECK (complaint_state IN ('PENDING','IN_REVIEW','RESOLVED','CLOSED')),
    customer_id       UUID        NOT NULL REFERENCES customer(id),
    complaint_type_id UUID        NOT NULL REFERENCES complaint_type(id),
    responded_by      UUID        REFERENCES users(id),
    created_at        TIMESTAMPTZ DEFAULT NOW(),
    updated_at        TIMESTAMPTZ,
    deleted_at        TIMESTAMPTZ,
    created_by        UUID        REFERENCES users(id),
    updated_by        UUID        REFERENCES users(id),
    deleted_by        UUID        REFERENCES users(id),
    status_id         UUID        REFERENCES status(id)
);

CREATE TABLE complaint_file ( -- Archivo de queja
    id           UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    file_url     VARCHAR(500) NOT NULL,
    file_type    VARCHAR(50),
    complaint_id UUID         NOT NULL REFERENCES complaint(id),
    created_at   TIMESTAMPTZ  DEFAULT NOW(),
    updated_at   TIMESTAMPTZ,
    deleted_at   TIMESTAMPTZ,
    created_by   UUID         REFERENCES users(id),
    updated_by   UUID         REFERENCES users(id),
    deleted_by   UUID         REFERENCES users(id),
    status_id    UUID         REFERENCES status(id)
);

CREATE TABLE support_ticket ( -- Ticket de soporte
    id             UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    subject        VARCHAR(200) NOT NULL,
    message        TEXT         NOT NULL,
    ticket_state   VARCHAR(20)  NOT NULL DEFAULT 'OPEN'
                       CHECK (ticket_state IN ('OPEN','IN_PROGRESS','CLOSED')),
    agent_response TEXT,
    rating_score   INT          CHECK (rating_score BETWEEN 1 AND 5),
    closed_at      TIMESTAMPTZ,
    customer_id    UUID         NOT NULL REFERENCES customer(id),
    assigned_to    UUID         REFERENCES users(id),
    created_at     TIMESTAMPTZ  DEFAULT NOW(),
    updated_at     TIMESTAMPTZ,
    deleted_at     TIMESTAMPTZ,
    created_by     UUID         REFERENCES users(id),
    updated_by     UUID         REFERENCES users(id),
    deleted_by     UUID         REFERENCES users(id),
    status_id      UUID         REFERENCES status(id)
);

CREATE TABLE ticket_message ( -- Mensaje del ticket
    id         UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    message    TEXT        NOT NULL,
    is_agent   BOOLEAN     NOT NULL DEFAULT FALSE,
    ticket_id  UUID        NOT NULL REFERENCES support_ticket(id),
    sender_id  UUID        NOT NULL REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID        REFERENCES users(id),
    updated_by UUID        REFERENCES users(id),
    deleted_by UUID        REFERENCES users(id),
    status_id  UUID        REFERENCES status(id)
);

-- ==========================================
-- MODULE 10: NOTIFICACIONES
-- ==========================================

CREATE TABLE notification_type ( -- Tipo de notificación
    id         UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    name       VARCHAR(100) NOT NULL UNIQUE,
    template   TEXT,
    created_at TIMESTAMPTZ  DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID         REFERENCES users(id),
    updated_by UUID         REFERENCES users(id),
    deleted_by UUID         REFERENCES users(id),
    status_id  UUID         REFERENCES status(id)
);

CREATE TABLE notification ( -- Notificación
    id                   UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    channel              VARCHAR(20)  NOT NULL CHECK (channel IN ('EMAIL','PUSH','SMS')),
    subject              VARCHAR(200),
    body                 TEXT         NOT NULL,
    sent                 BOOLEAN      NOT NULL DEFAULT FALSE,
    sent_at              TIMESTAMPTZ,
    user_id              UUID         NOT NULL REFERENCES users(id),
    notification_type_id UUID         NOT NULL REFERENCES notification_type(id),
    created_at           TIMESTAMPTZ  DEFAULT NOW(),
    updated_at           TIMESTAMPTZ,
    deleted_at           TIMESTAMPTZ,
    created_by           UUID         REFERENCES users(id),
    updated_by           UUID         REFERENCES users(id),
    deleted_by           UUID         REFERENCES users(id),
    status_id            UUID         REFERENCES status(id)
);

-- ==========================================
-- MODULE 11: AUDITORÍA
-- ==========================================

CREATE TABLE audit_log ( -- Registro de auditoría
    id         UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    action     VARCHAR(100) NOT NULL,
    entity     VARCHAR(100) NOT NULL,
    entity_id  UUID,
    old_value  JSONB,
    new_value  JSONB,
    ip_address VARCHAR(50),
    user_agent TEXT,
    endpoint   VARCHAR(255),
    result     VARCHAR(20)  NOT NULL CHECK (result IN ('SUCCESS','FAILURE')),
    user_id    UUID         REFERENCES users(id),
    created_at TIMESTAMPTZ  DEFAULT NOW()
);

-- ==========================================
-- MODULE 12: MARCA Y PERSONALIZACIÓN
-- ==========================================

CREATE TABLE branding_config ( -- Configuración de marca
    id              UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    primary_color   VARCHAR(10),
    secondary_color VARCHAR(10),
    accent_color    VARCHAR(10),
    logo_url        VARCHAR(500),
    logo_dark_url   VARCHAR(500),
    updated_by      UUID         REFERENCES users(id),
    created_at      TIMESTAMPTZ  DEFAULT NOW(),
    updated_at      TIMESTAMPTZ,
    status_id       UUID         REFERENCES status(id)
);

CREATE TABLE api_token ( -- Token de API
    id          UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    token       VARCHAR(500) NOT NULL UNIQUE,
    description VARCHAR(200),
    expires_at  TIMESTAMPTZ,
    revoked     BOOLEAN      NOT NULL DEFAULT FALSE,
    created_by  UUID         NOT NULL REFERENCES users(id),
    created_at  TIMESTAMPTZ  DEFAULT NOW(),
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ,
    status_id   UUID         REFERENCES status(id)
);