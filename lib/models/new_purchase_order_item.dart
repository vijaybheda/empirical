class NewPurchaseOrderItem {
  String? description;
  String? sku;
  String? poNumber;
  String? sealNumber;
  String? lotNumber;
  int? commodityId;
  String? commodityName;
  String? packDate;
  int? quantity;
  int? quantityUOM;
  String? quantityUOMName;
  String? number_spec;
  String? version_spec;
  int? poLineNo;
  int? quantityRejected;
  int? partnerId;
  String? ftl;
  String? branded;

  NewPurchaseOrderItem({
    required this.description,
    required this.sku,
    required this.poNumber,
    required this.sealNumber,
    required this.lotNumber,
    required this.commodityId,
    required this.commodityName,
    required this.packDate,
    required this.quantity,
    required this.quantityUOM,
    required this.quantityUOMName,
    required this.number_spec,
    required this.version_spec,
    required this.poLineNo,
    this.quantityRejected,
    required this.partnerId,
    required this.ftl,
    required this.branded,
  });

  // toJson
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
      'quantity': quantity,
      'quantityUOM': quantityUOM,
      'quantityUOMName': quantityUOMName,
      'number_spec': number_spec,
      'version_spec': version_spec,
      'poLineNo': poLineNo,
      'quantityRejected': quantityRejected,
      'partnerId': partnerId,
      'ftl': ftl,
      'branded': branded,
    };
  }

  // fromJson
  factory NewPurchaseOrderItem.fromJson(Map<String, dynamic> json) {
    return NewPurchaseOrderItem(
      description: json['description'],
      sku: json['sku'],
      poNumber: json['poNumber'],
      sealNumber: json['sealNumber'],
      lotNumber: json['lotNumber'],
      commodityId: json['commodityId'],
      commodityName: json['commodityName'],
      packDate: json['packDate'],
      quantity: json['quantity'],
      quantityUOM: json['quantityUOM'],
      quantityUOMName: json['quantityUOMName'],
      number_spec: json['number_spec'],
      version_spec: json['version_spec'],
      poLineNo: json['poLineNo'],
      quantityRejected: json['quantityRejected'],
      partnerId: json['partnerId'],
      ftl: json['ftl'],
      branded: json['branded'],
    );
  }

  // copyWith
  NewPurchaseOrderItem copyWith({
    String? description,
    String? sku,
    String? poNumber,
    String? sealNumber,
    String? lotNumber,
    int? commodityId,
    String? commodityName,
    String? packDate,
    int? quantity,
    int? quantityUOM,
    String? quantityUOMName,
    String? number_spec,
    String? version_spec,
    int? poLineNo,
    int? quantityRejected,
    int? partnerId,
    String? ftl,
    String? branded,
  }) {
    return NewPurchaseOrderItem(
      description: description ?? this.description,
      sku: sku ?? this.sku,
      poNumber: poNumber ?? this.poNumber,
      sealNumber: sealNumber ?? this.sealNumber,
      lotNumber: lotNumber ?? this.lotNumber,
      commodityId: commodityId ?? this.commodityId,
      commodityName: commodityName ?? this.commodityName,
      packDate: packDate ?? this.packDate,
      quantity: quantity ?? this.quantity,
      quantityUOM: quantityUOM ?? this.quantityUOM,
      quantityUOMName: quantityUOMName ?? this.quantityUOMName,
      number_spec: number_spec ?? this.number_spec,
      version_spec: version_spec ?? this.version_spec,
      poLineNo: poLineNo ?? this.poLineNo,
      quantityRejected: quantityRejected ?? this.quantityRejected,
      partnerId: partnerId ?? this.partnerId,
      ftl: ftl ?? this.ftl,
      branded: branded ?? this.branded,
    );
  }
}
