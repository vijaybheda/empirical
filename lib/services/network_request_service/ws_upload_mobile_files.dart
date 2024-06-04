import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:pverify/models/inspection_attachment.dart';
import 'package:pverify/models/inspection_defect_attachment.dart';
import 'package:pverify/models/upload_response_data.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/services/network_request_service/api_urls.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/utils.dart';

class WSUploadMobileFiles {
  String? request;
  List<InspectionDefectAttachment> attachments;
  List<InspectionAttachment>? inspectionAttachments;
  Map<String, dynamic> jsonInspection;
  int inspectionId;
  int? serverInspectionId;
  final AppStorage appStorage = AppStorage.instance;
  Map<String, dynamic>? jsonInspection2;

  static const String serverUrl = String.fromEnvironment('API_HOST');

  final ApplicationDao dao = ApplicationDao();

  WSUploadMobileFiles(
    this.inspectionId,
    this.attachments,
    this.jsonInspection,
  );

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
      if (i < (attachments.length - 1)) {
        requestString += "&";
      }
    }

    request = "$serverUrl${ApiUrls.UPLOAD_MOBILE_FILES_REQUEST}$requestString";

    inspectionAttachments =
        await dao.findInspectionAttachmentsByInspectionId(inspectionId);

    jsonInspection2 = createInspectionAttachmentJSONRequest();

    String? response = await _doFileUpload();
    debugPrint("HERE IS RESPONSE ${response.toString()}");
    if (response != null && response.isEmpty) {
      debugPrint('🔴 Error: Response is empty.$response');
      return;
    } else {
      // Parse the response and handle success scenario
      UploadResponseData uploadResponseData = parseUploadJson(response!);
      appStorage.uploadResponseData = uploadResponseData;

      if (appStorage.uploadResponseData!.inspectionServerID != 0) {
        await dao.updateInspectionServerId(
            inspectionId, appStorage.uploadResponseData!.inspectionServerID!);
      }

      if (appStorage.uploadResponseData!.uploaded!) {
        Utils.setInspectionUploadStatus(
            inspectionId, Consts.INSPECTION_UPLOAD_IN_PROGRESS);
        await dao.deleteInspectionAfterUpload(inspectionId);
      }
    }
  }

  Future<String?> _doFileUpload() async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(this.request!));
      final Map<String, String> headers =
          appStorage.read(StorageKey.kHeaderMap);
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
        if (await file.exists()) {
          XFile? compressedImage = await Utils.compressImage(file);
          if (compressedImage != null) {
            request.files.add(await http.MultipartFile.fromPath(
              'file',
              compressedImage.path,
              filename: basename(compressedImage.path),
            ));
          }
        }
      }

      /* Map<String, dynamic> jsonInspection2 =
        createInspectionAttachmentJSONRequest(); */
      final inspectionFile2 =
          await File('${Directory.systemTemp.path}/inspection2.txt').create();
      await inspectionFile2.writeAsString(json.encode(jsonInspection2));

      request.files.add(await http.MultipartFile.fromPath(
        'inspectionAttachments',
        inspectionFile2.path,
        filename: basename(inspectionFile2.path),
      ));

      // Add inspectionAttachment files
      for (InspectionAttachment attachment in inspectionAttachments ?? []) {
        File file = File(attachment.filelocation!);
        if (await file.exists()) {
          XFile? compressedImage = await Utils.compressImage(file);
          if (compressedImage != null) {
            request.files.add(await http.MultipartFile.fromPath(
              'inspectionAttachments',
              compressedImage.path,
              filename: basename(compressedImage.path),
            ));
          }
        }
      }

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        debugPrint('🟢 API CALLED SUCCESSFULLY....');
        String res = await response.stream.bytesToString();
        return res;
      } else if (response.statusCode == HttpStatus.unauthorized) {
        debugPrint('🔴 Error: Unauthorized request.');
        return null;
      } else if (response.statusCode == HttpStatus.notFound) {
        debugPrint('🔴 Error: Not found.');
        return null;
      } else {
        debugPrint('🔴 Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('🔴 Exception: $e');
      return null;
    }
  }

  Map<String, dynamic> createInspectionAttachmentJSONRequest() {
    Map<String, dynamic> jsonObj = {};
    List<Map<String, dynamic>> defectsArray = [];

    for (InspectionAttachment attachment in inspectionAttachments ?? []) {
      Map<String, dynamic> d_obj = {
        'inspectionId': serverInspectionId,
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

      if (responseObj.containsKey('inspectionServerID') &&
          responseObj['inspectionServerID'] != null) {
        inspectionServerID = responseObj['inspectionServerID'];
      }
      if (responseObj.containsKey('uploadCompleted') &&
          responseObj['uploadCompleted'] != null) {
        uploaded = responseObj['uploadCompleted'];
      }
      if (responseObj.containsKey('errorMessage') &&
          responseObj['errorMessage'] != null) {
        errorMessage = responseObj['errorMessage'];
      }
      if (responseObj.containsKey('validationErrors') &&
          responseObj['validationErrors'] != null) {
        validationError = responseObj['validationErrors'];
      }
      if (responseObj.containsKey('localInspectionID') &&
          responseObj['localInspectionID'] != null) {
        localInspectionID = responseObj['localInspectionID'];
      }
    } catch (e) {
      debugPrint('Error parsing JSON: $e');
    }

    return UploadResponseData(
      inspectionServerID: inspectionServerID,
      errorMessage: errorMessage,
      validationErrors: validationError,
      localInspectionID: localInspectionID,
      uploaded: uploaded,
    );
  }
}

// class UploadResponseData {
//   final int inspectionServerID;
//   final String errorMessage;
//   final String validationError;
//   final int localInspectionID;
//   final bool uploaded;
//
//   UploadResponseData(
//     this.inspectionServerID,
//     this.errorMessage,
//     this.validationError,
//     this.localInspectionID,
//     this.uploaded,
//   );
// }
