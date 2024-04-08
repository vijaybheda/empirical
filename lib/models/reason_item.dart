class ReasonItem {
  int? reasonID;
  String? reasonName;

  ReasonItem(int? reasonID, String? reasonName) {
    this.reasonID = reasonID;
    this.reasonName = reasonName;
  }

  ReasonItem.fromJson(Map<String, dynamic> json) {
    reasonID = json['reasonID'];
    reasonName = json['reasonName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['reasonID'] = reasonID;
    data['reasonName'] = reasonName;
    return data;
  }

  // copyWith
  ReasonItem copyWith({
    int? reasonID,
    String? reasonName,
  }) {
    return ReasonItem(
      reasonID ?? this.reasonID,
      reasonName ?? this.reasonName,
    );
  }
}
