import 'package:get/get_rx/src/rx_types/rx_types.dart';

import 'defect_item.dart';

class DefectsClass {
  RxList<SampleSetsObject>? sampleSet;
  DefectsClass({
    this.sampleSet,
  });
}

class SampleSetsObject {
  String? sampleValue;
  String? sampleId = '';
  String? name = '';
  int? setNumber = 0;
  double? timeCreated = 0.0;
  int? lotNumber = 0;
  String? packDate = '';
  bool? complete = false;
  List<DefectItem>? defectItem;

  SampleSetsObject({
    this.sampleValue,
    this.sampleId,
    this.name,
    this.setNumber,
    this.timeCreated,
    this.lotNumber,
    this.packDate,
    this.complete,
    this.defectItem,
  });
}
