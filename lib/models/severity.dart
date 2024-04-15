class Severity {
  int? id;
  String? name;
  String? color;
  String? abbrevation;
  int? sortSequence;

  Severity(int? id, String? name, String? color, String? abbrevation,
      int? sortSequence) {
    this.id = id;
    this.name = name;
    this.color = color;
    this.abbrevation = abbrevation;
    this.sortSequence = sortSequence;
  }

  Severity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    color = json['color'];
    abbrevation = json['abbrevation'];
    sortSequence = json['sortSequence'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['color'] = color;
    data['abbrevation'] = abbrevation;
    data['sortSequence'] = sortSequence;
    return data;
  }

  // copyWith
  Severity copyWith({
    int? id,
    String? name,
    String? color,
    String? abbrevation,
    int? sortSequence,
  }) {
    return Severity(
      id ?? this.id,
      name ?? this.name,
      color ?? this.color,
      abbrevation ?? this.abbrevation,
      sortSequence ?? this.sortSequence,
    );
  }
}
