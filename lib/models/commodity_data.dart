import 'package:pverify/services/database/column_names.dart';

class Commodity {
  int? id;
  String? name;
  String? keywords;
  String? keywordName;

  Commodity({this.id, this.name, this.keywords, this.keywordName});

  Commodity.fromJson(Map<String, dynamic> json) {
    id = json[CommodityColumn.ID];
    name = json[CommodityColumn.NAME];
    keywords = json[CommodityColumn.KEYWORDS];
    keywordName = json[CommodityColumn.keywordName];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data[CommodityColumn.ID] = id;
    data[CommodityColumn.NAME] = name;
    data[CommodityColumn.KEYWORDS] = keywords;
    data[CommodityColumn.keywordName] = keywordName;
    return data;
  }

  // copyWith
  Commodity copyWith({
    int? id,
    String? name,
    String? keywords,
    String? keywordName,
  }) {
    return Commodity(
      id: id ?? this.id,
      name: name ?? this.name,
      keywords: keywords ?? this.keywords,
      keywordName: keywords ?? this.keywordName,
    );
  }
}
