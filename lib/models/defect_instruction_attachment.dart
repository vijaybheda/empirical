class DefectInstructionAttachment {
  int? attachmentId;
  String? url;
  String? name;

  DefectInstructionAttachment({this.attachmentId, this.url, this.name});

  // toJson
  Map<String, dynamic> toJson() => {
        'attachmentId': attachmentId,
        'url': url,
        'name': name,
      };

  // fromJson
  factory DefectInstructionAttachment.fromJson(Map<String, dynamic> json) {
    return DefectInstructionAttachment(
      attachmentId: json['attachmentId'],
      url: json['url'],
      name: json['name'],
    );
  }

  // copyWith
  DefectInstructionAttachment copyWith({
    int? attachmentId,
    String? url,
    String? name,
  }) {
    return DefectInstructionAttachment(
      attachmentId: attachmentId ?? this.attachmentId,
      url: url ?? this.url,
      name: name ?? this.name,
    );
  }
}
