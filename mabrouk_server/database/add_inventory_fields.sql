-- 📦 Add stock_count to ALL service tables to ensure query consistency
USE `mabrouk_db_new`;

ALTER TABLE `srv_wedding_halls` ADD COLUMN `stock_count` INT DEFAULT 1 AFTER `offering_type`;
ALTER TABLE `srv_chalets` ADD COLUMN `stock_count` INT DEFAULT 1 AFTER `offering_type`;
ALTER TABLE `srv_photographers` ADD COLUMN `stock_count` INT DEFAULT 1 AFTER `offering_type`;
ALTER TABLE `srv_cars` ADD COLUMN `stock_count` INT DEFAULT 1 AFTER `offering_type`;

ALTER TABLE `srv_suits` ADD COLUMN `stock_count` INT DEFAULT 1 AFTER `offering_type`;
ALTER TABLE `srv_cakes` ADD COLUMN `stock_count` INT DEFAULT 1 AFTER `offering_type`;
ALTER TABLE `srv_others` ADD COLUMN `stock_count` INT DEFAULT 1 AFTER `offering_type`;

-- Note: srv_dresses already has stock_count.
