class SpecificationAnalyticalRequest {
  final int? inspectionID;
  final int? analyticalID;
  final String? sampleTextValue;
  final int? sampleNumValue;
  final String? comply;
  final String? comment;
  final String? analyticalName;
  final int? specTypeofEntry;
  final bool? isPictureRequired;
  final String? description;
  final double? specMin;
  final double? specMax;
  final String? inspectionResult;

  SpecificationAnalyticalRequest({
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
      inspectionID: json['inspectionID'],
      analyticalID: json['analyticalID'],
      sampleTextValue: json['sampleTextValue'],
      sampleNumValue: json['sampleNumValue'],
      comply: json['comply'],
      comment: json['comment'],
      analyticalName: json['analyticalName'],
      specTypeofEntry: json['specTypeofEntry'],
      isPictureRequired: json['isPictureRequired'],
      description: json['description'],
      specMin: json['specMin'],
      specMax: json['specMax'],
      inspectionResult: json['inspectionResult'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inspectionID': inspectionID,
      'analyticalID': analyticalID,
      'sampleTextValue': sampleTextValue,
      'sampleNumValue': sampleNumValue,
      'comply': comply,
      'comment': comment,
      'analyticalName': analyticalName,
      'specTypeofEntry': specTypeofEntry,
      'isPictureRequired': isPictureRequired,
      'description': description,
      'specMin': specMin,
      'specMax': specMax,
      'inspectionResult': inspectionResult,
    };
  }

  SpecificationAnalyticalRequest copyWith({
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
