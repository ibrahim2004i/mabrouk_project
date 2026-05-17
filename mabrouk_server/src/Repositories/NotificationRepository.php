<?php
namespace App\Repositories;

use App\Core\Database;
use PDO;

class NotificationRepository {
    private $db;

    public function __construct() {
        $this->db = Database::getInstance()->getConnection();
    }

    /**
     * 🔔 Create a new notification
     */
    public function create($userId, $title, $message, $type) {
        $stmt = $this->db->prepare("INSERT INTO notifications (user_id, title, message, type) VALUES (?, ?, ?, ?)");
        return $stmt->execute([$userId, $title, $message, $type]);
    }

    /**
     * 📜 Get user notifications with Auto-Cleanup
     */
    public function getByUser($userId) {
        // 🧹 Auto-Cleanup: Delete notifications older than 30 days
        $this->cleanup();

        $stmt = $this->db->prepare("SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT 50");
        $stmt->execute([$userId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * ✅ Mark notification as read
     */
    public function markAsRead($id, $userId) {
        $stmt = $this->db->prepare("UPDATE notifications SET is_read = 1 WHERE id = ? AND user_id = ?");
        return $stmt->execute([$id, $userId]);
    }

    /**
     * 🗑️ Mark all as read
     */
    public function markAllAsRead($userId) {
        $stmt = $this->db->prepare("UPDATE notifications SET is_read = 1 WHERE user_id = ?");
        return $stmt->execute([$userId]);
    }

    /**
     * 🧼 Internal Cleanup Logic
     */
    private function cleanup() {
        $stmt = $this->db->prepare("DELETE FROM notifications WHERE created_at < DATE_SUB(NOW(), INTERVAL 30 DAY)");
        $stmt->execute();
    }
}
