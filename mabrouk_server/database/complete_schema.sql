-- 🏛️ Mabrouk Professional Database Schema (Structure Only)
-- Version: 1.0 (Consolidated)
-- Date: 2026-04-15

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 🏗️ Initial Setup
CREATE DATABASE IF NOT EXISTS `mabrouk_db_new` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `mabrouk_db_new`;

-- ======================================================================================
-- 👤 SECTION: IDENTITY & ACCESS MANAGEMENT (IAM)
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

-- 2. Regular Customers (Extension)
CREATE TABLE IF NOT EXISTS `customers` (
  `user_id` INT PRIMARY KEY,
  `full_name` VARCHAR(150) NOT NULL,
  `profile_image` TEXT DEFAULT NULL,
  `gender` ENUM('male', 'female', 'other') DEFAULT NULL,
  `preferred_city_id` INT DEFAULT NULL,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Service Providers (Extension)
CREATE TABLE IF NOT EXISTS `service_providers` (
  `user_id` INT PRIMARY KEY,
  `brand_name` VARCHAR(255) NOT NULL,
  `legal_name` VARCHAR(255) DEFAULT NULL,
  `logo_url` TEXT DEFAULT NULL,
  `registration_number` VARCHAR(50) DEFAULT NULL UNIQUE,
  `office_phone` VARCHAR(20) DEFAULT NULL,
  `whatsapp_number` VARCHAR(20) DEFAULT NULL,
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
  `access_level` INT DEFAULT 1,
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
-- 💎 SECTION: GLOBAL SERVICE MODELS (Includes Contact & Location fields)
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
  `city_id` INT DEFAULT 1,
  `location_address` TEXT DEFAULT NULL,
  `office_phone` VARCHAR(20) DEFAULT NULL,
  `whatsapp_number` VARCHAR(20) DEFAULT NULL,
  `offering_type` ENUM('booking', 'purchase') DEFAULT 'booking',
  `stock_count` INT DEFAULT 1,
  `price_unit` ENUM('hour', 'day', 'event') DEFAULT 'event',
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
  `city_id` INT DEFAULT 1,
  `location_address` TEXT DEFAULT NULL,
  `office_phone` VARCHAR(20) DEFAULT NULL,
  `whatsapp_number` VARCHAR(20) DEFAULT NULL,
  `offering_type` ENUM('booking', 'purchase') DEFAULT 'booking',
  `stock_count` INT DEFAULT 1,
  `price_unit` ENUM('hour', 'day', 'event') DEFAULT 'day',
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
  `sizes_available` VARCHAR(100) DEFAULT 'S,M,L',
  `business_mode` ENUM('rent', 'buy', 'both') DEFAULT 'both',
  `stock_count` INT DEFAULT 1,
  `description` TEXT DEFAULT NULL,
  `status` ENUM('pending', 'approved', 'rejected', 'archived') DEFAULT 'pending',
  `city_id` INT DEFAULT 1,
  `location_address` TEXT DEFAULT NULL,
  `office_phone` VARCHAR(20) DEFAULT NULL,
  `whatsapp_number` VARCHAR(20) DEFAULT NULL,
  `offering_type` ENUM('booking', 'purchase') DEFAULT 'booking',
  `price_unit` ENUM('hour', 'day', 'event') DEFAULT 'event',
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
  `city_id` INT DEFAULT 1,
  `location_address` TEXT DEFAULT NULL,
  `office_phone` VARCHAR(20) DEFAULT NULL,
  `whatsapp_number` VARCHAR(20) DEFAULT NULL,
  `offering_type` ENUM('booking', 'purchase') DEFAULT 'booking',
  `price_unit` ENUM('hour', 'day', 'event') DEFAULT 'event',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`provider_id`) REFERENCES `service_providers`(`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Wedding Cars
CREATE TABLE IF NOT EXISTS `srv_cars` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `provider_id` INT NOT NULL,
  `name` VARCHAR(255) DEFAULT NULL,
  `brand` VARCHAR(100) NOT NULL,
  `model` VARCHAR(100) NOT NULL,
  `color` VARCHAR(50) DEFAULT NULL,
  `year` INT DEFAULT NULL,
  `price_per_day` DECIMAL(10, 2) NOT NULL,
  `with_driver` BOOLEAN DEFAULT TRUE,
  `description` TEXT DEFAULT NULL,
  `status` ENUM('pending', 'approved', 'rejected', 'archived') DEFAULT 'pending',
  `city_id` INT DEFAULT 1,
  `location_address` TEXT DEFAULT NULL,
  `office_phone` VARCHAR(20) DEFAULT NULL,
  `whatsapp_number` VARCHAR(20) DEFAULT NULL,
  `offering_type` ENUM('booking', 'purchase') DEFAULT 'booking',
  `stock_count` INT DEFAULT 1,
  `price_unit` ENUM('hour', 'day', 'event') DEFAULT 'day',
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
  `city_id` INT DEFAULT 1,
  `location_address` TEXT DEFAULT NULL,
  `office_phone` VARCHAR(20) DEFAULT NULL,
  `whatsapp_number` VARCHAR(20) DEFAULT NULL,
  `offering_type` ENUM('booking', 'purchase') DEFAULT 'purchase',
  `price_unit` ENUM('hour', 'day', 'event') DEFAULT 'event',
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
  `status` ENUM('pending', 'approved', 'rejected', 'archived') DEFAULT 'pending',
  `city_id` INT DEFAULT 1,
  `location_address` TEXT DEFAULT NULL,
  `office_phone` VARCHAR(20) DEFAULT NULL,
  `whatsapp_number` VARCHAR(20) DEFAULT NULL,
  `offering_type` ENUM('booking', 'purchase') DEFAULT 'booking',
  `stock_count` INT DEFAULT 1,
  `price_unit` ENUM('hour', 'day', 'event') DEFAULT 'hour',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`provider_id`) REFERENCES `service_providers`(`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. Others / Custom Services
CREATE TABLE IF NOT EXISTS `srv_others` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `provider_id` INT NOT NULL,
  `type_name` VARCHAR(100) NOT NULL COMMENT 'e.g. DJ, Zaffa',
  `title` VARCHAR(255) NOT NULL,
  `base_price` DECIMAL(10, 2) NOT NULL,
  `stock_count` INT DEFAULT 1,
  `description` TEXT DEFAULT NULL,
  `status` ENUM('pending', 'approved', 'rejected', 'archived') DEFAULT 'pending',
  `city_id` INT DEFAULT 1,
  `location_address` TEXT DEFAULT NULL,
  `office_phone` VARCHAR(20) DEFAULT NULL,
  `whatsapp_number` VARCHAR(20) DEFAULT NULL,
  `offering_type` ENUM('booking', 'purchase') DEFAULT 'booking',
  `price_unit` ENUM('hour', 'day', 'event') DEFAULT 'event',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`provider_id`) REFERENCES `service_providers`(`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. Service Specifications (Custom dynamic fields per service)
CREATE TABLE IF NOT EXISTS `service_specifications` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `service_type` VARCHAR(50) NOT NULL,
    `service_id` INT NOT NULL,
    `label` VARCHAR(255) NOT NULL,
    `value` VARCHAR(255) NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX (`service_type`, `service_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ======================================================================================
-- 📅 SECTION: TRANSACTIONAL DATA & INTERACTION
-- ======================================================================================

-- 1. Bookings (Includes Date/Time Range & Manual Name)
CREATE TABLE IF NOT EXISTS `bookings` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `customer_id` INT NOT NULL,
  `manual_customer_name` VARCHAR(255) DEFAULT NULL,
  `provider_id` INT NOT NULL,
  `service_type` ENUM('hall', 'chalet', 'dress', 'suit', 'car', 'cake', 'photographer', 'others') NOT NULL,
  `service_id` INT NOT NULL,
  `total_price` DECIMAL(10, 2) NOT NULL,
  `booking_date` DATE NOT NULL,
  `end_date` DATE DEFAULT NULL,
  `booking_time` TIME DEFAULT NULL,
  `end_time` TIME DEFAULT NULL,
  `status` ENUM('pending', 'confirmed', 'cancelled', 'completed', 'disputed') DEFAULT 'pending',
  `payment_status` ENUM('unpaid', 'partially_paid', 'paid', 'refunded') DEFAULT 'unpaid',
  `customer_notes` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`customer_id`) REFERENCES `customers`(`user_id`),
  FOREIGN KEY (`provider_id`) REFERENCES `service_providers`(`user_id`),
  INDEX `idx_booking_range` (`booking_date`, `end_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Central Media Gallery
CREATE TABLE IF NOT EXISTS `media` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `service_type` ENUM('hall', 'chalet', 'dress', 'suit', 'car', 'cake', 'photographer', 'others') NOT NULL,
  `service_id` INT NOT NULL,
  `file_url` TEXT NOT NULL,
  `is_thumbnail` BOOLEAN DEFAULT FALSE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Favorites
CREATE TABLE IF NOT EXISTS `favorites` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `service_type` VARCHAR(50) NOT NULL,
    `service_id` INT NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    UNIQUE KEY `unique_fav_user_service` (`user_id`, `service_type`, `service_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Complaints
CREATE TABLE IF NOT EXISTS `complaints` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `provider_id` INT NOT NULL,
    `booking_id` INT DEFAULT NULL,
    `subject` VARCHAR(255) NOT NULL,
    `description` TEXT NOT NULL,
    `status` ENUM('pending', 'resolved', 'ignored') DEFAULT 'pending',
    `admin_notes` TEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`provider_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`booking_id`) REFERENCES `bookings`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Notifications
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `message` TEXT NOT NULL,
  `type` ENUM('new_booking', 'status_change', 'system_alert') NOT NULL,
  `is_read` BOOLEAN DEFAULT FALSE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  INDEX `idx_user_unread` (`user_id`, `is_read`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Reviews
CREATE TABLE IF NOT EXISTS `reviews` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `booking_id` INT DEFAULT NULL,
  `customer_id` INT NOT NULL,
  `provider_id` INT NOT NULL,
  `service_type` ENUM('hall', 'chalet', 'dress', 'suit', 'car', 'cake', 'photographer', 'others') NOT NULL,
  `service_id` INT NOT NULL,
  `rating` TINYINT NOT NULL CHECK (`rating` BETWEEN 1 AND 5),
  `comment` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`booking_id`) REFERENCES `bookings`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`customer_id`) REFERENCES `customers`(`user_id`) ON DELETE CASCADE,
  FOREIGN KEY (`provider_id`) REFERENCES `service_providers`(`user_id`) ON DELETE CASCADE,
  INDEX `idx_service_reviews` (`service_type`, `service_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
