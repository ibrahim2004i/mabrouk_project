import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mabrouk_app/core/storage/local_storage.dart';
import 'package:mabrouk_app/core/constants/api_constants.dart';

final httpClientProvider = Provider<HttpClient>((ref) {
  final storage = ref.watch(localStorageProvider);
  return HttpClient(storage);
});

class HttpClient {
  final LocalStorageService _storage;
  final String _baseUrl = ApiConstants.baseUrl;

  HttpClient(this._storage);

  Future<Map<String, String>> _getHeaders() async {
    final token = _storage.getToken();
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    Uri url = Uri.parse('$_baseUrl$endpoint');
    if (queryParameters != null) {
      url = url.replace(queryParameters: queryParameters.map((key, value) => MapEntry(key, value.toString())));
    }
    final headers = await _getHeaders();
    return await http.get(url, headers: headers);
  }

  Future<http.Response> post(String endpoint, {Map<String, dynamic>? data}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders();
    return await http.post(
      url, 
      headers: headers, 
      body: data != null ? jsonEncode(data) : null,
    );
  }

  Future<http.Response> put(String endpoint, {Map<String, dynamic>? data}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders();
    return await http.put(
      url, 
      headers: headers, 
      body: data != null ? jsonEncode(data) : null,
    );
  }

  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders();
    return await http.delete(url, headers: headers);
  }
}
