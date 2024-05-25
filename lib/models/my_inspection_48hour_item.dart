import 'package:pverify/services/database/column_names.dart';
import 'package:pverify/utils/utils.dart';

class MyInspection48HourItem {
  int? inspectionId;
  int? deliveryToId;
  int? supplierId;
  int? reasonId;
  int? commodityId;
  int? itemGroup1Id;
  int? carrierId;
  int? createdDate;
  String? date = "";
  bool? completed;
  String? deliveryTo;
  String? itemGroup1Name;
  String? inspectionResult;
  String? inspectionReason;
  String? supplierName;
  String? status;
  String? commodityName;
  String? carrierName;
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
    this.inspectionId,
    this.deliveryToId,
    this.supplierId,
    this.reasonId,
    this.commodityId,
    this.itemGroup1Id,
    this.carrierId,
    this.createdDate,
    this.date,
    this.completed,
    this.deliveryTo,
    this.itemGroup1Name,
    this.inspectionResult,
    this.inspectionReason,
    this.supplierName,
    this.status,
    this.commodityName,
    this.carrierName,
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
      inspectionId: json[InspectionColumn.ID],
      deliveryToId: json[InspectionColumn.DELIVERYTO_ID],
      supplierId: json[InspectionColumn.SUPPLIER_ID],
      reasonId: json[InspectionColumn.REASON_ID],
      commodityId: json[InspectionColumn.COMMODITY_ID],
      itemGroup1Id: json[InspectionColumn.ITEMGROUP1_ID],
      carrierId: json[InspectionColumn.CARRIER_ID],
      createdDate: json[InspectionColumn.CREATED_DATE],
      completed: json[InspectionColumn.COMPLETED_TIME],
      deliveryTo: json[InspectionColumn.DELIVERYTO],
      itemGroup1Name: json[InspectionColumn.ITEMGROUP1_NAME],
      inspectionResult: json[InspectionColumn.INSPECTION_RESULT],
      inspectionReason: json[InspectionColumn.INSPECTION_REASON],
      supplierName: json[InspectionColumn.SUPPLIER_NAME],
      status: json[InspectionColumn.STATUS],
      commodityName: json[InspectionColumn.COMMODITY_NAME],
      carrierName: json[InspectionColumn.CARRIER_NAME],
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

  /*MyInspection48HourItem.fromMap(Map<String, dynamic> map) {


       inspectionId = map[BaseColumns.ID]
        user_ID = map['User_ID'],
        partner_ID = map['Partner_ID'],
        carrier_ID = map['Carrier_ID'],
        commodity_ID = map['Commodity_ID'],
        variety_ID = map['Variety_ID'],
        variety_Name = map['Variety_Name'],
        created_Time = map['Created_Time'],
        result = map['Result'],
        manager_Status = map['Manager_Status'],
        manager_Comment = map['Manager_Comment'],
        status = map['Status'],
        complete = map['Complete'],
        grade_ID = map['Grade_ID'],
        download_ID = map['Download_ID'],
        uploadStatus = map['UploadStatus'],
        completed_Time = map['Completed_Time'],
        specification_Name = map['Specification_Name'],
        specification_Version = map['Specification_Version'],
        specification_Number = map['Specification_Number'],
        specification_TypeName = map['Specification_TypeName'],
        lot_No = map['Lot_No'],
        packDate = map['PackDate'],
        sample_Size_By_Count = map['Sample_Size_By_Count'],
        item_SKU = map['Item_SKU'],
        item_SKU_Id = map['Item_SKU_Id'],
        commodity_Name = map['Commodity_Name'],
        pO_Number = map['PO_Number'],
        inspectionServerID = map['InspectionServerID'],
        rating = map['Rating'],
        pOLineNo = map['POLineNo'],
        partnerName = map['Partner_Name']
    setDate(createdDate);
  }*/

  /*int? setDate(int? createdDate) {
    final AppStorage appStorage = AppStorage.instance;
    if (createdDate != null) {
      DateTime myDate = DateTime.fromMillisecondsSinceEpoch(createdDate);
      DateFormat dateFormat;
      String formattedDate;

      if (appStorage.dateFormat == "mm-dd-yyyy") {
        dateFormat = DateFormat('M/d/yyyy');
      } else if (appStorage.dateFormat == "yyyy-mm-dd") {
        dateFormat = DateFormat('yyyy/M/d');
      } else {
        dateFormat = DateFormat('d/M/yyyy');
      }

      formattedDate = dateFormat.format(myDate);
      date = formattedDate;
      return myDate.millisecondsSinceEpoch;
    }
    return null;
  }*/
}
