<?php

declare(strict_types=1);

final class Settings
{
    private static ?array $settings = null;

    private function __construct()
    {
    }

    public static function raw(string $key, mixed $default = null): mixed
    {
        if (self::$settings === null) {
            self::$settings = [];

            try {
                $stmt = Database::connection()->query(<<<'SQL'
                    SELECT setting_key, setting_value, value_type
                    FROM system_settings
                SQL);

                foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
                    self::$settings[$row['setting_key']] = [
                        'value' => $row['setting_value'],
                        'type' => $row['value_type'],
                    ];
                }
            } catch (Throwable $e) {
                error_log(
                    'Error cargando configuración del sistema: '
                    . $e->getMessage()
                );

                return $default;
            }
        }

        if (!array_key_exists($key, self::$settings)) {
            return $default;
        }

        $value = self::$settings[$key]['value'];
        $type = self::$settings[$key]['type'];

        return match ($type) {
            'boolean' => filter_var($value, FILTER_VALIDATE_BOOLEAN),
            'integer' => (int)$value,
            'json' => json_decode(
                (string)$value,
                true,
                512,
                JSON_THROW_ON_ERROR
            ),
            default => (string)$value,
        };
    }

    public static function get(string $key, mixed $default = null): mixed
    {
        return self::raw($key, $default);
    }

    public static function getBool(string $key, bool $default = false): bool
    {
        return (bool)self::raw($key, $default);
    }

    public static function getInt(string $key, int $default = 0): int
    {
        return (int)self::raw($key, $default);
    }

    public static function getString(string $key, string $default = ''): string
    {
        return (string)self::raw($key, $default);
    }

    public static function exists(string $key): bool
    {
        $stmt = Database::connection()->prepare(<<<'SQL'
            SELECT 1
            FROM system_settings
            WHERE setting_key = ?
            LIMIT 1
        SQL);

        $stmt->execute([$key]);

        return $stmt->fetchColumn() !== false;
    }

    public static function update(
        string $key,
        string $value,
        int $userId
    ): void {
        $stmt = Database::connection()->prepare(<<<'SQL'
            UPDATE system_settings
            SET setting_value = ?,
                updated_by = ?,
                updated_at = CURRENT_TIMESTAMP
            WHERE setting_key = ?
              AND is_editable = 1
        SQL);

        $stmt->execute([
            $value,
            $userId,
            $key,
        ]);

        if ($stmt->rowCount() !== 1) {
            throw new RuntimeException(
                'Error actualizando las configuraciones del sistema'
            );
        }

        if (self::$settings !== null) {
            self::$settings = null;
        }
    }

    /**
     * @return array<array<string, mixed>>
     */
    public static function all(): array
    {
        $stmt = Database::connection()->query(<<<'SQL'
            SELECT
                id,
                setting_key,
                setting_value,
                value_type,
                description,
                is_public,
                is_editable,
                updated_by,
                updated_at
            FROM system_settings
            ORDER BY setting_key ASC
        SQL);

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}
