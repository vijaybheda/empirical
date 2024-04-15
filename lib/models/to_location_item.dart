class ToLocationItem {
  int? partnerID;
  String? partnerName;

  ToLocationItem(int? partnerID, String? partnerName) {
    this.partnerID = partnerID;
    this.partnerName = partnerName;
  }

  ToLocationItem.fromJson(Map<String, dynamic> json) {
    partnerID = json['partnerID'];
    partnerName = json['partnerName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['partnerID'] = partnerID;
    data['partnerName'] = partnerName;
    return data;
  }

  // copyWith
  ToLocationItem copyWith({
    int? partnerID,
    String? partnerName,
  }) {
    return ToLocationItem(
      partnerID ?? this.partnerID,
      partnerName ?? this.partnerName,
    );
  }
}
