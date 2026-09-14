CREATE TABLE IF NOT EXISTS api_keys (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    user_id BIGINT UNSIGNED NOT NULL,

    name VARCHAR(100) NOT NULL,

    key_prefix VARCHAR(20) NOT NULL,
    key_hash CHAR(64) NOT NULL,

    scopes TEXT NULL,

    last_used_at DATETIME NULL,
    expires_at DATETIME NULL,
    revoked_at DATETIME NULL,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_api_keys_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT uq_api_keys_hash UNIQUE (key_hash),
    CONSTRAINT uq_api_keys_user_name UNIQUE (user_id, name),

    INDEX idx_api_keys_user (user_id),
    INDEX idx_api_keys_prefix (key_prefix),
    INDEX idx_api_keys_expires (expires_at),
    INDEX idx_api_keys_revoked (revoked_at)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS rate_limits (
    bucket_key BINARY(32) NOT NULL PRIMARY KEY,

    attempts INT UNSIGNED NOT NULL DEFAULT 0,

    window_started_at DATETIME NOT NULL,
    last_attempt_at DATETIME NOT NULL,

    INDEX idx_rate_limits_last_attempt (last_attempt_at),
    INDEX idx_rate_limits_window (window_started_at)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;