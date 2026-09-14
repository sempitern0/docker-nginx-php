INSERT INTO users (
    username,
    email,
    password_hash,
    is_active,
    email_verified_at,
    password_changed_at
) VALUES
(
    'admin',
    'admin@example.test',
    '$2y$12$DgtiFuz5DflfNuXaFKeCTebIaRMCQkTWqhTnP0zc4fsk6xjAH6cKC',
    1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    'user',
    'user@example.test',
    '$2y$12$sFA5lQHFbuCNfY3Ki/7CJO9S11hbSatbp5WxQkWiouYmNV9tJcdDy',
    1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    'guest',
    'guest@example.test',
    '$2y$12$0yuocQrLfo.OocUVv2rR7eemLNY9Waz2g8/7L.7AOAcz0LVo7Zq/i',
    1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
)
ON DUPLICATE KEY UPDATE
    email = VALUES(email),
    is_active = VALUES(is_active),
    email_verified_at = VALUES(email_verified_at),
    password_changed_at = VALUES(password_changed_at);


INSERT IGNORE INTO user_roles (
    user_id,
    role_id
)
SELECT
    u.id,
    r.id
FROM users u
JOIN roles r
WHERE
    (
        u.username = 'admin'
        AND r.slug = 'admin'
    )
    OR
    (
        u.username = 'user'
        AND r.slug = 'user'
    )
    OR
    (
        u.username = 'guest'
        AND r.slug = 'guest'
    );

INSERT INTO user_profiles (
    user_id,
    first_name,
    last_name,
    country_code
)
SELECT
    id,
    CASE username
        WHEN 'admin' THEN 'Admin'
        WHEN 'user' THEN 'Normal'
        WHEN 'guest' THEN 'Guest'
    END,
    'Demo',
    'ES'
FROM users
WHERE username IN ('admin', 'user', 'guest')
ON DUPLICATE KEY UPDATE
    first_name = VALUES(first_name),
    last_name = VALUES(last_name),
    country_code = VALUES(country_code);