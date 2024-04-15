class TrendingDataItem {
  String? name;
  double? percentageRejection;

  TrendingDataItem({this.name, this.percentageRejection});

  TrendingDataItem.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    percentageRejection = json['percentageRejection'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['percentageRejection'] = percentageRejection;
    return data;
  }

  // copyWith
  TrendingDataItem copyWith({
    String? name,
    double? percentageRejection,
  }) {
    return TrendingDataItem(
      name: name ?? this.name,
      percentageRejection: percentageRejection ?? this.percentageRejection,
    );
  }
}
