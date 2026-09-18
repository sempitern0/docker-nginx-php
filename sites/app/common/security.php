<?php

declare(strict_types=1);

final class Security
{
    private function __construct() {}

    public static function uuidV4(): string
    {
        $bytes = random_bytes(16);

        $bytes[6] = chr(
            (ord($bytes[6]) & 0x0F) | 0x40
        );

        $bytes[8] = chr(
            (ord($bytes[8]) & 0x3F) | 0x80
        );

        $hex = bin2hex($bytes);

        return sprintf(
            '%s-%s-%s-%s-%s',
            substr($hex, 0, 8),
            substr($hex, 8, 4),
            substr($hex, 12, 4),
            substr($hex, 16, 4),
            substr($hex, 20, 12)
        );
    }

    /**
     * Escape untrusted text for HTML output.
     */
    public static function escape(?string $value): string
    {
        return htmlspecialchars(
            $value ?? '',
            ENT_QUOTES | ENT_SUBSTITUTE,
            'UTF-8'
        );
    }

    public static function escapeUrl(?string $value): string
    {
        return self::escape(self::url($value));
    }

    /**
     * Build an application-relative URL using the configured base URL.
     */
    public static function url(string $path = ''): string
    {
        $cleanPath = preg_replace(
            '/[\x00-\x1F\x7F]/',
            '',
            $path
        );

        $cleanPath = ltrim(
            trim((string)$cleanPath),
            '/'
        );

        $baseUrl = rtrim(
            (string)Helpers::config('app.base_url', ''),
            '/'
        );

        return $cleanPath !== ''
            ? "{$baseUrl}/{$cleanPath}"
            : $baseUrl;
    }

    /**
     * Validate an IPv4 address against a CIDR network.
     */
    public static function isIpv4InCidr(
        string $ip,
        string $cidr
    ): bool {
        [$subnet, $prefix] = array_pad(
            explode('/', $cidr, 2),
            2,
            '32'
        );

        $ipBinary = @inet_pton($ip);
        $subnetBinary = @inet_pton($subnet);

        if (
            $ipBinary === false ||
            $subnetBinary === false ||
            strlen($ipBinary) !== 4 ||
            strlen($subnetBinary) !== 4
        ) {
            return false;
        }

        $prefix = (int)$prefix;

        if ($prefix < 0 || $prefix > 32) {
            return false;
        }

        $fullBytes = intdiv($prefix, 8);
        $remainingBits = $prefix % 8;

        if (
            $fullBytes > 0 &&
            substr(
                $ipBinary,
                0,
                $fullBytes
            ) !== substr(
                $subnetBinary,
                0,
                $fullBytes
            )
        ) {
            return false;
        }

        if ($remainingBits === 0) {
            return true;
        }

        $mask = (
            0xFF << (8 - $remainingBits)
        ) & 0xFF;

        return (
            ord($ipBinary[$fullBytes]) & $mask
        ) === (
            ord($subnetBinary[$fullBytes]) & $mask
        );
    }

    /**
     * Validate an IPv6 address against a CIDR network.
     */
    public static function isIpv6InCidr(
        string $ip,
        string $cidr
    ): bool {
        [$subnet, $prefix] = array_pad(
            explode('/', $cidr, 2),
            2,
            '128'
        );

        $ipBinary = @inet_pton($ip);
        $subnetBinary = @inet_pton($subnet);

        if (
            $ipBinary === false ||
            $subnetBinary === false ||
            strlen($ipBinary) !== 16 ||
            strlen($subnetBinary) !== 16
        ) {
            return false;
        }

        $prefix = (int)$prefix;

        if ($prefix < 0 || $prefix > 128) {
            return false;
        }

        $fullBytes = intdiv($prefix, 8);
        $remainingBits = $prefix % 8;

        if (
            $fullBytes > 0 &&
            substr(
                $ipBinary,
                0,
                $fullBytes
            ) !== substr(
                $subnetBinary,
                0,
                $fullBytes
            )
        ) {
            return false;
        }

        if ($remainingBits === 0) {
            return true;
        }

        $mask = (
            0xFF << (8 - $remainingBits)
        ) & 0xFF;

        return (
            ord($ipBinary[$fullBytes]) & $mask
        ) === (
            ord($subnetBinary[$fullBytes]) & $mask
        );
    }

    /**
     * Match an IP address against an IPv4/IPv6 CIDR network.
     */
    public static function ipMatchesNetwork(
        string $ip,
        string $network
    ): bool {
        if (
            filter_var(
                $ip,
                FILTER_VALIDATE_IP,
                FILTER_FLAG_IPV4
            ) !== false
        ) {
            return self::isIpv4InCidr(
                $ip,
                $network
            );
        }

        if (
            filter_var(
                $ip,
                FILTER_VALIDATE_IP,
                FILTER_FLAG_IPV6
            ) !== false
        ) {
            return self::isIpv6InCidr(
                $ip,
                $network
            );
        }

        return false;
    }

    /**
     * Determine whether an IP belongs to a configured trusted proxy.
     */
    public static function isTrustedProxy(
        ?string $ip
    ): bool {
        if ($ip === null || $ip === '') {
            return false;
        }

        $trusted = Helpers::config(
            'security.trusted_proxies',
            []
        );

        if (!is_array($trusted)) {
            return false;
        }

        foreach ($trusted as $trustedNetwork) {
            $trustedNetwork = trim(
                (string)$trustedNetwork
            );

            if ($trustedNetwork === '') {
                continue;
            }

            /*
             * Exact IP match.
             */
            if (!str_contains($trustedNetwork, '/')) {
                if ($trustedNetwork === $ip) {
                    return true;
                }

                continue;
            }

            /*
             * CIDR match.
             */
            if (
                self::ipMatchesNetwork(
                    $ip,
                    $trustedNetwork
                )
            ) {
                return true;
            }
        }

        return false;
    }

    /**
     * Resolve the client IP.
     *
     * Forwarded headers are only trusted when REMOTE_ADDR belongs
     * to a configured trusted proxy.
     */
    public static function clientIp(): ?string
    {
        $remote = $_SERVER['REMOTE_ADDR'] ?? null;

        $remote = (
            is_string($remote) &&
            filter_var(
                $remote,
                FILTER_VALIDATE_IP
            ) !== false
        )
            ? $remote
            : null;

        if (
            $remote !== null &&
            self::isTrustedProxy($remote)
        ) {
            $realIp =
                $_SERVER['HTTP_X_REAL_IP'] ?? null;

            if (
                is_string($realIp) &&
                filter_var(
                    $realIp,
                    FILTER_VALIDATE_IP
                ) !== false
            ) {
                return $realIp;
            }

            $forwarded =
                $_SERVER['HTTP_X_FORWARDED_FOR'] ?? null;

            if (is_string($forwarded)) {
                $candidates = array_map(
                    'trim',
                    explode(',', $forwarded)
                );

                foreach ($candidates as $candidate) {
                    if (
                        filter_var(
                            $candidate,
                            FILTER_VALIDATE_IP
                        ) !== false
                    ) {
                        return $candidate;
                    }
                }
            }
        }

        return $remote;
    }

    /**
     * Validate a forum URL.
     *
     * Only HTTP and HTTPS URLs are allowed.
     */
    public static function isValidForumUrl(
        string $url
    ): bool {
        $url = trim($url);

        /*
         * Defensive length limit.
         */
        if (
            $url === '' ||
            strlen($url) > 2048
        ) {
            return false;
        }

        /*
         * The URL must be safe to place inside an HTML attribute.
         */
        if (
            preg_match(
                '/[\x00-\x20\x7F<>"\']/',
                $url
            ) === 1
        ) {
            return false;
        }

        try {
            $parts = parse_url($url);
        } catch (ValueError) {
            return false;
        }

        if (!is_array($parts)) {
            return false;
        }

        /*
         * Only web URLs are supported.
         */
        $scheme = strtolower(
            (string)($parts['scheme'] ?? '')
        );

        if (
            !in_array(
                $scheme,
                ['http', 'https'],
                true
            )
        ) {
            return false;
        }

        /*
         * A host is mandatory.
         */
        $host = $parts['host'] ?? null;

        if (
            !is_string($host) ||
            $host === ''
        ) {
            return false;
        }

        /*
         * Never allow credentials in forum links.
         *
         * Rejected:
         * https://user:password@example.com/
         */
        if (
            isset($parts['user']) ||
            isset($parts['pass'])
        ) {
            return false;
        }

        /*
         * Validate the final URL syntax.
         */
        if (
            filter_var(
                $url,
                FILTER_VALIDATE_URL
            ) === false
        ) {
            return false;
        }

        return true;
    }

    /**
     * Separate trailing punctuation from a URL.
     *
     * Example:
     *
     * https://example.com/test).
     *
     * URL:
     * https://example.com/test
     *
     * Trailing:
     * ).
     *
     * @return array{0: string, 1: string}
     */
    public static function splitForumUrlTrailingPunctuation(
        string $candidate
    ): array {
        $url = $candidate;

        while ($url !== '') {
            $last = substr(
                $url,
                -1
            );

            /*
             * Punctuation that normally ends a sentence.
             */
            if (
                str_contains(
                    '.,;:!?]}',
                    $last
                )
            ) {
                $url = substr(
                    $url,
                    0,
                    -1
                );

                continue;
            }

            /*
             * Parentheses can legitimately belong to URLs.
             *
             * Remove a closing ")" only when it is unmatched.
             */
            if (
                $last === ')' &&
                substr_count($url, ')') >
                substr_count($url, '(')
            ) {
                $url = substr(
                    $url,
                    0,
                    -1
                );

                continue;
            }

            break;
        }

        $trailing = substr(
            $candidate,
            strlen($url)
        );

        return [
            $url,
            $trailing,
        ];
    }

    /**
     * Validate all HTTP/HTTPS URLs found in text.
     *
     * This performs syntax validation only.
     * No external network request is made.
     *
     * @return array<int, string>
     */
    public static function validateForumUrls(
        string $text
    ): array {
        $errors = [];

        $pattern =
            '~https?://[^\s<>"\']+~iu';

        $result = preg_match_all(
            $pattern,
            $text,
            $matches
        );

        if (
            $result === false ||
            $result === 0
        ) {
            return [];
        }

        foreach ($matches[0] as $candidate) {
            [$url] =
                self::splitForumUrlTrailingPunctuation(
                    (string)$candidate
                );

            if (
                !self::isValidForumUrl($url)
            ) {
                $errors[] =
                    'One or more links are invalid or not allowed. ' .
                    'Only valid HTTP and HTTPS links are accepted.';
            }
        }

        return array_values(
            array_unique($errors)
        );
    }

    /**
     * Write an audit event.
     */
    public static function audit(
        ?int $uid,
        ?string $username,
        string $eventType,
        ?string $description = null,
        bool $success = true,
        bool $mandatory = false
    ): void {
        try {
            $ip = Settings::raw(
                'audit.store_ip',
                true
            )
                ? self::clientIp()
                : null;

            $userAgent =
                Settings::raw(
                    'audit.store_user_agent',
                    true
                ) &&
                isset($_SERVER['HTTP_USER_AGENT'])
                ? substr(
                    (string)$_SERVER['HTTP_USER_AGENT'],
                    0,
                    255
                )
                : null;

            $eventType = substr(
                $eventType,
                0,
                50
            );

            $description =
                $description !== null
                ? substr(
                    $description,
                    0,
                    255
                )
                : null;

            $stmt = Database::connection()->prepare(
                'INSERT INTO audit_log
                    (
                        user_id,
                        username,
                        event_type,
                        description,
                        ip_address,
                        user_agent,
                        success
                    )
                 VALUES (?, ?, ?, ?, ?, ?, ?)'
            );

            $stmt->execute([
                $uid,
                $username,
                $eventType,
                $description,
                $ip !== null
                    ? substr($ip, 0, 45)
                    : null,
                $userAgent,
                $success ? 1 : 0,
            ]);
        } catch (Throwable $e) {
            error_log(
                'Error al registrar auditoría: ' .
                    $e->getMessage()
            );

            if ($mandatory) {
                throw new RuntimeException(
                    'No se pudo registrar la auditoría.',
                    0,
                    $e
                );
            }
        }
    }

    /**
     * Write a mandatory audit event.
     */
    public static function auditCritical(
        ?int $uid,
        ?string $username,
        string $eventType,
        ?string $description = null,
        bool $success = true
    ): void {
        self::audit(
            $uid,
            $username,
            $eventType,
            $description,
            $success,
            true
        );
    }
}
