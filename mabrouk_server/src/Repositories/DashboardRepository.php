<?php
// 📊 Dashboard Repository
// Aggregates business data and analytics.

namespace App\Repositories;

use App\Core\Database;
use PDO;

class DashboardRepository {
    private $db;

    public function __construct() {
        $this->db = Database::getInstance()->getConnection();
    }

    public function getProviderStats($provider_id) {
        // Total bookings (Project-wide Logic: Confirmed + Time Passed = Completed)
        $stmt = $this->db->prepare("SELECT count(*) as total, 
                                           sum(case when status='pending' then 1 else 0 end) as pending,
                                           sum(case when status='confirmed' AND CONCAT(IFNULL(end_date, booking_date), ' ', IFNULL(end_time, booking_time)) >= NOW() then 1 else 0 end) as confirmed,
                                           sum(case when status='completed' OR (status='confirmed' AND CONCAT(IFNULL(end_date, booking_date), ' ', IFNULL(end_time, booking_time)) < NOW()) then 1 else 0 end) as completed,
                                           sum(case when status='cancelled' then 1 else 0 end) as cancelled,
                                           sum(case when status IN ('confirmed', 'completed') then total_price else 0 end) as total_revenue
                                    FROM bookings WHERE provider_id = ?");
        $stmt->execute([$provider_id]);
        return $stmt->fetch();
    }

    public function getBookingsByDay($provider_id, $days = 7) {
        $stmt = $this->db->prepare("SELECT booking_date, count(*) as total 
                                   FROM bookings 
                                   WHERE provider_id = ? AND booking_date >= DATE_SUB(CURDATE(), INTERVAL ? DAY)
                                   GROUP BY booking_date ORDER BY booking_date ASC");
        $stmt->execute([$provider_id, $days]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getMonthlyRevenueTrend($provider_id) {
        // Last 6 months revenue
        // Status checks also benefit from dynamic logic, but revenue usually follows 'confirmed' or 'completed'
        $stmt = $this->db->prepare("SELECT DATE_FORMAT(booking_date, '%Y-%m') as month, 
                                           sum(total_price) as revenue 
                                    FROM bookings 
                                    WHERE provider_id = ? AND status != 'cancelled'
                                    AND booking_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
                                    GROUP BY month ORDER BY month ASC");
        $stmt->execute([$provider_id]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getServicePerformance($provider_id) {
        // Compare bookings across different service types
        $stmt = $this->db->prepare("SELECT service_type, count(*) as total, sum(total_price) as revenue
                                    FROM bookings 
                                    WHERE provider_id = ?
                                    GROUP BY service_type");
        $stmt->execute([$provider_id]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getStatusDistribution($provider_id) {
        $stmt = $this->db->prepare("SELECT status_label as status, count(*) as total FROM (
                                        SELECT 
                                            CASE 
                                                WHEN status = 'confirmed' AND CONCAT(IFNULL(end_date, booking_date), ' ', IFNULL(end_time, booking_time)) < NOW() THEN 'completed'
                                                WHEN status = 'confirmed' AND CONCAT(IFNULL(end_date, booking_date), ' ', IFNULL(end_time, booking_time)) >= NOW() THEN 'confirmed'
                                                ELSE status 
                                            END as status_label
                                        FROM bookings 
                                        WHERE provider_id = ?
                                    ) as t 
                                    GROUP BY status_label");
        $stmt->execute([$provider_id]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}
