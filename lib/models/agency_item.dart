class AgencyItem {
  int? agencyID;
  String? agencyName;

  AgencyItem(this.agencyID, this.agencyName);

  AgencyItem.fromJson(Map<String, dynamic> json) {
    agencyID = json['agencyID'];
    agencyName = json['agencyName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['agencyID'] = agencyID;
    data['agencyName'] = agencyName;
    return data;
  }

  // copyWith
  AgencyItem copyWith({
    int? agencyID,
    String? agencyName,
  }) {
    return AgencyItem(
      agencyID ?? this.agencyID,
      agencyName ?? this.agencyName,
    );
  }
}
