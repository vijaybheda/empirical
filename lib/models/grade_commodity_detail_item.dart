class GradeCommodityDetailItem {
  int? gradeCommodityDetailId;
  int? gradeId;
  String? gradeName;

  GradeCommodityDetailItem(
      int? gradeCommodityDetailId, int? gradeId, String? gradeName) {
    this.gradeCommodityDetailId = gradeCommodityDetailId;
    this.gradeId = gradeId;
    this.gradeName = gradeName;
  }

  GradeCommodityDetailItem.fromJson(Map<String, dynamic> json) {
    gradeCommodityDetailId = json['gradeCommodityDetailId'];
    gradeId = json['gradeId'];
    gradeName = json['gradeName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['gradeCommodityDetailId'] = gradeCommodityDetailId;
    data['gradeId'] = gradeId;
    data['gradeName'] = gradeName;
    return data;
  }

  // copyWith
  GradeCommodityDetailItem copyWith({
    int? gradeCommodityDetailId,
    int? gradeId,
    String? gradeName,
  }) {
    return GradeCommodityDetailItem(
      gradeCommodityDetailId ?? this.gradeCommodityDetailId,
      gradeId ?? this.gradeId,
      gradeName ?? this.gradeName,
    );
  }
}
