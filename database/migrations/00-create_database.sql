SET NAMES utf8mb4;

SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE IF NOT EXISTS app_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE app_db;

CREATE TABLE IF NOT EXISTS rate_limits (
    bucket_key BINARY(32) NOT NULL,
    attempts INT UNSIGNED NOT NULL DEFAULT 0,
    window_started_at DATETIME NOT NULL,
    last_attempt_at DATETIME NOT NULL,

    PRIMARY KEY (bucket_key),
    INDEX idx_rate_limits_last_attempt (last_attempt_at)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;
  
CREATE TABLE IF NOT EXISTS users (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(190) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    mfa_secret VARCHAR(64) NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    is_email_verified TINYINT(1) NOT NULL DEFAULT 0,
    mfa_enabled TINYINT(1) NOT NULL DEFAULT 0,
    failed_attempts INT UNSIGNED NOT NULL DEFAULT 0,
    locked_until DATETIME NULL,
    last_login_at DATETIME NULL,
    password_changed_at DATETIME NULL,
    auth_version BIGINT UNSIGNED NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    CONSTRAINT uq_users_username UNIQUE (username),
    CONSTRAINT uq_users_email UNIQUE (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_profiles (
    user_id INT UNSIGNED PRIMARY KEY,
    first_name VARCHAR(50) NULL,
    last_name VARCHAR(50) NULL,
    dni_nif_encrypted VARCHAR(255) NULL,
    phone VARCHAR(20) NULL,
    address_line VARCHAR(255) NULL,
    city VARCHAR(100) NULL,
    postal_code VARCHAR(20) NULL,
    country VARCHAR(50) NOT NULL DEFAULT 'ES',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_profiles_user FOREIGN KEY (user_id)
        REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS roles (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description VARCHAR(255) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_roles_name UNIQUE (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS permissions (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    slug VARCHAR(100) NOT NULL,
    description VARCHAR(255) NULL,
    CONSTRAINT uq_permissions_slug UNIQUE (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS role_permissions (
    role_id INT UNSIGNED NOT NULL,
    permission_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (role_id, permission_id),
    CONSTRAINT fk_rp_role FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    CONSTRAINT fk_rp_permission FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_roles (
    user_id INT UNSIGNED NOT NULL,
    role_id INT UNSIGNED NOT NULL,
    assigned_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, role_id),
    CONSTRAINT fk_ur_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_ur_role FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS user_mfa (
    user_id INT UNSIGNED PRIMARY KEY,
    totp_secret_encrypted VARCHAR(255) NOT NULL,
    is_confirmed TINYINT(1) NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_mfa_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS mfa_backup_codes (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    code_hash VARCHAR(255) NOT NULL,
    used_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_mfa_backup_user (user_id),
    CONSTRAINT fk_mfa_backup_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_sessions (
    id VARCHAR(64) PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    ip_address VARCHAR(45) NOT NULL,
    user_agent VARCHAR(255) NULL,
    payload TEXT NULL,
    last_activity DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    expires_at DATETIME NOT NULL,
    INDEX idx_sessions_user (user_id),
    INDEX idx_sessions_expires (expires_at),
    CONSTRAINT fk_sessions_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS auth_tokens (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    token_hash VARCHAR(64) NOT NULL,
    type VARCHAR(30) NOT NULL,
    expires_at DATETIME NOT NULL,
    used_at DATETIME NULL,
    created_by_ip VARCHAR(45) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_tokens_hash (token_hash),
    CONSTRAINT fk_tokens_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT chk_tokens_type CHECK (type IN ('password_reset', 'email_verify', 'magic_link'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS api_keys (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    name VARCHAR(100) NOT NULL,
    key_prefix VARCHAR(10) NOT NULL,
    key_hash VARCHAR(64) NOT NULL,
    scopes VARCHAR(255) NULL,
    last_used_at DATETIME NULL,
    expires_at DATETIME NULL,
    revoked TINYINT(1) NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_apikeys_hash (key_hash),
    CONSTRAINT fk_apikeys_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS audit_log (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NULL,
    username VARCHAR(50) NULL,
    event_type VARCHAR(50) NOT NULL,
    description VARCHAR(255) NULL,
    ip_address VARCHAR(45) NULL,
    user_agent VARCHAR(255) NULL,
    success TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_audit_user (user_id),
    INDEX idx_audit_event (event_type),
    INDEX idx_audit_created (created_at),
    INDEX idx_audit_user_created (user_id, created_at),
    INDEX idx_audit_search (created_at, username),
    CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS system_settings (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    setting_key VARCHAR(100) NOT NULL,
    setting_value TEXT NULL,

    value_type VARCHAR(20) NOT NULL DEFAULT 'string',

    description VARCHAR(255) NULL,

    is_public TINYINT(1) NOT NULL DEFAULT 0,
    is_editable TINYINT(1) NOT NULL DEFAULT 1,

    updated_by INT UNSIGNED NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT uq_system_settings_key UNIQUE (setting_key),

    CONSTRAINT fk_system_settings_user
        FOREIGN KEY (updated_by)
        REFERENCES users(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    CONSTRAINT chk_system_settings_type
        CHECK (
            value_type IN (
                'string',
                'integer',
                'boolean',
                'json'
            )
        ),

    INDEX idx_system_settings_editable (is_editable),
    INDEX idx_system_settings_public (is_public)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;


INSERT INTO system_settings
    (setting_key, setting_value, value_type, description)
VALUES

(
    'audit.store_ip',
    '1',
    'boolean',
    'Guardar la dirección IP en los registros de auditoría.'
),

(
    'audit.store_user_agent',
    '1',
    'boolean',
    'Guardar el User-Agent en los registros de auditoría.'
),

(
    'security.mfa.enabled',
    '1',
    'boolean',
    'Permitir el uso de MFA en las cuentas.'
),

(
    'security.mfa.required_for_admin',
    '0',
    'boolean',
    'Obligar a los administradores a utilizar MFA.'
),

(
    'ui.theme',
    'default',
    'string',
    'Tema visual activo.'
)

ON DUPLICATE KEY UPDATE
    setting_key = VALUES(setting_key);
    
INSERT INTO roles (id, name, description) VALUES
(1, 'admin', 'Administrador del sistema con acceso total'),
(3, 'usuario', 'Usuario estándar'),
(4, 'invitado', 'Acceso restringido de solo lectura'),
(8, 'support', 'Visualiza datos que ayuden a dar soporte'),
ON DUPLICATE KEY UPDATE description = VALUES(description);

INSERT INTO permissions (id, slug, description) VALUES
(1, 'users:read', 'Ver lista de usuarios'),
(2, 'users:write', 'Crear y editar usuarios'),
(3, 'users:delete', 'Eliminar usuarios'),
(4, 'audit:read', 'Ver registros de auditoría'),
(5, 'audit:delete', 'Borrar registro de auditoría'),

(6, 'profile:read', 'Consultar el propio perfil'),
(7, 'profile:update', 'Modificar el propio perfil'),

(8, 'users:roles', 'Asignar y retirar roles de usuarios'),
(9, 'users:activate', 'Activar y desactivar usuarios'),
(10, 'users:reset_password', 'Restablecer contraseñas de usuarios'),
(11, 'users:mfa', 'Gestionar MFA de usuarios'),

(12, 'api_keys:read', 'Ver claves API propias'),
(13, 'api_keys:create', 'Crear claves API propias'),
(14, 'api_keys:revoke', 'Revocar claves API propias'),

(15, 'sessions:read', 'Ver sesiones propias'),
(16, 'sessions:revoke', 'Revocar sesiones propias')

ON DUPLICATE KEY UPDATE description = VALUES(description);

-- ============================================================================
-- 10. PERMISOS POR ROL
-- ============================================================================

-- Admin: todos los permisos.
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r CROSS JOIN permissions p
WHERE r.name = 'admin';


-- Usuario.
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r JOIN permissions p
WHERE r.name = 'usuario'
AND p.slug IN (
    'profile:read',
    'profile:update',
    'sessions:read',
    'sessions:revoke'
);


INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r JOIN permissions p
WHERE r.name = 'support'
AND p.slug IN (
    'users:read',
    'profile:read'
);


INSERT INTO users (id, username, email, password_hash, is_email_verified) VALUES
(1, 'admin', 'admin@mercadoblanco.local', '$2y$10$HwONg/7rp5yF0ZRouA9BmeMRUXN2Jitf2apx0SbBUcfORcD.OWAEm', 1),
(2, 'profesor', 'profesor@mercadoblanco.local', '$2y$10$HwONg/7rp5yF0ZRouA9BmeMRUXN2Jitf2apx0SbBUcfORcD.OWAEm', 1),
(3, 'usuario', 'usuario@mercadoblanco.local', '$2y$10$HwONg/7rp5yF0ZRouA9BmeMRUXN2Jitf2apx0SbBUcfORcD.OWAEm', 1),
(4, 'invitado', 'invitado@mercadoblanco.local', '$2y$10$HwONg/7rp5yF0ZRouA9BmeMRUXN2Jitf2apx0SbBUcfORcD.OWAEm', 1)
ON DUPLICATE KEY UPDATE
    password_hash = VALUES(password_hash),
    is_email_verified = VALUES(is_email_verified),
    password_changed_at = CURRENT_TIMESTAMP;

UPDATE users
SET auth_version = GREATEST(auth_version, 1)
WHERE id IN (1, 2, 3, 4);

INSERT INTO user_roles (user_id, role_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4)
ON DUPLICATE KEY UPDATE role_id = VALUES(role_id);

INSERT INTO user_profiles (user_id, first_name, last_name) VALUES
(1, 'Super', 'Admin'),
(2, 'Profe', 'Seguridad'),
(3, 'Juan', 'Pérez'),
(4, 'Visitante', 'Anónimo')
ON DUPLICATE KEY UPDATE
    first_name = VALUES(first_name),
    last_name = VALUES(last_name);

SET FOREIGN_KEY_CHECKS = 1;