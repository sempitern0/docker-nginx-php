<?php

declare(strict_types=1);

function system_setting_raw(
    string $key,
    mixed $default = null
): mixed {
    static $settings = null;

    if ($settings === null) {
        $settings = [];

        try {
            $stmt = db()->query(
                'SELECT setting_key, setting_value, value_type
                 FROM system_settings'
            );

            foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
                $settings[$row['setting_key']] = [
                    'value' => $row['setting_value'],
                    'type'  => $row['value_type'],
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

    if (!array_key_exists($key, $settings)) {
        return $default;
    }

    $value = $settings[$key]['value'];
    $type  = $settings[$key]['type'];

    return match ($type) {
        'boolean' => filter_var(
            $value,
            FILTER_VALIDATE_BOOLEAN
        ),

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

function system_setting(
    string $key,
    mixed $default = null
): mixed {
    return system_setting_raw($key, $default);
}

function system_setting_bool(
    string $key,
    bool $default = false
): bool {
    return (bool)system_setting_raw($key, $default);
}

function system_setting_int(
    string $key,
    int $default = 0
): int {
    return (int)system_setting_raw($key, $default);
}

function system_setting_string(
    string $key,
    string $default = ''
): string {
    return (string)system_setting_raw($key, $default);
}

function system_setting_exists(string $key): bool
{
    $stmt = db()->prepare(
        'SELECT 1
         FROM system_settings
         WHERE setting_key = ?
         LIMIT 1'
    );

    $stmt->execute([$key]);

    if ($stmt->rowCount() !== 1) {
        throw new RuntimeException(
            'Setting does not exist or is not editable.'
        );
    }

    return $stmt->fetchColumn() !== false;
}

function update_system_setting(
    string $key,
    string $value,
    int $userId
): void {
    $stmt = db()->prepare(
        'UPDATE system_settings
         SET setting_value = ?,
             updated_by = ?,
             updated_at = CURRENT_TIMESTAMP
         WHERE setting_key = ?
           AND is_editable = 1'
    );

    $stmt->execute([
        $value,
        $userId,
        $key,
    ]);

    if ($stmt->rowCount() !== 1) {
        throw new RuntimeException("Error actualizando las configuraciones del sistema");
    }
}

function get_all_system_settings(): array
{
    $stmt = db()->query(
        'SELECT
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
         ORDER BY setting_key ASC'
    );

    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}
