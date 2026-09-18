<?php

declare(strict_types=1);

final class Session
{
    private function __construct()
    {
    }

    public static function start(): void
    {
        if (session_status() !== PHP_SESSION_NONE) {
            return;
        }

        $sessionName = trim((string)Helpers::config('security.session_name', 'SEC_SESSID'));

        if ($sessionName === '') {
            $sessionName = 'SEC_SESSID';
        }

        session_name($sessionName);

        ini_set('session.use_strict_mode', '1');
        ini_set('session.use_only_cookies', '1');
        ini_set('session.use_trans_sid', '0');

        $configuredSecure = Helpers::config('security.secure_cookies', null);

        if ($configuredSecure === null) {
            $https = $_SERVER['HTTPS'] ?? '';
            $isSecure = (
                $https !== ''
                && strtolower((string)$https) !== 'off'
                && $https !== '0'
            );
        } else {
            $isSecure = (bool)$configuredSecure;
        }

        $sameSite = (string)Helpers::config('security.session_samesite', 'Lax');

        if (!in_array($sameSite, ['Lax', 'Strict', 'None'], true)) {
            $sameSite = 'Lax';
        }

        session_set_cookie_params([
            'lifetime' => 0,
            'path' => '/',
            'domain' => '',
            'secure' => $isSecure,
            'httponly' => true,
            'samesite' => $sameSite,
        ]);

        session_start();
    }

    public static function regenerateAuthenticated(): void
    {
        if (session_status() === PHP_SESSION_NONE) {
            self::start();
        }

        session_regenerate_id(true);
        $_SESSION['csrf'] = bin2hex(random_bytes(32));
    }

    public static function destroy(): void
    {
        if (session_status() === PHP_SESSION_NONE) {
            return;
        }

        $_SESSION = [];

        if (ini_get('session.use_cookies')) {
            $params = session_get_cookie_params();

            setcookie(session_name(), '', [
                'expires' => time() - 42000,
                'path' => $params['path'] ?: '/',
                'domain' => $params['domain'] ?: '',
                'secure' => (bool)$params['secure'],
                'httponly' => (bool)$params['httponly'],
                'samesite' => $params['samesite'] ?? 'Lax',
            ]);
        }

        session_destroy();
    }
}
