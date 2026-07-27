import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:pos_mobile/services/network_environment.dart';
import 'package:pos_mobile/services/pos_api_client.dart';
import 'package:pos_mobile/services/pos_repository.dart';

class _FakeClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final body = jsonEncode({
      'access_token': 'contract-token',
      'token_type': 'bearer',
      'user': {'id': 1, 'username': 'owner', 'role': 'owner', 'active': true},
    });
    return http.StreamedResponse(Stream.value(utf8.encode(body)), 200, headers: {'content-type': 'application/json'});
  }
}

void main() {
  test('backend login persists JWT and preserves mode selection', () async {
    NetworkConfiguration.configureForTesting(environment: 'online', backendBaseUrl: 'http://test');
    await GetStorage.init();
    final client = PosApiClient(client: _FakeClient());
    final result = await client.login(username: 'owner', password: 'password123');
    expect(result['access_token'], 'contract-token');
    expect(client.token, 'contract-token');
    expect(GetStorage().read<String>(PosApiClient.tokenStorageKey), 'contract-token');
    expect(NetworkConfiguration.usesBackend, isTrue);
    await client.clearToken();
  });

  test('repository read policy falls back only in hybrid mode', () async {
    final repository = PosRepository(api: PosApiClient(client: _FakeClient()));
    NetworkConfiguration.configureForTesting(environment: 'hybrid', backendBaseUrl: 'http://test');
    final value = await repository.readWithMode(
      local: () async => 'cache',
      remote: () async => throw const PosApiException('offline'),
    );
    expect(value, 'cache');

    NetworkConfiguration.configureForTesting(environment: 'online', backendBaseUrl: 'http://test');
    await expectLater(
      repository.readWithMode(
        local: () async => 'cache',
        remote: () async => throw const PosApiException('offline'),
      ),
      throwsA(isA<PosApiException>()),
    );
  });
}
