INSERT INTO system_settings (
    setting_key,
    setting_value,
    value_type,
    description,
    is_public,
    is_editable
)
VALUES
    ('audit.store_ip', '1', 'boolean', 'Guardar la dirección IP de los eventos de auditoría.', FALSE, TRUE),
    ('audit.store_user_agent', '1', 'boolean', 'Guardar el User-Agent de los eventos de auditoría.', FALSE, TRUE),
    ('security.mfa.enabled', '1', 'boolean', 'Permitir autenticación multifactor.', FALSE, TRUE),
    ('security.mfa.required_for_admin', '0', 'boolean', 'Exigir MFA a las cuentas administrativas.', FALSE, TRUE)
ON CONFLICT (setting_key) DO UPDATE SET
    setting_value = EXCLUDED.setting_value,
    value_type = EXCLUDED.value_type,
    description = EXCLUDED.description,
    is_public = EXCLUDED.is_public,
    is_editable = EXCLUDED.is_editable;
