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

  InspectionSample copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? location,
    String? date,
    String? time,
    String? status,
    String? inspector,
    String? inspectorId,
    String? inspectorImageUrl,
    String? inspectorEmail,
    String? inspectorPhone,
    String? inspectorLocation,
    String? inspectorDepartment,
    String? inspectorPosition,
    String? inspectorStatus,
    String? inspectorDate,
    String? inspectorTime,
  }) {
    return InspectionSample(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      inspector: inspector ?? this.inspector,
      inspectorId: inspectorId ?? this.inspectorId,
      inspectorImageUrl: inspectorImageUrl ?? this.inspectorImageUrl,
      inspectorEmail: inspectorEmail ?? this.inspectorEmail,
      inspectorPhone: inspectorPhone ?? this.inspectorPhone,
      inspectorLocation: inspectorLocation ?? this.inspectorLocation,
      inspectorDepartment: inspectorDepartment ?? this.inspectorDepartment,
      inspectorPosition: inspectorPosition ?? this.inspectorPosition,
      inspectorStatus: inspectorStatus ?? this.inspectorStatus,
      inspectorDate: inspectorDate ?? this.inspectorDate,
      inspectorTime: inspectorTime ?? this.inspectorTime,
    );
  }
}
