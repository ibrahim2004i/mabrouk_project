-- 📅 Migration: Add Date/Time Ranges to Bookings
-- Author: Antigravity Senior AI
-- Date: 2026-03-31

USE `mabrouk_db_new`;

ALTER TABLE `bookings` 
ADD COLUMN `end_date` DATE DEFAULT NULL AFTER `booking_date`,
ADD COLUMN `end_time` TIME DEFAULT NULL AFTER `booking_time`;

-- Optimization: Allow queries by range
CREATE INDEX `idx_booking_range` ON `bookings` (`booking_date`, `end_date`);
