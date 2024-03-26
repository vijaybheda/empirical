class DocumentItem {
  String? type;
  String? fileUrl;
  String? filePath;

  DocumentItem({this.type, this.fileUrl, this.filePath});

  // toJson
  Map<String, dynamic> toJson() => {
        'type': type,
        'fileUrl': fileUrl,
        'filePath': filePath,
      };

  // fromJson
  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    return DocumentItem(
      type: json['type'],
      fileUrl: json['fileUrl'],
      filePath: json['filePath'],
    );
  }

  // copyWith
  DocumentItem copyWith({
    String? type,
    String? fileUrl,
    String? filePath,
  }) {
    return DocumentItem(
      type: type ?? this.type,
      fileUrl: fileUrl ?? this.fileUrl,
      filePath: filePath ?? this.filePath,
    );
  }
}
