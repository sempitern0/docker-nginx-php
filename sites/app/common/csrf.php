<?php

declare(strict_types=1);

final class Csrf
{
    private function __construct()
    {
    }

    public static function field(): string
    {
        if (session_status() === PHP_SESSION_NONE) {
            Session::start();
        }

        if (empty($_SESSION['csrf'])) {
            $_SESSION['csrf'] = bin2hex(random_bytes(32));
        }

        return '<input type="hidden" name="csrf" value="'
            . Security::escape($_SESSION['csrf'])
            . '">';
    }

    public static function check(): void
    {
        if (session_status() === PHP_SESSION_NONE) {
            Session::start();
        }

        $postToken = (string)($_POST['csrf'] ?? '');
        $sessionToken = (string)($_SESSION['csrf'] ?? '');

        if (
            $postToken === ''
            || $sessionToken === ''
            || !hash_equals($sessionToken, $postToken)
        ) {
            http_response_code(403);
            exit('Solicitud no válida.');
        }
    }
}
