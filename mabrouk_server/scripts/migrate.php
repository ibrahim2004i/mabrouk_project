<?php
// 🚀 Migration Script
// Executes pending SQL migrations.

require_once __DIR__ . '/../vendor/autoload.php';
use App\Core\Database;

try {
    $db = Database::getInstance()->getConnection();
    
    $sqlPath = __DIR__ . '/../database/add_complaints_table.sql';
    if (!file_exists($sqlPath)) {
        die("SQL file not found at: $sqlPath\n");
    }

    $sql = file_get_contents($sqlPath);
    
    echo "Running migration: add_complaints_table.sql...\n";
    $db->exec($sql);
    echo "SUCCESS: Complaints table created.\n";

} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
