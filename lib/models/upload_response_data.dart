class UploadResponseData {
  int? inspectionServerID;
  int? localInspectionID;
  bool? uploaded;
  String? errorMessage;
  String? validationErrors;

  UploadResponseData({
    this.inspectionServerID,
    this.errorMessage,
    this.validationErrors,
    this.localInspectionID,
    this.uploaded,
  });

  UploadResponseData.empty();

  int? get getInspectionServerID => inspectionServerID;
  set setInspectionServerID(int? value) => inspectionServerID = value;

  int? get getLocalInspectionID => localInspectionID;
  set setLocalInspectionID(int? value) => localInspectionID = value;

  bool? get isUploaded => uploaded;
  set setUploaded(bool? value) => uploaded = value;

  String? get getErrorMessage => errorMessage;
  set setErrorMessage(String? value) => errorMessage = value;

  String? get getValidationErrors => validationErrors;
  set setValidationErrors(String? value) => validationErrors = value;
}
