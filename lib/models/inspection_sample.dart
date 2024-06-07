class InspectionSample {
  int? sampleId;
  int? inspectionId;
  int? setSize;
  String? setName;
  int? setNumber;
  int? createdTime;
  int? lastUpdatedTime;
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
    this.isComplete,
    this.sampleName,
  });

  factory InspectionSample.fromJson(Map<String, dynamic> json) {
    return InspectionSample(
      sampleId: json['_id'],
      inspectionId: json['Inspection_ID'],
      setSize: json['Set_Size'],
      setName: json['Set_Name'],
      setNumber: json['Set_Number'],
      createdTime: json['Created_Time'],
      lastUpdatedTime: json['Last_Updated_Time'],
      isComplete: json['complete'] == 1.toString(),
      sampleName: json['sampleName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': sampleId,
      'Inspection_ID': inspectionId,
      'Set_Size': setSize,
      'Set_Name': setName,
      'Set_Number': setNumber,
      'Created_Time': createdTime,
      'Last_Updated_Time': lastUpdatedTime,
      'complete': isComplete,
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
      isComplete: isComplete ?? this.isComplete,
      sampleName: sampleName ?? this.sampleName,
    );
  }
}
