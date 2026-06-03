import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pos_mobile/utils/debug_print.dart';

class KeyValidationService {
  static const String _baseUrl = String.fromEnvironment(
    'CRASH_REPORT_URL',
    defaultValue: 'http://10.158.13.2:8000',
  );

  /// Validate a key against the backend
  /// Returns true if key is valid and activated, false otherwise
  static Future<bool> validateKey({
    required String key,
    required String deviceId,
  }) async {
    try {
      cusDebugPrint('Validating key: $key for device: $deviceId');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/keys/validate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'key': key, 'device_id': deviceId}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['valid'] == true) {
          cusDebugPrint('Key validated successfully');
          return true;
        }
      } else if (response.statusCode == 400) {
        cusDebugPrint('Invalid or already used key');
        return false;
      } else {
        cusDebugPrint('Key validation failed: ${response.statusCode}');
        return false;
      }
    } on SocketException {
      cusDebugPrint('No internet connection for key validation');
      return false;
    } on http.ClientException {
      cusDebugPrint('Network error during key validation');
      return false;
    } catch (e) {
      cusDebugPrint('Error validating key: $e');
      return false;
    }

    return false;
  }

  /// Validate key details against the backend
  /// Returns a map with 'valid', 'message', and other keys
  static Future<Map<String, dynamic>> validateKeyDetails({
    required String key,
    required String deviceId,
  }) async {
    try {
      cusDebugPrint('Validating key details: $key for device: $deviceId');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/keys/validate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'key': key, 'device_id': deviceId}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'valid': responseData['valid'] ?? false,
          'message': responseData['message'] ?? '',
          'error_type': responseData['valid'] == false
              ? 'duplicate_device'
              : null,
        };
      } else {
        return {
          'valid': false,
          'message': 'Server returned status code: ${response.statusCode}',
        };
      }
    } on SocketException {
      throw const SocketException('No internet connection');
    } catch (e) {
      cusDebugPrint('Error checking key details: $e');
      rethrow;
    }
  }

  /// Check if a device has already activated a key
  static Future<bool> checkDeviceKeyStatus({required String deviceId}) async {
    try {
      cusDebugPrint('Checking key status for device: $deviceId');

      final response = await http
          .get(Uri.parse('$_baseUrl/api/keys/check/$deviceId'))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['has_key'] == true) {
          cusDebugPrint('Device already has activated key');
          return true;
        }
      }
    } on SocketException {
      cusDebugPrint('No internet connection checking key status');
    } on http.ClientException {
      cusDebugPrint('Network error checking key status');
    } catch (e) {
      cusDebugPrint('Error checking key status: $e');
    }

    return false;
  }
}
