class FinishedGoodsItemSKU {
  final int? itemSkuId;
  final String? itemSkuCode;
  final String? itemSkuName;
  final int? commodityId;
  final String? commodityName;
  final int? partnerId;
  final String? partnerName;
  final String? lotNumber;
  final String? packDate;
  final String? supplierId;
  final String? gtin;
  final String? supplierName;
  final String? dateType;

  FinishedGoodsItemSKU({
    this.itemSkuId,
    this.itemSkuCode,
    this.itemSkuName,
    this.commodityId,
    this.commodityName,
    this.partnerId,
    this.partnerName,
    this.lotNumber,
    this.packDate,
    this.supplierId,
    this.gtin,
    this.supplierName,
    this.dateType,
  });

  FinishedGoodsItemSKU copyWith({
    int? itemSkuId,
    String? itemSkuCode,
    String? itemSkuName,
    int? commodityId,
    String? commodityName,
    int? partnerId,
    String? partnerName,
    String? lotNumber,
    String? packDate,
    String? supplierId,
    String? gtin,
    String? supplierName,
    String? dateType,
  }) {
    return FinishedGoodsItemSKU(
      itemSkuId: itemSkuId ?? this.itemSkuId,
      itemSkuCode: itemSkuCode ?? this.itemSkuCode,
      itemSkuName: itemSkuName ?? this.itemSkuName,
      commodityId: commodityId ?? this.commodityId,
      commodityName: commodityName ?? this.commodityName,
      partnerId: partnerId ?? this.partnerId,
      partnerName: partnerName ?? this.partnerName,
      lotNumber: lotNumber ?? this.lotNumber,
      packDate: packDate ?? this.packDate,
      supplierId: supplierId ?? this.supplierId,
      gtin: gtin ?? this.gtin,
      supplierName: supplierName ?? this.supplierName,
      dateType: dateType ?? this.dateType,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemSkuId': itemSkuId,
      'itemSkuCode': itemSkuCode,
      'itemSkuName': itemSkuName,
      'commodityId': commodityId,
      'commodityName': commodityName,
      'partnerId': partnerId,
      'partnerName': partnerName,
      'lotNumber': lotNumber,
      'packDate': packDate,
      'supplierId': supplierId,
      'gtin': gtin,
      'supplierName': supplierName,
      'dateType': dateType,
    };
  }

  factory FinishedGoodsItemSKU.fromMap(Map<String, dynamic> map) {
    return FinishedGoodsItemSKU(
      itemSkuId: map['itemSkuId'],
      itemSkuCode: map['itemSkuCode'],
      itemSkuName: map['itemSkuName'],
      commodityId: map['commodityId'],
      commodityName: map['commodityName'],
      partnerId: map['partnerId'],
      partnerName: map['partnerName'],
      lotNumber: map['lotNumber'],
      packDate: map['packDate'],
      supplierId: map['supplierId'],
      gtin: map['gtin'],
      supplierName: map['supplierName'],
      dateType: map['dateType'],
    );
  }
}
