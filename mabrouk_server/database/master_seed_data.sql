-- 🏗️ MASTER SEED DATA: Mabrouk Project (Enhanced with Location)
-- كلمة المرور لجميع الحسابات: password123
SET FOREIGN_KEY_CHECKS = 0;

-- 🗑️ 0. CLEANUP (Ensure a fresh start)
DELETE FROM `media`;
DELETE FROM `bookings`;
DELETE FROM `complaints`;
DELETE FROM `srv_wedding_halls`;
DELETE FROM `srv_chalets`;
DELETE FROM `srv_dresses`;
DELETE FROM `srv_suits`;
DELETE FROM `srv_cars`;
DELETE FROM `srv_cakes`;
DELETE FROM `srv_photographers`;
DELETE FROM `srv_others`;
DELETE FROM `customers`;
DELETE FROM `service_providers`;
DELETE FROM `admins`;
DELETE FROM `users`;
ALTER TABLE `users` AUTO_INCREMENT = 1;

-- 🌍 0.1 SEED: CITIES (Required for all services)
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

-- 🏷️ 1. SEED: CATEGORIES
DELETE FROM `categories`;
ALTER TABLE `categories` AUTO_INCREMENT = 1;

INSERT INTO `categories` (`name_ar`, `name_en`, `icon_key`) VALUES 
('قاعات', 'Halls', 'business'),
('شاليهات', 'Chalets', 'holiday_village'), 
('فساتين', 'Dresses', 'checkroom'),
('بدلات', 'Suits', 'accessibility_new'), 
('مصورين', 'Photographers', 'camera_alt'),
('حلويات', 'Cakes', 'cake'),
('سيارات', 'Cars', 'directions_car'),
('أخرى', 'Others', 'star_border_rounded');

-- 1. 👥 SEED: USERS (Admin, 4 Providers, 4 Customers)
-- كلمة المرور لجميع الحسابات: password123
SET @pass = '$2y$10$fV3.p7Xh.SST6EIdvjYIeuYxK7eTqDQXU0H6.Z0l7I0fI.N8P0O1C';

INSERT INTO `users` (`id`, `phone_number`, `email`, `password_hash`, `role`) VALUES
(1, '0790000000', 'admin@mabrouk.com', @pass, 'admin'),
(2, '0791111111', 'provider1@gmail.com', @pass, 'provider'),
(3, '0792222222', 'provider2@gmail.com', @pass, 'provider'),
(4, '0793333333', 'provider3@gmail.com', @pass, 'provider'),
(5, '0794444444', 'provider4@gmail.com', @pass, 'provider'),
(6, '0785555555', 'customer1@gmail.com', @pass, 'customer'),
(7, '0786666666', 'customer2@gmail.com', @pass, 'customer'),
(8, '0787777777', 'customer3@gmail.com', @pass, 'customer'),
(9, '0788888888', 'customer4@gmail.com', @pass, 'customer');

-- 2. 🛡️ SEED: ADMINS
INSERT INTO `admins` (`user_id`, `nickname`, `access_level`) VALUES (1, 'Super Admin', 99);

-- 3. 🏢 SEED: SERVICE PROVIDERS
INSERT INTO `service_providers` (`user_id`, `brand_name`, `city_id`, `is_verified`, `overall_rating`, `status`) VALUES
(2, 'مجموعة القصور الملكية', 1, 1, 4.8, 'active'),
(3, 'منتجعات سياحية فاخرة', 4, 1, 4.5, 'active'),
(4, 'ليدي بوتيك للأزياء', 1, 1, 4.9, 'active'),
(5, 'مخبز وحلويات الشيف', 3, 1, 4.7, 'active');

-- 4. 👤 SEED: CUSTOMERS
INSERT INTO `customers` (`user_id`, `full_name`, `gender`, `preferred_city_id`) VALUES
(6, 'أحمد العلي', 'male', 1),
(7, 'سارة محمود', 'female', 1),
(8, 'محمد حسن', 'male', 2),
(9, 'ليان خالد', 'female', 4);

-- 5. 🏰 SEED: WEDDING HALLS (4 Items)
INSERT INTO `srv_wedding_halls` (`provider_id`, `name`, `base_price`, `max_capacity`, `hall_type`, `city_id`, `location_address`, `status`) VALUES
(2, 'قاعة الكريستال الملكية', 1500.00, 500, 'indoor', 1, 'عمان - شارع المدينة المنورة', 'approved'),
(2, 'قاعة اللؤلؤة الخارجية', 1200.00, 300, 'outdoor', 1, 'عمان - طريق المطار', 'approved'),
(2, 'قاعة الماسة الكبرى', 2500.00, 800, 'mixed', 1, 'عمان - دابوق', 'approved'),
(2, 'قاعة الورود الاقتصادية', 900.00, 200, 'indoor', 2, 'إربد - شارع الجامعة', 'approved');

-- 6. 🏡 SEED: CHALETS (4 Items)
INSERT INTO `srv_chalets` (`provider_id`, `name`, `price_per_night`, `rooms_count`, `has_pool`, `city_id`, `location_address`, `status`) VALUES
(3, 'شاليه غروب الشمس الهادئ', 150.00, 3, 1, 4, 'المفرق - منطقة المزارع', 'approved'),
(3, 'شاليه البحر الميت كوزي', 250.00, 4, 1, 14, 'منطقة الفنادق - البحر الميت', 'approved'),
(3, 'شاليه النخيل الجرشية', 120.00, 2, 0, 5, 'جرش - بالقرب من الآثار', 'approved'),
(3, 'شاليه الفخامة العقباوي', 300.00, 5, 1, 12, 'العقبة - جنوب المدينة', 'approved');

-- 7. 👗 SEED: DRESSES (4 Items)
INSERT INTO `srv_dresses` (`provider_id`, `title`, `price`, `sizes_available`, `business_mode`, `city_id`, `location_address`, `status`) VALUES
(4, 'فستان زفاف دانتيل فرنسي', 800.00, 'S,M,L', 'rent', 1, 'عمان - الصويفية', 'approved'),
(4, 'فستان الخطوبة المخملي الأحمر', 350.00, 'M,L', 'buy', 1, 'عمان - جبل الحسين', 'approved'),
(4, 'فستان سهرة كلاسيكي أسود', 200.00, 'S,M,L,XL', 'both', 3, 'الزرقاء - شارع السعادة', 'approved'),
(4, 'فستان العروس العصرية الحديث', 1200.00, 'S,M', 'buy', 1, 'عمان - عبدون', 'approved');

-- 8. 🚗 SEED: CARS (4 Items)
INSERT INTO `srv_cars` (`provider_id`, `brand`, `model`, `price_per_day`, `with_driver`, `city_id`, `location_address`, `status`) VALUES
(2, 'Mercedes', 'S-Class 2024 White', 200.00, 1, 1, 'عمان - مجمع بنك الإسكان', 'approved'),
(2, 'Range Rover', 'Vogue Black Edition', 250.00, 1, 1, 'عمان - الصويفية', 'approved'),
(3, 'Ford', 'Mustang Convertible Yellow', 150.00, 0, 12, 'العقبة - شارع الفنادق', 'approved'),
(2, 'Rolls Royce', 'Ghost Silver', 600.00, 1, 1, 'عمان - بوليفارد العبدلي', 'approved');

-- 9. 🎂 SEED: CAKES (4 Items)
INSERT INTO `srv_cakes` (`provider_id`, `name`, `base_price`, `preparation_days`, `city_id`, `location_address`, `status`) VALUES
(5, 'كيكة الزفاف الملكية الفاخرة', 450.00, 5, 1, 'عمان - شارع مكة', 'approved'),
(5, 'كيكة شوكولاتة التخرج المميزة', 60.00, 2, 3, 'الزرقاء - الوسط التجاري', 'approved'),
(5, 'كيكة أعياد ميلاد أطفال كرتون', 45.00, 2, 2, 'إربد - شارع الحصن', 'approved'),
(5, 'تشيز كيك الفراولة للمناسبات', 35.00, 1, 1, 'عمان - تلاع العلي', 'approved');

-- 10. 📸 SEED: PHOTOGRAPHERS (4 Items)
INSERT INTO `srv_photographers` (`provider_id`, `package_name`, `base_price`, `package_details`, `city_id`, `location_address`, `status`) VALUES
(3, 'باقة الفيديو والسيشن الكامل', 500.00, 'تصوير يوم كامل بـ 3 كاميرات مع ألبوم حراري', 1, 'عمان - جبل عمان', 'approved'),
(3, 'باقة الخطوبة الاقتصادية', 150.00, 'تصوير ساعتين + فلاش ميموري بـ 100 صورة', 2, 'إربد - أيدون', 'approved'),
(4, 'تصوير الأزياء الفاشن سيشن', 200.00, 'تصوير مودل داخلي مع معالجة احترافية', 1, 'عمان - الصويفية', 'approved'),
(3, 'باقة الدرون الجوية 4K', 300.00, 'تصوير جوي لكافة تفاصيل الحفل الخارجي', 14, 'العقبة - تالا باي', 'approved');

SET FOREIGN_KEY_CHECKS = 1;
