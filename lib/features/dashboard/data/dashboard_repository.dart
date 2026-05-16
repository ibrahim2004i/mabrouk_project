import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mabrouk_app/core/network/http_client.dart';
import 'package:mabrouk_app/core/constants/api_constants.dart';

final dashboardRepoProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.watch(httpClientProvider));
});

class DashboardRepository {
  final HttpClient _client;
  DashboardRepository(this._client);

  Future<Map<String, dynamic>> getStats() async {
    final response = await _client.get(ApiConstants.providerStats);
    
    final body = jsonDecode(response.body);
    if (body['success']) {
      return body['data'];
    } else {
      throw Exception(body['message']);
    }
  }
}
