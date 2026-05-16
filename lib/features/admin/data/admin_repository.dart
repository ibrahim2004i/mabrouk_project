import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mabrouk_app/core/network/http_client.dart';

final adminRepoProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.watch(httpClientProvider));
});

class AdminRepository {
  final HttpClient _client;
  AdminRepository(this._client);

  /**
   * PROVIDER MANAGEMENT
   */
  Future<List<Map<String, dynamic>>> getProviders() async {
    final response = await _client.get('/admin/providers');
    final body = jsonDecode(response.body);
    if (body['success']) {
      return List<Map<String, dynamic>>.from(body['data']);
    } else {
      throw Exception(body['message']);
    }
  }

  Future<List<Map<String, dynamic>>> getPendingProviders() async {
    final response = await _client.get('/admin/providers/pending');
    final body = jsonDecode(response.body);
    if (body['success']) {
      return List<Map<String, dynamic>>.from(body['data']);
    } else {
      throw Exception(body['message']);
    }
  }

  Future<void> deleteProvider(int providerId) async {
    final response = await _client.post('/admin/providers/delete', data: {'id': providerId});
    final body = jsonDecode(response.body);
    if (!body['success']) {
      throw Exception(body['message']);
    }
  }

  Future<void> updateProviderStatus(int providerId, String status) async {
    final response = await _client.post('/admin/providers/update-status', data: {
      'id': providerId,
      'status': status,
    });
    final body = jsonDecode(response.body);
    if (!body['success']) {
      throw Exception(body['message']);
    }
  }

  /**
   * COMPLAINTS
   */
  Future<List<Map<String, dynamic>>> getComplaints() async {
    final response = await _client.get('/admin/complaints');
    final body = jsonDecode(response.body);
    if (body['success']) {
      return List<Map<String, dynamic>>.from(body['data']);
    } else {
      throw Exception(body['message']);
    }
  }

  Future<void> resolveComplaint(int complaintId, String notes) async {
    final response = await _client.post('/admin/complaints/resolve', data: {
      'id': complaintId,
      'notes': notes,
    });
    final body = jsonDecode(response.body);
    if (!body['success']) {
      throw Exception(body['message']);
    }
  }

  Future<void> rejectService(String type, int id) async {
    final response = await _client.post('/admin/reject-service', data: {
      'service_type': type,
      'id': id,
    });
    final body = jsonDecode(response.body);
    if (!body['success']) {
      throw Exception(body['message']);
    }
  }

  Future<List<dynamic>> getPendingServices() async {
    final response = await _client.get('/admin/pending-services');
    final body = jsonDecode(response.body);
    if (body['success']) {
      return body['data'];
    } else {
      throw Exception(body['message']);
    }
  }

  Future<void> approveService(String type, int id) async {
    final response = await _client.post('/admin/approve-service', data: {
      'service_type': type,
      'id': id,
    });
    final body = jsonDecode(response.body);
    if (!body['success']) {
      throw Exception(body['message']);
    }
  }
  
  /**
   * CUSTOMER COMPLAINT SUBMISSION
   */
  Future<void> submitComplaint({
    required int providerId,
    required String subject,
    required String description,
    int? bookingId,
  }) async {
    final response = await _client.post('/complaints', data: {
      'provider_id': providerId,
      'subject': subject,
      'description': description,
      if (bookingId != null) 'booking_id': bookingId,
    });
    final body = jsonDecode(response.body);
    if (!body['success']) {
      throw Exception(body['message']);
    }
  }
}
