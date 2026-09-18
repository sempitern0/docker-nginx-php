<?php

declare(strict_types=1);

final class Rbac
{
    private static array $requestCache = [];

    private function __construct()
    {
    }

    /**
     * @return array<string>
     */
    public static function getUserRoles(int $userId): array
    {
        $stmt = Database::connection()->prepare(<<<'SQL'
            SELECT r.name
            FROM roles r
            JOIN user_roles ur ON r.id = ur.role_id
            WHERE ur.user_id = ?
        SQL);

        $stmt->execute([$userId]);

        return $stmt->fetchAll(PDO::FETCH_COLUMN) ?: [];
    }

    /**
     * @return array<string>
     */
    public static function getUserPermissions(int $userId): array
    {
        $stmt = Database::connection()->prepare(<<<'SQL'
            SELECT DISTINCT p.slug
            FROM permissions p
            JOIN role_permissions rp ON p.id = rp.permission_id
            JOIN user_roles ur ON rp.role_id = ur.role_id
            WHERE ur.user_id = ?
        SQL);

        $stmt->execute([$userId]);

        return $stmt->fetchAll(PDO::FETCH_COLUMN) ?: [];
    }

    /**
     * @return array<array<string, mixed>>
     */
    public static function getUserPermissionsDetailed(int $userId): array
    {
        $stmt = Database::connection()->prepare(<<<'SQL'
            SELECT DISTINCT p.id, p.slug, p.description
            FROM permissions p
            JOIN role_permissions rp ON p.id = rp.permission_id
            JOIN user_roles ur ON rp.role_id = ur.role_id
            WHERE ur.user_id = ?
            ORDER BY p.slug ASC
        SQL);

        $stmt->execute([$userId]);

        return $stmt->fetchAll() ?: [];
    }

    public static function getUserProfile(int $userId): ?array
    {
        if ($userId <= 0) {
            return null;
        }

        $stmt = Database::connection()->prepare(
            'SELECT * FROM user_profiles WHERE user_id = ? LIMIT 1'
        );
        $stmt->execute([$userId]);

        return $stmt->fetch() ?: null;
    }

    /**
     * @return array{roles: array<string>, permissions: array<string>}
     */
    public static function currentAuthorization(bool $forceRefresh = false): array
    {
        if (session_status() === PHP_SESSION_NONE) {
            Session::start();
        }

        $userId = (int)($_SESSION['user_id'] ?? 0);

        if ($userId <= 0) {
            return [
                'roles' => [],
                'permissions' => [],
            ];
        }

        if (!$forceRefresh && isset(self::$requestCache[$userId])) {
            return self::$requestCache[$userId];
        }

        $ttl = max(
            0,
            (int)Helpers::config('security.authorization_cache_ttl', 0)
        );
        $loadedAt = (int)($_SESSION['authorization_loaded_at'] ?? 0);

        if (
            !$forceRefresh
            && $ttl > 0
            && $loadedAt > 0
            && (time() - $loadedAt) <= $ttl
            && isset($_SESSION['roles'], $_SESSION['permissions'])
        ) {
            self::$requestCache[$userId] = [
                'roles' => is_array($_SESSION['roles'])
                    ? $_SESSION['roles']
                    : [],
                'permissions' => is_array($_SESSION['permissions'])
                    ? $_SESSION['permissions']
                    : [],
            ];

            return self::$requestCache[$userId];
        }

        $authorization = [
            'roles' => self::getUserRoles($userId),
            'permissions' => self::getUserPermissions($userId),
        ];

        $_SESSION['roles'] = $authorization['roles'];
        $_SESSION['permissions'] = $authorization['permissions'];
        $_SESSION['authorization_loaded_at'] = time();

        self::$requestCache[$userId] = $authorization;

        return $authorization;
    }

    /**
     * @return array{roles: array<string>, permissions: array<string>}
     */
    public static function refreshCurrentAuthorization(): array
    {
        return self::currentAuthorization(true);
    }

    /**
     * @return array<array<string, mixed>>
     */
    public static function currentUserPermissions(): array
    {
        if (session_status() === PHP_SESSION_NONE) {
            Session::start();
        }

        $userId = (int)($_SESSION['user_id'] ?? 0);

        if ($userId <= 0) {
            return [];
        }

        return self::getUserPermissionsDetailed($userId);
    }

    public static function hasRole(string|array $roles): bool
    {
        $authorization = self::currentAuthorization();
        $checkRoles = array_filter(
            array_map('strval', (array)$roles),
            static fn(string $role): bool => $role !== ''
        );

        return !empty(array_intersect($checkRoles, $authorization['roles']));
    }

    public static function hasPermission(string|array $permissions): bool
    {
        $authorization = self::currentAuthorization();
        $checkPermissions = (array)$permissions;

        return !empty(
            array_intersect($checkPermissions, $authorization['permissions'])
        );
    }

    public static function requireRole(string|array $roles): void
    {
        if (!self::hasRole($roles)) {
            http_response_code(403);
            exit('Acceso denegado: Rol insuficiente.');
        }
    }

    public static function requirePermission(string|array $permissions): void
    {
        if (!self::hasPermission($permissions)) {
            http_response_code(403);
            exit('Acceso denegado: Permiso insuficiente.');
        }
    }
}
