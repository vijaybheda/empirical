class FileUploadData {
  String? location;
  String? type;
  String? path;
  String? key;

  FileUploadData({this.location, this.type, this.path, this.key});

  FileUploadData.fromJson(Map<String, dynamic> json) {
    location = json['Location'];
    type = json['type'];
    path = json['path'];
    key = json['Key'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Location'] = location;
    data['type'] = type;
    data['path'] = path;
    data['Key'] = key;
    return data;
  }

  FileUploadData copyWith({
    String? location,
    String? type,
    String? path,
    String? key,
  }) {
    return FileUploadData(
      location: location ?? this.location,
      type: type ?? this.type,
      path: path ?? this.path,
      key: key ?? this.key,
    );
  }
}
