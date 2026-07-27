import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:get_storage/get_storage.dart';

import 'network_environment.dart';

class PosApiException implements Exception {
  final int? statusCode;
  final String message;
  const PosApiException(this.message, {this.statusCode});
  @override
  String toString() => 'PosApiException($statusCode): $message';
}

class PosApiClient {
  static const String tokenStorageKey = 'pos_backend_access_token';
  static const Duration requestTimeout = Duration(seconds: 15);
  final http.Client _client;
  String? _token;

  PosApiClient({http.Client? client}) : _client = client ?? http.Client();

  void setToken(String token) => _token = token;

  String? get token => _token;

  Future<void> loadPersistedToken() async {
    _token = GetStorage().read<String>(tokenStorageKey);
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
    String shopId = 'default',
  }) async {
    final response = await request(
      'POST',
      '/api/v1/auth/login',
      body: {'username': username, 'password': password, 'shop_id': shopId},
    );
    final result = Map<String, dynamic>.from(response as Map);
    final token = result['access_token'] as String?;
    if (token == null || token.isEmpty) {
      throw const PosApiException('Backend did not return an access token');
    }
    _token = token;
    await GetStorage().write(tokenStorageKey, token);
    return result;
  }

  Future<Map<String, dynamic>> bootstrap({
    required String username,
    required String password,
    String shopId = 'default',
  }) async {
    final response = await request(
      'POST',
      '/api/v1/auth/bootstrap',
      body: {'username': username, 'password': password, 'shop_id': shopId},
    );
    final result = Map<String, dynamic>.from(response as Map);
    final token = result['access_token'] as String?;
    if (token == null || token.isEmpty) {
      throw const PosApiException('Backend did not return an access token');
    }
    _token = token;
    await GetStorage().write(tokenStorageKey, token);
    return result;
  }

  Future<void> clearToken() async {
    _token = null;
    await GetStorage().remove(tokenStorageKey);
  }

  Future<dynamic> request(String method, String path, {Object? body}) async {
    if (!NetworkConfiguration.usesBackend) {
      throw const PosApiException('POS backend is disabled in offline mode');
    }
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (_token != null) headers['Authorization'] = 'Bearer $_token';
    try {
      final uri = Uri.parse('${NetworkConfiguration.backendBaseUrl}$path');
      final encoded = body == null ? null : jsonEncode(body);
      final response = await (switch (method.toUpperCase()) {
        'GET' => _client.get(uri, headers: headers),
        'POST' => _client.post(uri, headers: headers, body: encoded),
        'PUT' => _client.put(uri, headers: headers, body: encoded),
        'PATCH' => _client.patch(uri, headers: headers, body: encoded),
        'DELETE' => _client.delete(uri, headers: headers),
        _ => throw const PosApiException('Unsupported HTTP method'),
      }).timeout(requestTimeout);
      dynamic decoded;
      if (response.body.isNotEmpty) decoded = jsonDecode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = decoded is Map && decoded['error'] is Map
            ? decoded['error']['message'].toString()
            : 'Backend request failed';
        throw PosApiException(message, statusCode: response.statusCode);
      }
      return decoded;
    } on PosApiException {
      rethrow;
    } catch (error) {
      throw PosApiException('Backend unavailable: $error');
    }
  }

  /// Sends image bytes as multipart/form-data. The image bytes are already
  /// resized by ImageUploadService; the backend applies the authoritative
  /// 500 KiB limit before writing the BLOB.
  Future<Map<String, dynamic>> uploadImage({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
    String? sourceMimeType,
    int? itemId,
    String purpose = 'item',
  }) async {
    if (!NetworkConfiguration.usesBackend) {
      throw const PosApiException('POS backend is disabled in offline mode');
    }
    final uri = Uri.parse(
      '${NetworkConfiguration.backendBaseUrl}/api/v1/images/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['purpose'] = purpose
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
          contentType: _mediaType(mimeType),
        ),
      );
    if (itemId != null) request.fields['item_id'] = itemId.toString();
    if (sourceMimeType != null && sourceMimeType.isNotEmpty) {
      request.fields['source_mime_type'] = sourceMimeType;
    }
    if (_token != null) request.headers['Authorization'] = 'Bearer $_token';
    try {
      final response = await http.Response.fromStream(
        await request.send().timeout(requestTimeout),
      );
      dynamic decoded;
      if (response.body.isNotEmpty) decoded = jsonDecode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = decoded is Map && decoded['error'] is Map
            ? decoded['error']['message'].toString()
            : 'Image upload failed';
        throw PosApiException(message, statusCode: response.statusCode);
      }
      if (decoded is! Map) {
        throw const PosApiException(
          'Backend returned an invalid image response',
        );
      }
      return Map<String, dynamic>.from(decoded);
    } on PosApiException {
      rethrow;
    } catch (error) {
      throw PosApiException('Backend unavailable: $error');
    }
  }

  String publicImageUrl(int imageId, {String extension = 'jpg'}) =>
      '${NetworkConfiguration.backendBaseUrl}/api/images/$imageId.$extension';

  MediaType _mediaType(String mimeType) {
    final parts = mimeType.split('/');
    return parts.length == 2
        ? MediaType(parts[0], parts[1])
        : MediaType('application', 'octet-stream');
  }

  void close() => _client.close();
}
