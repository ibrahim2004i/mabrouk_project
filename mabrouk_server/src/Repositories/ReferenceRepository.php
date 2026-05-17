<?php
// 🗺️ Reference Repository
// Handles data access for cities, categories, and other static lookups.

namespace App\Repositories;

use App\Core\Database;
use PDO;

class ReferenceRepository {
    private $db;

    public function __construct() {
        $this->db = Database::getInstance()->getConnection();
    }

    /**
     * Get all registered cities.
     */
    public function getAllCities() {
        $stmt = $this->db->prepare("SELECT * FROM cities ORDER BY name_ar ASC");
        $stmt->execute();
        return $stmt->fetchAll();
    }

    /**
     * Get all service categories.
     */
    public function getAllCategories() {
        $stmt = $this->db->prepare("SELECT * FROM categories ORDER BY id ASC");
        $stmt->execute();
        return $stmt->fetchAll();
    }
}
