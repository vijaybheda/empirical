class DocumentItemData {
  String? type;
  String? fileURL;
  String? fileContent;

  DocumentItemData({this.type, this.fileURL, this.fileContent});

  // toJson
  Map<String, dynamic> toJson() => {
        'type': type,
        'fileURL': fileURL,
        'fileContent': fileContent,
      };

  // fromJson
  factory DocumentItemData.fromJson(Map<String, dynamic> json) {
    return DocumentItemData(
      type: json['type'],
      fileURL: json['fileURL'],
      fileContent: json['fileContent'],
    );
  }

  // copyWith
  DocumentItemData copyWith({
    String? type,
    String? fileURL,
    String? fileContent,
  }) {
    return DocumentItemData(
      type: type ?? this.type,
      fileURL: fileURL ?? this.fileURL,
      fileContent: fileContent ?? this.fileContent,
    );
  }
}
