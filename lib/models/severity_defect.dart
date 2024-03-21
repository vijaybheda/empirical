class SeverityDefect {
  int? id;
  String? name;

  SeverityDefect({this.id, this.name});

  // toJson
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  // fromJson
  factory SeverityDefect.fromJson(Map<String, dynamic> json) {
    return SeverityDefect(
      id: json['id'],
      name: json['name'],
    );
  }

  // copyWith
  SeverityDefect copyWith({
    int? id,
    String? name,
  }) {
    return SeverityDefect(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
