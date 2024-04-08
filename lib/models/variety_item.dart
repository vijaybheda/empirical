class VarietyItem {
  int? id;
  String? name;
  String? size;

  VarietyItem(int? id, String? name, String? size) {
    this.id = id;
    this.name = name;
    this.size = size;
  }

  VarietyItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    size = json['size'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['size'] = size;
    return data;
  }

// copyWith
  VarietyItem copyWith({
    int? id,
    String? name,
    String? size,
  }) {
    return VarietyItem(
      id ?? this.id,
      name ?? this.name,
      size ?? this.size,
    );
  }
}
