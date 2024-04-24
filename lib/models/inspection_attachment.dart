import 'dart:io';

class InspectionAttachment {
  int? id; // SQLite row id
  int Inspection_ID;
  int? Attachment_ID;
  String? ATTACHMENT_TITLE;
  int? CREATED_TIME;
  String? FILE_LOCATION;

  InspectionAttachment({
    this.id,
    required this.Inspection_ID,
    required this.Attachment_ID,
    required this.ATTACHMENT_TITLE,
    required this.CREATED_TIME,
    required this.FILE_LOCATION,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'Inspection_ID': Inspection_ID,
      'Attachment_ID': Attachment_ID,
      'ATTACHMENT_TITLE': ATTACHMENT_TITLE,
      'CREATED_TIME': CREATED_TIME,
      'FILE_LOCATION': FILE_LOCATION,
    };
  }

  factory InspectionAttachment.fromMap(Map<String, dynamic> map) {
    return InspectionAttachment(
      id: map['id'],
      Inspection_ID: map['Inspection_ID'],
      Attachment_ID: map['Attachment_ID'],
      ATTACHMENT_TITLE: map['ATTACHMENT_TITLE'],
      CREATED_TIME: map['CREATED_TIME'],
      FILE_LOCATION: map['FILE_LOCATION'],
    );
  }

  // copyWith
  InspectionAttachment copyWith({
    int? id,
    int? Inspection_ID,
    int? Attachment_ID,
    String? ATTACHMENT_TITLE,
    int? CREATED_TIME,
    String? FILE_LOCATION,
  }) {
    return InspectionAttachment(
      id: id ?? this.id,
      Inspection_ID: Inspection_ID ?? this.Inspection_ID,
      Attachment_ID: Attachment_ID ?? this.Attachment_ID,
      ATTACHMENT_TITLE: ATTACHMENT_TITLE ?? this.ATTACHMENT_TITLE,
      CREATED_TIME: CREATED_TIME ?? this.CREATED_TIME,
      FILE_LOCATION: FILE_LOCATION ?? this.FILE_LOCATION,
    );
  }
}

class PictureData {
  int? pictureId;
  String? photoTitle;
  String? pathToPhoto;
  File? image;
  int? createdTime;
  bool? savedInDB = false;

  PictureData({
    this.pictureId,
    this.photoTitle,
    this.pathToPhoto,
    this.image,
    this.createdTime,
    this.savedInDB,
  });
}

/*
        private Long pictureId;
        private String photoTitle;
        private String pathToPhoto;
        private Bitmap photoBitmap;
        private boolean savedInDB;
        private int createdTime;

*/
