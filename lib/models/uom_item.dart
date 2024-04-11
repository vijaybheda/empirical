class UOMItem {
  String? uomName;
  int? uomID;

  UOMItem(int? uomID, String? uomName) {
    this.uomID = uomID;
    this.uomName = uomName;
  }

  UOMItem.fromJson(Map<String, dynamic> json) {
    uomID = json['uomID'];
    uomName = json['uomName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uomID'] = uomID;
    data['uomName'] = uomName;
    return data;
  }

  // copyWith
  UOMItem copyWith({
    int? uomID,
    String? uomName,
  }) {
    return UOMItem(
      uomID ?? this.uomID,
      uomName ?? this.uomName,
    );
  }
}
