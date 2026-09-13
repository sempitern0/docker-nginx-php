<?php

declare(strict_types=1);

function start_secure_session(): void
{
    if (session_status() !== PHP_SESSION_NONE) {
        return;
    }

    $sessionName = trim((string)config('security.session_name', 'SEC_SESSID'));
    if ($sessionName === '') {
        $sessionName = 'SEC_SESSID';
    }

    session_name($sessionName);

    ini_set('session.use_strict_mode', '1');
    ini_set('session.use_only_cookies', '1');
    ini_set('session.use_trans_sid', '0');

    $configuredSecure = config('security.secure_cookies', null);

    if ($configuredSecure === null) {
        $https = $_SERVER['HTTPS'] ?? '';
        $isSecure = ($https !== '' && strtolower((string)$https) !== 'off' && $https !== '0');
    } else {
        $isSecure = (bool)$configuredSecure;
    }

    session_set_cookie_params([
        'lifetime' => 0,
        'path'     => '/',
        'domain'   => '',
        'secure'   => $isSecure,
        'httponly' => true,
        'samesite' => (string)config('security.session_samesite', 'Lax'),
    ]);

    session_start();
}


function regenerate_authenticated_session(): void
{
    if (session_status() === PHP_SESSION_NONE) {
        start_secure_session();
    }

    session_regenerate_id(true);
    $_SESSION['csrf'] = bin2hex(random_bytes(32));
}

/**
 * Limpia completamente la sesión y su cookie.
 */
function destroy_session(): void
{
    if (session_status() === PHP_SESSION_NONE) {
        return;
    }

    $_SESSION = [];

    if (ini_get('session.use_cookies')) {
        $params = session_get_cookie_params();
        setcookie(session_name(), '', [
            'expires'  => time() - 42000,
            'path'     => $params['path'] ?: '/',
            'domain'   => $params['domain'] ?: '',
            'secure'   => (bool)$params['secure'],
            'httponly' => (bool)$params['httponly'],
            'samesite' => $params['samesite'] ?? 'Lax',
        ]);
    }

    session_destroy();
}
