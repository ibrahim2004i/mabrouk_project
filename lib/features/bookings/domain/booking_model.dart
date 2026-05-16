class Booking {
  final int id;
  final int? customerId; // Nullable for manual bookings
  final String? customerName; 
  final String? customerPhone; // 🟢 New
  final String? manualCustomerName; 
  final int providerId;
  final String serviceType;
  final int serviceId;
  final double totalPrice;
  final String bookingDate;
  final String? endDate; // 🟢 New
  final String? bookingTime;
  final String? endTime; // 🟢 New
  final String status;
  final String? customerNotes;
  final String? brandName; 
  final String? priceUnit; // 🟢 New

  Booking({
    required this.id,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.manualCustomerName,
    required this.providerId,
    required this.serviceType,
    required this.serviceId,
    required this.totalPrice,
    required this.bookingDate,
    this.endDate,
    this.bookingTime,
    this.endTime,
    required this.status,
    this.customerNotes,
    this.brandName,
    this.priceUnit,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      customerId: json['customer_id'] != null ? (json['customer_id'] is int ? json['customer_id'] : int.parse(json['customer_id'].toString())) : null,
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      manualCustomerName: json['manual_customer_name'],
      providerId: json['provider_id'] is int ? json['provider_id'] : int.parse(json['provider_id'].toString()),
      serviceType: json['service_type'],
      serviceId: json['service_id'] is int ? json['service_id'] : int.parse(json['service_id'].toString()),
      totalPrice: double.parse(json['total_price'].toString()),
      bookingDate: json['booking_date'],
      endDate: json['end_date'],
      bookingTime: json['booking_time'],
      endTime: json['end_time'],
      status: json['status'],
      customerNotes: json['customer_notes'],
      brandName: json['brand_name'],
      priceUnit: json['price_unit'],
    );
  }
}
