class SpecificationGradeTolerance {
  String? specificationNumber;
  String? specificationVersion;
  double? gradeTolerancePercentage;
  double? specTolerancePercentage;
  int? severityDefectID;
  int? defectID;
  bool? overridden;
  String? defectName;
  String? severityDefectName;
  String? defectCategoryName;

  SpecificationGradeTolerance({
    this.specificationNumber,
    this.specificationVersion,
    this.gradeTolerancePercentage,
    this.specTolerancePercentage,
    this.severityDefectID,
    this.defectID,
    this.overridden,
    this.defectName,
    this.severityDefectName,
    this.defectCategoryName,
  });

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
    String? severityDefectName,
    String? defectCategoryName,
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
      severityDefectName: severityDefectName ?? this.severityDefectName,
      defectCategoryName: defectCategoryName ?? this.defectCategoryName,
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
      severityDefectName: json['severityDefectName'],
      defectCategoryName: json['defectCategoryName'],
    );
  }

  // toJson method
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['specificationNumber'] = specificationNumber;
    data['specificationVersion'] = specificationVersion;
    data['gradeTolerancePercentage'] = gradeTolerancePercentage;
    data['specTolerancePercentage'] = specTolerancePercentage;
    data['severityDefectID'] = severityDefectID;
    data['defectID'] = defectID;
    data['overridden'] = overridden;
    data['defectName'] = defectName;
    data['severityDefectName'] = severityDefectName;
    data['defectCategoryName'] = defectCategoryName;
    return data;
  }
}
