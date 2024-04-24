class QualityControlItem {
  int? qcID;
  int? inspectionID;
  int? brandID;
  int? qtyShipped;
  int? uomQtyShippedID;
  String? rpc;
  int? originID;
  String? lot;
  int?
      packDate; // Assuming UNIX timestamp (int). Consider converting to DateTime.
  String? seal;
  String? claimFiledAgainst;
  int? qtyRejected;
  int? uomQtyRejectedID;
  int? reasonID;
  String? qcComments;
  String? poNumber;
  int? qtyReceived;
  int? uomQtyReceivedID;
  int? pulpTempMin;
  int? pulpTempMax;
  int? recorderTempMin;
  int? recorderTempMax;
  bool? isComplete;
  String? specificationName;
  String? qcdOpen1;
  String? qcdOpen2;
  String? qcdOpen3;
  String? qcdOpen4;
  int?
      workDate; // Assuming UNIX timestamp (int). Consider converting to DateTime.
  String? gtin;
  int? lotsize;
  int?
      shipDate; // Assuming UNIX timestamp (int). Consider converting to DateTime.
  String? dateType;

  QualityControlItem({
    this.qcID,
    this.inspectionID,
    this.brandID,
    this.qtyShipped,
    this.uomQtyShippedID,
    this.rpc,
    this.originID,
    this.lot,
    this.packDate,
    this.seal,
    this.claimFiledAgainst,
    this.qtyRejected,
    this.uomQtyRejectedID,
    this.reasonID,
    this.qcComments,
    this.poNumber,
    this.qtyReceived,
    this.uomQtyReceivedID,
    this.pulpTempMin,
    this.pulpTempMax,
    this.recorderTempMin,
    this.recorderTempMax,
    this.isComplete,
    this.specificationName,
    this.qcdOpen1,
    this.qcdOpen2,
    this.qcdOpen3,
    this.qcdOpen4,
    this.workDate,
    this.gtin,
    this.lotsize,
    this.shipDate,
    this.dateType,
  });

  factory QualityControlItem.fromJson(Map<String, dynamic> json) {
    return QualityControlItem(
      qcID: json['qcID'],
      inspectionID: json['inspectionID'],
      brandID: json['brandID'],
      qtyShipped: json['qtyShipped'],
      uomQtyShippedID: json['uomQtyShippedID'],
      rpc: json['rpc'],
      originID: json['originID'],
      lot: json['lot'],
      packDate: json['packDate'],
      seal: json['seal'],
      claimFiledAgainst: json['claimFiledAgainst'],
      qtyRejected: json['qtyRejected'],
      uomQtyRejectedID: json['uomQtyRejectedID'],
      reasonID: json['reasonID'],
      qcComments: json['qcComments'],
      poNumber: json['poNumber'],
      qtyReceived: json['qtyReceived'],
      uomQtyReceivedID: json['uomQtyReceivedID'],
      pulpTempMin: json['pulpTempMin'],
      pulpTempMax: json['pulpTempMax'],
      recorderTempMin: json['recorderTempMin'],
      recorderTempMax: json['recorderTempMax'],
      isComplete: json['isComplete'],
      specificationName: json['specificationName'],
      qcdOpen1: json['qcdOpen1'],
      qcdOpen2: json['qcdOpen2'],
      qcdOpen3: json['qcdOpen3'],
      qcdOpen4: json['qcdOpen4'],
      workDate: json['workDate'],
      gtin: json['gtin'],
      lotsize: json['lotsize'],
      shipDate: json['shipDate'],
      dateType: json['dateType'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['qcID'] = qcID;
    data['inspectionID'] = inspectionID;
    data['brandID'] = brandID;
    data['qtyShipped'] = qtyShipped;
    data['uomQtyShippedID'] = uomQtyShippedID;
    data['rpc'] = rpc;
    data['originID'] = originID;
    data['lot'] = lot;
    data['packDate'] = packDate;
    data['seal'] = seal;
    data['claimFiledAgainst'] = claimFiledAgainst;
    data['qtyRejected'] = qtyRejected;
    data['uomQtyRejectedID'] = uomQtyRejectedID;
    data['reasonID'] = reasonID;
    data['qcComments'] = qcComments;
    data['poNumber'] = poNumber;
    data['qtyReceived'] = qtyReceived;
    data['uomQtyReceivedID'] = uomQtyReceivedID;
    data['pulpTempMin'] = pulpTempMin;
    data['pulpTempMax'] = pulpTempMax;
    data['recorderTempMin'] = recorderTempMin;
    data['recorderTempMax'] = recorderTempMax;
    data['isComplete'] = isComplete;
    data['specificationName'] = specificationName;
    data['qcdOpen1'] = qcdOpen1;
    data['qcdOpen2'] = qcdOpen2;
    data['qcdOpen3'] = qcdOpen3;
    data['qcdOpen4'] = qcdOpen4;
    data['workDate'] = workDate;
    data['gtin'] = gtin;
    data['lotsize'] = lotsize;
    data['shipDate'] = shipDate;
    data['dateType'] = dateType;
    return data;
  }
}
