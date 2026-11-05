-- =============================================================================
-- DRIVIQUE - SCRIPT MAESTRO DE BASE DE DATOS POSTGRESQL 17
-- SISTEMA DE GESTIÓN Y ALQUILER DE FLOTA VEHICULAR
-- SERVICIO NACIONAL DE APRENDIZAJE (SENA) - FICHA: 3145555
-- INTEGRANTES: Laura Vanessa Pérez Perdomo, Danna Valentina Barrios Penagos, Emily Sharith Amézquita Saavedra
-- AÑO: 2026
-- =============================================================================

-- HABILITACIÓN DE EXTENSIONES OBLIGATORIAS
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- CREACIÓN DE LOS 10 ESQUEMAS TEMÁTICOS DEL SISTEMA
CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS iam;
CREATE SCHEMA IF NOT EXISTS location;
CREATE SCHEMA IF NOT EXISTS fleet;
CREATE SCHEMA IF NOT EXISTS catalog;
CREATE SCHEMA IF NOT EXISTS rental;
CREATE SCHEMA IF NOT EXISTS contract;
CREATE SCHEMA IF NOT EXISTS billing;
CREATE SCHEMA IF NOT EXISTS support;
CREATE SCHEMA IF NOT EXISTS audit;

-- FUNCIÓN DE TRIGGER TRANSVERSAL PARA MARCAS TEMPORALES
CREATE OR REPLACE FUNCTION core.touch_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- =============================================================================
-- SECCIÓN: 02 TIPOS Y ENUMS
-- =============================================================================

-- =============================================================================
-- SECCIÓN: 03 TABLAS DDL - ESQUEMA [CORE]
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: 003-create-languages-table.sql
-- -----------------------------------------------------------------------------
CREATE TABLE core.languages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(10) NOT NULL,
    name VARCHAR(50) NOT NULL,
    is_default BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_languages_code UNIQUE (code),
    CONSTRAINT uq_languages_name UNIQUE (name),
    CONSTRAINT chk_languages_code_format CHECK (code ~ '^[a-z]{2}(-[A-Z]{2})?$')
);

-- -----------------------------------------------------------------------------
-- Archivo: 004-create-currencies-table.sql
-- -----------------------------------------------------------------------------
CREATE TABLE core.currencies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code CHAR(3) NOT NULL,
    name VARCHAR(50) NOT NULL,
    symbol VARCHAR(5) NOT NULL,
    is_default BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_currencies_code UNIQUE (code),
    CONSTRAINT uq_currencies_name UNIQUE (name),
    CONSTRAINT chk_currencies_code_format CHECK (code ~ '^[A-Z]{3}$')
);

-- -----------------------------------------------------------------------------
-- Archivo: 011-create-exchange-rates-table.sql
-- -----------------------------------------------------------------------------
CREATE TABLE core.exchange_rates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    from_currency_id UUID NOT NULL,
    to_currency_id UUID NOT NULL,
    rate NUMERIC(16, 6) NOT NULL,
    provider VARCHAR(80) NOT NULL,
    fetched_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_exchange_rates_from_currency
        FOREIGN KEY (from_currency_id) REFERENCES core.currencies (id),
    CONSTRAINT fk_exchange_rates_to_currency
        FOREIGN KEY (to_currency_id) REFERENCES core.currencies (id),
    CONSTRAINT uq_exchange_rates_pair_fetched_at
        UNIQUE (from_currency_id, to_currency_id, fetched_at),
    CONSTRAINT chk_exchange_rates_rate_positive CHECK (rate > 0),
    CONSTRAINT chk_exchange_rates_currency_pair CHECK (from_currency_id <> to_currency_id)
);

-- -----------------------------------------------------------------------------
-- Archivo: brand-configurations.sql
-- -----------------------------------------------------------------------------
CREATE TABLE core.brand_configurations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_name VARCHAR(100) NOT NULL,
    logo_url VARCHAR(2048),
    favicon_url VARCHAR(2048),
    primary_color VARCHAR(7) NOT NULL,
    secondary_color VARCHAR(7) NOT NULL,
    accent_color VARCHAR(7) NOT NULL,
    default_theme VARCHAR(10) NOT NULL DEFAULT 'SYSTEM',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_brand_configurations_primary_color_hex
        CHECK (primary_color ~ '^#[0-9A-Fa-f]{6}$'),
    CONSTRAINT chk_brand_configurations_secondary_color_hex
        CHECK (secondary_color ~ '^#[0-9A-Fa-f]{6}$'),
    CONSTRAINT chk_brand_configurations_accent_color_hex
        CHECK (accent_color ~ '^#[0-9A-Fa-f]{6}$'),
    CONSTRAINT chk_brand_configurations_distinct_colors
        CHECK (
            primary_color <> secondary_color
            AND primary_color <> accent_color
            AND secondary_color <> accent_color
        ),
    CONSTRAINT chk_brand_configurations_default_theme
        CHECK (default_theme IN ('LIGHT', 'DARK', 'SYSTEM'))
);

-- =============================================================================
-- SECCIÓN: 03 TABLAS DDL - ESQUEMA [IAM]
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: add-document-catalog-and-user-document-fields.sql
-- -----------------------------------------------------------------------------
ALTER TABLE iam.document_types
    ADD COLUMN description VARCHAR(255),
    ADD COLUMN is_mandatory BOOLEAN NOT NULL DEFAULT TRUE;

ALTER TABLE iam.user_documents
    ADD COLUMN document_number VARCHAR(50);

-- -----------------------------------------------------------------------------
-- Archivo: add-document-statuses-description.sql
-- -----------------------------------------------------------------------------
ALTER TABLE iam.document_statuses
    ADD COLUMN description VARCHAR(255);

-- -----------------------------------------------------------------------------
-- Archivo: add-users-identity-catalog-foreign-keys.sql
-- -----------------------------------------------------------------------------
ALTER TABLE iam.users
    ADD CONSTRAINT fk_users_document_type
        FOREIGN KEY (document_type_id) REFERENCES iam.document_types (id),
    ADD CONSTRAINT fk_users_nationality
        FOREIGN KEY (nationality_id) REFERENCES iam.nationalities (id);

-- -----------------------------------------------------------------------------
-- Archivo: document-statuses.sql
-- -----------------------------------------------------------------------------
CREATE TABLE iam.document_statuses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_document_statuses_code UNIQUE (code),
    CONSTRAINT uq_document_statuses_name UNIQUE (name),
    CONSTRAINT chk_document_statuses_code_format CHECK (code ~ '^[A-Z][A-Z0-9_]*$')
);

-- -----------------------------------------------------------------------------
-- Archivo: document-types.sql
-- -----------------------------------------------------------------------------
CREATE TABLE iam.document_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    requires_front_and_back BOOLEAN NOT NULL DEFAULT TRUE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_document_types_code UNIQUE (code),
    CONSTRAINT uq_document_types_name UNIQUE (name),
    CONSTRAINT chk_document_types_code_format CHECK (code ~ '^[A-Z][A-Z0-9_]*$')
);

-- -----------------------------------------------------------------------------
-- Archivo: nationalities.sql
-- -----------------------------------------------------------------------------
CREATE TABLE iam.nationalities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    iso_code CHAR(2) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_nationalities_name UNIQUE (name),
    CONSTRAINT uq_nationalities_iso_code UNIQUE (iso_code),
    CONSTRAINT chk_nationalities_iso_code_format CHECK (iso_code ~ '^[A-Z]{2}$')
);

-- -----------------------------------------------------------------------------
-- Archivo: password-policies.sql
-- -----------------------------------------------------------------------------
CREATE TABLE iam.password_policies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    policy_name VARCHAR(80) NOT NULL,
    min_length SMALLINT NOT NULL,
    require_uppercase BOOLEAN NOT NULL DEFAULT TRUE,
    require_number BOOLEAN NOT NULL DEFAULT TRUE,
    require_symbol BOOLEAN NOT NULL DEFAULT TRUE,
    password_history_limit SMALLINT NOT NULL DEFAULT 5,
    expiration_days SMALLINT NOT NULL DEFAULT 90,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_password_policies_name UNIQUE (policy_name),
    CONSTRAINT chk_password_policies_min_length CHECK (min_length >= 8),
    CONSTRAINT chk_password_policies_history_limit CHECK (password_history_limit >= 0),
    CONSTRAINT chk_password_policies_expiration_days CHECK (expiration_days > 0)
);

-- -----------------------------------------------------------------------------
-- Archivo: permissions.sql
-- -----------------------------------------------------------------------------
CREATE TABLE iam.permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(80) NOT NULL,
    name VARCHAR(120) NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_permissions_code UNIQUE (code),
    CONSTRAINT chk_permissions_code_format CHECK (code ~ '^[A-Z][A-Z0-9_]*$'),
    CONSTRAINT chk_permissions_name_not_blank CHECK (btrim(name) <> '')
);

-- -----------------------------------------------------------------------------
-- Archivo: role_permissions.sql
-- -----------------------------------------------------------------------------
CREATE TABLE iam.role_permissions (
    role_id UUID NOT NULL,
    permission_id UUID NOT NULL,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_role_permissions PRIMARY KEY (role_id, permission_id),
    CONSTRAINT fk_role_permissions_role FOREIGN KEY (role_id) REFERENCES iam.roles(id) ON DELETE CASCADE,
    CONSTRAINT fk_role_permissions_permission FOREIGN KEY (permission_id) REFERENCES iam.permissions(id) ON DELETE CASCADE
);

-- -----------------------------------------------------------------------------
-- Archivo: roles.sql
-- -----------------------------------------------------------------------------
CREATE TABLE iam.roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(40) NOT NULL,
    name VARCHAR(80) NOT NULL,
    description VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_roles_code UNIQUE (code),
    CONSTRAINT uq_roles_name UNIQUE (name),
    CONSTRAINT chk_roles_code_format CHECK (code ~ '^[A-Z][A-Z0-9_]*$'),
    CONSTRAINT chk_roles_name_not_blank CHECK (btrim(name) <> '')
);

-- -----------------------------------------------------------------------------
-- Archivo: security-configuration-changes-hu-int-19.sql
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS iam.security_configuration_changes (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    config_key varchar(100) NOT NULL,
    old_value text,
    new_value text NOT NULL,
    reason varchar(300),
    reverted boolean NOT NULL DEFAULT false,
    changed_by uuid NOT NULL REFERENCES iam.users (id),
    changed_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_security_configuration_changes_key ON iam.security_configuration_changes (config_key, changed_at DESC);

-- -----------------------------------------------------------------------------
-- Archivo: security-configurations.sql
-- -----------------------------------------------------------------------------
CREATE TABLE iam.security_configurations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    config_key VARCHAR(100) NOT NULL,
    config_value TEXT NOT NULL,
    description VARCHAR(500) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_security_configurations_key UNIQUE (config_key),
    CONSTRAINT chk_security_configurations_key_format CHECK (config_key ~ '^[A-Z][A-Z0-9_]*$'),
    CONSTRAINT chk_security_configurations_value_not_blank CHECK (btrim(config_value) <> ''),
    CONSTRAINT chk_security_configurations_description_not_blank CHECK (btrim(description) <> '')
);

-- -----------------------------------------------------------------------------
-- Archivo: user-consents.sql
-- -----------------------------------------------------------------------------
CREATE TABLE iam.user_consents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    consent_type VARCHAR(60) NOT NULL,
    document_version VARCHAR(40) NOT NULL,
    accepted_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ip_address INET NOT NULL,
    CONSTRAINT fk_user_consents_user
        FOREIGN KEY (user_id) REFERENCES iam.users (id),
    CONSTRAINT uq_user_consents_user_type_version
        UNIQUE (user_id, consent_type, document_version),
    CONSTRAINT chk_user_consents_type_not_blank
        CHECK (btrim(consent_type) <> ''),
    CONSTRAINT chk_user_consents_version_not_blank
        CHECK (btrim(document_version) <> '')
);

-- -----------------------------------------------------------------------------
-- Archivo: user-documents.sql
-- -----------------------------------------------------------------------------
CREATE TABLE iam.user_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    document_type_id UUID NOT NULL,
    status_id UUID NOT NULL,
    front_url VARCHAR(1000) NOT NULL,
    back_url VARCHAR(1000),
    review_notes VARCHAR(500),
    reviewed_by UUID,
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_documents_user
        FOREIGN KEY (user_id) REFERENCES iam.users (id),
    CONSTRAINT fk_user_documents_document_type
        FOREIGN KEY (document_type_id) REFERENCES iam.document_types (id),
    CONSTRAINT fk_user_documents_status
        FOREIGN KEY (status_id) REFERENCES iam.document_statuses (id),
    CONSTRAINT fk_user_documents_reviewer
        FOREIGN KEY (reviewed_by) REFERENCES iam.users (id),
    CONSTRAINT chk_user_documents_front_url_not_blank
        CHECK (btrim(front_url) <> ''),
    CONSTRAINT chk_user_documents_back_url_not_blank
        CHECK (back_url IS NULL OR btrim(back_url) <> ''),
    CONSTRAINT chk_user_documents_review_notes_not_blank
        CHECK (review_notes IS NULL OR btrim(review_notes) <> '')
);

-- -----------------------------------------------------------------------------
-- Archivo: user_preferences.sql
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS iam.user_preferences (
    user_id UUID PRIMARY KEY REFERENCES iam.users(id) ON DELETE CASCADE,
    language_id UUID REFERENCES core.languages(id) ON DELETE SET NULL,
    currency_id UUID REFERENCES core.currencies(id) ON DELETE SET NULL,
    theme_preference VARCHAR(20) NOT NULL DEFAULT 'SYSTEM' CHECK (theme_preference IN ('LIGHT', 'DARK', 'SYSTEM')),
    email_notifications BOOLEAN NOT NULL DEFAULT true,
    sms_notifications BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- -----------------------------------------------------------------------------
-- Archivo: user_profiles.sql
-- -----------------------------------------------------------------------------
CREATE TABLE iam.user_profiles (
    user_id UUID PRIMARY KEY,
    address VARCHAR(255),
    city_of_residence VARCHAR(100),
    department_of_residence VARCHAR(100),
    postal_code VARCHAR(20),
    gender VARCHAR(20),
    emergency_contact_name VARCHAR(150),
    emergency_contact_phone VARCHAR(30),
    avatar_url VARCHAR(1000),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_profiles_user FOREIGN KEY (user_id) REFERENCES iam.users(id) ON DELETE CASCADE,
    CONSTRAINT chk_user_profiles_gender CHECK (gender IS NULL OR gender IN ('MALE', 'FEMALE', 'OTHER', 'PREFER_NOT_TO_SAY'))
);

-- -----------------------------------------------------------------------------
-- Archivo: user_roles.sql
-- -----------------------------------------------------------------------------
CREATE TABLE iam.user_roles (
    user_id UUID NOT NULL,
    role_id UUID NOT NULL,
    assigned_by UUID,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_user_roles PRIMARY KEY (user_id, role_id),
    CONSTRAINT fk_user_roles_user FOREIGN KEY (user_id) REFERENCES iam.users(id) ON DELETE CASCADE,
    CONSTRAINT fk_user_roles_role FOREIGN KEY (role_id) REFERENCES iam.roles(id) ON DELETE RESTRICT,
    CONSTRAINT fk_user_roles_assigned_by FOREIGN KEY (assigned_by) REFERENCES iam.users(id) ON DELETE SET NULL
);

-- -----------------------------------------------------------------------------
-- Archivo: user_sessions.sql
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS iam.user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES iam.users(id) ON DELETE CASCADE,
    refresh_token_hash VARCHAR(255) NOT NULL UNIQUE,
    device_info VARCHAR(255),
    ip_address VARCHAR(45),
    user_agent VARCHAR(500),
    started_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    expires_at TIMESTAMPTZ NOT NULL,
    revoked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_user_sessions_expires_at CHECK (expires_at > started_at)
);

-- -----------------------------------------------------------------------------
-- Archivo: user_social_accounts.sql
-- -----------------------------------------------------------------------------
CREATE TABLE iam.user_social_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    provider VARCHAR(30) NOT NULL,
    provider_user_id VARCHAR(255) NOT NULL,
    email VARCHAR(254),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_social_accounts_user FOREIGN KEY (user_id) REFERENCES iam.users(id) ON DELETE CASCADE,
    CONSTRAINT uq_user_social_accounts_provider_user_id UNIQUE (provider, provider_user_id),
    CONSTRAINT uq_user_social_accounts_user_provider UNIQUE (user_id, provider),
    CONSTRAINT chk_user_social_accounts_provider CHECK (provider IN ('GOOGLE', 'FACEBOOK'))
);

CREATE INDEX idx_user_social_accounts_user_id ON iam.user_social_accounts(user_id);
CREATE INDEX idx_user_social_accounts_provider_lookup ON iam.user_social_accounts(provider, provider_user_id);

-- -----------------------------------------------------------------------------
-- Archivo: users.sql
-- -----------------------------------------------------------------------------
CREATE TABLE iam.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(254) NOT NULL,
    phone VARCHAR(30),
    document_type_id UUID,
    document_number VARCHAR(50),
    birth_date DATE,
    nationality_id UUID,
    password_hash VARCHAR(255) NOT NULL,
    account_status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    is_profile_complete BOOLEAN NOT NULL DEFAULT FALSE,
    failed_login_attempts SMALLINT NOT NULL DEFAULT 0,
    locked_until TIMESTAMPTZ,
    email_verified_at TIMESTAMPTZ,
    last_login_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_users_email UNIQUE (email),
    CONSTRAINT uq_users_document_number UNIQUE (document_number),
    CONSTRAINT chk_users_email_not_blank CHECK (btrim(email) <> ''),
    CONSTRAINT chk_users_failed_attempts CHECK (failed_login_attempts >= 0),
    CONSTRAINT chk_users_account_status CHECK (account_status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED', 'LOCKED', 'PENDING_VERIFICATION', 'DELETED'))
);

-- -----------------------------------------------------------------------------
-- Archivo: verification_codes.sql
-- -----------------------------------------------------------------------------
CREATE TABLE iam.verification_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    purpose VARCHAR(40) NOT NULL,
    code_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    used_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_verification_codes_user FOREIGN KEY (user_id) REFERENCES iam.users(id) ON DELETE CASCADE,
    CONSTRAINT chk_verification_codes_purpose CHECK (purpose IN ('ACCOUNT_VERIFICATION', 'EMAIL_VERIFICATION', 'PASSWORD_RESET', 'TWO_FACTOR_AUTH', 'EMAIL_CHANGE'))
);

-- =============================================================================
-- SECCIÓN: 03 TABLAS DDL - ESQUEMA [LOCATION]
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: branch-users.sql
-- -----------------------------------------------------------------------------
CREATE TABLE location.branch_users (
    user_id UUID NOT NULL,
    branch_id UUID NOT NULL,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_branch_users PRIMARY KEY (user_id, branch_id),
    CONSTRAINT fk_branch_users_user
        FOREIGN KEY (user_id) REFERENCES iam.users (id) ON DELETE CASCADE,
    CONSTRAINT fk_branch_users_branch
        FOREIGN KEY (branch_id) REFERENCES location.branches (id) ON DELETE CASCADE
);

-- -----------------------------------------------------------------------------
-- Archivo: branches.sql
-- -----------------------------------------------------------------------------
CREATE TABLE location.branches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(120) NOT NULL,
    address VARCHAR(255) NOT NULL,
    city_id UUID NOT NULL,
    phone VARCHAR(30) NOT NULL,
    opening_time TIME NOT NULL,
    closing_time TIME NOT NULL,
    allows_cash_payment BOOLEAN NOT NULL DEFAULT TRUE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_branches_city
        FOREIGN KEY (city_id) REFERENCES location.cities (id),
    CONSTRAINT uq_branches_name UNIQUE (name),
    CONSTRAINT chk_branches_name_not_blank CHECK (btrim(name) <> ''),
    CONSTRAINT chk_branches_address_not_blank CHECK (btrim(address) <> ''),
    CONSTRAINT chk_branches_phone_not_blank CHECK (btrim(phone) <> ''),
    CONSTRAINT chk_branches_business_hours CHECK (closing_time > opening_time)
);

-- -----------------------------------------------------------------------------
-- Archivo: cities.sql
-- -----------------------------------------------------------------------------
CREATE TABLE location.cities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    department_id UUID NOT NULL,
    name VARCHAR(100) NOT NULL,
    has_airport BOOLEAN NOT NULL DEFAULT FALSE,
    has_terminal BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_cities_department
        FOREIGN KEY (department_id) REFERENCES location.departments (id),
    CONSTRAINT uq_cities_department_name UNIQUE (department_id, name),
    CONSTRAINT chk_cities_name_not_blank CHECK (btrim(name) <> '')
);

-- -----------------------------------------------------------------------------
-- Archivo: delivery-drivers.sql
-- -----------------------------------------------------------------------------
CREATE TABLE location.delivery_drivers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    branch_id UUID NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(254),
    phone VARCHAR(30),
    document_type VARCHAR(10) NOT NULL DEFAULT 'CC',
    document_number VARCHAR(40) NOT NULL,
    license_number VARCHAR(40),
    license_category VARCHAR(5),
    license_expires_on DATE,
    vehicle_description VARCHAR(120),
    status VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_delivery_drivers_branch FOREIGN KEY (branch_id) REFERENCES location.branches (id),
    CONSTRAINT uq_delivery_drivers_branch_document UNIQUE (branch_id, document_number),
    CONSTRAINT chk_delivery_drivers_name_not_blank CHECK (btrim(full_name) <> ''),
    CONSTRAINT chk_delivery_drivers_document_not_blank CHECK (btrim(document_number) <> ''),
    CONSTRAINT chk_delivery_drivers_status CHECK (status IN ('AVAILABLE', 'ON_ROUTE', 'INACTIVE'))
);

CREATE INDEX idx_delivery_drivers_branch ON location.delivery_drivers (branch_id);

ALTER TABLE rental.reservation_delivery_points
    ADD COLUMN driver_id UUID,
    ADD COLUMN delivery_pin VARCHAR(10),
    ADD COLUMN delivery_status VARCHAR(12) NOT NULL DEFAULT 'PENDING',
    ADD COLUMN delivered_at TIMESTAMPTZ;

ALTER TABLE rental.reservation_delivery_points
    ADD CONSTRAINT fk_reservation_delivery_points_driver FOREIGN KEY (driver_id) REFERENCES location.delivery_drivers (id),
    ADD CONSTRAINT chk_reservation_delivery_points_delivery_status CHECK (delivery_status IN ('PENDING', 'ASSIGNED', 'COMPLETED', 'CANCELLED'));

GRANT SELECT, INSERT, UPDATE, DELETE ON location.delivery_drivers TO drivique_app;

-- -----------------------------------------------------------------------------
-- Archivo: departments.sql
-- -----------------------------------------------------------------------------
CREATE TABLE location.departments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_departments_name UNIQUE (name),
    CONSTRAINT chk_departments_name_not_blank CHECK (btrim(name) <> '')
);

-- -----------------------------------------------------------------------------
-- Archivo: update-reservation-delivery-status-cancelled.sql
-- -----------------------------------------------------------------------------
-- Actualización del constraint de estados de entrega para soportar cancelaciones automáticas y manuales
ALTER TABLE rental.reservation_delivery_points
    DROP CONSTRAINT IF EXISTS chk_reservation_delivery_points_delivery_status;

ALTER TABLE rental.reservation_delivery_points
    ADD CONSTRAINT chk_reservation_delivery_points_delivery_status
    CHECK (delivery_status IN ('PENDING', 'ASSIGNED', 'COMPLETED', 'CANCELLED'));

-- =============================================================================
-- SECCIÓN: 03 TABLAS DDL - ESQUEMA [FLEET]
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: features.sql
-- -----------------------------------------------------------------------------
CREATE TABLE fleet.features (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    feature_group VARCHAR(30) NOT NULL,
    icon VARCHAR(100),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_features_name UNIQUE (name),
    CONSTRAINT chk_features_name_not_blank CHECK (btrim(name) <> ''),
    CONSTRAINT chk_features_group CHECK (feature_group IN ('STANDARD', 'TECHNOLOGY', 'SECURITY', 'COMFORT'))
);

-- -----------------------------------------------------------------------------
-- Archivo: fuel-types.sql
-- -----------------------------------------------------------------------------
CREATE TABLE fleet.fuel_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(30) NOT NULL,
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_fuel_types_code UNIQUE (code),
    CONSTRAINT chk_fuel_types_code_format CHECK (code ~ '^[A-Z][A-Z_]*$'),
    CONSTRAINT chk_fuel_types_name_not_blank CHECK (btrim(name) <> '')
);

-- -----------------------------------------------------------------------------
-- Archivo: maintenance-types.sql
-- -----------------------------------------------------------------------------
CREATE TABLE fleet.maintenance_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(40) NOT NULL,
    name VARCHAR(80) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_maintenance_types_code UNIQUE (code),
    CONSTRAINT uq_maintenance_types_name UNIQUE (name),
    CONSTRAINT chk_maintenance_types_code CHECK (code IN ('PREVENTIVE', 'CORRECTIVE', 'OIL_CHANGE', 'TIRES'))
);

-- -----------------------------------------------------------------------------
-- Archivo: transmission-types.sql
-- -----------------------------------------------------------------------------
CREATE TABLE fleet.transmission_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(30) NOT NULL,
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_transmission_types_code UNIQUE (code),
    CONSTRAINT chk_transmission_types_code_format CHECK (code ~ '^[A-Z][A-Z_]*$'),
    CONSTRAINT chk_transmission_types_name_not_blank CHECK (btrim(name) <> '')
);

-- -----------------------------------------------------------------------------
-- Archivo: user-favorite-vehicles.sql
-- -----------------------------------------------------------------------------
CREATE TABLE fleet.user_favorite_vehicles (
    user_id UUID NOT NULL,
    vehicle_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, vehicle_id),
    CONSTRAINT fk_user_favorite_vehicles_user FOREIGN KEY (user_id) REFERENCES iam.users (id) ON DELETE CASCADE,
    CONSTRAINT fk_user_favorite_vehicles_vehicle FOREIGN KEY (vehicle_id) REFERENCES fleet.vehicles (id) ON DELETE CASCADE
);

-- -----------------------------------------------------------------------------
-- Archivo: vehicle-brands.sql
-- -----------------------------------------------------------------------------
CREATE TABLE fleet.vehicle_brands (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_vehicle_brands_name UNIQUE (name),
    CONSTRAINT chk_vehicle_brands_name_not_blank CHECK (btrim(name) <> '')
);

-- -----------------------------------------------------------------------------
-- Archivo: vehicle-categories.sql
-- -----------------------------------------------------------------------------
CREATE TABLE fleet.vehicle_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    base_daily_rate NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    security_deposit NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_vehicle_categories_name UNIQUE (name),
    CONSTRAINT chk_vehicle_categories_name_not_blank CHECK (btrim(name) <> ''),
    CONSTRAINT chk_vehicle_categories_base_daily_rate CHECK (base_daily_rate >= 0),
    CONSTRAINT chk_vehicle_categories_security_deposit CHECK (security_deposit >= 0)
);

-- -----------------------------------------------------------------------------
-- Archivo: vehicle-documents.sql
-- -----------------------------------------------------------------------------
CREATE TABLE fleet.vehicle_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_id UUID NOT NULL,
    document_type VARCHAR(30) NOT NULL,
    document_number VARCHAR(100),
    file_url VARCHAR(1000) NOT NULL,
    issued_at DATE,
    expires_at DATE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    verified_at TIMESTAMPTZ,
    verified_by UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_vehicle_documents_vehicle FOREIGN KEY (vehicle_id) REFERENCES fleet.vehicles (id) ON DELETE CASCADE,
    CONSTRAINT fk_vehicle_documents_verified_by FOREIGN KEY (verified_by) REFERENCES iam.users (id) ON DELETE SET NULL,
    CONSTRAINT chk_vehicle_documents_type CHECK (document_type IN ('SOAT', 'TECHNICAL_INSPECTION', 'REGISTRATION', 'INSURANCE', 'OTHER')),
    CONSTRAINT chk_vehicle_documents_file_url_not_blank CHECK (btrim(file_url) <> ''),
    CONSTRAINT chk_vehicle_documents_dates CHECK (expires_at IS NULL OR issued_at IS NULL OR expires_at >= issued_at)
);

-- -----------------------------------------------------------------------------
-- Archivo: vehicle-features.sql
-- -----------------------------------------------------------------------------
CREATE TABLE fleet.vehicle_features (
    vehicle_id UUID NOT NULL,
    feature_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (vehicle_id, feature_id),
    CONSTRAINT fk_vehicle_features_vehicle FOREIGN KEY (vehicle_id) REFERENCES fleet.vehicles (id) ON DELETE CASCADE,
    CONSTRAINT fk_vehicle_features_feature FOREIGN KEY (feature_id) REFERENCES fleet.features (id) ON DELETE CASCADE
);

-- -----------------------------------------------------------------------------
-- Archivo: vehicle-images.sql
-- -----------------------------------------------------------------------------
CREATE TABLE fleet.vehicle_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_id UUID NOT NULL,
    url VARCHAR(1000) NOT NULL,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    sort_order SMALLINT NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_vehicle_images_vehicle FOREIGN KEY (vehicle_id) REFERENCES fleet.vehicles (id) ON DELETE CASCADE,
    CONSTRAINT uq_vehicle_images_vehicle_sort_order UNIQUE (vehicle_id, sort_order),
    CONSTRAINT chk_vehicle_images_url_not_blank CHECK (btrim(url) <> ''),
    CONSTRAINT chk_vehicle_images_sort_order CHECK (sort_order > 0)
);

-- -----------------------------------------------------------------------------
-- Archivo: vehicle-maintenances.sql
-- -----------------------------------------------------------------------------
CREATE TABLE fleet.vehicle_maintenances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_id UUID NOT NULL,
    maintenance_type_id UUID NOT NULL,
    scheduled_date DATE NOT NULL,
    completed_date DATE,
    cost NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    description TEXT,
    created_by UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_vehicle_maintenances_vehicle FOREIGN KEY (vehicle_id) REFERENCES fleet.vehicles (id) ON DELETE CASCADE,
    CONSTRAINT fk_vehicle_maintenances_type FOREIGN KEY (maintenance_type_id) REFERENCES fleet.maintenance_types (id),
    CONSTRAINT fk_vehicle_maintenances_created_by FOREIGN KEY (created_by) REFERENCES iam.users (id) ON DELETE SET NULL,
    CONSTRAINT chk_vehicle_maintenances_cost CHECK (cost >= 0),
    CONSTRAINT chk_vehicle_maintenances_dates CHECK (completed_date IS NULL OR completed_date >= scheduled_date)
);

-- -----------------------------------------------------------------------------
-- Archivo: vehicle-statuses.sql
-- -----------------------------------------------------------------------------
CREATE TABLE fleet.vehicle_statuses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(30) NOT NULL,
    name VARCHAR(100) NOT NULL,
    allows_reservation BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_vehicle_statuses_code UNIQUE (code),
    CONSTRAINT chk_vehicle_statuses_code_format CHECK (code ~ '^[A-Z][A-Z_]*$'),
    CONSTRAINT chk_vehicle_statuses_name_not_blank CHECK (btrim(name) <> '')
);

-- -----------------------------------------------------------------------------
-- Archivo: vehicles.sql
-- -----------------------------------------------------------------------------
CREATE TABLE fleet.vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    plate VARCHAR(10) NOT NULL,
    vin VARCHAR(17) NOT NULL,
    brand_id UUID NOT NULL,
    category_id UUID NOT NULL,
    transmission_type_id UUID NOT NULL,
    fuel_type_id UUID NOT NULL,
    status_id UUID NOT NULL,
    current_branch_id UUID NOT NULL,
    model VARCHAR(100) NOT NULL,
    year SMALLINT NOT NULL,
    color VARCHAR(50),
    passenger_capacity SMALLINT NOT NULL,
    doors_count SMALLINT,
    trunk_capacity_liters INTEGER,
    mileage INTEGER NOT NULL DEFAULT 0,
    daily_rate NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    main_image_url VARCHAR(2048),
    is_featured BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_vehicles_plate UNIQUE (plate),
    CONSTRAINT uq_vehicles_vin UNIQUE (vin),
    CONSTRAINT fk_vehicles_brand FOREIGN KEY (brand_id) REFERENCES fleet.vehicle_brands (id),
    CONSTRAINT fk_vehicles_category FOREIGN KEY (category_id) REFERENCES fleet.vehicle_categories (id),
    CONSTRAINT fk_vehicles_transmission_type FOREIGN KEY (transmission_type_id) REFERENCES fleet.transmission_types (id),
    CONSTRAINT fk_vehicles_fuel_type FOREIGN KEY (fuel_type_id) REFERENCES fleet.fuel_types (id),
    CONSTRAINT fk_vehicles_status FOREIGN KEY (status_id) REFERENCES fleet.vehicle_statuses (id),
    CONSTRAINT fk_vehicles_current_branch FOREIGN KEY (current_branch_id) REFERENCES location.branches (id),
    CONSTRAINT chk_vehicles_plate_not_blank CHECK (btrim(plate) <> ''),
    CONSTRAINT chk_vehicles_vin_not_blank CHECK (btrim(vin) <> ''),
    CONSTRAINT chk_vehicles_model_not_blank CHECK (btrim(model) <> ''),
    CONSTRAINT chk_vehicles_year CHECK (year BETWEEN 1900 AND 2100),
    CONSTRAINT chk_vehicles_passenger_capacity CHECK (passenger_capacity > 0),
    CONSTRAINT chk_vehicles_mileage CHECK (mileage >= 0),
    CONSTRAINT chk_vehicles_daily_rate CHECK (daily_rate >= 0)
);

-- =============================================================================
-- SECCIÓN: 03 TABLAS DDL - ESQUEMA [CATALOG]
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: additional-services.sql
-- -----------------------------------------------------------------------------
CREATE TABLE catalog.additional_services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(120) NOT NULL,
    daily_rate NUMERIC(12, 2) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_additional_services_name UNIQUE (name),
    CONSTRAINT chk_additional_services_name_not_blank CHECK (btrim(name) <> ''),
    CONSTRAINT chk_additional_services_daily_rate_nonnegative CHECK (daily_rate >= 0)
);

-- -----------------------------------------------------------------------------
-- Archivo: insurance-coverages.sql
-- -----------------------------------------------------------------------------
CREATE TABLE catalog.insurance_coverages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(120) NOT NULL,
    daily_rate NUMERIC(12, 2) NOT NULL,
    description TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_insurance_coverages_name UNIQUE (name),
    CONSTRAINT chk_insurance_coverages_name_not_blank CHECK (btrim(name) <> ''),
    CONSTRAINT chk_insurance_coverages_description_not_blank CHECK (btrim(description) <> ''),
    CONSTRAINT chk_insurance_coverages_daily_rate_nonnegative CHECK (daily_rate >= 0)
);

-- -----------------------------------------------------------------------------
-- Archivo: mileage-plans.sql
-- -----------------------------------------------------------------------------
CREATE TABLE catalog.mileage_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(120) NOT NULL,
    included_km INT,
    daily_rate NUMERIC(12, 2) NOT NULL,
    extra_km_rate NUMERIC(12, 2) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_mileage_plans_name UNIQUE (name),
    CONSTRAINT chk_mileage_plans_name_not_blank CHECK (btrim(name) <> ''),
    CONSTRAINT chk_mileage_plans_included_km_nonnegative CHECK (included_km IS NULL OR included_km >= 0),
    CONSTRAINT chk_mileage_plans_daily_rate_nonnegative CHECK (daily_rate >= 0),
    CONSTRAINT chk_mileage_plans_extra_km_rate_nonnegative CHECK (extra_km_rate >= 0)
);

-- -----------------------------------------------------------------------------
-- Archivo: promotions.sql
-- -----------------------------------------------------------------------------
CREATE TABLE catalog.promotions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL,
    offer_type VARCHAR(20) NOT NULL,
    discount_type VARCHAR(20) NOT NULL,
    discount_value NUMERIC(12, 2) NOT NULL,
    starts_at TIMESTAMPTZ NOT NULL,
    ends_at TIMESTAMPTZ NOT NULL,
    minimum_rental_days INT NOT NULL DEFAULT 1,
    max_uses_limit INT,
    current_uses_count INT NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_promotions_code_not_blank CHECK (btrim(code) <> ''),
    CONSTRAINT chk_promotions_offer_type CHECK (offer_type IN ('PROMOTION', 'COUPON')),
    CONSTRAINT chk_promotions_discount_type CHECK (discount_type IN ('PERCENTAGE', 'FIXED_AMOUNT')),
    CONSTRAINT chk_promotions_discount_value_positive CHECK (discount_value > 0),
    CONSTRAINT chk_promotions_percentage_maximum CHECK (discount_type <> 'PERCENTAGE' OR discount_value <= 100),
    CONSTRAINT chk_promotions_date_range CHECK (ends_at > starts_at),
    CONSTRAINT chk_promotions_minimum_rental_days CHECK (minimum_rental_days >= 1),
    CONSTRAINT chk_promotions_use_counts CHECK (
        current_uses_count >= 0
        AND (max_uses_limit IS NULL OR max_uses_limit >= current_uses_count)
    )
);

-- -----------------------------------------------------------------------------
-- Archivo: user-coupon-usages.sql
-- -----------------------------------------------------------------------------
CREATE TABLE catalog.user_coupon_usages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    promotion_id UUID NOT NULL,
    user_id UUID NOT NULL,
    used_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    discount_amount NUMERIC(12, 2) NOT NULL,
    CONSTRAINT fk_user_coupon_usages_promotion
        FOREIGN KEY (promotion_id) REFERENCES catalog.promotions (id) ON DELETE RESTRICT,
    CONSTRAINT fk_user_coupon_usages_user
        FOREIGN KEY (user_id) REFERENCES iam.users (id) ON DELETE RESTRICT,
    CONSTRAINT chk_user_coupon_usages_discount_amount_nonnegative CHECK (discount_amount >= 0)
);

-- =============================================================================
-- SECCIÓN: 03 TABLAS DDL - ESQUEMA [RENTAL]
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: branch-reviews.sql
-- -----------------------------------------------------------------------------
CREATE TABLE rental.branch_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    branch_id UUID NOT NULL,
    user_id UUID NOT NULL,
    reservation_id UUID NOT NULL,
    rating SMALLINT NOT NULL,
    comment VARCHAR(1000),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_branch_reviews_reservation_branch UNIQUE (reservation_id, branch_id),
    CONSTRAINT fk_branch_reviews_branch FOREIGN KEY (branch_id) REFERENCES location.branches (id) ON DELETE RESTRICT,
    CONSTRAINT fk_branch_reviews_user FOREIGN KEY (user_id) REFERENCES iam.users (id) ON DELETE RESTRICT,
    CONSTRAINT fk_branch_reviews_reservation FOREIGN KEY (reservation_id) REFERENCES rental.reservations (id) ON DELETE RESTRICT,
    CONSTRAINT chk_branch_reviews_rating CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT chk_branch_reviews_comment_not_blank CHECK (comment IS NULL OR btrim(comment) <> '')
);

-- -----------------------------------------------------------------------------
-- Archivo: rental-extension-requests.sql
-- -----------------------------------------------------------------------------
CREATE TABLE rental.rental_extension_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reservation_id UUID NOT NULL,
    requested_return_date TIMESTAMPTZ NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    additional_amount NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    reviewed_by UUID,
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rental_extension_requests_reservation
        FOREIGN KEY (reservation_id) REFERENCES rental.reservations (id) ON DELETE CASCADE,
    CONSTRAINT fk_rental_extension_requests_reviewer
        FOREIGN KEY (reviewed_by) REFERENCES iam.users (id) ON DELETE SET NULL,
    CONSTRAINT chk_rental_extension_requests_status
        CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED')),
    CONSTRAINT chk_rental_extension_requests_additional_amount_nonnegative
        CHECK (additional_amount >= 0)
);

-- -----------------------------------------------------------------------------
-- Archivo: reservation-additional-services.sql
-- -----------------------------------------------------------------------------
CREATE TABLE rental.reservation_additional_services (
    reservation_id UUID NOT NULL,
    additional_service_id UUID NOT NULL,
    quantity SMALLINT NOT NULL DEFAULT 1,
    daily_rate NUMERIC(12, 2) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_reservation_additional_services
        PRIMARY KEY (reservation_id, additional_service_id),
    CONSTRAINT fk_reservation_additional_services_reservation
        FOREIGN KEY (reservation_id) REFERENCES rental.reservations (id) ON DELETE CASCADE,
    CONSTRAINT fk_reservation_additional_services_service
        FOREIGN KEY (additional_service_id) REFERENCES catalog.additional_services (id) ON DELETE RESTRICT,
    CONSTRAINT chk_reservation_additional_services_quantity_positive
        CHECK (quantity > 0),
    CONSTRAINT chk_reservation_additional_services_daily_rate_nonnegative
        CHECK (daily_rate >= 0)
);

-- -----------------------------------------------------------------------------
-- Archivo: reservation-delivery-points.sql
-- -----------------------------------------------------------------------------
CREATE TABLE rental.reservation_delivery_points (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reservation_id UUID NOT NULL,
    point_type VARCHAR(10) NOT NULL,
    modality VARCHAR(20) NOT NULL,
    branch_id UUID,
    city_id UUID,
    neighborhood VARCHAR(120),
    address VARCHAR(255),
    flight_or_bus_number VARCHAR(60),
    reference_details VARCHAR(500),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_reservation_delivery_points_reservation
        FOREIGN KEY (reservation_id) REFERENCES rental.reservations (id) ON DELETE CASCADE,
    CONSTRAINT fk_reservation_delivery_points_branch
        FOREIGN KEY (branch_id) REFERENCES location.branches (id),
    CONSTRAINT fk_reservation_delivery_points_city
        FOREIGN KEY (city_id) REFERENCES location.cities (id),
    CONSTRAINT uq_reservation_delivery_points_reservation_point_type
        UNIQUE (reservation_id, point_type),
    CONSTRAINT chk_reservation_delivery_points_point_type
        CHECK (point_type IN ('PICKUP', 'RETURN')),
    CONSTRAINT chk_reservation_delivery_points_modality
        CHECK (modality IN ('BRANCH', 'HOME_DELIVERY', 'AIRPORT', 'TERMINAL')),
    CONSTRAINT chk_reservation_delivery_points_modality_data
        CHECK (
            (modality = 'BRANCH' AND branch_id IS NOT NULL AND city_id IS NULL AND address IS NULL)
            OR (modality = 'HOME_DELIVERY' AND branch_id IS NULL AND city_id IS NOT NULL AND address IS NOT NULL)
            OR (modality IN ('AIRPORT', 'TERMINAL') AND branch_id IS NULL AND city_id IS NOT NULL)
        ),
    CONSTRAINT chk_reservation_delivery_points_neighborhood_not_blank
        CHECK (neighborhood IS NULL OR btrim(neighborhood) <> ''),
    CONSTRAINT chk_reservation_delivery_points_address_not_blank
        CHECK (address IS NULL OR btrim(address) <> ''),
    CONSTRAINT chk_reservation_delivery_points_flight_or_bus_number_not_blank
        CHECK (flight_or_bus_number IS NULL OR btrim(flight_or_bus_number) <> ''),
    CONSTRAINT chk_reservation_delivery_points_reference_details_not_blank
        CHECK (reference_details IS NULL OR btrim(reference_details) <> '')
);

-- -----------------------------------------------------------------------------
-- Archivo: reservation-promotions.sql
-- -----------------------------------------------------------------------------
CREATE TABLE rental.reservation_promotions (
    reservation_id UUID NOT NULL,
    promotion_id UUID NOT NULL,
    discount_applied NUMERIC(12, 2) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_reservation_promotions
        PRIMARY KEY (reservation_id, promotion_id),
    CONSTRAINT fk_reservation_promotions_reservation
        FOREIGN KEY (reservation_id) REFERENCES rental.reservations (id) ON DELETE CASCADE,
    CONSTRAINT fk_reservation_promotions_promotion
        FOREIGN KEY (promotion_id) REFERENCES catalog.promotions (id) ON DELETE RESTRICT,
    CONSTRAINT chk_reservation_promotions_discount_applied_nonnegative
        CHECK (discount_applied >= 0)
);

-- -----------------------------------------------------------------------------
-- Archivo: reservation-statuses.sql
-- -----------------------------------------------------------------------------
CREATE TABLE rental.reservation_statuses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(30) NOT NULL,
    name VARCHAR(100) NOT NULL,
    blocks_availability BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_reservation_statuses_code UNIQUE (code),
    CONSTRAINT chk_reservation_statuses_code_format CHECK (code ~ '^[A-Z][A-Z_]*$'),
    CONSTRAINT chk_reservation_statuses_name_not_blank CHECK (btrim(name) <> '')
);

-- -----------------------------------------------------------------------------
-- Archivo: reservations.sql
-- -----------------------------------------------------------------------------
CREATE TABLE rental.reservations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(30) NOT NULL,
    customer_id UUID NOT NULL,
    vehicle_id UUID NOT NULL,
    status_id UUID NOT NULL,
    insurance_coverage_id UUID NOT NULL,
    mileage_plan_id UUID NOT NULL,
    cash_payment_branch_id UUID,
    pickup_date TIMESTAMPTZ NOT NULL,
    return_date TIMESTAMPTZ NOT NULL,
    daily_rate NUMERIC(12, 2) NOT NULL,
    total_estimated NUMERIC(12, 2) NOT NULL,
    cash_payment_code VARCHAR(30),
    cash_payment_expires_at TIMESTAMPTZ,
    blocks_availability BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_reservations_code UNIQUE (code),
    CONSTRAINT uq_reservations_cash_payment_code UNIQUE (cash_payment_code),
    CONSTRAINT fk_reservations_customer FOREIGN KEY (customer_id) REFERENCES iam.users (id),
    CONSTRAINT fk_reservations_vehicle FOREIGN KEY (vehicle_id) REFERENCES fleet.vehicles (id),
    CONSTRAINT fk_reservations_status FOREIGN KEY (status_id) REFERENCES rental.reservation_statuses (id),
    CONSTRAINT fk_reservations_insurance_coverage FOREIGN KEY (insurance_coverage_id) REFERENCES catalog.insurance_coverages (id),
    CONSTRAINT fk_reservations_mileage_plan FOREIGN KEY (mileage_plan_id) REFERENCES catalog.mileage_plans (id),
    CONSTRAINT fk_reservations_cash_payment_branch FOREIGN KEY (cash_payment_branch_id) REFERENCES location.branches (id),
    CONSTRAINT chk_reservations_code_not_blank CHECK (btrim(code) <> ''),
    CONSTRAINT chk_reservations_period CHECK (return_date > pickup_date),
    CONSTRAINT chk_reservations_daily_rate_nonnegative CHECK (daily_rate >= 0),
    CONSTRAINT chk_reservations_total_estimated_nonnegative CHECK (total_estimated >= 0),
    CONSTRAINT chk_reservations_cash_payment_code_not_blank CHECK (cash_payment_code IS NULL OR btrim(cash_payment_code) <> '')
);

-- -----------------------------------------------------------------------------
-- Archivo: vehicle-ratings.sql
-- -----------------------------------------------------------------------------
CREATE TABLE rental.vehicle_ratings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reservation_id UUID NOT NULL,
    vehicle_id UUID NOT NULL,
    user_id UUID NOT NULL,
    rating SMALLINT NOT NULL,
    comment VARCHAR(1000),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_vehicle_ratings_reservation UNIQUE (reservation_id),
    CONSTRAINT fk_vehicle_ratings_reservation FOREIGN KEY (reservation_id) REFERENCES rental.reservations (id) ON DELETE RESTRICT,
    CONSTRAINT fk_vehicle_ratings_vehicle FOREIGN KEY (vehicle_id) REFERENCES fleet.vehicles (id) ON DELETE RESTRICT,
    CONSTRAINT fk_vehicle_ratings_user FOREIGN KEY (user_id) REFERENCES iam.users (id) ON DELETE RESTRICT,
    CONSTRAINT chk_vehicle_ratings_rating CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT chk_vehicle_ratings_comment_not_blank CHECK (comment IS NULL OR btrim(comment) <> '')
);

-- =============================================================================
-- SECCIÓN: 03 TABLAS DDL - ESQUEMA [CONTRACT]
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: contract-clause-assignments.sql
-- -----------------------------------------------------------------------------
CREATE TABLE contract.contract_clause_assignments (
    contract_id UUID NOT NULL,
    clause_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_contract_clause_assignments
        PRIMARY KEY (contract_id, clause_id),
    CONSTRAINT fk_contract_clause_assignments_contract
        FOREIGN KEY (contract_id) REFERENCES contract.rental_contracts (id) ON DELETE CASCADE,
    CONSTRAINT fk_contract_clause_assignments_clause
        FOREIGN KEY (clause_id) REFERENCES contract.contract_clauses (id) ON DELETE RESTRICT
);

-- -----------------------------------------------------------------------------
-- Archivo: contract-clauses.sql
-- -----------------------------------------------------------------------------
CREATE TABLE contract.contract_clauses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    version VARCHAR(40) NOT NULL,
    sort_order SMALLINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_contract_clauses_version_sort_order UNIQUE (version, sort_order),
    CONSTRAINT chk_contract_clauses_version_not_blank CHECK (btrim(version) <> ''),
    CONSTRAINT chk_contract_clauses_sort_order_positive CHECK (sort_order > 0),
    CONSTRAINT chk_contract_clauses_title_not_blank CHECK (btrim(title) <> ''),
    CONSTRAINT chk_contract_clauses_content_not_blank CHECK (btrim(content) <> '')
);

-- -----------------------------------------------------------------------------
-- Archivo: contract-statuses.sql
-- -----------------------------------------------------------------------------
CREATE TABLE contract.contract_statuses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(40) NOT NULL,
    name VARCHAR(80) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_final BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_contract_statuses_code UNIQUE (code),
    CONSTRAINT uq_contract_statuses_name UNIQUE (name),
    CONSTRAINT chk_contract_statuses_code_not_blank CHECK (btrim(code) <> ''),
    CONSTRAINT chk_contract_statuses_name_not_blank CHECK (btrim(name) <> '')
);

-- -----------------------------------------------------------------------------
-- Archivo: inspection-checklist-answers.sql
-- -----------------------------------------------------------------------------
CREATE TABLE contract.inspection_checklist_answers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    inspection_id UUID NOT NULL,
    checklist_item_id UUID NOT NULL,
    is_compliant BOOLEAN NOT NULL DEFAULT TRUE,
    observation TEXT,
    evidence_photo_url VARCHAR(1000),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_inspection_checklist_answers_item
        UNIQUE (inspection_id, checklist_item_id),
    CONSTRAINT fk_inspection_checklist_answers_inspection
        FOREIGN KEY (inspection_id) REFERENCES contract.vehicle_inspections (id) ON DELETE CASCADE,
    CONSTRAINT fk_inspection_checklist_answers_item
        FOREIGN KEY (checklist_item_id) REFERENCES contract.inspection_checklist_items (id) ON DELETE RESTRICT,
    CONSTRAINT chk_inspection_checklist_answers_observation_not_blank
        CHECK (observation IS NULL OR btrim(observation) <> ''),
    CONSTRAINT chk_inspection_checklist_answers_evidence_url_not_blank
        CHECK (evidence_photo_url IS NULL OR btrim(evidence_photo_url) <> '')
);

-- -----------------------------------------------------------------------------
-- Archivo: inspection-checklist-items.sql
-- -----------------------------------------------------------------------------
CREATE TABLE contract.inspection_checklist_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(120) NOT NULL,
    description VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_inspection_checklist_items_name
        UNIQUE (name),
    CONSTRAINT chk_inspection_checklist_items_name_not_blank
        CHECK (btrim(name) <> ''),
    CONSTRAINT chk_inspection_checklist_items_description_not_blank
        CHECK (description IS NULL OR btrim(description) <> '')
);

-- -----------------------------------------------------------------------------
-- Archivo: rental-contracts.sql
-- -----------------------------------------------------------------------------
CREATE TABLE contract.rental_contracts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_number VARCHAR(30) NOT NULL,
    reservation_id UUID NOT NULL,
    customer_id UUID NOT NULL,
    vehicle_id UUID NOT NULL,
    status_id UUID NOT NULL,
    pickup_branch_id UUID NOT NULL,
    return_branch_id UUID NOT NULL,
    scheduled_start_at TIMESTAMPTZ NOT NULL,
    scheduled_end_at TIMESTAMPTZ NOT NULL,
    base_amount NUMERIC(12, 2) NOT NULL,
    security_deposit NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    signature_url VARCHAR(1000),
    signature_stroke_data JSONB,
    signed_city_id UUID,
    signed_at TIMESTAMPTZ,
    pdf_url VARCHAR(1000),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_rental_contracts_contract_number UNIQUE (contract_number),
    CONSTRAINT uq_rental_contracts_reservation UNIQUE (reservation_id),
    CONSTRAINT fk_rental_contracts_reservation
        FOREIGN KEY (reservation_id) REFERENCES rental.reservations (id) ON DELETE CASCADE,
    CONSTRAINT fk_rental_contracts_customer
        FOREIGN KEY (customer_id) REFERENCES iam.users (id) ON DELETE RESTRICT,
    CONSTRAINT fk_rental_contracts_vehicle
        FOREIGN KEY (vehicle_id) REFERENCES fleet.vehicles (id) ON DELETE RESTRICT,
    CONSTRAINT fk_rental_contracts_status
        FOREIGN KEY (status_id) REFERENCES contract.contract_statuses (id) ON DELETE RESTRICT,
    CONSTRAINT fk_rental_contracts_pickup_branch
        FOREIGN KEY (pickup_branch_id) REFERENCES location.branches (id) ON DELETE RESTRICT,
    CONSTRAINT fk_rental_contracts_return_branch
        FOREIGN KEY (return_branch_id) REFERENCES location.branches (id) ON DELETE RESTRICT,
    CONSTRAINT fk_rental_contracts_signed_city
        FOREIGN KEY (signed_city_id) REFERENCES location.cities (id) ON DELETE RESTRICT,
    CONSTRAINT chk_rental_contracts_contract_number_not_blank CHECK (btrim(contract_number) <> ''),
    CONSTRAINT chk_rental_contracts_scheduled_period CHECK (scheduled_end_at > scheduled_start_at),
    CONSTRAINT chk_rental_contracts_base_amount_nonnegative CHECK (base_amount >= 0),
    CONSTRAINT chk_rental_contracts_security_deposit_nonnegative CHECK (security_deposit >= 0),
    CONSTRAINT chk_rental_contracts_signature_url_not_blank CHECK (signature_url IS NULL OR btrim(signature_url) <> ''),
    CONSTRAINT chk_rental_contracts_pdf_url_not_blank CHECK (pdf_url IS NULL OR btrim(pdf_url) <> '')
);

-- -----------------------------------------------------------------------------
-- Archivo: vehicle-inspections.sql
-- -----------------------------------------------------------------------------
CREATE TABLE contract.vehicle_inspections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id UUID NOT NULL,
    inspection_type VARCHAR(20) NOT NULL,
    inspector_user_id UUID NOT NULL,
    mileage INTEGER NOT NULL,
    fuel_level_percent NUMERIC(5, 2) NOT NULL,
    observations TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_vehicle_inspections_contract_type
        UNIQUE (contract_id, inspection_type),
    CONSTRAINT fk_vehicle_inspections_contract
        FOREIGN KEY (contract_id) REFERENCES contract.rental_contracts (id) ON DELETE CASCADE,
    CONSTRAINT fk_vehicle_inspections_inspector
        FOREIGN KEY (inspector_user_id) REFERENCES iam.users (id) ON DELETE RESTRICT,
    CONSTRAINT chk_vehicle_inspections_type
        CHECK (inspection_type IN ('CHECK_IN', 'CHECK_OUT')),
    CONSTRAINT chk_vehicle_inspections_mileage_nonnegative
        CHECK (mileage >= 0),
    CONSTRAINT chk_vehicle_inspections_fuel_level_percent
        CHECK (fuel_level_percent >= 0.00 AND fuel_level_percent <= 100.00),
    CONSTRAINT chk_vehicle_inspections_observations_not_blank
        CHECK (observations IS NULL OR btrim(observations) <> '')
);

-- =============================================================================
-- SECCIÓN: 03 TABLAS DDL - ESQUEMA [BILLING]
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: payment-methods.sql
-- -----------------------------------------------------------------------------
CREATE TABLE billing.payment_methods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(30) NOT NULL,
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_payment_methods_code UNIQUE (code),
    CONSTRAINT chk_payment_methods_code_format CHECK (code ~ '^[A-Z][A-Z_]*$'),
    CONSTRAINT chk_payment_methods_name_not_blank CHECK (btrim(name) <> '')
);

-- -----------------------------------------------------------------------------
-- Archivo: payment-receipts.sql
-- -----------------------------------------------------------------------------
CREATE TABLE billing.payment_receipts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id UUID NOT NULL,
    receipt_number VARCHAR(50) NOT NULL,
    pdf_url VARCHAR(1000) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_payment_receipts_payment UNIQUE (payment_id),
    CONSTRAINT uq_payment_receipts_number UNIQUE (receipt_number),
    CONSTRAINT fk_payment_receipts_payment FOREIGN KEY (payment_id) REFERENCES billing.payments (id) ON DELETE RESTRICT,
    CONSTRAINT chk_payment_receipts_number_not_blank CHECK (btrim(receipt_number) <> ''),
    CONSTRAINT chk_payment_receipts_pdf_url_not_blank CHECK (btrim(pdf_url) <> '')
);

-- -----------------------------------------------------------------------------
-- Archivo: payment-statuses.sql
-- -----------------------------------------------------------------------------
CREATE TABLE billing.payment_statuses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(30) NOT NULL,
    name VARCHAR(100) NOT NULL,
    is_final BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_payment_statuses_code UNIQUE (code),
    CONSTRAINT chk_payment_statuses_code_format CHECK (code ~ '^[A-Z][A-Z_]*$'),
    CONSTRAINT chk_payment_statuses_name_not_blank CHECK (btrim(name) <> '')
);

-- -----------------------------------------------------------------------------
-- Archivo: payments.sql
-- -----------------------------------------------------------------------------
CREATE TABLE billing.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id UUID NOT NULL,
    payment_method_id UUID NOT NULL,
    status_id UUID NOT NULL,
    gateway_provider VARCHAR(30) NOT NULL,
    gateway_reference VARCHAR(100) NOT NULL,
    amount NUMERIC(12, 2) NOT NULL,
    currency_id UUID NOT NULL,
    paid_at TIMESTAMPTZ,
    confirmed_by_user_id UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_payments_gateway_reference UNIQUE (gateway_provider, gateway_reference),
    CONSTRAINT fk_payments_contract FOREIGN KEY (contract_id) REFERENCES contract.rental_contracts (id) ON DELETE RESTRICT,
    CONSTRAINT fk_payments_method FOREIGN KEY (payment_method_id) REFERENCES billing.payment_methods (id) ON DELETE RESTRICT,
    CONSTRAINT fk_payments_status FOREIGN KEY (status_id) REFERENCES billing.payment_statuses (id) ON DELETE RESTRICT,
    CONSTRAINT fk_payments_currency FOREIGN KEY (currency_id) REFERENCES core.currencies (id) ON DELETE RESTRICT,
    CONSTRAINT fk_payments_confirmed_by FOREIGN KEY (confirmed_by_user_id) REFERENCES iam.users (id) ON DELETE RESTRICT,
    CONSTRAINT chk_payments_gateway_provider CHECK (gateway_provider IN ('WOMPI', 'EFECTIVO_CAJA')),
    CONSTRAINT chk_payments_gateway_reference_not_blank CHECK (btrim(gateway_reference) <> ''),
    CONSTRAINT chk_payments_amount_positive CHECK (amount > 0)
);

-- -----------------------------------------------------------------------------
-- Archivo: user-saved-payment-methods.sql
-- -----------------------------------------------------------------------------
CREATE TABLE billing.user_saved_payment_methods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    gateway_provider VARCHAR(30) NOT NULL DEFAULT 'WOMPI',
    payment_token VARCHAR(255) NOT NULL,
    card_brand VARCHAR(50) NOT NULL,
    last_four CHAR(4) NOT NULL,
    exp_month SMALLINT NOT NULL,
    exp_year SMALLINT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_user_saved_payment_methods_token UNIQUE (payment_token),
    CONSTRAINT fk_user_saved_payment_methods_user FOREIGN KEY (user_id) REFERENCES iam.users (id) ON DELETE RESTRICT,
    CONSTRAINT chk_user_saved_payment_methods_provider CHECK (gateway_provider = 'WOMPI'),
    CONSTRAINT chk_user_saved_payment_methods_token_not_blank CHECK (btrim(payment_token) <> ''),
    CONSTRAINT chk_user_saved_payment_methods_token_not_pan CHECK (payment_token !~ '^[0-9]{13,19}$'),
    CONSTRAINT chk_user_saved_payment_methods_brand_not_blank CHECK (btrim(card_brand) <> ''),
    CONSTRAINT chk_user_saved_payment_methods_last_four CHECK (last_four ~ '^[0-9]{4}$'),
    CONSTRAINT chk_user_saved_payment_methods_exp_month CHECK (exp_month BETWEEN 1 AND 12),
    CONSTRAINT chk_user_saved_payment_methods_exp_year CHECK (exp_year >= 2024)
);

-- =============================================================================
-- SECCIÓN: 03 TABLAS DDL - ESQUEMA [SUPPORT]
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: idempotency-keys.sql
-- -----------------------------------------------------------------------------
-- Protocolo de idempotencia (cabecera Idempotency-Key): guarda el resultado de cada operacion de reservas y pagos
-- para devolver la MISMA respuesta si el cliente repite la peticion (doble clic, reintento de red, timeout).
-- La restriccion unica (persona, clave) es lo que serializa dos peticiones simultaneas con la misma clave.
CREATE TABLE IF NOT EXISTS support.idempotency_keys (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_email VARCHAR(254) NOT NULL,
    idempotency_key VARCHAR(80) NOT NULL,
    http_method VARCHAR(10) NOT NULL,
    request_path VARCHAR(255) NOT NULL,
    request_hash VARCHAR(64) NOT NULL,
    status VARCHAR(12) NOT NULL,
    response_status INTEGER,
    response_content_type VARCHAR(100),
    response_body TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    completed_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ NOT NULL,
    CONSTRAINT uq_idempotency_keys_scope UNIQUE (user_email, idempotency_key),
    CONSTRAINT chk_idempotency_keys_status CHECK (status IN ('IN_PROGRESS', 'COMPLETED'))
);

CREATE INDEX IF NOT EXISTS idx_idempotency_keys_expires ON support.idempotency_keys (expires_at);

-- -----------------------------------------------------------------------------
-- Archivo: incident-reports.sql
-- -----------------------------------------------------------------------------
CREATE TABLE support.incident_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    incident_code VARCHAR(30) NOT NULL,
    vehicle_id UUID,
    reservation_id UUID,
    reported_by_user_id UUID NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'OPEN',
    priority VARCHAR(20) NOT NULL DEFAULT 'MEDIUM',
    subject VARCHAR(150) NOT NULL,
    description TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_incident_reports_incident_code UNIQUE (incident_code),
    CONSTRAINT fk_incident_reports_vehicle FOREIGN KEY (vehicle_id) REFERENCES fleet.vehicles (id) ON DELETE RESTRICT,
    CONSTRAINT fk_incident_reports_reservation FOREIGN KEY (reservation_id) REFERENCES rental.reservations (id) ON DELETE RESTRICT,
    CONSTRAINT fk_incident_reports_reported_by FOREIGN KEY (reported_by_user_id) REFERENCES iam.users (id) ON DELETE RESTRICT,
    CONSTRAINT chk_incident_reports_status CHECK (status IN ('OPEN', 'IN_REVIEW', 'RESOLVED', 'CLOSED')),
    CONSTRAINT chk_incident_reports_priority CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    CONSTRAINT chk_incident_reports_incident_code_not_blank CHECK (btrim(incident_code) <> ''),
    CONSTRAINT chk_incident_reports_subject_not_blank CHECK (btrim(subject) <> ''),
    CONSTRAINT chk_incident_reports_description_not_blank CHECK (btrim(description) <> '')
);

-- -----------------------------------------------------------------------------
-- Archivo: incident-responses.sql
-- -----------------------------------------------------------------------------
CREATE TABLE support.incident_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    incident_report_id UUID NOT NULL,
    author_user_id UUID NOT NULL,
    message TEXT NOT NULL,
    attachment_url VARCHAR(500),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_incident_responses_report FOREIGN KEY (incident_report_id) REFERENCES support.incident_reports (id) ON DELETE CASCADE,
    CONSTRAINT fk_incident_responses_author FOREIGN KEY (author_user_id) REFERENCES iam.users (id) ON DELETE RESTRICT,
    CONSTRAINT chk_incident_responses_message_not_blank CHECK (btrim(message) <> ''),
    CONSTRAINT chk_incident_responses_attachment_url_not_blank CHECK (attachment_url IS NULL OR btrim(attachment_url) <> '')
);

-- -----------------------------------------------------------------------------
-- Archivo: notification-delivery-attempts.sql
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS support.notification_delivery_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    outbox_id UUID NOT NULL,
    attempt_number INTEGER NOT NULL,
    provider VARCHAR(50) NOT NULL,
    status VARCHAR(30) NOT NULL,
    provider_message_id VARCHAR(100),
    error_code VARCHAR(50),
    error_message TEXT,
    attempted_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notification_attempts_outbox
        FOREIGN KEY (outbox_id) REFERENCES support.notification_outbox (id) ON DELETE CASCADE,
    CONSTRAINT chk_notification_attempts_number
        CHECK (attempt_number > 0),
    CONSTRAINT chk_notification_attempts_status
        CHECK (status IN ('SUCCESS', 'FAILED', 'REJECTED', 'TIMEOUT')),
    CONSTRAINT chk_notification_attempts_provider_not_blank
        CHECK (btrim(provider) <> ''),
    CONSTRAINT uq_notification_delivery_attempts_number
        UNIQUE (outbox_id, attempt_number)
);

CREATE INDEX IF NOT EXISTS idx_notification_attempts_outbox
    ON support.notification_delivery_attempts (outbox_id);

CREATE INDEX IF NOT EXISTS idx_notification_attempts_provider_status
    ON support.notification_delivery_attempts (provider, status);

-- -----------------------------------------------------------------------------
-- Archivo: notification-outbox.sql
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS support.notification_outbox (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    notification_id UUID NOT NULL,
    channel VARCHAR(20) NOT NULL,
    recipient VARCHAR(255) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    retry_count INTEGER NOT NULL DEFAULT 0,
    max_retries INTEGER NOT NULL DEFAULT 3,
    next_retry_at TIMESTAMPTZ,
    scheduled_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMPTZ,
    idempotency_key VARCHAR(100),
    metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notification_outbox_notification
        FOREIGN KEY (notification_id) REFERENCES support.notifications (id) ON DELETE CASCADE,
    CONSTRAINT chk_notification_outbox_channel
        CHECK (channel IN ('EMAIL', 'SMS', 'PUSH', 'IN_APP')),
    CONSTRAINT chk_notification_outbox_status
        CHECK (status IN ('PENDING', 'PROCESSING', 'SENT', 'FAILED', 'DEAD_LETTER')),
    CONSTRAINT chk_notification_outbox_retry_count
        CHECK (retry_count >= 0),
    CONSTRAINT chk_notification_outbox_max_retries
        CHECK (max_retries >= 0),
    CONSTRAINT chk_notification_outbox_recipient_not_blank
        CHECK (btrim(recipient) <> ''),
    CONSTRAINT uq_notification_outbox_idempotency
        UNIQUE (idempotency_key)
);

CREATE TRIGGER trg_notification_outbox_set_updated_at
    BEFORE UPDATE ON support.notification_outbox
    FOR EACH ROW
    EXECUTE FUNCTION core.set_updated_at();

CREATE INDEX IF NOT EXISTS idx_notification_outbox_pending
    ON support.notification_outbox (status, next_retry_at)
    WHERE status IN ('PENDING', 'FAILED');

CREATE INDEX IF NOT EXISTS idx_notification_outbox_notification
    ON support.notification_outbox (notification_id);

CREATE INDEX IF NOT EXISTS idx_notification_outbox_channel
    ON support.notification_outbox (channel);

-- -----------------------------------------------------------------------------
-- Archivo: notification-templates.sql
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS support.notification_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(60) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    channel VARCHAR(20) NOT NULL,
    subject_template VARCHAR(250) NOT NULL,
    body_template TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_notification_templates_channel
        CHECK (channel IN ('EMAIL', 'SMS', 'PUSH', 'IN_APP')),
    CONSTRAINT chk_notification_templates_event_type
        CHECK (event_type IN ('REGISTRATION', 'PAYMENT', 'RESERVATION', 'CANCELLATION', 'CONTRACT', 'DELIVERY', 'RETURN', 'DOCUMENT', 'INCIDENT', 'SECURITY', 'PROMOTION', 'GENERAL')),
    CONSTRAINT chk_notification_templates_code_not_blank
        CHECK (btrim(code) <> ''),
    CONSTRAINT chk_notification_templates_name_not_blank
        CHECK (btrim(name) <> ''),
    CONSTRAINT chk_notification_templates_body_not_blank
        CHECK (btrim(body_template) <> '')
);

CREATE TRIGGER trg_notification_templates_set_updated_at
    BEFORE UPDATE ON support.notification_templates
    FOR EACH ROW
    EXECUTE FUNCTION core.set_updated_at();

CREATE INDEX IF NOT EXISTS idx_notification_templates_event_channel
    ON support.notification_templates (event_type, channel)
    WHERE is_active = TRUE;

-- -----------------------------------------------------------------------------
-- Archivo: notifications.sql
-- -----------------------------------------------------------------------------
CREATE TABLE support.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    channel VARCHAR(20) NOT NULL,
    type VARCHAR(30) NOT NULL,
    subject VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    reference_id UUID,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    sent_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES iam.users (id) ON DELETE RESTRICT,
    CONSTRAINT chk_notifications_channel CHECK (channel IN ('EMAIL', 'SMS', 'PUSH', 'IN_APP')),
    CONSTRAINT chk_notifications_type CHECK (type IN ('GENERAL', 'SECURITY', 'RESERVATION', 'PROMOTION')),
    CONSTRAINT chk_notifications_subject_not_blank CHECK (btrim(subject) <> ''),
    CONSTRAINT chk_notifications_message_not_blank CHECK (btrim(message) <> '')
);

-- =============================================================================
-- SECCIÓN: 03 TABLAS DDL - ESQUEMA [AUDIT]
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: administrative-report-types.sql
-- -----------------------------------------------------------------------------
CREATE TABLE audit.administrative_report_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_administrative_report_types_code UNIQUE (code),
    CONSTRAINT chk_administrative_report_types_code CHECK (code IN ('FLEET_OCCUPANCY', 'REVENUE_SUMMARY', 'AUDIT_TRAIL', 'MAINTENANCE')),
    CONSTRAINT chk_administrative_report_types_name_not_blank CHECK (btrim(name) <> '')
);

-- -----------------------------------------------------------------------------
-- Archivo: audit-logs.sql
-- -----------------------------------------------------------------------------
CREATE TABLE audit.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    domain_name VARCHAR(50) NOT NULL,
    entity_name VARCHAR(128) NOT NULL,
    entity_id UUID,
    operation VARCHAR(20) NOT NULL,
    result VARCHAR(20) NOT NULL DEFAULT 'SUCCESS',
    actor_user_id UUID,
    branch_id UUID,
    ip_address INET,
    description TEXT,
    old_data JSONB,
    new_data JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_logs_actor FOREIGN KEY (actor_user_id) REFERENCES iam.users (id) ON DELETE RESTRICT,
    CONSTRAINT fk_audit_logs_branch FOREIGN KEY (branch_id) REFERENCES location.branches (id) ON DELETE RESTRICT,
    CONSTRAINT chk_audit_logs_operation CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),
    CONSTRAINT chk_audit_logs_result CHECK (result IN ('SUCCESS', 'FAILURE')),
    CONSTRAINT chk_audit_logs_domain_not_blank CHECK (btrim(domain_name) <> ''),
    CONSTRAINT chk_audit_logs_entity_not_blank CHECK (btrim(entity_name) <> '')
);

-- -----------------------------------------------------------------------------
-- Archivo: generated-reports.sql
-- -----------------------------------------------------------------------------
CREATE TABLE audit.generated_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    report_type_id UUID NOT NULL,
    format VARCHAR(20) NOT NULL,
    generated_by UUID NOT NULL,
    filters JSONB NOT NULL DEFAULT '{}'::jsonb,
    file_url VARCHAR(500),
    status VARCHAR(20) NOT NULL DEFAULT 'COMPLETED',
    generated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_generated_reports_type FOREIGN KEY (report_type_id) REFERENCES audit.administrative_report_types (id) ON DELETE RESTRICT,
    CONSTRAINT fk_generated_reports_generated_by FOREIGN KEY (generated_by) REFERENCES iam.users (id) ON DELETE RESTRICT,
    CONSTRAINT chk_generated_reports_format CHECK (format IN ('PDF', 'EXCEL', 'WORD', 'CSV')),
    CONSTRAINT chk_generated_reports_status CHECK (status IN ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED')),
    CONSTRAINT chk_generated_reports_file_url_not_blank CHECK (file_url IS NULL OR btrim(file_url) <> '')
);

-- =============================================================================
-- SECCIÓN: 07 FUNCIONES DE BASE DE DATOS
-- =============================================================================

-- =============================================================================
-- SECCIÓN: 07 FUNCIONES DE BASE DE DATOS -> core
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: 005-create-set-updated-at-function.sql
-- -----------------------------------------------------------------------------
CREATE FUNCTION core.set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- =============================================================================
-- SECCIÓN: 07 FUNCIONES DE BASE DE DATOS -> iam
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: prevent-user-consent-mutation.sql
-- -----------------------------------------------------------------------------
CREATE FUNCTION iam.prevent_user_consent_mutation()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE EXCEPTION 'User consent records are immutable'
        USING ERRCODE = '55000';
END;
$$;

-- -----------------------------------------------------------------------------
-- Archivo: validate-user-document.sql
-- -----------------------------------------------------------------------------
CREATE FUNCTION iam.validate_user_document()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    requires_front_and_back BOOLEAN;
    status_code VARCHAR(20);
BEGIN
    SELECT document_type.requires_front_and_back
    INTO requires_front_and_back
    FROM iam.document_types AS document_type
    WHERE document_type.id = NEW.document_type_id;

    IF requires_front_and_back AND NEW.back_url IS NULL THEN
        RAISE EXCEPTION 'Documents of this type require front and back images'
            USING ERRCODE = '23514';
    END IF;

    SELECT document_status.code
    INTO status_code
    FROM iam.document_statuses AS document_status
    WHERE document_status.id = NEW.status_id;

    IF status_code IN ('APPROVED', 'REJECTED') THEN
        IF NEW.reviewed_by IS NULL OR NEW.reviewed_at IS NULL THEN
            RAISE EXCEPTION 'Approved and rejected documents require reviewer and review timestamp'
                USING ERRCODE = '23514';
        END IF;

        IF status_code = 'REJECTED' AND NEW.review_notes IS NULL THEN
            RAISE EXCEPTION 'Rejected documents require review notes'
                USING ERRCODE = '23514';
        END IF;
    ELSIF status_code = 'PENDING' AND (NEW.reviewed_by IS NOT NULL OR NEW.reviewed_at IS NOT NULL) THEN
        RAISE EXCEPTION 'Pending documents cannot have review data'
            USING ERRCODE = '23514';
    END IF;

    RETURN NEW;
END;
$$;

-- =============================================================================
-- SECCIÓN: 07 FUNCIONES DE BASE DE DATOS -> rental
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: apply-reservation-rules-payment-window.sql
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION rental.apply_reservation_rules()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    status_blocks_availability BOOLEAN;
BEGIN
    SELECT blocks_availability
    INTO status_blocks_availability
    FROM rental.reservation_statuses
    WHERE id = NEW.status_id;

    NEW.blocks_availability = status_blocks_availability;

    IF NEW.cash_payment_branch_id IS NULL AND NEW.cash_payment_code IS NULL THEN
        NEW.cash_payment_expires_at = NULL;
    ELSIF NEW.cash_payment_branch_id IS NOT NULL AND NEW.cash_payment_code IS NOT NULL THEN
        NEW.cash_payment_expires_at = COALESCE(NEW.cash_payment_expires_at, NEW.created_at + INTERVAL '72 hours');
    ELSE
        RAISE EXCEPTION 'Cash payment branch and code must be provided together';
    END IF;

    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- -----------------------------------------------------------------------------
-- Archivo: apply-reservation-rules-pending-window-hu-int-21.sql
-- -----------------------------------------------------------------------------
-- El plazo de vencimiento aplica a toda reserva pendiente (efectivo o en línea), no solo a las de efectivo:
-- así una reserva sin gestionar libera las fechas al vencer.
CREATE OR REPLACE FUNCTION rental.apply_reservation_rules()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    status_blocks_availability BOOLEAN;
BEGIN
    SELECT blocks_availability
    INTO status_blocks_availability
    FROM rental.reservation_statuses
    WHERE id = NEW.status_id;

    NEW.blocks_availability = status_blocks_availability;

    IF NEW.cash_payment_branch_id IS NULL AND NEW.cash_payment_code IS NULL THEN
        -- sin pago en efectivo: se conserva el plazo que calculó la aplicación
        NEW.cash_payment_expires_at = NEW.cash_payment_expires_at;
    ELSIF NEW.cash_payment_branch_id IS NOT NULL AND NEW.cash_payment_code IS NOT NULL THEN
        NEW.cash_payment_expires_at = COALESCE(NEW.cash_payment_expires_at, NEW.created_at + INTERVAL '72 hours');
    ELSE
        RAISE EXCEPTION 'Cash payment branch and code must be provided together';
    END IF;

    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- -----------------------------------------------------------------------------
-- Archivo: apply-reservation-rules.sql
-- -----------------------------------------------------------------------------
CREATE FUNCTION rental.apply_reservation_rules()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    status_blocks_availability BOOLEAN;
BEGIN
    SELECT blocks_availability
    INTO status_blocks_availability
    FROM rental.reservation_statuses
    WHERE id = NEW.status_id;

    NEW.blocks_availability = status_blocks_availability;

    IF NEW.cash_payment_branch_id IS NULL AND NEW.cash_payment_code IS NULL THEN
        NEW.cash_payment_expires_at = NULL;
    ELSIF NEW.cash_payment_branch_id IS NOT NULL AND NEW.cash_payment_code IS NOT NULL THEN
        NEW.cash_payment_expires_at = NEW.created_at + INTERVAL '72 hours';
    ELSE
        RAISE EXCEPTION 'Cash payment branch and code must be provided together';
    END IF;

    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- =============================================================================
-- SECCIÓN: 09 TRIGGERS Y DISPARADORES
-- =============================================================================

-- =============================================================================
-- SECCIÓN: 09 TRIGGERS Y DISPARADORES -> audit
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: add-administrative-reports-updated-at-triggers.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_administrative_report_types_set_updated_at
BEFORE UPDATE ON audit.administrative_report_types
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

CREATE TRIGGER trg_generated_reports_set_updated_at
BEFORE UPDATE ON audit.generated_reports
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- =============================================================================
-- SECCIÓN: 09 TRIGGERS Y DISPARADORES -> billing
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: add-payment-methods-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_payment_methods_set_updated_at
BEFORE UPDATE ON billing.payment_methods
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-payment-receipts-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_payment_receipts_set_updated_at
BEFORE UPDATE ON billing.payment_receipts
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-payment-statuses-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_payment_statuses_set_updated_at
BEFORE UPDATE ON billing.payment_statuses
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-payments-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_payments_set_updated_at
BEFORE UPDATE ON billing.payments
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-user-saved-payment-methods-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_user_saved_payment_methods_set_updated_at
BEFORE UPDATE ON billing.user_saved_payment_methods
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- =============================================================================
-- SECCIÓN: 09 TRIGGERS Y DISPARADORES -> catalog
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: add-additional-services-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_additional_services_set_updated_at
BEFORE UPDATE ON catalog.additional_services
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-insurance-coverages-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_insurance_coverages_set_updated_at
BEFORE UPDATE ON catalog.insurance_coverages
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-mileage-plans-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_mileage_plans_set_updated_at
BEFORE UPDATE ON catalog.mileage_plans
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-promotions-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_promotions_set_updated_at
BEFORE UPDATE ON catalog.promotions
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- =============================================================================
-- SECCIÓN: 09 TRIGGERS Y DISPARADORES -> contract
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: add-contract-clauses-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_contract_clauses_set_updated_at
BEFORE UPDATE ON contract.contract_clauses
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-contract-statuses-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_contract_statuses_set_updated_at
BEFORE UPDATE ON contract.contract_statuses
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-inspection-checklist-answers-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_inspection_checklist_answers_set_updated_at
BEFORE UPDATE ON contract.inspection_checklist_answers
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-inspection-checklist-items-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_inspection_checklist_items_set_updated_at
BEFORE UPDATE ON contract.inspection_checklist_items
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-rental-contracts-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_rental_contracts_set_updated_at
BEFORE UPDATE ON contract.rental_contracts
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-vehicle-inspections-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_vehicle_inspections_set_updated_at
BEFORE UPDATE ON contract.vehicle_inspections
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- =============================================================================
-- SECCIÓN: 09 TRIGGERS Y DISPARADORES -> core
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: 006-add-languages-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_languages_set_updated_at
BEFORE UPDATE ON core.languages
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: 007-add-currencies-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_currencies_set_updated_at
BEFORE UPDATE ON core.currencies
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-brand-configurations-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_brand_configurations_set_updated_at
BEFORE UPDATE ON core.brand_configurations
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- =============================================================================
-- SECCIÓN: 09 TRIGGERS Y DISPARADORES -> fleet
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: add-fuel-types-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_fuel_types_set_updated_at
BEFORE UPDATE ON fleet.fuel_types
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-transmission-types-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_transmission_types_set_updated_at
BEFORE UPDATE ON fleet.transmission_types
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-vehicle-brands-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_vehicle_brands_set_updated_at
BEFORE UPDATE ON fleet.vehicle_brands
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-vehicle-categories-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_vehicle_categories_set_updated_at
BEFORE UPDATE ON fleet.vehicle_categories
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-vehicle-documents-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_vehicle_documents_updated_at
BEFORE UPDATE ON fleet.vehicle_documents
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-vehicle-maintenances-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_vehicle_maintenances_updated_at
BEFORE UPDATE ON fleet.vehicle_maintenances
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-vehicle-statuses-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_vehicle_statuses_set_updated_at
BEFORE UPDATE ON fleet.vehicle_statuses
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-vehicles-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_vehicles_set_updated_at
BEFORE UPDATE ON fleet.vehicles
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- =============================================================================
-- SECCIÓN: 09 TRIGGERS Y DISPARADORES -> iam
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: add-document-statuses-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_document_statuses_set_updated_at
BEFORE UPDATE ON iam.document_statuses
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-document-types-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_document_types_set_updated_at
BEFORE UPDATE ON iam.document_types
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-nationalities-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_nationalities_set_updated_at
BEFORE UPDATE ON iam.nationalities
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-password-policies-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_password_policies_set_updated_at
BEFORE UPDATE ON iam.password_policies
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-roles-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_roles_set_updated_at
BEFORE UPDATE ON iam.roles
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-security-configurations-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_security_configurations_set_updated_at
BEFORE UPDATE ON iam.security_configurations
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-user-consents-immutable-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_user_consents_immutable
BEFORE UPDATE OR DELETE ON iam.user_consents
FOR EACH ROW
EXECUTE FUNCTION iam.prevent_user_consent_mutation();

-- -----------------------------------------------------------------------------
-- Archivo: add-user-documents-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_user_documents_set_updated_at
BEFORE UPDATE ON iam.user_documents
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-user-documents-validation-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_user_documents_validate
BEFORE INSERT OR UPDATE ON iam.user_documents
FOR EACH ROW
EXECUTE FUNCTION iam.validate_user_document();

-- -----------------------------------------------------------------------------
-- Archivo: add-user-preferences-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_user_preferences_updated_at
BEFORE UPDATE ON iam.user_preferences
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-user-profiles-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_user_profiles_set_updated_at
BEFORE UPDATE ON iam.user_profiles
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-user-sessions-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_user_sessions_updated_at
BEFORE UPDATE ON iam.user_sessions
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-users-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_users_set_updated_at
BEFORE UPDATE ON iam.users
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- =============================================================================
-- SECCIÓN: 09 TRIGGERS Y DISPARADORES -> location
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: add-branches-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_branches_set_updated_at
BEFORE UPDATE ON location.branches
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-cities-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_cities_set_updated_at
BEFORE UPDATE ON location.cities
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-departments-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_departments_set_updated_at
BEFORE UPDATE ON location.departments
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- =============================================================================
-- SECCIÓN: 09 TRIGGERS Y DISPARADORES -> rental
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: add-ratings-and-reviews-updated-at-triggers.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_vehicle_ratings_set_updated_at
BEFORE UPDATE ON rental.vehicle_ratings
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

CREATE TRIGGER trg_branch_reviews_set_updated_at
BEFORE UPDATE ON rental.branch_reviews
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-rental-extension-requests-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_rental_extension_requests_set_updated_at
BEFORE UPDATE ON rental.rental_extension_requests
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-reservation-delivery-points-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_reservation_delivery_points_set_updated_at
BEFORE UPDATE ON rental.reservation_delivery_points
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-reservation-statuses-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_reservation_statuses_set_updated_at
BEFORE UPDATE ON rental.reservation_statuses
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-reservations-rules-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_reservations_apply_rules
BEFORE INSERT OR UPDATE ON rental.reservations
FOR EACH ROW
EXECUTE FUNCTION rental.apply_reservation_rules();

-- =============================================================================
-- SECCIÓN: 09 TRIGGERS Y DISPARADORES -> support
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: add-incidents-updated-at-triggers.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_incident_reports_set_updated_at
BEFORE UPDATE ON support.incident_reports
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

CREATE TRIGGER trg_incident_responses_set_updated_at
BEFORE UPDATE ON support.incident_responses
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- -----------------------------------------------------------------------------
-- Archivo: add-notifications-updated-at-trigger.sql
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_notifications_set_updated_at
BEFORE UPDATE ON support.notifications
FOR EACH ROW
EXECUTE FUNCTION core.set_updated_at();

-- =============================================================================
-- SECCIÓN: 10 ÍNDICES EXPLÍCITOS DE RENDIMIENTO
-- =============================================================================

-- =============================================================================
-- SECCIÓN: 10 ÍNDICES EXPLÍCITOS DE RENDIMIENTO -> audit
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: create-administrative-reports-indexes.sql
-- -----------------------------------------------------------------------------
CREATE INDEX idx_administrative_report_types_code ON audit.administrative_report_types (code);
CREATE INDEX idx_generated_reports_type ON audit.generated_reports (report_type_id);
CREATE INDEX idx_generated_reports_generated_by ON audit.generated_reports (generated_by);
CREATE INDEX idx_generated_reports_format ON audit.generated_reports (format);
CREATE INDEX idx_generated_reports_generated_at ON audit.generated_reports (generated_at);
CREATE INDEX idx_generated_reports_filters ON audit.generated_reports USING gin (filters);

-- -----------------------------------------------------------------------------
-- Archivo: create-audit-logs-indexes.sql
-- -----------------------------------------------------------------------------
CREATE INDEX idx_audit_table_date ON audit.audit_logs (entity_name, created_at);
CREATE INDEX idx_audit_actor ON audit.audit_logs (actor_user_id);
CREATE INDEX idx_audit_logs_domain ON audit.audit_logs (domain_name);
CREATE INDEX idx_audit_logs_entity_id ON audit.audit_logs (entity_id);
CREATE INDEX idx_audit_logs_branch ON audit.audit_logs (branch_id);
CREATE INDEX idx_audit_logs_operation ON audit.audit_logs (operation);
CREATE INDEX idx_audit_logs_old_data ON audit.audit_logs USING gin (old_data);
CREATE INDEX idx_audit_logs_new_data ON audit.audit_logs USING gin (new_data);

-- =============================================================================
-- SECCIÓN: 10 ÍNDICES EXPLÍCITOS DE RENDIMIENTO -> billing
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: create-payments-indexes.sql
-- -----------------------------------------------------------------------------
CREATE INDEX idx_payments_contract ON billing.payments (contract_id);
CREATE INDEX idx_payments_status ON billing.payments (status_id);

-- -----------------------------------------------------------------------------
-- Archivo: create-user-saved-payment-methods-index.sql
-- -----------------------------------------------------------------------------
CREATE INDEX idx_user_saved_payment_methods_active_user
ON billing.user_saved_payment_methods (user_id)
WHERE is_active;

-- =============================================================================
-- SECCIÓN: 10 ÍNDICES EXPLÍCITOS DE RENDIMIENTO -> catalog
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: create-promotions-indexes.sql
-- -----------------------------------------------------------------------------
CREATE UNIQUE INDEX idx_promotions_code ON catalog.promotions (code);
CREATE INDEX idx_promotions_dates ON catalog.promotions (starts_at, ends_at);
CREATE INDEX idx_user_coupon_usages_user ON catalog.user_coupon_usages (user_id, used_at DESC);

-- =============================================================================
-- SECCIÓN: 10 ÍNDICES EXPLÍCITOS DE RENDIMIENTO -> contract
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: create-rental-contracts-indexes.sql
-- -----------------------------------------------------------------------------
CREATE INDEX idx_contracts_reservation ON contract.rental_contracts (reservation_id);
CREATE INDEX idx_contracts_customer ON contract.rental_contracts (customer_id);
CREATE INDEX idx_contracts_status ON contract.rental_contracts (status_id);

-- -----------------------------------------------------------------------------
-- Archivo: create-vehicle-inspections-indexes.sql
-- -----------------------------------------------------------------------------
CREATE INDEX idx_vehicle_inspections_contract ON contract.vehicle_inspections (contract_id);
CREATE INDEX idx_vehicle_inspections_inspector ON contract.vehicle_inspections (inspector_user_id);
CREATE INDEX idx_inspection_checklist_answers_item ON contract.inspection_checklist_answers (checklist_item_id);

-- =============================================================================
-- SECCIÓN: 10 ÍNDICES EXPLÍCITOS DE RENDIMIENTO -> core
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: 008-create-default-catalog-indexes.sql
-- -----------------------------------------------------------------------------
CREATE UNIQUE INDEX uq_languages_one_default
    ON core.languages (is_default)
    WHERE is_default;

CREATE UNIQUE INDEX uq_currencies_one_default
    ON core.currencies (is_default)
    WHERE is_default;

-- -----------------------------------------------------------------------------
-- Archivo: 012-create-exchange-rates-lookup-index.sql
-- -----------------------------------------------------------------------------
CREATE INDEX idx_exchange_rates_currency_pair_fetched_at
    ON core.exchange_rates (from_currency_id, to_currency_id, fetched_at DESC);

-- -----------------------------------------------------------------------------
-- Archivo: create-brand-configurations-active-index.sql
-- -----------------------------------------------------------------------------
CREATE UNIQUE INDEX uq_brand_configurations_one_active
    ON core.brand_configurations (is_active)
    WHERE is_active;

-- =============================================================================
-- SECCIÓN: 10 ÍNDICES EXPLÍCITOS DE RENDIMIENTO -> fleet
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: create-features-indexes.sql
-- -----------------------------------------------------------------------------
CREATE INDEX idx_vehicle_features_feat ON fleet.vehicle_features (feature_id);
CREATE INDEX idx_user_favorite_vehicles_veh ON fleet.user_favorite_vehicles (vehicle_id);
CREATE INDEX idx_user_favorite_vehicles_user ON fleet.user_favorite_vehicles (user_id);

-- -----------------------------------------------------------------------------
-- Archivo: create-vehicle-assets-indexes.sql
-- -----------------------------------------------------------------------------
CREATE INDEX idx_vehicle_images_veh ON fleet.vehicle_images (vehicle_id);
CREATE UNIQUE INDEX uq_vehicle_images_primary ON fleet.vehicle_images (vehicle_id) WHERE is_primary;
CREATE INDEX idx_vehicle_documents_veh ON fleet.vehicle_documents (vehicle_id);
CREATE UNIQUE INDEX uq_vehicle_documents_active_type ON fleet.vehicle_documents (vehicle_id, document_type) WHERE is_active;
CREATE INDEX idx_vehicle_documents_expiration ON fleet.vehicle_documents (expires_at) WHERE is_active AND expires_at IS NOT NULL;

-- -----------------------------------------------------------------------------
-- Archivo: create-vehicle-maintenances-indexes.sql
-- -----------------------------------------------------------------------------
CREATE INDEX idx_vehicle_maintenances_veh ON fleet.vehicle_maintenances (vehicle_id);
CREATE INDEX idx_vehicle_maintenances_type ON fleet.vehicle_maintenances (maintenance_type_id);
CREATE INDEX idx_vehicle_maintenances_scheduled ON fleet.vehicle_maintenances (scheduled_date);

-- -----------------------------------------------------------------------------
-- Archivo: create-vehicles-indexes.sql
-- -----------------------------------------------------------------------------
CREATE INDEX idx_vehicles_plate ON fleet.vehicles (plate);
CREATE INDEX idx_vehicles_branch_status ON fleet.vehicles (current_branch_id, status_id, is_active);
CREATE INDEX idx_vehicles_cat_rate ON fleet.vehicles (category_id, daily_rate);

-- =============================================================================
-- SECCIÓN: 10 ÍNDICES EXPLÍCITOS DE RENDIMIENTO -> iam
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: create-identity-catalogs-active-indexes.sql
-- -----------------------------------------------------------------------------
CREATE INDEX idx_document_types_active ON iam.document_types (code) WHERE is_active;
CREATE INDEX idx_nationalities_active ON iam.nationalities (name) WHERE is_active;
CREATE INDEX idx_document_statuses_active ON iam.document_statuses (code) WHERE is_active;

-- -----------------------------------------------------------------------------
-- Archivo: create-password-policies-active-index.sql
-- -----------------------------------------------------------------------------
CREATE UNIQUE INDEX uq_password_policies_one_active
    ON iam.password_policies (is_active)
    WHERE is_active;

-- -----------------------------------------------------------------------------
-- Archivo: create-role-permissions-lookup-index.sql
-- -----------------------------------------------------------------------------
CREATE INDEX idx_role_permissions_permission_id ON iam.role_permissions (permission_id);

-- -----------------------------------------------------------------------------
-- Archivo: create-roles-active-index.sql
-- -----------------------------------------------------------------------------
CREATE INDEX idx_roles_is_active ON iam.roles (is_active);

-- -----------------------------------------------------------------------------
-- Archivo: create-user-consents-index.sql
-- -----------------------------------------------------------------------------
CREATE INDEX idx_user_consents_user_accepted_at
    ON iam.user_consents (user_id, accepted_at DESC);

-- -----------------------------------------------------------------------------
-- Archivo: create-user-documents-indexes.sql
-- -----------------------------------------------------------------------------
CREATE INDEX idx_user_documents_user ON iam.user_documents (user_id);
CREATE INDEX idx_user_documents_status ON iam.user_documents (status_id);

-- -----------------------------------------------------------------------------
-- Archivo: create-user-preferences-indexes.sql
-- -----------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_user_preferences_lang ON iam.user_preferences (language_id);
CREATE INDEX IF NOT EXISTS idx_user_preferences_curr ON iam.user_preferences (currency_id);

-- -----------------------------------------------------------------------------
-- Archivo: create-user-roles-indexes.sql
-- -----------------------------------------------------------------------------
CREATE INDEX idx_user_roles_role_id ON iam.user_roles (role_id);

-- -----------------------------------------------------------------------------
-- Archivo: create-user-sessions-indexes.sql
-- -----------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_user_sessions_user ON iam.user_sessions (user_id);
CREATE INDEX IF NOT EXISTS idx_user_sessions_exp ON iam.user_sessions (expires_at);
CREATE INDEX IF NOT EXISTS idx_user_sessions_revoked ON iam.user_sessions (revoked_at);

-- -----------------------------------------------------------------------------
-- Archivo: create-users-indexes.sql
-- -----------------------------------------------------------------------------
CREATE INDEX idx_users_email ON iam.users (email);
CREATE INDEX idx_users_doc_num ON iam.users (document_number);
CREATE INDEX idx_users_account_status ON iam.users (account_status);

-- -----------------------------------------------------------------------------
-- Archivo: create-verification-codes-indexes.sql
-- -----------------------------------------------------------------------------
CREATE INDEX idx_verification_codes_user_purpose ON iam.verification_codes (user_id, purpose);

-- -----------------------------------------------------------------------------
-- Archivo: create-verification-codes-user-index.sql
-- -----------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_verification_codes_user ON iam.verification_codes (user_id);
CREATE INDEX IF NOT EXISTS idx_verification_codes_exp ON iam.verification_codes (expires_at);

-- =============================================================================
-- SECCIÓN: 10 ÍNDICES EXPLÍCITOS DE RENDIMIENTO -> location
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: create-branch-users-branch-index.sql
-- -----------------------------------------------------------------------------
CREATE INDEX idx_branch_users_branch ON location.branch_users (branch_id);

-- -----------------------------------------------------------------------------
-- Archivo: create-branches-city-index.sql
-- -----------------------------------------------------------------------------
CREATE INDEX idx_branches_city ON location.branches (city_id);

-- -----------------------------------------------------------------------------
-- Archivo: create-cities-department-index.sql
-- -----------------------------------------------------------------------------
CREATE INDEX idx_cities_dept ON location.cities (department_id);

-- =============================================================================
-- SECCIÓN: 10 ÍNDICES EXPLÍCITOS DE RENDIMIENTO -> rental
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: create-ratings-and-reviews-indexes.sql
-- -----------------------------------------------------------------------------
CREATE INDEX idx_vehicle_ratings_veh ON rental.vehicle_ratings (vehicle_id);
CREATE INDEX idx_branch_reviews_branch ON rental.branch_reviews (branch_id);

-- -----------------------------------------------------------------------------
-- Archivo: create-rental-extension-requests-indexes.sql
-- -----------------------------------------------------------------------------
CREATE INDEX idx_rental_extension_requests_reservation ON rental.rental_extension_requests (reservation_id);
CREATE INDEX idx_rental_extension_requests_status ON rental.rental_extension_requests (status);
CREATE INDEX idx_rental_extension_requests_reviewer ON rental.rental_extension_requests (reviewed_by);

-- -----------------------------------------------------------------------------
-- Archivo: create-reservation-delivery-points-indexes.sql
-- -----------------------------------------------------------------------------
CREATE INDEX idx_reservation_delivery_points_reservation ON rental.reservation_delivery_points (reservation_id);
CREATE INDEX idx_reservation_delivery_points_branch ON rental.reservation_delivery_points (branch_id);
CREATE INDEX idx_reservation_delivery_points_city ON rental.reservation_delivery_points (city_id);

-- -----------------------------------------------------------------------------
-- Archivo: create-reservation-services-and-promotions-indexes.sql
-- -----------------------------------------------------------------------------
CREATE INDEX idx_reservation_additional_services_service ON rental.reservation_additional_services (additional_service_id);
CREATE INDEX idx_reservation_promotions_promotion ON rental.reservation_promotions (promotion_id);

-- -----------------------------------------------------------------------------
-- Archivo: create-reservations-indexes-and-exclusion.sql
-- -----------------------------------------------------------------------------
ALTER TABLE rental.reservations
    ADD CONSTRAINT reservations_vehicle_period_no_overlap
    EXCLUDE USING GIST (
        vehicle_id WITH =,
        tstzrange(pickup_date, return_date, '[)') WITH &&
    )
    WHERE (blocks_availability);

CREATE INDEX idx_reservations_customer ON rental.reservations (customer_id);
CREATE INDEX idx_reservations_vehicle ON rental.reservations (vehicle_id);
CREATE INDEX idx_reservations_status ON rental.reservations (status_id);
CREATE INDEX idx_reservations_dates ON rental.reservations (pickup_date, return_date);

-- =============================================================================
-- SECCIÓN: 10 ÍNDICES EXPLÍCITOS DE RENDIMIENTO -> support
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: create-incidents-indexes.sql
-- -----------------------------------------------------------------------------
CREATE INDEX idx_incident_reports_code ON support.incident_reports (incident_code);
CREATE INDEX idx_incident_reports_vehicle ON support.incident_reports (vehicle_id);
CREATE INDEX idx_incident_reports_reservation ON support.incident_reports (reservation_id);
CREATE INDEX idx_incident_reports_reported_by ON support.incident_reports (reported_by_user_id);
CREATE INDEX idx_incident_reports_status ON support.incident_reports (status);
CREATE INDEX idx_incident_responses_report ON support.incident_responses (incident_report_id);
CREATE INDEX idx_incident_responses_author ON support.incident_responses (author_user_id);

-- -----------------------------------------------------------------------------
-- Archivo: create-notifications-indexes.sql
-- -----------------------------------------------------------------------------
CREATE INDEX idx_notifications_user_unread ON support.notifications (user_id, is_read);
CREATE INDEX idx_notifications_user ON support.notifications (user_id);
CREATE INDEX idx_notifications_type ON support.notifications (type);
CREATE INDEX idx_notifications_channel ON support.notifications (channel);
CREATE INDEX idx_notifications_created_at ON support.notifications (created_at);

-- =============================================================================
-- SECCIÓN: DML DATOS INICIALES Y SEMILLAS DEL SISTEMA
-- =============================================================================

-- =============================================================================
-- SECCIÓN: DML DATOS INICIALES Y SEMILLAS DEL SISTEMA -> audit
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: seed-administrative-report-types-hu-int-18.sql
-- -----------------------------------------------------------------------------
INSERT INTO audit.administrative_report_types (code, name, description, is_active)
VALUES
    ('EXECUTIVE_SUMMARY', 'Resumen Ejecutivo y Operativo', 'Balance global del negocio con indicadores clave de reservas, ingresos, flota, contratos e incidencias', true),
    ('FINANCIAL_CONSOLIDATED', 'Consolidado Financiero e Ingresos', 'Ingresos por sucursal, métodos de pago y ticket promedio', true),
    ('INCIDENTS_MAINTENANCE', 'Balance de Incidencias y Mantenimiento', 'Incidencias por gravedad, estado y costo estimado', true),
    ('RESERVATIONS', 'Reporte Específico de Reservas', 'Listado detallado de reservas', true),
    ('VEHICLES', 'Reporte Específico de Flota y Vehículos', 'Inventario de vehículos', true),
    ('CONTRACTS', 'Reporte Específico de Contratos', 'Relación de contratos de arrendamiento', true),
    ('INCIDENTS', 'Reporte Específico de Incidencias', 'Listado de incidencias reportadas', true),
    ('USERS', 'Reporte Específico de Clientes y Usuarios', 'Directorio de usuarios del sistema', true),
    ('PROMOTIONS', 'Reporte Específico de Promociones y Cupones', 'Catálogo de promociones y cupones', true)
ON CONFLICT (code) DO NOTHING;

-- -----------------------------------------------------------------------------
-- Archivo: seed-administrative-report-types.sql
-- -----------------------------------------------------------------------------
INSERT INTO audit.administrative_report_types (code, name, description, is_active)
VALUES
    ('FLEET_OCCUPANCY', 'Ocupación de Flota', 'Reporte analítico de disponibilidad y tasa de uso de vehículos', true),
    ('REVENUE_SUMMARY', 'Resumen de Ingresos', 'Consolidado financiero de pagos, facturación y cobros de alquiler', true),
    ('AUDIT_TRAIL', 'Trazabilidad de Auditoría', 'Registro pormenorizado de operaciones y eventos de seguridad', true),
    ('MAINTENANCE', 'Mantenimiento Preventivo y Correctivo', 'Historial y planificación de mantenimientos de flota', true)
ON CONFLICT (code) DO NOTHING;

-- -----------------------------------------------------------------------------
-- Archivo: seed-branches-report-type-hu-int-19.sql
-- -----------------------------------------------------------------------------
INSERT INTO audit.administrative_report_types (code, name, description, is_active)
VALUES ('BRANCHES', 'Reporte de Sedes', 'Vehículos, reservas, ingresos, incidencias y calificación por sucursal', true)
ON CONFLICT (code) DO NOTHING;

-- =============================================================================
-- SECCIÓN: DML DATOS INICIALES Y SEMILLAS DEL SISTEMA -> billing
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: seed-payment-catalogs.sql
-- -----------------------------------------------------------------------------
INSERT INTO billing.payment_methods (code, name) VALUES
    ('CASH', 'Cash'),
    ('CREDIT_CARD', 'Credit card'),
    ('DEBIT_CARD', 'Debit card'),
    ('PSE', 'PSE'),
    ('NEQUI', 'Nequi'),
    ('BANCOLOMBIA', 'Bancolombia');

INSERT INTO billing.payment_statuses (code, name, is_final) VALUES
    ('PENDING', 'Pending', FALSE),
    ('APPROVED', 'Approved', TRUE),
    ('DECLINED', 'Declined', TRUE),
    ('REFUNDED', 'Refunded', TRUE),
    ('VOIDED', 'Voided', TRUE);

-- =============================================================================
-- SECCIÓN: DML DATOS INICIALES Y SEMILLAS DEL SISTEMA -> catalog
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: seed-additional-services-and-insurance-coverages.sql
-- -----------------------------------------------------------------------------
INSERT INTO catalog.additional_services (name, daily_rate) VALUES
    ('Baby Seat', 25000.00),
    ('GPS Navigation', 18000.00),
    ('Mobile Wi-Fi', 22000.00),
    ('Additional Driver', 30000.00),
    ('Roadside Assistance', 15000.00)
ON CONFLICT (name) DO NOTHING;

INSERT INTO catalog.insurance_coverages (name, daily_rate, description) VALUES
    ('Basic Protection', 0.00, 'Base protection included with every rental.'),
    ('Standard Protection', 45000.00, 'Reduces the customer liability for covered events.'),
    ('Premium Protection', 80000.00, 'Provides the broadest available protection and lower liability.')
ON CONFLICT (name) DO NOTHING;

-- -----------------------------------------------------------------------------
-- Archivo: seed-mileage-plans.sql
-- -----------------------------------------------------------------------------
INSERT INTO catalog.mileage_plans (name, included_km, daily_rate, extra_km_rate) VALUES
    ('Standard 200 km', 200, 0.00, 850.00),
    ('Extended 400 km', 400, 15000.00, 700.00),
    ('Unlimited Mileage', NULL, 35000.00, 0.00);

-- -----------------------------------------------------------------------------
-- Archivo: seed-promotions.sql
-- -----------------------------------------------------------------------------
INSERT INTO catalog.promotions (code, offer_type, discount_type, discount_value, starts_at, ends_at, minimum_rental_days, is_active)
VALUES 
    ('BIENVENIDO10', 'COUPON', 'PERCENTAGE', 10.00, '2026-01-01 00:00:00Z', '2027-12-31 23:59:59Z', 1, true),
    ('DRIVIQUE50K', 'COUPON', 'FIXED_AMOUNT', 50000.00, '2026-01-01 00:00:00Z', '2027-12-31 23:59:59Z', 1, true),
    ('SUV20', 'PROMOTION', 'PERCENTAGE', 20.00, '2026-01-01 00:00:00Z', '2027-12-31 23:59:59Z', 1, true)
ON CONFLICT (code) DO NOTHING;

-- =============================================================================
-- SECCIÓN: DML DATOS INICIALES Y SEMILLAS DEL SISTEMA -> contract
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: seed-contract-clauses-hu-int-20.sql
-- -----------------------------------------------------------------------------
-- Cláusulas del contrato v1.0: antes se creaban desde el código; ahora son datos versionados de la base
INSERT INTO contract.contract_clauses (id, version, sort_order, title, content, is_active) SELECT gen_random_uuid(), 'v1.0', 1, 'Objeto del Contrato', 'El arrendador entrega en arrendamiento al arrendatario el vehículo automotor descrito en la carátula del presente contrato.', 't' WHERE NOT EXISTS (SELECT 1 FROM contract.contract_clauses WHERE version = 'v1.0' AND sort_order = 1);
INSERT INTO contract.contract_clauses (id, version, sort_order, title, content, is_active) SELECT gen_random_uuid(), 'v1.0', 2, 'Uso y Destinación', 'El arrendatario se compromete a usar el vehículo exclusivamente para transporte particular lícito dentro del territorio nacional autorizado.', 't' WHERE NOT EXISTS (SELECT 1 FROM contract.contract_clauses WHERE version = 'v1.0' AND sort_order = 2);
INSERT INTO contract.contract_clauses (id, version, sort_order, title, content, is_active) SELECT gen_random_uuid(), 'v1.0', 3, 'Obligaciones del Arrendatario', 'El arrendatario deberá restituir el vehículo en la fecha, hora y sede acordadas, en el mismo estado mecánico y estético recibido.', 't' WHERE NOT EXISTS (SELECT 1 FROM contract.contract_clauses WHERE version = 'v1.0' AND sort_order = 3);
INSERT INTO contract.contract_clauses (id, version, sort_order, title, content, is_active) SELECT gen_random_uuid(), 'v1.0', 4, 'Depósito de Garantía y Cargos', 'El arrendatario autoriza el bloqueo del depósito de garantía y el cobro de deducibles, multas de tránsito o combustible faltante.', 't' WHERE NOT EXISTS (SELECT 1 FROM contract.contract_clauses WHERE version = 'v1.0' AND sort_order = 4);
INSERT INTO contract.contract_clauses (id, version, sort_order, title, content, is_active) SELECT gen_random_uuid(), 'v1.0', 5, 'Firma y Validez Jurídica', 'Las partes reconocen plena validez legal y probatoria a la firma electrónica y biométrica capturada en la plataforma Drivique.', 't' WHERE NOT EXISTS (SELECT 1 FROM contract.contract_clauses WHERE version = 'v1.0' AND sort_order = 5);

-- -----------------------------------------------------------------------------
-- Archivo: seed-contract-clauses.sql
-- -----------------------------------------------------------------------------
INSERT INTO contract.contract_clauses (version, sort_order, title, content, is_active) VALUES
    ('v1.0', 1, 'Objeto del Contrato', 'El arrendador entrega en arrendamiento al arrendatario el vehículo automotor descrito en la carátula del presente contrato.', TRUE),
    ('v1.0', 2, 'Uso y Destinación', 'El arrendatario se compromete a usar el vehículo exclusivamente para transporte particular lícito dentro del territorio nacional autorizado.', TRUE),
    ('v1.0', 3, 'Obligaciones del Arrendatario', 'El arrendatario deberá restituir el vehículo en la fecha, hora y sede acordadas, en el mismo estado mecánico y estético recibido.', TRUE),
    ('v1.0', 4, 'Depósito de Garantía y Cargos', 'El arrendatario autoriza el bloqueo del depósito de garantía y el cobro de deducibles, multas de tránsito o combustible faltante.', TRUE),
    ('v1.0', 5, 'Firma y Validez Jurídica', 'Las partes reconocen plena validez legal y probatoria a la firma electrónica y biométrica capturada en la plataforma Drivique.', TRUE)
ON CONFLICT (version, sort_order) DO NOTHING;

-- -----------------------------------------------------------------------------
-- Archivo: seed-contract-statuses.sql
-- -----------------------------------------------------------------------------
INSERT INTO contract.contract_statuses (code, name, is_active, is_final) VALUES
    ('DRAFT', 'Draft', FALSE, FALSE),
    ('PENDING_SIGNATURE', 'Pending Signature', TRUE, FALSE),
    ('ACTIVE', 'Active', TRUE, FALSE),
    ('FINALIZED', 'Finalized', FALSE, TRUE),
    ('CANCELLED', 'Cancelled', FALSE, TRUE)
ON CONFLICT (code) DO NOTHING;

-- -----------------------------------------------------------------------------
-- Archivo: seed-inspection-checklist-items.sql
-- -----------------------------------------------------------------------------
INSERT INTO contract.inspection_checklist_items (name, description) VALUES
    ('Llantas', 'Estado de neumáticos, labrado y presión de inflado'),
    ('Luces', 'Funcionamiento de luces altas, bajas, direccionales y stop'),
    ('Carrocería', 'Inspección de rayones, abolladuras, pintura y piezas exteriores'),
    ('Espejos', 'Estado y ajuste de retrovisores laterales y central')
ON CONFLICT (name) DO NOTHING;

-- =============================================================================
-- SECCIÓN: DML DATOS INICIALES Y SEMILLAS DEL SISTEMA -> core
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: 009-seed-languages.sql
-- -----------------------------------------------------------------------------
INSERT INTO core.languages (code, name, is_default, is_active)
VALUES
    ('es', 'Spanish', TRUE, TRUE),
    ('en', 'English', FALSE, TRUE),
    ('fr', 'French', FALSE, TRUE),
    ('pt', 'Portuguese', FALSE, TRUE),
    ('br', 'Brazilian Portuguese', FALSE, TRUE);

-- -----------------------------------------------------------------------------
-- Archivo: 010-seed-currencies.sql
-- -----------------------------------------------------------------------------
INSERT INTO core.currencies (code, name, symbol, is_default, is_active)
VALUES
    ('COP', 'Colombian Peso', '$', TRUE, TRUE),
    ('USD', 'United States Dollar', '$', FALSE, TRUE),
    ('EUR', 'Euro', '€', FALSE, TRUE);

-- -----------------------------------------------------------------------------
-- Archivo: seed-brand-configurations.sql
-- -----------------------------------------------------------------------------
INSERT INTO core.brand_configurations (
    company_name,
    logo_url,
    favicon_url,
    primary_color,
    secondary_color,
    accent_color,
    default_theme,
    is_active
) VALUES (
    'Drivique',
    NULL,
    NULL,
    '#2563EB',
    '#1E3A8A',
    '#60A5FA',
    'SYSTEM',
    TRUE
);

-- =============================================================================
-- SECCIÓN: DML DATOS INICIALES Y SEMILLAS DEL SISTEMA -> fleet
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: seed-features.sql
-- -----------------------------------------------------------------------------
-- Seed features catalog
INSERT INTO fleet.features (name, feature_group, icon, is_active)
VALUES
    ('Aire Acondicionado', 'COMFORT', 'air-conditioner', TRUE),
    ('Asientos de Cuero', 'COMFORT', 'car-seat', TRUE),
    ('Techo Panorámico', 'COMFORT', 'sunroof', TRUE),
    ('Navegación GPS', 'TECHNOLOGY', 'navigation', TRUE),
    ('Bluetooth y Manos Libres', 'TECHNOLOGY', 'bluetooth', TRUE),
    ('Apple CarPlay y Android Auto', 'TECHNOLOGY', 'smartphone', TRUE),
    ('Pantalla Táctil Multimedia', 'TECHNOLOGY', 'screen', TRUE),
    ('Frenos ABS', 'SECURITY', 'brake', TRUE),
    ('Airbags Frontales y Laterales', 'SECURITY', 'airbag', TRUE),
    ('Cámara de Reversa HD', 'SECURITY', 'camera', TRUE),
    ('Sensores de Parqueo 360', 'SECURITY', 'sensor', TRUE),
    ('Control de Estabilidad (ESP)', 'SECURITY', 'shield', TRUE),
    ('Dirección Asistida', 'STANDARD', 'steering-wheel', TRUE),
    ('Vidrios Eléctricos', 'STANDARD', 'window', TRUE),
    ('Bloqueo Central', 'STANDARD', 'lock', TRUE)
ON CONFLICT (name) DO NOTHING;

-- Seed vehicle_features associations for existing seeded vehicles
INSERT INTO fleet.vehicle_features (vehicle_id, feature_id)
SELECT v.id, f.id
FROM fleet.vehicles v
CROSS JOIN fleet.features f
WHERE v.plate = 'ABC-123' AND f.name IN ('Navegación GPS', 'Apple CarPlay y Android Auto', 'Cámara de Reversa HD', 'Frenos ABS', 'Aire Acondicionado')
ON CONFLICT (vehicle_id, feature_id) DO NOTHING;

INSERT INTO fleet.vehicle_features (vehicle_id, feature_id)
SELECT v.id, f.id
FROM fleet.vehicles v
CROSS JOIN fleet.features f
WHERE v.plate = 'GHI-789' AND f.name IN ('Asientos de Cuero', 'Apple CarPlay y Android Auto', 'Sensores de Parqueo 360', 'Frenos ABS')
ON CONFLICT (vehicle_id, feature_id) DO NOTHING;

INSERT INTO fleet.vehicle_features (vehicle_id, feature_id)
SELECT v.id, f.id
FROM fleet.vehicles v
CROSS JOIN fleet.features f
WHERE v.plate = 'PQR-678' AND f.name IN ('Techo Panorámico', 'Asientos de Cuero', 'Navegación GPS', 'Apple CarPlay y Android Auto', 'Sensores de Parqueo 360', 'Control de Estabilidad (ESP)')
ON CONFLICT (vehicle_id, feature_id) DO NOTHING;

-- -----------------------------------------------------------------------------
-- Archivo: seed-maintenance-types.sql
-- -----------------------------------------------------------------------------
-- Seed maintenance types catalog
INSERT INTO fleet.maintenance_types (code, name, is_active)
VALUES
    ('PREVENTIVE', 'Mantenimiento Preventivo', TRUE),
    ('CORRECTIVE', 'Mantenimiento Correctivo', TRUE),
    ('OIL_CHANGE', 'Cambio de Aceite y Filtros', TRUE),
    ('TIRES', 'Revisión y Cambio de Llantas', TRUE)
ON CONFLICT (code) DO NOTHING;

-- Seed initial sample maintenance for history audit
INSERT INTO fleet.vehicle_maintenances (
    vehicle_id,
    maintenance_type_id,
    scheduled_date,
    completed_date,
    cost,
    description
)
SELECT
    v.id,
    mt.id,
    '2024-02-01'::DATE,
    '2024-02-02'::DATE,
    250000.00,
    'Cambio preventivo de aceite sintético 5W-30 y filtros de aire'
FROM fleet.vehicles v
CROSS JOIN fleet.maintenance_types mt
WHERE v.plate = 'ABC-123' AND mt.code = 'OIL_CHANGE'
LIMIT 1;

-- -----------------------------------------------------------------------------
-- Archivo: seed-technical-catalogs.sql
-- -----------------------------------------------------------------------------
INSERT INTO fleet.vehicle_brands (name) VALUES
    ('Chevrolet'),
    ('Renault'),
    ('Mazda'),
    ('Toyota'),
    ('Kia'),
    ('Nissan'),
    ('Hyundai'),
    ('Ford'),
    ('Volkswagen'),
    ('BMW'),
    ('Mercedes-Benz');

INSERT INTO fleet.transmission_types (code, name) VALUES
    ('MANUAL', 'Manual'),
    ('AUTOMATIC', 'Automatic');

INSERT INTO fleet.fuel_types (code, name) VALUES
    ('GASOLINE', 'Gasoline'),
    ('DIESEL', 'Diesel'),
    ('ELECTRIC', 'Electric'),
    ('HYBRID', 'Hybrid');

INSERT INTO fleet.vehicle_statuses (code, name, allows_reservation) VALUES
    ('AVAILABLE', 'Available', TRUE),
    ('RENTED', 'Rented', FALSE),
    ('MAINTENANCE', 'Maintenance', FALSE),
    ('INACTIVE', 'Inactive', FALSE);

-- -----------------------------------------------------------------------------
-- Archivo: seed-vehicle-assets.sql
-- -----------------------------------------------------------------------------
-- Seed vehicle images for initial fleet
INSERT INTO fleet.vehicle_images (vehicle_id, url, is_primary, sort_order)
SELECT v.id, img.url, img.is_primary, img.sort_order::SMALLINT
FROM (
    VALUES
        ('ABC-123', 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7', TRUE, 1),
        ('ABC-123', 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341', FALSE, 2),
        ('DEF-456', 'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d', TRUE, 1),
        ('GHI-789', 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf', TRUE, 1),
        ('JKL-012', 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d', TRUE, 1),
        ('MNO-345', 'https://images.unsplash.com/photo-1559416523-140ddc3d238c', TRUE, 1),
        ('PQR-678', 'https://images.unsplash.com/photo-1555215695-3004980ad54e', TRUE, 1)
) AS img(plate, url, is_primary, sort_order)
JOIN fleet.vehicles v ON v.plate = img.plate;

-- Seed vehicle documents (SOAT and TECHNICAL_INSPECTION)
INSERT INTO fleet.vehicle_documents (vehicle_id, document_type, document_number, file_url, issued_at, expires_at, is_active)
SELECT v.id, doc.doc_type, doc.doc_num, doc.file_url, doc.issued_at::DATE, doc.expires_at::DATE, TRUE
FROM (
    VALUES
        ('ABC-123', 'SOAT', 'SOAT-2024-001', 'https://documents.drivique.com/soat/ABC123-2024.pdf', '2024-01-01', '2025-01-01'),
        ('ABC-123', 'TECHNICAL_INSPECTION', 'RTM-2024-001', 'https://documents.drivique.com/rtm/ABC123-2024.pdf', '2024-01-01', '2025-01-01'),
        ('DEF-456', 'SOAT', 'SOAT-2024-002', 'https://documents.drivique.com/soat/DEF456-2024.pdf', '2024-02-01', '2025-02-01'),
        ('GHI-789', 'SOAT', 'SOAT-2024-003', 'https://documents.drivique.com/soat/GHI789-2024.pdf', '2024-03-01', '2025-03-01'),
        ('JKL-012', 'SOAT', 'SOAT-2024-004', 'https://documents.drivique.com/soat/JKL012-2024.pdf', '2024-01-15', '2025-01-15'),
        ('MNO-345', 'SOAT', 'SOAT-2024-005', 'https://documents.drivique.com/soat/MNO345-2024.pdf', '2024-04-01', '2025-04-01'),
        ('PQR-678', 'SOAT', 'SOAT-2024-006', 'https://documents.drivique.com/soat/PQR678-2024.pdf', '2024-05-01', '2025-05-01')
) AS doc(plate, doc_type, doc_num, file_url, issued_at, expires_at)
JOIN fleet.vehicles v ON v.plate = doc.plate;

-- -----------------------------------------------------------------------------
-- Archivo: seed-vehicle-categories.sql
-- -----------------------------------------------------------------------------
INSERT INTO fleet.vehicle_categories (name, base_daily_rate, security_deposit) VALUES
    ('SUV', 180000.00, 1500000.00),
    ('Sedán', 120000.00, 1000000.00),
    ('Hatchback', 100000.00, 800000.00),
    ('Camioneta', 220000.00, 2000000.00),
    ('Lujo', 350000.00, 3000000.00);

-- -----------------------------------------------------------------------------
-- Archivo: seed-vehicles.sql
-- -----------------------------------------------------------------------------
INSERT INTO fleet.vehicles (
    plate,
    vin,
    brand_id,
    category_id,
    transmission_type_id,
    fuel_type_id,
    status_id,
    current_branch_id,
    model,
    year,
    color,
    passenger_capacity,
    doors_count,
    trunk_capacity_liters,
    mileage,
    daily_rate,
    main_image_url,
    is_featured,
    is_active
)
SELECT
    v.plate,
    v.vin,
    b.id,
    c.id,
    t.id,
    f.id,
    s.id,
    br.id,
    v.model,
    v.year,
    v.color,
    v.passenger_capacity,
    v.doors_count,
    v.trunk_capacity_liters,
    v.mileage,
    v.daily_rate,
    v.main_image_url,
    v.is_featured,
    v.is_active
FROM (
    VALUES
        ('ABC-123', '1HGCR2F83HA000001', 'Toyota', 'SUV', 'AUTOMATIC', 'HYBRID', 'AVAILABLE', 'Drivique Bogotá Centro', 'RAV4 Hybrid Limited', 2024::SMALLINT, 'Blanco Perla', 5::SMALLINT, 5::SMALLINT, 580, 15000, 220000.00, 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7', TRUE, TRUE),
        ('DEF-456', '2T1BURHE5HC000002', 'Renault', 'Sedán', 'MANUAL', 'GASOLINE', 'AVAILABLE', 'Drivique Bogotá Centro', 'Logan Intens', 2023::SMALLINT, 'Gris Estrella', 5::SMALLINT, 4::SMALLINT, 510, 28000, 120000.00, 'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d', FALSE, TRUE),
        ('GHI-789', '3VW2K7AJ4EM000003', 'Mazda', 'SUV', 'AUTOMATIC', 'GASOLINE', 'AVAILABLE', 'Drivique Medellín Centro', 'CX-5 Grand Touring', 2024::SMALLINT, 'Rojo Diamante', 5::SMALLINT, 5::SMALLINT, 506, 12000, 240000.00, 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf', TRUE, TRUE),
        ('JKL-012', '4T1B11HK8JU000004', 'Chevrolet', 'Hatchback', 'MANUAL', 'GASOLINE', 'AVAILABLE', 'Drivique Medellín Aeropuerto', 'Onix RS', 2023::SMALLINT, 'Negro Ébano', 5::SMALLINT, 5::SMALLINT, 385, 34000, 110000.00, 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d', FALSE, TRUE),
        ('MNO-345', '5N1AL0MM8KC000005', 'Toyota', 'Camioneta', 'AUTOMATIC', 'DIESEL', 'AVAILABLE', 'Drivique Cali Centro', 'Hilux SRV 4x4', 2024::SMALLINT, 'Plata Metálico', 5::SMALLINT, 4::SMALLINT, 1000, 18000, 320000.00, 'https://images.unsplash.com/photo-1559416523-140ddc3d238c', TRUE, TRUE),
        ('PQR-678', 'WBA3A5C58DF000006', 'BMW', 'Lujo', 'AUTOMATIC', 'GASOLINE', 'AVAILABLE', 'Drivique Bogotá Centro', 'Serie 3 330i M Sport', 2024::SMALLINT, 'Azul Portimao', 5::SMALLINT, 4::SMALLINT, 480, 8500, 450000.00, 'https://images.unsplash.com/photo-1555215695-3004980ad54e', TRUE, TRUE)
) AS v(plate, vin, brand_name, category_name, trans_code, fuel_code, status_code, branch_name, model, year, color, passenger_capacity, doors_count, trunk_capacity_liters, mileage, daily_rate, main_image_url, is_featured, is_active)
JOIN fleet.vehicle_brands b ON b.name = v.brand_name
JOIN fleet.vehicle_categories c ON c.name = v.category_name
JOIN fleet.transmission_types t ON t.code = v.trans_code
JOIN fleet.fuel_types f ON f.code = v.fuel_code
JOIN fleet.vehicle_statuses s ON s.code = v.status_code
JOIN location.branches br ON br.name = v.branch_name
WHERE NOT EXISTS (
    SELECT 1 FROM fleet.vehicles existing WHERE existing.plate = v.plate
);

-- =============================================================================
-- SECCIÓN: DML DATOS INICIALES Y SEMILLAS DEL SISTEMA -> iam
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: seed-admin-user.sql
-- -----------------------------------------------------------------------------
-- ============================================================================
-- SEED: Super Administrator User
-- NOTA DE SEGURIDAD:
-- En ambientes de producción o staging, defina la configuración de sesión:
--   SET app.admin_password_hash = '<hash_bcrypt_seguro>';
-- Si no está definida, la cuenta queda BLOQUEADA (sin contraseña conocida) y la API le asigna
-- la contraseña real al arrancar a partir de BOOTSTRAP_ADMIN_PASSWORD.
-- ============================================================================

INSERT INTO iam.users (
    id, first_name, last_name, email, document_number, password_hash, account_status, is_profile_complete, email_verified_at
) VALUES (
    'a0000000-0000-0000-0000-000000000001',
    'Super',
    'Administrator',
    'admin@drivique.com',
    '1000000000',
    COALESCE(NULLIF(current_setting('app.admin_password_hash', true), ''), '!LOCKED-DEFINE-BOOTSTRAP-PASSWORD'),
    'ACTIVE',
    TRUE,
    CURRENT_TIMESTAMP
) ON CONFLICT (email) DO NOTHING;

INSERT INTO iam.user_roles (user_id, role_id)
SELECT u.id, r.id
FROM iam.users u
CROSS JOIN iam.roles r
WHERE u.email = 'admin@drivique.com' AND r.code = 'SUPER_ADMIN'
ON CONFLICT DO NOTHING;

-- -----------------------------------------------------------------------------
-- Archivo: seed-identity-catalogs.sql
-- -----------------------------------------------------------------------------
INSERT INTO iam.document_types (code, name, requires_front_and_back) VALUES
    ('CC', 'Citizenship Card', TRUE),
    ('CE', 'Foreign Resident ID', TRUE),
    ('PASSPORT', 'Passport', FALSE),
    ('TI', 'Identity Card', TRUE),
    ('NIT', 'Tax Identification Number', FALSE),
    ('DRIVER_LICENSE', 'Driver License', FALSE)
ON CONFLICT (code) DO NOTHING;

INSERT INTO iam.nationalities (name, iso_code) VALUES
    ('Argentina', 'AR'),
    ('Australia', 'AU'),
    ('Brazil', 'BR'),
    ('Canada', 'CA'),
    ('Chile', 'CL'),
    ('China', 'CN'),
    ('Colombia', 'CO'),
    ('Ecuador', 'EC'),
    ('France', 'FR'),
    ('Germany', 'DE'),
    ('India', 'IN'),
    ('Italy', 'IT'),
    ('Japan', 'JP'),
    ('Mexico', 'MX'),
    ('Peru', 'PE'),
    ('Spain', 'ES'),
    ('United Kingdom', 'GB'),
    ('United States', 'US'),
    ('Venezuela', 'VE')
ON CONFLICT (iso_code) DO NOTHING;

INSERT INTO iam.document_statuses (code, name) VALUES
    ('PENDING', 'Pending'),
    ('APPROVED', 'Approved'),
    ('REJECTED', 'Rejected')
ON CONFLICT (code) DO NOTHING;

-- -----------------------------------------------------------------------------
-- Archivo: seed-password-policies.sql
-- -----------------------------------------------------------------------------
INSERT INTO iam.password_policies (
    policy_name, min_length, require_uppercase, require_number, require_symbol,
    password_history_limit, expiration_days, is_active
) VALUES (
    'DRIVIQUE_DEFAULT', 12, TRUE, TRUE, TRUE, 5, 90, TRUE
);

-- -----------------------------------------------------------------------------
-- Archivo: seed-permissions.sql
-- -----------------------------------------------------------------------------
INSERT INTO iam.permissions (code, name, description) VALUES
    ('USERS_READ', 'Read Users', 'View user accounts and profiles'),
    ('USERS_MANAGE', 'Manage Users', 'Create, update, lock, and manage user accounts'),
    ('ROLES_MANAGE', 'Manage Roles', 'Manage roles and permission assignments'),
    ('BRAND_CONFIGURATION_MANAGE', 'Manage Brand Configuration', 'Manage platform brand settings'),
    ('BRANCHES_MANAGE', 'Manage Branches', 'Manage cities, branches, and branch staff'),
    ('FLEET_MANAGE', 'Manage Fleet', 'Manage vehicles, maintenance, and fleet catalogs'),
    ('CATALOG_MANAGE', 'Manage Catalog', 'Manage prices, coverages, services, and promotions'),
    ('RESERVATIONS_READ', 'Read Reservations', 'View reservations and availability'),
    ('RESERVATIONS_MANAGE', 'Manage Reservations', 'Create and manage reservation lifecycle'),
    ('CONTRACTS_MANAGE', 'Manage Contracts', 'Create contracts, inspections, and signatures'),
    ('PAYMENTS_MANAGE', 'Manage Payments', 'Process payments and cash confirmations'),
    ('SUPPORT_MANAGE', 'Manage Support', 'Manage tickets, incidents, and notifications'),
    ('REPORTS_READ', 'Read Reports', 'Generate and view operational reports'),
    ('AUDIT_READ', 'Read Audit Log', 'View auditable business events')
ON CONFLICT (code) DO NOTHING;

-- -----------------------------------------------------------------------------
-- Archivo: seed-role-permissions.sql
-- -----------------------------------------------------------------------------
INSERT INTO iam.role_permissions (role_id, permission_id)
SELECT role.id, permission.id
FROM iam.roles AS role
CROSS JOIN iam.permissions AS permission
WHERE role.code = 'SUPER_ADMIN'
ON CONFLICT DO NOTHING;

INSERT INTO iam.role_permissions (role_id, permission_id)
SELECT role.id, permission.id
FROM iam.roles AS role
JOIN iam.permissions AS permission ON permission.code IN (
    'USERS_READ', 'BRANCHES_MANAGE', 'FLEET_MANAGE', 'CATALOG_MANAGE',
    'RESERVATIONS_READ', 'RESERVATIONS_MANAGE', 'CONTRACTS_MANAGE',
    'PAYMENTS_MANAGE', 'SUPPORT_MANAGE', 'REPORTS_READ'
)
WHERE role.code = 'BRANCH_ADMIN'
ON CONFLICT DO NOTHING;

INSERT INTO iam.role_permissions (role_id, permission_id)
SELECT role.id, permission.id
FROM iam.roles AS role
JOIN iam.permissions AS permission ON permission.code IN (
    'RESERVATIONS_READ', 'RESERVATIONS_MANAGE', 'CONTRACTS_MANAGE',
    'PAYMENTS_MANAGE', 'SUPPORT_MANAGE'
)
WHERE role.code = 'EMPLOYEE'
ON CONFLICT DO NOTHING;

-- -----------------------------------------------------------------------------
-- Archivo: seed-roles.sql
-- -----------------------------------------------------------------------------
INSERT INTO iam.roles (code, name, description, is_active) VALUES
    ('SUPER_ADMIN', 'Super Administrator', 'Full system access and tenant management', TRUE),
    ('BRANCH_ADMIN', 'Branch Administrator', 'Branch-level operational management', TRUE),
    ('CUSTOMER', 'Customer', 'End-user vehicle rental and profile self-service', TRUE)
ON CONFLICT (code) DO NOTHING;

-- -----------------------------------------------------------------------------
-- Archivo: seed-security-configurations.sql
-- -----------------------------------------------------------------------------
INSERT INTO iam.security_configurations (config_key, config_value, description) VALUES
    ('MAX_LOGIN_ATTEMPTS', '5', 'Maximum consecutive failed login attempts before account lockout.'),
    ('ACCOUNT_LOCKOUT_MINUTES', '30', 'Duration of an account lockout after reaching the maximum failed attempts.'),
    ('MFA_REQUIRED_FOR_ADMINS', 'true', 'Whether multi-factor authentication is required for administrator accounts.'),
    ('SESSION_IDLE_TIMEOUT_MINUTES', '30', 'Maximum inactive session duration before the user must authenticate again.'),
    ('PASSWORD_RESET_TOKEN_EXPIRATION_MINUTES', '15', 'Validity duration for password reset tokens.');

-- =============================================================================
-- SECCIÓN: DML DATOS INICIALES Y SEMILLAS DEL SISTEMA -> location
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: seed-branches.sql
-- -----------------------------------------------------------------------------
INSERT INTO location.branches (
    name,
    address,
    city_id,
    phone,
    opening_time,
    closing_time,
    allows_cash_payment
)
SELECT
    seeded_branches.name,
    seeded_branches.address,
    cities.id,
    seeded_branches.phone,
    seeded_branches.opening_time,
    seeded_branches.closing_time,
    seeded_branches.allows_cash_payment
FROM (
    VALUES
        ('Drivique Bogotá Centro', 'Carrera 7 # 72-41', 'Bogotá', '+57 601 555 0101', '08:00'::TIME, '18:00'::TIME, TRUE),
        ('Drivique Medellín Centro', 'Calle 10 # 43C-30', 'Medellín', '+57 604 555 0102', '08:00'::TIME, '18:00'::TIME, TRUE),
        ('Drivique Medellín Aeropuerto', 'Aeropuerto Internacional José María Córdova', 'Rionegro', '+57 604 555 0103', '06:00'::TIME, '22:00'::TIME, FALSE),
        ('Drivique Cali Centro', 'Avenida 6N # 24N-12', 'Cali', '+57 602 555 0104', '08:00'::TIME, '18:00'::TIME, TRUE),
        ('Drivique Barranquilla Centro', 'Carrera 53 # 80-198', 'Barranquilla', '+57 605 555 0105', '08:00'::TIME, '18:00'::TIME, TRUE),
        ('Drivique Cartagena Centro', 'Avenida San Martín # 8-67', 'Cartagena', '+57 605 555 0106', '08:00'::TIME, '18:00'::TIME, TRUE)
) AS seeded_branches(name, address, city_name, phone, opening_time, closing_time, allows_cash_payment)
JOIN location.cities ON cities.name = seeded_branches.city_name;

-- -----------------------------------------------------------------------------
-- Archivo: seed-colombian-territorial-division.sql
-- -----------------------------------------------------------------------------
INSERT INTO location.departments (name) VALUES
    ('Antioquia'),
    ('Atlántico'),
    ('Bogotá D.C.'),
    ('Bolívar'),
    ('Boyacá'),
    ('Caldas'),
    ('Cesar'),
    ('Córdoba'),
    ('Cundinamarca'),
    ('Huila'),
    ('Magdalena'),
    ('Meta'),
    ('Nariño'),
    ('Norte de Santander'),
    ('Quindío'),
    ('Risaralda'),
    ('Santander'),
    ('Tolima'),
    ('Valle del Cauca');

INSERT INTO location.cities (department_id, name, has_airport, has_terminal)
SELECT departments.id, seeded_cities.name, seeded_cities.has_airport, seeded_cities.has_terminal
FROM (
    VALUES
        ('Antioquia', 'Medellín', TRUE, TRUE),
        ('Antioquia', 'Rionegro', TRUE, FALSE),
        ('Atlántico', 'Barranquilla', TRUE, TRUE),
        ('Bogotá D.C.', 'Bogotá', TRUE, TRUE),
        ('Bolívar', 'Cartagena', TRUE, TRUE),
        ('Boyacá', 'Tunja', FALSE, TRUE),
        ('Caldas', 'Manizales', TRUE, TRUE),
        ('Cesar', 'Valledupar', TRUE, TRUE),
        ('Córdoba', 'Montería', TRUE, TRUE),
        ('Cundinamarca', 'Soacha', FALSE, TRUE),
        ('Huila', 'Neiva', TRUE, TRUE),
        ('Magdalena', 'Santa Marta', TRUE, TRUE),
        ('Meta', 'Villavicencio', TRUE, TRUE),
        ('Nariño', 'Pasto', TRUE, TRUE),
        ('Norte de Santander', 'Cúcuta', TRUE, TRUE),
        ('Quindío', 'Armenia', TRUE, TRUE),
        ('Risaralda', 'Pereira', TRUE, TRUE),
        ('Santander', 'Bucaramanga', TRUE, TRUE),
        ('Tolima', 'Ibagué', TRUE, TRUE),
        ('Valle del Cauca', 'Cali', TRUE, TRUE)
) AS seeded_cities(department_name, name, has_airport, has_terminal)
JOIN location.departments ON departments.name = seeded_cities.department_name;

-- =============================================================================
-- SECCIÓN: DML DATOS INICIALES Y SEMILLAS DEL SISTEMA -> rental
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: seed-document-review-reservation-status.sql
-- -----------------------------------------------------------------------------
INSERT INTO rental.reservation_statuses (code, name, blocks_availability)
VALUES ('PENDING_DOCUMENT_REVIEW', 'Pending document review', TRUE)
ON CONFLICT (code) DO UPDATE
SET blocks_availability = TRUE;

-- -----------------------------------------------------------------------------
-- Archivo: seed-pending-schedule-reservation-status.sql
-- -----------------------------------------------------------------------------
INSERT INTO rental.reservation_statuses (code, name, blocks_availability)
VALUES ('PENDING_SCHEDULE', 'Pending branch schedule', TRUE)
ON CONFLICT (code) DO UPDATE
SET blocks_availability = TRUE;

-- -----------------------------------------------------------------------------
-- Archivo: seed-reservation-statuses.sql
-- -----------------------------------------------------------------------------
INSERT INTO rental.reservation_statuses (code, name, blocks_availability) VALUES
    ('PENDING_PAYMENT', 'Pending payment', TRUE),
    ('CONFIRMED', 'Confirmed', TRUE),
    ('IN_PROGRESS', 'In progress', TRUE),
    ('COMPLETED', 'Completed', FALSE),
    ('CANCELLED_BY_TIMEOUT', 'Cancelled by timeout', FALSE),
    ('CANCELLED_BY_USER', 'Cancelled by user', FALSE),
    ('REJECTED', 'Rejected', FALSE);

-- =============================================================================
-- SECCIÓN: DML DATOS INICIALES Y SEMILLAS DEL SISTEMA -> support
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Archivo: seed-notification-templates.sql
-- -----------------------------------------------------------------------------
INSERT INTO support.notification_templates (
    code, name, event_type, channel, subject_template, body_template
) VALUES
(
    'REGISTRATION_WELCOME_EMAIL',
    'Bienvenida al registrarse',
    'REGISTRATION',
    'EMAIL',
    '¡Bienvenido a Drivique, {{firstName}}!',
    'Hola {{firstName}}, tu cuenta en Drivique ha sido creada con éxito. Ya puedes explorar y reservar tu vehículo.'
),
(
    'PAYMENT_SUCCESS_EMAIL',
    'Confirmación de pago exitoso',
    'PAYMENT',
    'EMAIL',
    'Comprobante de pago - Reserva {{bookingCode}}',
    'Hemos recibido tu pago de {{amount}} {{currency}} para la reserva {{bookingCode}}. Adjuntamos el recibo correspondiente.'
),
(
    'PAYMENT_SUCCESS_IN_APP',
    'Comprobante in-app de pago exitoso',
    'PAYMENT',
    'IN_APP',
    '¡Pago exitoso de tu reserva {{bookingCode}}!',
    'Tu pago de {{amount}} {{currency}} fue aprobado exitosamente. Tu reserva está confirmada.'
),
(
    'PAYMENT_FAILED_EMAIL',
    'Notificación de fallo en pago',
    'PAYMENT',
    'EMAIL',
    'Problema con tu pago - Reserva {{bookingCode}}',
    'No pudimos procesar tu pago de {{amount}} {{currency}}. Por favor actualiza tu método de pago para mantener tu reserva.'
),
(
    'PAYMENT_FAILED_IN_APP',
    'Notificación in-app de pago rechazado',
    'PAYMENT',
    'IN_APP',
    'Pago rechazado - Reserva {{bookingCode}}',
    'La transacción de {{amount}} {{currency}} fue rechazada. Reintenta tu pago para mantener la reserva.'
),
(
    'RESERVATION_CONFIRMATION_EMAIL',
    'Confirmación de reserva',
    'RESERVATION',
    'EMAIL',
    'Tu reserva {{bookingCode}} está confirmada',
    'Tu reserva del vehículo {{vehicleModel}} para el {{pickupDate}} en la sede {{branchName}} ha sido confirmada.'
),
(
    'RESERVATION_CONFIRMATION_PUSH',
    'Push de reserva confirmada',
    'RESERVATION',
    'PUSH',
    'Reserva confirmada',
    'Tu reserva {{bookingCode}} está lista. Consulta los detalles de recogida en la app.'
),
(
    'RESERVATION_CONFIRMATION_IN_APP',
    'Confirmación in-app de reserva',
    'RESERVATION',
    'IN_APP',
    'Reserva {{bookingCode}} confirmada',
    'Tu reserva ha sido confirmada con éxito. Ya puedes revisar los detalles y firmar el contrato.'
),
(
    'RESERVATION_CANCELLED_EMAIL',
    'Cancelación de reserva',
    'CANCELLATION',
    'EMAIL',
    'Reserva {{bookingCode}} cancelada',
    'Tu reserva {{bookingCode}} ha sido cancelada conforme a nuestras políticas de cancelación.'
),
(
    'RESERVATION_CANCELLED_IN_APP',
    'Cancelación in-app de reserva',
    'CANCELLATION',
    'IN_APP',
    'Reserva {{bookingCode}} cancelada',
    'Tu reserva {{bookingCode}} ha sido cancelada ({{reason}}). El vehículo ha sido liberado.'
),
(
    'PAYMENT_EXPIRATION_WARNING_EMAIL',
    'Aviso de vencimiento de plazo de pago',
    'PAYMENT_EXPIRATION_WARNING',
    'EMAIL',
    'Plazo de pago por vencer - Reserva {{bookingCode}}',
    'Hola, te recordamos que el plazo para pagar tu reserva {{bookingCode}} está próximo a vencer. Completa tu pago para no perder tu vehículo.'
),
(
    'PAYMENT_EXPIRATION_WARNING_IN_APP',
    'Aviso in-app de vencimiento de pago',
    'PAYMENT_EXPIRATION_WARNING',
    'IN_APP',
    'Plazo de pago por vencer - Reserva {{bookingCode}}',
    'Atención: Tu plazo para pagar la reserva {{bookingCode}} vencerá pronto. Realiza el pago para no perder la reserva.'
),
(
    'CONTRACT_SIGNATURE_EMAIL',
    'Solicitud de firma de contrato',
    'CONTRACT',
    'EMAIL',
    'Firma digital requerida - Contrato {{contractNumber}}',
    'Tu contrato de alquiler {{contractNumber}} está listo para firma digital. Accede para completarlo antes de la entrega.'
),
(
    'VEHICLE_DELIVERY_PUSH',
    'Entrega de vehículo confirmada',
    'DELIVERY',
    'PUSH',
    'Vehículo entregado',
    'La entrega de tu vehículo {{vehiclePlate}} fue registrada exitosamente. ¡Disfruta tu viaje!'
),
(
    'VEHICLE_RETURN_EMAIL',
    'Cierre y devolución de vehículo',
    'RETURN',
    'EMAIL',
    'Devolución completada - Contrato {{contractNumber}}',
    'La inspección de devolución del vehículo {{vehiclePlate}} ha concluido satisfactoriamente.'
),
(
    'DOCUMENT_STATUS_UPDATE_PUSH',
    'Actualización de validación documental',
    'DOCUMENT',
    'PUSH',
    'Estado de tus documentos KYC',
    'Tu documento {{documentType}} ha cambiado a estado {{status}}.'
),
(
    'INCIDENT_REGISTERED_EMAIL',
    'Reporte de incidencia recibido',
    'INCIDENT',
    'EMAIL',
    'Incidencia {{incidentCode}} recibida',
    'Hemos recibido tu reporte de incidencia {{incidentCode}}. Nuestro equipo de soporte está revisando el caso.'
),
(
    'INCIDENT_UPDATE_IN_APP',
    'Actualización de incidencia en la app',
    'INCIDENT',
    'IN_APP',
    'Actualización en tu reporte {{incidentCode}}',
    'Hay novedades en la atención de tu incidencia {{incidentCode}}. Revisa el detalle en el centro de ayuda.'
)
ON CONFLICT (code) DO NOTHING;

