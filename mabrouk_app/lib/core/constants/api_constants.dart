class ApiConstants {
  static const String baseUrl = 'https://api.mabrouk.shop';
  
  // Auth
  static const String login = '/auth/login';
  static const String registerCustomer = '/auth/register/customer';
  static const String registerProvider = '/auth/register/provider';
  
  // Services
  static const String services = '/services'; // /services/{type}
  
  // Bookings
  static const String bookings = '/bookings';
  static const String myBookings = '/bookings/my-bookings';
  
  // Provider
  static const String providerStats = '/provider/stats';
  static const String providerBookings = '/provider/bookings';
  static const String providerServices = '/provider/my-services';
  static const String manualBooking = '/provider/bookings/manual';
  
  // Admin
  static const String admin = '/admin';
  static const String adminPending = '/admin/pending-services';
  static const String adminApprove = '/admin/approve-service';
  
  // Reference Data
  static const String cities = '/cities';
}
