-- ==========================================
-- DATABASE: renta_movil
-- ==========================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==========================================
-- MODULE 0: ESTADO GLOBAL
-- Tabla central de estados reutilizada por todos los módulos
-- ==========================================

CREATE TABLE status (
    id          UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ
);

-- ==========================================
-- MODULE 1: PARÁMETROS BASE
-- ==========================================

CREATE TABLE document_type (
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

CREATE TABLE country (
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

CREATE TABLE city (
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

CREATE TABLE language (
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

CREATE TABLE person (
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

-- ==========================================
-- Tabla FILE polimórfica: centraliza todos los archivos del sistema
-- Reemplaza maintenance_file y complaint_file
-- entity_type indica a qué tabla pertenece el archivo
-- entity_id referencia el registro específico
-- ==========================================

CREATE TABLE file (
    id          UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    file_name   VARCHAR(255) NOT NULL,
    file_url    VARCHAR(500) NOT NULL,
    file_type   VARCHAR(50),
    entity_type VARCHAR(50)  NOT NULL CHECK (entity_type IN ('PERSON','MAINTENANCE','COMPLAINT','VEHICLE','CONTRACT','DRIVER_LICENSE')),
    entity_id   UUID         NOT NULL,
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
-- ==========================================

CREATE TABLE users (
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

-- Ahora que users existe, agregamos las FK de auditoría en las tablas anteriores
ALTER TABLE document_type ADD CONSTRAINT fk_doctype_created_by FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE document_type ADD CONSTRAINT fk_doctype_updated_by FOREIGN KEY (updated_by) REFERENCES users(id);
ALTER TABLE document_type ADD CONSTRAINT fk_doctype_deleted_by FOREIGN KEY (deleted_by) REFERENCES users(id);

ALTER TABLE country ADD CONSTRAINT fk_country_created_by FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE country ADD CONSTRAINT fk_country_updated_by FOREIGN KEY (updated_by) REFERENCES users(id);
ALTER TABLE country ADD CONSTRAINT fk_country_deleted_by FOREIGN KEY (deleted_by) REFERENCES users(id);

ALTER TABLE city ADD CONSTRAINT fk_city_created_by FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE city ADD CONSTRAINT fk_city_updated_by FOREIGN KEY (updated_by) REFERENCES users(id);
ALTER TABLE city ADD CONSTRAINT fk_city_deleted_by FOREIGN KEY (deleted_by) REFERENCES users(id);

ALTER TABLE language ADD CONSTRAINT fk_language_created_by FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE language ADD CONSTRAINT fk_language_updated_by FOREIGN KEY (updated_by) REFERENCES users(id);
ALTER TABLE language ADD CONSTRAINT fk_language_deleted_by FOREIGN KEY (deleted_by) REFERENCES users(id);

ALTER TABLE person ADD CONSTRAINT fk_person_created_by FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE person ADD CONSTRAINT fk_person_updated_by FOREIGN KEY (updated_by) REFERENCES users(id);
ALTER TABLE person ADD CONSTRAINT fk_person_deleted_by FOREIGN KEY (deleted_by) REFERENCES users(id);

ALTER TABLE file ADD CONSTRAINT fk_file_created_by FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE file ADD CONSTRAINT fk_file_updated_by FOREIGN KEY (updated_by) REFERENCES users(id);
ALTER TABLE file ADD CONSTRAINT fk_file_deleted_by FOREIGN KEY (deleted_by) REFERENCES users(id);

CREATE TABLE user_preference (
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

CREATE TABLE user_session (
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

CREATE TABLE role (
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

CREATE TABLE module (
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

CREATE TABLE view (
    id          UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        VARCHAR(100) NOT NULL,
    route       VARCHAR(255),
    description TEXT,
    module_id   UUID         NOT NULL REFERENCES module(id),  -- FK directa: toda vista pertenece a un módulo
    created_at  TIMESTAMPTZ  DEFAULT NOW(),
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ,
    created_by  UUID         REFERENCES users(id),
    updated_by  UUID         REFERENCES users(id),
    deleted_by  UUID         REFERENCES users(id),
    status_id   UUID         REFERENCES status(id)
);

-- NOTA: Se elimina module_view como tabla pivote.
-- La relación view→module ahora es directa (module_id en view).
-- Una vista pertenece a un solo módulo, lo cual es la regla de negocio correcta.

CREATE TABLE user_role (
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

CREATE TABLE role_module (
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

CREATE TABLE password_reset_token (
    id         UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    token      VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ  NOT NULL,
    used       BOOLEAN      NOT NULL DEFAULT FALSE,
    user_id    UUID         NOT NULL REFERENCES users(id),
    created_at TIMESTAMPTZ  DEFAULT NOW(),
    status_id  UUID         REFERENCES status(id)
);

CREATE TABLE two_factor_code (
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

CREATE TABLE vehicle_category (
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

CREATE TABLE branch (
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

CREATE TABLE fleet (
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

CREATE TABLE vehicle (
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

CREATE TABLE vehicle_image (
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

CREATE TABLE insurance (
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

CREATE TABLE maintenance (
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

-- NOTA: maintenance_file y complaint_file fueron eliminadas.
-- Sus archivos ahora se almacenan en la tabla FILE con entity_type = 'MAINTENANCE' o 'COMPLAINT'.

CREATE TABLE additional_service (
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

CREATE TABLE vehicle_additional_service (
    vehicle_id            UUID NOT NULL REFERENCES vehicle(id),
    additional_service_id UUID NOT NULL REFERENCES additional_service(id),
    PRIMARY KEY (vehicle_id, additional_service_id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    status_id  UUID        REFERENCES status(id)
);

-- ==========================================
-- MODULE 4: CLIENTES Y LICENCIAS
-- customer_type eliminada: el tipo se maneja con CHECK en customer
-- ==========================================

CREATE TABLE customer (
    id               UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_type    VARCHAR(30) NOT NULL DEFAULT 'REGULAR'
                         CHECK (customer_type IN ('REGULAR','CORPORATE','VIP')),
    person_id        UUID        NOT NULL REFERENCES person(id),
    user_id          UUID        NOT NULL REFERENCES users(id),
    created_at       TIMESTAMPTZ DEFAULT NOW(),
    updated_at       TIMESTAMPTZ,
    deleted_at       TIMESTAMPTZ,
    created_by       UUID        REFERENCES users(id),
    updated_by       UUID        REFERENCES users(id),
    deleted_by       UUID        REFERENCES users(id),
    status_id        UUID        REFERENCES status(id)
);

CREATE TABLE driver_license (
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

CREATE TABLE customer_favorite (
    customer_id UUID NOT NULL REFERENCES customer(id),
    vehicle_id  UUID NOT NULL REFERENCES vehicle(id),
    PRIMARY KEY (customer_id, vehicle_id),
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    status_id   UUID        REFERENCES status(id)
);

-- ==========================================
-- MODULE 5: RESERVAS
-- ==========================================

CREATE TABLE coverage_plan (
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

CREATE TABLE mileage_plan (
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

-- NOTA: reservation_status eliminada como tabla.
-- El estado de la reserva se maneja con CHECK constraint (más simple, misma función).

CREATE TABLE reservation (
    id                    UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
    reservation_code      VARCHAR(50)   NOT NULL UNIQUE,
    start_date            DATE          NOT NULL,
    end_date              DATE          NOT NULL,
    pickup_branch_id      UUID          NOT NULL REFERENCES branch(id),
    return_branch_id      UUID          NOT NULL REFERENCES branch(id),   -- NUEVO: sucursal de devolución
    total_days            INT           NOT NULL,
    daily_rate            DECIMAL(10,2) NOT NULL,
    mileage_extra_cost    DECIMAL(10,2) NOT NULL DEFAULT 0,
    services_cost         DECIMAL(10,2) NOT NULL DEFAULT 0,
    coverage_cost         DECIMAL(10,2) NOT NULL DEFAULT 0,
    total_amount          DECIMAL(10,2) NOT NULL,
    cancellation_policy   TEXT,
    reservation_state     VARCHAR(20)   NOT NULL DEFAULT 'PENDING'
                              CHECK (reservation_state IN ('PENDING','CONFIRMED','ACTIVE','COMPLETED','CANCELLED','NO_SHOW')),
    vehicle_id            UUID          NOT NULL REFERENCES vehicle(id),
    customer_id           UUID          NOT NULL REFERENCES customer(id),
    coverage_plan_id      UUID          REFERENCES coverage_plan(id),
    mileage_plan_id       UUID          REFERENCES mileage_plan(id),
    created_at            TIMESTAMPTZ   DEFAULT NOW(),
    updated_at            TIMESTAMPTZ,
    deleted_at            TIMESTAMPTZ,
    created_by            UUID          REFERENCES users(id),
    updated_by            UUID          REFERENCES users(id),
    deleted_by            UUID          REFERENCES users(id),
    status_id             UUID          REFERENCES status(id)
);

CREATE TABLE reservation_additional_service (
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

CREATE TABLE vehicle_inspection (
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

CREATE TABLE contract (
    id              UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    contract_number VARCHAR(50)  NOT NULL UNIQUE,
    content         TEXT,
    pdf_url         VARCHAR(500),
    signature_url   VARCHAR(500),
    signature_type  VARCHAR(20)  CHECK (signature_type IN ('DIGITAL','PHYSICAL')),
    signed_at       TIMESTAMPTZ,
    contract_state  VARCHAR(20)  NOT NULL DEFAULT 'PENDING'
                        CHECK (contract_state IN ('PENDING','SIGNED','CANCELLED')),
    reservation_id  UUID         NOT NULL UNIQUE REFERENCES reservation(id),  -- UNIQUE: una reserva = un contrato
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

CREATE TABLE payment_method (
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

CREATE TABLE payment (
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
-- complaint_type eliminada: el tipo se maneja con CHECK en complaint
-- ==========================================

CREATE TABLE rating (
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

CREATE TABLE complaint (
    id               UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    complaint_type   VARCHAR(50) NOT NULL DEFAULT 'SERVICE'
                         CHECK (complaint_type IN ('SERVICE','VEHICLE','BILLING','OTHER')),
    description      TEXT        NOT NULL,
    admin_response   TEXT,
    auto_closed      BOOLEAN     NOT NULL DEFAULT FALSE,
    closed_at        TIMESTAMPTZ,
    complaint_state  VARCHAR(20) NOT NULL DEFAULT 'PENDING'
                         CHECK (complaint_state IN ('PENDING','IN_REVIEW','RESOLVED','CLOSED')),
    customer_id      UUID        NOT NULL REFERENCES customer(id),
    responded_by     UUID        REFERENCES users(id),
    created_at       TIMESTAMPTZ DEFAULT NOW(),
    updated_at       TIMESTAMPTZ,
    deleted_at       TIMESTAMPTZ,
    created_by       UUID        REFERENCES users(id),
    updated_by       UUID        REFERENCES users(id),
    deleted_by       UUID        REFERENCES users(id),
    status_id        UUID        REFERENCES status(id)
);

CREATE TABLE support_ticket (
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

CREATE TABLE ticket_message (
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

CREATE TABLE notification_type (
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

CREATE TABLE notification (
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

CREATE TABLE audit_log (
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

CREATE TABLE branding_config (
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

CREATE TABLE api_token (
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