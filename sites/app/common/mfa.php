<?php

declare(strict_types=1);

final class Mfa
{
    private function __construct()
    {
    }

    /**
     * Generates replacement backup codes and stores only their hashes.
     *
     * @return array<string>
     */
    public static function generateBackupCodes(
        PDO $pdo,
        int $userId,
        int $count = 8
    ): array {
        if ($userId <= 0) {
            throw new InvalidArgumentException('Usuario no válido.');
        }

        $count = max(1, min($count, 20));
        $pdo->beginTransaction();

        try {
            $delete = $pdo->prepare(
                'DELETE FROM mfa_backup_codes WHERE user_id = ?'
            );
            $delete->execute([$userId]);

            $plainCodes = [];
            $insert = $pdo->prepare(
                'INSERT INTO mfa_backup_codes (user_id, code_hash) VALUES (?, ?)'
            );

            for ($i = 0; $i < $count; $i++) {
                $code = strtoupper(bin2hex(random_bytes(4)));
                $plainCodes[] = $code;
                $hash = password_hash($code, PASSWORD_DEFAULT);
                $insert->execute([$userId, $hash]);
            }

            $pdo->commit();

            return $plainCodes;
        } catch (Throwable $e) {
            if ($pdo->inTransaction()) {
                $pdo->rollBack();
            }

            throw $e;
        }
    }

    public static function verifyAndConsumeBackupCode(
        PDO $pdo,
        int $userId,
        string $inputCode
    ): bool {
        if ($userId <= 0) {
            return false;
        }

        $inputCode = strtoupper(trim($inputCode));

        if (!preg_match('/^[A-Z0-9]{8}$/', $inputCode)) {
            return false;
        }

        $stmt = $pdo->prepare(<<<'SQL'
            SELECT id, code_hash
            FROM mfa_backup_codes
            WHERE user_id = ? AND used_at IS NULL
        SQL);

        $stmt->execute([$userId]);

        while ($record = $stmt->fetch(PDO::FETCH_ASSOC)) {
            if (!password_verify($inputCode, (string)$record['code_hash'])) {
                continue;
            }

            $update = $pdo->prepare(<<<'SQL'
                UPDATE mfa_backup_codes
                SET used_at = CURRENT_TIMESTAMP
                WHERE id = ? AND user_id = ? AND used_at IS NULL
            SQL);
            $update->execute([(int)$record['id'], $userId]);

            return $update->rowCount() === 1;
        }

        return false;
    }

    public static function verifyTotp(
        string $secretBase32,
        string $inputCode,
        int $discrepancy = 1
    ): bool {
        $inputCode = trim($inputCode);

        if (!preg_match('/^\d{6}$/', $inputCode)) {
            return false;
        }

        $secretBase32 = strtoupper(
            str_replace([' ', '-', "\t", "\r", "\n"], '', $secretBase32)
        );

        if ($secretBase32 === '') {
            return false;
        }

        $binarySecret = self::base32Decode($secretBase32);

        if ($binarySecret === null || $binarySecret === '') {
            return false;
        }

        $discrepancy = max(0, min($discrepancy, 2));
        $currentTimeSlice = (int)floor(time() / 30);

        for ($offset = -$discrepancy; $offset <= $discrepancy; $offset++) {
            $timeSlice = $currentTimeSlice + $offset;
            $counter = pack(
                'N2',
                ($timeSlice >> 32) & 0xFFFFFFFF,
                $timeSlice & 0xFFFFFFFF
            );

            $hmac = hash_hmac('sha1', $counter, $binarySecret, true);
            $offsetIndex = ord($hmac[strlen($hmac) - 1]) & 0x0F;
            $chunk = substr($hmac, $offsetIndex, 4);

            if (strlen($chunk) !== 4) {
                continue;
            }

            $value = unpack('N', $chunk)[1] & 0x7FFFFFFF;
            $calculatedCode = str_pad(
                (string)($value % 1000000),
                6,
                '0',
                STR_PAD_LEFT
            );

            if (hash_equals($calculatedCode, $inputCode)) {
                return true;
            }
        }

        return false;
    }

    public static function base32Decode(string $input): ?string
    {
        $alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
        $input = strtoupper($input);

        $buffer = 0;
        $bitsLeft = 0;
        $output = '';

        for ($i = 0, $length = strlen($input); $i < $length; $i++) {
            $char = $input[$i];

            if ($char === '=') {
                break;
            }

            $position = strpos($alphabet, $char);

            if ($position === false) {
                return null;
            }

            $buffer = ($buffer << 5) | $position;
            $bitsLeft += 5;

            if ($bitsLeft >= 8) {
                $bitsLeft -= 8;
                $output .= chr(($buffer >> $bitsLeft) & 0xFF);
                $buffer &= (1 << $bitsLeft) - 1;
            }
        }

        return $output !== '' ? $output : null;
    }

    public static function generateBase32Secret(int $length = 16): string
    {
        $length = max(16, min($length, 64));
        $alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
        $secret = '';

        for ($i = 0; $i < $length; $i++) {
            $secret .= $alphabet[random_int(0, 31)];
        }

        return $secret;
    }
}
