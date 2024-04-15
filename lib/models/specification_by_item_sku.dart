class SpecificationByItemSKU {
  String? specificationNumber;
  String? specificationVersion;
  String? specificationName;
  String? specificationTypeName;
  String? agencyName;
  String? gradeName;
  String? commodityName;
  String? itemGroup1Name;
  int? commodityId;
  int? itemGroup1Id;
  int? agencyId;
  int? gradeId;
  int? sampleSizeByCount;

  SpecificationByItemSKU({
    this.specificationNumber,
    this.specificationVersion,
    this.specificationName,
    this.specificationTypeName,
    this.agencyName,
    this.gradeName,
    this.commodityName,
    this.itemGroup1Name,
    this.commodityId,
    this.itemGroup1Id,
    this.agencyId,
    this.gradeId,
    this.sampleSizeByCount,
  });

  SpecificationByItemSKU.fromJson(Map<String, dynamic> json) {
    specificationNumber = json['specificationNumber'];
    specificationVersion = json['specificationVersion'];
    specificationName = json['specificationName'];
    specificationTypeName = json['specificationTypeName'];
    agencyName = json['agencyName'];
    gradeName = json['gradeName'];
    commodityName = json['commodityName'];
    itemGroup1Name = json['itemGroup1Name'];
    commodityId = json['commodityId'];
    itemGroup1Id = json['itemGroup1Id'];
    agencyId = json['agencyId'];
    gradeId = json['gradeId'];
    sampleSizeByCount = json['sampleSizeByCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['specificationNumber'] = specificationNumber;
    data['specificationVersion'] = specificationVersion;
    data['specificationName'] = specificationName;
    data['specificationTypeName'] = specificationTypeName;
    data['agencyName'] = agencyName;
    data['gradeName'] = gradeName;
    data['commodityName'] = commodityName;
    data['itemGroup1Name'] = itemGroup1Name;
    data['commodityId'] = commodityId;
    data['itemGroup1Id'] = itemGroup1Id;
    data['agencyId'] = agencyId;
    data['gradeId'] = gradeId;
    data['sampleSizeByCount'] = sampleSizeByCount;
    return data;
  }
}
