INSERT INTO system_settings (
    setting_key,
    setting_value,
    value_type,
    description,
    is_public,
    is_editable
) VALUES
(
    'audit.store_ip',
    '1',
    'boolean',
    'Guardar la dirección IP de los eventos de auditoría.',
    0,
    1
),
(
    'audit.store_user_agent',
    '1',
    'boolean',
    'Guardar el User-Agent de los eventos de auditoría.',
    0,
    1
),
(
    'security.mfa.enabled',
    '1',
    'boolean',
    'Permitir autenticación multifactor.',
    0,
    1
),
(
    'security.mfa.required_for_admin',
    '0',
    'boolean',
    'Exigir MFA a las cuentas administrativas.',
    0,
    1
)
ON DUPLICATE KEY UPDATE
    setting_value = VALUES(setting_value),
    value_type = VALUES(value_type),
    description = VALUES(description),
    is_public = VALUES(is_public),
    is_editable = VALUES(is_editable);