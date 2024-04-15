class GradeDefectDetailItem {
  int? severityId;
  int? defectId;
  int? percentage;

  GradeDefectDetailItem({
    this.severityId,
    this.defectId,
    this.percentage,
  });

  GradeDefectDetailItem.fromJson(Map<String, dynamic> json) {
    severityId = json['severityId'];
    defectId = json['defectId'];
    percentage = json['percentage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['severityId'] = severityId;
    data['defectId'] = defectId;
    data['percentage'] = percentage;
    return data;
  }

  GradeDefectDetailItem copyWith({
    int? severityId,
    int? defectId,
    int? percentage,
  }) {
    return GradeDefectDetailItem(
      severityId: severityId ?? this.severityId,
      defectId: defectId ?? this.defectId,
      percentage: percentage ?? this.percentage,
    );
  }
}
