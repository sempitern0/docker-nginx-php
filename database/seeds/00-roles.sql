INSERT INTO roles (
    slug,
    name,
    description
) VALUES
(
    'admin',
    'Administrador',
    'Acceso completo al sistema.'
),
(
    'user',
    'Usuario',
    'Usuario estándar del sistema.'
),
(
    'guest',
    'Invitado',
    'Acceso restringido de lectura.'
)
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    description = VALUES(description);

INSERT INTO permissions (
    slug,
    name,
    description
) VALUES
(
    'users.read',
    'Ver usuarios',
    'Consultar usuarios del sistema.'
),
(
    'users.create',
    'Crear usuarios',
    'Crear nuevos usuarios.'
),
(
    'users.update',
    'Editar usuarios',
    'Modificar usuarios existentes.'
),
(
    'users.delete',
    'Eliminar usuarios',
    'Eliminar o desactivar usuarios.'
),
(
    'users.roles',
    'Gestionar roles',
    'Asignar y retirar roles.'
),
(
    'profile.read',
    'Ver perfil',
    'Consultar el perfil propio.'
),
(
    'profile.update',
    'Editar perfil',
    'Modificar el perfil propio.'
),
(
    'sessions.read',
    'Ver sesiones',
    'Consultar sesiones activas propias.'
),
(
    'sessions.revoke',
    'Revocar sesiones',
    'Cerrar sesiones propias.'
),
(
    'audit.read',
    'Ver auditoría',
    'Consultar registros de auditoría.'
),
(
    'settings.read',
    'Ver configuración',
    'Consultar configuración del sistema.'
),
(
    'settings.update',
    'Editar configuración',
    'Modificar configuración editable.'
)
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    description = VALUES(description);

INSERT IGNORE INTO role_permissions (
    role_id,
    permission_id
)
SELECT
    r.id,
    p.id
FROM roles r
CROSS JOIN permissions p
WHERE r.slug = 'admin';

INSERT IGNORE INTO role_permissions (
    role_id,
    permission_id
)
SELECT
    r.id,
    p.id
FROM roles r
JOIN permissions p
WHERE r.slug = 'user'
  AND p.slug IN (
      'profile.read',
      'profile.update',
      'sessions.read',
      'sessions.revoke'
  );

INSERT IGNORE INTO role_permissions (
    role_id,
    permission_id
)
SELECT
    r.id,
    p.id
FROM roles r
JOIN permissions p
WHERE r.slug = 'guest'
  AND p.slug IN (
      'profile.read'
  );