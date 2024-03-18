class MyInspection48HourItem {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String date;
  final String time;
  final String location;
  final String status;

  MyInspection48HourItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.date,
    required this.time,
    required this.location,
    required this.status,
  });

  factory MyInspection48HourItem.fromJson(Map<String, dynamic> json) {
    return MyInspection48HourItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      date: json['date'],
      time: json['time'],
      location: json['location'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'date': date,
      'time': time,
      'location': location,
      'status': status,
    };
  }

  // fromMap
  factory MyInspection48HourItem.fromMap(Map<String, dynamic> map) {
    return MyInspection48HourItem(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      date: map['date'],
      time: map['time'],
      location: map['location'],
      status: map['status'],
    );
  }
}
