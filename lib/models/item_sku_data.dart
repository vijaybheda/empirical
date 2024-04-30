import 'package:pverify/utils/utils.dart';

class FinishedGoodsItemSKU {
  String? uniqueItemId;
  int? id;
  String? sku;
  String? name;
  String? lotNo;
  String? poNo;
  int? commodityID;
  String? commodityName;
  String? description;
  int? inspectionId;
  int? partnerId;
  bool? is_Complete;
  bool? isSelected;
  bool? isPartialComplete;
  String? packDate;
  String? gtin;
  String? partnerName;
  int? quantity;
  int? quantityUOM;
  String? quantityUOMName;
  String? number_spec, version_spec;
  int? poLineNo;
  String? FTLflag;
  String? Branded;
  String? dateType;

  FinishedGoodsItemSKU({
    this.uniqueItemId,
    this.id,
    this.sku,
    this.name,
    this.lotNo,
    this.poNo,
    this.commodityID,
    this.commodityName,
    this.description,
    this.inspectionId,
    this.partnerId,
    this.is_Complete,
    this.isSelected,
    this.isPartialComplete,
    this.packDate,
    this.gtin,
    this.partnerName,
    this.quantity,
    this.quantityUOM,
    this.quantityUOMName,
    this.number_spec,
    this.version_spec,
    this.poLineNo,
    this.FTLflag,
    this.Branded,
    this.dateType,
  });

  // (int id, String sku, String name, int commodityID, String commodityName, int partnerId, String partnerName, String dateType, String gtin, String lotNo, String packDate)

  FinishedGoodsItemSKU.fromGtinOffline({
    required this.id,
    required this.sku,
    required this.name,
    required this.commodityID,
    required this.commodityName,
    required this.partnerId,
    required this.partnerName,
    required this.dateType,
    required this.gtin,
    required this.lotNo,
    required this.packDate,
  });

  // (int id, String sku, String name, int commodityID, String commodityName, String uniqueItemId, String lotNo, String packDate, int partnerId, String gtin, String partnerName, String dateType)
  FinishedGoodsItemSKU.fromGtinStorage({
    required this.id,
    required this.sku,
    required this.name,
    required this.commodityID,
    required this.commodityName,
    required this.uniqueItemId,
    required this.lotNo,
    required this.packDate,
    required this.partnerId,
    required this.gtin,
    required this.partnerName,
    required this.dateType,
  });

  FinishedGoodsItemSKU.fromJson(Map<String, dynamic> json) {
    printKeysAndValueTypes(json);
    uniqueItemId = json['uniqueItemId'];
    id = json['id'];
    sku = json['sku'];
    name = json['name'];
    lotNo = json['lotNo'];
    poNo = json['poNo'];
    commodityID = json['commodityID'];
    commodityName = json['commodityName'];
    description = json['description'];
    inspectionId = json['inspectionId'];
    partnerId = json['partnerId'];
    is_Complete = json['is_Complete'];
    isSelected = json['isSelected'];
    isPartialComplete = json['isPartialComplete'];
    packDate = json['packDate'];
    gtin = json['gtin'];
    partnerName = json['partnerName'];
    quantity = json['quantity'];
    quantityUOM = json['quantityUOM'];
    quantityUOMName = json['quantityUOMName'];
    number_spec = json['number_spec'];
    version_spec = json['version_spec'];
    poLineNo = json['poLineNo'];
    FTLflag = json['FTLflag'];
    Branded = json['Branded'];
    dateType = json['dateType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uniqueItemId'] = uniqueItemId;
    data['id'] = id;
    data['sku'] = sku;
    data['name'] = name;
    data['lotNo'] = lotNo;
    data['poNo'] = poNo;
    data['commodityID'] = commodityID;
    data['commodityName'] = commodityName;
    data['description'] = description;
    data['inspectionId'] = inspectionId;
    data['partnerId'] = partnerId;
    data['is_Complete'] = is_Complete;
    data['isSelected'] = isSelected;
    data['isPartialComplete'] = isPartialComplete;
    data['packDate'] = packDate;
    data['gtin'] = gtin;
    data['partnerName'] = partnerName;
    data['quantity'] = quantity;
    data['quantityUOM'] = quantityUOM;
    data['quantityUOMName'] = quantityUOMName;
    data['number_spec'] = number_spec;
    data['version_spec'] = version_spec;
    data['poLineNo'] = poLineNo;
    data['FTLflag'] = FTLflag;
    data['Branded'] = Branded;
    data['dateType'] = dateType;
    return data;
  }

  // copyWith
  FinishedGoodsItemSKU copyWith({
    String? uniqueItemId,
    int? id,
    String? sku,
    String? name,
    String? lotNo,
    String? poNo,
    int? commodityID,
    String? commodityName,
    String? description,
    int? inspectionId,
    int? partnerId,
    bool? is_Complete,
    bool? isSelected,
    bool? isPartialComplete,
    String? packDate,
    String? gtin,
    String? partnerName,
    int? quantity,
    int? quantityUOM,
    String? quantityUOMName,
    String? number_spec,
    String? version_spec,
    int? poLineNo,
    String? FTLflag,
    String? Branded,
    String? dateType,
  }) {
    return FinishedGoodsItemSKU(
      uniqueItemId: uniqueItemId ?? this.uniqueItemId,
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      lotNo: lotNo ?? this.lotNo,
      poNo: poNo ?? this.poNo,
      commodityID: commodityID ?? this.commodityID,
      commodityName: commodityName ?? this.commodityName,
      description: description ?? this.description,
      inspectionId: inspectionId ?? this.inspectionId,
      partnerId: partnerId ?? this.partnerId,
      is_Complete: is_Complete ?? this.is_Complete,
      isSelected: isSelected ?? this.isSelected,
      isPartialComplete: isPartialComplete ?? this.isPartialComplete,
      packDate: packDate ?? this.packDate,
      gtin: gtin ?? this.gtin,
      partnerName: partnerName ?? this.partnerName,
      quantity: quantity ?? this.quantity,
      quantityUOM: quantityUOM ?? this.quantityUOM,
      quantityUOMName: quantityUOMName ?? this.quantityUOMName,
      number_spec: number_spec ?? this.number_spec,
      version_spec: version_spec ?? this.version_spec,
      poLineNo: poLineNo ?? this.poLineNo,
      FTLflag: FTLflag ?? this.FTLflag,
      Branded: Branded ?? this.Branded,
      dateType: dateType ?? this.dateType,
    );
  }
}
