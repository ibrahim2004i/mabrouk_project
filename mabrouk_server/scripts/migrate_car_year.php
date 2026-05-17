<?php
require_once __DIR__ . '/../src/Core/Database.php';
use App\Core\Database;

try {
    $db = Database::getInstance()->getConnection();
    
    echo "Adding 'year' column to srv_cars table... ";
    
    // Check if column exists first
    $check = $db->query("SHOW COLUMNS FROM `srv_cars` LIKE 'year'");
    if ($check->rowCount() == 0) {
        $db->exec("ALTER TABLE `srv_cars` ADD COLUMN `year` INT DEFAULT NULL AFTER `color` ");
        echo "✅ Column added successfully!";
    } else {
        echo "⚠️ Column already exists.";
    }
    
    echo "<br>✅ Migration completed.";
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage();
}
