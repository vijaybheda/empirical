import 'package:pverify/models/defect_item.dart';
import 'package:pverify/models/document_item.dart';
import 'package:pverify/models/severity_defect.dart';
import 'package:pverify/services/database/column_names.dart';

class CommodityItem {
  int? id;
  String? name;
  int? numberSamplesSet;
  int? sampleSizeByCount;
  double? sampleSizeByWeight;
  List<DefectItem>? defectList;
  List<SeverityDefect> severityDefectList;
  String? keywords;
  List<DocumentItem> documents;

  CommodityItem({
    required this.id,
    required this.name,
    this.numberSamplesSet,
    this.sampleSizeByCount,
    this.sampleSizeByWeight,
    required this.defectList,
    required this.severityDefectList,
    this.keywords,
    required this.documents,
  });

  void addDocumentItem(DocumentItem item) {
    documents.add(item);
  }

  void removeDocumentItem(DocumentItem item) {
    documents.remove(item);
  }

  void addDefectItem(DefectItem item) {
    defectList ??= [];
    defectList?.add(item);
  }

  void removeDefectItem(DefectItem item) {
    defectList ??= [];
    defectList?.remove(item);
  }

  // toJson
  Map<String, dynamic> toJson() => {
        'ID': id,
        'Name': name,
        'numberSamplesSet': numberSamplesSet,
        'sampleSizeByCount': sampleSizeByCount,
        'sampleSizeByWeight': sampleSizeByWeight,
        'defectList': defectList?.map((item) => item.toJson()).toList(),
        'severityDefectList':
            severityDefectList.map((item) => item.toJson()).toList(),
        CommodityColumn.KEYWORDS: keywords,
        'documents': documents.map((item) => item.toJson()).toList(),
      };

  // fromJson
  factory CommodityItem.fromJson(Map<String, dynamic> json) {
    return CommodityItem(
      id: json['ID'],
      name: json['Name'],
      numberSamplesSet: json['numberSamplesSet'],
      sampleSizeByCount: json['sampleSizeByCount'],
      sampleSizeByWeight: json['sampleSizeByWeight'],
      defectList: (json['defectList'] != null)
          ? json['defectList']
              .map<DefectItem>((item) => DefectItem.fromJson(item))
              .toList()
          : [],
      severityDefectList: (json['severityDefectList'] != null)
          ? json['severityDefectList']
              .map<SeverityDefect>((item) => SeverityDefect.fromJson(item))
              .toList()
          : [],
      keywords: json[CommodityColumn.KEYWORDS],
      documents: (json['documents'] != null)
          ? json['documents']
              .map<DocumentItem>((item) => DocumentItem.fromJson(item))
              .toList()
          : [],
    );
  }

  // copyWith
  CommodityItem copyWith({
    int? id,
    String? name,
    int? numberSamplesSet,
    int? sampleSizeByCount,
    double? sampleSizeByWeight,
    List<DefectItem>? defectList,
    List<SeverityDefect>? severityDefectList,
    String? keywords,
    List<DocumentItem>? documents,
  }) {
    return CommodityItem(
      id: id ?? this.id,
      name: name ?? this.name,
      numberSamplesSet: numberSamplesSet ?? this.numberSamplesSet,
      sampleSizeByCount: sampleSizeByCount ?? this.sampleSizeByCount,
      sampleSizeByWeight: sampleSizeByWeight ?? this.sampleSizeByWeight,
      defectList: defectList ?? this.defectList,
      severityDefectList: severityDefectList ?? this.severityDefectList,
      keywords: keywords ?? this.keywords,
      documents: documents ?? this.documents,
    );
  }
}
