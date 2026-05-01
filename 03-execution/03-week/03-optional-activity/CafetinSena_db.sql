-- ==========================================
-- BASE DE DATOS: cafetinsena
-- ==========================================

CREATE DATABASE cafetinsena;
\c cafetinsena;

-- Habilitar extensión UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==========================================
-- MÓDULO: SECURITY
-- ==========================================

CREATE TABLE type_document (
    id    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name  VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE academic_program (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    program_name  VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE study_group (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    group_code          VARCHAR(50) NOT NULL UNIQUE,
    academic_program_id UUID NOT NULL REFERENCES academic_program(id)
);

CREATE TABLE person (
    id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    first_name       VARCHAR(100) NOT NULL,
    last_name        VARCHAR(100) NOT NULL,
    document_number  VARCHAR(20) NOT NULL UNIQUE,
    email            VARCHAR(150) NOT NULL UNIQUE,
    phone            VARCHAR(20),
    type_document_id UUID NOT NULL REFERENCES type_document(id),
    study_group_id   UUID REFERENCES study_group(id)
);

CREATE TABLE users (
    id        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username  VARCHAR(100) NOT NULL UNIQUE,
    password  VARCHAR(255) NOT NULL,
    active    BOOLEAN NOT NULL DEFAULT TRUE,
    person_id UUID NOT NULL REFERENCES person(id)
);

CREATE TABLE role (
    id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_name  VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE user_role (
    user_id UUID NOT NULL REFERENCES users(id),
    role_id UUID NOT NULL REFERENCES role(id),
    PRIMARY KEY (user_id, role_id)
);

CREATE TABLE customer_type (
    id    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name  VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE customer (
    id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    person_id        UUID NOT NULL REFERENCES person(id),
    customer_type_id UUID NOT NULL REFERENCES customer_type(id)
);

-- ==========================================
-- MÓDULO: INVENTORY
-- ==========================================

CREATE TABLE category (
    id    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name  VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE supplier (
    id    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name  VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE product (
    id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name         VARCHAR(150) NOT NULL,
    description  TEXT,
    price        DECIMAL(10,2) NOT NULL,
    stock        INT NOT NULL DEFAULT 0,
    image_url    VARCHAR(255),
    category_id  UUID NOT NULL REFERENCES category(id),
    supplier_id  UUID NOT NULL REFERENCES supplier(id)
);

CREATE TABLE inventory_movement (
    id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    movement_type  VARCHAR(20) NOT NULL CHECK (movement_type IN ('ENTRADA', 'SALIDA')),
    quantity       INT NOT NULL,
    product_id     UUID NOT NULL REFERENCES product(id),
    created_by     UUID NOT NULL REFERENCES users(id),
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE memory_game_item (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    english_name  VARCHAR(100) NOT NULL,
    image_url     VARCHAR(255),
    product_id    UUID NOT NULL REFERENCES product(id)
);

-- ==========================================
-- MÓDULO: BILL
-- ==========================================

CREATE TABLE order_status (
    id    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name  VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE orders (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    total_amount  DECIMAL(10,2) NOT NULL,
    status_id     UUID NOT NULL REFERENCES order_status(id),
    customer_id   UUID NOT NULL REFERENCES customer(id),
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_item (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id    UUID NOT NULL REFERENCES orders(id),
    product_id  UUID NOT NULL REFERENCES product(id),
    quantity    INT NOT NULL,
    unit_price  DECIMAL(10,2) NOT NULL
);

CREATE TABLE invoice (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_number  VARCHAR(50) NOT NULL UNIQUE,
    total           DECIMAL(10,2) NOT NULL,
    order_id        UUID NOT NULL REFERENCES orders(id),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE invoice_item (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_id  UUID NOT NULL REFERENCES invoice(id),
    product_id  UUID NOT NULL REFERENCES product(id),
    quantity    INT NOT NULL,
    price       DECIMAL(10,2) NOT NULL
);

CREATE TABLE method_payment (
    id    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name  VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE payment (
    id                 UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    amount_paid        DECIMAL(10,2) NOT NULL,
    invoice_id         UUID NOT NULL REFERENCES invoice(id),
    method_payment_id  UUID NOT NULL REFERENCES method_payment(id),
    paid_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

