<?php
/**
 * 🚀 MABROUK MASTER SEEDER v2.0 (Polymorphic Contact Info Support)
 * This script clears and populates the database with a heavy dataset
 * tailored for testing the new per-service contact number features.
 */

require_once __DIR__ . '/src/Core/Database.php';
use App\Core\Database;

try {
    $db = Database::getInstance()->getConnection();
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "<h1>🌱 Mabrouk Database Reset & Seeding (v2.0)...</h1>";

    // 1. 🛡️ Disable Foreign Key Checks
    $db->exec("SET FOREIGN_KEY_CHECKS = 0");

    // 2. 🧹 Clean all tables
    $tables = [
        'media', 'bookings', 'complaints', 
        'srv_wedding_halls', 'srv_chalets', 'srv_dresses', 'srv_suits', 
        'srv_cars', 'srv_cakes', 'srv_photographers', 'srv_others',
        'customers', 'service_providers', 'admins', 'users',
        'cities', 'categories'
    ];

    foreach ($tables as $table) {
        $db->exec("DELETE FROM `$table` ");
        $db->exec("ALTER TABLE `$table` AUTO_INCREMENT = 1");
    }
    echo "✅ Tables Cleaned.<br>";

    // 2.5 🛠️ Sync Schema (Ensure provider status is correct)
    // FORCE-SYNC: Migrate legacy 'active' to 'approved' and fix ENUM
    try {
        // Step A: Convert any stuck legacy statuses
        $db->exec("UPDATE service_providers SET status = 'approved' WHERE status = 'active'");
        
        // Step B: Update the ENUM definition to support the new standard
        $db->exec("ALTER TABLE service_providers MODIFY COLUMN status ENUM('pending', 'approved', 'rejected', 'suspended') DEFAULT 'pending'");
        
        echo "✅ Database Schema Synchronized (Status ENUM Fixed).<br>";
    } catch (Exception $e) {
        echo "⚠️ Note: Schema sync might require manual attention or was already Fixed: " . $e->getMessage() . "<br>";
    }

    // 3. 🌍 Seed Cities
    $cities = [
        ['عمان', 'Amman'], ['إربد', 'Irbid'], ['الزرقاء', 'Zarqa'], 
        ['المفرق', 'Mafraq'], ['جرش', 'Jerash'], ['العقبة', 'Aqaba'], 
        ['البحر الميت', 'Dead Sea'], ['مادبا', 'Madaba']
    ];
    $cityStmt = $db->prepare("INSERT INTO cities (name_ar, name_en) VALUES (?, ?)");
    foreach ($cities as $c) $cityStmt->execute($c);

    // 4. 🏷️ Seed Categories
    $categories = [
        ['قاعات', 'Halls', 'business'], ['شاليهات', 'Chalets', 'holiday_village'],
        ['فساتين', 'Dresses', 'checkroom'], ['بدلات', 'Suits', 'accessibility_new'],
        ['مصورين', 'Photographers', 'camera_alt'], ['حلويات', 'Cakes', 'cake'],
        ['سيارات', 'Cars', 'directions_car'], ['أخرى', 'Others', 'more_horiz']
    ];
    $catStmt = $db->prepare("INSERT INTO categories (name_ar, name_en, icon_key) VALUES (?, ?, ?)");
    foreach ($categories as $cat) $catStmt->execute($cat);


    $password = password_hash('oopi2004', PASSWORD_BCRYPT);
    $userPassword = password_hash('password123', PASSWORD_BCRYPT);

$users = [
    [1, '0788596344', 'admin@mabrouk.com', $password, 'admin'],
    [2, '0791111111', 'approved_provider@mabrouk.com', $userPassword, 'provider'],
    [3, '0792222222', 'general_provider@mabrouk.com', $userPassword, 'provider'],
    [4, '0785555555', 'customer1@gmail.com', $userPassword, 'customer'],
    [5, '0770000000', 'pending_provider@mabrouk.com', $userPassword, 'provider'],
    [6, '0799999999', 'rejected_provider@mabrouk.com', $userPassword, 'provider']
];
    $userStmt = $db->prepare("INSERT INTO users (id, phone_number, email, password_hash, role) VALUES (?, ?, ?, ?, ?)");
    foreach ($users as $u) $userStmt->execute($u);

    $db->exec("INSERT INTO admins (user_id, nickname) VALUES (1, 'Super Admin')");
    $db->exec("INSERT INTO service_providers (user_id, brand_name, city_id, status, office_phone, whatsapp_number) VALUES 
        (2, 'مؤسسة القصور الملكية (مقبول)', 1, 'approved', '065005001', '0790000002'),
        (3, 'مركز مبروك الشامل (مقبول)', 1, 'approved', '065005002', '0790000003'),
        (5, 'مزود جديد للتجربة (قيد الانتظار)', 1, 'pending', '0770000001', '0770000002'),
        (6, 'مزود مرفوض (محظور)', 1, 'rejected', '0799999991', '0799999992')");

    $db->exec("INSERT INTO customers (user_id, full_name, preferred_city_id) VALUES (4, 'أحمد العالي', 1)");

    // 6. 🏰 Seed Services with Dedicated Contact Info
    
    // 🏛️ Halls
    $db->exec("INSERT INTO srv_wedding_halls (provider_id, name, base_price, city_id, status, offering_type, description, office_phone, whatsapp_number, max_capacity, hall_type) VALUES 
        (2, 'قاعة الكريستال الملكية', 1500, 1, 'approved', 'booking', 'قاعة فاخرة جداً تتسع لـ 500 شخص.', '0795551111', '0795552222', 500, 'indoor'),
        (2, 'قاعة الجوهرة (قيد المراجعة)', 1000, 1, 'pending', 'booking', 'قاعة عصرية للمناسبات المتوسطة.', '0795553333', '0795554444', 300, 'indoor')");

    // 🏰 Chalets
    $db->exec("INSERT INTO srv_chalets (provider_id, name, price_per_night, city_id, status, offering_type, description, office_phone, whatsapp_number, rooms_count, has_pool) VALUES 
        (3, 'شاليه النسيم الهادئ', 250, 7, 'approved', 'booking', 'شاليه بخصوصية تامة ومسبح مدفأ.', '0781112222', '0781113333', 4, 1),
        (3, 'شاليه البحر الميت الفاخر', 400, 7, 'approved', 'booking', 'إإطلالة مباشرة على البحر.', '0782223333', '0782224444', 6, 1)");

    // 👔 Clothes (Dresses & Suits)
    $db->exec("INSERT INTO srv_dresses (provider_id, title, price, city_id, status, offering_type, description, office_phone, whatsapp_number, sizes_available, business_mode) VALUES 
        (3, 'فستان زفاف ملكي (للبيع)', 1200, 1, 'approved', 'purchase', 'تصميم إيطالي فاخر.', '0790001111', '0790002222', 'S, M, L', 'sale'),
        (3, 'فستان خطوبة أحمر', 300, 1, 'approved', 'booking', 'إإيجار لمدة ليلة واحدة.', '0790001111', '0790002222', 'M, L', 'rent')");

    $db->exec("INSERT INTO srv_suits (provider_id, title, price, city_id, status, offering_type, description, office_phone, whatsapp_number, sizes_available) VALUES 
        (3, 'بدلة رسمية سوداء', 150, 1, 'approved', 'purchase', 'قماش فاخر أصلي.', '0790003333', '0790004444', '48, 50, 52')");

    // 🚗 Cars
    $db->exec("INSERT INTO srv_cars (provider_id, brand, model, price_per_day, city_id, status, offering_type, description, office_phone, whatsapp_number, with_driver) VALUES 
        (3, 'مرسيدس S-Class', '2023', 250, 1, 'approved', 'booking', 'سيارة فارهة مع سائق.', '0778889999', '0778880000', 1)");

    // 🎂 Cakes
    $db->exec("INSERT INTO srv_cakes (provider_id, name, base_price, city_id, status, offering_type, description, office_phone, whatsapp_number, preparation_days) VALUES 
        (3, 'كيكة زفاف 5 طبقات', 450, 1, 'approved', 'purchase', 'حشوات متنوعة وشيكولاتة فاخرة.', '0791114444', '0791115555', 5)");

    // 📸 Photographers
    $db->exec("INSERT INTO srv_photographers (provider_id, package_name, base_price, city_id, status, offering_type, package_details, office_phone, whatsapp_number) VALUES 
        (3, 'باكيج التصوير الفضي', 200, 1, 'approved', 'booking', 'تصوير فوتوغرافي وفيديو 4 ساعات مع البوم.', '0792225555', '0792226666')");

    // ✨ Others
    $db->exec("INSERT INTO srv_others (provider_id, title, base_price, city_id, status, offering_type, description, type_name, office_phone, whatsapp_number) VALUES 
        (3, 'تنسيق بالونات فخم', 80, 1, 'approved', 'purchase', 'تنسيق متكامل لمداخل القاعات.', 'زينة', '0793337777', '0793338888')");

    echo "✅ Services Seeded with Per-Item Contact Info.<br>";

    // 7. ⭐ Seed Reviews
    $db->exec("INSERT INTO reviews (customer_id, provider_id, service_type, service_id, rating, comment) VALUES 
        (4, 2, 'hall', 1, 5, 'قاعة رائعة جداً والتنسيق كان ممتاز!'),
        (4, 3, 'cake', 1, 4, 'الكيكة لذيذة جداً ولكن التوصيل تأخر قليلاً')");

    echo "✅ Reviews Seeded.<br>";

    // 8. 🛡️ Enable Foreign Key Checks
    $db->exec("SET FOREIGN_KEY_CHECKS = 1");

    echo "<h2>🎉 Database Re-Seeded Successfully!</h2>";
    echo "<p><b>Test Login:</b> 0785555555 / password123 (Customer)</p>";
    echo "<p><b>Test Login:</b> 0791111111 / password123 (Hall Provider)</p>";

} catch (Exception $e) {
    if (isset($db)) $db->exec("SET FOREIGN_KEY_CHECKS = 1");
    echo "<h2 style='color: red;'>❌ Error: " . $e->getMessage() . "</h2>";
}
