import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mabrouk_app/core/network/http_client.dart';
import 'package:mabrouk_app/core/constants/api_constants.dart';

final referenceRepoProvider = Provider<ReferenceRepository>((ref) {
  return ReferenceRepository(ref.watch(httpClientProvider));
});

class City {
  final int id;
  final String nameAr;
  final String nameEn;

  City({required this.id, required this.nameAr, required this.nameEn});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      nameAr: json['name_ar'],
      nameEn: json['name_en'] ?? '',
    );
  }
}

class ReferenceRepository {
  final HttpClient _client;
  ReferenceRepository(this._client);

  Future<List<City>> getCities() async {
    try {
      final response = await _client.get(ApiConstants.cities);
      final body = jsonDecode(response.body);
      
      if (body['success']) {
        final List list = body['data'];
        return list.map((item) => City.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

final citiesProvider = FutureProvider<List<City>>((ref) async {
  return ref.watch(referenceRepoProvider).getCities();
});
