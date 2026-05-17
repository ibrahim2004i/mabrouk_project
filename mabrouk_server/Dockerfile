FROM php:8.2-apache

# تثبيت الإضافات
RUN docker-php-ext-install pdo pdo_mysql

# تفعيل الـ Rewrite
RUN a2enmod rewrite

# ضبط المنفذ والمسار بشكل مباشر وبسيط
RUN sed -i 's/80/8080/g' /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf
RUN sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf

# نسخ الكود
COPY . /var/www/html/

# ضبط الصلاحيات
RUN chown -R www-data:www-data /var/www/html

EXPOSE 8080
CMD ["apache2-foreground"]
