class CustomException implements Exception {
  final String message;
  final int? code;

  CustomException(this.message, {this.code});

  @override
  String toString() => message;
}
