import 'package:pverify/services/database/column_names.dart';
import 'package:pverify/utils/utils.dart';

class MyInspection48HourItem {
  int? id;
  int? inspectionId;
  int? commodityId;
  int? carrierId;
  String? date = "";
  int? completed;
  String? status;
  String? commodityName;
  int? gradeId;
  String? specificationNumber;
  String? specificationVersion;
  String? specificationName;
  String? specificationTypeName;
  String? lotNo;
  String? packDate;
  int? sampleSizeByCount;
  String? itemSKU;
  int? itemSKUId;
  String? poNumber;
  int? toLocationId;
  String? cteType;
  String? itemSkuName;

  MyInspection48HourItem({
    this.id,
    this.inspectionId,
    this.commodityId,
    this.carrierId,
    this.date,
    this.completed,
    this.status,
    this.commodityName,
    this.gradeId,
    this.specificationNumber,
    this.specificationVersion,
    this.specificationName,
    this.specificationTypeName,
    this.lotNo,
    this.packDate,
    this.sampleSizeByCount,
    this.itemSKU,
    this.itemSKUId,
    this.poNumber,
    this.toLocationId,
    this.cteType,
    this.itemSkuName,
  });

  // fromJson method
  factory MyInspection48HourItem.fromJson(Map<String, dynamic> json) {
    printKeysAndValueTypes(json);
    return MyInspection48HourItem(
      id: json[InspectionColumn.ID],
      inspectionId: json[InspectionColumn.INSPECTION_SERVER_ID],
      commodityId: json[InspectionColumn.COMMODITY_ID],
      carrierId: json[InspectionColumn.CARRIER_ID],
      completed: json[InspectionColumn.COMPLETED_TIME],
      status: json[InspectionColumn.STATUS],
      commodityName: json[InspectionColumn.COMMODITY_NAME],
      gradeId: json[InspectionColumn.GRADE_ID],
      specificationNumber: json[InspectionColumn.SPECIFICATION_NUMBER],
      specificationVersion: json[InspectionColumn.SPECIFICATION_VERSION],
      specificationName: json[InspectionColumn.SPECIFICATION_NAME],
      specificationTypeName: json[InspectionColumn.SPECIFICATION_TYPENAME],
      lotNo: json[InspectionColumn.LOT_NO],
      packDate: json[InspectionColumn.PACK_DATE],
      sampleSizeByCount: json[InspectionColumn.SAMPLE_SIZE_BY_COUNT],
      itemSKU: json[InspectionColumn.ITEM_SKU],
      itemSKUId: json[InspectionColumn.ITEM_SKU_ID],
      poNumber: json[InspectionColumn.PO_NUMBER],
      toLocationId: json[InspectionColumn.TO_LOCATION_ID],
      cteType: json[InspectionColumn.CTE_TYPE],
      itemSkuName: json[InspectionColumn.ITEM_SKU_NAME],
    );
  }
}
