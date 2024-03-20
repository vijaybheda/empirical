import 'dart:convert';
import 'dart:developer';
import 'dart:io' show Directory, File, HttpStatus;

import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/services/network_request_service/network_request_base_class.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/utils.dart' show Utils;

class CacheDownloadService extends BaseRequestService {
  static CacheDownloadService get instance => _instance;
  static final CacheDownloadService _instance =
      CacheDownloadService._internal();
  CacheDownloadService._internal();

  /// download Zip File
  Future<File?> downloadZip(
      String requestUrl, Map<String, dynamic> headerMap) async {
    try {
      var storagePath = await Utils().getExternalStoragePath();
      final Directory directory =
          Directory("$storagePath${AppStrings.csvFilesCache}/");
      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
      directory.createSync(recursive: true);

      File? savedZipFile = await downloadFile(requestUrl, directory.path,
          headers: headerMap, fileName: 'file.zip');
      if (savedZipFile == null) {
        return null;
      }

      List<int> bytes = await savedZipFile.readAsBytes();

      final zipInputStream = ZipDecoder().decodeBytes(bytes);

      for (ArchiveFile zipEntry in zipInputStream) {
        log('Extracting: ${zipEntry.name}');
        final innerFileName = '${directory.path}/${zipEntry.name}';
        final innerFile = File(innerFileName);

        if (!zipEntry.isFile) {
          await innerFile.create(recursive: true);
        } else {
          await innerFile.create(recursive: true);
          await innerFile.writeAsBytes(zipEntry.content);
        }
      }

      // final response = await getCall(requestUrl, headers: headerMap);

      /*if (response.statusCode == HttpStatus.ok) {
        var storagePath = await Utils().getExternalStoragePath();
        final Directory directory =
            Directory("$storagePath/${AppStrings.csvFilesCache}/");
        if (directory.existsSync()) {
          directory.deleteSync(recursive: true);
        }
        directory.createSync(recursive: true);

        final List<int> bytes = [];
        await response.bodyBytes?.forEach((chunk) {
          bytes.addAll(chunk);
        });

        final zipInputStream = ZipDecoder().decodeBytes(bytes);

        for (ArchiveFile zipEntry in zipInputStream) {
          log('Extracting: ${zipEntry.name}');
          final innerFileName = '${directory.path}/${zipEntry.name}';
          final innerFile = File(innerFileName);

          if (!zipEntry.isFile) {
            await innerFile.create(recursive: true);
          } else {
            await innerFile.create(recursive: true);
            await innerFile.writeAsBytes(zipEntry.content);
          }
        }

        return File(directory.path);
      } else if (response.statusCode == HttpStatus.unauthorized) {
        log('Error in downloadZip: 401 Unauthorized');
      } else if (response.statusCode == HttpStatus.notFound) {
        log('Error in downloadZip: 404 Not Found');
      } else {
        log('Error in downloadZip: ${response.statusCode}');
      }*/
      return savedZipFile;
    } catch (e) {
      log('Error in downloadZip');
      log(e.toString());
      return null;
    }
  }

  /// download JSON File
  Future<File?> downloadJSON(
      String requestUrl, Map<String, dynamic> headerMap) async {
    try {
      var storagePath = await Utils().getExternalStoragePath();
      final Directory directory =
          Directory("$storagePath${AppStrings.jsonFilesCache}/");
      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
      directory.createSync(recursive: true);

      File? savedJsonFile = await downloadFile(requestUrl, directory.path,
          headers: headerMap, fileName: 'jsonfile.zip');
      if (savedJsonFile == null) {
        return null;
      }

      List<int> bytes = await savedJsonFile.readAsBytes();

      final zipInputStream = ZipDecoder().decodeBytes(bytes);

      for (ArchiveFile zipEntry in zipInputStream) {
        log('Extracting: ${zipEntry.name}');
        final innerFileName = '${directory.path}${zipEntry.name}';
        final innerFile = File(innerFileName);

        if (!zipEntry.isFile) {
          await innerFile.create(recursive: true);
        } else {
          await innerFile.create(recursive: true);
          await innerFile.writeAsBytes(zipEntry.content);
        }
      }

      /*final response = await getCall(requestUrl, headers: headerMap);

      if (response.statusCode == HttpStatus.ok) {
        var storagePath = await Utils().getExternalStoragePath();
        final Directory directory =
            Directory("$storagePath${AppStrings.jsonFilesCache}/");
        if (directory.existsSync()) {
          directory.deleteSync(recursive: true);
        }
        directory.createSync(recursive: true);

        final List<int> bytes = [];
        await response.bodyBytes?.forEach((chunk) {
          bytes.addAll(chunk);
        });

        Uint8List data = Uint8List.fromList(bytes);

        List<int> outputBytes = [];
        ZipDecoder decoder = ZipDecoder();
        Archive archive = decoder.decodeBytes(data);
        for (ArchiveFile file in archive) {
          String innerFileName =
              '${directory.path}${AppStrings.jsonFilesCache}/${file.name}';
          File innerFile = File(innerFileName);
          if (innerFile.existsSync()) {
            await innerFile.delete();
          }
          if (file.isFile) {
            await innerFile.create(recursive: true);
            outputBytes = [];
            for (int i = 0; i < file.content.length; i++) {
              outputBytes.addAll(file.content[i]);
            }
            await innerFile.writeAsBytes(outputBytes);
          } else {
            await innerFile.create(recursive: true);
          }
        }

        return true;
      } else if (response.statusCode == HttpStatus.unauthorized) {
        log('Error in downloadZip: 401 Unauthorized');
      } else if (response.statusCode == HttpStatus.notFound) {
        log('Error in downloadZip: 404 Not Found');
      } else {
        log('Error in downloadZip: ${response.statusCode}');
      }*/
      return savedJsonFile;
    } catch (e) {
      log('Error in downloadZip');
      log(e.toString());
      return null;
    }
  }

  Future<bool> downloadAllUsers(
      String requestUrl, Map<String, dynamic> headerMap) async {
    try {
      final response = await getCall(requestUrl, headers: headerMap);

      if (response.statusCode == HttpStatus.ok) {
        try {
          List<Map<String, dynamic>> usersArray =
              jsonDecode(response.bodyString!);
          for (Map<String, dynamic> item in usersArray) {
            String userId = item["userName"];
            String access = item["access1"];
            String status = item["status"];
            int enterpriseId = 0;
            if (item["enterpriseId"] != null) {
              enterpriseId = item["enterpriseId"];
            }
            int supplierId = 0;
            if (item["supplierId"] != null) {
              supplierId = item["supplierId"];
            }
            int headquarterSupplierId = 0;
            if (item["headquarterSupplierId"] != null) {
              headquarterSupplierId = item["headquarterSupplierId"];
            }

            String subscriptionExpirationDateString =
                item["subscriptionExpirationDateString"];
            int subscriptionExpirationDate = item["subscriptionExpirationDate"];
            bool isExpired = false;
            DateTime strDate = DateTime.parse(subscriptionExpirationDateString);
            if (DateTime.now().millisecondsSinceEpoch >
                subscriptionExpirationDate) {
              isExpired = true;
            }

            bool gtinScanning = false;
            if (item["gtinScanning"] != null) {
              gtinScanning = item["gtinScanning"];
            }

            await ApplicationDao().createOrUpdateOfflineUser(
                userId.toLowerCase(),
                access,
                enterpriseId,
                status,
                isExpired,
                supplierId,
                headquarterSupplierId,
                gtinScanning);
            return true;
          }
        } catch (e) {
          log(e.toString());
          return false;
        }
      }
      return false;
    } catch (e) {
      log('Error in downloadAllUsers');
      log(e.toString());
      return false;
    }
  }

  Future<File?> downloadFile(
    String url,
    String savePath, {
    required String? fileName,
    Map<String, dynamic>? headers,
  }) async {
    Dio dio = Dio();

    try {
      Response? response = await dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 60),
          headers: headers,
        ),
        queryParameters: headers,
      );

      // Write the file
      File file = File(join(savePath, fileName));
      await file.writeAsBytes(response.data);
      print('File downloaded to: $savePath');

      return file;
    } catch (e) {
      print('Error downloading file: $e');
      return null;
    }
  }
}
