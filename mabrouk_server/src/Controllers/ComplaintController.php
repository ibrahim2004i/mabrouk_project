<?php
// 📥 Complaint Controller
// Submit complaints via API.

namespace App\Controllers;

use App\Core\Request;
use App\Core\Response;
use App\Core\Database;
use App\Repositories\UserRepository;
use App\Repositories\NotificationRepository;
use Exception;

class ComplaintController {
    private $db;
    private $userRepo;
    private $notificationRepo;

    public function __construct() {
        $this->db = Database::getInstance()->getConnection();
        $this->userRepo = new UserRepository();
        $this->notificationRepo = new NotificationRepository();
    }

    /**
     * Submit a new complaint.
     * POST /api/complaints
     */
    public function store() {
        $user_id = $_SESSION['user_id'] ?? null;
        if (!$user_id) Response::error("Unauthorized", 401);

        $data = Request::getBody();
        $provider_id = $data['provider_id'] ?? null;
        $subject = $data['subject'] ?? null;
        $description = $data['description'] ?? null;
        $booking_id = $data['booking_id'] ?? null;

        if (!$provider_id || !$subject || !$description) {
            Response::error("Missing required fields (provider_id, subject, description)", 400);
        }

        try {
            $stmt = $this->db->prepare("INSERT INTO complaints (user_id, provider_id, booking_id, subject, description) VALUES (?, ?, ?, ?, ?)");
            $stmt->execute([$user_id, $provider_id, $booking_id, $subject, $description]);

            // 🔔 Notify Admins
            $admins = $this->userRepo->getAdminIds();
            foreach ($admins as $adminId) {
                $this->notificationRepo->create(
                    $adminId, 
                    "شكوى جديدة", 
                    "قام مستخدم بتقديم شكوى جديدة بخصوص مزود خدمة.", 
                    "system_alert"
                );
            }

            Response::success("Complaint submitted successfully");
        } catch (Exception $e) {
            Response::error($e->getMessage(), 500);
        }
    }
}
