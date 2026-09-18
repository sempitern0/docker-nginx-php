<?php

declare(strict_types=1);

final class Helpers
{
    private static ?array $config = null;

    private function __construct()
    {
    }

    public static function config(?string $key = null, mixed $default = null): mixed
    {
        if (self::$config === null) {
            $path = dirname(__DIR__) . '/config/config.php';

            if (!is_file($path)) {
                throw new RuntimeException('Configuration file not found.');
            }

            $config = require $path;

            if (!is_array($config)) {
                throw new RuntimeException('Configuration file must return an array.');
            }

            self::$config = $config;
        }

        if ($key === null) {
            return self::$config;
        }

        $value = self::$config;

        foreach (explode('.', $key) as $segment) {
            if (is_array($value) && array_key_exists($segment, $value)) {
                $value = $value[$segment];
            } else {
                return $default;
            }
        }

        return $value;
    }

    public static function redirect(string $path, int $status = 302): never
    {
        $allowedStatuses = [301, 302, 303, 307, 308];

        if (!in_array($status, $allowedStatuses, true)) {
            throw new InvalidArgumentException('Código HTTP de redirección no permitido.');
        }

        if (preg_match('/[\r\n\x00-\x1F\x7F]/', $path)) {
            throw new InvalidArgumentException('La redirección contiene caracteres de control.');
        }

        $path = trim($path);

        if ($path === '' || str_starts_with($path, '//')) {
            throw new InvalidArgumentException('Destino de redirección inválido.');
        }

        if (preg_match('~^[a-z][a-z0-9+.-]*://~i', $path)) {
            throw new InvalidArgumentException('Helpers::redirect() no admite destinos externos.');
        }

        $location = Security::url($path);

        header("Location: $location", true, $status);
        exit;
    }
}
