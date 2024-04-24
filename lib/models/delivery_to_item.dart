class DeliveryToItem {
  int? partnerID;
  String? partnerName;

  DeliveryToItem(this.partnerID, this.partnerName);

  DeliveryToItem.fromJson(Map<String, dynamic> json) {
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
  DeliveryToItem copyWith({
    int? partnerID,
    String? partnerName,
  }) {
    return DeliveryToItem(
      partnerID ?? this.partnerID,
      partnerName ?? this.partnerName,
    );
  }
}
