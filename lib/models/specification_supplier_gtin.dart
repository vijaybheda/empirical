class SpecificationSupplierGTIN {
  String? specificationNumber;
  String? specificationVersion;
  String? specificationName;
  String? supplierName;
  int? supplierId;
  String? varietyId;
  String? varietyName;
  int? commodityId;
  String? commodityName;
  String? gtin;
  String? itemSkuId;
  String? itemSkuName;
  double? agencyId;
  String? agencyName;
  int? gradeId;
  String? gradeName;
  String? samplesizecount;
  String? specificationTypeName;
  String? itemSkuCode;

  SpecificationSupplierGTIN(
      {this.specificationNumber,
      this.specificationVersion,
      this.specificationName,
      this.supplierName,
      this.supplierId,
      this.varietyId,
      this.varietyName,
      this.commodityId,
      this.commodityName,
      this.gtin,
      this.itemSkuId,
      this.itemSkuName,
      this.agencyId,
      this.agencyName,
      this.gradeId,
      this.gradeName,
      this.samplesizecount,
      this.specificationTypeName,
      this.itemSkuCode});

  SpecificationSupplierGTIN.fromJson(Map<String, dynamic> json) {
    specificationNumber = json['specificationNumber'];
    specificationVersion = json['specificationVersion'];
    specificationName = json['specificationName'];
    supplierName = json['supplierName'];
    supplierId = json['supplierId'];
    varietyId = json['varietyId'];
    varietyName = json['varietyName'];
    commodityId = json['commodityId'];
    commodityName = json['commodityName'];
    gtin = json['gtin'];
    itemSkuId = json['itemSkuId'];
    itemSkuName = json['itemSkuName'];
    agencyId = json['agencyId'];
    agencyName = json['agencyName'];
    gradeId = json['gradeId'];
    gradeName = json['gradeName'];
    samplesizecount = json['samplesizecount'];
    specificationTypeName = json['specificationTypeName'];
    itemSkuCode = json['itemSkuCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['specificationNumber'] = specificationNumber;
    data['specificationVersion'] = specificationVersion;
    data['specificationName'] = specificationName;
    data['supplierName'] = supplierName;
    data['supplierId'] = supplierId;
    data['varietyId'] = varietyId;
    data['varietyName'] = varietyName;
    data['commodityId'] = commodityId;
    data['commodityName'] = commodityName;
    data['gtin'] = gtin;
    data['itemSkuId'] = itemSkuId;
    data['itemSkuName'] = itemSkuName;
    data['agencyId'] = agencyId;
    data['agencyName'] = agencyName;
    data['gradeId'] = gradeId;
    data['gradeName'] = gradeName;
    data['samplesizecount'] = samplesizecount;
    data['specificationTypeName'] = specificationTypeName;
    data['itemSkuCode'] = itemSkuCode;
    return data;
  }

  // copyWith
  SpecificationSupplierGTIN copyWith({
    String? specificationNumber,
    String? specificationVersion,
    String? specificationName,
    String? supplierName,
    int? supplierId,
    String? varietyId,
    String? varietyName,
    int? commodityId,
    String? commodityName,
    String? gtin,
    String? itemSkuId,
    String? itemSkuName,
    double? agencyId,
    String? agencyName,
    int? gradeId,
    String? gradeName,
    String? samplesizecount,
    String? specificationTypeName,
    String? itemSkuCode,
  }) {
    return SpecificationSupplierGTIN(
      specificationNumber: specificationNumber ?? this.specificationNumber,
      specificationVersion: specificationVersion ?? this.specificationVersion,
      specificationName: specificationName ?? this.specificationName,
      supplierName: supplierName ?? this.supplierName,
      supplierId: supplierId ?? this.supplierId,
      varietyId: varietyId ?? this.varietyId,
      varietyName: varietyName ?? this.varietyName,
      commodityId: commodityId ?? this.commodityId,
      commodityName: commodityName ?? this.commodityName,
      gtin: gtin ?? this.gtin,
      itemSkuId: itemSkuId ?? this.itemSkuId,
      itemSkuName: itemSkuName ?? this.itemSkuName,
      agencyId: agencyId ?? this.agencyId,
      agencyName: agencyName ?? this.agencyName,
      gradeId: gradeId ?? this.gradeId,
      gradeName: gradeName ?? this.gradeName,
      samplesizecount: samplesizecount ?? this.samplesizecount,
      specificationTypeName:
          specificationTypeName ?? this.specificationTypeName,
      itemSkuCode: itemSkuCode ?? this.itemSkuCode,
    );
  }
}
