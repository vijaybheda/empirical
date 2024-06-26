class PurchaseOrderHeader {
  String poNumber;
  int partnerId;
  String partnerName;

  PurchaseOrderHeader({
    required this.poNumber,
    required this.partnerId,
    required this.partnerName,
  });

  factory PurchaseOrderHeader.fromMap(Map<String, dynamic> map) {
    return PurchaseOrderHeader(
      poNumber: map['PO_Number'],
      partnerId: map['PO_Partner_Id'],
      partnerName: map['PO_Partner_Name'],
    );
  }
}
