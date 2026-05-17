<?php
// 🛠️ Base Service Repository
// Handles generic CRUD operations for all specialized service tables.

namespace App\Repositories;

use App\Core\Database;
use Exception;
use PDO;

class BaseServiceRepository {
    protected $db;
    protected $typeToTable = [
        'hall' => 'srv_wedding_halls',
        'chalet' => 'srv_chalets',
        'dress' => 'srv_dresses',
        'suit' => 'srv_suits',
        'car' => 'srv_cars',
        'cake' => 'srv_cakes',
        'photographer' => 'srv_photographers',
        'others' => 'srv_others'
    ];

    public function __construct() {
        $this->db = Database::getInstance()->getConnection();
    }

    protected function getTableName($type) {
        if (!isset($this->typeToTable[$type])) {
            throw new Exception("Invalid service type: $type");
        }
        return $this->typeToTable[$type];
    }

    public function getAllApproved($type, $city_id = null) {
        $table = $this->getTableName($type);
        $query = "SELECT s.*, '$type' as service_type, sp.brand_name, 
                         COALESCE(m.file_url, sp.logo_url) as logo_url,
                         sp.logo_url as provider_logo,
                         sp.office_phone as sp_phone, sp.whatsapp_number as sp_whatsapp,
                         c.name_ar as city_name,
                         (SELECT IFNULL(AVG(r.rating), 0) FROM reviews r WHERE r.service_type = '$type' AND r.service_id = s.id) as overall_rating,
                         (SELECT COUNT(*) FROM reviews r WHERE r.service_type = '$type' AND r.service_id = s.id) as reviews_count
                  FROM $table s 
                  JOIN service_providers sp ON s.provider_id = sp.user_id 
                  LEFT JOIN media m ON m.service_type = '$type' AND m.service_id = s.id AND m.is_thumbnail = 1
                  LEFT JOIN cities c ON s.city_id = c.id
                  WHERE s.status = 'approved' AND sp.status = 'approved'";
        
        $params = [];
        if ($city_id) {
            $query .= " AND s.city_id = ?";
            $params[] = $city_id;
        }

        // 📦 Rule: Hide purchase items with 0 stock
        $query .= " AND (s.offering_type = 'booking' OR (s.offering_type = 'purchase' AND s.stock_count > 0))";

        $stmt = $this->db->prepare($query);
        $stmt->execute($params);
        $results = $stmt->fetchAll();

        foreach ($results as &$r) {
            $r['office_phone'] = $r['office_phone'] ?? $r['sp_phone'];
            $r['whatsapp_number'] = $r['whatsapp_number'] ?? $r['sp_whatsapp'];
        }
        return $results;
    }

    public function getById($type, $id) {
        $table = $this->getTableName($type);
        $stmt = $this->db->prepare("SELECT s.*, '$type' as service_type, sp.brand_name, 
                                     COALESCE(m.file_url, sp.logo_url) as logo_url,
                                     sp.logo_url as provider_logo,
                                     sp.office_phone as sp_phone, sp.whatsapp_number as sp_whatsapp,
                                     ct.name_ar as city_name,
                                     (SELECT IFNULL(AVG(r.rating), 0) FROM reviews r WHERE r.service_type = '$type' AND r.service_id = s.id) as overall_rating,
                                     (SELECT COUNT(*) FROM reviews r WHERE r.service_type = '$type' AND r.service_id = s.id) as reviews_count
                                     FROM $table s 
                                     JOIN service_providers sp ON s.provider_id = sp.user_id 
                                     LEFT JOIN media m ON m.service_type = '$type' AND m.service_id = s.id AND m.is_thumbnail = 1
                                     LEFT JOIN cities ct ON s.city_id = ct.id
                                     WHERE s.id = ? AND sp.status = 'approved'");
        $stmt->execute([$id]);
        $res = $stmt->fetch();
        if ($res) {
            $res['office_phone'] = $res['office_phone'] ?? ($res['sp_phone'] ?? '');
            $res['whatsapp_number'] = $res['whatsapp_number'] ?? ($res['sp_whatsapp'] ?? '');
            $res['specifications'] = $this->getSpecifications($type, $id);
        }
        return $res;
    }

    public function getSpecifications($type, $id) {
        $stmt = $this->db->prepare("SELECT label, value FROM service_specifications WHERE service_type = ? AND service_id = ?");
        $stmt->execute([$type, $id]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getMedia($type, $id) {
        $stmt = $this->db->prepare("SELECT file_url, is_thumbnail FROM media WHERE service_type = ? AND service_id = ? ORDER BY is_thumbnail DESC, id ASC");
        $stmt->execute([$type, $id]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getProviderServices($type, $provider_id) {
        $table = $this->getTableName($type);
        $stmt = $this->db->prepare("SELECT * FROM $table WHERE provider_id = ?");
        $stmt->execute([$provider_id]);
        return $stmt->fetchAll();
    }

    /**
     * Aggregates services from all tables for a specific provider.
     */
    public function getAllProviderServices($provider_id) {
        $allServices = [];
        foreach ($this->typeToTable as $type => $table) {
            $stmt = $this->db->prepare("SELECT s.*, '$type' as service_type,
                                        (SELECT IFNULL(AVG(r.rating), 0) FROM reviews r WHERE r.service_type = '$type' AND r.service_id = s.id) as overall_rating,
                                        (SELECT COUNT(*) FROM reviews r WHERE r.service_type = '$type' AND r.service_id = s.id) as reviews_count,
                                        (SELECT COUNT(*) FROM bookings b WHERE b.service_type = '$type' AND b.service_id = s.id AND b.status = 'pending') as pending_count,
                                        (SELECT COUNT(*) FROM bookings b WHERE b.service_type = '$type' AND b.service_id = s.id AND b.status = 'confirmed' AND CONCAT(IFNULL(b.end_date, b.booking_date), ' ', IFNULL(b.end_time, b.booking_time)) >= NOW()) as confirmed_count,
                                        (SELECT COUNT(*) FROM bookings b WHERE b.service_type = '$type' AND b.service_id = s.id AND (b.status = 'completed' OR (b.status = 'confirmed' AND CONCAT(IFNULL(b.end_date, b.booking_date), ' ', IFNULL(b.end_time, b.booking_time)) < NOW()))) as completed_count,
                                        (SELECT COUNT(*) FROM bookings b WHERE b.service_type = '$type' AND b.service_id = s.id AND b.status = 'cancelled') as cancelled_count
                                        FROM $table s WHERE provider_id = ?");
            $stmt->execute([$provider_id]);
            $services = $stmt->fetchAll();
            foreach ($services as &$s) {
                $s['specifications'] = $this->getSpecifications($type, $s['id']);
                $s['media'] = $this->getMedia($type, $s['id']);
            }
            $allServices = array_merge($allServices, $services);
        }
        
        // Sort by created_at descending
        usort($allServices, function($a, $b) {
            return strtotime($b['created_at']) <=> strtotime($a['created_at']);
        });

        return $allServices;
    }
    public function create($type, $data) {
        if (isset($data['specifications'])) {
            $specifications = $data['specifications'];
            unset($data['specifications']);
        }

        $table = $this->getTableName($type);
        $columns = implode(", ", array_keys($data));
        $placeholders = implode(", ", array_fill(0, count($data), "?"));
        
        $stmt = $this->db->prepare("INSERT INTO $table ($columns) VALUES ($placeholders)");
        $stmt->execute(array_values($data));
        $id = $this->db->lastInsertId();

        if (isset($specifications)) {
            $this->saveSpecifications($type, $id, $specifications);
        }

        return $id;
    }

    public function update($type, $id, $data) {
        if (isset($data['specifications'])) {
            $specifications = $data['specifications'];
            unset($data['specifications']);
            $this->saveSpecifications($type, $id, $specifications);
        }

        $table = $this->getTableName($type);
        $sets = [];
        foreach (array_keys($data) as $column) {
            $sets[] = "$column = ?";
        }
        $setString = implode(", ", $sets);
        
        $stmt = $this->db->prepare("UPDATE $table SET $setString WHERE id = ?");
        $values = array_values($data);
        $values[] = $id;
        
        return $stmt->execute($values);
    }

    public function saveSpecifications($type, $id, $specs) {
        // Delete old ones first
        $stmt = $this->db->prepare("DELETE FROM service_specifications WHERE service_type = ? AND service_id = ?");
        $stmt->execute([$type, $id]);

        if (empty($specs)) return;

        // Insert new ones
        $sql = "INSERT INTO service_specifications (service_type, service_id, label, value) VALUES ";
        $values = [];
        $placeholders = [];
        foreach ($specs as $spec) {
            $placeholders[] = "(?, ?, ?, ?)";
            $values[] = $type;
            $values[] = $id;
            $values[] = $spec['label'];
            $values[] = $spec['value'];
        }
        $sql .= implode(", ", $placeholders);
        $stmt = $this->db->prepare($sql);
        return $stmt->execute($values);
    }

    public function getGlobalPendingServices() {
        $results = [];
        foreach ($this->typeToTable as $type => $table) {
            $stmt = $this->db->prepare("SELECT s.*, '$type' as service_type, sp.brand_name 
                                        FROM $table s 
                                        JOIN service_providers sp ON s.provider_id = sp.user_id 
                                        WHERE s.status = 'pending'");
            $stmt->execute();
            $results = array_merge($results, $stmt->fetchAll());
        }
        return $results;
    }

    public function updateServiceStatus($type, $id, $status) {
        $table = $this->getTableName($type);
        $stmt = $this->db->prepare("UPDATE $table SET status = ? WHERE id = ?");
        return $stmt->execute([$status, $id]);
    }

    public function decrementStock($type, $id) {
        $table = $this->getTableName($type);
        $stmt = $this->db->prepare("UPDATE $table SET stock_count = GREATEST(0, stock_count - 1) WHERE id = ?");
        return $stmt->execute([$id]);
    }
}



