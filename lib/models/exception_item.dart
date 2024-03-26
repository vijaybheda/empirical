class ExceptionItem {
  String? shortDescription;
  String? longDescription;
  String? expirationDate;

  ExceptionItem({
    this.shortDescription,
    this.longDescription,
    this.expirationDate,
  });

  ExceptionItem.fromJson(Map<String, dynamic> json) {
    shortDescription = json['shortDescription'];
    longDescription = json['longDescription'];
    expirationDate = json['expirationDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['shortDescription'] = shortDescription;
    data['longDescription'] = longDescription;
    data['expirationDate'] = expirationDate;
    return data;
  }

  ExceptionItem copyWith({
    String? shortDescription,
    String? longDescription,
    String? expirationDate,
  }) {
    return ExceptionItem(
      shortDescription: shortDescription ?? this.shortDescription,
      longDescription: longDescription ?? this.longDescription,
      expirationDate: expirationDate ?? this.expirationDate,
    );
  }
}
