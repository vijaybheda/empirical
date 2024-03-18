class InspectionAttachment {
  int? id; // SQLite row id
  int inspectionId;
  String title;
  int createdTime;
  String fileLocation;

  InspectionAttachment({
    this.id,
    required this.inspectionId,
    required this.title,
    required this.createdTime,
    required this.fileLocation,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'inspectionId': inspectionId,
      'title': title,
      'createdTime': createdTime,
      'fileLocation': fileLocation,
    };
  }

  factory InspectionAttachment.fromMap(Map<String, dynamic> map) {
    return InspectionAttachment(
      id: map['id'],
      inspectionId: map['inspectionId'],
      title: map['title'],
      createdTime: map['createdTime'],
      fileLocation: map['fileLocation'],
    );
  }
}
