import 'dart:io';

extension FileName on File {
  Future<String> uniqueName(
    String name,
  ) async {
    String fileName = name.substring(0, name.lastIndexOf('.'));
    String fileType = name.substring(name.lastIndexOf('.'), name.length);
    String result =
        "$fileName-${DateTime.now().microsecondsSinceEpoch}$fileType";
    return '$path$result';
  }
}
