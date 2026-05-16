/**
 * 🌐 API Configuration Constants
 * Project: Mabrouk App
 */

class ApiConfig {
  // للتشغيل على المحاكي (Emulator) استخدم 10.0.2.2
  // للتشغيل على جهاز حقيقي، استخدم IP الجهاز الذي يشغل السيرفر
  static const String baseUrl = 'https://mabrouk-api-v2-984506041911.europe-west3.run.app';

  // الرؤوس المشتركة (Common Headers)
  static Map<String, String> get headers => {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  // روابط المسارات (Endpoints)
  static const String login = '$baseUrl/auth/login.php';
  static const String register = '$baseUrl/auth/register.php';
  static const String categories = '$baseUrl/content/categories.php';
  static const String cities = '$baseUrl/content/cities.php';
  static const String services = '$baseUrl/services/get_all.php';
  static const String createBooking = '$baseUrl/bookings/create.php';
  static const String userBookings = '$baseUrl/bookings/get_user_bookings.php';
  static const String createService = '$baseUrl/services/create.php';
  
  // مسارات الرفع (Upload Endpoints)
  static const String uploadProfile = '$baseUrl/upload/profile';
  static const String uploadServiceMedia = '$baseUrl/upload/service-media';
  static const String deleteImage = '$baseUrl/upload/delete';
}
