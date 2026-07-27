import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  final baseUrl = Platform.environment['POS_BACKEND_TEST_URL'];
  test(
    'POS backend health contract',
    () async {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      expect(response.statusCode, 200);
    },
    skip: baseUrl == null ? 'Set POS_BACKEND_TEST_URL to run live Flutter/FastAPI integration tests' : false,
  );
}
