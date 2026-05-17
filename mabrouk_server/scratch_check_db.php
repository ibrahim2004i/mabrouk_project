<?php
require_once __DIR__ . '/src/Core/Database.php';
$db = \App\Core\Database::getInstance()->getConnection();
$stmt = $db->query("SELECT * FROM bookings");
echo "Bookings count: " . $stmt->rowCount() . "\n";
print_r($stmt->fetchAll(\PDO::FETCH_ASSOC));
