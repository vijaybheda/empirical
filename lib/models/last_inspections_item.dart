class LastInspectionsItem {
  int? inspectionId;
  int? createdDate;
  String? commodityName;
  String? inspectionReason;
  String? inspectionResult;
  String? displayDate;

  LastInspectionsItem({
    this.inspectionId,
    this.createdDate,
    this.commodityName,
    this.inspectionReason,
    this.inspectionResult,
    this.displayDate,
  });

  LastInspectionsItem.fromJson(Map<String, dynamic> json) {
    inspectionId = json['inspectionId'];
    createdDate = json['createdDate'];
    commodityName = json['commodityName'];
    inspectionReason = json['inspectionReason'];
    inspectionResult = json['inspectionResult'];
    displayDate = json['displayDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['inspectionId'] = inspectionId;
    data['createdDate'] = createdDate;
    data['commodityName'] = commodityName;
    data['inspectionReason'] = inspectionReason;
    data['inspectionResult'] = inspectionResult;
    data['displayDate'] = displayDate;
    return data;
  }

  // copyWith
  LastInspectionsItem copyWith({
    int? inspectionId,
    int? createdDate,
    String? commodityName,
    String? inspectionReason,
    String? inspectionResult,
    String? displayDate,
  }) {
    return LastInspectionsItem(
      inspectionId: inspectionId ?? this.inspectionId,
      createdDate: createdDate ?? this.createdDate,
      commodityName: commodityName ?? this.commodityName,
      inspectionReason: inspectionReason ?? this.inspectionReason,
      inspectionResult: inspectionResult ?? this.inspectionResult,
      displayDate: displayDate ?? this.displayDate,
    );
  }
}
