import 'package:get_storage/get_storage.dart';
import 'package:pos_mobile/services/network_environment.dart';
import 'package:pos_mobile/services/pos_api_client.dart';

Future<void> main() async {
  final baseUrl = const String.fromEnvironment(
    'POS_BACKEND_URL',
    defaultValue: 'http://127.0.0.1:8765',
  );
  NetworkConfiguration.configureForTesting(
    environment: 'online',
    backendBaseUrl: baseUrl,
    shopId: 'default',
  );
  await GetStorage.init();
  final client = PosApiClient();
  final login = await client.login(
    username: const String.fromEnvironment('POS_TEST_USERNAME', defaultValue: 'owner'),
    password: const String.fromEnvironment('POS_TEST_PASSWORD', defaultValue: 'password123'),
    shopId: 'default',
  );
  if (client.token == null || login['user'] == null) {
    throw StateError('login/token contract failed');
  }
  final users = await client.request('GET', '/api/v1/users') as Map;
  final settings = await client.request('PUT', '/api/v1/settings/live-smoke', body: {
    'key': 'live-smoke',
    'value': 'ok',
  }) as Map;
  if (users['items'] is! List || settings['value'] != 'ok') {
    throw StateError('authenticated domain API contract failed');
  }
  client.close();
}
