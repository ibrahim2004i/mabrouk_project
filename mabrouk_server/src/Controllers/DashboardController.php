<?php
// 📊 Dashboard Controller
// Analytical endpoints for service providers.

namespace App\Controllers;

use App\Core\Response;
use App\Repositories\DashboardRepository;

class DashboardController {
    private $dashboardRepo;

    public function __construct() {
        $this->dashboardRepo = new DashboardRepository();
    }

    public function stats() {
        $provider_id = $_SESSION['user_id'] ?? null;
        if (!$provider_id) Response::error("Unauthorized", 401);

        $stats = $this->dashboardRepo->getProviderStats($provider_id);
        $dailyBookings = $this->dashboardRepo->getBookingsByDay($provider_id);
        $revenueTrend = $this->dashboardRepo->getMonthlyRevenueTrend($provider_id);
        $servicePerformance = $this->dashboardRepo->getServicePerformance($provider_id);
        $statusBreakdown = $this->dashboardRepo->getStatusDistribution($provider_id);

        Response::success("Comprehensive Provider Analytics", [
            "summary" => $stats,
            "trends" => [
                "daily" => $dailyBookings,
                "monthly_revenue" => $revenueTrend
            ],
            "distribution" => [
                "services" => $servicePerformance,
                "statuses" => $statusBreakdown
            ]
        ]);
    }
}
