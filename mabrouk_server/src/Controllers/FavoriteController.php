<?php
// 🏗️ Favorite Controller
// Exposes wishlist operations to the API.

namespace App\Controllers;

use App\Core\Request;
use App\Core\Response;
use App\Repositories\FavoriteRepository;

class FavoriteController {
    private $favoriteRepo;

    public function __construct() {
        $this->favoriteRepo = new FavoriteRepository();
    }

    /**
     * ❤️ Toggle Favorite
     * Requires Auth.
     */
    public function toggle() {
        $userId = $_SESSION['user_id'] ?? null;
        if (!$userId) Response::error("Unauthorized", 401);

        $body = Request::getBody();
        $type = $body['type'] ?? '';
        $id = $body['id'] ?? '';

        if (!$type || !$id) {
            Response::error("Service type and ID are required", 400);
        }

        try {
            $result = $this->favoriteRepo->toggle($userId, $type, $id);
            Response::success("Operation Successful", $result);
        } catch (\Exception $e) {
            Response::error($e->getMessage(), 500);
        }
    }

    /**
     * 📜 Get All Favorites
     * Returns list of composite IDs.
     */
    public function index() {
        $userId = $_SESSION['user_id'] ?? null;
        if (!$userId) Response::error("Unauthorized", 401);

        try {
            $favorites = $this->favoriteRepo->findAllByUser($userId);
            Response::success("Favorites fetched", $favorites);
        } catch (\Exception $e) {
            Response::error($e->getMessage(), 500);
        }
    }
}
