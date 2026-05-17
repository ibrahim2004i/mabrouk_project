<?php
// 📤 Unified JSON Response Utility
// Standardizes the API output format.

namespace App\Core;

class Response {
    public static function json($success, $message, $data = null, $code = 200) {
        header("Content-Type: application/json; charset=utf-8");
        header("Access-Control-Allow-Origin: *");
        header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
        header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
        header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
        http_response_code($code);

        echo json_encode([
            "success" => $success,
            "message" => $message,
            "data" => $data
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    public static function error($message, $code = 400, $data = null) {
        return self::json(false, $message, $data, $code);
    }

    public static function success($message, $data = null, $code = 200) {
        return self::json(true, $message, $data, $code);
    }
}
