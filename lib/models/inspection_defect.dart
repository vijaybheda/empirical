import 'package:flutter/material.dart';
import 'package:pverify/services/database/column_names.dart';

class InspectionDefect {
  int? inspectionDefectId;
  int? sampleId;
  String? spinnerSelection;
  int? defectId;
  int? injuryCnt;
  int? damageCnt;
  int? seriousDamageCnt;
  String? comment;
  int? createdTime;
  List<int>? attachmentIds;
  int? verySeriousDamageCnt;
  int? decayCnt;
  int? severityInjuryId;
  int? severityDamageId;
  int? severitySeriousDamageId;
  int? severityVerySeriousDamageId;
  int? severityDecayId;
  String? defectCategory;
  TextEditingController injuryTextEditingController =
      TextEditingController(text: '0');
  TextEditingController damageTextEditingController =
      TextEditingController(text: '0');
  TextEditingController sDamageTextEditingController =
      TextEditingController(text: '0');
  TextEditingController vsDamageTextEditingController =
      TextEditingController(text: '0');
  TextEditingController decayTextEditingController =
      TextEditingController(text: '0');

  InspectionDefect({
    this.inspectionDefectId,
    this.sampleId,
    this.spinnerSelection,
    this.defectId,
    this.injuryCnt,
    this.damageCnt,
    this.seriousDamageCnt,
    this.comment,
    this.createdTime,
    this.attachmentIds,
    this.verySeriousDamageCnt,
    this.decayCnt,
    this.severityInjuryId,
    this.severityDamageId,
    this.severitySeriousDamageId,
    this.severityVerySeriousDamageId,
    this.severityDecayId,
    this.defectCategory,
    // this.injuryTextEditingController,
    // this.damageTextEditingController,
    // this.sDamageTextEditingController,
    // this.vsDamageTextEditingController,
    // this.decayTextEditingController,
  });

  factory InspectionDefect.fromJson(Map<String, dynamic> json) {
    return InspectionDefect(
      inspectionDefectId: json[InspectionDefectColumn.ID],
      spinnerSelection: json[InspectionDefectColumn.DEFECT_NAME],
      defectId: json[InspectionDefectColumn.DEFECT_ID],
      injuryCnt: json[InspectionDefectColumn.INJURY_CNT],
      damageCnt: json[InspectionDefectColumn.DAMAGE_CNT],
      seriousDamageCnt: json[InspectionDefectColumn.SERIOUS_DAMAGE_CNT],
      comment: json[InspectionDefectColumn.COMMENTS],
      createdTime: json[InspectionDefectColumn.CREATED_TIME],
      verySeriousDamageCnt:
          json[InspectionDefectColumn.VERY_SERIOUS_DAMAGE_CNT],
      decayCnt: json[InspectionDefectColumn.DECAY_CNT],
      severityInjuryId: json[InspectionDefectColumn.INJURY_ID],
      severityDamageId: json[InspectionDefectColumn.DAMAGE_ID],
      severitySeriousDamageId: json[InspectionDefectColumn.SERIOUS_DAMAGE_ID],
      severityVerySeriousDamageId:
          json[InspectionDefectColumn.VERY_SERIOUS_DAMAGE_ID],
      severityDecayId: json[InspectionDefectColumn.DECAY_ID],
      defectCategory: json[InspectionDefectColumn.DEFECT_CATEGORY],
    );
  }

  // toMap
  Map<String, dynamic> toMap() {
    return {
      InspectionDefectColumn.ID: inspectionDefectId,
      InspectionDefectColumn.DEFECT_NAME: spinnerSelection,
      InspectionDefectColumn.DEFECT_ID: defectId,
      InspectionDefectColumn.INJURY_CNT: injuryCnt,
      InspectionDefectColumn.DAMAGE_CNT: damageCnt,
      InspectionDefectColumn.SERIOUS_DAMAGE_CNT: seriousDamageCnt,
      InspectionDefectColumn.COMMENTS: comment,
      InspectionDefectColumn.CREATED_TIME: createdTime,
      InspectionDefectColumn.VERY_SERIOUS_DAMAGE_CNT: verySeriousDamageCnt,
      InspectionDefectColumn.DECAY_CNT: decayCnt,
      InspectionDefectColumn.INJURY_ID: severityInjuryId,
      InspectionDefectColumn.DAMAGE_ID: severityDamageId,
      InspectionDefectColumn.SERIOUS_DAMAGE_ID: severitySeriousDamageId,
      InspectionDefectColumn.VERY_SERIOUS_DAMAGE_ID:
          severityVerySeriousDamageId,
      InspectionDefectColumn.DECAY_ID: severityDecayId,
      InspectionDefectColumn.DEFECT_CATEGORY: defectCategory,
    };
  }

  // copyWith
  InspectionDefect copyWith({
    int? inspectionDefectId,
    int? sampleId,
    String? spinnerSelection,
    int? defectId,
    int? injuryCnt,
    int? damageCnt,
    int? seriousDamageCnt,
    String? comment,
    int? createdTime,
    List<int>? attachmentIds,
    int? verySeriousDamageCnt,
    int? decayCnt,
    int? severityInjuryId,
    int? severityDamageId,
    int? severitySeriousDamageId,
    int? severityVerySeriousDamageId,
    int? severityDecayId,
    String? defectCategory,
  }) {
    return InspectionDefect(
      inspectionDefectId: inspectionDefectId ?? this.inspectionDefectId,
      sampleId: sampleId ?? this.sampleId,
      spinnerSelection: spinnerSelection ?? this.spinnerSelection,
      defectId: defectId ?? this.defectId,
      injuryCnt: injuryCnt ?? this.injuryCnt,
      damageCnt: damageCnt ?? this.damageCnt,
      seriousDamageCnt: seriousDamageCnt ?? this.seriousDamageCnt,
      comment: comment ?? this.comment,
      createdTime: createdTime ?? this.createdTime,
      attachmentIds: attachmentIds ?? this.attachmentIds,
      verySeriousDamageCnt: verySeriousDamageCnt ?? this.verySeriousDamageCnt,
      decayCnt: decayCnt ?? this.decayCnt,
      severityInjuryId: severityInjuryId ?? this.severityInjuryId,
      severityDamageId: severityDamageId ?? this.severityDamageId,
      severitySeriousDamageId:
          severitySeriousDamageId ?? this.severitySeriousDamageId,
      severityVerySeriousDamageId:
          severityVerySeriousDamageId ?? this.severityVerySeriousDamageId,
      severityDecayId: severityDecayId ?? this.severityDecayId,
      defectCategory: defectCategory ?? this.defectCategory,
    );
  }
}
