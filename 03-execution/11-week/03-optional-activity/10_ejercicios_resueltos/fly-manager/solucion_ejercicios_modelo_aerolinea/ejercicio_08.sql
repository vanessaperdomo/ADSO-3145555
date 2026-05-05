-- ============================================================
-- EJERCICIO 08 - Auditoría de acceso y asignación de roles
--               a usuarios
-- ============================================================

-- ► REQ 1: Consulta INNER JOIN (7 tablas)
-- Tablas: person, user_account, user_status, user_role,
--         security_role, role_permission, security_permission
SELECT
    p.first_name || ' ' || p.last_name    AS nombre_persona,
    ua.username                            AS usuario,
    us.status_name                         AS estado_usuario,
    sr.role_name                           AS rol_asignado,
    ur.assigned_at                         AS fecha_asignacion_rol,
    sp.permission_name                     AS permiso_asociado,
    rp.granted_at                          AS fecha_permiso_otorgado
FROM person p
INNER JOIN user_account ua          ON ua.person_id = p.person_id
INNER JOIN user_status us           ON us.user_status_id = ua.user_status_id
INNER JOIN user_role ur             ON ur.user_account_id = ua.user_account_id
INNER JOIN security_role sr         ON sr.security_role_id = ur.security_role_id
INNER JOIN role_permission rp       ON rp.security_role_id = sr.security_role_id
INNER JOIN security_permission sp   ON sp.security_permission_id = rp.security_permission_id
ORDER BY p.last_name, ua.username, sr.role_name, sp.permission_name;

-- ► REQ 2: Función del trigger
-- Cuando se asigna un nuevo rol a un usuario,
-- actualiza updated_at de la cuenta para reflejar el cambio de acceso
CREATE OR REPLACE FUNCTION fn_actualizar_cuenta_por_rol()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE user_account
    SET updated_at = now()
    WHERE user_account_id = NEW.user_account_id;

    RAISE NOTICE 'Rol asignado a usuario_id: %. Cuenta actualizada.',
        NEW.user_account_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ► REQ 2: Trigger AFTER INSERT sobre user_role
CREATE OR REPLACE TRIGGER trg_after_user_role_insert
AFTER INSERT ON user_role
FOR EACH ROW
EXECUTE FUNCTION fn_actualizar_cuenta_por_rol();

-- ► REQ 3: Procedimiento almacenado
-- Asigna un rol a un usuario existente
CREATE OR REPLACE PROCEDURE sp_asignar_rol_usuario(
    p_user_account_id      uuid,
    p_security_role_id     uuid,
    p_assigned_by_user_id  uuid,
    p_assigned_at          timestamptz
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Validar que el usuario exista
    IF NOT EXISTS (
        SELECT 1 FROM user_account
        WHERE user_account_id = p_user_account_id
    ) THEN
        RAISE EXCEPTION 'No existe usuario con user_account_id: %', p_user_account_id;
    END IF;

    -- Validar que el rol exista
    IF NOT EXISTS (
        SELECT 1 FROM security_role
        WHERE security_role_id = p_security_role_id
    ) THEN
        RAISE EXCEPTION 'No existe rol con security_role_id: %', p_security_role_id;
    END IF;

    -- Validar que no tenga ya ese rol asignado
    IF EXISTS (
        SELECT 1 FROM user_role
        WHERE user_account_id = p_user_account_id
          AND security_role_id = p_security_role_id
    ) THEN
        RAISE EXCEPTION 'El usuario ya tiene asignado ese rol';
    END IF;

    -- Asignar el rol
    INSERT INTO user_role (
        user_account_id,
        security_role_id,
        assigned_at,
        assigned_by_user_id
    )
    VALUES (
        p_user_account_id,
        p_security_role_id,
        p_assigned_at,
        p_assigned_by_user_id
    );

    RAISE NOTICE 'Rol % asignado al usuario %', p_security_role_id, p_user_account_id;
END;
$$;

-- ► INVOCAR el procedimiento con IDs reales
DO $$
DECLARE
    v_user_account_id   uuid;
    v_security_role_id  uuid;
    v_assigned_by_id    uuid;
BEGIN
    -- Usuario al que se le asignará el rol
    SELECT ua.user_account_id INTO v_user_account_id
    FROM user_account ua
    WHERE NOT EXISTS (
        SELECT 1 FROM user_role ur
        WHERE ur.user_account_id = ua.user_account_id
    )
    LIMIT 1;

    -- Rol a asignar
    SELECT security_role_id INTO v_security_role_id
    FROM security_role
    LIMIT 1;

    -- Usuario que hace la asignación
    SELECT user_account_id INTO v_assigned_by_id
    FROM user_account
    WHERE user_account_id <> v_user_account_id
    LIMIT 1;

    CALL sp_asignar_rol_usuario(
        v_user_account_id,
        v_security_role_id,
        v_assigned_by_id,
        now()
    );
END;
$$;

-- ► VALIDACIÓN: Ver el rol asignado
SELECT
    ur.user_role_id,
    ur.user_account_id,
    sr.role_name,
    sr.role_code,
    ur.assigned_at,
    ur.assigned_by_user_id
FROM user_role ur
INNER JOIN security_role sr ON sr.security_role_id = ur.security_role_id
ORDER BY ur.created_at DESC
LIMIT 3;

-- ► VALIDACIÓN: Ver que el trigger actualizó la cuenta del usuario
SELECT
    user_account_id,
    username,
    updated_at
FROM user_account
ORDER BY updated_at DESC
LIMIT 3;