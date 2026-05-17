<?php
require_once 'src/Core/Database.php';
use App\Core\Database;

try {
    $db = Database::getInstance()->getConnection();
    $sql = "ALTER TABLE bookings ADD COLUMN manual_customer_name VARCHAR(255) NULL AFTER customer_id";
    $db->exec($sql);
    echo "Migration Success: manual_customer_name added to bookings table.\n";
} catch (Exception $e) {
    echo "Migration Error or Column Already Exists: " . $e->getMessage() . "\n";
}
