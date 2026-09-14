<?php

declare(strict_types=1);

function establish_authenticated_session(
    int $userId,
    string $username,
    array $roles,
    array $permissions
): void {
    regenerate_authenticated_session();

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

function complete_mfa_login(int $userId): bool
{
    if ($userId <= 0) {
        return false;
    }

    if (session_status() === PHP_SESSION_NONE) {
        start_secure_session();
    }

    $stmt = db()->prepare('
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
    ');

    $stmt->execute([$userId]);
    $u = $stmt->fetch();

    if (!$u || (int)$u['is_active'] !== 1 || !empty($u['deleted_at']) || (int)$u['mfa_enabled'] !== 1) {
        unset($_SESSION['mfa_pending_user_id']);
        return false;
    }

    $roles = get_user_roles($userId);
    $permissions = get_user_permissions($userId);

    establish_authenticated_session($userId, $u['username'], $roles, $permissions);

    rate_limit_clear('login:user', (string)$userId);

    $clearLock = db()->prepare(
        'UPDATE users
         SET failed_login_attempts = 0, locked_until = NULL, last_login_at = NOW()
         WHERE id = ?'
    );

    $clearLock->execute([$userId]);

    audit($userId, $u['username'], 'auth.login.success', 'Inicio de sesión exitoso tras MFA', true);
    return true;
}

function login_user(string $username, string $password): string|bool
{
    $username = trim($username);

    if (empty($username)) {
        return 'Credenciales incorrectas.';
    }

    $stmt = db()->prepare(
        'SELECT 
            id,
            username,
            email,
            password_hash,
            is_active,
            email_verified_at,
            failed_login_attempts,
            locked_until,
            mfa_enabled,
            mfa_secret,
            last_login_at,
            created_at
         FROM users
         WHERE username = ? AND deleted_at IS NULL
         LIMIT 1'
    );

    $stmt->execute([$username]);
    $u = $stmt->fetch();

    if (!$u) {
        audit(null, $username, 'auth.login.failed', 'Usuario no encontrado', false);
        return 'Credenciales incorrectas.';
    }

    $userRateLimit = rate_limit_check(
        'login:user',
        (string)$u['id'],
        max(1, (int)config('security.login_user_max_attempts', 5)),
        max(1, (int)config('security.login_user_window_seconds', 900))
    );

    if (!$userRateLimit['allowed']) {
        audit(
            (int)$u['id'],
            $u['username'],
            'auth.login.rate_limited',
            'Límite de intentos de autenticación por usuario alcanzado',
            false
        );

        return 'Credenciales incorrectas.';
    }


    if (!(int)$u['is_active']) {
        audit((int)$u['id'], $u['username'], 'auth.login.failed', 'Cuenta desactivada', false);
        return 'Cuenta desactivada.';
    }

    if (!empty($u['locked_until']) && strtotime((string)$u['locked_until']) > time()) {
        audit((int)$u['id'], $u['username'], 'auth.login.failed', 'Bloqueo temporal activo', false);
        return 'Cuenta bloqueada temporalmente. Inténtalo más tarde.';
    }

    if (!password_verify($password, (string)$u['password_hash'])) {
        rate_limit_consume(
            'login:user',
            (string)$u['id'],
            max(1, (int)config('security.login_user_max_attempts', 5)),
            max(1, (int)config('security.login_user_window_seconds', 900))
        );

        $maxAttempts = max(1, (int)config('security.max_login_attempts', 5));
        $lockoutMins = max(1, (int)config('security.lockout_minutes', 15));

        $pdo = db();
        $pdo->beginTransaction();

        try {
            $lockStmt = $pdo->prepare(
                'SELECT failed_login_attempts
                 FROM users
                 WHERE id = ?
                 FOR UPDATE'
            );

            $lockStmt->execute([(int)$u['id']]);
            $current = $lockStmt->fetch();

            $attempts = ((int)($current['failed_login_attempts'] ?? 0)) + 1;
            $locked = $attempts >= $maxAttempts;

            if ($locked) {
                $lockedUntil = (new DateTimeImmutable())
                    ->modify("+{$lockoutMins} minutes")
                    ->format('Y-m-d H:i:s');

                $update = $pdo->prepare(
                    'UPDATE users
                        SET failed_login_attempts = ?,
                            locked_until = ?
                        WHERE id = ?'
                );

                $update->execute([
                    $attempts,
                    $lockedUntil,
                    (int)$u['id'],
                ]);
            } else {
                $update = $pdo->prepare(
                    'UPDATE users
                     SET failed_login_attempts = ?, locked_until = NULL
                     WHERE id = ?'
                );
                $update->execute([$attempts, (int)$u['id']]);
            }

            $pdo->commit();
        } catch (Throwable $e) {
            if ($pdo->inTransaction()) {
                $pdo->rollBack();
            }

            throw $e;
        }

        audit((int)$u['id'], $u['username'], 'auth.login.failed', 'Contraseña incorrecta', false);

        return 'Credenciales incorrectas.';
    }

    if (password_needs_rehash((string)$u['password_hash'], PASSWORD_DEFAULT)) {
        $update = db()->prepare('UPDATE users SET password_hash = ? WHERE id = ?');
        $update->execute([
            password_hash($password, PASSWORD_DEFAULT),
            (int)$u['id'],
        ]);
    }

    if ((int)$u['mfa_enabled'] === 1) {
        if (session_status() === PHP_SESSION_NONE) {
            start_secure_session();
        }

        regenerate_authenticated_session();

        unset(
            $_SESSION['user_id'],
            $_SESSION['username'],
            $_SESSION['roles'],
            $_SESSION['permissions'],
            $_SESSION['authorization_loaded_at'],
            $_SESSION['last_activity']
        );

        $_SESSION['mfa_pending_user_id'] = (int)$u['id'];
        $_SESSION['mfa_pending_at'] = time();

        if (empty($u['mfa_secret'])) {
            audit(
                (int)$u['id'],
                $u['username'],
                'auth.mfa_setup_required',
                'Configuración de MFA requerida',
                true
            );

            return 'mfa_setup_required';
        }

        audit(
            (int)$u['id'],
            $u['username'],
            'auth.mfa_required',
            'Paso de verificación MFA requerido',
            true
        );



        return 'mfa_verify_required';
    }

    rate_limit_clear('login:user', (string)$u['id']);
    $roles = get_user_roles((int)$u['id']);
    $permissions = get_user_permissions((int)$u['id']);

    establish_authenticated_session((int)$u['id'], $u['username'], $roles, $permissions);

    $clearLock = db()->prepare(
        'UPDATE users
         SET failed_login_attempts = 0, locked_until = NULL, last_login_at = NOW()
         WHERE id = ?'
    );
    $clearLock->execute([(int)$u['id']]);

    audit((int)$u['id'], $u['username'], 'auth.login.success', 'Inicio de sesión exitoso', true);

    return true;
}

function require_login(): void
{
    if (session_status() === PHP_SESSION_NONE) {
        start_secure_session();
    }

    if (empty($_SESSION['user_id'])) {
        if (!empty($_SESSION['mfa_pending_user_id'])) {
            $pendingTtl = max(1, (int)config('security.mfa_pending_timeout', 300));
            $pendingAt = (int)($_SESSION['mfa_pending_at'] ?? 0);

            if ($pendingAt > 0 && (time() - $pendingAt) > $pendingTtl) {
                unset($_SESSION['mfa_pending_user_id'], $_SESSION['mfa_pending_at']);
                redirect('index.php');
            }

            redirect('mfa_verify.php');
        }

        redirect('index.php');
    }

    $timeout = max(1, (int)config('security.session_timeout', 1800));

    if (isset($_SESSION['last_activity']) && (time() - (int)$_SESSION['last_activity']) > $timeout) {
        $userId   = (int)($_SESSION['user_id'] ?? 0);
        $username = (string)($_SESSION['username'] ?? '');

        audit($userId, $username, 'auth.session_expired', 'Cierre de sesión por inactividad', true);
        destroy_session();

        redirect('index.php');
    }

    $_SESSION['last_activity'] = time();
}

function current_user(): array
{
    if (session_status() === PHP_SESSION_NONE) {
        start_secure_session();
    }

    if (empty($_SESSION['user_id'])) {
        return [];
    }

    $stmt = db()->prepare(
        'SELECT
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
        LIMIT 1'
    );
    $stmt->execute([(int)$_SESSION['user_id']]);
    $user = $stmt->fetch();

    if (!$user) {
        return [];
    }

    $authorization = current_authorization();
    $user['roles'] = $authorization['roles'];
    $user['permissions'] = $authorization['permissions'];

    return $user;
}

function is_logged_in(): bool
{
    if (session_status() === PHP_SESSION_NONE) {
        start_secure_session();
    }

    return !empty($_SESSION['user_id']) && empty($_SESSION['mfa_pending_user_id']);
}
