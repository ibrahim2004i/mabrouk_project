<?php
// 🚀 Migration Script: Reviews Table
// Run: php run_reviews_migration.php

require_once __DIR__ . '/src/Core/Autoloader.php';
use App\Core\Database;

try {
    $db = Database::getInstance()->getConnection();
    
    $sqlPath = __DIR__ . '/database/add_reviews_table.sql';
    if (!file_exists($sqlPath)) {
        die("❌ SQL file not found at: $sqlPath\n");
    }

    $sql = file_get_contents($sqlPath);
    
    echo "🏗️ Running migration: add_reviews_table.sql...\n";
    $db->exec($sql);
    echo "✅ SUCCESS: Reviews table created.\n";

} catch (Exception $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
}
