<?php

declare(strict_types=1);

require_once dirname(__DIR__) . '/config/bootstrap.php';

Session::start();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    header('Allow: POST');
    exit('Método no permitido');
}

Csrf::check();

$userId = (int)($_SESSION['user_id'] ?? 0);
$username = (string)($_SESSION['username'] ?? '');

$mfaPendingUserId = (int)($_SESSION['mfa_pending_user_id'] ?? 0);

if ($userId > 0 && Auth::isLoggedIn()) {
    Security::audit(
        $userId,
        $username,
        'auth.logout',
        'Cierre de sesión',
        true
    );
} elseif ($mfaPendingUserId > 0) {
    Security::audit(
        $mfaPendingUserId,
        null,
        'auth.mfa.cancelled',
        'Cancelación del flujo de autenticación MFA',
        true
    );
}

Session::destroy();

header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
header('Pragma: no-cache');
header('Expires: 0');
Helpers::redirect('/', 303);
