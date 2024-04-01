class QCHeaderDetails {
  int? id;
  int? partnerID;
  String? poNo;
  String? sealNo;
  String? qchOpen1;
  String? qchOpen2;
  String? qchOpen3;
  String? qchOpen4;
  String? qchOpen5;
  String? qchOpen6;
  String? qchOpen9;
  String? qchOpen10;
  String? truckTempOk;
  String? productTransfer;
  String? cteType;

  QCHeaderDetails({
    this.id,
    this.partnerID,
    this.poNo,
    this.sealNo,
    this.qchOpen1,
    this.qchOpen2,
    this.qchOpen3,
    this.qchOpen4,
    this.qchOpen5,
    this.qchOpen6,
    this.qchOpen9,
    this.qchOpen10,
    this.truckTempOk,
    this.productTransfer,
    this.cteType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'partnerID': partnerID,
      'poNo': poNo,
      'sealNo': sealNo,
      'qchOpen1': qchOpen1,
      'qchOpen2': qchOpen2,
      'qchOpen3': qchOpen3,
      'qchOpen4': qchOpen4,
      'qchOpen5': qchOpen5,
      'qchOpen6': qchOpen6,
      'qchOpen9': qchOpen9,
      'qchOpen10': qchOpen10,
      'truckTempOk': truckTempOk,
      'productTransfer': productTransfer,
      'cteType': cteType,
    };
  }

  factory QCHeaderDetails.fromMap(Map<String, dynamic> map) {
    return QCHeaderDetails(
      id: map['id'],
      partnerID: map['partnerID'],
      poNo: map['poNo'],
      sealNo: map['sealNo'],
      qchOpen1: map['qchOpen1'],
      qchOpen2: map['qchOpen2'],
      qchOpen3: map['qchOpen3'],
      qchOpen4: map['qchOpen4'],
      qchOpen5: map['qchOpen5'],
      qchOpen6: map['qchOpen6'],
      qchOpen9: map['qchOpen9'],
      qchOpen10: map['qchOpen10'],
      truckTempOk: map['truckTempOk'],
      productTransfer: map['productTransfer'],
      cteType: map['cteType'],
    );
  }
}
