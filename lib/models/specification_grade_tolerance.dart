import 'package:pverify/services/database/column_names.dart';

class SpecificationGradeTolerance {
  String? specificationNumber;
  String? specificationVersion;
  int? gradeTolerancePercentage;
  int? specTolerancePercentage;
  String? severityDefectID;
  int? defectID;
  int? overridden;
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
    int? gradeTolerancePercentage,
    int? specTolerancePercentage,
    String? severityDefectID,
    int? defectID,
    int? overridden,
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
      specificationNumber:
          json[SpecificationGradeToleranceColumn.NUMBER_SPECIFICATION],
      specificationVersion:
          json[SpecificationGradeToleranceColumn.VERSION_SPECIFICATION],
      gradeTolerancePercentage:
          json[SpecificationGradeToleranceColumn.GRADE_TOLERANCE_PERCENTAGE],
      specTolerancePercentage:
          json[SpecificationGradeToleranceColumn.GRADE_TOLERANCE_PERCENTAGE],
      severityDefectID:
          json[SpecificationGradeToleranceColumn.SEVERITY_DEFECT_ID],
      defectID: json[SpecificationGradeToleranceColumn.DEFECT_ID],
      overridden: json[SpecificationGradeToleranceColumn.OVERRIDDEN],
      defectName: json[SpecificationGradeToleranceColumn.DEFECT_NAME],
      severityDefectName:
          json[SpecificationGradeToleranceColumn.SEVERITY_DEFECT_NAME],
      defectCategoryName:
          json[SpecificationGradeToleranceColumn.DEFECT_CATEGORY_NAME],
    );
  }

  // toJson method
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data[SpecificationGradeToleranceColumn.NUMBER_SPECIFICATION] =
        specificationNumber;
    data[SpecificationGradeToleranceColumn.VERSION_SPECIFICATION] =
        specificationVersion;
    data[SpecificationGradeToleranceColumn.GRADE_TOLERANCE_PERCENTAGE] =
        gradeTolerancePercentage;
    data[SpecificationGradeToleranceColumn.GRADE_TOLERANCE_PERCENTAGE] =
        specTolerancePercentage;
    data[SpecificationGradeToleranceColumn.SEVERITY_DEFECT_ID] =
        severityDefectID;
    data[SpecificationGradeToleranceColumn.DEFECT_ID] = defectID;
    data[SpecificationGradeToleranceColumn.OVERRIDDEN] = overridden;
    data[SpecificationGradeToleranceColumn.DEFECT_NAME] = defectName;
    data[SpecificationGradeToleranceColumn.SEVERITY_DEFECT_NAME] =
        severityDefectName;
    data[SpecificationGradeToleranceColumn.DEFECT_CATEGORY_NAME] =
        defectCategoryName;
    return data;
  }
}
