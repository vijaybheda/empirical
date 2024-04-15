class CountryItem {
  int? countryID;
  String? countryName;

  CountryItem(int? countryID, String? countryName) {
    this.countryID = countryID;
    this.countryName = countryName;
  }

  CountryItem.fromJson(Map<String, dynamic> json) {
    countryID = json['countryID'];
    countryName = json['countryName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['countryID'] = countryID;
    data['countryName'] = countryName;
    return data;
  }

  // copyWith
  CountryItem copyWith({
    int? countryID,
    String? countryName,
  }) {
    return CountryItem(
      countryID ?? this.countryID,
      countryName ?? this.countryName,
    );
  }
}
