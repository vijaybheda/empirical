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
