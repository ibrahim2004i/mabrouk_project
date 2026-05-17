<?php
// 📥 Incoming Request Handler
// Parses JSON input and handles query parameters.

namespace App\Core;

class Request {
    public static function getBody() {
        $json = json_decode(file_get_contents("php://input"), true);
        $data = $json ? $json : [];
        return array_merge($_POST, $data);
    }

    public static function getQueryParams() {
        return $_GET;
    }

    public static function getMethod() {
        return $_SERVER['REQUEST_METHOD'];
    }

    public static function getUri() {
        $path = $_SERVER['REQUEST_URI'] ?? '/';
        $position = strpos($path, '?');
        if ($position === false) {
            return $path;
        }
        return substr($path, 0, $position);
    }
}
