<?php
// ⭐ Review Repository
// Data access layer for client feedback and service ratings.

namespace App\Repositories;

use App\Core\Database;
use PDO;

class ReviewRepository {
    private $db;

    public function __construct() {
        $this->db = Database::getInstance()->getConnection();
    }

    /**
     * Create a new review and link it to a booking.
     */
    public function create($data) {
        $columns = implode(", ", array_keys($data));
        $placeholders = implode(", ", array_fill(0, count($data), "?"));
        
        $stmt = $this->db->prepare("INSERT INTO reviews ($columns) VALUES ($placeholders)");
        $stmt->execute(array_values($data));
        $review_id = $this->db->lastInsertId();

        // 🧠 Auto-recalculate Provider's average rating
        if (isset($data['provider_id'])) {
            $this->recalculateProviderRating($data['provider_id']);
        }

        return $review_id;
    }

    /**
     * Delete a review and refresh calculations.
     */
    public function delete($id) {
        // 1. Get Provider ID before deleting to recalculate
        $stmt = $this->db->prepare("SELECT provider_id FROM reviews WHERE id = ?");
        $stmt->execute([$id]);
        $row = $stmt->fetch();
        
        if ($row) {
            $provider_id = $row['provider_id'];
            
            // 2. Delete the record
            $delStmt = $this->db->prepare("DELETE FROM reviews WHERE id = ?");
            $success = $delStmt->execute([$id]);

            // 3. Recalculate
            if ($success) $this->recalculateProviderRating($provider_id);
            return $success;
        }
        return false;
    }

    /**
     * Fetch all reviews for a specific service.
     */
    public function getServiceReviews($type, $id) {
        $stmt = $this->db->prepare("SELECT r.*, IFNULL(c.full_name, 'مستخدم مبروك') as customer_name, c.profile_image 
                                    FROM reviews r 
                                    LEFT JOIN customers c ON r.customer_id = c.user_id 
                                    WHERE r.service_type = ? AND r.service_id = ? 
                                    ORDER BY r.created_at DESC");
        $stmt->execute([$type, $id]);
        return $stmt->fetchAll();
    }

    /**
     * Identify a single review by its ID.
     */
    public function getById($id) {
        $stmt = $this->db->prepare("SELECT * FROM reviews WHERE id = ?");
        $stmt->execute([$id]);
        return $stmt->fetch();
    }

    /**
     * 🧠 The "Auto-Magic" Recalculator
     * Updates service_providers.overall_rating based on all associated reviews.
     */
    private function recalculateProviderRating($provider_id) {
        // Calculate average
        $stmt = $this->db->prepare("SELECT AVG(rating) as avg_score FROM reviews WHERE provider_id = ?");
        $stmt->execute([$provider_id]);
        $avg = $stmt->fetch()['avg_score'] ?? 0.00;

        // Update provider table
        $uptStmt = $this->db->prepare("UPDATE service_providers SET overall_rating = ? WHERE user_id = ?");
        $uptStmt->execute([$avg, $provider_id]);
    }
}
