<?php
require_once __DIR__ . '/../src/Core/Database.php';
use App\Core\Database;

try {
    $db = Database::getInstance()->getConnection();
    
    echo "Creating service_specifications table... ";
    
    $query = "CREATE TABLE IF NOT EXISTS `service_specifications` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `service_type` VARCHAR(50) NOT NULL,
        `service_id` INT NOT NULL,
        `label` VARCHAR(255) NOT NULL,
        `value` VARCHAR(255) NOT NULL,
        `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        INDEX (`service_type`, `service_id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";
    
    $db->exec($query);
    
    echo "✅ Table created successfully!";
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage();
}
