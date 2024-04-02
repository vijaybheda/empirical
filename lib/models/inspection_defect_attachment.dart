import 'package:pverify/services/database/column_names.dart';

class InspectionDefectAttachment {
  int? attachmentId;
  int? inspectionId;
  int? sampleId;
  int? defectId;
  int? createdTime;
  String? fileLocation;
  bool? defectSaved;

  InspectionDefectAttachment({
    this.attachmentId,
    this.inspectionId,
    this.sampleId,
    this.defectId,
    this.createdTime,
    this.fileLocation,
    this.defectSaved,
  });

  InspectionDefectAttachment.fromJson(Map<String, dynamic> json) {
    attachmentId = json[InspectionDefectAttachmentColumn.ATTACHMENT_ID];
    inspectionId = json[InspectionDefectAttachmentColumn.INSPECTION_ID];
    sampleId = json[InspectionDefectAttachmentColumn.INSPECTION_SAMPLE_ID];
    defectId = json[InspectionDefectAttachmentColumn.INSPECTION_DEFECT_ID];
    createdTime = json[InspectionDefectAttachmentColumn.CREATED_TIME];
    fileLocation = json[InspectionDefectAttachmentColumn.FILE_LOCATION];
    defectSaved = json[InspectionDefectAttachmentColumn.DEFECT_SAVED];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data[InspectionDefectAttachmentColumn.ATTACHMENT_ID] = attachmentId;
    data[InspectionDefectAttachmentColumn.INSPECTION_ID] = inspectionId;
    data[InspectionDefectAttachmentColumn.INSPECTION_SAMPLE_ID] = sampleId;
    data[InspectionDefectAttachmentColumn.INSPECTION_DEFECT_ID] = defectId;
    data[InspectionDefectAttachmentColumn.CREATED_TIME] = createdTime;
    data[InspectionDefectAttachmentColumn.FILE_LOCATION] = fileLocation;
    data[InspectionDefectAttachmentColumn.DEFECT_SAVED] = defectSaved;
    return data;
  }
}
