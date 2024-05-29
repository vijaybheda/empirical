import 'package:pverify/services/database/column_names.dart';

class QualityControlItem {
  int? qcID;
  int? inspectionID;
  int? brandID;
  int? qtyShipped;
  int? uomQtyShippedID;
  String? rpc;
  int? originID;
  String? lot;
  String? packDate;
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
  int? isComplete;
  String? specificationName;
  String? qcdOpen1;
  String? qcdOpen2;
  String? qcdOpen3;
  String? qcdOpen4;
  String? workDate;
  String? gtin;
  int? lotsize;
  String? shipDate;
  String? dateType;
  String? gln;
  String? glnType;

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
    this.gln,
    this.glnType,
  });

  factory QualityControlItem.fromJson(Map<String, dynamic> json) {
    return QualityControlItem(
      qcID: json[QualityControlColumn.ID],
      inspectionID: json[QualityControlColumn.INSPECTION_ID],
      brandID: json[QualityControlColumn.BRAND_ID],
      qtyShipped: json[QualityControlColumn.QTY_SHIPPED],
      uomQtyShippedID: json[QualityControlColumn.UOM_QTY_SHIPPED_ID],
      rpc: json[QualityControlColumn.RPC],
      originID: json[QualityControlColumn.ORIGIN_ID],
      lot: json[QualityControlColumn.LOT_NUMBER],
      packDate: json[QualityControlColumn.PACK_DATE],
      seal: json[QualityControlColumn.SEAL],
      claimFiledAgainst: json[QualityControlColumn.CLAIM_FILED_AGAINST],
      qtyRejected: json[QualityControlColumn.QTY_REJECTED],
      uomQtyRejectedID: json[QualityControlColumn.UOM_QTY_REJECTED_ID],
      reasonID: json[QualityControlColumn.REASON_ID],
      qcComments: json[QualityControlColumn.QC_COMMENTS],
      poNumber: json[QualityControlColumn.PO_NO],
      qtyReceived: json[QualityControlColumn.QTY_RECEIVED],
      uomQtyReceivedID: json[QualityControlColumn.UOM_QTY_RECEIVED],
      pulpTempMin: json[QualityControlColumn.PULP_TEMP_MIN],
      pulpTempMax: json[QualityControlColumn.PULP_TEMP_MAX],
      recorderTempMin: json[QualityControlColumn.RECORDER_TEMP_MIN],
      recorderTempMax: json[QualityControlColumn.RECORDER_TEMP_MAX],
      isComplete: json[QualityControlColumn.IS_COMPLETE],
      specificationName: json[QualityControlColumn.SPECIFICATION_NAME],
      qcdOpen1: json[QualityControlColumn.QCDOPEN1],
      qcdOpen2: json[QualityControlColumn.QCDOPEN2],
      qcdOpen3: json[QualityControlColumn.QCDOPEN3],
      qcdOpen4: json[QualityControlColumn.QCDOPEN4],
      workDate: json[QualityControlColumn.QCDOPEN5],
      gtin: json[QualityControlColumn.GTIN],
      lotsize: json[QualityControlColumn.LOT_SIZE],
      shipDate: json[QualityControlColumn.SHIP_DATE],
      dateType: json[QualityControlColumn.DATE_TYPE],
      gln: json[QualityControlColumn.GLN],
      glnType: json[QualityControlColumn.GLN_TYPE],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data[QualityControlColumn.ID] = qcID;
    data[QualityControlColumn.INSPECTION_ID] = inspectionID;
    data[QualityControlColumn.BRAND_ID] = brandID;
    data[QualityControlColumn.QTY_SHIPPED] = qtyShipped;
    data[QualityControlColumn.UOM_QTY_SHIPPED_ID] = uomQtyShippedID;
    data[QualityControlColumn.RPC] = rpc;
    data[QualityControlColumn.ORIGIN_ID] = originID;
    data[QualityControlColumn.LOT_NUMBER] = lot;
    data[QualityControlColumn.PACK_DATE] = packDate;
    data[QualityControlColumn.SEAL] = seal;
    data[QualityControlColumn.CLAIM_FILED_AGAINST] = claimFiledAgainst;
    data[QualityControlColumn.QTY_REJECTED] = qtyRejected;
    data[QualityControlColumn.UOM_QTY_REJECTED_ID] = uomQtyRejectedID;
    data[QualityControlColumn.REASON_ID] = reasonID;
    data[QualityControlColumn.QC_COMMENTS] = qcComments;
    data[QualityControlColumn.PO_NO] = poNumber;
    data[QualityControlColumn.QTY_RECEIVED] = qtyReceived;
    data[QualityControlColumn.UOM_QTY_RECEIVED] = uomQtyReceivedID;
    data[QualityControlColumn.PULP_TEMP_MIN] = pulpTempMin;
    data[QualityControlColumn.PULP_TEMP_MAX] = pulpTempMax;
    data[QualityControlColumn.RECORDER_TEMP_MIN] = recorderTempMin;
    data[QualityControlColumn.RECORDER_TEMP_MAX] = recorderTempMax;
    data[QualityControlColumn.IS_COMPLETE] = isComplete;
    data[QualityControlColumn.SPECIFICATION_NAME] = specificationName;
    data[QualityControlColumn.QCDOPEN1] = qcdOpen1;
    data[QualityControlColumn.QCDOPEN2] = qcdOpen2;
    data[QualityControlColumn.QCDOPEN3] = qcdOpen3;
    data[QualityControlColumn.QCDOPEN4] = qcdOpen4;
    data[QualityControlColumn.QCDOPEN5] = workDate;
    data[QualityControlColumn.GTIN] = gtin;
    data[QualityControlColumn.LOT_SIZE] = lotsize;
    data[QualityControlColumn.SHIP_DATE] = shipDate;
    data[QualityControlColumn.DATE_TYPE] = dateType;
    data[QualityControlColumn.GLN] = gln;
    data[QualityControlColumn.GLN_TYPE] = glnType;
    return data;
  }
}
