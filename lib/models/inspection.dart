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
  bool isDefectsComplete = false;
  bool isTrailerTempComplete = false;
  bool isQualityControlComplete;
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
    this.isDefectsComplete = false,
    this.isTrailerTempComplete = false,
    this.isQualityControlComplete = false,
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
      'inspectionId': inspectionId,
      'userId': userId,
      'partnerId': partnerId,
      'carrierId': carrierId,
      'commodityId': commodityId,
      'varietyId': varietyId,
      'varietyName': varietyName,
      'gradeId': gradeId,
      'createdTime': createdTime,
      'result': result,
      'managerStatus': managerStatus,
      'managerComment': managerComment,
      'status': status,
      'downloadId': downloadId,
      'complete': complete,
      'uploadStatus': uploadStatus,
      'completedTime': completedTime,
      'isDefectsComplete': isDefectsComplete,
      'isTrailerTempComplete': isTrailerTempComplete,
      'isQualityControlComplete': isQualityControlComplete,
      'specificationName': specificationName,
      'itemSKU': itemSKU,
      'lotNo': lotNo,
      'packDate': packDate,
      'specificationNumber': specificationNumber,
      'specificationVersion': specificationVersion,
      'specificationTypeName': specificationTypeName,
      'sampleSizeByCount': sampleSizeByCount,
      'itemSKUId': itemSKUId,
      'commodityName': commodityName,
      'poNumber': poNumber,
      'serverInspectionId': serverInspectionId,
      'rating': rating,
      'poLineNo': poLineNo,
      'toLocationId': toLocationId,
      'toLocationName': toLocationName,
      'partnerName': partnerName,
      'cteType': cteType,
      'itemSkuName': itemSkuName,
      'gtin': gtin,
    };
  }

  // fromJson method
  factory Inspection.fromJson(Map<String, dynamic> json) {
    return Inspection(
      inspectionId: json['inspectionId'],
      userId: json['userId'],
      partnerId: json['partnerId'],
      carrierId: json['carrierId'],
      commodityId: json['commodityId'],
      varietyId: json['varietyId'],
      varietyName: json['varietyName'],
      gradeId: json['gradeId'],
      createdTime: json['createdTime'],
      result: json['result'],
      managerStatus: json['managerStatus'],
      managerComment: json['managerComment'],
      status: json['status'],
      downloadId: json['downloadId'],
      complete: json['complete'],
      uploadStatus: json['uploadStatus'],
      completedTime: json['completedTime'],
      isDefectsComplete: json['isDefectsComplete'],
      isTrailerTempComplete: json['isTrailerTempComplete'],
      isQualityControlComplete: json['isQualityControlComplete'],
      specificationName: json['specificationName'],
      itemSKU: json['itemSKU'],
      lotNo: json['lotNo'],
      packDate: json['packDate'],
      specificationNumber: json['specificationNumber'],
      specificationVersion: json['specificationVersion'],
      specificationTypeName: json['specificationTypeName'],
      sampleSizeByCount: json['sampleSizeByCount'],
      itemSKUId: json['itemSKUId'],
      commodityName: json['commodityName'],
      poNumber: json['poNumber'],
      serverInspectionId: json['serverInspectionId'],
      rating: json['rating'],
      poLineNo: json['poLineNo'],
      toLocationId: json['toLocationId'],
      toLocationName: json['toLocationName'],
      partnerName: json['partnerName'],
      cteType: json['cteType'],
      itemSkuName: json['itemSkuName'],
      gtin: json['gtin'],
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
    bool? isDefectsComplete,
    bool? isTrailerTempComplete,
    bool? isQualityControlComplete,
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
      isDefectsComplete: isDefectsComplete ?? this.isDefectsComplete,
      isTrailerTempComplete:
          isTrailerTempComplete ?? this.isTrailerTempComplete,
      isQualityControlComplete:
          isQualityControlComplete ?? this.isQualityControlComplete,
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
