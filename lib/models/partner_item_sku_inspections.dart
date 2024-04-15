import 'package:pverify/services/database/column_names.dart';

class PartnerItemSKUInspections {
  int? partnerId;
  String? itemSKU;
  int? inspectionId;
  String? lotNo;
  String? packDate;
  String? lotSize;
  String? uniqueId;
  int? poLineNo;
  String? poNo;

  PartnerItemSKUInspections({
    this.partnerId,
    this.itemSKU,
    this.inspectionId,
    this.lotNo,
    this.packDate,
    this.lotSize,
    this.uniqueId,
    this.poLineNo,
    this.poNo,
  });

  PartnerItemSKUInspections.fromMap(Map<String, dynamic> map) {
    partnerId = map[PartnerItemSkuColumn.PARTNER_ID];
    itemSKU = map[PartnerItemSkuColumn.ITEM_SKU];
    inspectionId = map[PartnerItemSkuColumn.INSPECTION_ID];
    lotNo = map[PartnerItemSkuColumn.LOT_NO];
    packDate = map[PartnerItemSkuColumn.PACK_DATE];
    lotSize = map[PartnerItemSkuColumn.LOT_SIZE];
    uniqueId = map[PartnerItemSkuColumn.UNIQUE_ID];
    poLineNo = map[PartnerItemSkuColumn.PO_LINE_NO];
    poNo = map[PartnerItemSkuColumn.PO_NO];
  }

  Map<String, dynamic> toMap() {
    return {
      PartnerItemSkuColumn.PARTNER_ID: partnerId,
      PartnerItemSkuColumn.ITEM_SKU: itemSKU,
      PartnerItemSkuColumn.INSPECTION_ID: inspectionId,
      PartnerItemSkuColumn.LOT_NO: lotNo,
      PartnerItemSkuColumn.PACK_DATE: packDate,
      PartnerItemSkuColumn.LOT_SIZE: lotSize,
      PartnerItemSkuColumn.UNIQUE_ID: uniqueId,
      PartnerItemSkuColumn.PO_LINE_NO: poLineNo,
      PartnerItemSkuColumn.PO_NO: poNo,
    };
  }

  // copyWith
  PartnerItemSKUInspections copyWith({
    int? partnerId,
    String? itemSKU,
    int? inspectionId,
    String? lotNo,
    String? packDate,
    String? lotSize,
    String? uniqueId,
    int? poLineNo,
    String? poNo,
  }) {
    return PartnerItemSKUInspections(
      partnerId: partnerId ?? this.partnerId,
      itemSKU: itemSKU ?? this.itemSKU,
      inspectionId: inspectionId ?? this.inspectionId,
      lotNo: lotNo ?? this.lotNo,
      packDate: packDate ?? this.packDate,
      lotSize: lotSize ?? this.lotSize,
      uniqueId: uniqueId ?? this.uniqueId,
      poLineNo: poLineNo ?? this.poLineNo,
      poNo: poNo ?? this.poNo,
    );
  }
}
