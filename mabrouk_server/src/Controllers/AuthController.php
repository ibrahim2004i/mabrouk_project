<?php
// 🛂 Authentication Controller
// Entry points for User Login and Registration.

namespace App\Controllers;

use App\Core\Request;
use App\Core\Response;
use App\Repositories\UserRepository;
use App\Repositories\NotificationRepository;
use App\Services\AuthService;
use Exception;

class AuthController {
    private $userRepo;
    private $notificationRepo;

    public function __construct() {
        $this->userRepo = new UserRepository();
        $this->notificationRepo = new NotificationRepository();
    }

    public function login() {
        $data = Request::getBody();
        $phone = $data['phone'] ?? '';
        $password = $data['password'] ?? '';

        if (!$phone || !$password) {
            Response::error("Phone and password are required", 400);
        }

        $user = $this->userRepo->findByPhone($phone);
        if (!$user || !password_verify($password, $user['password_hash'])) {
            Response::error("Invalid credentials", 401);
        }

        $token = AuthService::generateToken($user['id'], $user['role']);
        
        $profile = null;
        if ($user['role'] === 'customer') {
            $profile = $this->userRepo->getCustomerProfile($user['id']);
        } else if ($user['role'] === 'provider') {
            $profile = $this->userRepo->getProviderProfile($user['id']);
            // 🔒 Approval Gate: Providers must be 'approved' by Admin to log in
            if (!$profile || ($profile['status'] ?? '') !== 'approved') {
                Response::error("نعتذر، حسابك قيد المراجعة حالياً من قبل الإدارة. سنقوم بتفعيله قريباً.", 403);
            }
        }

        Response::success("Login successful", [
            "token" => $token,
            "user" => $profile ? $profile : $user
        ]);
    }

    public function registerCustomer() {
        $data = Request::getBody();
        $phone = $data['phone'] ?? '';
        $password = $data['password'] ?? '';
        $name = $data['name'] ?? '';

        if (!$phone || !$password || !$name) {
            Response::error("Phone, password, and name are required", 400);
        }

        try {
            $existing = $this->userRepo->findByPhone($phone);
            if ($existing) Response::error("Phone already registered", 400);

            $user_id = $this->userRepo->createBaseUser($phone, $password, 'customer');
            $this->userRepo->createCustomer($user_id, $name);

            Response::success("Registration successful", ["user_id" => $user_id]);
        } catch (Exception $e) {
            Response::error($e->getMessage(), 500);
        }
    }

    public function registerProvider() {
        $data = Request::getBody();
        $phone = $data['phone'] ?? '';
        $password = $data['password'] ?? '';
        $brand_name = $data['brand_name'] ?? '';
        $city_id = $data['city_id'] ?? 1;

        if (!$phone || !$password || !$brand_name) {
            Response::error("Phone, password, and brand name are required", 400);
        }

        try {
            $existing = $this->userRepo->findByPhone($phone);
            if ($existing) Response::error("Phone already registered", 400);

            $user_id = $this->userRepo->createBaseUser($phone, $password, 'provider');
            $this->userRepo->createProvider($user_id, $brand_name, $city_id);

            // 🔔 Notify Admins
            $admins = $this->userRepo->getAdminIds();
            foreach ($admins as $adminId) {
                $this->notificationRepo->create(
                    $adminId, 
                    "مزود جديد", 
                    "انضم مزود خدمة جديد ($brand_name) إلى المنصة.", 
                    "provider_signup"
                );
            }

            Response::success("Provider registration successful, pending approval", ["user_id" => $user_id]);
        } catch (Exception $e) {
            Response::error($e->getMessage(), 500);
        }
    }

    /**
     * 🧠 Update User Profile (Shared)
     */
    public function updateProfile() {
        $user_id = $_SESSION['user_id'] ?? null;
        $role = $_SESSION['role'] ?? null;
        
        if (!$user_id) Response::error("Unauthorized", 401);

        $data = Request::getBody();
        $newPhone = $data['phone_number'] ?? '';

        try {
            // 1. Phone Uniqueness Check
            if ($newPhone) {
                if ($this->userRepo->isPhoneTaken($newPhone, $user_id)) {
                    Response::error("رقم الهاتف مستخدم حالياً بحساب آخر", 400);
                }
                $this->userRepo->updatePhone($user_id, $newPhone);
            }

            // 2. Specialty Update
            if ($role === 'customer') {
                $this->userRepo->updateCustomer($user_id, [
                    'full_name' => $data['full_name'] ?? '',
                    'gender' => $data['gender'] ?? null,
                    'city_id' => $data['city_id'] ?? null
                ]);
                $updated = $this->userRepo->getCustomerProfile($user_id);
            } else if ($role === 'provider') {
                $this->userRepo->updateProvider($user_id, $data);
                $updated = $this->userRepo->getProviderProfile($user_id);
            } else {
                Response::error("Invalid user role for profile update", 400);
            }

            Response::success("تم تحديث البروفايل بنجاح", ["user" => $updated]);
        } catch (Exception $e) {
            Response::error($e->getMessage(), 500);
        }
    }
}
