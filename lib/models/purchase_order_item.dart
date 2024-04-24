class PurchaseOrderItem {
  String? description;
  String? sku;
  String? poNumber;
  String? sealNumber;
  String? lotNumber;
  int? commodityId;
  String? commodityName;
  String? packDate;
  String? ftl, Branded;

  PurchaseOrderItem({
    required this.description,
    required this.sku,
    required this.poNumber,
    required this.sealNumber,
    required this.lotNumber,
    required this.commodityId,
    required this.commodityName,
    required this.packDate,
    required this.ftl,
    required this.Branded,
  });

  PurchaseOrderItem.newData(
      String? description,
      String? sku,
      String? poNumber,
      String? sealNumber,
      String? lotNumber,
      int? commodityId,
      String? commodityName,
      String? packDate,
      String? Ftl,
      String? Branded) {
    this.description = description;
    this.sku = sku;
    this.poNumber = poNumber;
    this.sealNumber = sealNumber;
    this.lotNumber = lotNumber;
    this.commodityId = commodityId;
    this.commodityName = commodityName;
    this.packDate = packDate;
    this.ftl = Ftl;
    this.Branded = Branded;
  }

  PurchaseOrderItem copyWith({
    String? description,
    String? sku,
    String? poNumber,
    String? sealNumber,
    String? lotNumber,
    int? commodityId,
    String? commodityName,
    String? packDate,
    String? ftl,
    String? Branded,
  }) {
    return PurchaseOrderItem(
      description: description ?? this.description,
      sku: sku ?? this.sku,
      poNumber: poNumber ?? this.poNumber,
      sealNumber: sealNumber ?? this.sealNumber,
      lotNumber: lotNumber ?? this.lotNumber,
      commodityId: commodityId ?? this.commodityId,
      commodityName: commodityName ?? this.commodityName,
      packDate: packDate ?? this.packDate,
      ftl: ftl ?? this.ftl,
      Branded: Branded ?? this.Branded,
    );
  }

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItem(
      description: json['description'],
      sku: json['sku'],
      poNumber: json['poNumber'],
      sealNumber: json['sealNumber'],
      lotNumber: json['lotNumber'],
      commodityId: json['commodityId'],
      commodityName: json['commodityName'],
      packDate: json['packDate'],
      ftl: json['Ftl'],
      Branded: json['Branded'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'sku': sku,
      'poNumber': poNumber,
      'sealNumber': sealNumber,
      'lotNumber': lotNumber,
      'commodityId': commodityId,
      'commodityName': commodityName,
      'packDate': packDate,
      'Ftl': ftl,
      'Branded': Branded,
    };
  }
}
