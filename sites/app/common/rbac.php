<?php

declare(strict_types=1);

/**
 * Obtiene los nombres de los roles asignados a un usuario.
 * @return array<string>
 */
function get_user_roles(int $userId): array
{
    $stmt = db()->prepare('
        SELECT r.name
        FROM roles r
        JOIN user_roles ur ON r.id = ur.role_id
        WHERE ur.user_id = ?
    ');

    $stmt->execute([$userId]);
    return $stmt->fetchAll(PDO::FETCH_COLUMN) ?: [];
}

/**
 * Obtiene los slugs de permisos asignados a un usuario a través de sus roles.
 * @return array<string>
 */
function get_user_permissions(int $userId): array
{
    $stmt = db()->prepare('
        SELECT DISTINCT p.slug
        FROM permissions p
        JOIN role_permissions rp ON p.id = rp.permission_id
        JOIN user_roles ur ON rp.role_id = ur.role_id
        WHERE ur.user_id = ?
    ');

    $stmt->execute([$userId]);
    return $stmt->fetchAll(PDO::FETCH_COLUMN) ?: [];
}

/**
 * Obtiene los detalles completos de los permisos asignados a un usuario.
 * @return array<array<string, mixed>>
 */
function get_user_permissions_detailed(int $userId): array
{
    static $cache = [];

    if (isset($cache[$userId])) {
        return $cache[$userId];
    }

    $stmt = db()->prepare('
        SELECT DISTINCT p.id, p.slug, p.description
        FROM permissions p
        JOIN role_permissions rp ON p.id = rp.permission_id
        JOIN user_roles ur ON rp.role_id = ur.role_id
        WHERE ur.user_id = ?
        ORDER BY p.slug ASC
    ');

    $stmt->execute([$userId]);
    $cache[$userId] = $stmt->fetchAll() ?: [];

    return $cache[$userId];
}

/**
 * Obtiene el perfil/datos PII de un usuario desde user_profiles.
 */
function get_user_profile(int $userId): ?array
{
    $stmt = db()->prepare('SELECT * FROM user_profiles WHERE user_id = ? LIMIT 1');
    $stmt->execute([$userId]);
    return $stmt->fetch() ?: null;
}

/**
 * Carga/refresca la autorización del usuario actual.
 */
function current_authorization(bool $forceRefresh = false): array
{
    static $requestCache = [];

    if (session_status() === PHP_SESSION_NONE) {
        start_secure_session();
    }

    $userId = (int)($_SESSION['user_id'] ?? 0);

    if ($userId <= 0) {
        return ['roles' => [], 'permissions' => []];
    }

    if (!$forceRefresh && isset($requestCache[$userId])) {
        return $requestCache[$userId];
    }

    $ttl = max(0, (int)config('security.authorization_cache_ttl', 0));
    $loadedAt = (int)($_SESSION['authorization_loaded_at'] ?? 0);

    if (
        !$forceRefresh
        && $ttl > 0
        && $loadedAt > 0
        && (time() - $loadedAt) <= $ttl
        && isset($_SESSION['roles'], $_SESSION['permissions'])
    ) {
        $requestCache[$userId] = [
            'roles'       => is_array($_SESSION['roles']) ? $_SESSION['roles'] : [],
            'permissions' => is_array($_SESSION['permissions']) ? $_SESSION['permissions'] : [],
        ];
        return $requestCache[$userId];
    }

    $authorization = [
        'roles'       => get_user_roles($userId),
        'permissions' => get_user_permissions($userId),
    ];

    $_SESSION['roles'] = $authorization['roles'];
    $_SESSION['permissions'] = $authorization['permissions'];
    $_SESSION['authorization_loaded_at'] = time();

    $requestCache[$userId] = $authorization;

    return $authorization;
}

/**
 * Fuerza una actualización inmediata de roles/permisos.
 */
function refresh_current_authorization(): array
{
    return current_authorization(true);
}

/**
 * Obtiene los permisos detailed del usuario autenticado.
 * @return array<array<string, mixed>>
 */
function current_user_permissions(): array
{
    if (session_status() === PHP_SESSION_NONE) {
        start_secure_session();
    }

    $userId = (int)($_SESSION['user_id'] ?? 0);
    if ($userId <= 0) {
        return [];
    }

    return get_user_permissions_detailed($userId);
}

function has_role(string|array $roles): bool
{
    $authorization = current_authorization();
    $checkRoles = (array)$roles;

    return !empty(array_intersect($checkRoles, $authorization['roles']));
}

function has_permission(string|array $permissions): bool
{
    $authorization = current_authorization();
    $checkPermissions = (array)$permissions;

    return !empty(array_intersect($checkPermissions, $authorization['permissions']));
}

function require_role(string|array $roles): void
{
    if (!has_role($roles)) {
        http_response_code(403);
        exit('Acceso denegado: Rol insuficiente.');
    }
}

function require_permission(string|array $permissions): void
{
    if (!has_permission($permissions)) {
        http_response_code(403);
        exit('Acceso denegado: Permiso insuficiente.');
    }
}
