import 'package:pverify/services/database/column_names.dart';

class SpecificationAnalyticalRequest {
  final int? id;
  final int? inspectionID;
  final int? analyticalID;
  String? sampleTextValue;
  int? sampleNumValue;
  String? comply;
  String? comment;
  final String? analyticalName;
  final int? specTypeofEntry;
  final bool? isPictureRequired;
  final String? description;
  final double? specMin;
  final double? specMax;
  final String? inspectionResult;

  SpecificationAnalyticalRequest({
    this.id,
    this.inspectionID,
    this.analyticalID,
    this.sampleTextValue,
    this.sampleNumValue,
    this.comply,
    this.comment,
    this.analyticalName,
    this.specTypeofEntry,
    this.isPictureRequired,
    this.description,
    this.specMin,
    this.specMax,
    this.inspectionResult,
  });

  factory SpecificationAnalyticalRequest.fromJson(Map<String, dynamic> json) {
    return SpecificationAnalyticalRequest(
      id: json[SpecificationAttributesColumn.ID],
      inspectionID: json[SpecificationAttributesColumn.INSPECTION_ID],
      analyticalID: json[SpecificationAttributesColumn.ANALYTICAL_ID],
      sampleTextValue: json[SpecificationAttributesColumn.SAMPLE_TEXT_VALUE],
      sampleNumValue: json[SpecificationAttributesColumn.SAMPLE_VALUE],
      comply: json[SpecificationAttributesColumn.COMPLY],
      comment: json[SpecificationAttributesColumn.COMMENT],
      analyticalName: json[SpecificationAttributesColumn.ANALYTICAL_NAME],
      isPictureRequired:
          json[SpecificationAttributesColumn.PICTURE_REQUIRED] == 1
              ? true
              : false,
      inspectionResult: json[SpecificationAttributesColumn.INSPECTION_RESULT],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SpecificationAttributesColumn.ID: id,
      SpecificationAttributesColumn.INSPECTION_ID: inspectionID,
      SpecificationAttributesColumn.ANALYTICAL_ID: analyticalID,
      SpecificationAttributesColumn.SAMPLE_TEXT_VALUE: sampleTextValue,
      SpecificationAttributesColumn.SAMPLE_VALUE: sampleNumValue,
      SpecificationAttributesColumn.COMPLY: comply,
      SpecificationAttributesColumn.COMMENT: comment,
      SpecificationAttributesColumn.ANALYTICAL_NAME: analyticalName,
      'specTypeofEntry': specTypeofEntry,
      SpecificationAttributesColumn.PICTURE_REQUIRED: isPictureRequired,
      'description': description,
      'Spec_Min': specMin,
      'Spec_Max': specMax,
      SpecificationAttributesColumn.INSPECTION_RESULT: inspectionResult,
    };
  }

  SpecificationAnalyticalRequest copyWith({
    int? id,
    int? inspectionID,
    int? analyticalID,
    String? sampleTextValue,
    int? sampleNumValue,
    String? comply,
    String? comment,
    String? analyticalName,
    int? specTypeofEntry,
    bool? isPictureRequired,
    String? description,
    double? specMin,
    double? specMax,
    String? inspectionResult,
  }) {
    return SpecificationAnalyticalRequest(
      id: id ?? this.id,
      inspectionID: inspectionID ?? this.inspectionID,
      analyticalID: analyticalID ?? this.analyticalID,
      sampleTextValue: sampleTextValue ?? this.sampleTextValue,
      sampleNumValue: sampleNumValue ?? this.sampleNumValue,
      comply: comply ?? this.comply,
      comment: comment ?? this.comment,
      analyticalName: analyticalName ?? this.analyticalName,
      specTypeofEntry: specTypeofEntry ?? this.specTypeofEntry,
      isPictureRequired: isPictureRequired ?? this.isPictureRequired,
      description: description ?? this.description,
      specMin: specMin ?? this.specMin,
      specMax: specMax ?? this.specMax,
      inspectionResult: inspectionResult ?? this.inspectionResult,
    );
  }
}
