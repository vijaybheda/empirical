// ignore_for_file: unnecessary_this, non_constant_identifier_names

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

  void setData(
      int? attachment_id, String? file_location, bool savedInDB, File pic) {
    this.pictureId = attachment_id;
    this.pathToPhoto = file_location;
    this.savedInDB = savedInDB;
  }
}
