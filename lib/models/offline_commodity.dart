class OfflineCommodity {
  int id;
  String name;
  String? keywords;

  OfflineCommodity({
    required this.id,
    required this.name,
    this.keywords,
  });

// fromJson
  factory OfflineCommodity.fromJson(Map<String, dynamic> json) {
    return OfflineCommodity(
      id: json['id'],
      name: json['name'],
      keywords: json['keywords'],
    );
  }

  // toJson
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'keywords': keywords,
      };

  // copyWith
  OfflineCommodity copyWith({
    int? id,
    String? name,
    String? keywords,
  }) {
    return OfflineCommodity(
      id: id ?? this.id,
      name: name ?? this.name,
      keywords: keywords ?? this.keywords,
    );
  }
}
