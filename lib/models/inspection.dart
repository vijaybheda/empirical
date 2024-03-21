class Inspection {
  int? id; // For SQLite row id
  String userId;
  String partnerId;
  String carrierId;
  int commodityId;
  int varietyId;
  String varietyName;
  int createdTime;
  String status;
  bool isComplete;
  int gradeId;
  String downloadId;
  int uploadStatus;
  String specificationName;
  String specificationVersion;
  String specificationNumber;
  String specificationTypeName;
  String lotNo;
  String packDate;
  int sampleSizeByCount;
  String itemSKU;
  int itemSKUId;
  String commodityName;
  String poNumber;
  int rating;
  String poLineNo;
  String partnerName;
  int toLocationId;
  String cteType;
  String itemSkuName;

  Inspection({
    this.id,
    required this.userId,
    required this.partnerId,
    required this.carrierId,
    required this.commodityId,
    required this.varietyId,
    required this.varietyName,
    required this.createdTime,
    required this.status,
    required this.isComplete,
    required this.gradeId,
    required this.downloadId,
    required this.uploadStatus,
    required this.specificationName,
    required this.specificationVersion,
    required this.specificationNumber,
    required this.specificationTypeName,
    required this.lotNo,
    required this.packDate,
    required this.sampleSizeByCount,
    required this.itemSKU,
    required this.itemSKUId,
    required this.commodityName,
    required this.poNumber,
    required this.rating,
    required this.poLineNo,
    required this.partnerName,
    required this.toLocationId,
    required this.cteType,
    required this.itemSkuName,
  });

  factory Inspection.fromMap(Map<String, dynamic> json) => Inspection(
        id: json["id"],
        userId: json["user_id"],
        partnerId: json["partner_id"],
        carrierId: json["carrier_id"],
        commodityId: json["commodity_id"],
        varietyId: json["variety_id"],
        varietyName: json["variety_name"],
        createdTime: json["created_time"],
        status: json["status"],
        isComplete: json["is_complete"],
        gradeId: json["grade_id"],
        downloadId: json["download_id"],
        uploadStatus: json["upload_status"],
        specificationName: json["specification_name"],
        specificationVersion: json["specification_version"],
        specificationNumber: json["specification_number"],
        specificationTypeName: json["specification_type_name"],
        lotNo: json["lot_no"],
        packDate: json["pack_date"],
        sampleSizeByCount: json["sample_size_by_count"],
        itemSKU: json["item_sku"],
        itemSKUId: json["item_sku_id"],
        commodityName: json["commodity_name"],
        poNumber: json["po_number"],
        rating: json["rating"],
        poLineNo: json["po_line_no"],
        partnerName: json["partner_name"],
        toLocationId: json["to_location_id"],
        cteType: json["cte_type"],
        itemSkuName: json["item_sku_name"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "user_id": userId,
        "partner_id": partnerId,
        "carrier_id": carrierId,
        "commodity_id": commodityId,
        "variety_id": varietyId,
        "variety_name": varietyName,
        "created_time": createdTime,
        "status": status,
        "is_complete": isComplete,
        "grade_id": gradeId,
        "download_id": downloadId,
        "upload_status": uploadStatus,
        "specification_name": specificationName,
        "specification_version": specificationVersion,
        "specification_number": specificationNumber,
        "specification_type_name": specificationTypeName,
        "lot_no": lotNo,
        "pack_date": packDate,
        "sample_size_by_count": sampleSizeByCount,
        "item_sku": itemSKU,
        "item_sku_id": itemSKUId,
        "commodity_name": commodityName,
        "po_number": poNumber,
        "rating": rating,
        "po_line_no": poLineNo,
        "partner_name": partnerName,
        "to_location_id": toLocationId,
        "cte_type": cteType,
        "item_sku_name": itemSkuName,
      };

  // copyWith
  Inspection copyWith({
    int? id,
    String? userId,
    String? partnerId,
    String? carrierId,
    int? commodityId,
    int? varietyId,
    String? varietyName,
    int? createdTime,
    String? status,
    bool? isComplete,
    int? gradeId,
    String? downloadId,
    int? uploadStatus,
    String? specificationName,
    String? specificationVersion,
    String? specificationNumber,
    String? specificationTypeName,
    String? lotNo,
    String? packDate,
    int? sampleSizeByCount,
    String? itemSKU,
    int? itemSKUId,
    String? commodityName,
    String? poNumber,
    int? rating,
    String? poLineNo,
    String? partnerName,
    int? toLocationId,
    String? cteType,
    String? itemSkuName,
  }) {
    return Inspection(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      partnerId: partnerId ?? this.partnerId,
      carrierId: carrierId ?? this.carrierId,
      commodityId: commodityId ?? this.commodityId,
      varietyId: varietyId ?? this.varietyId,
      varietyName: varietyName ?? this.varietyName,
      createdTime: createdTime ?? this.createdTime,
      status: status ?? this.status,
      isComplete: isComplete ?? this.isComplete,
      gradeId: gradeId ?? this.gradeId,
      downloadId: downloadId ?? this.downloadId,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      specificationName: specificationName ?? this.specificationName,
      specificationVersion: specificationVersion ?? this.specificationVersion,
      specificationNumber: specificationNumber ?? this.specificationNumber,
      specificationTypeName:
          specificationTypeName ?? this.specificationTypeName,
      lotNo: lotNo ?? this.lotNo,
      packDate: packDate ?? this.packDate,
      sampleSizeByCount: sampleSizeByCount ?? this.sampleSizeByCount,
      itemSKU: itemSKU ?? this.itemSKU,
      itemSKUId: itemSKUId ?? this.itemSKUId,
      commodityName: commodityName ?? this.commodityName,
      poNumber: poNumber ?? this.poNumber,
      rating: rating ?? this.rating,
      poLineNo: poLineNo ?? this.poLineNo,
      partnerName: partnerName ?? this.partnerName,
      toLocationId: toLocationId ?? this.toLocationId,
      cteType: cteType ?? this.cteType,
      itemSkuName: itemSkuName ?? this.itemSkuName,
    );
  }
}
