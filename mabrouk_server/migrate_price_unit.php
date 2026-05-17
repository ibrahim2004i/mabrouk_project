<?php
// 🏗️ MIGRATION: ADD PRICE_UNIT TO SERVICES
require_once __DIR__ . '/src/Core/Database.php';
use App\Core\Database;

try {
    $db = Database::getInstance()->getConnection();
    
    $tables = [
        'srv_wedding_halls', 'srv_chalets', 'srv_dresses', 'srv_suits', 
        'srv_cars', 'srv_cakes', 'srv_photographers', 'srv_others'
    ];

    foreach ($tables as $table) {
        try {
            $db->exec("ALTER TABLE `$table` ADD COLUMN `price_unit` ENUM('hour', 'day', 'event') DEFAULT 'event' AFTER `status` ");
            echo "✅ Added price_unit to $table<br>";
        } catch (Exception $e) {
            echo "⚠️ $table already has price_unit or error: " . $e->getMessage() . "<br>";
        }
    }

    // Set defaults for specific categories
    $db->exec("UPDATE srv_photographers SET price_unit = 'hour'");
    $db->exec("UPDATE srv_wedding_halls SET price_unit = 'event'");
    $db->exec("UPDATE srv_chalets SET price_unit = 'day'");
    $db->exec("UPDATE srv_cars SET price_unit = 'day'");
    
    echo "🏁 Migration finished successfully.";
} catch (Exception $e) {
    echo "❌ Migration failed: " . $e->getMessage();
}
