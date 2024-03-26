import 'dart:convert';

import 'package:bcrypt/bcrypt.dart';
import 'package:crypto/crypto.dart';

class SecurePassword {
  String hashPassword(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
    // Create a SHA-256 hash
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  bool validatePasswordHash(String password, String userHash) {
    // Validate password hash
    return hashPassword(password) == userHash;
  }

// Constant-time comparison to prevent timing attacks
  bool constantTimeEquality(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }
}
