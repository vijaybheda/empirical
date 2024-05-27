import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:pverify/models/inspection_attachment.dart';
import 'package:pverify/models/inspection_defect_attachment.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/services/network_request_service/api_urls.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/utils.dart';

class WSUploadMobileFiles {
  String? request;
  List<InspectionDefectAttachment> attachments;
  List<InspectionAttachment> inspectionAttachments;
  Map<String, dynamic> jsonInspection;
  int inspectionId;
  final AppStorage appStorage = AppStorage.instance;

  static const String serverUrl = String.fromEnvironment('API_HOST');

  final ApplicationDao dao = ApplicationDao();

  WSUploadMobileFiles(this.inspectionId, this.attachments, this.jsonInspection,
      this.request, this.inspectionAttachments);

  Future<void> requestUploadMobileFiles(
      List<InspectionDefectAttachment> attachments,
      Map<String, dynamic> jsonInspection,
      int inspectionId) async {
    this.attachments = attachments;
    this.jsonInspection = jsonInspection;
    this.inspectionId = inspectionId;

    String requestString = "";
    if (attachments.isEmpty) {
      requestString = "?localPictureId=0";
    } else {
      requestString = "?localPictureId=0&";
    }
    for (int i = 0; i < attachments.length; i++) {
      requestString += "localPictureId=${attachments[i].attachmentId}";
      if (i < (attachments.length - 1)) requestString += "&";
    }

    request = "$serverUrl${ApiUrls.UPLOAD_MOBILE_FILES_REQUEST}$requestString";

    inspectionAttachments =
        await dao.findInspectionAttachmentsByInspectionId(inspectionId);

    Map<String, dynamic> jsonInspection2 =
        createInspectionAttachmentJSONRequest();

    String response = await _doFileUpload();

    if (response.isEmpty) {
      // TODO: Handle error
      // You can handle the error scenario here
    } else {
      // Parse the response and handle success scenario
      UploadResponseData uploadResponseData = parseUploadJson(response);

      if (uploadResponseData.inspectionServerID != 0) {
        dao.updateInspectionServerId(
            inspectionId, uploadResponseData.inspectionServerID);
      }

      if (uploadResponseData.uploaded) {
        Utils.setInspectionUploadStatus(
            inspectionId, Consts.INSPECTION_UPLOAD_IN_PROGRESS);
        dao.deleteInspectionAfterUpload(inspectionId);
      }
    }
  }

  Future<String> _doFileUpload() async {
    var request = http.MultipartRequest('POST', Uri.parse(this.request!));
    final Map<String, String> headers = appStorage.read(StorageKey.kHeaderMap);
    // Add headers
    request.headers.addAll(headers);

    // Add fields
    request.fields['file'] = json.encode(jsonInspection);

    String externalStoragePath = await Utils().getExternalStoragePath();
    // Create a temporary file and write data to it
    final file = await File('$externalStoragePath/inspection.txt').create();
    await file.writeAsString(json.encode(jsonInspection));

    // Add the file to the multipart request
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      file.path,
      filename: basename(file.path),
    ));

    // Add files
    for (InspectionDefectAttachment attachment in attachments) {
      File file = File(attachment.fileLocation!);
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        filename: basename(file.path),
      ));
    }

    Map<String, dynamic> jsonInspection2 =
        createInspectionAttachmentJSONRequest();
    final inspectionFile2 =
        await File('${Directory.systemTemp.path}/inspection2.txt').create();
    await inspectionFile2.writeAsString(json.encode(jsonInspection2));

    request.files.add(await http.MultipartFile.fromPath(
      'inspectionAttachments',
      inspectionFile2.path,
      filename: basename(inspectionFile2.path),
    ));

    // Add inspectionAttachment files
    for (InspectionAttachment attachment in inspectionAttachments) {
      File file = File(attachment.filelocation!);
      request.files.add(await http.MultipartFile.fromPath(
        'inspectionAttachments',
        file.path,
        filename: basename(file.path),
      ));
    }

    // Send the request
    var response = await request.send();

    if (response.statusCode == 200) {
      return await response.stream.bytesToString();
    } else {
      return '';
    }
  }

  Map<String, dynamic> createInspectionAttachmentJSONRequest() {
    Map<String, dynamic> jsonObj = {};
    List<Map<String, dynamic>> defectsArray = [];

    for (InspectionAttachment attachment in inspectionAttachments) {
      Map<String, dynamic> d_obj = {
        'inspectionId': inspectionId,
        'attachmentId': attachment.id,
        'attachmentTitle': attachment.title,
      };
      defectsArray.add(d_obj);
    }

    jsonObj['attachments'] = defectsArray;

    return jsonObj;
  }

  UploadResponseData parseUploadJson(String response) {
    int inspectionServerID = 0;
    bool uploaded = false;
    String errorMessage = "";
    int localInspectionID = 0;
    String validationError = "";

    try {
      Map<String, dynamic> responseObj = json.decode(response);

      if (responseObj.containsKey('inspectionServerID')) {
        inspectionServerID = responseObj['inspectionServerID'];
      }
      if (responseObj.containsKey('uploadCompleted')) {
        uploaded = responseObj['uploadCompleted'];
      }
      if (responseObj.containsKey('errorMessage')) {
        errorMessage = responseObj['errorMessage'];
      }
      if (responseObj.containsKey('validationErrors')) {
        validationError = responseObj['validationErrors'];
      }
      if (responseObj.containsKey('localInspectionID')) {
        localInspectionID = responseObj['localInspectionID'];
      }
    } catch (e) {
      print('Error parsing JSON: $e');
    }

    return UploadResponseData(
      inspectionServerID,
      errorMessage,
      validationError,
      localInspectionID,
      uploaded,
    );
  }
}

class UploadResponseData {
  final int inspectionServerID;
  final String errorMessage;
  final String validationError;
  final int localInspectionID;
  final bool uploaded;

  UploadResponseData(
    this.inspectionServerID,
    this.errorMessage,
    this.validationError,
    this.localInspectionID,
    this.uploaded,
  );
}
