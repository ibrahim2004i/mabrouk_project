import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mabrouk_app/core/network/http_client.dart';
import 'package:mabrouk_app/core/constants/api_constants.dart';
import 'package:mabrouk_app/features/bookings/domain/booking_model.dart';

final bookingRepoProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(ref.watch(httpClientProvider));
});

class BookingRepository {
  final HttpClient _client;
  BookingRepository(this._client);

  Future<List<Booking>> getMyBookings() async {
    final response = await _client.get(ApiConstants.myBookings);
    
    final body = jsonDecode(response.body);
    if (body['success']) {
      final List list = body['data'];
      return list.map((item) => Booking.fromJson(item)).toList();
    } else {
      throw Exception(body['message']);
    }
  }

  Future<void> createBooking(Map<String, dynamic> data) async {
    final response = await _client.post(ApiConstants.bookings, data: data);
    
    final body = jsonDecode(response.body);
    if (!body['success']) {
      if (body['data'] != null && body['data']['conflict'] != null) {
        throw jsonEncode(body); // Special handling for conflicts
      }
      throw Exception(body['message']);
    }
  }

  Future<List<Booking>> getProviderBookings() async {
    final response = await _client.get(ApiConstants.providerBookings);
    
    final body = jsonDecode(response.body);
    if (body['success']) {
      final List list = body['data'];
      return list.map((item) => Booking.fromJson(item)).toList();
    } else {
      throw Exception(body['message']);
    }
  }

  Future<List<Booking>> getServiceBookings(String type, int id) async {
    final response = await _client.get('/provider/services/$type/$id/bookings');
    
    final body = jsonDecode(response.body);
    if (body['success']) {
      final List list = body['data'];
      return list.map((item) => Booking.fromJson(item)).toList();
    } else {
      throw Exception(body['message']);
    }
  }

  Future<void> updateBookingStatus(int bookingId, String status) async {
    final response = await _client.post('/provider/bookings/update-status', data: {
      'id': bookingId,
      'status': status,
    });
    
    final body = jsonDecode(response.body);
    if (!body['success']) {
      throw Exception(body['message']);
    }
  }

  Future<void> rescheduleBooking(int bookingId, String date, String time, String endDate, String endTime) async {
    final response = await _client.post('/provider/bookings/reschedule', data: {
      'id': bookingId,
      'booking_date': date,
      'booking_time': time,
      'end_date': endDate,
      'end_time': endTime, 
    });
    
    final body = jsonDecode(response.body);
    if (!body['success']) {
      throw Exception(body['message']);
    }
  }
}
