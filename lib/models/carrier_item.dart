class CarrierItem {
  final int id;
  final String name;
  final double redPercentage;
  final double yellowPercentage;
  final double orangePercentage;
  final double greenPercentage;
  final String recordType;

  CarrierItem(
    this.id,
    this.name,
    this.redPercentage,
    this.yellowPercentage,
    this.orangePercentage,
    this.greenPercentage,
    this.recordType,
  );

  factory CarrierItem.fromJson(Map<String, dynamic> json) {
    return CarrierItem(
      json['id'],
      json['name'],
      json['redPercentage'].toDouble(),
      json['yellowPercentage'].toDouble(),
      json['orangePercentage'].toDouble(),
      json['greenPercentage'].toDouble(),
      json['recordType'],
    );
  }

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
  CarrierItem copyWith({
    int? id,
    String? name,
    double? redPercentage,
    double? yellowPercentage,
    double? orangePercentage,
    double? greenPercentage,
    String? recordType,
  }) {
    return CarrierItem(
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
