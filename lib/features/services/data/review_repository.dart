import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mabrouk_app/core/network/http_client.dart';
import 'package:mabrouk_app/features/services/domain/review_model.dart';

final reviewRepoProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository(ref.watch(httpClientProvider));
});

class ReviewRepository {
  final HttpClient _client;
  ReviewRepository(this._client);

  Future<List<Review>> getServiceReviews(String type, int id) async {
    final response = await _client.get('/services/$type/$id/reviews');
    final body = jsonDecode(response.body);
    
    if (body['success']) {
      final List list = body['data'];
      return list.map((item) => Review.fromJson(item)).toList();
    } else {
      throw Exception(body['message']);
    }
  }

  Future<void> submitReview(Map<String, dynamic> data) async {
    final response = await _client.post('/reviews', data: data);
    final body = jsonDecode(response.body);
    
    if (!body['success']) {
      throw Exception(body['message']);
    }
  }

  Future<void> deleteReview(int id) async {
    final response = await _client.delete('/reviews/$id');
    final body = jsonDecode(response.body);
    
    if (!body['success']) {
      throw Exception(body['message']);
    }
  }
}
