CREATE TABLE IF NOT EXISTS audit_log (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    user_id BIGINT UNSIGNED NULL,
    username VARCHAR(50) NULL,

    event_type VARCHAR(50) NOT NULL,
    description VARCHAR(255) NULL,

    ip_address VARCHAR(45) NULL,
    user_agent VARCHAR(255) NULL,

    success TINYINT(1) NOT NULL DEFAULT 1,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_audit_log_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    INDEX idx_audit_log_user (user_id),
    INDEX idx_audit_log_event (event_type),
    INDEX idx_audit_log_created (created_at),
    INDEX idx_audit_log_user_created (user_id, created_at)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;