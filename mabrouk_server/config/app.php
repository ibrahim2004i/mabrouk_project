<?php
// ⚙️ Global Application Configuration
// Use this file to manage environment-specific settings.

return [
    'db' => [
        'host' => getenv('DB_HOST') ?: 'localhost',
        'dbname' => getenv('DB_NAME') ?: 'mabrouk_db_new',
        'user' => getenv('DB_USER') ?: 'root',
        'pass' => getenv('DB_PASS') ?: '',
        'charset' => 'utf8mb4',
        'socket' => getenv('DB_SOCKET') ?: null, // For Cloud SQL Unix Socket
    ],
    'auth' => [
        'jwt_secret' => 'mabrouk_super_secret_key_2026', // Change in production
        'token_expiry' => 3600 * 24 * 7, // 7 Days
    ],
    'app' => [
        'name' => 'Mabrouk Marketplace',
        'version' => '1.0.0',
        'debug' => true,
    ]
];
