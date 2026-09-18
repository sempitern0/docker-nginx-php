<?php

declare(strict_types=1);

final class RateLimiter
{
    private function __construct()
    {
    }

    /**
     * Generates an opaque, privacy-preserving bucket key.
     * The raw identifier is never stored.
     */
    public static function key(string $scope, string $identifier): string
    {
        $secret = (string)Helpers::config('security.rate_limit_secret', '');

        if ($secret === '') {
            throw new RuntimeException('Rate limit secret is not configured.');
        }

        return hash_hmac(
            'sha256',
            $scope . ':' . $identifier,
            $secret,
            true
        );
    }

    /**
     * @return array{allowed: bool, attempts: int, retry_after: int}
     */
    public static function check(
        string $scope,
        string $identifier,
        int $maxAttempts,
        int $windowSeconds
    ): array {
        $maxAttempts = max(1, $maxAttempts);
        $windowSeconds = max(1, $windowSeconds);

        $key = self::key($scope, $identifier);
        $pdo = Database::connection();
        $ageExpression = self::windowAgeExpression($pdo);

        $stmt = $pdo->prepare(
            "SELECT attempts,\n"
            . "       $ageExpression AS window_age\n"
            . "FROM rate_limits\n"
            . "WHERE bucket_key = ?\n"
            . "LIMIT 1"
        );

        $stmt->execute([$key]);
        $row = $stmt->fetch();

        if (!$row) {
            return [
                'allowed' => true,
                'attempts' => 0,
                'retry_after' => 0,
            ];
        }

        $windowAge = max(0, (int)$row['window_age']);

        if ($windowAge >= $windowSeconds) {
            return [
                'allowed' => true,
                'attempts' => 0,
                'retry_after' => 0,
            ];
        }

        $attempts = (int)$row['attempts'];

        if ($attempts < $maxAttempts) {
            return [
                'allowed' => true,
                'attempts' => $attempts,
                'retry_after' => 0,
            ];
        }

        return [
            'allowed' => false,
            'attempts' => $attempts,
            'retry_after' => max(1, $windowSeconds - $windowAge),
        ];
    }

    /**
     * @return array{allowed: bool, attempts: int, retry_after: int}
     */
    public static function consume(
        string $scope,
        string $identifier,
        int $maxAttempts,
        int $windowSeconds
    ): array {
        $maxAttempts = max(1, $maxAttempts);
        $windowSeconds = max(1, $windowSeconds);

        $key = self::key($scope, $identifier);
        $pdo = Database::connection();
        $ageExpression = self::windowAgeExpression($pdo);

        $pdo->beginTransaction();

        try {
            self::ensureBucketExists($pdo, $key);

            $select = $pdo->prepare(
                "SELECT attempts,\n"
                . "       $ageExpression AS window_age\n"
                . "FROM rate_limits\n"
                . "WHERE bucket_key = ?\n"
                . "FOR UPDATE"
            );

            $select->execute([$key]);
            $row = $select->fetch();

            if (!$row) {
                throw new RuntimeException(
                    'Unable to initialize rate-limit bucket.'
                );
            }

            $attempts = (int)$row['attempts'];
            $windowAge = max(0, (int)$row['window_age']);

            if ($windowAge >= $windowSeconds) {
                $update = $pdo->prepare(<<<'SQL'
                    UPDATE rate_limits
                    SET attempts = 1,
                        window_started_at = CURRENT_TIMESTAMP,
                        last_attempt_at = CURRENT_TIMESTAMP
                    WHERE bucket_key = ?
                SQL);

                $update->execute([$key]);
                $pdo->commit();

                return [
                    'allowed' => true,
                    'attempts' => 1,
                    'retry_after' => 0,
                ];
            }

            if ($attempts >= $maxAttempts) {
                $retryAfter = max(1, $windowSeconds - $windowAge);
                $pdo->commit();

                return [
                    'allowed' => false,
                    'attempts' => $attempts,
                    'retry_after' => $retryAfter,
                ];
            }

            $attempts++;

            $update = $pdo->prepare(<<<'SQL'
                UPDATE rate_limits
                SET attempts = ?,
                    last_attempt_at = CURRENT_TIMESTAMP
                WHERE bucket_key = ?
            SQL);

            $update->execute([$attempts, $key]);
            $pdo->commit();

            return [
                'allowed' => true,
                'attempts' => $attempts,
                'retry_after' => 0,
            ];
        } catch (Throwable $e) {
            if ($pdo->inTransaction()) {
                $pdo->rollBack();
            }

            throw $e;
        }
    }

    public static function clear(string $scope, string $identifier): void
    {
        $key = self::key($scope, $identifier);

        $stmt = Database::connection()->prepare(<<<'SQL'
            DELETE FROM rate_limits
            WHERE bucket_key = ?
        SQL);

        $stmt->execute([$key]);
    }

    public static function cleanup(int $maxAgeSeconds = 86400): void
    {
        $maxAgeSeconds = max(3600, $maxAgeSeconds);
        $cutoff = (new DateTimeImmutable())
            ->modify("-{$maxAgeSeconds} seconds")
            ->format('Y-m-d H:i:s');

        $stmt = Database::connection()->prepare(<<<'SQL'
            DELETE FROM rate_limits
            WHERE last_attempt_at < ?
        SQL);

        $stmt->execute([$cutoff]);
    }

    private static function ensureBucketExists(PDO $pdo, string $key): void
    {
        $driver = strtolower((string)Helpers::config('db.driver', 'mysql'));

        if ($driver === 'pgsql') {
            $stmt = $pdo->prepare(<<<'SQL'
                INSERT INTO rate_limits (
                    bucket_key,
                    attempts,
                    window_started_at,
                    last_attempt_at
                )
                VALUES (?, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
                ON CONFLICT (bucket_key) DO NOTHING
            SQL);
        } else {
            $stmt = $pdo->prepare(<<<'SQL'
                INSERT IGNORE INTO rate_limits (
                    bucket_key,
                    attempts,
                    window_started_at,
                    last_attempt_at
                )
                VALUES (?, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
            SQL);
        }

        $stmt->execute([$key]);
    }

    private static function windowAgeExpression(PDO $pdo): string
    {
        $driver = strtolower((string)$pdo->getAttribute(PDO::ATTR_DRIVER_NAME));

        return match ($driver) {
            'pgsql' => 'EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - window_started_at))',
            default => 'TIMESTAMPDIFF(SECOND, window_started_at, CURRENT_TIMESTAMP)',
        };
    }
}
