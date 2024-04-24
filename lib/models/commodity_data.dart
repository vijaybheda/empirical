class Commodity {
  int? id;
  String? name;
  String? keywords;
  String? keywordName;

  Commodity(this.id, this.name, this.keywords);

  Commodity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    keywords = json['keywords'];
    keywordName = json['keywordName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['keywords'] = keywords;
    data['keywordName'] = keywordName;
    return data;
  }

  // copyWith
  Commodity copyWith({
    int? id,
    String? name,
    String? keywords,
    String? keywordName,
  }) {
    return Commodity(
      id ?? this.id,
      name ?? this.name,
      keywords ?? this.keywords,
    );
  }
}
