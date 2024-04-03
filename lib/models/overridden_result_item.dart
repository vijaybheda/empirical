class OverriddenResult {
  int? overriddenBy;
  String? overriddenResult;
  int? overriddenTimestamp; // Consider using DateTime for handling date/time
  String? overrriddenComments;
  String? oldResult;
  int? originalQtyShipped;
  int? originalQtyRejected;
  int? newQtyShipped;
  int? newQtyRejected;

  OverriddenResult({
    this.overriddenBy,
    this.overriddenResult,
    this.overriddenTimestamp,
    this.overrriddenComments,
    this.oldResult,
    this.originalQtyShipped,
    this.originalQtyRejected,
    this.newQtyShipped,
    this.newQtyRejected,
  });

  factory OverriddenResult.fromMap(Map<String, dynamic> map) {
    return OverriddenResult(
      overriddenBy: map['Overridden_By'],
      overriddenResult: map['Overridden_Result'],
      overriddenTimestamp: map['Overridden_Timestamp'],
      overrriddenComments: map['Overridden_Comments'],
      oldResult: map['Old_Result'],
      originalQtyShipped: map['Original_Qty_Shipped'],
      originalQtyRejected: map['Original_Qty_Rejected'],
      newQtyShipped: map['New_Qty_Shipped'],
      newQtyRejected: map['New_Qty_Rejected'],
    );
  }
}
