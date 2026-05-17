<?php
// 🛡️ JWT Authentication Service
// Handles token generation and validation.

namespace App\Services;

class AuthService {
    private static $secret = "mabrouk_super_secret_key_2026";

    public static function generateToken($user_id, $role) {
        $header = json_encode(['typ' => 'JWT', 'alg' => 'HS256']);
        $payload = json_encode([
            'user_id' => $user_id,
            'role' => $role,
            'exp' => time() + (60 * 60 * 24) // 24 hours
        ]);

        $base64UrlHeader = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($header));
        $base64UrlPayload = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($payload));

        $signature = hash_hmac('sha256', $base64UrlHeader . "." . $base64UrlPayload, self::$secret, true);
        $base64UrlSignature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));

        return $base64UrlHeader . "." . $base64UrlPayload . "." . $base64UrlSignature;
    }

    public static function validateToken($token) {
        $parts = explode('.', $token);
        if (count($parts) !== 3) return false;

        list($header, $payload, $signature) = $parts;

        $validSignature = hash_hmac('sha256', $header . "." . $payload, self::$secret, true);
        $base64UrlValidSignature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($validSignature));

        if ($signature !== $base64UrlValidSignature) return false;

        $payloadData = json_decode(base64_decode($payload), true);
        if ($payloadData['exp'] < time()) return false;

        return $payloadData;
    }
}
