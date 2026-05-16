import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mabrouk_app/core/network/http_client.dart';

final favoriteRepoProvider = Provider<FavoriteRepository>((ref) {
  return FavoriteRepository(ref.watch(httpClientProvider));
});

class FavoriteRepository {
  final HttpClient _client;
  FavoriteRepository(this._client);

  Future<List<String>> getFavorites() async {
    final response = await _client.get('/favorites');
    final body = jsonDecode(response.body);
    if (body['success']) {
      return List<String>.from(body['data']);
    }
    throw Exception(body['message']);
  }

  Future<void> toggleFavorite(String type, String id) async {
    final response = await _client.post('/favorites/toggle', data: {
      'type': type,
      'id': id,
    });
    final body = jsonDecode(response.body);
    if (!body['success']) {
      throw Exception(body['message']);
    }
  }
}
