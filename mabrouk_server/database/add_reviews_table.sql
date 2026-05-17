-- 📝 Migration: Add Reviews Table (V2 - Direct Reviews)
-- Allows both booking-linked and direct service reviews.

USE `mabrouk_db_new`;

CREATE TABLE IF NOT EXISTS `reviews` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `booking_id` INT DEFAULT NULL, -- Optional: Link to booking if exists
  `customer_id` INT NOT NULL,
  `provider_id` INT NOT NULL, -- Who is being reviewed
  `service_type` ENUM('hall', 'chalet', 'dress', 'suit', 'car', 'cake', 'photographer') NOT NULL,
  `service_id` INT NOT NULL,
  `rating` TINYINT NOT NULL CHECK (`rating` BETWEEN 1 AND 5),
  `comment` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`booking_id`) REFERENCES `bookings`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`customer_id`) REFERENCES `customers`(`user_id`) ON DELETE CASCADE,
  FOREIGN KEY (`provider_id`) REFERENCES `service_providers`(`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Optional: Indexing for fast retrieval on service pages
CREATE INDEX `idx_service_reviews` ON `reviews` (`service_type`, `service_id`);
