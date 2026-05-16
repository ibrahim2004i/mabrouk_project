import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mabrouk_app/core/network/http_client.dart';
import 'package:mabrouk_app/core/constants/api_constants.dart';
import 'package:mabrouk_app/features/auth/domain/auth_models.dart';

final authRepoProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(httpClientProvider));
});

class AuthRepository {
  final HttpClient _client;

  AuthRepository(this._client);

  Future<AuthResponse> login(String phone, String password) async {
    final response = await _client.post(ApiConstants.login, data: {
      'phone': phone,
      'password': password,
    });
    
    final body = jsonDecode(response.body);
    if (body['success']) {
      return AuthResponse.fromJson(body['data']);
    } else {
      throw Exception(body['message']);
    }
  }

  Future<void> registerCustomer(String phone, String password, String name) async {
    final response = await _client.post(ApiConstants.registerCustomer, data: {
      'phone': phone,
      'password': password,
      'name': name,
    });
    
    final body = jsonDecode(response.body);
    if (!body['success']) {
      throw Exception(body['message']);
    }
  }

  Future<void> registerProvider({
    required String phone,
    required String password,
    required String brandName,
    required int cityId,
  }) async {
    final response = await _client.post(ApiConstants.registerProvider, data: {
      'phone': phone,
      'password': password,
      'brand_name': brandName,
      'city_id': cityId,
    });

    final body = jsonDecode(response.body);
    if (!body['success']) {
      throw Exception(body['message']);
    }
  }

  Future<AuthUser> updateProfile(Map<String, dynamic> data) async {
    final response = await _client.post('/auth/profile/update', data: data);
    
    final body = jsonDecode(response.body);
    if (body['success']) {
      return AuthUser.fromJson(body['data']['user']);
    } else {
      throw Exception(body['message']);
    }
  }
}
