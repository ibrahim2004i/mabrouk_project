<?php
require_once 'src/Core/Database.php';
use App\Core\Database;

try {
    $db = Database::getInstance()->getConnection();
    $sql = file_get_contents('database/add_custom_service_table.sql');
    $db->exec($sql);
    echo "Migration Success: srv_others table created.\n";

    $sqlComplaints = file_get_contents('database/add_complaints_table.sql');
    $db->exec($sqlComplaints);
    echo "Migration Success: complaints table created.\n";

} catch (Exception $e) {
    echo "Migration Error: " . $e->getMessage() . "\n";
}
