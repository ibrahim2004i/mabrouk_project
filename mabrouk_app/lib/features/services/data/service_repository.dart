import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mabrouk_app/core/network/http_client.dart';
import 'package:mabrouk_app/core/constants/api_constants.dart';
import 'package:mabrouk_app/features/services/domain/service_models.dart';

final serviceRepoProvider = Provider<ServiceRepository>((ref) {
  return ServiceRepository(ref.watch(httpClientProvider));
});

class ServiceRepository {
  final HttpClient _client;
  ServiceRepository(this._client);

  Future<List<ServiceBase>> getServicesByType(String type, {int? cityId}) async {
    final response = await _client.get(
      '${ApiConstants.services}/$type', 
      queryParameters: {
        if (cityId != null) 'city_id': cityId,
      },
    );
    
    final body = jsonDecode(response.body);
    if (body['success']) {
      final List list = body['data'];
      return list.map((item) {
        switch (type) {
          case 'hall': return WeddingHall.fromJson(item);
          case 'dress': return Dress.fromJson(item);
          case 'chalet': return Chalet.fromJson(item);
          case 'suit': return Suit.fromJson(item);
          case 'car': return Car.fromJson(item);
          case 'cake': return Cake.fromJson(item);
          case 'photographer': return Photographer.fromJson(item);
          default: return WeddingHall.fromJson(item);
        }
      }).toList();

    } else {
      throw Exception(body['message']);
    }
  }

  Future<ServiceBase> getServiceById(String type, String id) async {
    final response = await _client.get('${ApiConstants.services}/$type/$id');
    
    final body = jsonDecode(response.body);
    if (body['success']) {
      return ServiceBase.fromJson(body['data']);
    } else {
      throw Exception(body['message']);
    }
  }

  Future<int> createService(String type, Map<String, dynamic> data) async {
    final response = await _client.post(
      '${ApiConstants.services}/$type', 
      data: data,
    );
    
    final body = jsonDecode(response.body);
    if (!body['success']) {
      throw Exception(body['message']);
    }
    return int.parse(body['data']['id'].toString());
  }

  Future<void> updateService(String type, int id, Map<String, dynamic> data) async {
    final response = await _client.put(
      '${ApiConstants.services}/$type/$id', 
      data: data,
    );
    
    final body = jsonDecode(response.body);
    if (!body['success']) {
      throw Exception(body['message']);
    }
  }

  Future<List<dynamic>> getMyServices({int? providerId}) async {
    final url = providerId != null 
        ? '${ApiConstants.admin}/provider-services?id=$providerId'
        : ApiConstants.providerServices;
        
    final response = await _client.get(url);
    
    final body = jsonDecode(response.body);
    if (body['success']) {
      return body['data'];
    } else {
      throw Exception(body['message']);
    }
  }
}
