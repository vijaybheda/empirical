import 'package:pverify/services/database/column_names.dart';
import 'package:pverify/services/database/database_helper.dart';

class Inspection {
  int? inspectionId;
  int? userId;
  int? partnerId;
  int? carrierId;
  int? commodityId;
  int? varietyId;
  String? varietyName; // For local inspection display only
  int? gradeId;
  int? createdTime;
  String? result;
  String? managerStatus;
  String? managerComment;
  String? status;
  int? downloadId;
  bool complete;
  int? uploadStatus = 0;
  int? completedTime;
  // bool isDefectsComplete = false;
  // bool isTrailerTempComplete = false;
  // bool isQualityControlComplete;
  String? specificationName;
  String? itemSKU;
  String? lotNo;
  String? packDate;
  String? specificationNumber;
  String? specificationVersion;
  String? specificationTypeName;
  int sampleSizeByCount;
  int itemSKUId;
  String? commodityName;
  String? poNumber;
  int serverInspectionId;
  int rating;
  int poLineNo;
  int? toLocationId;
  String? toLocationName;
  String? partnerName;
  String? cteType;
  String? itemSkuName;
  String? gtin;

  Inspection({
    this.inspectionId,
    this.userId,
    this.partnerId,
    this.carrierId,
    this.commodityId,
    this.varietyId,
    this.varietyName,
    this.gradeId,
    this.createdTime,
    this.result,
    this.managerStatus,
    this.managerComment,
    this.status,
    this.downloadId,
    required this.complete,
    this.uploadStatus,
    this.completedTime,
    // this.isDefectsComplete = false,
    // this.isTrailerTempComplete = false,
    // this.isQualityControlComplete = false,
    this.specificationName,
    this.itemSKU,
    this.lotNo,
    this.packDate,
    this.specificationNumber,
    this.specificationVersion,
    this.specificationTypeName,
    required this.sampleSizeByCount,
    required this.itemSKUId,
    this.commodityName,
    this.poNumber,
    this.serverInspectionId = 0,
    required this.rating,
    required this.poLineNo,
    this.toLocationId,
    this.toLocationName,
    this.partnerName,
    this.cteType,
    this.itemSkuName,
    this.gtin,
  });

  // toJson
  Map<String, dynamic> toJson() {
    return {
      // BaseColumns.ID: inspectionId,
      InspectionColumn.USER_ID: userId,
      InspectionColumn.PARTNER_ID: partnerId,
      InspectionColumn.CARRIER_ID: carrierId,
      InspectionColumn.COMMODITY_ID: commodityId,
      InspectionColumn.VARIETY_ID: varietyId,
      InspectionColumn.VARIETY_NAME: varietyName,
      InspectionColumn.GRADE_ID: gradeId,
      InspectionColumn.CREATED_TIME: createdTime,
      InspectionColumn.RESULT: result,
      InspectionColumn.MANAGER_STATUS: managerStatus,
      InspectionColumn.MANAGER_COMMENT: managerComment,
      InspectionColumn.STATUS: status,
      InspectionColumn.DOWNLOAD_ID: downloadId,
      InspectionColumn.COMPLETE: complete,
      InspectionColumn.UPLOAD_STATUS: uploadStatus,
      InspectionColumn.COMPLETED_TIME: completedTime,
      // InspectionColumn.IS_DEFECTS_COMPLETE: isDefectsComplete,
      // InspectionColumn.IS_TRAILER_TEMPCOMPLETE: isTrailerTempComplete,
      // InspectionColumn.IS_QUALITY_CONTROL_COMPLETE: isQualityControlComplete,
      InspectionColumn.SPECIFICATION_NAME: specificationName,
      InspectionColumn.ITEM_SKU: itemSKU,
      InspectionColumn.LOT_NO: lotNo,
      InspectionColumn.PACK_DATE: packDate,
      InspectionColumn.SPECIFICATION_NUMBER: specificationNumber,
      InspectionColumn.SPECIFICATION_VERSION: specificationVersion,
      InspectionColumn.SPECIFICATION_TYPENAME: specificationTypeName,
      InspectionColumn.SAMPLE_SIZE_BY_COUNT: sampleSizeByCount,
      InspectionColumn.ITEM_SKU_ID: itemSKUId,
      InspectionColumn.COMMODITY_NAME: commodityName,
      InspectionColumn.PO_NUMBER: poNumber,
      InspectionColumn.INSPECTION_SERVER_ID: serverInspectionId,
      InspectionColumn.RATING: rating,
      InspectionColumn.POLINENO: poLineNo,
      InspectionColumn.TO_LOCATION_ID: toLocationId,
      InspectionColumn.TO_LOCATION_NAME: toLocationName,
      InspectionColumn.PARTNER_NAME: partnerName,
      InspectionColumn.CTE_TYPE: cteType,
      InspectionColumn.ITEM_SKU_NAME: itemSkuName,
      // InspectionColumn.GTIN: gtin,
    };
  }

  // fromJson method
  factory Inspection.fromJson(Map<String, dynamic> json) {
    return Inspection(
      inspectionId: json[BaseColumns.ID],
      userId: json[InspectionColumn.USER_ID],
      partnerId: json[InspectionColumn.PARTNER_ID],
      carrierId: json[InspectionColumn.CARRIER_ID],
      commodityId: json[InspectionColumn.COMMODITY_ID],
      varietyId: json[InspectionColumn.VARIETY_ID],
      varietyName: json[InspectionColumn.VARIETY_NAME],
      gradeId: json[InspectionColumn.GRADE_ID],
      createdTime: json[InspectionColumn.CREATED_TIME],
      result: json[InspectionColumn.RESULT],
      managerStatus: json[InspectionColumn.MANAGER_STATUS],
      managerComment: json[InspectionColumn.MANAGER_COMMENT],
      status: json[InspectionColumn.STATUS],
      downloadId: json[InspectionColumn.DOWNLOAD_ID],
      complete: json[InspectionColumn.COMPLETE],
      uploadStatus: json[InspectionColumn.UPLOAD_STATUS],
      completedTime: json[InspectionColumn.COMPLETED_TIME],
      // isDefectsComplete: json['isDefectsComplete'],
      // isTrailerTempComplete: json['isTrailerTempComplete'],
      // isQualityControlComplete: json['isQualityControlComplete'],
      specificationName: json[InspectionColumn.SPECIFICATION_NAME],
      itemSKU: json[InspectionColumn.ITEM_SKU],
      lotNo: json[InspectionColumn.LOT_NO],
      packDate: json[InspectionColumn.PACK_DATE],
      specificationNumber: json[InspectionColumn.SPECIFICATION_NUMBER],
      specificationVersion: json[InspectionColumn.SPECIFICATION_VERSION],
      specificationTypeName: json[InspectionColumn.SPECIFICATION_TYPENAME],
      sampleSizeByCount: json[InspectionColumn.SAMPLE_SIZE_BY_COUNT],
      itemSKUId: json[InspectionColumn.ITEM_SKU_ID],
      commodityName: json[InspectionColumn.COMMODITY_NAME],
      poNumber: json[InspectionColumn.PO_NUMBER],
      serverInspectionId: json[InspectionColumn.INSPECTION_SERVER_ID],
      rating: json[InspectionColumn.RATING],
      poLineNo: json[InspectionColumn.POLINENO],
      toLocationId: json[InspectionColumn.TO_LOCATION_ID],
      toLocationName: json[InspectionColumn.TO_LOCATION_NAME],
      partnerName: json[InspectionColumn.PARTNER_NAME],
      cteType: json[InspectionColumn.CTE_TYPE],
      itemSkuName: json[InspectionColumn.ITEM_SKU_NAME],
      gtin: json[InspectionColumn.GTIN],
    );
  }

  Inspection copyWith({
    int? inspectionId,
    int? userId,
    int? partnerId,
    int? carrierId,
    int? commodityId,
    int? varietyId,
    String? varietyName,
    int? gradeId,
    int? createdTime,
    String? result,
    String? managerStatus,
    String? managerComment,
    String? status,
    int? downloadId,
    bool? complete,
    int? uploadStatus,
    int? completedTime,
    // bool? isDefectsComplete,
    // bool? isTrailerTempComplete,
    // bool? isQualityControlComplete,
    String? specificationName,
    String? itemSKU,
    String? lotNo,
    String? packDate,
    String? specificationNumber,
    String? specificationVersion,
    String? specificationTypeName,
    int? sampleSizeByCount,
    int? itemSKUId,
    String? commodityName,
    String? poNumber,
    int? serverInspectionId,
    int? rating,
    int? poLineNo,
    int? toLocationId,
    String? toLocationName,
    String? partnerName,
    String? cteType,
    String? itemSkuName,
    String? gtin,
  }) {
    return Inspection(
      inspectionId: inspectionId ?? this.inspectionId,
      userId: userId ?? this.userId,
      partnerId: partnerId ?? this.partnerId,
      carrierId: carrierId ?? this.carrierId,
      commodityId: commodityId ?? this.commodityId,
      varietyId: varietyId ?? this.varietyId,
      varietyName: varietyName ?? this.varietyName,
      gradeId: gradeId ?? this.gradeId,
      createdTime: createdTime ?? this.createdTime,
      result: result ?? this.result,
      managerStatus: managerStatus ?? this.managerStatus,
      managerComment: managerComment ?? this.managerComment,
      status: status ?? this.status,
      downloadId: downloadId ?? this.downloadId,
      complete: complete ?? this.complete,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      completedTime: completedTime ?? this.completedTime,
      // isDefectsComplete: isDefectsComplete ?? this.isDefectsComplete,
      // isTrailerTempComplete:
      //     isTrailerTempComplete ?? this.isTrailerTempComplete,
      // isQualityControlComplete:
      //     isQualityControlComplete ?? this.isQualityControlComplete,
      specificationName: specificationName ?? this.specificationName,
      itemSKU: itemSKU ?? this.itemSKU,
      lotNo: lotNo ?? this.lotNo,
      packDate: packDate ?? this.packDate,
      specificationNumber: specificationNumber ?? this.specificationNumber,
      specificationVersion: specificationVersion ?? this.specificationVersion,
      specificationTypeName:
          specificationTypeName ?? this.specificationTypeName,
      sampleSizeByCount: sampleSizeByCount ?? this.sampleSizeByCount,
      itemSKUId: itemSKUId ?? this.itemSKUId,
      commodityName: commodityName ?? this.commodityName,
      poNumber: poNumber ?? this.poNumber,
      serverInspectionId: serverInspectionId ?? this.serverInspectionId,
      rating: rating ?? this.rating,
      poLineNo: poLineNo ?? this.poLineNo,
      toLocationId: toLocationId ?? this.toLocationId,
      toLocationName: toLocationName ?? this.toLocationName,
      partnerName: partnerName ?? this.partnerName,
      cteType: cteType ?? this.cteType,
      itemSkuName: itemSkuName ?? this.itemSkuName,
      gtin: gtin ?? this.gtin,
    );
  }
}
