import 'package:pverify/models/defect_item.dart';

class DefectCategories {
  int? id;
  String? name;
  List<DefectItem>? defectList;

  DefectCategories(this.id, this.name, this.defectList);

  DefectCategories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    if (json['defectList'] != null) {
      defectList = <DefectItem>[];
      json['defectList'].forEach((dynamic v) {
        defectList!.add(DefectItem.fromJson(v as Map<String, dynamic>));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    if (defectList != null) {
      data['defectList'] = defectList!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  // copyWith
  DefectCategories copyWith({
    int? id,
    String? name,
    List<DefectItem>? defectList,
  }) {
    return DefectCategories(
      id ?? this.id,
      name ?? this.name,
      defectList ?? this.defectList,
    );
  }
}
