import 'package:pverify/models/document_item_data.dart';
import 'package:pverify/models/exception_item.dart';

class CommodityVarietyData {
  String commodityId;
  String varietyId;
  String varietyName;
  List<DocumentItemData> documents = [];
  List<ExceptionItem> exceptions = [];

  CommodityVarietyData(this.commodityId, this.varietyId, this.varietyName);

  void addDocumentItem(DocumentItemData item) {
    documents.add(item);
  }

  void addExceptionItem(ExceptionItem item) {
    exceptions.add(item);
  }

  // toJson
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['commodityId'] = commodityId;
    data['varietyId'] = varietyId;
    data['varietyName'] = varietyName;
    data['documents'] = documents.map((e) => e.toJson()).toList();
    data['exceptions'] = exceptions.map((e) => e.toJson()).toList();
    return data;
  }

  // fromJson
  factory CommodityVarietyData.fromJson(Map<String, dynamic> json) {
    return CommodityVarietyData(
      json['commodityId'],
      json['varietyId'],
      json['varietyName'],
    )
      ..documents = (json['documents'] as List<dynamic>)
          .map((e) => DocumentItemData.fromJson(e as Map<String, dynamic>))
          .toList()
      ..exceptions = (json['exceptions'] as List<dynamic>)
          .map((e) => ExceptionItem.fromJson(e as Map<String, dynamic>))
          .toList();
  }

  // copyWith
  CommodityVarietyData copyWith({
    String? commodityId,
    String? varietyId,
    String? varietyName,
    List<DocumentItemData>? documents,
    List<ExceptionItem>? exceptions,
  }) {
    return CommodityVarietyData(
      commodityId ?? this.commodityId,
      varietyId ?? this.varietyId,
      varietyName ?? this.varietyName,
    )
      ..documents = documents ?? this.documents
      ..exceptions = exceptions ?? this.exceptions;
  }
}
