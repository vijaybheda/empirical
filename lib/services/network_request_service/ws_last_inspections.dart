import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:pverify/models/last_inspections_item.dart';
import 'package:pverify/services/network_request_service/api_urls.dart';
import 'package:pverify/utils/app_storage.dart';

class WSLastInspections {
  final BuildContext context;
  final int milliseconds = 90000;
  String? parsedString;
  String? request;
  int? partnerId;
  final AppStorage appStorage = AppStorage.instance;
  WSLastInspections(this.context);

  static const String serverUrl = String.fromEnvironment('API_HOST');
  Future<void> requestLastInspections(int partnerId) async {
    parsedString = "";

    String language = Get.locale?.languageCode ?? 'en';

    request = '${ApiUrls.LAST_INSPECTIONS_REQUEST}?lang=$language';

    this.partnerId = partnerId;

    var object = {'partnerID': partnerId, 'numberOfInspections': 10};

    try {
      String? response = await doPostConnection(
        request: request!,
        milliseconds: milliseconds,
        object: object,
      );
      if (response!.isNotEmpty) {
        List<LastInspectionsItem> inspections = parseJson(response);
        appStorage.lastInspectionsList = inspections;
      }
    } catch (e) {
      debugPrint(" 🔴 Do Post Connection $e");
    }
  }

  Future<String?> doPostConnection({
    required String request,
    required int milliseconds,
    required Map<String, dynamic> object,
  }) async {
    final String url = '$serverUrl$request';
    final client = http.Client();

    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final Map<String, String> savedHeader =
        appStorage.read(StorageKey.kHeaderMap);
    headers.addAll(savedHeader);

    try {
      final jsonString = jsonEncode(object);

      final response = await client
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonString,
          )
          .timeout(Duration(milliseconds: milliseconds));

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        log(' 🟢 JSON Data: $data');
        return response.body;
      } else if (response.statusCode == 401) {
        debugPrint('🔴 Error: Unauthorized request.');
        return null;
      } else if (response.statusCode == 404) {
        debugPrint('🔴 Error: Not found.');
        return null;
      } else {
        debugPrint('🔴 Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('🔴 Catch Error: $e');
    } finally {
      client.close();
    }
    return null;
  }

  List<LastInspectionsItem> parseJson(String response) {
    List<LastInspectionsItem> list = [];

    try {
      List<dynamic> reasonArray = json.decode(response);

      for (var item in reasonArray) {
        list.add(
          LastInspectionsItem.fromJson(item),
        );
      }
    } catch (e) {
      debugPrint(" 🔴 Error parsing JSON Last Inspections Item: $e");
    }
    return list;
  }
}
