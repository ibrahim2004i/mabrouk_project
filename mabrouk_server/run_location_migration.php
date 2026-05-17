<?php
/**
 * 🚀 Database Migration Runner - Location & Cities
 * Runs the SQL script to add location fields and seed Jordanian cities.
 */

require_once __DIR__ . '/src/Core/Database.php';

use App\Core\Database;

try {
    $db = Database::getInstance()->getConnection();
    
    echo "<h1>📍 Running Location Migration...</h1>";
    
    $sqlFile = __DIR__ . '/database/add_location_fields.sql';
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
            echo "<p style='color: green;'>✅ Executed: " . substr($query, 0, 50) . "...</p>";
        }
    }

    echo "<h2>🎉 Migration Completed Successfully!</h2>";
    echo "<p>Cities have been seeded and location fields added to all services.</p>";
    echo "<a href='index.php'>Back to Home</a>";

} catch (Exception $e) {
    echo "<h2 style='color: red;'>❌ Migration Failed</h2>";
    echo "<p>Error: " . $e->getMessage() . "</p>";
}
