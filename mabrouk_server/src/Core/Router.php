<?php
// 🧭 API Routing System
// Map URI paths to specific controller actions.

namespace App\Core;

class Router {
    private static $routes = [];

    public static function add($method, $path, $handler, $middleware = []) {
        $path = preg_replace('/\{([a-zA-Z0-9_]+)\}/', '(?P<\1>[^/]+)', $path);
        self::$routes[] = [
            'method' => $method,
            'path' => "#^$path$#",
            'handler' => $handler,
            'middleware' => $middleware
        ];
    }

    public static function resolve($method, $uri) {
        foreach (self::$routes as $route) {
            if ($route['method'] === $method && preg_match($route['path'], $uri, $matches)) {
                $params = array_filter($matches, 'is_string', ARRAY_FILTER_USE_KEY);
                return ['handler' => $route['handler'], 'params' => $params, 'middleware' => $route['middleware']];
            }
        }
        return null;
    }

    // Static route registration methods
    public static function get($path, $handler, $mw = []) { self::add('GET', $path, $handler, $mw); }
    public static function post($path, $handler, $mw = []) { self::add('POST', $path, $handler, $mw); }
    public static function put($path, $handler, $mw = []) { self::add('PUT', $path, $handler, $mw); }
    public static function delete($path, $handler, $mw = []) { self::add('DELETE', $path, $handler, $mw); }
}
