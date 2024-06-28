class PurchaseOrderDetails {
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
      'PO_Number': poNumber,
      'PO_Deliver_To_Id': deliverToId,
      'PO_Deliver_To_Name': deliverToName,
      'PO_Line_Number': poLineNumber,
      'PO_Item_Sku_Id': itemSkuId,
      'PO_Item_Sku_Code': itemSkuCode,
      'PO_Item_Sku_Name': itemSkuName,
      'PO_Quantity': quantity,
      'PO_Qty_UOM_Id': quantityUOMId,
      'PO_Qty_UOM_Name': quantityUOMName,
      'PO_Number_Spec': numberSpecification,
      'PO_Version_Spec': versionSpecification,
      'PO_Commodity_Id': commodityId,
      'PO_Commodity_Name': commodityName,
      'PO_Partner_Id': partnerId,
      'PO_Partner_Name': partnerName,
    };
  }

  factory PurchaseOrderDetails.fromMap(Map<String, dynamic> map) {
    return PurchaseOrderDetails(
      poNumber: map['PO_Number'],
      deliverToId: map['PO_Deliver_To_Id'],
      deliverToName: map['PO_Deliver_To_Name'],
      poLineNumber: map['PO_Line_Number'],
      itemSkuId: map['PO_Item_Sku_Id'],
      itemSkuCode: map['PO_Item_Sku_Code'],
      itemSkuName: map['PO_Item_Sku_Name'],
      quantity: map['PO_Quantity'],
      quantityUOMId: map['PO_Qty_UOM_Id'],
      quantityUOMName: map['PO_Qty_UOM_Name'],
      numberSpecification: map['PO_Number_Spec'],
      versionSpecification: map['PO_Version_Spec'],
      commodityId: map['PO_Commodity_Id'],
      commodityName: map['PO_Commodity_Name'],
      partnerId: map['PO_Partner_Id'],
      partnerName: map['PO_Partner_Name'],
    );
  }
}
