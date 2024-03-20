class PartnerItem {
  final int id;
  final String name;
  final double redPercentage;
  final double yellowPercentage;
  final double orangePercentage;
  final double greenPercentage;
  final String recordType;

  PartnerItem(this.id, this.name, this.redPercentage, this.yellowPercentage,
      this.orangePercentage, this.greenPercentage, this.recordType);

  PartnerItem.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        redPercentage = json['redPercentage'],
        yellowPercentage = json['yellowPercentage'],
        orangePercentage = json['orangePercentage'],
        greenPercentage = json['greenPercentage'],
        recordType = json['recordType'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'redPercentage': redPercentage,
        'yellowPercentage': yellowPercentage,
        'orangePercentage': orangePercentage,
        'greenPercentage': greenPercentage,
        'recordType': recordType,
      };

  // copyWith
  PartnerItem copyWith({
    int? id,
    String? name,
    double? redPercentage,
    double? yellowPercentage,
    double? orangePercentage,
    double? greenPercentage,
    String? recordType,
  }) {
    return PartnerItem(
      id ?? this.id,
      name ?? this.name,
      redPercentage ?? this.redPercentage,
      yellowPercentage ?? this.yellowPercentage,
      orangePercentage ?? this.orangePercentage,
      greenPercentage ?? this.greenPercentage,
      recordType ?? this.recordType,
    );
  }
}
