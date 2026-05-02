-- ==========================================
-- BASE DE DATOS: coffee-shop
-- ==========================================
-- Elimina o comenta estas 3 líneas:
-- DROP DATABASE IF EXISTS "coffee-shop";
-- CREATE DATABASE "coffee-shop";
-- \c "coffee-shop";

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==========================================
-- MÓDULO 0: STATUS GLOBAL
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
-- MÓDULO 1: PARAMETER
-- Nota: created_by/updated_by/deleted_by van sin FK
-- porque users aún no existe en este punto.
-- ==========================================

CREATE TABLE type_document (
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

CREATE TABLE academic_program (
    id           UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    program_name VARCHAR(150) NOT NULL UNIQUE,
    created_at   TIMESTAMPTZ  DEFAULT NOW(),
    updated_at   TIMESTAMPTZ,
    deleted_at   TIMESTAMPTZ,
    created_by   UUID,
    updated_by   UUID,
    deleted_by   UUID,
    status_id    UUID         REFERENCES status(id)
);

CREATE TABLE study_group (
    id                  UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    group_code          VARCHAR(50) NOT NULL UNIQUE,
    academic_program_id UUID        NOT NULL REFERENCES academic_program(id),
    created_at          TIMESTAMPTZ DEFAULT NOW(),
    updated_at          TIMESTAMPTZ,
    deleted_at          TIMESTAMPTZ,
    created_by          UUID,
    updated_by          UUID,
    deleted_by          UUID,
    status_id           UUID        REFERENCES status(id)
);

CREATE TABLE person (
    id               UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    first_name       VARCHAR(100) NOT NULL,
    last_name        VARCHAR(100) NOT NULL,
    document_number  VARCHAR(20)  NOT NULL UNIQUE,
    email            VARCHAR(150) NOT NULL UNIQUE,
    phone            VARCHAR(20),
    type_document_id UUID         NOT NULL REFERENCES type_document(id),
    study_group_id   UUID         REFERENCES study_group(id),
    created_at       TIMESTAMPTZ  DEFAULT NOW(),
    updated_at       TIMESTAMPTZ,
    deleted_at       TIMESTAMPTZ,
    created_by       UUID,
    updated_by       UUID,
    deleted_by       UUID,
    status_id        UUID         REFERENCES status(id)
);

CREATE TABLE file (
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
-- MÓDULO 2: SECURITY
-- A partir de aquí users ya existe,
-- todas las FK de auditoría se declaran inline.
-- ==========================================

CREATE TABLE users (
    id          UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    username    VARCHAR(100) NOT NULL UNIQUE,
    password    VARCHAR(255) NOT NULL,
    active      BOOLEAN      NOT NULL DEFAULT TRUE,
    person_id   UUID         NOT NULL REFERENCES person(id),
    created_at  TIMESTAMPTZ  DEFAULT NOW(),
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ,
    created_by  UUID         REFERENCES users(id),
    updated_by  UUID         REFERENCES users(id),
    deleted_by  UUID         REFERENCES users(id),
    status_id   UUID         REFERENCES status(id)
);

CREATE TABLE role (
    id          UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_name   VARCHAR(50) NOT NULL UNIQUE,
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
    created_at  TIMESTAMPTZ  DEFAULT NOW(),
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ,
    created_by  UUID         REFERENCES users(id),
    updated_by  UUID         REFERENCES users(id),
    deleted_by  UUID         REFERENCES users(id),
    status_id   UUID         REFERENCES status(id)
);

CREATE TABLE user_role (
    user_id     UUID        NOT NULL REFERENCES users(id),
    role_id     UUID        NOT NULL REFERENCES role(id),
    PRIMARY KEY (user_id, role_id),
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ,
    created_by  UUID        REFERENCES users(id),
    updated_by  UUID        REFERENCES users(id),
    deleted_by  UUID        REFERENCES users(id),
    status_id   UUID        REFERENCES status(id)
);

CREATE TABLE role_module (
    role_id     UUID        NOT NULL REFERENCES role(id),
    module_id   UUID        NOT NULL REFERENCES module(id),
    PRIMARY KEY (role_id, module_id),
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ,
    created_by  UUID        REFERENCES users(id),
    updated_by  UUID        REFERENCES users(id),
    deleted_by  UUID        REFERENCES users(id),
    status_id   UUID        REFERENCES status(id)
);

CREATE TABLE module_view (
    module_id   UUID        NOT NULL REFERENCES module(id),
    view_id     UUID        NOT NULL REFERENCES view(id),
    PRIMARY KEY (module_id, view_id),
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ,
    created_by  UUID        REFERENCES users(id),
    updated_by  UUID        REFERENCES users(id),
    deleted_by  UUID        REFERENCES users(id),
    status_id   UUID        REFERENCES status(id)
);

-- ==========================================
-- MÓDULO 3: INVENTORY
-- ==========================================

CREATE TABLE category (
    id          UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        VARCHAR(100) NOT NULL UNIQUE,
    created_at  TIMESTAMPTZ  DEFAULT NOW(),
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ,
    created_by  UUID         REFERENCES users(id),
    updated_by  UUID         REFERENCES users(id),
    deleted_by  UUID         REFERENCES users(id),
    status_id   UUID         REFERENCES status(id)
);

CREATE TABLE supplier (
    id          UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        VARCHAR(150) NOT NULL UNIQUE,
    phone       VARCHAR(20),
    email       VARCHAR(150),
    created_at  TIMESTAMPTZ  DEFAULT NOW(),
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ,
    created_by  UUID         REFERENCES users(id),
    updated_by  UUID         REFERENCES users(id),
    deleted_by  UUID         REFERENCES users(id),
    status_id   UUID         REFERENCES status(id)
);

CREATE TABLE product (
    id           UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
    name         VARCHAR(150)  NOT NULL,
    description  TEXT,
    price        DECIMAL(10,2) NOT NULL,
    stock        INT           NOT NULL DEFAULT 0,
    image_url    VARCHAR(255),
    category_id  UUID          NOT NULL REFERENCES category(id),
    supplier_id  UUID          NOT NULL REFERENCES supplier(id),
    created_at   TIMESTAMPTZ   DEFAULT NOW(),
    updated_at   TIMESTAMPTZ,
    deleted_at   TIMESTAMPTZ,
    created_by   UUID          REFERENCES users(id),
    updated_by   UUID          REFERENCES users(id),
    deleted_by   UUID          REFERENCES users(id),
    status_id    UUID          REFERENCES status(id)
);

CREATE TABLE inventory_movement (
    id             UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    movement_type  VARCHAR(20) NOT NULL CHECK (movement_type IN ('ENTRADA', 'SALIDA')),
    quantity       INT         NOT NULL,
    product_id     UUID        NOT NULL REFERENCES product(id),
    created_at     TIMESTAMPTZ DEFAULT NOW(),
    updated_at     TIMESTAMPTZ,
    deleted_at     TIMESTAMPTZ,
    created_by     UUID        NOT NULL REFERENCES users(id),
    updated_by     UUID        REFERENCES users(id),
    deleted_by     UUID        REFERENCES users(id),
    status_id      UUID        REFERENCES status(id)
);

CREATE TABLE memory_game_item (
    id            UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    english_name  VARCHAR(100) NOT NULL,
    image_url     VARCHAR(255),
    product_id    UUID         NOT NULL REFERENCES product(id),
    created_at    TIMESTAMPTZ  DEFAULT NOW(),
    updated_at    TIMESTAMPTZ,
    deleted_at    TIMESTAMPTZ,
    created_by    UUID         REFERENCES users(id),
    updated_by    UUID         REFERENCES users(id),
    deleted_by    UUID         REFERENCES users(id),
    status_id     UUID         REFERENCES status(id)
);

-- ==========================================
-- MÓDULO 4: SALES
-- ==========================================

CREATE TABLE customer_type (
    id          UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        VARCHAR(50) NOT NULL UNIQUE,
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ,
    created_by  UUID        REFERENCES users(id),
    updated_by  UUID        REFERENCES users(id),
    deleted_by  UUID        REFERENCES users(id),
    status_id   UUID        REFERENCES status(id)
);

CREATE TABLE customer (
    id               UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    person_id        UUID        NOT NULL REFERENCES person(id),
    customer_type_id UUID        NOT NULL REFERENCES customer_type(id),
    created_at       TIMESTAMPTZ DEFAULT NOW(),
    updated_at       TIMESTAMPTZ,
    deleted_at       TIMESTAMPTZ,
    created_by       UUID        REFERENCES users(id),
    updated_by       UUID        REFERENCES users(id),
    deleted_by       UUID        REFERENCES users(id),
    status_id        UUID        REFERENCES status(id)
);

CREATE TABLE order_status (
    id          UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        VARCHAR(50) NOT NULL UNIQUE,
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ,
    created_by  UUID        REFERENCES users(id),
    updated_by  UUID        REFERENCES users(id),
    deleted_by  UUID        REFERENCES users(id),
    status_id   UUID        REFERENCES status(id)
);

CREATE TABLE orders (
    id              UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
    total_amount    DECIMAL(10,2) NOT NULL,
    order_status_id UUID          NOT NULL REFERENCES order_status(id),
    customer_id     UUID          NOT NULL REFERENCES customer(id),
    created_at      TIMESTAMPTZ   DEFAULT NOW(),
    updated_at      TIMESTAMPTZ,
    deleted_at      TIMESTAMPTZ,
    created_by      UUID          REFERENCES users(id),
    updated_by      UUID          REFERENCES users(id),
    deleted_by      UUID          REFERENCES users(id),
    status_id       UUID          REFERENCES status(id)
);

CREATE TABLE order_item (
    id          UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id    UUID          NOT NULL REFERENCES orders(id),
    product_id  UUID          NOT NULL REFERENCES product(id),
    quantity    INT           NOT NULL,
    unit_price  DECIMAL(10,2) NOT NULL,
    created_at  TIMESTAMPTZ   DEFAULT NOW(),
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ,
    created_by  UUID          REFERENCES users(id),
    updated_by  UUID          REFERENCES users(id),
    deleted_by  UUID          REFERENCES users(id),
    status_id   UUID          REFERENCES status(id)
);

-- ==========================================
-- MÓDULO 4: METHOD_PAYMENT
-- ==========================================

CREATE TABLE method_payment (
    id          UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        VARCHAR(50) NOT NULL UNIQUE,
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ,
    created_by  UUID        REFERENCES users(id),
    updated_by  UUID        REFERENCES users(id),
    deleted_by  UUID        REFERENCES users(id),
    status_id   UUID        REFERENCES status(id)
);

-- ==========================================
-- MÓDULO 5: BILLING
-- ==========================================

CREATE TABLE invoice (
    id              UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_number  VARCHAR(50)   NOT NULL UNIQUE,
    total           DECIMAL(10,2) NOT NULL,
    order_id        UUID          NOT NULL REFERENCES orders(id),
    created_at      TIMESTAMPTZ   DEFAULT NOW(),
    updated_at      TIMESTAMPTZ,
    deleted_at      TIMESTAMPTZ,
    created_by      UUID          REFERENCES users(id),
    updated_by      UUID          REFERENCES users(id),
    deleted_by      UUID          REFERENCES users(id),
    status_id       UUID          REFERENCES status(id)
);

CREATE TABLE invoice_item (
    id          UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_id  UUID          NOT NULL REFERENCES invoice(id),
    product_id  UUID          NOT NULL REFERENCES product(id),
    quantity    INT           NOT NULL,
    price       DECIMAL(10,2) NOT NULL,
    created_at  TIMESTAMPTZ   DEFAULT NOW(),
    updated_at  TIMESTAMPTZ,
    deleted_at  TIMESTAMPTZ,
    created_by  UUID          REFERENCES users(id),
    updated_by  UUID          REFERENCES users(id),
    deleted_by  UUID          REFERENCES users(id),
    status_id   UUID          REFERENCES status(id)
);

CREATE TABLE payment (
    id                UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
    amount_paid       DECIMAL(10,2) NOT NULL,
    invoice_id        UUID          NOT NULL REFERENCES invoice(id),
    method_payment_id UUID          NOT NULL REFERENCES method_payment(id),
    paid_at           TIMESTAMPTZ   DEFAULT NOW(),
    created_at        TIMESTAMPTZ   DEFAULT NOW(),
    updated_at        TIMESTAMPTZ,
    deleted_at        TIMESTAMPTZ,
    created_by        UUID          REFERENCES users(id),
    updated_by        UUID          REFERENCES users(id),
    deleted_by        UUID          REFERENCES users(id),
    status_id         UUID          REFERENCES status(id)
);