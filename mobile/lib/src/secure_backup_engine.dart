import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

class SecureBackupEngine {
  const SecureBackupEngine._();

  static const _iterations = 120000;
  static final _cipher = AesGcm.with256bits();
  static final _kdf = Pbkdf2.hmacSha256(iterations: _iterations, bits: 256);

  static Future<String> encrypt({
    required String clearText,
    required String password,
  }) async {
    _validatePassword(password);
    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256));
    final key = await _kdf.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );
    final box = await _cipher.encrypt(utf8.encode(clearText), secretKey: key);
    return jsonEncode({
      'format': 'PHX-SECURE-BACKUP',
      'version': 1,
      'cipher': 'AES-256-GCM',
      'kdf': 'PBKDF2-HMAC-SHA256',
      'iterations': _iterations,
      'salt': base64Url.encode(salt),
      'box': base64Url.encode(box.concatenation()),
    });
  }

  static Future<String> decrypt({
    required String envelope,
    required String password,
  }) async {
    _validatePassword(password);
    try {
      final json = jsonDecode(envelope) as Map<String, dynamic>;
      if (json['format'] != 'PHX-SECURE-BACKUP' || json['version'] != 1) {
        throw const FormatException('Unknown encrypted Phoenix backup.');
      }
      final iterations = json['iterations'] as int;
      if (iterations < 100000 || iterations > 1000000) {
        throw const FormatException('Unsafe key-derivation parameters.');
      }
      final salt = base64Url.decode(json['salt'] as String);
      final bytes = base64Url.decode(json['box'] as String);
      final kdf = Pbkdf2.hmacSha256(iterations: iterations, bits: 256);
      final key = await kdf.deriveKeyFromPassword(
        password: password,
        nonce: salt,
      );
      final box = SecretBox.fromConcatenation(
        bytes,
        nonceLength: _cipher.nonceLength,
        macLength: _cipher.macAlgorithm.macLength,
      );
      final clear = await _cipher.decrypt(box, secretKey: key);
      return utf8.decode(clear, allowMalformed: false);
    } on FormatException {
      rethrow;
    } on Object {
      throw const FormatException(
        'Wrong password or damaged encrypted backup.',
      );
    }
  }

  static void _validatePassword(String password) {
    if (password.length < 10 || password.length > 200) {
      throw const FormatException(
        'The export password must contain 10–200 characters.',
      );
    }
  }
}
