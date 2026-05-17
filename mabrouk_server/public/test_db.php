<?php
require_once __DIR__ . '/../src/Core/Autoloader.php';
use App\Core\Database;
use App\Repositories\BookingRepository;

header('Content-Type: application/json');

try {
    $db = Database::getInstance()->getConnection();
    $repo = new BookingRepository();
    
    // محاولة إدخال حجز تجريبي (Test Booking)
    // ملاحظة: هذا يتطلب وجود مزود وخدمة في قاعدة البيانات، لذا سنقوم فقط بفحص الاتصال ووجود الجدول
    $stmt = $db->query("SHOW TABLES LIKE 'bookings'");
    $tableExists = $stmt->rowCount() > 0;
    
    if (!$tableExists) {
        echo json_encode(["status" => "error", "message" => "Table 'bookings' does not exist! Please run schema.sql"]);
        exit;
    }

    $columns = $db->query("DESCRIBE bookings")->fetchAll(PDO::FETCH_COLUMN);

    echo json_encode([
        "status" => "success",
        "message" => "Database is ready!",
        "table" => "bookings",
        "columns" => $columns
    ]);

} catch (Exception $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
