class CommodityKeywords {
  int? id;
  String? keywords;

  CommodityKeywords({
    required this.id,
    this.keywords,
  });

// fromJson
  factory CommodityKeywords.fromJson(Map<String, dynamic> json) {
    return CommodityKeywords(
      id: json['id'],
      keywords: json['keywords'],
    );
  }

  // toJson
  Map<String, dynamic> toJson() => {
        'id': id,
        'keywords': keywords,
      };

  // copyWith
  CommodityKeywords copyWith({
    int? id,
    String? keywords,
  }) {
    return CommodityKeywords(
      id: id ?? this.id,
      keywords: keywords ?? this.keywords,
    );
  }
}
