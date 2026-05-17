<?php
namespace App\Controllers;

use App\Core\Request;
use App\Core\Response;
use App\Repositories\NotificationRepository;
use Exception;

class NotificationController {
    private $notificationRepo;

    public function __construct() {
        $this->notificationRepo = new NotificationRepository();
    }

    /**
     * 📜 List User Notifications
     */
    public function index() {
        $user_id = $_SESSION['user_id'] ?? null;
        if (!$user_id) Response::error("Unauthorized", 401);

        try {
            $notifications = $this->notificationRepo->getByUser($user_id);
            Response::success("Fetched successfully", $notifications);
        } catch (Exception $e) {
            Response::error($e->getMessage(), 500);
        }
    }

    /**
     * ✅ Mark as Read
     */
    public function markRead() {
        $user_id = $_SESSION['user_id'] ?? null;
        if (!$user_id) Response::error("Unauthorized", 401);

        $data = Request::getBody();
        $id = $data['id'] ?? null;

        try {
            if ($id) {
                $this->notificationRepo->markAsRead($id, $user_id);
            } else {
                $this->notificationRepo->markAllAsRead($user_id);
            }
            Response::success("Updated successfully");
        } catch (Exception $e) {
            Response::error($e->getMessage(), 500);
        }
    }
}
