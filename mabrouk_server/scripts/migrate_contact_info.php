<?php
require_once __DIR__ . '/../src/Core/Database.php';
use App\Core\Database;

try {
    $db = Database::getInstance()->getConnection();
    
    $tables = [
        'srv_wedding_halls', 'srv_chalets', 'srv_dresses', 'srv_suits', 
        'srv_cars', 'srv_cakes', 'srv_photographers', 'srv_others'
    ];

    foreach ($tables as $table) {
        echo "Updating $table... ";
        try {
            $db->exec("ALTER TABLE `$table` ADD COLUMN `office_phone` VARCHAR(20) NULL AFTER `location_address` ");
            echo "Added office_phone. ";
        } catch (Exception $e) {
            echo "office_phone skip (exists?). ";
        }

        try {
            $db->exec("ALTER TABLE `$table` ADD COLUMN `whatsapp_number` VARCHAR(20) NULL AFTER `office_phone` ");
            echo "Added whatsapp_number. ";
        } catch (Exception $e) {
            echo "whatsapp_number skip (exists?). ";
        }
        echo "<br>";
    }

    echo "✅ Migration completed successfully!";
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage();
}
