<?php
require_once 'src/Core/Database.php';
use App\Core\Database;

try {
    $db = Database::getInstance()->getConnection();
    $sql = file_get_contents('database/add_inventory_fields.sql');
    $db->exec($sql);
    echo "Migration Success: stock_count fields added to service tables.\n";
} catch (Exception $e) {
    echo "Migration Error: " . $e->getMessage() . "\n";
}
