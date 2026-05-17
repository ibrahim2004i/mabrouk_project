<?php
// 🏢 Service Controller
// Handles all high-level business logic for halls, chalets, dresses, etc.

namespace App\Controllers;

use App\Core\Request;
use App\Core\Response;
use App\Repositories\BaseServiceRepository;
use App\Repositories\UserRepository;
use App\Repositories\NotificationRepository;
use Exception;

class ServiceController {
    private $serviceRepo;
    private $userRepo;
    private $notificationRepo;

    public function __construct() {
        $this->serviceRepo = new BaseServiceRepository();
        $this->userRepo = new UserRepository();
        $this->notificationRepo = new NotificationRepository();
    }

    /**
     * Public API: Get all approved services of a 특정 type.
     * GET /api/services/{type}?city_id=X
     */
    public function index($type) {
        $queryParams = Request::getQueryParams();
        $city_id = $queryParams['city_id'] ?? null;

        try {
            $services = $this->serviceRepo->getAllApproved($type, $city_id);
            Response::success("Services found", $services);
        } catch (Exception $e) {
            Response::error($e->getMessage(), 400);
        }
    }

    /**
     * Public API: Get details for a single service.
     * GET /api/services/{type}/{id}
     */
    public function show($type, $id) {
        try {
            $service = $this->serviceRepo->getById($type, $id);
            if (!$service) {
                Response::error("Service not found", 404);
            }

            // Append media gallery
            $service['media'] = $this->serviceRepo->getMedia($type, $id);

            Response::success("Service details", $service);
        } catch (Exception $e) {
            Response::error($e->getMessage(), 400);
        }
    }

    /**
     * Provider API: Get all services owned by the current provider.
     * GET /api/provider/my-services
     */
    public function providerIndex() {
        $provider_id = $_SESSION['user_id'] ?? null;
        if (!$provider_id) Response::error("Unauthorized", 401);

        try {
            $services = $this->serviceRepo->getAllProviderServices($provider_id);
            Response::success("Your services", $services);
        } catch (Exception $e) {
            Response::error($e->getMessage(), 400);
        }
    }

    /**
     * Provider API: Create a new service.
     * POST /api/services/{type}
     */
    public function store($type) {
        $provider_id = $_SESSION['user_id'] ?? null;
        if (!$provider_id) Response::error("Unauthorized", 401);

        $data = Request::getBody();
        $data['provider_id'] = $provider_id;
        $data['status'] = 'approved'; // Auto-approve new services

        try {
            $id = $this->serviceRepo->create($type, $data);

            Response::success("Service created and live", ["id" => $id], 201);
        } catch (Exception $e) {
            Response::error($e->getMessage(), 400);
        }
    }

    /**
     * Provider API: Update an existing service.
     * PUT /api/services/{type}/{id}
     */
    public function update($type, $id) {
        $provider_id = $_SESSION['user_id'] ?? null;
        if (!$provider_id) Response::error("Unauthorized", 401);

        try {
            // Verify ownership
            $existing = $this->serviceRepo->getById($type, $id);
            if (!$existing) Response::error("Service not found", 404);
            if ($existing['provider_id'] != $provider_id) Response::error("Forbidden", 403);

            $data = Request::getBody();
            unset($data['provider_id']); // Cannot transfer ownership
            unset($data['id']);          // Cannot change primary key
            
            $data['status'] = 'approved'; // Keep approved after update

            $this->serviceRepo->update($type, $id, $data);

            Response::success("Service updated successfully");
        } catch (Exception $e) {
            Response::error($e->getMessage(), 400);
        }
    }
}
