<?php
// 🛠️ One-time Admin Setup Script
require_once __DIR__ . '/../src/Core/Autoloader.php';

use App\Core\Database;
use App\Core\Response;

try {
    $db = Database::getInstance()->getConnection();
    
    $phone = '0788595344';
    $email = 'admin@mabrouk.com';
    $password = 'oopi2004';
    $role = 'admin';
    
    // Check if exists
    $stmt = $db->prepare("SELECT id FROM users WHERE phone_number = ?");
    $stmt->execute([$phone]);
    if ($stmt->fetch()) {
        die("❌ Admin already exists!");
    }
    
    $hash = password_hash($password, PASSWORD_BCRYPT);
    
    $stmt = $db->prepare("INSERT INTO users (phone_number, email, password_hash, role, is_active) VALUES (?, ?, ?, ?, 1)");
    $stmt->execute([$phone, $email, $hash, $role]);
    
    echo "<h2>✅ Admin Created Successfully!</h2>";
    echo "<p>Phone: $phone</p>";
    echo "<p>Password: $password</p>";
    echo "<p><b>Security Note:</b> Please delete this file (setup_admin.php) from your project and re-deploy for security.</p>";

} catch (Exception $e) {
    echo "<h2>❌ Error</h2>";
    echo "<p>" . $e->getMessage() . "</p>";
}
