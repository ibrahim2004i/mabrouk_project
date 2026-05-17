<?php
// ⭐ Review Controller (V2 - Direct Reviews)
// Handling the lifecycle of service feedback and provider moderation.

namespace App\Controllers;

use App\Core\Request;
use App\Core\Response;
use App\Repositories\ReviewRepository;
use App\Repositories\BookingRepository;
use Exception;

class ReviewController {
    private $reviewRepo;
    private $bookingRepo;

    public function __construct() {
        $this->reviewRepo = new ReviewRepository();
        $this->bookingRepo = new BookingRepository();
    }

    /**
     * Customer API: Post a review for a service (Direct or Booking-Linked).
     */
    public function store() {
        $customer_id = $_SESSION['user_id'] ?? null;
        $data = Request::getBody();

        if (!$customer_id) Response::error("يجب تسجيل الدخول لإضافة تقييم.", 401);
        if (!isset($data['rating'])) {
            Response::error("التقييم بالنجوم مطلوب.", 400);
        }

        try {
            $reviewData = [
                'customer_id' => $customer_id,
                'rating' => $data['rating'],
                'comment' => $data['comment'] ?? '',
                'booking_id' => $data['booking_id'] ?? null,
            ];

            // 🛡️ Mode 1: Booking Linked (Higher Priority Data)
            if (isset($data['booking_id'])) {
                $booking = $this->bookingRepo->getById($data['booking_id']);
                if (!$booking || $booking['customer_id'] != $customer_id) {
                    Response::error("Invalid booking ID.", 403);
                }
                $reviewData['provider_id'] = $booking['provider_id'];
                $reviewData['service_type'] = $booking['service_type'];
                $reviewData['service_id'] = $booking['service_id'];
            } 
            // 🛡️ Mode 2: Direct Service Review
            else {
                if (!isset($data['provider_id']) || !isset($data['service_type']) || !isset($data['service_id'])) {
                    Response::error("معلومات الخدمة ناقصة.", 400);
                }
                $reviewData['provider_id'] = $data['provider_id'];
                $reviewData['service_type'] = $data['service_type'];
                $reviewData['service_id'] = $data['service_id'];
            }

            $id = $this->reviewRepo->create($reviewData);
            Response::success("شكراً لتقييمك! تم نشر التقييم بنجاح.", ["id" => $id], 201);
        } catch (Exception $e) {
            Response::error($e->getMessage(), 500);
        }
    }

    /**
     * Public API: Get reviews for a specific service.
     */
    public function index($type, $id) {
        try {
            $reviews = $this->reviewRepo->getServiceReviews($type, $id);
            Response::success("Service reviews fetched", $reviews);
        } catch (Exception $e) {
            Response::error($e->getMessage(), 500);
        }
    }

    /**
     * Provider/Admin API: Delete a review.
     */
    public function destroy($id) {
        $user_id = $_SESSION['user_id'] ?? null;
        $role = $_SESSION['role'] ?? null;

        if (!$user_id) Response::error("Unauthorized", 401);

        try {
            $review = $this->reviewRepo->getById($id);
            if (!$review) Response::error("Review not found", 404);

            // 🛡️ Authorization Check
            $isOwner = ($role === 'provider' && $review['provider_id'] == $user_id);
            $isAdmin = ($role === 'admin');

            if (!$isOwner && !$isAdmin) {
                Response::error("لا تملك الصلاحية لحذف هذا التقييم.", 403);
            }

            $success = $this->reviewRepo->delete($id);
            if ($success) {
                Response::success("تم حذف التقييم بنجاح.");
            } else {
                Response::error("Failed to delete review", 500);
            }
        } catch (Exception $e) {
            Response::error($e->getMessage(), 500);
        }
    }
}
