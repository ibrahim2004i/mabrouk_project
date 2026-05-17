<?php
// 🚀 Mabrouk API Entry Point
// Centralizes request handling and routing.

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit;
}

// 🐛 DEBUG LOGGING
file_put_contents(__DIR__ . '/log.txt', "[".date('Y-m-d H:i:s')."] " . $_SERVER['REQUEST_METHOD'] . " " . $_SERVER['REQUEST_URI'] . "\n", FILE_APPEND);

require_once __DIR__ . '/../src/Core/Autoloader.php';
require_once __DIR__ . '/../src/Routes/api.php';

use App\Core\Request;
use App\Core\Router;
use App\Core\Response;

$method = Request::getMethod();
$uri = Request::getUri();

// 🏎️ DYNAMIC BASE PATH DETECTION
$uri = $_SERVER['REQUEST_URI'];
if (strpos($uri, '?') !== false) {
    $uri = substr($uri, 0, strpos($uri, '?'));
}

// Strip /index.php from the URI if it exists
$uri = str_replace('/index.php', '', $uri);

if ($uri == '' || $uri == '/') $uri = '/';

try {
    $match = Router::resolve($method, $uri);

    if (!$match) {
        Response::error("Endpoint not found", 404);
    }

    $handler = $match['handler'];
    $params = $match['params'];
    $middleware = $match['middleware'];

    // 🛑 MIDDLEWARE EXECUTION
    $authPayload = null;
    foreach ($middleware as $mw) {
        if ($mw === 'auth') {
            $authPayload = \App\Middleware\AuthMiddleware::handle();
        }
        if ($mw === 'provider' || $mw === 'admin') {
            if (!$authPayload) {
                $authPayload = \App\Middleware\AuthMiddleware::handle();
            }
            \App\Middleware\AuthMiddleware::checkRole($authPayload['role'], $mw);
        }
    }

    // Pass authPayload to Global if needed or inject into Request
    $_SESSION['user_id'] = $authPayload['user_id'] ?? null;
    $_SESSION['role'] = $authPayload['role'] ?? null;

    // 🏎️ CONTROLLER EXECUTION
    list($controllerName, $action) = explode('@', $handler);
    $controllerClass = "App\\Controllers\\" . $controllerName;

    if (!class_exists($controllerClass)) {
        Response::error("Controller $controllerClass not found", 500);
    }

    $controller = new $controllerClass();
    if (!method_exists($controller, $action)) {
        Response::error("Action $action not found in $controllerClass", 500);
    }

    // Call the controller action with params
    call_user_func_array([$controller, $action], $params);

} catch (Exception $e) {
    Response::error("Server Error: " . $e->getMessage(), 500);
}
