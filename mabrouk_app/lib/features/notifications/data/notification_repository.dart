import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mabrouk_app/core/network/http_client.dart';
import 'package:mabrouk_app/features/notifications/domain/notification_model.dart';

final notificationRepoProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(httpClientProvider));
});

class NotificationRepository {
  final HttpClient _client;

  NotificationRepository(this._client);

  Future<List<AppNotification>> getNotifications() async {
    final response = await _client.get('/notifications');
    final body = jsonDecode(response.body);
    
    if (body['success']) {
      return (body['data'] as List)
          .map((json) => AppNotification.fromJson(json))
          .toList();
    }
    throw Exception(body['message']);
  }

  Future<void> markAsRead({int? id}) async {
    await _client.post('/notifications/read', data: id != null ? {'id': id} : {});
  }
}
