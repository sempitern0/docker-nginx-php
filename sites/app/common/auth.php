<?php

declare(strict_types=1);

final class Auth
{
    private function __construct()
    {
    }

    public static function establishAuthenticatedSession(
        int $userId,
        string $username,
        array $roles,
        array $permissions
    ): void {
        Session::regenerateAuthenticated();

        unset(
            $_SESSION['mfa_pending_user_id'],
            $_SESSION['mfa_pending_at']
        );

        $_SESSION['user_id'] = $userId;
        $_SESSION['username'] = $username;
        $_SESSION['roles'] = $roles;
        $_SESSION['permissions'] = $permissions;
        $_SESSION['authorization_loaded_at'] = time();
        $_SESSION['last_activity'] = time();
    }

    public static function completeMfaLogin(int $userId): bool
    {
        if ($userId <= 0) {
            return false;
        }

        if (session_status() === PHP_SESSION_NONE) {
            Session::start();
        }

        $stmt = Database::connection()->prepare(<<<'SQL'
            SELECT
                u.id,
                u.username,
                u.is_active,
                u.deleted_at,
                COALESCE(m.is_enabled, 0) AS mfa_enabled
            FROM users AS u
            LEFT JOIN user_mfa AS m
                ON m.user_id = u.id
            WHERE u.id = ?
            LIMIT 1
        SQL);

        $stmt->execute([$userId]);
        $user = $stmt->fetch();

        if (
            !$user
            || (int)$user['is_active'] !== 1
            || !empty($user['deleted_at'])
            || (int)$user['mfa_enabled'] !== 1
        ) {
            unset($_SESSION['mfa_pending_user_id']);

            return false;
        }

        $roles = Rbac::getUserRoles($userId);
        $permissions = Rbac::getUserPermissions($userId);

        self::establishAuthenticatedSession(
            $userId,
            (string)$user['username'],
            $roles,
            $permissions
        );

        RateLimiter::clear('login:user', (string)$userId);

        $clearLock = Database::connection()->prepare(<<<'SQL'
            UPDATE users
            SET failed_login_attempts = 0,
                locked_until = NULL,
                last_login_at = CURRENT_TIMESTAMP
            WHERE id = ?
        SQL);

        $clearLock->execute([$userId]);

        Security::audit(
            $userId,
            (string)$user['username'],
            'auth.login.success',
            'Inicio de sesión exitoso tras MFA',
            true
        );

        return true;
    }

    public static function loginUser(string $username, string $password): string|bool
    {
        $username = trim($username);

        if ($username === '') {
            return 'Credenciales incorrectas.';
        }

        $stmt = Database::connection()->prepare(<<<'SQL'
            SELECT
                u.id,
                u.username,
                u.email,
                u.password_hash,
                u.is_active,
                u.email_verified_at,
                u.failed_login_attempts,
                u.locked_until,
                COALESCE(m.is_enabled, 0) AS mfa_enabled,
                m.secret_encrypted AS mfa_secret_encrypted,
                u.last_login_at,
                u.created_at
            FROM users AS u
            LEFT JOIN user_mfa AS m
                ON m.user_id = u.id
            WHERE u.username = ?
              AND u.deleted_at IS NULL
            LIMIT 1
        SQL);

        $stmt->execute([$username]);
        $user = $stmt->fetch();

        if (!$user) {
            Security::audit(
                null,
                $username,
                'auth.login.failed',
                'Usuario no encontrado',
                false
            );

            return 'Credenciales incorrectas.';
        }

        $userRateLimit = RateLimiter::check(
            'login:user',
            (string)$user['id'],
            max(1, (int)Helpers::config('security.login_user_max_attempts', 5)),
            max(1, (int)Helpers::config('security.login_user_window_seconds', 900))
        );

        if (!$userRateLimit['allowed']) {
            Security::audit(
                (int)$user['id'],
                (string)$user['username'],
                'auth.login.rate_limited',
                'Límite de intentos de autenticación por usuario alcanzado',
                false
            );

            return 'Credenciales incorrectas.';
        }

        if (!(int)$user['is_active']) {
            Security::audit(
                (int)$user['id'],
                (string)$user['username'],
                'auth.login.failed',
                'Cuenta desactivada',
                false
            );

            return 'Cuenta desactivada.';
        }

        if (
            !empty($user['locked_until'])
            && strtotime((string)$user['locked_until']) > time()
        ) {
            Security::audit(
                (int)$user['id'],
                (string)$user['username'],
                'auth.login.failed',
                'Bloqueo temporal activo',
                false
            );

            return 'Cuenta bloqueada temporalmente. Inténtalo más tarde.';
        }

        if (!password_verify($password, (string)$user['password_hash'])) {
            RateLimiter::consume(
                'login:user',
                (string)$user['id'],
                max(1, (int)Helpers::config('security.login_user_max_attempts', 5)),
                max(1, (int)Helpers::config('security.login_user_window_seconds', 900))
            );

            $maxAttempts = max(
                1,
                (int)Helpers::config('security.max_login_attempts', 5)
            );
            $lockoutMins = max(
                1,
                (int)Helpers::config('security.lockout_minutes', 15)
            );

            $pdo = Database::connection();
            $pdo->beginTransaction();

            try {
                $lockStmt = $pdo->prepare(<<<'SQL'
                    SELECT failed_login_attempts
                    FROM users
                    WHERE id = ?
                    FOR UPDATE
                SQL);

                $lockStmt->execute([(int)$user['id']]);
                $current = $lockStmt->fetch();

                $attempts = ((int)($current['failed_login_attempts'] ?? 0)) + 1;
                $locked = $attempts >= $maxAttempts;

                if ($locked) {
                    $lockedUntil = (new DateTimeImmutable())
                        ->modify("+{$lockoutMins} minutes")
                        ->format('Y-m-d H:i:s');

                    $update = $pdo->prepare(<<<'SQL'
                        UPDATE users
                        SET failed_login_attempts = ?,
                            locked_until = ?
                        WHERE id = ?
                    SQL);

                    $update->execute([
                        $attempts,
                        $lockedUntil,
                        (int)$user['id'],
                    ]);
                } else {
                    $update = $pdo->prepare(<<<'SQL'
                        UPDATE users
                        SET failed_login_attempts = ?,
                            locked_until = NULL
                        WHERE id = ?
                    SQL);

                    $update->execute([
                        $attempts,
                        (int)$user['id'],
                    ]);
                }

                $pdo->commit();
            } catch (Throwable $e) {
                if ($pdo->inTransaction()) {
                    $pdo->rollBack();
                }

                throw $e;
            }

            Security::audit(
                (int)$user['id'],
                (string)$user['username'],
                'auth.login.failed',
                'Contraseña incorrecta',
                false
            );

            return 'Credenciales incorrectas.';
        }

        if (password_needs_rehash((string)$user['password_hash'], PASSWORD_DEFAULT)) {
            $update = Database::connection()->prepare(
                'UPDATE users SET password_hash = ? WHERE id = ?'
            );
            $update->execute([
                password_hash($password, PASSWORD_DEFAULT),
                (int)$user['id'],
            ]);
        }

        if ((int)$user['mfa_enabled'] === 1) {
            if (session_status() === PHP_SESSION_NONE) {
                Session::start();
            }

            Session::regenerateAuthenticated();

            unset(
                $_SESSION['user_id'],
                $_SESSION['username'],
                $_SESSION['roles'],
                $_SESSION['permissions'],
                $_SESSION['authorization_loaded_at'],
                $_SESSION['last_activity']
            );

            $_SESSION['mfa_pending_user_id'] = (int)$user['id'];
            $_SESSION['mfa_pending_at'] = time();

            if (empty($user['mfa_secret_encrypted'])) {
                Security::audit(
                    (int)$user['id'],
                    (string)$user['username'],
                    'auth.mfa_setup_required',
                    'Configuración de MFA requerida',
                    true
                );

                return 'mfa_setup_required';
            }

            Security::audit(
                (int)$user['id'],
                (string)$user['username'],
                'auth.mfa_required',
                'Paso de verificación MFA requerido',
                true
            );

            return 'mfa_verify_required';
        }

        RateLimiter::clear('login:user', (string)$user['id']);

        $roles = Rbac::getUserRoles((int)$user['id']);
        $permissions = Rbac::getUserPermissions((int)$user['id']);

        self::establishAuthenticatedSession(
            (int)$user['id'],
            (string)$user['username'],
            $roles,
            $permissions
        );

        $clearLock = Database::connection()->prepare(<<<'SQL'
            UPDATE users
            SET failed_login_attempts = 0,
                locked_until = NULL,
                last_login_at = CURRENT_TIMESTAMP
            WHERE id = ?
        SQL);

        $clearLock->execute([(int)$user['id']]);

        Security::audit(
            (int)$user['id'],
            (string)$user['username'],
            'auth.login.success',
            'Inicio de sesión exitoso',
            true
        );

        return true;
    }

    public static function requireLogin(): void
    {
        if (session_status() === PHP_SESSION_NONE) {
            Session::start();
        }

        if (empty($_SESSION['user_id'])) {
            if (!empty($_SESSION['mfa_pending_user_id'])) {
                $pendingTtl = max(
                    1,
                    (int)Helpers::config('security.mfa_pending_timeout', 300)
                );
                $pendingAt = (int)($_SESSION['mfa_pending_at'] ?? 0);

                if (
                    $pendingAt > 0
                    && (time() - $pendingAt) > $pendingTtl
                ) {
                    unset(
                        $_SESSION['mfa_pending_user_id'],
                        $_SESSION['mfa_pending_at']
                    );
                    Helpers::redirect('index.php');
                }

                Helpers::redirect('mfa_verify.php');
            }

            Helpers::redirect('index.php');
        }

        $timeout = max(
            1,
            (int)Helpers::config('security.session_timeout', 1800)
        );

        if (
            isset($_SESSION['last_activity'])
            && (time() - (int)$_SESSION['last_activity']) > $timeout
        ) {
            $userId = (int)($_SESSION['user_id'] ?? 0);
            $currentUsername = (string)($_SESSION['username'] ?? '');

            Security::audit(
                $userId,
                $currentUsername,
                'auth.session_expired',
                'Cierre de sesión por inactividad',
                true
            );

            Session::destroy();
            Helpers::redirect('index.php');
        }

        $_SESSION['last_activity'] = time();
    }

    public static function currentUser(): array
    {
        if (session_status() === PHP_SESSION_NONE) {
            Session::start();
        }

        if (empty($_SESSION['user_id'])) {
            return [];
        }

        $stmt = Database::connection()->prepare(<<<'SQL'
            SELECT
                u.id,
                u.username,
                u.email,
                u.is_active,
                CASE
                    WHEN u.email_verified_at IS NOT NULL THEN 1
                    ELSE 0
                END AS is_email_verified,
                COALESCE(m.is_enabled, 0) AS mfa_enabled,
                u.last_login_at,
                u.created_at
            FROM users AS u
            LEFT JOIN user_mfa AS m
                ON m.user_id = u.id
            WHERE u.id = ?
              AND u.deleted_at IS NULL
            LIMIT 1
        SQL);

        $stmt->execute([(int)$_SESSION['user_id']]);
        $user = $stmt->fetch();

        if (!$user) {
            return [];
        }

        $authorization = Rbac::currentAuthorization();
        $user['roles'] = $authorization['roles'];
        $user['permissions'] = $authorization['permissions'];

        return $user;
    }

    public static function isLoggedIn(): bool
    {
        if (session_status() === PHP_SESSION_NONE) {
            Session::start();
        }

        return !empty($_SESSION['user_id'])
            && empty($_SESSION['mfa_pending_user_id']);
    }
}
