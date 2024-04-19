import 'package:pverify/services/database/column_names.dart';
import 'package:pverify/utils/utils.dart';

class SpecificationAnalytical {
  // Number_Specification (String)
  // Version_Specification (String)
  // Analytical_ID (int)
  // Analytical_name (String)
  // Spec_Min (String)
  // Spec_Max (int)
  // Target_Num_Value (String)
  // Target_Text_Value (String)
  // UOM_Name (String)
  // Type_Entry (String)
  // Description (String)
  // OrderNo (int)
  // Picture_Required (String)
  // Target_Text_Default (String)
  // Inspection_Result (String)

  String? specificationNumber;
  String? specificationVersion;
  String? analyticalName;
  int? analyticalID;
  double? specMin;
  double? specMax;
  double? specTargetNumValue;
  String? uomName;
  String? specTargetTextValue;
  var specTypeofEntry;
  bool? isTargetNumValue;
  String? description;
  int? order;
  bool? isPictureRequired;
  String? specTargetTextDefault;
  String? inspectionResult;

  SpecificationAnalytical({
    this.specificationNumber,
    this.specificationVersion,
    this.analyticalName,
    this.analyticalID,
    this.specMin,
    this.specMax,
    this.specTargetNumValue,
    this.uomName,
    this.specTargetTextValue,
    this.specTypeofEntry,
    this.isTargetNumValue,
    this.description,
    this.order,
    this.isPictureRequired,
    this.specTargetTextDefault,
    this.inspectionResult,
  });

  factory SpecificationAnalytical.fromMap(Map<String, dynamic> map) {
    // printKeysAndValueTypes(map);
    return SpecificationAnalytical(
      specificationNumber:
          map[SpecificationAnalyticalColumn.NUMBER_SPECIFICATION],
      specificationVersion:
          map[SpecificationAnalyticalColumn.VERSION_SPECIFICATION],
      analyticalName: map[SpecificationAnalyticalColumn.ANALYTICAL_NAME],
      analyticalID: parseIntOrReturnNull(
          map[SpecificationAnalyticalColumn.ANALYTICAL_ID]),
      specMin:
          parseDoubleOrReturnNull(map[SpecificationAnalyticalColumn.SPEC_MIN]),
      specMax:
          parseDoubleOrReturnNull(map[SpecificationAnalyticalColumn.SPEC_MAX]),
      specTargetNumValue: parseDoubleOrReturnNull(
          map[SpecificationAnalyticalColumn.TARGET_NUM_VALUE]),
      uomName: map[SpecificationAnalyticalColumn.UOM_NAME],
      specTargetTextValue: map[SpecificationAnalyticalColumn.TARGET_TEXT_VALUE],
      specTypeofEntry: map[SpecificationAnalyticalColumn.TYPE_ENTRY],
      isTargetNumValue: map['isTargetNumValue'] == 1,
      description: map[SpecificationAnalyticalColumn.DESCRIPTION],
      order: parseIntOrReturnNull(map[SpecificationAnalyticalColumn.ORDER_NO]),
      isPictureRequired:
          map[SpecificationAnalyticalColumn.PICTURE_REQUIRED] == 1,
      specTargetTextDefault:
          map[SpecificationAnalyticalColumn.TARGET_TEXT_DEFAULT],
      inspectionResult: map[SpecificationAnalyticalColumn.INSPECTION_RESULT],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      SpecificationAnalyticalColumn.NUMBER_SPECIFICATION: specificationNumber,
      SpecificationAnalyticalColumn.VERSION_SPECIFICATION: specificationVersion,
      SpecificationAnalyticalColumn.ANALYTICAL_NAME: analyticalName,
      SpecificationAnalyticalColumn.ANALYTICAL_ID: analyticalID,
      SpecificationAnalyticalColumn.SPEC_MIN: specMin,
      SpecificationAnalyticalColumn.SPEC_MAX: specMax,
      SpecificationAnalyticalColumn.TARGET_NUM_VALUE: specTargetNumValue,
      SpecificationAnalyticalColumn.UOM_NAME: uomName,
      SpecificationAnalyticalColumn.TARGET_TEXT_VALUE: specTargetTextValue,
      SpecificationAnalyticalColumn.TYPE_ENTRY: specTypeofEntry,
      'isTargetNumValue': isTargetNumValue,
      SpecificationAnalyticalColumn.DESCRIPTION: description,
      SpecificationAnalyticalColumn.ORDER_NO: order,
      SpecificationAnalyticalColumn.PICTURE_REQUIRED: isPictureRequired,
      SpecificationAnalyticalColumn.TARGET_TEXT_DEFAULT: specTargetTextDefault,
      SpecificationAnalyticalColumn.INSPECTION_RESULT: inspectionResult,
    };
  }

  SpecificationAnalytical copyWith({
    String? specificationNumber,
    String? specificationVersion,
    String? analyticalName,
    int? analyticalID,
    double? specMin,
    double? specMax,
    double? specTargetNumValue,
    String? uomName,
    String? specTargetTextValue,
    var specTypeofEntry,
    bool? isTargetNumValue,
    String? description,
    int? order,
    bool? isPictureRequired,
    String? specTargetTextDefault,
    String? inspectionResult,
  }) {
    return SpecificationAnalytical(
      specificationNumber: specificationNumber ?? this.specificationNumber,
      specificationVersion: specificationVersion ?? this.specificationVersion,
      analyticalName: analyticalName ?? this.analyticalName,
      analyticalID: analyticalID ?? this.analyticalID,
      specMin: specMin ?? this.specMin,
      specMax: specMax ?? this.specMax,
      specTargetNumValue: specTargetNumValue ?? this.specTargetNumValue,
      uomName: uomName ?? this.uomName,
      specTargetTextValue: specTargetTextValue ?? this.specTargetTextValue,
      specTypeofEntry: specTypeofEntry ?? this.specTypeofEntry,
      isTargetNumValue: isTargetNumValue ?? this.isTargetNumValue,
      description: description ?? this.description,
      order: order ?? this.order,
      isPictureRequired: isPictureRequired ?? this.isPictureRequired,
      specTargetTextDefault:
          specTargetTextDefault ?? this.specTargetTextDefault,
      inspectionResult: inspectionResult ?? this.inspectionResult,
    );
  }
}
