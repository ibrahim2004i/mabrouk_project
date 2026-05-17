-- 📱 Migration: Add WhatsApp Number to Service Providers
-- User objective: Allow customers to contact providers via WhatsApp directly.

ALTER TABLE `service_providers` 
ADD COLUMN `whatsapp_number` VARCHAR(20) DEFAULT NULL AFTER `office_phone`;
