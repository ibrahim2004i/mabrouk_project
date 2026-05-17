-- 📦 Create Others/Custom Service Table
USE `mabrouk_db_new`;

CREATE TABLE IF NOT EXISTS `srv_others` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `provider_id` INT NOT NULL,
  `type_name` VARCHAR(100) NOT NULL COMMENT 'e.g. DJ, Zaffa, Balloons',
  `title` VARCHAR(255) NOT NULL,
  `base_price` DECIMAL(10, 2) NOT NULL,
  `description` TEXT DEFAULT NULL,
  `status` ENUM('pending', 'approved', 'rejected', 'archived') DEFAULT 'pending',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`provider_id`) REFERENCES `service_providers`(`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 🏷️ Add 'other' category if not exists
INSERT IGNORE INTO `categories` (`name_ar`, `name_en`, `icon_key`) 
VALUES ('أخرى / طلبات مخصصة', 'Others / Custom', 'more_horiz');
