class PurchaseOrderDetails {
  String? poDetailId;
  String? poHeaderId;
  String? poNumber;
  int? deliverToId;
  String? deliverToName;
  int? poLineNumber;
  int? itemSkuId;
  String? itemSkuCode;
  String? itemSkuName;
  int? quantity;
  int? quantityUOMId;
  String? quantityUOMName;
  String? numberSpecification;
  String? versionSpecification;
  int? commodityId;
  String? commodityName;
  int? partnerId;
  String? partnerName;

  PurchaseOrderDetails({
    this.poDetailId,
    this.poHeaderId,
    this.poNumber,
    this.deliverToId,
    this.deliverToName,
    this.poLineNumber,
    this.itemSkuId,
    this.itemSkuCode,
    this.itemSkuName,
    this.quantity,
    this.quantityUOMId,
    this.quantityUOMName,
    this.numberSpecification,
    this.versionSpecification,
    this.commodityId,
    this.commodityName,
    this.partnerId,
    this.partnerName,
  });

  Map<String, dynamic> toJson() {
    return {
      'poDetailId': poDetailId,
      'poHeaderId': poHeaderId,
      'poNumber': poNumber,
      'deliverToId': deliverToId,
      'deliverToName': deliverToName,
      'poLineNumber': poLineNumber,
      'itemSkuId': itemSkuId,
      'itemSkuCode': itemSkuCode,
      'itemSkuName': itemSkuName,
      'quantity': quantity,
      'quantityUOMId': quantityUOMId,
      'quantityUOMName': quantityUOMName,
      'numberSpecification': numberSpecification,
      'versionSpecification': versionSpecification,
      'commodityId': commodityId,
      'commodityName': commodityName,
      'partnerId': partnerId,
      'partnerName': partnerName,
    };
  }

  factory PurchaseOrderDetails.fromMap(Map<String, dynamic> map) {
    return PurchaseOrderDetails(
      poDetailId: map['poDetailId'],
      poHeaderId: map['poHeaderId'],
      poNumber: map['poNumber'],
      deliverToId: map['deliverToId'],
      deliverToName: map['deliverToName'],
      poLineNumber: map['poLineNumber'],
      itemSkuId: map['itemSkuId'],
      itemSkuCode: map['itemSkuCode'],
      itemSkuName: map['itemSkuName'],
      quantity: map['quantity'],
      quantityUOMId: map['quantityUOMId'],
      quantityUOMName: map['quantityUOMName'],
      numberSpecification: map['numberSpecification'],
      versionSpecification: map['versionSpecification'],
      commodityId: map['commodityId'],
      commodityName: map['commodityName'],
      partnerId: map['partnerId'],
      partnerName: map['partnerName'],
    );
  }
}
