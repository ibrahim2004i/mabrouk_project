<?php
// 👤 User Repository
// Data access layer for User, Customer, and Provider model.

namespace App\Repositories;

use App\Core\Database;
use PDO;

class UserRepository {
    private $db;

    public function __construct() {
        $this->db = Database::getInstance()->getConnection();
    }

    public function findByPhone($phone) {
        $stmt = $this->db->prepare("SELECT * FROM users WHERE phone_number = ?");
        $stmt->execute([$phone]);
        return $stmt->fetch();
    }

    public function createBaseUser($phone, $password, $role) {
        $stmt = $this->db->prepare("INSERT INTO users (phone_number, password_hash, role) VALUES (?, ?, ?)");
        $password_hash = password_hash($password, PASSWORD_BCRYPT);
        $stmt->execute([$phone, $password_hash, $role]);
        return $this->db->lastInsertId();
    }

    public function createCustomer($user_id, $full_name) {
        $stmt = $this->db->prepare("INSERT INTO customers (user_id, full_name) VALUES (?, ?)");
        $stmt->execute([$user_id, $full_name]);
    }

    public function createProvider($user_id, $brand_name, $city_id, $status = 'pending') {
        $stmt = $this->db->prepare("INSERT INTO service_providers (user_id, brand_name, city_id, status) VALUES (?, ?, ?, ?)");
        $stmt->execute([$user_id, $brand_name, $city_id, $status]);
    }

    public function getCustomerProfile($user_id) {
        $stmt = $this->db->prepare("SELECT u.id, u.phone_number, u.role, c.full_name, c.profile_image, c.gender, c.preferred_city_id 
                                  FROM users u JOIN customers c ON u.id = c.user_id WHERE u.id = ?");
        $stmt->execute([$user_id]);
        return $stmt->fetch();
    }

    public function getProviderProfile($user_id) {
        $stmt = $this->db->prepare("SELECT u.id, u.phone_number, u.role, sp.brand_name, sp.logo_url, sp.city_id, sp.is_verified, sp.status, sp.legal_name, sp.office_phone, sp.whatsapp_number, sp.address_details, sp.bio_description 
                                  FROM users u JOIN service_providers sp ON u.id = sp.user_id WHERE u.id = ?");
        $stmt->execute([$user_id]);
        return $stmt->fetch();
    }

    public function isPhoneTaken($phone, $excludeUserId = null) {
        $sql = "SELECT id FROM users WHERE phone_number = ?";
        $params = [$phone];
        if ($excludeUserId) {
            $sql .= " AND id != ?";
            $params[] = $excludeUserId;
        }
        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetch() !== false;
    }

    public function updatePhone($userId, $newPhone) {
        $stmt = $this->db->prepare("UPDATE users SET phone_number = ? WHERE id = ?");
        $stmt->execute([$newPhone, $userId]);
    }

    public function updateCustomer($userId, $data) {
        $stmt = $this->db->prepare("UPDATE customers SET full_name = ?, gender = ?, preferred_city_id = ? WHERE user_id = ?");
        $stmt->execute([
            $data['full_name'],
            $data['gender'] ?? null,
            $data['city_id'] ?? null,
            $userId
        ]);
    }

    public function updateProvider($userId, $data) {
        $stmt = $this->db->prepare("UPDATE service_providers SET brand_name = ?, legal_name = ?, office_phone = ?, whatsapp_number = ?, city_id = ?, address_details = ?, bio_description = ? WHERE user_id = ?");
        $stmt->execute([
            $data['brand_name'],
            $data['legal_name'] ?? null,
            $data['office_phone'] ?? null,
            $data['whatsapp_number'] ?? null,
            $data['city_id'],
            $data['address_details'] ?? null,
            $data['bio_description'] ?? null,
            $userId
        ]);
    }

    /**
     * Get IDs of all administrators.
     */
    public function getAdminIds() {
        $stmt = $this->db->query("SELECT id FROM users WHERE role = 'admin'");
        return $stmt->fetchAll(PDO::FETCH_COLUMN);
    }
}

