class Specification {
  String? specificationName, specificationVersion, specificationNumber;
  int? inspectionID;

  Specification({
    required this.specificationName,
    required this.specificationVersion,
    required this.specificationNumber,
    required this.inspectionID,
  });

  Specification.fromJson(Map<String, dynamic> json) {
    specificationName = json['Specification_Name'];
    specificationVersion = json['Specification_Version'];
    specificationNumber = json['Specification_Number'];
    inspectionID = json['Inspection_ID'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['Specification_Name'] = specificationName;
    data['Specification_Version'] = specificationVersion;
    data['Specification_Number'] = specificationNumber;
    data['Inspection_ID'] = inspectionID;
    return data;
  }

  // fromMap
  Specification.fromMap(Map<String, dynamic> map) {
    specificationName = map['Specification_Name'];
    specificationVersion = map['Specification_Version'];
    specificationNumber = map['Specification_Number'];
    inspectionID = map['Inspection_ID'];
  }
  // toMap
  Map<String, dynamic> toMap() {
    return {
      'Specification_Name': specificationName,
      'Specification_Version': specificationVersion,
      'Specification_Number': specificationNumber,
      'Inspection_ID': inspectionID,
    };
  }

  // copyWith
  Specification copyWith({
    String? specificationName,
    String? specificationVersion,
    String? specificationNumber,
    int? inspectionID,
  }) {
    return Specification(
      specificationName: specificationName ?? this.specificationName,
      specificationVersion: specificationVersion ?? this.specificationVersion,
      specificationNumber: specificationNumber ?? this.specificationNumber,
      inspectionID: inspectionID ?? this.inspectionID,
    );
  }
}
