class InspectionSample {
  int? sampleId;
  int? inspectionId;
  int? setSize;
  String? setName;
  int? setNumber;
  int? createdTime;
  int? lastUpdatedTime;
  int? lotNumber;
  String? packDate;
  bool? isComplete;
  String? sampleName;

  InspectionSample({
    this.sampleId,
    this.inspectionId,
    this.setSize,
    this.setName,
    this.setNumber,
    this.createdTime,
    this.lastUpdatedTime,
    this.lotNumber,
    this.packDate,
    this.isComplete,
    this.sampleName,
  });

  factory InspectionSample.fromJson(Map<String, dynamic> json) {
    return InspectionSample(
      sampleId: json['sampleId'],
      inspectionId: json['inspectionId'],
      setSize: json['setSize'],
      setName: json['setName'],
      setNumber: json['setNumber'],
      createdTime: json['createdTime'],
      lastUpdatedTime: json['lastUpdatedTime'],
      lotNumber: json['lotNumber'],
      packDate: json['packDate'],
      isComplete: json['isComplete'],
      sampleName: json['sampleName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sampleId': sampleId,
      'inspectionId': inspectionId,
      'setSize': setSize,
      'setName': setName,
      'setNumber': setNumber,
      'createdTime': createdTime,
      'lastUpdatedTime': lastUpdatedTime,
      'lotNumber': lotNumber,
      'packDate': packDate,
      'isComplete': isComplete,
      'sampleName': sampleName,
    };
  }

  InspectionSample copyWith({
    int? sampleId,
    int? inspectionId,
    int? setSize,
    String? setName,
    int? setNumber,
    int? createdTime,
    int? lastUpdatedTime,
    int? lotNumber,
    String? packDate,
    bool? isComplete,
    String? sampleName,
  }) {
    return InspectionSample(
      sampleId: sampleId ?? this.sampleId,
      inspectionId: inspectionId ?? this.inspectionId,
      setSize: setSize ?? this.setSize,
      setName: setName ?? this.setName,
      setNumber: setNumber ?? this.setNumber,
      createdTime: createdTime ?? this.createdTime,
      lastUpdatedTime: lastUpdatedTime ?? this.lastUpdatedTime,
      lotNumber: lotNumber ?? this.lotNumber,
      packDate: packDate ?? this.packDate,
      isComplete: isComplete ?? this.isComplete,
      sampleName: sampleName ?? this.sampleName,
    );
  }
}
