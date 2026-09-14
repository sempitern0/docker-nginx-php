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

CREATE TABLE IF NOT EXISTS rate_limits (
    bucket_key BINARY(32) NOT NULL PRIMARY KEY,

    attempts INT UNSIGNED NOT NULL DEFAULT 0,

    window_started_at DATETIME NOT NULL,
    last_attempt_at DATETIME NOT NULL,

    INDEX idx_rate_limits_last_attempt (last_attempt_at)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;