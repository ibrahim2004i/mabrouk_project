<?php
// 📸 Media Repository
// Data access layer for the central media gallery.

namespace App\Repositories;

use App\Core\Database;
use PDO;

class MediaRepository {
    private $db;

    public function __construct() {
        $this->db = Database::getInstance()->getConnection();
    }

    public function create($data) {
        $columns = implode(", ", array_keys($data));
        $placeholders = implode(", ", array_fill(0, count($data), "?"));
        
        $stmt = $this->db->prepare("INSERT INTO media ($columns) VALUES ($placeholders)");
        $stmt->execute(array_values($data));
        return $this->db->lastInsertId();
    }

    public function getByService($type, $id) {
        $stmt = $this->db->prepare("SELECT * FROM media WHERE service_type = ? AND service_id = ?");
        $stmt->execute([$type, $id]);
        return $stmt->fetchAll();
    }

    public function delete($media_id) {
        $stmt = $this->db->prepare("DELETE FROM media WHERE id = ?");
        return $stmt->execute([$media_id]);
    }

    public function getById($id) {
        $stmt = $this->db->prepare("SELECT * FROM media WHERE id = ?");
        $stmt->execute([$id]);
        return $stmt->fetch();
    }
}
