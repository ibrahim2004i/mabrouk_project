-- 📍 Location & Cities Refinement Migration
-- Adding city_id and location_address to all service tables.

SET FOREIGN_KEY_CHECKS = 0;

-- 1. Wedding Halls
ALTER TABLE `srv_wedding_halls` 
ADD COLUMN `city_id` INT DEFAULT 1,
ADD COLUMN `location_address` TEXT DEFAULT NULL,
ADD CONSTRAINT `fk_hall_city` FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`);

-- 2. Chalets
ALTER TABLE `srv_chalets` 
ADD COLUMN `city_id` INT DEFAULT 1,
ADD COLUMN `location_address` TEXT DEFAULT NULL,
ADD CONSTRAINT `fk_chalet_city` FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`);

-- 3. Wedding Dresses
ALTER TABLE `srv_dresses` 
ADD COLUMN `city_id` INT DEFAULT 1,
ADD COLUMN `location_address` TEXT DEFAULT NULL,
ADD CONSTRAINT `fk_dress_city` FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`);

-- 4. Wedding Suits
ALTER TABLE `srv_suits` 
ADD COLUMN `city_id` INT DEFAULT 1,
ADD COLUMN `location_address` TEXT DEFAULT NULL,
ADD CONSTRAINT `fk_suit_city` FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`);

-- 5. Wedding Cars
ALTER TABLE `srv_cars` 
ADD COLUMN `city_id` INT DEFAULT 1,
ADD COLUMN `location_address` TEXT DEFAULT NULL,
ADD CONSTRAINT `fk_car_city` FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`);

-- 6. Bakers / Cakes
ALTER TABLE `srv_cakes` 
ADD COLUMN `city_id` INT DEFAULT 1,
ADD COLUMN `location_address` TEXT DEFAULT NULL,
ADD CONSTRAINT `fk_cake_city` FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`);

-- 7. Photographers
ALTER TABLE `srv_photographers` 
ADD COLUMN `city_id` INT DEFAULT 1,
ADD COLUMN `location_address` TEXT DEFAULT NULL,
ADD CONSTRAINT `fk_photo_city` FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`);

-- 8. Custom Services (Others)
ALTER TABLE `srv_others` 
ADD COLUMN `city_id` INT DEFAULT 1,
ADD COLUMN `location_address` TEXT DEFAULT NULL,
ADD CONSTRAINT `fk_other_city` FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`);

-- 🗺️ SEED: Jordan Governorates & Primary Cities
DELETE FROM `cities`;
ALTER TABLE `cities` AUTO_INCREMENT = 1;

INSERT INTO `cities` (`name_ar`, `name_en`, `region`) VALUES 
('عمان', 'Amman', 'Central'),
('إربد', 'Irbid', 'North'),
('الزرقاء', 'Zarqa', 'Central'),
('المفرق', 'Mafraq', 'North'),
('جرش', 'Jerash', 'North'),
('عجلون', 'Ajloun', 'North'),
('السلط', 'As-Salt', 'Central'),
('مأدبا', 'Madaba', 'Central'),
('الكرك', 'Al-Karak', 'South'),
('الطفيلة', 'At-Tafilah', 'South'),
('معان', 'Ma\'an', 'South'),
('العقبة', 'Aqaba', 'South'),
('الرمثا', 'Ar-Ramtha', 'North'),
('البحر الميت', 'Dead Sea', 'Central');

SET FOREIGN_KEY_CHECKS = 1;
