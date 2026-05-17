<?php
// 🛡️ Authentication Middleware
// Protects routes by verifying the JWT token.

namespace App\Middleware;

use App\Core\Request;
use App\Core\Response;
use App\Services\AuthService;

class AuthMiddleware {
    public static function handle() {
        // 🧪 Robust Header Extraction
        $authHeader = null;
        
        if (isset($_SERVER['HTTP_AUTHORIZATION'])) {
            $authHeader = $_SERVER['HTTP_AUTHORIZATION'];
        } elseif (function_exists('apache_request_headers')) {
            $headers = apache_request_headers();
            $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? null;
        } elseif (function_exists('getallheaders')) {
            $headers = getallheaders();
            $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? null;
        }

        if (!$authHeader || strpos($authHeader, 'Bearer ') !== 0) {
            Response::error("Unauthorized access", 401);
        }

        $token = substr($authHeader, 7);
        $payload = AuthService::validateToken($token);

        if (!$payload) {
            Response::error("Invalid or expired token", 401);
        }

        return $payload;
    }

    public static function checkRole($userRole, $requiredRole) {
        if ($userRole !== $requiredRole) {
            Response::error("Access forbidden: Restricted to $requiredRole role", 403);
        }
    }
}
