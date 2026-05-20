import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class AuthSecurity {
  AuthSecurity._();

  static const String _hashedPrefix = 'v1';

  static String hashPassword(String plainTextPassword) {
    final random = Random.secure();
    final saltBytes = List<int>.generate(16, (_) => random.nextInt(256));
    final salt = base64Url.encode(saltBytes);
    final digest = _digest(salt, plainTextPassword);
    return '$_hashedPrefix\n$salt\n$digest';
  }

  static bool verifyPassword({
    required String storedPassword,
    required String inputPassword,
  }) {
    final parsed = _parse(storedPassword);
    if (parsed == null) {
      // Legacy plaintext fallback for old local data.
      return storedPassword == inputPassword;
    }

    final digest = _digest(parsed.salt, inputPassword);
    return digest == parsed.digest;
  }

  static bool isHashed(String storedPassword) {
    return _parse(storedPassword) != null;
  }

  static String? migrateLegacyPasswordIfNeeded({
    required String storedPassword,
    required String inputPassword,
  }) {
    if (isHashed(storedPassword)) {
      return null;
    }

    if (storedPassword != inputPassword) {
      return null;
    }

    return hashPassword(inputPassword);
  }

  static String _digest(String salt, String plainTextPassword) {
    final bytes = utf8.encode('$salt:$plainTextPassword');
    return sha256.convert(bytes).toString();
  }

  static _ParsedHash? _parse(String value) {
    final parts = value.split('\n');
    if (parts.length != 3) return null;
    if (parts[0] != _hashedPrefix) return null;
    if (parts[1].isEmpty || parts[2].isEmpty) return null;
    return _ParsedHash(salt: parts[1], digest: parts[2]);
  }
}

class _ParsedHash {
  final String salt;
  final String digest;

  const _ParsedHash({required this.salt, required this.digest});
}
