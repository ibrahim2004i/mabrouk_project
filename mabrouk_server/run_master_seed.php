<?php
/**
 * 🚀 Master Seed Data Runner
 * Populates the database with realistic demo data for all features.
 */

require_once __DIR__ . '/src/Core/Database.php';

use App\Core\Database;

try {
    $db = Database::getInstance()->getConnection();
    
    echo "<h1>🌱 Running Master Seed Data...</h1>";
    
    $sqlFile = __DIR__ . '/database/master_seed_data.sql';
    if (!file_exists($sqlFile)) {
        throw new Exception("SQL file not found at: $sqlFile");
    }

    $sql = file_get_contents($sqlFile);
    
    // Split by semicolon but ignore inside quotes
    $queries = preg_split("/;(?=(?:[^\']|\'[^\']*\')*$)/", $sql);

    foreach ($queries as $query) {
        $query = trim($query);
        if (!empty($query)) {
            $db->exec($query);
            echo "<p style='color: blue;'>⚙️ Seeding: " . substr($query, 0, 40) . "...</p>";
        }
    }

    echo "<h2>🎉 Seeding Completed Successfully!</h2>";
    echo "<p>Your database is now populated with providers, services, and customers.</p>";
    echo "<p><b>Credentials:</b> All accounts use 'password123'</p>";
    echo "<a href='index.php'>Go to Dashboard</a>";

} catch (Exception $e) {
    echo "<h2 style='color: red;'>❌ Seeding Failed</h2>";
    echo "<p>Error: " . $e->getMessage() . "</p>";
}
