// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pverify/services/network_request_service/file_service.dart';
import 'package:pverify/utils/enumeration.dart';
import 'package:pverify/utils/theme/magic_number.dart';

class ResponsiveHelper {
  static double getDeviceWidth(BuildContext context) {
    return MediaQuery.of(context).size.width *
        MediaQuery.of(context).devicePixelRatio;
  }

  static double getDeviceHeight(BuildContext context) {
    // Add Additional or Customize To Get Accurate Height
    return MediaQuery.of(context).size.height *
            MediaQuery.of(context).devicePixelRatio +
        kToolbarHeight +
        kBottomNavigationBarHeight;
  }
}

class AppConst {
  static Device getDeviceType(BuildContext? context) {
    final data = MediaQuery.of(context!);
    return data.size.shortestSide > 600 ? Device.tablet : Device.phone;
  }

  static const ThemeType AppTheme = ThemeType.light;
  static const String primaryErrorMsg = 'Oops! Something went wrong.';
  static const String timeOutErrorMsg =
      "Timeout, Please try again after some time.";
  static const String networkErrorMsg =
      "Please check your internet connection.";

  static const dataLength = 10;

  static const quizExpiredText =
      'The quiz time has expired.\nWe are taking you to the\nquiz score now';
  static const defaultPrimaryButtonHeight = 36 * magicNumber;
  static const int undoDurationInSecond = 5;

  static Future<T> customLoading<T>(
    Future<T> Function() future,
  ) async {
    final list = await Future.wait(
      [
        future.call(),
        Future.delayed(
          const Duration(milliseconds: 500),
        ),
      ],
    );

    return list[0] as T;
  }

  static String addCommasToInteger(int number) {
    final formatter = NumberFormat('#,###'); // Create a NumberFormat instance
    return formatter
        .format(number); // Format the number with commas and return as a string
  }

  static int readTime(int articleCount) {
    if ((articleCount / 200).ceil() > 0) {
      return (articleCount / 200).ceil();
    } else {
      return 1;
    }
  }

  static final List<BoxShadow> shadow = [
    BoxShadow(
      color: const Color(0xff6e6e6e).withOpacity(0.3),
      offset: const Offset(
        0.0,
        1.0,
      ),
      blurRadius: 6.0,
      spreadRadius: 0.0,
    ),
  ];

  static final List<BlendMode> colorModes = [
    BlendMode.srcIn,
    BlendMode.colorBurn
  ];
  static double remap(
      double value,
      double originalMinValue,
      double originalMaxValue,
      double translatedMinValue,
      double translatedMaxValue) {
    if (originalMaxValue - originalMinValue == 0) return 0;

    return (value - originalMinValue) /
            (originalMaxValue - originalMinValue) *
            (translatedMaxValue - translatedMinValue) +
        translatedMinValue;
  }
}

List<String> fileExtension = ['jpeg', 'jpg', 'png', 'gif'];
List<String> allowedFileExtension = [
  'jpeg',
  'jpg',
  'png',
  'gif',
  'pdf',
  'xls',
  'doc',
  'docx',
  'xlsx',
  'ppt',
  'pptm',
  'pptx',
];

class SectionType {
  static int get caseStudy => 1;
  static int get quiz => 2;
  static int get poll => 3;
  static int get interviewTip => 4;
  static int get resumeTip => 5;
  static int get jargon => 6;

  static int createId(String type, int id) {
    //the switch will make the id unique for each push notification
    switch (type) {
      case "case":
        return id * 10 + caseStudy;
      case "quiz":
        return id * 10 + quiz;
      case "resume":
        return id * 10 + resumeTip;
      case "interview":
        return id * 10 + interviewTip;
      case "business":
        return id * 10 + jargon;
      case "poll":
        return id * 10 + poll;
      default:
        return id;
    }
  }
}

Future<String> saveAssetImageToFile(String assetImagePath) async {
  final ByteData byteData = await rootBundle.load(assetImagePath);
  final Uint8List uint8List = byteData.buffer.asUint8List();

  final String dir = (await getApplicationDocumentsDirectory()).path;
  final String fileName = assetImagePath
      .split('/')
      .last; // Extract the file name from the asset path
  final String filePath = '$dir/$fileName';

  final File file = File(filePath);
  await file.writeAsBytes(uint8List);

  return filePath;
}

Future<ByteData> loadImageFromAssets(String path) async {
  return await rootBundle.load(path);
}

Future<String> saveImage(imageNetworkUrl) async {
  await FileService.requestFilePermission();
  if (imageNetworkUrl.isEmpty) {
    ByteData data = await loadImageFromAssets('assets/app_images/app_icon.png');
    String path = await FileService.getDownloadDirectory();
    File file = File('${path}bigPicture.png');
    if (await file.exists()) {
      return file.path;
    }
    await file.writeAsBytes(data.buffer.asUint8List());
    return file.path;
  } else {
    final http.Response response = await http.get(Uri.parse(imageNetworkUrl));
    String path = await FileService.getDownloadDirectory();
    File file = File('$path${imageNetworkUrl.split('/').last}');
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }
}

String filterFileName(String url) {
  String fileName = Uri.decodeComponent(Uri.parse(url).pathSegments.last);
  return fileName.substring(fileName.indexOf('_') + 1);
}
