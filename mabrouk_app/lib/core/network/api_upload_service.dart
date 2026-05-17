import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mabrouk_app/core/constants/api_constants.dart';
import 'package:mabrouk_app/core/storage/local_storage.dart';
import 'package:path/path.dart' as path;

final apiUploadServiceProvider = Provider<ApiUploadService>((ref) {
  return ApiUploadService(ref.watch(localStorageProvider));
});

class ApiUploadService {
  final LocalStorageService _storage;
  static const String _baseUrl = ApiConstants.baseUrl;

  ApiUploadService(this._storage);

  Future<String?> uploadProfileImage(File imageFile, {Function(double)? onProgress}) async {
    try {
      final token = _storage.getToken();
      if (token == null) return null;

      final uri = Uri.parse('$_baseUrl/upload/profile');
      final request = ProgressMultipartRequest('POST', uri, onProgress: onProgress);
      
      request.headers['Authorization'] = 'Bearer $token';
      
      final extension = path.extension(imageFile.path).replaceFirst('.', '');
      request.files.add(await http.MultipartFile.fromPath(
        'image', 
        imageFile.path,
        contentType: MediaType('image', extension == 'jpg' ? 'jpeg' : extension),
      ));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);

      if (jsonResponse['success'] == true) {
        return jsonResponse['data']['url'];
      } else {
        print('Upload failed: ${jsonResponse['message']}');
        return null;
      }
    } catch (e) {
      print('Exception during upload: $e');
      return null;
    }
  }

  Future<List<String>?> uploadServiceMedia(int serviceId, String serviceType, List<File> images, {Function(double)? onProgress}) async {
    try {
      final token = _storage.getToken();
      if (token == null) return null;

      final uri = Uri.parse('$_baseUrl/upload/service-media');
      final request = ProgressMultipartRequest('POST', uri, onProgress: onProgress);
      
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['service_id'] = serviceId.toString();
      request.fields['service_type'] = serviceType;

      for (var imageFile in images) {
        final extension = path.extension(imageFile.path).replaceFirst('.', '');
        request.files.add(await http.MultipartFile.fromPath(
          'images[]', 
          imageFile.path,
          contentType: MediaType('image', extension == 'jpg' ? 'jpeg' : extension),
        ));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);

      if (jsonResponse['success'] == true) {
        return List<String>.from(jsonResponse['data']['urls']);
      } else {
        print('Upload failed: ${jsonResponse['message']}');
        return null;
      }
    } catch (e) {
      print('Exception during upload: $e');
      return null;
    }
  }

  Future<bool> deleteImage(String imageUrl) async {
    try {
      final token = _storage.getToken();
      if (token == null) return false;

      final uri = Uri.parse('$_baseUrl/upload/delete');
      final response = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'url': imageUrl}),
      );

      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['success'] == true;
    } catch (e) {
      print('Exception during delete: $e');
      return false;
    }
  }
}

class ProgressMultipartRequest extends http.MultipartRequest {
  final Function(double)? onProgress;

  ProgressMultipartRequest(String method, Uri url, {this.onProgress}) : super(method, url);

  @override
  http.ByteStream finalize() {
    final byteStream = super.finalize();
    if (onProgress == null) return byteStream;

    final totalBytes = contentLength;
    int bytesSent = 0;

    return http.ByteStream(byteStream.map((chunk) {
      bytesSent += chunk.length;
      onProgress!(bytesSent / totalBytes);
      return chunk;
    }));
  }
}
