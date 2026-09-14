INSERT INTO roles (slug, name, description)
VALUES
    ('admin', 'Administrador', 'Acceso completo al sistema.'),
    ('user', 'Usuario', 'Usuario estándar del sistema.'),
    ('guest', 'Invitado', 'Acceso restringido de lectura.')
ON CONFLICT (slug) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description;

INSERT INTO permissions (slug, name, description)
VALUES
    ('users.read', 'Ver usuarios', 'Consultar usuarios del sistema.'),
    ('users.create', 'Crear usuarios', 'Crear nuevos usuarios.'),
    ('users.update', 'Editar usuarios', 'Modificar usuarios existentes.'),
    ('users.delete', 'Eliminar usuarios', 'Eliminar o desactivar usuarios.'),
    ('users.roles', 'Gestionar roles', 'Asignar y retirar roles.'),
    ('profile.read', 'Ver perfil', 'Consultar el perfil propio.'),
    ('profile.update', 'Editar perfil', 'Modificar el perfil propio.'),
    ('sessions.read', 'Ver sesiones', 'Consultar sesiones activas propias.'),
    ('sessions.revoke', 'Revocar sesiones', 'Cerrar sesiones propias.'),
    ('audit.read', 'Ver auditoría', 'Consultar registros de auditoría.'),
    ('settings.read', 'Ver configuración', 'Consultar configuración del sistema.'),
    ('settings.update', 'Editar configuración', 'Modificar configuración editable.')
ON CONFLICT (slug) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description;

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
CROSS JOIN permissions p
WHERE r.slug = 'admin'
ON CONFLICT DO NOTHING;

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.slug IN ('profile.read', 'profile.update', 'sessions.read', 'sessions.revoke')
WHERE r.slug = 'user'
ON CONFLICT DO NOTHING;

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.slug = 'profile.read'
WHERE r.slug = 'guest'
ON CONFLICT DO NOTHING;
