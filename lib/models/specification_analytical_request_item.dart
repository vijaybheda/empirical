class SpecificationAnalyticalRequest {
  int? inspectionID;
  int? analyticalID;
  String? comply;
  String? sampleTextValue;
  int? sampleNumValue;
  String? comment;
  String? analyticalName;
  bool? pictureRequired;
  String? inspectionResult;

  SpecificationAnalyticalRequest({
    this.inspectionID,
    this.analyticalID,
    this.comply,
    this.sampleTextValue,
    this.sampleNumValue,
    this.comment,
    this.analyticalName,
    this.pictureRequired,
    this.inspectionResult,
  });

  factory SpecificationAnalyticalRequest.fromMap(Map<String, dynamic> map) {
    return SpecificationAnalyticalRequest(
      inspectionID: map['inspectionID'],
      analyticalID: map['analyticalID'],
      comply: map['comply'],
      sampleTextValue: map['sampleTextValue'],
      sampleNumValue: map['sampleNumValue'] is int
          ? map['sampleNumValue']
          : int.tryParse(map['sampleNumValue'] ?? '0'),
      comment: map['comment'],
      analyticalName: map['analyticalName'],
      pictureRequired: map['pictureRequired'] == "1",
      inspectionResult: map['inspectionResult'],
    );
  }
}
