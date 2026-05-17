-- 🗄️ Mabrouk App Database Schema
-- Created: 2026-03-27

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 🏗️ Create Database
CREATE DATABASE IF NOT EXISTS `mabrouk_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `mabrouk_db`;

-- 1. Users Table
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL,
  `phone` VARCHAR(20) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL,
  `profile_image` TEXT DEFAULT NULL,
  `role` ENUM('guest', 'user', 'provider', 'admin') DEFAULT 'user',
  `is_guest` BOOLEAN DEFAULT FALSE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Categories Table
CREATE TABLE IF NOT EXISTS `categories` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Cities Table (Lookup)
CREATE TABLE IF NOT EXISTS `cities` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(50) NOT NULL UNIQUE,
  `region` VARCHAR(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Shops / Providers Table
CREATE TABLE IF NOT EXISTS `shops` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `owner_id` INT NOT NULL,
  `category_id` INT NOT NULL,
  `city_id` INT NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `logo_url` TEXT DEFAULT NULL,
  `location_address` TEXT DEFAULT NULL,
  `contact_phone` VARCHAR(20) DEFAULT NULL,
  `open_time` VARCHAR(100) DEFAULT NULL,
  `rating` FLOAT DEFAULT 0,
  `status` ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`owner_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`category_id`) REFERENCES `categories`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Venues Table (Halls & Chalets)
CREATE TABLE IF NOT EXISTS `venues` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `shop_id` INT NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `capacity` INT DEFAULT 0,
  `price_jd` DECIMAL(10, 2) NOT NULL,
  `image_url` TEXT NOT NULL,
  `description` TEXT DEFAULT NULL,
  `features` JSON DEFAULT NULL,
  `status` ENUM('pending', 'approved', 'rejected') DEFAULT 'approved',
  FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Clothing Table (Dresses & Suits)
CREATE TABLE IF NOT EXISTS `clothing` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `shop_id` INT NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `price_jd` DECIMAL(10, 2) NOT NULL,
  `image_url` TEXT NOT NULL,
  `clothing_type` VARCHAR(50) DEFAULT NULL,
  `available_sizes` TEXT DEFAULT NULL,
  `business_mode` ENUM('rent', 'sell', 'both') DEFAULT 'both',
  `stock_quantity` INT DEFAULT 1,
  `description` TEXT DEFAULT NULL,
  `status` ENUM('pending', 'approved', 'rejected') DEFAULT 'approved',
  FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. Bookings Table
CREATE TABLE IF NOT EXISTS `bookings` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `shop_id` INT NOT NULL,
  `item_id` INT NOT NULL,
  `item_type` VARCHAR(50) NOT NULL, -- e.g. 'venues', 'clothing', 'services'
  `total_price` DECIMAL(10, 2) NOT NULL,
  `booking_date` DATE NOT NULL,
  `image_url` TEXT DEFAULT NULL,
  `status` ENUM('pending', 'accepted', 'delivered', 'completed', 'cancelled') DEFAULT 'pending',
  `notes` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`),
  FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. General Services Table (Photographers, Cars, Cakes, etc.)
CREATE TABLE IF NOT EXISTS `services` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `shop_id` INT NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `price_jd` DECIMAL(10, 2) NOT NULL,
  `image_url` TEXT NOT NULL,
  `description` TEXT DEFAULT NULL,
  `status` ENUM('pending', 'approved', 'rejected') DEFAULT 'approved',
  FOREIGN KEY (`shop_id`) REFERENCES `shops`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. Media Gallery
CREATE TABLE IF NOT EXISTS `media_gallery` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `item_id` INT NOT NULL,
  `item_type` VARCHAR(50) NOT NULL,
  `url` TEXT NOT NULL,
  `is_primary` BOOLEAN DEFAULT FALSE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Seed Initial Data
INSERT INTO `cities` (`name`, `region`) VALUES 
('عمان', 'Center'), ('إربد', 'North'), ('الزرقاء', 'Center'), 
('البلقاء', 'Center'), ('المفرق', 'North'), ('الكرك', 'South'), 
('مأدبا', 'Center'), ('جرش', 'North'), ('عجلون', 'North'), 
('العقبة', 'South'), ('معان', 'South'), ('الطفيلة', 'South');

INSERT INTO `categories` (`name`) VALUES 
('قاعات'), ('شاليهات'), ('فساتين'), ('بدلات'), ('مصورين'), ('حلويات'), ('سيارات');

SET FOREIGN_KEY_CHECKS = 1;
