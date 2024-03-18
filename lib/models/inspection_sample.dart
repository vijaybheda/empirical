class InspectionSample {
  final String? id;
  final String? name;
  final String? description;
  final String? imageUrl;
  final String? location;
  final String? date;
  final String? time;
  final String? status;
  final String? inspector;
  final String? inspectorId;
  final String? inspectorImageUrl;
  final String? inspectorEmail;
  final String? inspectorPhone;
  final String? inspectorLocation;
  final String? inspectorDepartment;
  final String? inspectorPosition;
  final String? inspectorStatus;
  final String? inspectorDate;
  final String? inspectorTime;

  InspectionSample({
    this.id,
    this.name,
    this.description,
    this.imageUrl,
    this.location,
    this.date,
    this.time,
    this.status,
    this.inspector,
    this.inspectorId,
    this.inspectorImageUrl,
    this.inspectorEmail,
    this.inspectorPhone,
    this.inspectorLocation,
    this.inspectorDepartment,
    this.inspectorPosition,
    this.inspectorStatus,
    this.inspectorDate,
    this.inspectorTime,
  });

  factory InspectionSample.fromJson(Map<String, dynamic> json) {
    return InspectionSample(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      location: json['location'],
      date: json['date'],
      time: json['time'],
      status: json['status'],
      inspector: json['inspector'],
      inspectorId: json['inspectorId'],
      inspectorImageUrl: json['inspectorImageUrl'],
      inspectorEmail: json['inspectorEmail'],
      inspectorPhone: json['inspectorPhone'],
      inspectorLocation: json['inspectorLocation'],
      inspectorDepartment: json['inspectorDepartment'],
      inspectorPosition: json['inspectorPosition'],
      inspectorStatus: json['inspectorStatus'],
      inspectorDate: json['inspectorDate'],
      inspectorTime: json['inspectorTime'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'location': location,
      'date': date,
      'time': time,
      'status': status,
      'inspector': inspector,
      'inspectorId': inspectorId,
      'inspectorImageUrl': inspectorImageUrl,
      'inspectorEmail': inspectorEmail,
      'inspectorPhone': inspectorPhone,
      'inspectorLocation': inspectorLocation,
      'inspectorDepartment': inspectorDepartment,
      'inspectorPosition': inspectorPosition,
      'inspectorStatus': inspectorStatus,
      'inspectorDate': inspectorDate,
      'inspectorTime': inspectorTime,
    };
  }
}
