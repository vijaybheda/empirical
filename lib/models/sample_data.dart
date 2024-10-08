import 'package:pverify/models/inspection_defect.dart';

class SampleData {
  int sampleSize;
  int? sampleId;
  int setNumber;
  int? timeCreated;
  String name;
  int iCnt = 0;
  int dCnt = 0;
  int sdCnt = 0;
  int vsdCnt = 0;
  int dcCnt = 0;
  bool complete;
  String? sampleNameUser;

  // defectItems: List<InspectionDefect> = [];
  List<InspectionDefect> defectItems = <InspectionDefect>[];

  SampleData({
    required this.sampleSize,
    required this.name,
    this.sampleId,
    this.setNumber = 0,
    this.timeCreated,
    this.iCnt = 0,
    this.dCnt = 0,
    this.sdCnt = 0,
    this.vsdCnt = 0,
    this.dcCnt = 0,
    this.complete = false,
    this.sampleNameUser,
    this.defectItems = const <InspectionDefect>[],
  });

  SampleData.simple({
    required this.sampleSize,
    required this.name,
  })  : sampleId = null,
        setNumber = 0,
        timeCreated = null,
        iCnt = 0,
        dCnt = 0,
        sdCnt = 0,
        vsdCnt = 0,
        dcCnt = 0,
        complete = false,
        sampleNameUser = null;

  SampleData copyWith({
    int? sampleSize,
    int? sampleId,
    int? setNumber,
    int? timeCreated,
    String? name,
    int? iCnt,
    int? dCnt,
    int? sdCnt,
    int? vsdCnt,
    int? dcCnt,
    bool? complete,
    String? sampleNameUser,
    List<InspectionDefect>? defectItems,
  }) {
    return SampleData(
      sampleSize: sampleSize ?? this.sampleSize,
      sampleId: sampleId ?? this.sampleId,
      setNumber: setNumber ?? this.setNumber,
      timeCreated: timeCreated ?? this.timeCreated,
      name: name ?? this.name,
      iCnt: iCnt ?? this.iCnt,
      dCnt: dCnt ?? this.dCnt,
      sdCnt: sdCnt ?? this.sdCnt,
      vsdCnt: vsdCnt ?? this.vsdCnt,
      dcCnt: dcCnt ?? this.dcCnt,
      complete: complete ?? this.complete,
      sampleNameUser: sampleNameUser ?? this.sampleNameUser,
      defectItems: defectItems ?? this.defectItems,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sampleSize': sampleSize,
      'sampleId': sampleId,
      'setNumber': setNumber,
      'timeCreated': timeCreated,
      'name': name,
      'iCnt': iCnt,
      'dCnt': dCnt,
      'sdCnt': sdCnt,
      'vsdCnt': vsdCnt,
      'dcCnt': dcCnt,
      'complete': complete,
      'sampleNameUser': sampleNameUser,
      'defectItems': defectItems,
    };
  }

  factory SampleData.fromMap(Map<String, dynamic> map) {
    return SampleData(
      sampleSize: map['sampleSize'],
      sampleId: map['sampleId'],
      setNumber: map['setNumber'],
      timeCreated: map['timeCreated'],
      name: map['name'],
      iCnt: map['iCnt'],
      dCnt: map['dCnt'],
      sdCnt: map['sdCnt'],
      vsdCnt: map['vsdCnt'],
      dcCnt: map['dcCnt'],
      complete: map['complete'],
      sampleNameUser: map['sampleNameUser'],
      defectItems: map['defectItems'],
    );
  }
}
