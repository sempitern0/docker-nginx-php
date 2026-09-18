<?php

declare(strict_types=1);

final class Database
{
    private static ?PDO $pdo = null;

    private function __construct()
    {
    }

    public static function connection(): PDO
    {
        if (self::$pdo instanceof PDO) {
            return self::$pdo;
        }

        $driver = strtolower((string)Helpers::config('db.driver', 'mysql'));
        $host = (string)Helpers::config('db.host', '127.0.0.1');
        $port = (int)Helpers::config('db.port', 3306);
        $dbname = (string)Helpers::config('db.name', 'app_db');
        $charset = (string)Helpers::config('db.charset', 'utf8mb4');

        if ($driver === 'pgsql') {
            $clientEncoding = strtoupper($charset) === 'UTF8MB4'
                ? 'UTF8'
                : $charset;

            $dsn = sprintf(
                "pgsql:host=%s;port=%d;dbname=%s;options='--client_encoding=%s'",
                $host,
                $port,
                $dbname,
                $clientEncoding
            );
        } else {
            $dsn = sprintf(
                '%s:host=%s;port=%d;dbname=%s;charset=%s',
                $driver,
                $host,
                $port,
                $dbname,
                $charset
            );
        }

        $timeout = max(1, (int)Helpers::config('db.connect_timeout', 5));
        $options = Helpers::config('db.options', [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
            PDO::ATTR_STRINGIFY_FETCHES => false,
            PDO::ATTR_TIMEOUT => $timeout,
            PDO::ATTR_PERSISTENT => false,
        ]);

        try {
            self::$pdo = new PDO(
                $dsn,
                (string)Helpers::config('db.user', 'root'),
                (string)Helpers::config('db.pass', ''),
                $options
            );
        } catch (PDOException $e) {
            throw new RuntimeException(
                'Unable to connect to the database.',
                0,
                $e
            );
        }

        return self::$pdo;
    }
}
