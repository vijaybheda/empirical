extension IntExtension on int {
  bool equals(int other) {
    return this == other;
  }
}

extension StringExtension on String {
  bool equals(String? other) {
    return this == other;
  }

  bool equalsIgnoreCase(String? other) {
    return toLowerCase() == other?.toLowerCase();
  }
}

extension StringNullableExtension on String? {
  bool isNullOrEmpty() {
    return this == null || this!.isEmpty;
  }

  bool equals(String? other) {
    return this == other;
  }

  bool equalsIgnoreCase(String? other) {
    return other == other;
  }
}

extension NullableIntExtension on int? {
  bool isNull() {
    return this == null;
  }

  bool equals(int? other) {
    return this == other;
  }
}
