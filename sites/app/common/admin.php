<?php

declare(strict_types=1);

/**
 * Devuelve la fecha local de la aplicación usada para rotar el código diario.
 */
function admin_gate_date(): string
{
    $timezone = new DateTimeZone((string)config('app.timezone', 'UTC'));
    return (new DateTimeImmutable('now', $timezone))->format('Y-m-d');
}

/**
 * Código determinista diario derivado de un secreto fuera del repositorio.
 * 128 bits truncados de HMAC-SHA-256.
 */
function admin_daily_code(?DateTimeImmutable $now = null): string
{
    $secret = (string)config('security.admin_gate_secret', '');

    if (strlen($secret) < 32) {
        throw new RuntimeException('security.admin_gate_secret debe contener al menos 32 bytes.');
    }

    $timezone = new DateTimeZone((string)config('app.timezone', 'UTC'));
    $now ??= new DateTimeImmutable('now', $timezone);
    $date = $now->setTimezone($timezone)->format('Y-m-d');

    return substr(hash_hmac(
        'sha256',
        "admin-gate|$date",
        $secret
    ), 0, 32);
}


function verify_admin_gate_code(string $providedCode): bool
{
    $providedCode = trim($providedCode);
    $expectedCode = admin_daily_code();

    if (strlen($providedCode) !== strlen($expectedCode)) {
        return false;
    }

    if (!hash_equals($expectedCode, $providedCode)) {
        return false;
    }

    $_SESSION['admin_gate_date'] = admin_gate_date();
    $_SESSION['admin_gate_verified_at'] = time();

    return true;
}


function require_admin_gate(): void
{
    if (session_status() === PHP_SESSION_NONE) {
        start_secure_session();
    }

    $today = admin_gate_date();
    $providedCode = (string)($_POST['code'] ?? '');

    if ($providedCode !== '' && verify_admin_gate_code($providedCode)) {
        return;
    }

    if (
        $_SESSION['admin_gate_date'] === $today
        && time() - (int)$_SESSION['admin_gate_verified_at']
        <= config('security.admin_gate_timeout', 3600)
    ) {
        return;
    }

    http_response_code(404);
    exit('Not Found');
}

function has_admin_panel_access(): bool
{
    if (has_role(['admin', 'profesor'])) {
        return true;
    }

    return has_permission([
        'orders:read_all',
        'products:read',
    ]);
}

/**
 * Guard común para todas las páginas administrativas distintas del index.
 */
function require_admin_route(): void
{
    require_login();
    require_admin_gate();

    if (!has_admin_panel_access()) {
        redirect('/');
    }
}
