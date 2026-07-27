import 'package:flutter_dotenv/flutter_dotenv.dart';

enum ApplicationNetworkEnvironment { offline, online, hybrid }

class NetworkConfiguration {
  NetworkConfiguration._();

  static ApplicationNetworkEnvironment get environment => _environment;
  static String get backendBaseUrl => _backendBaseUrl;
  static String get shopId => _shopId;
  static ApplicationNetworkEnvironment _environment =
      ApplicationNetworkEnvironment.offline;
  static String _backendBaseUrl = 'http://localhost:8000';
  static String _shopId = 'default';

  static Future<void> initialize() async {
    final raw = dotenv.env['APPLICATION_NETWORK_ENVIRONMENT']
        ?.trim()
        .toLowerCase();
    if (raw == null || raw.isEmpty) {
      throw StateError('APPLICATION_NETWORK_ENVIRONMENT is required');
    }
    _setEnvironment(raw);
    _backendBaseUrl = (dotenv.env['POS_BACKEND_URL'] ?? _backendBaseUrl)
        .replaceAll(RegExp(r'/$'), '');
    _shopId = (dotenv.env['POS_SHOP_ID'] ?? _shopId).trim();
  }

  static void configureForTesting({
    required String environment,
    String? backendBaseUrl,
    String? shopId,
  }) {
    _setEnvironment(environment.trim().toLowerCase());
    if (backendBaseUrl != null) _backendBaseUrl = backendBaseUrl.replaceAll(RegExp(r'/$'), '');
    if (shopId != null && shopId.trim().isNotEmpty) _shopId = shopId.trim();
  }

  static void _setEnvironment(String raw) {
    _environment = switch (raw) {
      'offline' => ApplicationNetworkEnvironment.offline,
      'online' => ApplicationNetworkEnvironment.online,
      'hybrid' => ApplicationNetworkEnvironment.hybrid,
      _ => throw StateError(
        'Invalid APPLICATION_NETWORK_ENVIRONMENT: $raw. Expected offline, online, or hybrid',
        ),
    };
  }

  static bool get usesBackend =>
      environment != ApplicationNetworkEnvironment.offline;
  static bool get allowsOfflineWrites =>
      environment != ApplicationNetworkEnvironment.online;
}
