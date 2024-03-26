class Specification {
  String? name;
  String? value;

  Specification({this.name, this.value});

  Specification.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['value'] = value;
    return data;
  }

  // fromMap
  Specification.fromMap(Map<String, dynamic> map) {
    name = map['name'];
    value = map['value'];
  }
  // toMap
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'value': value,
    };
  }

  // copyWith
  Specification copyWith({
    String? name,
    String? value,
  }) {
    return Specification(
      name: name ?? this.name,
      value: value ?? this.value,
    );
  }
}
