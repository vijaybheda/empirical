class InspectionSpecification {
  int? id; // SQLite's row ID.
  int inspectionID;
  String number;
  String version;
  String name;

  InspectionSpecification({
    this.id,
    required this.inspectionID,
    required this.number,
    required this.version,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id, // Note: 'id' is managed by SQLite.
      'Inspection_ID': inspectionID,
      'Number': number,
      'Version': version,
      'Name': name,
    };
  }

  factory InspectionSpecification.fromMap(Map<String, dynamic> map) {
    return InspectionSpecification(
      id: map['id'],
      inspectionID: map['Inspection_ID'],
      number: map['Number'],
      version: map['Version'],
      name: map['Name'],
    );
  }

  // copyWith
  InspectionSpecification copyWith({
    int? id,
    int? inspectionID,
    String? number,
    String? version,
    String? name,
  }) {
    return InspectionSpecification(
      id: id ?? this.id,
      inspectionID: inspectionID ?? this.inspectionID,
      number: number ?? this.number,
      version: version ?? this.version,
      name: name ?? this.name,
    );
  }
}
