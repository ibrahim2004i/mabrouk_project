<?php
// 📂 Reference Controller
// Public API for fetching static data like cities and categories.

namespace App\Controllers;

use App\Core\Response;
use App\Repositories\ReferenceRepository;
use Exception;

class ReferenceController {
    private $referenceRepo;

    public function __construct() {
        $this->referenceRepo = new ReferenceRepository();
    }

    /**
     * GET /api/cities
     */
    public function cities() {
        try {
            $cities = $this->referenceRepo->getAllCities();
            Response::success("Cities fetched successfully", $cities);
        } catch (Exception $e) {
            Response::error("Failed to fetch cities: " . $e->getMessage(), 500);
        }
    }

    /**
     * GET /api/categories
     */
    public function categories() {
        try {
            $categories = $this->referenceRepo->getAllCategories();
            Response::success("Categories fetched successfully", $categories);
        } catch (Exception $e) {
            Response::error("Failed to fetch categories: " . $e->getMessage(), 500);
        }
    }
}
