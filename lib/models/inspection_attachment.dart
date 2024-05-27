// ignore_for_file: unnecessary_this, non_constant_identifier_names

import 'dart:io';

class InspectionAttachment {
  int? id; // SQLite row id
  int Inspection_ID;
  int? Attachment_ID;
  String? Attachment_Title;
  int? CREATED_TIME;
  String? filelocation;
  String? title;

  InspectionAttachment({
    this.id,
    required this.Inspection_ID,
    required this.Attachment_ID,
    required this.Attachment_Title,
    required this.CREATED_TIME,
    required this.filelocation,
    required this.title,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'Inspection_ID': Inspection_ID,
      'Attachment_ID': Attachment_ID,
      'Attachment_Title': Attachment_Title,
      'Created_Time': CREATED_TIME,
      'fileLocation': filelocation,
      'title': title,
    };
  }

  factory InspectionAttachment.fromMap(Map<String, dynamic> map) {
    return InspectionAttachment(
      id: map['id'],
      Inspection_ID: map['Inspection_ID'],
      Attachment_ID: map['Attachment_ID'],
      Attachment_Title: map['Attachment_Title'],
      CREATED_TIME: map['Created_Time'],
      filelocation: map['fileLocation'],
      title: map['title'],
    );
  }

  // copyWith
  InspectionAttachment copyWith({
    int? id,
    int? Inspection_ID,
    int? Attachment_ID,
    String? ATTACHMENT_TITLE,
    int? CREATED_TIME,
    String? filelocation,
    String? title,
  }) {
    return InspectionAttachment(
      id: id ?? this.id,
      Inspection_ID: Inspection_ID ?? this.Inspection_ID,
      Attachment_ID: Attachment_ID ?? this.Attachment_ID,
      Attachment_Title: ATTACHMENT_TITLE ?? this.Attachment_Title,
      CREATED_TIME: CREATED_TIME ?? this.CREATED_TIME,
      filelocation: filelocation ?? this.filelocation,
      title: title ?? this.title,
    );
  }
}

class PictureData {
  int? pictureId;
  String? Attachment_Title;
  String? pathToPhoto;
  File? image;
  int? createdTime;
  bool? savedInDB = false;

  PictureData({
    this.pictureId,
    this.Attachment_Title,
    this.pathToPhoto,
    this.image,
    this.createdTime,
    this.savedInDB,
  });

  void setData(
      int? attachment_id, String? filelocation, bool savedInDB, File pic) {
    this.pictureId = attachment_id;
    this.pathToPhoto = filelocation;
    this.savedInDB = savedInDB;
    this.image = pic;
  }
}
