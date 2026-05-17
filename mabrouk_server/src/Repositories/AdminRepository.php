<?php
// 🛡️ Admin Repository
// Data access for provider management and complaints.

namespace App\Repositories;

use App\Core\Database;
use PDO;

class AdminRepository {
    private $db;

    public function __construct() {
        $this->db = Database::getInstance()->getConnection();
    }

    /**
     * List all providers with their basic stats.
     */
    public function getAllProviders() {
        $sql = "SELECT u.id, u.phone_number, sp.brand_name, sp.city_id, sp.status, u.created_at,
                       (SELECT COUNT(*) FROM srv_wedding_halls WHERE provider_id = u.id) +
                       (SELECT COUNT(*) FROM srv_chalets WHERE provider_id = u.id) +
                       (SELECT COUNT(*) FROM srv_cars WHERE provider_id = u.id) +
                       (SELECT COUNT(*) FROM srv_dresses WHERE provider_id = u.id) +
                       (SELECT COUNT(*) FROM srv_suits WHERE provider_id = u.id) +
                       (SELECT COUNT(*) FROM srv_photographers WHERE provider_id = u.id) +
                       (SELECT COUNT(*) FROM srv_cakes WHERE provider_id = u.id) +
                       (SELECT COUNT(*) FROM srv_others WHERE provider_id = u.id) as total_services,
                       (SELECT COUNT(*) FROM bookings WHERE provider_id = u.id AND status = 'pending') as pending_count,
                       (SELECT COUNT(*) FROM bookings WHERE provider_id = u.id AND status = 'confirmed' AND CONCAT(IFNULL(end_date, booking_date), ' ', IFNULL(end_time, booking_time)) >= NOW()) as confirmed_count,
                       (SELECT COUNT(*) FROM bookings WHERE provider_id = u.id AND (status = 'completed' OR (status = 'confirmed' AND CONCAT(IFNULL(end_date, booking_date), ' ', IFNULL(end_time, booking_time)) < NOW()))) as completed_count,
                       (SELECT COUNT(*) FROM bookings WHERE provider_id = u.id AND status = 'cancelled') as cancelled_count
                FROM users u
                JOIN service_providers sp ON u.id = sp.user_id
                WHERE u.role = 'provider' AND sp.status = 'approved'
                ORDER BY u.created_at DESC";
        
        $stmt = $this->db->query($sql);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Permanent deletion of a provider and all related data.
     * Foreign keys with ON DELETE CASCADE will handle services and bookings.
     */
    public function deleteProvider($provider_id) {
        $stmt = $this->db->prepare("DELETE FROM users WHERE id = ? AND role = 'provider'");
        return $stmt->execute([$provider_id]);
    }

    /**
     * List ONLY pending providers.
     */
    public function getPendingProviders() {
        $sql = "SELECT u.id, u.phone_number, sp.brand_name, sp.city_id, sp.status, u.created_at
                FROM users u
                JOIN service_providers sp ON u.id = sp.user_id
                WHERE u.role = 'provider' AND sp.status = 'pending'
                ORDER BY u.created_at ASC";
        
        $stmt = $this->db->query($sql);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * List all complaints.
     */
    public function getAllComplaints() {
        $sql = "SELECT c.*, u.phone_number as complainant_phone,
                       sp_u.phone_number as provider_phone, sp.brand_name as provider_name
                FROM complaints c
                JOIN users u ON c.user_id = u.id
                JOIN users sp_u ON c.provider_id = sp_u.id
                JOIN service_providers sp ON sp_u.id = sp.user_id
                ORDER BY c.created_at DESC";
        
        $stmt = $this->db->query($sql);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Resolve a complaint.
     */
    public function resolveComplaint($complaint_id, $notes = '') {
        $stmt = $this->db->prepare("UPDATE complaints SET status = 'resolved', admin_notes = ? WHERE id = ?");
        return $stmt->execute([$notes, $complaint_id]);
    }

    /**
     * Update a provider's approval status.
     */
    public function updateProviderStatus($provider_id, $status) {
        $stmt = $this->db->prepare("UPDATE service_providers SET status = ? WHERE user_id = ?");
        return $stmt->execute([$status, $provider_id]);
    }
}
