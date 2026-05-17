<?php
// 📂 Favorite Repository
// Manages user wishlists in the database.

namespace App\Repositories;

use App\Core\Database;
use PDO;

class FavoriteRepository {
    private $db;

    public function __construct() {
        $this->db = Database::getInstance()->getConnection();
    }

    /**
     * ❤️ Toggle Favorite
     * Adds if it doesn't exist, removes if it does.
     */
    public function toggle($userId, $type, $id) {
        // Check if exists
        $stmt = $this->db->prepare("SELECT id FROM favorites WHERE user_id = ? AND service_type = ? AND service_id = ?");
        $stmt->execute([$userId, $type, $id]);
        $exists = $stmt->fetch();

        if ($exists) {
            $stmt = $this->db->prepare("DELETE FROM favorites WHERE id = ?");
            $stmt->execute([$exists['id']]);
            return ['status' => 'removed'];
        } else {
            $stmt = $this->db->prepare("INSERT INTO favorites (user_id, service_type, service_id) VALUES (?, ?, ?)");
            $stmt->execute([$userId, $type, $id]);
            return ['status' => 'added'];
        }
    }

    /**
     * 📜 Find All by User
     * Returns a list of composite keys like "type_id" for easy frontend matching.
     */
    public function findAllByUser($userId) {
        $stmt = $this->db->prepare("SELECT service_type, service_id FROM favorites WHERE user_id = ?");
        $stmt->execute([$userId]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        return array_map(function($row) {
            return $row['service_type'] . '_' . $row['service_id'];
        }, $rows);
    }
}
