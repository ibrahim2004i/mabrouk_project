<?php
// 🗄️ Database Singleton Configuration
// Ensures a single connection per request.

namespace App\Core;

use PDO;
use PDOException;
use Exception;

class Database {
    private static $instance = null;
    private $conn;

    private function __construct() {
        $config = require __DIR__ . '/../../config/app.php';
        $db = $config['db'];

        try {
            $dsn = "mysql:dbname=" . $db['dbname'] . ";charset=" . $db['charset'];
            if (!empty($db['socket'])) {
                $dsn .= ";unix_socket=" . $db['socket'];
            } else {
                $dsn .= ";host=" . $db['host'];
            }

            $this->conn = new PDO($dsn, $db['user'], $db['pass']);
            $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            $this->conn->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            throw new Exception("Connection error: " . $e->getMessage());
        }
    }

    public static function getInstance() {
        if (!self::$instance) {
            self::$instance = new Database();
        }
        return self::$instance;
    }

    public function getConnection() {
        return $this->conn;
    }
}
