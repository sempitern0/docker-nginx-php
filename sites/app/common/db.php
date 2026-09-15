<?php

declare(strict_types=1);

function db(): PDO
{
    static $pdo = null;

    $driver  = (string)config('db.driver', 'mysql');
    $host    = (string)config('db.host', '127.0.0.1');
    $port    = (int)config('db.port', 3306);
    $dbname  = (string)config('db.name', 'app_db');
    $charset = (string)config('db.charset', 'utf8mb4');

    if ($driver === 'pgsql') {
        $dsn = sprintf(
            'pgsql:host=%s;port=%d;dbname=%s;options=\'--client_encoding=%s\'',
            $host,
            $port,
            $dbname,
            $charset
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

    $timeout = max(1, (int) config('db.connect_timeout', 5));
    $options = config('db.options', [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
        PDO::ATTR_STRINGIFY_FETCHES => false,
        PDO::ATTR_TIMEOUT => $timeout,
        PDO::ATTR_PERSISTENT => false,
    ]);

    try {
        $pdo = new PDO(
            $dsn,
            (string)config('db.user', 'root'),
            (string)config('db.pass', ''),
            $options
        );
    } catch (PDOException $e) {
        throw new RuntimeException('Unable to connect to the database.', 0, $e);
    }

    return $pdo;
}
