import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

class SecurePassword {
  static const int iterations = 5000;
  static const int keyLength = 512;

  static String generatePasswordHash(String password) {
    final salt = _getSalt();
    final hash = _generateHash(password, salt);

    return '${_bytesToHex(salt)}:${_bytesToHex(hash)}';
  }

  static bool validatePasswordHash(String password, String storedHashWithSalt) {
    final parts = storedHashWithSalt.split(':');
    if (parts.length != 2) {
      return false;
    }

    final salt = _hexToBytes(parts[0]);
    final hash = _hexToBytes(parts[1]);
    final testHash = _generateHash(password, salt);

    return _constantTimeComparison(hash, testHash);
  }

  static Uint8List _getSalt() {
    final rnd = FortunaRandom();
    rnd.seed(KeyParameter(_seed32Bytes()));
    return rnd.nextBytes(16); // 128-bit salt
  }

  static Uint8List _generateHash(String password, Uint8List salt) {
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA1Digest(), 64))
      ..init(Pbkdf2Parameters(salt, iterations, keyLength ~/ 8));
    return pbkdf2.process(Uint8List.fromList(utf8.encode(password)));
  }

  static bool _constantTimeComparison(List<int> a, List<int> b) {
    if (a.length != b.length) {
      return false;
    }
    int diff = 0;
    for (int i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }

  static String _bytesToHex(Uint8List bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  static Uint8List _hexToBytes(String hex) {
    final length = hex.length;
    final bytes = Uint8List(length ~/ 2);
    for (int i = 0; i < length; i += 2) {
      final byteString = hex.substring(i, i + 2);
      final byteValue = int.parse(byteString, radix: 16);
      bytes[i ~/ 2] = byteValue;
    }
    return bytes;
  }

  static Uint8List _seed32Bytes() {
    return Uint8List.fromList(List<int>.generate(32, (i) => i));
  }
}
