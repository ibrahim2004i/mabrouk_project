<?php
require_once __DIR__ . '/../src/Core/Database.php';
use App\Core\Database;

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();

    // 1. Add name column if it doesn't exist
    $checkColumn = $conn->query("SHOW COLUMNS FROM srv_cars LIKE 'name'");
    if ($checkColumn->rowCount() == 0) {
        $conn->exec("ALTER TABLE srv_cars ADD COLUMN name VARCHAR(255) AFTER provider_id");
        echo "Successfully added 'name' column to srv_cars table.\n";
    } else {
        echo "'name' column already exists in srv_cars table.\n";
    }

    // 2. Populate name with current brand values where name is NULL
    $conn->exec("UPDATE srv_cars SET name = brand WHERE name IS NULL");
    echo "Successfully migrated existing brand values to name column.\n";

} catch (PDOException $e) {
    echo "Migration failed: " . $e->getMessage() . "\n";
}
?>
