<?php

declare(strict_types=1);

/**
 * Generates an opaque, privacy-preserving bucket key.
 *
 * The raw identifier (IP address, user ID, etc.) is never stored.
 */
function rate_limit_key(string $scope, string $identifier): string
{
    $secret = (string)config('security.rate_limit_secret', '');

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
 * Check whether a rate-limit bucket is currently allowed.
 *
 * This function does not increment the counter.
 *
 * @return array{
 *     allowed: bool,
 *     attempts: int,
 *     retry_after: int
 * }
 */
function rate_limit_check(
    string $scope,
    string $identifier,
    int $maxAttempts,
    int $windowSeconds
): array {
    $maxAttempts = max(1, $maxAttempts);
    $windowSeconds = max(1, $windowSeconds);

    $key = rate_limit_key($scope, $identifier);
    $pdo = db();

    $stmt = $pdo->prepare(
        'SELECT attempts,
                window_started_at,
                TIMESTAMPDIFF(
                    SECOND,
                    window_started_at,
                    NOW()
                ) AS window_age
         FROM rate_limits
         WHERE bucket_key = ?
         LIMIT 1'
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
 * Atomically records one attempt in a rate-limit bucket.
 *
 * @return array{
 *     allowed: bool,
 *     attempts: int,
 *     retry_after: int
 * }
 */
function rate_limit_consume(
    string $scope,
    string $identifier,
    int $maxAttempts,
    int $windowSeconds
): array {
    $maxAttempts = max(1, $maxAttempts);
    $windowSeconds = max(1, $windowSeconds);

    $key = rate_limit_key($scope, $identifier);
    $pdo = db();

    $pdo->beginTransaction();

    try {
        /*
         * Ensure the row exists before SELECT ... FOR UPDATE.
         *
         * INSERT IGNORE is safe here because bucket_key is the primary key.
         */
        $insert = $pdo->prepare(
            'INSERT IGNORE INTO rate_limits (
                bucket_key,
                attempts,
                window_started_at,
                last_attempt_at
            ) VALUES (?, 0, NOW(), NOW())'
        );

        $insert->execute([$key]);

        $select = $pdo->prepare(
            'SELECT attempts,
                    TIMESTAMPDIFF(
                        SECOND,
                        window_started_at,
                        NOW()
                    ) AS window_age
             FROM rate_limits
             WHERE bucket_key = ?
             FOR UPDATE'
        );

        $select->execute([$key]);
        $row = $select->fetch();

        if (!$row) {
            throw new RuntimeException('Unable to initialize rate-limit bucket.');
        }

        $attempts = (int)$row['attempts'];
        $windowAge = max(0, (int)$row['window_age']);

        /*
         * Start a new window after the current one expires.
         */
        if ($windowAge >= $windowSeconds) {
            $update = $pdo->prepare(
                'UPDATE rate_limits
                 SET attempts = 1,
                     window_started_at = NOW(),
                     last_attempt_at = NOW()
                 WHERE bucket_key = ?'
            );

            $update->execute([$key]);

            $pdo->commit();

            return [
                'allowed' => true,
                'attempts' => 1,
                'retry_after' => 0,
            ];
        }

        /*
         * The current request is allowed only if it does not exceed
         * the configured limit.
         */
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

        $update = $pdo->prepare(
            'UPDATE rate_limits
             SET attempts = ?,
                 last_attempt_at = NOW()
             WHERE bucket_key = ?'
        );

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

/**
 * Clear a rate-limit bucket.
 *
 * Used for account-specific failures after a successful login.
 */
function rate_limit_clear(string $scope, string $identifier): void
{
    $key = rate_limit_key($scope, $identifier);

    $stmt = db()->prepare(
        'DELETE FROM rate_limits
         WHERE bucket_key = ?'
    );

    $stmt->execute([$key]);
}

/**
 * Remove old buckets.
 *
 * This is intended for occasional maintenance, not for every request.
 */
function rate_limit_cleanup(int $maxAgeSeconds = 86400): void
{
    $maxAgeSeconds = max(3600, $maxAgeSeconds);
    $cutoff = (new DateTimeImmutable())
        ->modify("-{$maxAgeSeconds} seconds")
        ->format('Y-m-d H:i:s');

    $stmt = db()->prepare('DELETE FROM rate_limits WHERE last_attempt_at < ?');
    $stmt->execute([$cutoff]);
}
