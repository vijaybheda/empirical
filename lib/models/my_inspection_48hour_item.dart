import 'package:intl/intl.dart';

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

  MyInspection48HourItem.fromMap(Map<String, dynamic> map)
      : inspectionId = map['inspectionId'],
        deliveryToId = map['deliveryToId'],
        supplierId = map['supplierId'],
        reasonId = map['reasonId'],
        commodityId = map['commodityId'],
        itemGroup1Id = map['itemGroup1Id'],
        carrierId = map['carrierId'],
        createdDate = map['createdDate'],
        date = map['date'],
        completed = map['completed'],
        deliveryTo = map['deliveryTo'],
        itemGroup1Name = map['itemGroup1Name'],
        inspectionResult = map['inspectionResult'],
        inspectionReason = map['inspectionReason'],
        supplierName = map['supplierName'],
        status = map['status'],
        commodityName = map['commodityName'],
        carrierName = map['carrierName'],
        gradeId = map['gradeId'],
        specificationNumber = map['specificationNumber'],
        specificationVersion = map['specificationVersion'],
        specificationName = map['specificationName'],
        specificationTypeName = map['specificationTypeName'],
        lotNo = map['lotNo'],
        packDate = map['packDate'],
        sampleSizeByCount = map['sampleSizeByCount'],
        itemSKU = map['itemSKU'],
        itemSKUId = map['itemSKUId'],
        poNumber = map['poNumber'],
        toLocationId = map['toLocationId'],
        cteType = map['cteType'],
        itemSkuName = map['itemSkuName'] {
    setDate(createdDate);
  }

  void setDate(int? createdDate) {
    if (createdDate != null) {
      DateTime myDate = DateTime.fromMillisecondsSinceEpoch(createdDate);
      DateFormat dateFormat;
      String formattedDate;

      if (AppInfo.dateFormat == "mm-dd-yyyy") {
        dateFormat = DateFormat('M/d/yyyy');
      } else if (AppInfo.dateFormat == "yyyy-mm-dd") {
        dateFormat = DateFormat('yyyy/M/d');
      } else {
        dateFormat = DateFormat('d/M/yyyy');
      }

      formattedDate = dateFormat.format(myDate);
      date = formattedDate;
    }
  }
}

class AppInfo {
  static String dateFormat = "mm-dd-yyyy";
}
