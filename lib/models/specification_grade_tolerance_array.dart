import 'package:pverify/models/specification_grade_tolerance.dart';

class SpecificationGradeToleranceArray {
  List<SpecificationGradeTolerance>? specificationGradeToleranceList;
  String? specificationNumber;
  String? specificationVersion;

  SpecificationGradeToleranceArray(
      {this.specificationGradeToleranceList,
      this.specificationNumber,
      this.specificationVersion});

  // copyWith method
  SpecificationGradeToleranceArray copyWith({
    List<SpecificationGradeTolerance>? specificationGradeToleranceList,
    String? specificationNumber,
    String? specificationVersion,
  }) {
    return SpecificationGradeToleranceArray(
      specificationGradeToleranceList: specificationGradeToleranceList ??
          this.specificationGradeToleranceList,
      specificationNumber: specificationNumber ?? this.specificationNumber,
      specificationVersion: specificationVersion ?? this.specificationVersion,
    );
  }

  // fromJson method
  factory SpecificationGradeToleranceArray.fromJson(Map<String, dynamic> json) {
    return SpecificationGradeToleranceArray(
      specificationGradeToleranceList:
          json['specificationGradeToleranceList'] != null
              ? (json['specificationGradeToleranceList'] as List)
                  .map((i) => SpecificationGradeTolerance.fromJson(i))
                  .toList()
              : null,
      specificationNumber: json['specificationNumber'],
      specificationVersion: json['specificationVersion'],
    );
  }

  // toJson method
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['specificationGradeToleranceList'] =
        this.specificationGradeToleranceList != null
            ? this
                .specificationGradeToleranceList!
                .map((v) => v.toJson())
                .toList()
            : null;
    data['specificationNumber'] = this.specificationNumber;
    data['specificationVersion'] = this.specificationVersion;
    return data;
  }
}
