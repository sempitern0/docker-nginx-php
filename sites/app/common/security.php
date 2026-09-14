<?php

declare(strict_types=1);

function e(?string $v): string
{
    return htmlspecialchars($v ?? '', ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

function url(string $path = ''): string
{
    $cleanPath = preg_replace('/[\x00-\x1F\x7F]/', '', $path);
    $cleanPath = ltrim(trim((string)$cleanPath), '/');
    $baseUrl = rtrim((string)config('app.base_url', ''), '/');

    return $cleanPath !== '' ? "{$baseUrl}/{$cleanPath}" : $baseUrl;
}

function is_ipv4_in_cidr(string $ip, string $cidr): bool
{
    [$subnet, $prefix] = array_pad(explode('/', $cidr, 2), 2, '32');

    $ipBin = @inet_pton($ip);
    $subnetBin = @inet_pton($subnet);

    if ($ipBin === false || $subnetBin === false || strlen($ipBin) !== 4 || strlen($subnetBin) !== 4) {
        return false;
    }

    $prefix = (int)$prefix;
    if ($prefix < 0 || $prefix > 32) {
        return false;
    }

    $fullBytes = intdiv($prefix, 8);
    $remainingBits = $prefix % 8;

    if ($fullBytes > 0 && substr($ipBin, 0, $fullBytes) !== substr($subnetBin, 0, $fullBytes)) {
        return false;
    }

    if ($remainingBits === 0) {
        return true;
    }

    $mask = (0xFF << (8 - $remainingBits)) & 0xFF;
    return (ord($ipBin[$fullBytes]) & $mask) === (ord($subnetBin[$fullBytes]) & $mask);
}

function is_ipv6_in_cidr(string $ip, string $cidr): bool
{
    [$subnet, $prefix] = array_pad(explode('/', $cidr, 2), 2, '128');

    $ipBin = @inet_pton($ip);
    $subnetBin = @inet_pton($subnet);

    if ($ipBin === false || $subnetBin === false || strlen($ipBin) !== 16 || strlen($subnetBin) !== 16) {
        return false;
    }

    $prefix = (int)$prefix;
    if ($prefix < 0 || $prefix > 128) {
        return false;
    }

    $fullBytes = intdiv($prefix, 8);
    $remainingBits = $prefix % 8;

    if ($fullBytes > 0 && substr($ipBin, 0, $fullBytes) !== substr($subnetBin, 0, $fullBytes)) {
        return false;
    }

    if ($remainingBits === 0) {
        return true;
    }

    $mask = (0xFF << (8 - $remainingBits)) & 0xFF;
    return (ord($ipBin[$fullBytes]) & $mask) === (ord($subnetBin[$fullBytes]) & $mask);
}

function ip_matches_network(string $ip, string $network): bool
{
    if (filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_IPV4) !== false) {
        return is_ipv4_in_cidr($ip, $network);
    }

    if (filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_IPV6) !== false) {
        return is_ipv6_in_cidr($ip, $network);
    }

    return false;
}


function is_trusted_proxy(?string $ip): bool
{
    if ($ip === null || $ip === '') {
        return false;
    }

    $trusted = config('security.trusted_proxies', []);

    if (!is_array($trusted)) {
        return false;
    }

    foreach ($trusted as $trustedNetwork) {
        $trustedNetwork = trim((string)$trustedNetwork);

        if ($trustedNetwork === '') {
            continue;
        }

        if (!str_contains($trustedNetwork, '/')) {

            if ($trustedNetwork === $ip) {
                return true;
            }

            continue;
        }

        if (ip_matches_network($ip, $trustedNetwork)) {
            return true;
        }
    }

    return false;
}

/*
 * Only honor forwarded client IP headers when REMOTE_ADDR
 * belongs to a configured trusted proxy.
 */
function client_ip(): ?string
{
    $remote = $_SERVER['REMOTE_ADDR'] ?? null;
    $remote = is_string($remote) && filter_var($remote, FILTER_VALIDATE_IP) !== false
        ? $remote
        : null;

    if ($remote !== null && is_trusted_proxy($remote)) {
        $realIp = $_SERVER['HTTP_X_REAL_IP'] ?? null;
        if (is_string($realIp) && filter_var($realIp, FILTER_VALIDATE_IP) !== false) {
            return $realIp;
        }

        $forwarded = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? null;
        if (is_string($forwarded)) {
            $candidates = array_map('trim', explode(',', $forwarded));

            foreach ($candidates as $candidate) {
                if (filter_var($candidate, FILTER_VALIDATE_IP) !== false) {
                    return $candidate;
                }
            }
        }
    }

    return $remote;
}
function audit(
    ?int $uid,
    ?string $username,
    string $eventType,
    ?string $description = null,
    bool $success = true,
    bool $mandatory = false
): void {
    try {
        $ip = system_setting_bool('audit.store_ip', true)
            ? client_ip()
            : null;

        $userAgent = system_setting_bool('audit.store_user_agent', true)
            && isset($_SERVER['HTTP_USER_AGENT'])
            ? substr((string)$_SERVER['HTTP_USER_AGENT'], 0, 255)
            : null;

        $eventType   = substr($eventType, 0, 50);
        $description = $description !== null ? substr($description, 0, 255) : null;

        $stmt = db()->prepare(
            'INSERT INTO audit_log
                (user_id, username, event_type, description, ip_address, user_agent, success)
             VALUES (?, ?, ?, ?, ?, ?, ?)'
        );

        $stmt->execute([
            $uid,
            $username,
            $eventType,
            $description,
            $ip !== null ? substr($ip, 0, 45) : null,
            $userAgent,
            $success ? 1 : 0,
        ]);
    } catch (Throwable $e) {
        error_log('Error al registrar auditoría: ' . $e->getMessage());

        if ($mandatory) {
            throw new RuntimeException('No se pudo registrar la auditoría.', 0, $e);
        }
    }
}


function audit_critical(
    ?int $uid,
    ?string $username,
    string $eventType,
    ?string $description = null,
    bool $success = true
): void {
    audit($uid, $username, $eventType, $description, $success, true);
}
