CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;   
END;
$$ language 'plpgsql';

/*********************
Modulo 1: SECURITY
**********************/

CREATE TABLE role(
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ, deleted_at TIMESTAMPTZ,
    created_by UUID, updated_by UUID, deleted_by UUID, status UUID
);

CREATE TABLE module(
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ, deleted_at TIMESTAMPTZ,
    created_by UUID, updated_by UUID, deleted_by UUID, status UUID
);

CREATE TABLE view(
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    route VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ, deleted_at TIMESTAMPTZ,
    created_by UUID, updated_by UUID, deleted_by UUID, status UUID
);

CREATE TABLE users(
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ, deleted_at TIMESTAMPTZ,
    created_by UUID, updated_by UUID, deleted_by UUID, status UUID
);

CREATE TABLE user_role(
    user_id BIGINT REFERENCES users(id),
    role_id BIGINT REFERENCES role(id),
    PRIMARY KEY (user_id, role_id)
);

CREATE TABLE role_module(
    role_id BIGINT REFERENCES role(id),
    module_id BIGINT REFERENCES module(id),
    PRIMARY KEY (role_id, module_id)
);

CREATE TABLE module_view(
    module_id BIGINT REFERENCES module(id),
    view_id BIGINT REFERENCES view(id),
    PRIMARY KEY (module_id, view_id)
);

/*********************
Modulo 2: PARAMETER
**********************/

CREATE TABLE type_document(
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ, deleted_at TIMESTAMPTZ,
    created_by UUID, updated_by UUID, deleted_by UUID, status UUID
);

CREATE TABLE academic_program(
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    program_name VARCHAR(150) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ, deleted_at TIMESTAMPTZ,
    created_by UUID, updated_by UUID, deleted_by UUID, status UUID
);

CREATE TABLE study_group(
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    group_code VARCHAR(50) NOT NULL UNIQUE,
    academic_program_id BIGINT REFERENCES academic_program(id),
    created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ, deleted_at TIMESTAMPTZ,
    created_by UUID, updated_by UUID, deleted_by UUID, status UUID
);

CREATE TABLE person(
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    document_number VARCHAR(20) UNIQUE,
    type_document_id BIGINT REFERENCES type_document(id),
    user_id BIGINT REFERENCES users(id),
    study_group_id BIGINT REFERENCES study_group(id),
    created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ, deleted_at TIMESTAMPTZ,
    created_by UUID, updated_by UUID, deleted_by UUID, status UUID
);

CREATE TABLE file(
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    file_path VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ, deleted_at TIMESTAMPTZ,
    created_by UUID, updated_by UUID, deleted_by UUID, status UUID
);

/*********************
Modulo 3: INVENTORY
**********************/

CREATE TABLE category(
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ, deleted_at TIMESTAMPTZ,
    created_by UUID, updated_by UUID, deleted_by UUID, status UUID
);

CREATE TABLE supplier(
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ, deleted_at TIMESTAMPTZ,
    created_by UUID, updated_by UUID, deleted_by UUID, status UUID
);

CREATE TABLE product(
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    descripcion TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT NOT NULL,
    image_url VARCHAR(255),
    category_id BIGINT REFERENCES category(id),
    created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ, deleted_at TIMESTAMPTZ,
    created_by UUID, updated_by UUID, deleted_by UUID, status UUID
);

CREATE TABLE inventory(
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    quantity_change INT,
    movement_type VARCHAR(10),
    product_id BIGINT REFERENCES product(id),
    created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ, deleted_at TIMESTAMPTZ,
    created_by UUID, updated_by UUID, deleted_by UUID, status UUID
);

/*********************
Modulo 4: SALES
**********************/

CREATE TABLE customer(
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_type VARCHAR(50),
    person_id BIGINT REFERENCES person(id),
    created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ, deleted_at TIMESTAMPTZ,
    created_by UUID, updated_by UUID, deleted_by UUID, status UUID
);

CREATE TABLE method_payment(
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ, deleted_at TIMESTAMPTZ,
    created_by UUID, updated_by UUID, deleted_by UUID, status UUID
);

CREATE TABLE orders(
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id BIGINT REFERENCES customer(id),
    total_amount DECIMAL(10,2),
    order_status VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ, deleted_at TIMESTAMPTZ,
    created_by UUID, updated_by UUID, deleted_by UUID, status UUID
);

CREATE TABLE order_item(
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id BIGINT REFERENCES orders(id),
    product_id BIGINT REFERENCES product(id),
    quantity INT,
    unit_price DECIMAL(10,2),
    created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ, deleted_at TIMESTAMPTZ,
    created_by UUID, updated_by UUID, deleted_by UUID, status UUID
);

/*********************
Modulo 5: BILLING
**********************/

CREATE TABLE invoice(
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id BIGINT REFERENCES orders(id),
    invoice_number VARCHAR(50) UNIQUE,
    total DECIMAL(10,2),
    created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ, deleted_at TIMESTAMPTZ,
    created_by UUID, updated_by UUID, deleted_by UUID, status UUID
);

CREATE TABLE invoice_item(
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    invoice_id BIGINT REFERENCES invoice(id),
    product_name VARCHAR(150),
    quantity INT,
    price DECIMAL(10,2),
    created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ, deleted_at TIMESTAMPTZ,
    created_by UUID, updated_by UUID, deleted_by UUID, status UUID
);

CREATE TABLE payment(
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    invoice_id BIGINT REFERENCES invoice(id),
    method_payment_id BIGINT REFERENCES method_payment(id),
    amount_paid DECIMAL(10,2),
    created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ, deleted_at TIMESTAMPTZ,
    created_by UUID, updated_by UUID, deleted_by UUID, status UUID
);

CREATE TABLE memory_game_item(
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id BIGINT REFERENCES product(id),
    english_name VARCHAR(150),
    image_url VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW(), updated_at TIMESTAMPTZ, deleted_at TIMESTAMPTZ,
    created_by UUID, updated_by UUID, deleted_by UUID, status UUID
);




DO $$ 
DECLARE 
    t text;
BEGIN
    FOR t IN (SELECT table_name FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE') LOOP
        EXECUTE format('CREATE OR REPLACE TRIGGER tr_update_modtime_%I BEFORE UPDATE ON %I FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();', t, t);
    END LOOP;
END $$;

