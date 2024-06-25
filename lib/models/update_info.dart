class UpdateInfo {
  String downloadURL;

  String version;

  UpdateInfo({required this.downloadURL, required this.version});

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      downloadURL: json['downloadUrl'],
      version: json['version'],
    );
  }
}
