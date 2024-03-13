import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pverify/models/file_upload_model.dart';
import 'package:pverify/utils/app_snackbar.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/extensions/directory_extensions.dart';

typedef OnUploadProgressCallback = void Function(int sentBytes, int totalBytes);
typedef OnDownloadProgressCallback = void Function(
    int receivedBytes, int totalBytes);

class FileService {
  static bool trustSelfSigned = true;
  static final AppStorage _appStorage = AppStorage.instance;

  static HttpClient getHttpClient() {
    HttpClient httpClient = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10)
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => trustSelfSigned);

    return httpClient;
  }

  static Future<FileUploadData?> uploadFile(FilePickerResult? fileResult,
      {OnUploadProgressCallback? onUploadProgress}) async {
    final String authToken = _appStorage.read(StorageKey.jwtToken) ?? "";
    try {
      MultipartRequest request = MultipartRequest(
        'POST',
        Uri.parse("${const String.fromEnvironment('API_HOST')}/api/v1/upload"),
        onProgress: (int bytes, int total) {
          if (onUploadProgress != null) {
            onUploadProgress(bytes, total);
            // log('CALL STATUS CALLBACK');
          }
        },
      );
      Map<String, String> headers = {
        "Authorization": "Bearer $authToken",
        "Content-type": "multipart/form-data"
      };
      request.files.add(
        await http.MultipartFile.fromPath(
            'file', fileResult?.files.first.path ?? 'name'),
      );
      request.headers.addAll(headers);
      http.StreamedResponse res = await request.send();
      http.Response response = await http.Response.fromStream(res);
      if (response.statusCode ~/ 100 != 2) {
        AppSnackBar.getCustomSnackBar("Error", "Error uploading file",
            isSuccess: false);
        throw Exception(
            'Error uploading file, Status code: ${response.statusCode}');
      } else {
        Map<String, dynamic> data = jsonDecode(response.body);
        FileUploadData fileUploadModel = FileUploadData.fromJson(data['data']);
        FileUploadData model = fileUploadModel.copyWith(
            type: fileResult?.files.first.extension,
            path: fileResult?.files.first.path);
        return model;
      }
    } catch (e, stackTrace) {
      log(e.toString(), error: e, name: "[uploadFile]");
      AppSnackBar.getCustomSnackBar("Error", "Something went wrong",
          isSuccess: false);
    }
    return null;
  }

  static Future<Response> uploadFileWithProgress(FilePickerResult? fileResult,
      {OnUploadProgressCallback? onUploadProgress}) async {
    final String authToken = _appStorage.read(StorageKey.jwtToken) ?? "";
    Map<String, String> headers = {
      "Authorization": "Bearer $authToken",
      "Content-type": "multipart/form-data"
    };
    final dio = Dio();
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        fileResult?.files.first.path ?? 'name',
        filename: '${fileResult?.files.first.name}',
      ),
    });
    Response response = await dio.post(
      "${const String.fromEnvironment('API_HOST')}/api/v1/upload",
      data: formData,
      options: Options(headers: headers),
      onSendProgress: (int bytes, int total) {
        if (onUploadProgress != null) {
          onUploadProgress(bytes, total);
        }
      },
    ).catchError((onError, stackTrace) {
      AppSnackBar.getCustomSnackBar("Error", "Error uploading file",
          isSuccess: false);
      throw Exception(
          'Error uploading file, Status code: ${onError.toString()}');
    });
    return response;
  }

  static Future<void> fileDownload(String fileUrl,
      {OnUploadProgressCallback? onDownloadProgress}) async {
    final url = Uri.decodeFull(fileUrl);
    final Dio dio = Dio();
    String filename = url.substring((url.lastIndexOf('/')) + 1);
    String directory = "";
    directory = await getDownloadDirectory();
    String path = await File(directory).uniqueName(
      filename.substring(filename.indexOf('_') + 1).toString(),
    );
    //while creating college folder with ":" symbol making issue in android
    if (path.contains(":")) {
      path = path.replaceAll(":", "");
    }

    File file = await File(path).create(recursive: true);
    try {
      await dio
          .download(fileUrl, file.path, onReceiveProgress: onDownloadProgress)
          .then((value) {
        // NotificationService.instance.showNotification(RemoteMessage(
        //     notification: RemoteNotification(
        //         title: filename.substring(filename.indexOf('_') + 1).toString(),
        //         body: 'Download complete'),
        //     data: {'type': 'open_file', 'path': file.path}));
      });
    } catch (e, stackTrace) {
      log(e.toString(), error: e, name: "[fileDownload]");

      AppSnackBar.getCustomSnackBar("Error", "Something went wrong",
          isSuccess: false);
    } finally {}
  }

  static Future<bool> requestFilePermission() async {
    bool checkPermission = false;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      String version = androidInfo.version.release.toString().contains('.0')
          ? androidInfo.version.release.split('.').first.toString()
          : androidInfo.version.release;

      if (int.parse(version) >= 13) {
        checkPermission = true;
      } else {
        try {
          checkPermission = await Permission.storage.request().then((value) {
            return value.isGranted;
          });
        } catch (e, stackTrace) {
          log(e.toString(), error: e, name: "[requestFilePermission]");
        }
      }
    } else {
      //for ios
      checkPermission = true;
    }

    return checkPermission;
  }

  static Future<Response> uploadOrDeleteProfileImageWithProgress(
      String filePath,
      {OnUploadProgressCallback? onUploadProgress}) async {
    final String authToken = _appStorage.read(StorageKey.jwtToken) ?? "";
    Map<String, String> headers = {
      "Authorization": "Bearer $authToken",
      // "Content-type": "multipart/form-data"
    };
    final dio = Dio();
    FormData? formData;
    //if file path is null then the file is going to be deleted from server
    try {
      formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split("/").last,
        ),
      });
    } catch (e) {
      //delete the image from server

      formData = null;
    }
    Response response = await dio.put(
      "${const String.fromEnvironment('API_HOST')}/api/v1/students/profile/update-profile-photo",
      data: formData,
      options: Options(headers: headers),
      onSendProgress: (int bytes, int total) {
        if (onUploadProgress != null) {
          onUploadProgress(bytes, total);
        }
      },
    ).catchError((onError, stackTrace) {
      AppSnackBar.getCustomSnackBar("Error", "Error uploading file",
          isSuccess: false);
      throw Exception(
          'Error uploading file, Status code: ${onError.toString()}');
    });
    return response;
  }

  static Future<String> getDownloadDirectory() async {
    bool dirDownloadExists = true;
    String directory = "";
    if (Platform.isIOS) {
      directory = (await getApplicationDocumentsDirectory()).path;
      directory = directory + Platform.pathSeparator;
    } else {
      directory = "/storage/emulated/0/Download/";
      dirDownloadExists = await Directory(directory).exists();
      if (!dirDownloadExists) {
        directory = "/storage/emulated/0/Downloads/";
      }
      final Directory appDocDirFolder =
          Directory('$directory${const String.fromEnvironment('APP_NAME')}/');
      if (await appDocDirFolder.exists()) {
      } else {
        await appDocDirFolder.create(recursive: true);
      }
      directory = appDocDirFolder.path;
    }
    return directory;
  }

  static Future<void> certificateDownload(String fileUrl, bool isCaseStudy,
      {OnUploadProgressCallback? onDownloadProgress}) async {
    final Dio dio = Dio();
    String filename =
        isCaseStudy ? "case_study.pdf" : "participation_certificate.pdf";

    String directory = "";
    directory = await getDownloadDirectory();
    String path = await File(directory).uniqueName(
      filename,
    );
    //while creating college folder with ":" symbol making issue in android
    if (path.contains(":")) {
      path = path.replaceAll(":", "");
    }

    File file = await File(path).create(recursive: true);
    try {
      final String authToken = _appStorage.read(StorageKey.jwtToken) ?? "";
      final Map<String, String> headers = {
        'Authorization': "Bearer $authToken"
      };
      final response = await dio.get(
        fileUrl,
        options: Options(
          responseType: ResponseType.bytes,
          headers: headers,
        ),
        data: headers,
      );

      final imageBytes = response.data as List<int>;
      await file.writeAsBytes(imageBytes);

      // NotificationService.instance.showNotification(RemoteMessage(
      //     notification:
      //         RemoteNotification(title: filename, body: 'Download complete'),
      //     data: {'type': 'open_file', 'path': file.path}));
    } catch (e, stackTrace) {
      log(e.toString(), error: e, name: "[fileDownload]");
      AppSnackBar.getCustomSnackBar("Error", "Something went wrong",
          isSuccess: false);
    }
  }
}

class MultipartRequest extends http.MultipartRequest {
  MultipartRequest(
    super.method,
    super.url, {
    required this.onProgress,
  });

  final void Function(int bytes, int totalBytes) onProgress;
  @override
  http.ByteStream finalize() {
    final byteStream = super.finalize();
    final total = contentLength;
    int bytes = 0;

    final t = StreamTransformer.fromHandlers(
      handleData: (List<int> data, EventSink<List<int>> sink) {
        bytes += data.length;
        onProgress.call(bytes, total);
        sink.add(data);
      },
    );
    final stream = byteStream.transform(t);
    return http.ByteStream(stream);
  }
}
