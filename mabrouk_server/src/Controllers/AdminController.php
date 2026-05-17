<?php
// 🛡️ Admin Moderation Controller
// Platform-wide management for providers and services.

namespace App\Controllers;

use App\Core\Request;
use App\Core\Response;
use App\Repositories\BaseServiceRepository;
use App\Repositories\AdminRepository;
use Exception;

class AdminController {
    private $serviceRepo;
    private $adminRepo;

    public function __construct() {
        $this->serviceRepo = new BaseServiceRepository();
        $this->adminRepo = new AdminRepository();
    }

    /**
     * Admin API: List all service providers.
     */
    public function listProviders() {
        try {
            $providers = $this->adminRepo->getAllProviders();
            Response::success("Provider list", $providers);
        } catch (Exception $e) {
            Response::error($e->getMessage(), 500);
        }
    }

    /**
     * Admin API: List only pending service providers.
     */
    public function listPendingProviders() {
        try {
            $providers = $this->adminRepo->getPendingProviders();
            Response::success("Pending providers", $providers);
        } catch (Exception $e) {
            Response::error($e->getMessage(), 500);
        }
    }

    /**
     * Admin API: Delete a provider account.
     */
    public function deleteProvider() {
        $data = Request::getBody();
        $id = $data['id'] ?? null;
        if (!$id) Response::error("Provider ID required", 400);

        try {
            $this->adminRepo->deleteProvider($id);
            Response::success("Provider deleted successfully");
        } catch (Exception $e) {
            Response::error($e->getMessage(), 500);
        }
    }

    /**
     * Admin API: Change provider approval status.
     * POST /admin/providers/update-status
     */
    public function updateProviderStatus() {
        $data = Request::getBody();
        $id = $data['id'] ?? null;
        $status = $data['status'] ?? null; // 'approved' or 'rejected'

        if (!$id || !$status) {
            Response::error("Provider ID and status are required", 400);
        }

        try {
            $this->adminRepo->updateProviderStatus($id, $status);
            Response::success("Provider status updated to $status successfully");
        } catch (Exception $e) {
            Response::error($e->getMessage(), 500);
        }
    }

    /**
     * Admin API: List all user complaints.
     */
    public function listComplaints() {
        try {
            $complaints = $this->adminRepo->getAllComplaints();
            Response::success("Complaint list", $complaints);
        } catch (Exception $e) {
            Response::error($e->getMessage(), 500);
        }
    }

    /**
     * Admin API: Resolve a complaint.
     */
    public function resolveComplaint() {
        $data = Request::getBody();
        $id = $data['id'] ?? null;
        $notes = $data['notes'] ?? '';
        if (!$id) Response::error("Complaint ID required", 400);

        try {
            $this->adminRepo->resolveComplaint($id, $notes);
            Response::success("Complaint resolved");
        } catch (Exception $e) {
            Response::error($e->getMessage(), 500);
        }
    }

    /**
     * Admin API: List all pending services from all categories.
     * GET /api/admin/pending-services
     */
    public function pendingServices() {
        try {
            $services = $this->serviceRepo->getGlobalPendingServices();
            Response::success("Pending services across all categories", $services);
        } catch (Exception $e) {
            Response::error($e->getMessage(), 500);
        }
    }

    /**
     * Admin API: Approve a specific service.
     * POST /api/admin/approve-service
     */
    public function approveService() {
        $data = Request::getBody();
        $type = $data['service_type'] ?? null;
        $id = $data['id'] ?? null;

        if (!$type || !$id) {
            Response::error("Service Type and ID are required", 400);
        }

        try {
            $this->serviceRepo->updateServiceStatus($type, $id, 'approved');
            Response::success("Service approved successfully");
        } catch (Exception $e) {
            Response::error($e->getMessage(), 400);
        }
    }

    /**
     * Admin API: Reject a specific service.
     * POST /api/admin/reject-service
     */
    public function rejectService() {
        $data = Request::getBody();
        $type = $data['service_type'] ?? null;
        $id = $data['id'] ?? null;

        if (!$type || !$id) Response::error("Type and ID required", 400);

        try {
            $this->serviceRepo->updateServiceStatus($type, $id, 'rejected');
            Response::success("Service rejected");
        } catch (Exception $e) {
            Response::error($e->getMessage(), 400);
        }
    }

    /**

     * Admin API: List all services for a specific provider.
     * GET /api/admin/provider-services?id=123
     */
    public function getProviderServices() {
        $id = $_GET['id'] ?? null;
        if (!$id) Response::error("Provider ID required", 400);

        try {
            $services = $this->serviceRepo->getAllProviderServices($id);
            Response::success("Provider's services", $services);
        } catch (Exception $e) {
            Response::error($e->getMessage(), 500);
        }
    }
}
