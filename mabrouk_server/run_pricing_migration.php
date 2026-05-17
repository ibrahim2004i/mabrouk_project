<?php
// 🚀 Pricing Strategy Migration Runner
// Updates all service tables with new pricing columns.

require_once 'src/Core/Database.php';
use App\Core\Database;

try {
    $db = Database::getInstance()->getConnection();
    $sql = file_get_contents('database/add_pricing_strategy.sql');
    
    // Execute the SQL
    $db->exec($sql);
    
    echo "✅ Migration Success: Pricing strategy columns added to all tables.\n";
} catch (Exception $e) {
    echo "❌ Migration Error: " . $e->getMessage() . "\n";
}
