<?php
// 📅 Booking Repository
// Data access layer for the central bookings table.

namespace App\Repositories;

use App\Core\Database;
use PDO;

class BookingRepository {
    private $db;

    public function __construct() {
        $this->db = Database::getInstance()->getConnection();
    }

    public function create($data) {
        $columns = implode(", ", array_keys($data));
        $placeholders = implode(", ", array_fill(0, count($data), "?"));
        
        $stmt = $this->db->prepare("INSERT INTO bookings ($columns) VALUES ($placeholders)");
        $stmt->execute(array_values($data));
        return $this->db->lastInsertId();
    }

    public function getCustomerBookings($customer_id) {
        $stmt = $this->db->prepare("SELECT b.*, sp.brand_name,
                                    (CASE 
                                        WHEN b.status = 'confirmed' AND CONCAT(IFNULL(b.end_date, b.booking_date), ' ', IFNULL(b.end_time, b.booking_time)) < NOW() THEN 'completed'
                                        WHEN b.status = 'confirmed' AND CONCAT(IFNULL(b.end_date, b.booking_date), ' ', IFNULL(b.end_time, b.booking_time)) >= NOW() THEN 'confirmed'
                                        ELSE b.status 
                                    END) as status,
                                    (CASE 
                                        WHEN b.service_type = 'photographer' THEN 'hour'
                                        WHEN b.service_type = 'hall' THEN 'event'
                                        ELSE 'day' 
                                    END) as price_unit
                                    FROM bookings b 
                                    JOIN service_providers sp ON b.provider_id = sp.user_id 
                                    WHERE b.customer_id = ? 
                                    ORDER BY b.booking_date DESC");
        $stmt->execute([$customer_id]);
        return $stmt->fetchAll();
    }

    public function getProviderBookings($provider_id) {
        $stmt = $this->db->prepare("SELECT b.*, c.full_name as customer_name, u.phone_number as customer_phone, sp.brand_name,
                                    (CASE 
                                        WHEN b.status = 'confirmed' AND CONCAT(IFNULL(b.end_date, b.booking_date), ' ', IFNULL(b.end_time, b.booking_time)) < NOW() THEN 'completed'
                                        WHEN b.status = 'confirmed' AND CONCAT(IFNULL(b.end_date, b.booking_date), ' ', IFNULL(b.end_time, b.booking_time)) >= NOW() THEN 'confirmed'
                                        ELSE b.status 
                                    END) as status,
                                    (CASE 
                                        WHEN b.service_type = 'photographer' THEN 'hour'
                                        WHEN b.service_type = 'hall' THEN 'event'
                                        ELSE 'day' 
                                    END) as price_unit
                                    FROM bookings b 
                                    LEFT JOIN customers c ON b.customer_id = c.user_id 
                                    LEFT JOIN users u ON b.customer_id = u.id 
                                    LEFT JOIN service_providers sp ON b.provider_id = sp.user_id
                                    WHERE b.provider_id = ? 
                                    ORDER BY b.booking_date DESC");
        $stmt->execute([$provider_id]);
        return $stmt->fetchAll();
    }

    public function updateStatus($booking_id, $status) {
        $stmt = $this->db->prepare("UPDATE bookings SET status = ? WHERE id = ?");
        return $stmt->execute([$status, $booking_id]);
    }

    public function updateDateTime($booking_id, $date, $time, $endDate, $endTime) {
        $stmt = $this->db->prepare("UPDATE bookings SET 
                                    booking_date = ?, 
                                    booking_time = ?, 
                                    end_date = ?, 
                                    end_time = ? 
                                    WHERE id = ?");
        return $stmt->execute([$date, $time, $endDate, $endTime, $booking_id]);
    }

    public function getById($id) {
        $stmt = $this->db->prepare("SELECT b.*, sp.brand_name,
                                    (CASE 
                                        WHEN b.status = 'confirmed' AND CONCAT(IFNULL(b.end_date, b.booking_date), ' ', IFNULL(b.end_time, b.booking_time)) < NOW() THEN 'completed'
                                        WHEN b.status = 'confirmed' AND CONCAT(IFNULL(b.end_date, b.booking_date), ' ', IFNULL(b.end_time, b.booking_time)) >= NOW() THEN 'confirmed'
                                        ELSE b.status 
                                    END) as status,
                                    (CASE 
                                        WHEN service_type = 'photographer' THEN 'hour'
                                        WHEN service_type = 'hall' THEN 'event'
                                        ELSE 'day' 
                                    END) as price_unit
                                    FROM bookings b
                                    JOIN service_providers sp ON b.provider_id = sp.user_id
                                    WHERE b.id = ?");
        $stmt->execute([$id]);
        return $stmt->fetch();
    }

    public function getServiceBookings($type, $id) {
        $stmt = $this->db->prepare("SELECT b.*, c.full_name as customer_name, u.phone_number as customer_phone,
                                    (CASE 
                                        WHEN b.status = 'confirmed' AND CONCAT(IFNULL(b.end_date, b.booking_date), ' ', IFNULL(b.end_time, b.booking_time)) < NOW() THEN 'completed'
                                        WHEN b.status = 'confirmed' AND CONCAT(IFNULL(b.end_date, b.booking_date), ' ', IFNULL(b.end_time, b.booking_time)) >= NOW() THEN 'confirmed'
                                        ELSE b.status 
                                    END) as status,
                                    (CASE 
                                        WHEN b.service_type = 'photographer' THEN 'hour'
                                        WHEN b.service_type = 'hall' THEN 'event'
                                        ELSE 'day' 
                                    END) as price_unit
                                    FROM bookings b 
                                    LEFT JOIN customers c ON b.customer_id = c.user_id 
                                    LEFT JOIN users u ON b.customer_id = u.id 
                                    WHERE b.service_type = ? AND b.service_id = ? 
                                    ORDER BY b.booking_date DESC");
        $stmt->execute([$type, $id]);
        return $stmt->fetchAll();
    }

    /**
     * 🧠 Junior Check: Prevent overlapping bookings based on Date/Time ranges.
     * Logic: (NewStart < ExistEnd) AND (ExistStart < NewEnd)
     */
    public function hasOverlap($type, $id, $newStart, $newEnd, $exclude_id = null) {
        $sql = "SELECT * 
                FROM bookings 
                WHERE service_type = ? AND service_id = ? 
                AND status IN ('confirmed', 'pending')";
        
        $params = [$type, $id];
        
        if ($exclude_id) {
            $sql .= " AND id != ?";
            $params[] = $exclude_id;
        }

        $sql .= " AND (
                    (CONCAT(booking_date, ' ', booking_time) < ?) 
                    AND 
                    (CONCAT(end_date, ' ', end_time) > ?)
                )";
        
        $params[] = $newEnd;
        $params[] = $newStart;

        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetch(); // Returns the conflict row or false
    }
}
