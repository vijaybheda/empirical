class SpecificationGradeTolerance {
  String? specificationNumber;
  String? specificationVersion;
  double? gradeTolerancePercentage;
  double? specTolerancePercentage;
  int? severityDefectID;
  int? defectID;
  bool? overridden;
  String? defectName;

  SpecificationGradeTolerance(
      {this.specificationNumber,
      this.specificationVersion,
      this.gradeTolerancePercentage,
      this.specTolerancePercentage,
      this.severityDefectID,
      this.defectID,
      this.overridden,
      this.defectName});

// copyWith method
  SpecificationGradeTolerance copyWith({
    String? specificationNumber,
    String? specificationVersion,
    double? gradeTolerancePercentage,
    double? specTolerancePercentage,
    int? severityDefectID,
    int? defectID,
    bool? overridden,
    String? defectName,
  }) {
    return SpecificationGradeTolerance(
      specificationNumber: specificationNumber ?? this.specificationNumber,
      specificationVersion: specificationVersion ?? this.specificationVersion,
      gradeTolerancePercentage:
          gradeTolerancePercentage ?? this.gradeTolerancePercentage,
      specTolerancePercentage:
          specTolerancePercentage ?? this.specTolerancePercentage,
      severityDefectID: severityDefectID ?? this.severityDefectID,
      defectID: defectID ?? this.defectID,
      overridden: overridden ?? this.overridden,
      defectName: defectName ?? this.defectName,
    );
  }

// fromJson method
  factory SpecificationGradeTolerance.fromJson(Map<String, dynamic> json) {
    return SpecificationGradeTolerance(
      specificationNumber: json['specificationNumber'],
      specificationVersion: json['specificationVersion'],
      gradeTolerancePercentage: json['gradeTolerancePercentage'],
      specTolerancePercentage: json['specTolerancePercentage'],
      severityDefectID: json['severityDefectID'],
      defectID: json['defectID'],
      overridden: json['overridden'],
      defectName: json['defectName'],
    );
  }

  // toJson method
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['specificationNumber'] = this.specificationNumber;
    data['specificationVersion'] = this.specificationVersion;
    data['gradeTolerancePercentage'] = this.gradeTolerancePercentage;
    data['specTolerancePercentage'] = this.specTolerancePercentage;
    data['severityDefectID'] = this.severityDefectID;
    data['defectID'] = this.defectID;
    data['overridden'] = this.overridden;
    data['defectName'] = this.defectName;
    return data;
  }
}
