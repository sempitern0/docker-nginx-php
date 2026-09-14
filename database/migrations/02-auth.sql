CREATE TABLE IF NOT EXISTS users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    username VARCHAR(50) NOT NULL,
    email VARCHAR(190) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,

    is_active TINYINT(1) NOT NULL DEFAULT 1,
    email_verified_at DATETIME NULL,

    failed_login_attempts INT UNSIGNED NOT NULL DEFAULT 0,
    locked_until DATETIME NULL,

    password_changed_at DATETIME NULL,
    auth_version BIGINT UNSIGNED NOT NULL DEFAULT 1,

    last_login_at DATETIME NULL,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,

    CONSTRAINT uq_users_username UNIQUE (username),
    CONSTRAINT uq_users_email UNIQUE (email),

    INDEX idx_users_active (is_active),
    INDEX idx_users_deleted (deleted_at),
    INDEX idx_users_locked (locked_until)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS user_profiles (
    user_id BIGINT UNSIGNED PRIMARY KEY,

    first_name VARCHAR(100) NULL,
    last_name VARCHAR(100) NULL,

    phone VARCHAR(30) NULL,

    address_line VARCHAR(255) NULL,
    city VARCHAR(100) NULL,
    postal_code VARCHAR(20) NULL,
    country_code CHAR(2) NOT NULL DEFAULT 'ES',

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_user_profiles_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_sessions (
    id VARCHAR(128) NOT NULL PRIMARY KEY,

    user_id BIGINT UNSIGNED NOT NULL,

    ip_address VARCHAR(45) NULL,
    user_agent VARCHAR(255) NULL,

    last_activity_at DATETIME NOT NULL,
    expires_at DATETIME NOT NULL,
    revoked_at DATETIME NULL,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_user_sessions_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    INDEX idx_user_sessions_user (user_id),
    INDEX idx_user_sessions_expires (expires_at),
    INDEX idx_user_sessions_revoked (revoked_at)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS auth_tokens (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    user_id BIGINT UNSIGNED NOT NULL,

    token_hash CHAR(64) NOT NULL,
    token_type VARCHAR(30) NOT NULL,

    expires_at DATETIME NOT NULL,
    used_at DATETIME NULL,

    created_ip VARCHAR(45) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_auth_tokens_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT uq_auth_tokens_hash UNIQUE (token_hash),

    INDEX idx_auth_tokens_user (user_id),
    INDEX idx_auth_tokens_expires (expires_at),

    CONSTRAINT chk_auth_tokens_type
        CHECK (
            token_type IN (
                'password_reset',
                'email_verification',
                'magic_link'
            )
        )
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_mfa (
    user_id BIGINT UNSIGNED PRIMARY KEY,

    secret_encrypted VARCHAR(255) NOT NULL,

    is_enabled TINYINT(1) NOT NULL DEFAULT 0,
    confirmed_at DATETIME NULL,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_user_mfa_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS mfa_backup_codes (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    user_id BIGINT UNSIGNED NOT NULL,

    code_hash VARCHAR(255) NOT NULL,
    used_at DATETIME NULL,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_mfa_backup_codes_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    INDEX idx_mfa_backup_codes_user (user_id),
    INDEX idx_mfa_backup_codes_used (used_at)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;