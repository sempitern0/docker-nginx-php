<?php

declare(strict_types=1);


function csrf_field(): string
{
    if (session_status() === PHP_SESSION_NONE) {
        start_secure_session();
    }

    if (empty($_SESSION['csrf'])) {
        $_SESSION['csrf'] = bin2hex(random_bytes(32));
    }

    return '<input type="hidden" name="csrf" value="' . e($_SESSION['csrf']) . '">';
}


function csrf_check(): void
{
    if (session_status() === PHP_SESSION_NONE) {
        start_secure_session();
    }

    $postToken    = (string)($_POST['csrf'] ?? '');
    $sessionToken = (string)($_SESSION['csrf'] ?? '');

    if ($postToken === '' || $sessionToken === '' || !hash_equals($sessionToken, $postToken)) {
        http_response_code(403);
        exit('Solicitud no válida.');
    }
}
