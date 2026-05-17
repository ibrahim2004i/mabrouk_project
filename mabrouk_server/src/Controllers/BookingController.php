<?php
// 📅 Booking Controller
// Managing the lifecycle of service reservations.

namespace App\Controllers;

use App\Core\Request;
use App\Core\Response;
use App\Repositories\BookingRepository;
use App\Repositories\BaseServiceRepository;
use App\Repositories\NotificationRepository;
use Exception;

class BookingController {
    private $bookingRepo;
    private $serviceRepo;
    private $notificationRepo;

    public function __construct() {
        $this->bookingRepo = new BookingRepository();
        $this->serviceRepo = new BaseServiceRepository();
        $this->notificationRepo = new NotificationRepository();
    }

    /**
     * Customer API: Create a booking.
     */
    public function store() {
        $customer_id = $_SESSION['user_id'] ?? null;
        $role = $_SESSION['role'] ?? null;

        if (!$customer_id || $role !== 'customer') {
            Response::error("نعتذر، الحجز متاح للزبائن فقط. يرجى تسجيل الدخول كزبون.", 403);
        }

        $data = Request::getBody();
        
        // 🛡️ Security: Force the customer_id from the session token
        $data['customer_id'] = $customer_id;

        try {
            // 🧠 Fetch service info to check offering_type and price_unit
            $service = $this->serviceRepo->getById($data['service_type'], $data['service_id']);
            $offering_type = $service['offering_type'] ?? 'booking';
            
            // 🕒 Project-Wide Rule: Hourly Validation (Only for Bookings)
            if ($offering_type === 'booking' && isset($data['booking_time']) && isset($data['end_time'])) {
                if (strtotime($data['end_time']) <= strtotime($data['booking_time'])) {
                    Response::error("يجب أن يكون وقت النهاية بعد وقت البداية.", 400);
                }
            }

            // 🧠 Check for Overlaps ONLY for bookings
            if ($offering_type === 'booking') {
                $start = $data['booking_date'] . ' ' . $data['booking_time'];
                $end = ($data['end_date'] ?? $data['booking_date']) . ' ' . ($data['end_time'] ?? $data['booking_time']);
                
                $conflict = $this->bookingRepo->hasOverlap($data['service_type'], $data['service_id'], $start, $end);
                if ($conflict) {
                    Response::error("هذا الوقت محجوز مسبقاً.", 409, [
                        "conflict" => [
                            "start_date" => $conflict['booking_date'],
                            "start_time" => $conflict['booking_time'],
                            "end_date" => $conflict['end_date'] ?? $conflict['booking_date'],
                            "end_time" => $conflict['end_time'] ?? $conflict['booking_time'],
                        ]
                    ]);
                }
            } else {
                // 📦 Purchase Logic: Check Stock
                $stock = $service['stock_count'] ?? 0;
                if ($stock <= 0) {
                    Response::error("نعتذر، لقد نفدت الكمية من هذا المنتج.", 400);
                }
            }


            $id = $this->bookingRepo->create($data);

            // 📦 If it's a purchase, decrement stock
            if ($offering_type === 'purchase') {
                $this->serviceRepo->decrementStock($data['service_type'], $data['service_id']);
            }

            // 🔔 Notify Provider
            $this->notificationRepo->create(
                $data['provider_id'], 
                "حجز جديد!", 
                "لقد وصلك طلب حجز جديد لخدمتك. يرجى المراجعة والرد.", 
                'new_booking'
            );

            Response::success("تم إرسال طلب الحجز بنجاح", ["id" => $id], 201);
        } catch (Exception $e) {
            Response::error("خطأ في قاعدة البيانات: " . $e->getMessage(), 400);
        }
    }

    public function customerIndex() {
        $customer_id = $_SESSION['user_id'] ?? null;
        $bookings = $this->bookingRepo->getCustomerBookings($customer_id);
        Response::success("My bookings", $bookings);
    }

    public function providerIndex() {
        $provider_id = $_SESSION['user_id'] ?? null;
        $bookings = $this->bookingRepo->getProviderBookings($provider_id);
        Response::success("Provider bookings", $bookings);
    }

    public function serviceBookings($type, $id) {
        $bookings = $this->bookingRepo->getServiceBookings($type, $id);
        Response::success("Service bookings", $bookings);
    }

    public function updateStatus() {
        $provider_id = $_SESSION['user_id'] ?? null;
        $data = Request::getBody();
        $booking_id = $data['id'];
        $requestedStatus = $data['status'];

        try {
            $booking = $this->bookingRepo->getById($booking_id);
            if (!$booking) Response::error("Booking not found", 404);
            if ($booking['provider_id'] != $provider_id) Response::error("Unauthorized", 403);

            $finalStatus = $requestedStatus;
            
            // 🧠 Project-Wide Rule: Auto-Complete Purchases on Approval
            if ($requestedStatus === 'confirmed') {
                $service = $this->serviceRepo->getById($booking['service_type'], $booking['service_id']);
                if (($service['offering_type'] ?? 'booking') === 'purchase') {
                    $finalStatus = 'completed';
                }
            }

            $this->bookingRepo->updateStatus($booking_id, $finalStatus);

            // 🔔 Notify Customer
            if ($booking['customer_id']) {
                $statusAr = "مرفوض";
                if ($finalStatus == 'confirmed') $statusAr = "مؤكد";
                if ($finalStatus == 'completed') $statusAr = "مكتمل (تمت عملية البيع)";

                $this->notificationRepo->create(
                    $booking['customer_id'],
                    "تحديث حالة الطلب",
                    "لقد تم تغيير حالة طلبك لـ {$booking['service_type']} إلى: $statusAr",
                    'status_change'
                );
            }

            Response::success("Status updated to $finalStatus");
        } catch (Exception $e) {
            Response::error($e->getMessage(), 500);
        }
    }

    public function reschedule() {
        $provider_id = $_SESSION['user_id'] ?? null;
        $data = Request::getBody();
        $booking_id = $data['id'];
        $newDate = $data['booking_date'];
        $newTime = $data['booking_time'];
        $newEndDate = $data['end_date'] ?? $newDate;
        $newEndTime = $data['end_time'] ?? $newTime;

        // 🕒 Project-Wide Rule: Hourly Validation for Rescheduling
        if (strtotime($newEndTime) <= strtotime($newTime)) {
             Response::error("يجب أن يكون وقت النهاية بعد وقت البداية.", 400);
        }

        try {
            $booking = $this->bookingRepo->getById($booking_id);
            if (!$booking) Response::error("Booking not found", 404);
            if ($booking['provider_id'] != $provider_id) Response::error("Unauthorized", 403);

            // 🧠 Check for Overlaps on new slot (Excluding current booking)
            $newStart = "$newDate $newTime";
            $newEnd = "$newEndDate $newEndTime";
            $conflict = $this->bookingRepo->hasOverlap($booking['service_type'], $booking['service_id'], $newStart, $newEnd, $booking_id);
            if ($conflict) {
                 Response::error("الموعد الجديد محجوز مسبقاً.", 409, [
                    "conflict" => [
                        "start_date" => $conflict['booking_date'],
                        "start_time" => $conflict['booking_time'],
                        "end_date" => $conflict['end_date'] ?? $conflict['booking_date'],
                        "end_time" => $conflict['end_time'] ?? $conflict['booking_time'],
                    ]
                 ]);
            }

            $this->bookingRepo->updateDateTime($booking_id, $newDate, $newTime, $newEndDate, $newEndTime);

            // 🔔 Notify Customer
            if ($booking['customer_id']) {
                $this->notificationRepo->create(
                    $booking['customer_id'],
                    "تغيير موعد الحجز",
                    "لقد قام مزود الخدمة بتغيير موعد حجزك لـ {$booking['service_type']} إلى: $newDate $newTime",
                    'reschedule'
                );
            }

            Response::success("Booking rescheduled successfully");
        } catch (Exception $e) {
            Response::error($e->getMessage(), 500);
        }
    }
}
