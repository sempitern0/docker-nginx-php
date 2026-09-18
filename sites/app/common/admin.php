<?php

declare(strict_types=1);

final class Admin
{
    private function __construct() {}

    public static function gateDate(): string
    {
        $timezone = new DateTimeZone(
            (string)Helpers::config('app.timezone', 'UTC')
        );

        return (new DateTimeImmutable('now', $timezone))->format('Y-m-d');
    }

    public static function dailyCode(?DateTimeImmutable $now = null): string
    {
        $secret = (string)Helpers::config('security.admin_gate_secret', '');

        if (strlen($secret) < 32) {
            throw new RuntimeException(
                'security.admin_gate_secret debe contener al menos 32 bytes.'
            );
        }

        $timezone = new DateTimeZone(
            (string)Helpers::config('app.timezone', 'UTC')
        );
        $now ??= new DateTimeImmutable('now', $timezone);
        $date = $now->setTimezone($timezone)->format('Y-m-d');

        return substr(
            hash_hmac(
                'sha256',
                "admin-gate|$date",
                $secret
            ),
            0,
            32
        );
    }

    public static function verifyGateCode(string $providedCode): bool
    {
        $providedCode = trim($providedCode);
        $expectedCode = self::dailyCode();

        if (strlen($providedCode) !== strlen($expectedCode)) {
            return false;
        }

        if (!hash_equals($expectedCode, $providedCode)) {
            return false;
        }

        if (session_status() === PHP_SESSION_NONE) {
            Session::start();
        }

        $_SESSION['admin_gate_date'] = self::gateDate();
        $_SESSION['admin_gate_verified_at'] = time();

        return true;
    }

    public static function requireGate(): void
    {
        if (session_status() === PHP_SESSION_NONE) {
            Session::start();
        }

        $today = self::gateDate();
        $providedCode = (string)($_POST['code'] ?? '');

        if ($providedCode !== '' && self::verifyGateCode($providedCode)) {
            return;
        }

        $verifiedDate = (string)($_SESSION['admin_gate_date'] ?? '');
        $verifiedAt = (int)($_SESSION['admin_gate_verified_at'] ?? 0);
        $timeout = max(
            1,
            (int)Helpers::config('security.admin_gate_timeout', 3600)
        );

        if (
            $verifiedDate === $today
            && $verifiedAt > 0
            && time() - $verifiedAt <= $timeout
        ) {
            return;
        }

        http_response_code(404);
        exit('Not Found');
    }

    public static function hasPanelAccess(): bool
    {
        return Rbac::hasRole(['admin']);
    }

    public static function requireRoute(): void
    {
        Auth::requireLogin();
        self::requireGate();

        if (!self::hasPanelAccess()) {
            Helpers::redirect('/');
        }
    }
}
