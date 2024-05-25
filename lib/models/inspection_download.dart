class InspectionDownload {
  int? localInspectionId;
  int? inspectionId;
  QualityControl? qualityControl;
  DownloadDefect? defect;
  DownloadTrailerTemp? trailerTemp;

  InspectionDownload({
    this.localInspectionId,
    this.inspectionId,
    this.qualityControl,
    this.defect,
    this.trailerTemp,
  });
}

class DownloadDefect {
  int? localInspectionId;
  int? serverInspectionId;
  List<InspectionSampleDownload>? inspectionSampleDownloadList;

  DownloadDefect({
    this.localInspectionId,
    this.serverInspectionId,
    this.inspectionSampleDownloadList,
  });
}

class InspectionSampleDownload {
  int? inspectionSampleId;
  int? setNumber;
  int? setSize;
  int? createdTime;
  int? lastUpdatedTime;
  List<DownloadInspectionDefect>? inspectionDefects;
  int? lotNumber;
  String? packDate;

  InspectionSampleDownload({
    this.inspectionSampleId,
    this.setNumber,
    this.setSize,
    this.createdTime,
    this.lastUpdatedTime,
    this.inspectionDefects,
    this.lotNumber,
    this.packDate,
  });
}

class DownloadInspectionDefect {
  int? inspectionDefectId;
  int? inspectionSampleId;
  int? defectId;
  String? comments;
  List<DownloadInspectionDefectDetail>? inspectionDefectDetails;
  List<DownloadInspectionDefectAttachment>? inspectionDefectAttachments;

  DownloadInspectionDefect({
    this.inspectionDefectId,
    this.inspectionSampleId,
    this.defectId,
    this.comments,
    this.inspectionDefectDetails,
    this.inspectionDefectAttachments,
  });
}

class DownloadInspectionDefectDetail {
  int? inspectionDefectId;
  int? severityDefectId;
  int? numberOfDefects;

  DownloadInspectionDefectDetail({
    this.inspectionDefectId,
    this.severityDefectId,
    this.numberOfDefects,
  });
}

class DownloadInspectionDefectAttachment {
  int? attachmentId;
  String? attachmentURL;

  DownloadInspectionDefectAttachment({
    this.attachmentId,
    this.attachmentURL,
  });
}

class DownloadTrailerTemp {
  int? localInspectionId;
  int? serverInspectionId;
  List<TrailerTemperatureItem>? trailerTemperatureItemList;

  DownloadTrailerTemp({
    this.localInspectionId,
    this.serverInspectionId,
    this.trailerTemperatureItemList,
  });
}

class QualityControl {}

class TrailerTemperatureItem {}
