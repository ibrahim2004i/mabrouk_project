-- 🏛️ Mabrouk Professional Database Schema (v1.0 - Refactored)
-- Architect: Antigravity Senior Backend AI
-- Date: 2026-03-29

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 🏗️ Initial Setup
CREATE DATABASE IF NOT EXISTS `mabrouk_db_new` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `mabrouk_db_new`;

-- ======================================================================================
-- 👤 SECTION: IDENTITY & ACCESS MANAGEMENT (IAM)
-- Using Multi-Table Inheritance (MTI) for specialized roles.
-- ======================================================================================

-- 1. Base Users Table (Authentication Core)
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `phone_number` VARCHAR(20) NOT NULL UNIQUE,
  `email` VARCHAR(100) DEFAULT NULL UNIQUE,
  `password_hash` VARCHAR(255) NOT NULL,
  `role` ENUM('customer', 'provider', 'admin') NOT NULL,
  `is_active` BOOLEAN DEFAULT TRUE,
  `last_login` TIMESTAMP NULL DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_phone` (`phone_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Regular Users / Customers (Extension)
CREATE TABLE IF NOT EXISTS `customers` (
  `user_id` INT PRIMARY KEY,
  `full_name` VARCHAR(150) NOT NULL,
  `profile_image` TEXT DEFAULT NULL,
  `gender` ENUM('male', 'female', 'other') DEFAULT NULL,
  `preferred_city_id` INT DEFAULT NULL,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Service Providers (Extension)
-- Represents the legal/business entity.
CREATE TABLE IF NOT EXISTS `service_providers` (
  `user_id` INT PRIMARY KEY,
  `brand_name` VARCHAR(255) NOT NULL,
  `legal_name` VARCHAR(255) DEFAULT NULL,
  `logo_url` TEXT DEFAULT NULL,
  `registration_number` VARCHAR(50) DEFAULT NULL UNIQUE,
  `office_phone` VARCHAR(20) DEFAULT NULL,
  `city_id` INT NOT NULL,
  `address_details` TEXT DEFAULT NULL,
  `bio_description` TEXT DEFAULT NULL,
  `is_verified` BOOLEAN DEFAULT FALSE,
  `overall_rating` DECIMAL(3, 2) DEFAULT 0.00,
  `status` ENUM('pending', 'approved', 'rejected', 'suspended') DEFAULT 'pending',
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Administrators
CREATE TABLE IF NOT EXISTS `admins` (
  `user_id` INT PRIMARY KEY,
  `nickname` VARCHAR(50) DEFAULT 'Admin',
  `access_level` INT DEFAULT 1, -- 1: Moderator, 99: SuperAdmin
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ======================================================================================
-- 🗺️ SECTION: REFERENCE DATA
-- ======================================================================================

CREATE TABLE IF NOT EXISTS `cities` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name_ar` VARCHAR(100) NOT NULL,
  `name_en` VARCHAR(100) DEFAULT NULL,
  `region` VARCHAR(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `categories` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name_ar` VARCHAR(100) NOT NULL,
  `name_en` VARCHAR(100) DEFAULT NULL,
  `icon_key` VARCHAR(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ======================================================================================
-- 💎 SECTION: SPECIALIZED SERVICE MODELS
-- Each service type has its own data structure and validation rules.
-- ======================================================================================

-- 1. Wedding Halls
CREATE TABLE IF NOT EXISTS `srv_wedding_halls` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `provider_id` INT NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `base_price` DECIMAL(10, 2) NOT NULL,
  `max_capacity` INT NOT NULL,
  `hall_type` ENUM('indoor', 'outdoor', 'mixed') DEFAULT 'indoor',
  `description` TEXT DEFAULT NULL,
  `status` ENUM('pending', 'approved', 'rejected', 'archived') DEFAULT 'pending',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`provider_id`) REFERENCES `service_providers`(`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Chalets
CREATE TABLE IF NOT EXISTS `srv_chalets` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `provider_id` INT NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `price_per_night` DECIMAL(10, 2) NOT NULL,
  `rooms_count` INT DEFAULT 1,
  `has_pool` BOOLEAN DEFAULT TRUE,
  `description` TEXT DEFAULT NULL,
  `status` ENUM('pending', 'approved', 'rejected', 'archived') DEFAULT 'pending',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`provider_id`) REFERENCES `service_providers`(`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Wedding Dresses
CREATE TABLE IF NOT EXISTS `srv_dresses` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `provider_id` INT NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `price` DECIMAL(10, 2) NOT NULL,
  `sizes_available` VARCHAR(100) DEFAULT 'S,M,L', -- Serialized/CSV
  `business_mode` ENUM('rent', 'buy', 'both') DEFAULT 'both',
  `stock_count` INT DEFAULT 1,
  `description` TEXT DEFAULT NULL,
  `status` ENUM('pending', 'approved', 'rejected', 'archived') DEFAULT 'pending',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`provider_id`) REFERENCES `service_providers`(`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Wedding Suits
CREATE TABLE IF NOT EXISTS `srv_suits` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `provider_id` INT NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `price` DECIMAL(10, 2) NOT NULL,
  `sizes_available` VARCHAR(100) DEFAULT NULL,
  `stock_count` INT DEFAULT 1,
  `description` TEXT DEFAULT NULL,
  `status` ENUM('pending', 'approved', 'rejected', 'archived') DEFAULT 'pending',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`provider_id`) REFERENCES `service_providers`(`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Wedding Cars
CREATE TABLE IF NOT EXISTS `srv_cars` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `provider_id` INT NOT NULL,
  `brand` VARCHAR(100) NOT NULL,
  `model` VARCHAR(100) NOT NULL,
  `color` VARCHAR(50) DEFAULT NULL,
  `price_per_day` DECIMAL(10, 2) NOT NULL,
  `with_driver` BOOLEAN DEFAULT TRUE,
  `description` TEXT DEFAULT NULL,
  `status` ENUM('pending', 'approved', 'rejected', 'archived') DEFAULT 'pending',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`provider_id`) REFERENCES `service_providers`(`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Bakers / Cakes
CREATE TABLE IF NOT EXISTS `srv_cakes` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `provider_id` INT NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `base_price` DECIMAL(10, 2) NOT NULL,
  `preparation_days` INT DEFAULT 3,
  `stock_count` INT DEFAULT 1,
  `description` TEXT DEFAULT NULL,
  `status` ENUM('pending', 'approved', 'rejected', 'archived') DEFAULT 'pending',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`provider_id`) REFERENCES `service_providers`(`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. Photographers
CREATE TABLE IF NOT EXISTS `srv_photographers` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `provider_id` INT NOT NULL,
  `package_name` VARCHAR(255) NOT NULL,
  `base_price` DECIMAL(10, 2) NOT NULL,
  `package_details` TEXT DEFAULT NULL,
  `stock_count` INT DEFAULT 1,
  `status` ENUM('pending', 'approved', 'rejected', 'archived') DEFAULT 'pending',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`provider_id`) REFERENCES `service_providers`(`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ======================================================================================
-- 📸 SECTION: CROSS-SERVICE FEATURES
-- ======================================================================================

-- Central Media Gallery
CREATE TABLE IF NOT EXISTS `media` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `service_type` ENUM('hall', 'chalet', 'dress', 'suit', 'car', 'cake', 'photographer') NOT NULL,
  `service_id` INT NOT NULL,
  `file_url` TEXT NOT NULL,
  `is_thumbnail` BOOLEAN DEFAULT FALSE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ======================================================================================
-- 📅 SECTION: TRANSACTIONAL DATA
-- ======================================================================================

CREATE TABLE IF NOT EXISTS `bookings` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `customer_id` INT NOT NULL,
  `provider_id` INT NOT NULL,
  `service_type` ENUM('hall', 'chalet', 'dress', 'suit', 'car', 'cake', 'photographer') NOT NULL,
  `service_id` INT NOT NULL,
  `total_price` DECIMAL(10, 2) NOT NULL,
  `booking_date` DATE NOT NULL,
  `booking_time` TIME DEFAULT NULL,
  `status` ENUM('pending', 'confirmed', 'cancelled', 'completed', 'disputed') DEFAULT 'pending',
  `payment_status` ENUM('unpaid', 'partially_paid', 'paid', 'refunded') DEFAULT 'unpaid',
  `customer_notes` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`customer_id`) REFERENCES `customers`(`user_id`),
  FOREIGN KEY (`provider_id`) REFERENCES `service_providers`(`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ======================================================================================
-- 🧪 SECTION: SEED DATA (CORE ONLY)
-- ======================================================================================

INSERT INTO `cities` (`name_ar`, `name_en`, `region`) VALUES 
('عمان', 'Amman', 'Central'), ('إربد', 'Irbid', 'North'), ('الزرقاء', 'Zarqa', 'Central'), 
('العقبة', 'Aqaba', 'South'), ('جرش', 'Jerash', 'North'), ('مادبا', 'Madaba', 'Central');

INSERT INTO `categories` (`name_ar`, `name_en`, `icon_key`) VALUES 
('قاعات', 'Halls', 'business'), ('شاليهات', 'Chalets', 'holiday_village'), 
('فساتين', 'Dresses', 'checkroom'), ('بدلات', 'Suits', 'accessibility_new'), 
('مصورين', 'Photographers', 'camera_alt'), ('حلويات', 'Cakes', 'cake'), ('سيارات', 'Cars', 'directions_car');

SET FOREIGN_KEY_CHECKS = 1;

