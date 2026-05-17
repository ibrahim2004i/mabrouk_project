<?php
// 👨‍🌾 Database Seeder Script
// Populates the database with professional dummy data for testing.

require_once __DIR__ . '/../src/Core/Database.php';

use App\Core\Database;

try {
    $db = Database::getInstance()->getConnection();
    echo "🌱 Starting database seeding...\n";

    // 0. Clear old data (Foreign Key checks must be disabled first)
    $db->exec("SET FOREIGN_KEY_CHECKS = 0;");
    $db->exec("TRUNCATE TABLE bookings;");
    $db->exec("TRUNCATE TABLE srv_wedding_halls;");
    $db->exec("TRUNCATE TABLE srv_chalets;");
    $db->exec("TRUNCATE TABLE srv_dresses;");
    $db->exec("TRUNCATE TABLE srv_suits;");
    $db->exec("TRUNCATE TABLE srv_cars;");
    $db->exec("TRUNCATE TABLE srv_cakes;");
    $db->exec("TRUNCATE TABLE srv_photographers;");
    $db->exec("TRUNCATE TABLE service_providers;");
    $db->exec("TRUNCATE TABLE customers;");
    $db->exec("TRUNCATE TABLE admins;");
    $db->exec("TRUNCATE TABLE users;");
    $db->exec("SET FOREIGN_KEY_CHECKS = 1;");
    echo "🧹 Database cleared.\n";

    // 1. Create Admins
    $admin_pass = password_hash('admin123', PASSWORD_BCRYPT);
    $db->prepare("INSERT INTO users (phone_number, password_hash, role) VALUES (?, ?, 'admin')")
       ->execute(['0700000001', $admin_pass]);
    $admin_id = $db->lastInsertId();
    $db->prepare("INSERT INTO admins (user_id, nickname) VALUES (?, 'Super Admin')")
       ->execute([$admin_id]);

    // 2. Create Providers
    $prov_pass = password_hash('prov123', PASSWORD_BCRYPT);
    $providers = [
        ['0791111111', 'Royal Wedding Halls', 'Amman'],
        ['0792222222', 'Elegance Dresses', 'Zarqa'],
        ['0793333333', 'Fast Cars Rental', 'Irbid']
    ];

    $provider_ids = [];
    foreach ($providers as $p) {
        $db->prepare("INSERT INTO users (phone_number, password_hash, role) VALUES (?, ?, 'provider')")
           ->execute([$p[0], $prov_pass]);
        $uid = $db->lastInsertId();
        $db->prepare("INSERT INTO service_providers (user_id, brand_name, city_id) VALUES (?, ?, 1)") // Assuming city_id 1 is Amman/Default
           ->execute([$uid, $p[1]]);
        $provider_ids[] = $uid;
    }

    // 3. Create Customers
    $cust_pass = password_hash('cust123', PASSWORD_BCRYPT);
    $db->prepare("INSERT INTO users (phone_number, password_hash, role) VALUES (?, ?, 'customer')")
       ->execute(['0780000001', $cust_pass]);
    $cust_id = $db->lastInsertId();
    $db->prepare("INSERT INTO customers (user_id, full_name) VALUES (?, 'Ahmad Ali')")
       ->execute([$cust_id]);

    // 4. Create Services (Approved)
    // Hall
    $db->prepare("INSERT INTO srv_wedding_halls (provider_id, name, base_price, max_capacity, hall_type, status) 
                  VALUES (?, 'Grand Ballroom', 1500, 500, 'indoor', 'approved')")
       ->execute([$provider_ids[0]]);

    // Dress
    $db->prepare("INSERT INTO srv_dresses (provider_id, title, price, sizes_available, business_mode, status) 
                  VALUES (?, 'White Diamond Dress', 300, 'S, M, L', 'rent', 'approved')")
       ->execute([$provider_ids[1]]);

    // Car
    $db->prepare("INSERT INTO srv_cars (provider_id, brand, model, price_per_day, color, status) 
                  VALUES (?, 'Mercedes', 'S-Class', 200, 'White', 'approved')")
       ->execute([$provider_ids[2]]);

    // 5. Create Pending Service (For Admin Review)
    $db->prepare("INSERT INTO srv_wedding_halls (provider_id, name, base_price, max_capacity, hall_type, status) 
                  VALUES (?, 'Sunrise Garden', 800, 200, 'outdoor', 'pending')")
       ->execute([$provider_ids[0]]);

    // 6. Create Rich Bookings for Analytics (Provider 0)
    $stmt = $db->prepare("INSERT INTO bookings (customer_id, provider_id, service_type, service_id, total_price, booking_date, status) VALUES (?, ?, ?, ?, ?, ?, ?)");
    
    // Monthly trend data
    for ($i = 5; $i >= 0; $i--) {
        $date = date('Y-m-d', strtotime("-$i month"));
        // Varying revenue and counts
        $count = $i + 2;
        for ($j = 0; $j < $count; $j++) {
            $status = ($j % 3 == 0) ? 'confirmed' : (($j % 3 == 1) ? 'completed' : 'pending');
            $price = 1000 + ($i * 100);
            $stmt->execute([$cust_id, $provider_ids[0], 'hall', 1, $price, $date, $status]);
        }
    }

    // Some cancelled bookings
    $stmt->execute([$cust_id, $provider_ids[0], 'hall', 1, 1500, date('Y-m-d', strtotime('-2 week')), 'cancelled']);
    $stmt->execute([$cust_id, $provider_ids[0], 'car', 1, 500, date('Y-m-d', strtotime('-1 week')), 'cancelled']);

    echo "✅ Seeding completed successfully!\n";
    echo "🔑 Test Credentials:\n";
    echo "- Admin: 0700000001 / admin123\n";
    echo "- Provider: 0791111111 / prov123\n";
    echo "- Customer: 0780000001 / cust123\n";

} catch (Exception $e) {
    echo "❌ Error during seeding: " . $e->getMessage() . "\n";
}
