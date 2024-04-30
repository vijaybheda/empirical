import 'package:get/get_rx/src/rx_types/rx_types.dart';

import 'defect_item.dart';

class DefectsClass {
  RxList<SampleSetObject>? sampleSet;
  DefectsClass({
    this.sampleSet,
  });
}

class SampleSetObject {
  String? sampleValue;
  String? sampleId = '';
  String? name = '';
  int? setNumber = 0;
  double? timeCreated = 0.0;
  int? lotNumber = 0;
  String? packDate = '';
  bool? complete = false;
  int? sampleSize;
  int? iCnt = 0;
  int? dCnt = 0;
  int? sdCnt = 0;
  int? vsdCnt = 0;
  int? dcCnt = 0;
  String? sampleNameUser;
  List<DefectItem>? defectItem;

  SampleSetObject({
    this.sampleValue,
    this.sampleId,
    this.name,
    this.setNumber,
    this.timeCreated,
    this.lotNumber,
    this.packDate,
    this.complete,
    this.sampleSize,
    this.iCnt,
    this.dCnt,
    this.sdCnt,
    this.vsdCnt,
    this.dcCnt,
    this.defectItem,
  });
}
