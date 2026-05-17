import 'package:intl/intl.dart';

class Review {
  final int id;
  final int? bookingId; 
  final int customerId;
  final String customerName;
  final String? profileImage;
  final String serviceType;
  final int serviceId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  Review({
    required this.id,
    this.bookingId,
    required this.customerId,
    required this.customerName,
    this.profileImage,
    required this.serviceType,
    required this.serviceId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      bookingId: json['booking_id'] != null 
          ? (json['booking_id'] is int ? json['booking_id'] : int.parse(json['booking_id'].toString())) 
          : null,
      customerId: json['customer_id'] is int ? json['customer_id'] : int.parse(json['customer_id'].toString()),
      customerName: json['customer_name'] ?? 'defaultUserName',
      profileImage: json['profile_image'],
      serviceType: json['service_type'],
      serviceId: json['service_id'] is int ? json['service_id'] : int.parse(json['service_id'].toString()),
      rating: json['rating'] is int ? json['rating'] : int.parse(json['rating'].toString()),
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  String get formattedDate {
    return DateFormat('yyyy-MM-dd').format(createdAt);
  }
}
