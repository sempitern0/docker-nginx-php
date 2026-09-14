<?php

declare(strict_types=1);

function env_value(string $name, ?string $default = null): ?string
{
    $file = getenv($name . '_FILE');

    if (is_string($file) && $file !== '' && is_readable($file)) {
        $value = file_get_contents($file);

        if ($value !== false) {
            return trim($value);
        }
    }

    $value = getenv($name);

    return $value === false ? $default : $value;
}

$driver = strtolower(trim((string)env_value('DB_DRIVER', 'mysql')));

if (!in_array($driver, ['mysql', 'pgsql'], true)) {
    throw new RuntimeException('Unsupported database driver.');
}

return [
    'app' => [
        'name' => env_value('APP_NAME', 'MYSITE'),
        'env' => env_value('APP_ENV', 'development'),
        'debug' => filter_var(env_value('APP_DEBUG', 'false'), FILTER_VALIDATE_BOOLEAN),
        'timezone' => env_value('APP_TIMEZONE', 'Europe/Madrid'),
        'base_url' => rtrim((string)env_value('APP_DOMAIN', 'https://'), '/'),
        'locale' => env_value('APP_LOCALE', 'es'),
    ],

    'db' => [
        'driver'    => $driver,
        'host'      => env_value('DB_HOST', $driver === 'pgsql' ? 'postgresdb' : 'mariadb'),
        'port'      => (int)env_value('DB_PORT', $driver === 'pgsql' ? '5432' : '3306'),
        'name'      => env_value('DB_DATABASE', 'app_db'),
        'user'      => env_value('DB_USER', 'ca_user'),
        'pass'      => env_value('DB_PASSWORD', ''),
        'charset'   => $driver === 'pgsql' ? 'utf8' : 'utf8mb4',
        'collation' => 'utf8mb4_unicode_ci',
        'connect_timeout' => (int) env_value('DB_CONNECT_TIMEOUT', '5'),
        'options' => [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
            PDO::ATTR_STRINGIFY_FETCHES => false,
            PDO::ATTR_TIMEOUT => (int)env_value('DB_CONNECT_TIMEOUT', '5'),
            PDO::ATTR_PERSISTENT => false,
        ],
    ],

    'security' => [
        'session_name' => env_value('SESSION_NAME', 'APP_SESSID'),
        'session_timeout' => (int)env_value('SESSION_TIMEOUT', '1800'),
        'secure_cookies' => filter_var(env_value('SESSION_SECURE_COOKIE', 'true'), FILTER_VALIDATE_BOOLEAN),
        'max_login_attempts' => (int)env_value('MAX_LOGIN_ATTEMPTS', '5'),
        'lockout_minutes' => (int)env_value('LOCKOUT_MINUTES', '15'),

        'admin_gate_secret' => env_value('ADMIN_GATE_SECRET', ''),
        'admin_gate_timeout' => (int)env_value('ADMIN_GATE_TIMEOUT', '3600'),
        'rate_limit_secret' => env_value('RATE_LIMIT_SECRET', ''),
        'login_ip_max_attempts' => (int)env_value('LOGIN_IP_MAX_ATTEMPTS', '20'),
        'login_ip_window_seconds' => (int)env_value('LOGIN_IP_WINDOW_SECONDS', '300'),
        'login_user_max_attempts' => (int)env_value('LOGIN_USER_MAX_ATTEMPTS', '5'),
        'login_user_window_seconds' => (int)env_value('LOGIN_USER_WINDOW_SECONDS', '900'),

        'session_samesite' => env_value('SESSION_SAMESITE', 'Lax'),
        'mfa_pending_timeout' => (int)env_value('MFA_PENDING_TIMEOUT', '300'),
        'authorization_cache_ttl' => (int)env_value('AUTHORIZATION_CACHE_TTL', '0'),
        'trusted_proxies' => array_values(array_filter(array_map(
            'trim',
            explode(',', (string)env_value('TRUSTED_PROXIES', '172.30.0.0/24'))
        ))),
    ],
];
