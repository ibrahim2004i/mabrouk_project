-- 📈 Dynamic Pricing Strategy Migration
-- Adding offering type and pricing unit to all service tables.

-- Halls
ALTER TABLE `srv_wedding_halls` 
ADD COLUMN `offering_type` ENUM('booking', 'purchase') DEFAULT 'booking',
ADD COLUMN `price_unit` ENUM('hour', 'day', 'event') DEFAULT 'event';

-- Chalets
ALTER TABLE `srv_chalets` 
ADD COLUMN `offering_type` ENUM('booking', 'purchase') DEFAULT 'booking',
ADD COLUMN `price_unit` ENUM('hour', 'day', 'event') DEFAULT 'day';

-- Dresses
ALTER TABLE `srv_dresses` 
ADD COLUMN `offering_type` ENUM('booking', 'purchase') DEFAULT 'booking',
ADD COLUMN `price_unit` ENUM('hour', 'day', 'event') DEFAULT 'event';

-- Suits
ALTER TABLE `srv_suits` 
ADD COLUMN `offering_type` ENUM('booking', 'purchase') DEFAULT 'booking',
ADD COLUMN `price_unit` ENUM('hour', 'day', 'event') DEFAULT 'event';

-- Cars
ALTER TABLE `srv_cars` 
ADD COLUMN `offering_type` ENUM('booking', 'purchase') DEFAULT 'booking',
ADD COLUMN `price_unit` ENUM('hour', 'day', 'event') DEFAULT 'event';

-- Cakes
ALTER TABLE `srv_cakes` 
ADD COLUMN `offering_type` ENUM('booking', 'purchase') DEFAULT 'purchase',
ADD COLUMN `price_unit` ENUM('hour', 'day', 'event') DEFAULT 'event';

-- Photographers
ALTER TABLE `srv_photographers` 
ADD COLUMN `offering_type` ENUM('booking', 'purchase') DEFAULT 'booking',
ADD COLUMN `price_unit` ENUM('hour', 'day', 'event') DEFAULT 'event';

-- Custom Services (others)
ALTER TABLE `srv_others` 
ADD COLUMN `offering_type` ENUM('booking', 'purchase') DEFAULT 'booking',
ADD COLUMN `price_unit` ENUM('hour', 'day', 'event') DEFAULT 'event';
