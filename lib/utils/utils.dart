import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pverify/controller/dialog_progress_controller.dart';
import 'package:pverify/controller/json_file_operations.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/theme/colors.dart';

class AppIcon {
  static Widget get backIcon => Icon(
        Platform.isAndroid
            ? Icons.arrow_back_outlined
            : Icons.arrow_back_ios_outlined,
        color: AppColors.dark,
        size: 25,
      );

  static Widget get downIcon => Transform.rotate(
        angle: 180 * math.pi / 360,
        child: Icon(
          Icons.arrow_forward_ios_rounded,
          color: AppColors.dark,
          size: 25,
        ),
      );
}

class Utils {
  static String? appCurrentLanguage;
  static bool isDialogShowing = true;

  DateFormat get dateFormat => _dateFormat;
  static final _dateFormat = DateFormat('dd-MM-yyyy');

  final AppStorage _appStorage = AppStorage.instance;

  static final ApplicationDao _dao = ApplicationDao();

  static DateTime fromDateTimeToUTCDateTime(
      String dateFormat, String timeFormat) {
    String a = "$dateFormat $timeFormat";
    DateTime? date = DateTime.parse(a);
    return date.toUtc();
  }

  static double? getLong(dynamic val) {
    if (val is double) {
      return val;
    } else if (val is int) {
      return (val).toDouble();
    } else {
      return null;
    }
  }

  static String fromDateTimeToUTCString(String dateFormat, String timeFormat) {
    return fromDateTimeToUTCDateTime(dateFormat, timeFormat).toIso8601String();
  }

  static Future<bool> isOnline() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
      return true;
    }
    return false;
  }

  /*static Future<XFile?> compressImage(File file,
      {int quality = 80, int minWidth = 1000, int minHeight = 1000}) async {
    final filePath = file.absolute.path;

    final lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";

    */ /* Max image compression quality value accept up to 95 */ /*
    final compressedImage = await FlutterImageCompress.compressAndGetFile(
        filePath, outPath,
        minWidth: minWidth, minHeight: minHeight, quality: quality);

    return compressedImage;
  }*/

  static Future<bool> hasInternetConnection() async {
    try {
      List<ConnectivityResult> connectivityResults =
          await Connectivity().checkConnectivity();

      // Iterating through the list of connectivity results to check for any connection
      for (var connectivityResult in connectivityResults) {
        if (connectivityResult == ConnectivityResult.mobile ||
            connectivityResult == ConnectivityResult.wifi) {
          // Device is connected to either mobile or WiFi network
          return true;
        }
      }

      // No valid connection found
      return false;
    } catch (_) {
      // Error occurred, assuming offline
      return false;
    }
  }

  /*static Future<bool> hasInternetConnection() async {
    bool isOffline;
    try {
      ConnectivityResult connectivityResult =
          await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile) {
        // I am connected to a mobile network.
        return true;
      } else if (connectivityResult == ConnectivityResult.wifi) {
        // I am connected to a wifi network.
        return true;
      } else {
        return false;
      }
    } on PlatformException catch (_) {
      isOffline = false;
      return isOffline;
    } on TimeoutException catch (_) {
      isOffline = false;
      return isOffline;
    } on SocketException catch (_) {
      isOffline = false;
      return isOffline;
    }
  }*/

  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return _dateFormat.format(date);
  }

  Future<void> showAlertDialog({
    required BuildContext context,
    required String title,
    String? content,
    void Function()? onPressed,
  }) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(
          title,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
        ),
        content: Text(
          (content != null) ? content : "",
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
        ),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Get.back();
            },
            child: Text(
              'No',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  color: AppColors.alertBoxTextColot),
            ),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: onPressed,
            child: Text(
              'Yes',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  color: AppColors.alertBoxTextColot),
            ),
          ),
        ],
      ),
    );
  }

  static void showInternetConnectionDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text('OK'),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        // dismisses only the dialog and returns nothing
        isDialogShowing = false;
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('internetConnection'.tr),
      content: Text('noInternetConnection'.tr),
      actions: [
        okButton,
      ],
    );
    isDialogShowing = true;
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    ).onError((error, stackTrace) {
      isDialogShowing = false;
    }).whenComplete(() {
      isDialogShowing = false;
    });
  }

  static getRandomString([int len = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz';
    final random = math.Random.secure();
    return List.generate(len, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  static String parseTimeStamp({required int value, required bool isTime}) {
    if (isTime) {
      DateTime calender = DateTime.fromMillisecondsSinceEpoch(value * 1000);
      String date = DateFormat('hh:mm a').format(calender);
      log("Date => $calender");
      return date;
    } else {
      DateTime time = DateTime.fromMillisecondsSinceEpoch(value * 1000);
      String d12 = DateFormat('dd/MM/yyyy').format(time);
      log("Milli second to hours and min => $d12");
      return d12;
    }
  }

  static String getNewImage(String s, String errorUrl, {int size = 200}) {
    final Uri url = Uri.parse(s);
    final List<String> pathSagment = url.pathSegments.toList();

    if (pathSagment.isNotEmpty) {
      final String fileName = pathSagment[pathSagment.length - 1];

      // split file name
      final List<String> fileNameList = fileName.split('.');

      if (fileNameList.length >= 2) {
        // chnage file name
        fileNameList[fileNameList.length - 2] =
            '${fileNameList[fileNameList.length - 2]}_${size}x$size';

        // join file name
        final String newName = fileNameList.join('.');
        // set new file name
        pathSagment[pathSagment.length - 1] = newName;
        // replace new path segments
        return url.replace(pathSegments: pathSagment).toString();
      }
    }
    return errorUrl;
  }

  static String convertStringToDate(
      {required String data,
      bool isTime = false,
      bool getInLocalTime = false}) {
    String? date;
    DateTime dateTime = DateTime.parse(data);
    dateTime = dateTime.toLocal();
    if (isTime) {
      date = DateFormat("jm").format(dateTime);
    } else {
      date = DateFormat("dd/MM/yyyy").format(dateTime);
    }

    log('date =>$date');
    return date;
  }

  static String timeAgo({required DateTime d}) {
    Duration diff = DateTime.now().difference(d);
    if (diff.inDays > 365) {
      return "${(diff.inDays / 365).floor()}${(diff.inDays / 365).floor() == 1 ? " year" : "years"} ago";
    }
    if (diff.inDays > 30) {
      return "${(diff.inDays / 30).floor()}${(diff.inDays / 30).floor() == 1 ? " month" : "months"} ago";
    }
    if (diff.inDays > 7) {
      return "${(diff.inDays / 7).floor()}${(diff.inDays / 7).floor() == 1 ? " week" : "weeks"} ago";
    }
    if (diff.inDays > 0) {
      return "${diff.inDays}${diff.inDays == 1 ? " day" : " days"} ago";
    }
    if (diff.inHours > 0) {
      return "${diff.inHours}${diff.inHours == 1 ? " h" : " h"} ago";
    }
    if (diff.inMinutes > 0) {
      return "${diff.inMinutes}${diff.inMinutes == 1 ? " min" : " min"} ago";
    }
    return "just now";
  }

  String expireTime({required DateTime expTime}) {
    Duration diff = expTime.difference(DateTime.now().toUtc().toLocal());
    if (diff.inDays > 7) {
      return "Expires in ${(diff.inDays / 7).floor()}${(diff.inDays / 7).floor() == 1 ? " week" : "weeks"} ";
    }
    if (diff.inDays > 0) {
      return "Expires in ${diff.inDays}${diff.inDays == 1 ? " day" : " days"} ";
    }
    if (diff.inHours > 0) {
      return "Expires in ${diff.inHours}${diff.inHours == 1 ? "h" : "h"} ";
    }
    return "";
  }

  static String timewithAgo({required DateTime d}) {
    Duration diff = DateTime.now().difference(d);
    if (diff.inDays > 365) {
      return "${(diff.inDays / 365).floor()}${(diff.inDays / 365).floor() == 1 ? " year" : "years"}";
    }
    if (diff.inDays > 30) {
      return "${(diff.inDays / 30).floor()}${(diff.inDays / 30).floor() == 1 ? " month" : "months"}";
    }
    if (diff.inDays > 7) {
      return "${(diff.inDays / 7).floor()}${(diff.inDays / 7).floor() == 1 ? " week" : "weeks"}";
    }
    if (diff.inDays > 0) {
      return "${diff.inDays}${diff.inDays == 1 ? " day" : " days"}";
    }
    if (diff.inHours > 0) {
      return "${diff.inHours}${diff.inHours == 1 ? " h" : " h"}";
    }
    if (diff.inMinutes > 0) {
      return "${diff.inMinutes}${diff.inMinutes == 1 ? " min" : " min"}";
    }
    return "just now";
  }

  Future<ImageSource?> selectImageSource({
    required BuildContext context,
    required String title,
    String? content,
    void Function()? onPressed,
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
        ),
        content: Text(
          (content != null) ? content : "",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: Text(
              'Camera',
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: Text(
              'Gallery',
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
        ],
      ),
    );
  }

  static void showErrorAlertDialog(String message,
      {Widget? additionalButton, Function? onOk}) {
    // Helly redesign this dialog based on client requirement, change text style and color

    Get.dialog(AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      title: Text(
        "ERROR",
        style: Get.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.bold, fontSize: 30.sp, color: Colors.black),
      ),
      content: Text(
        message,
        style: Get.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w500, fontSize: 20.sp, color: Colors.black),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            if (onOk != null) {
              onOk();
            }
          },
          child: Text(
            'OK',
            style: Get.textTheme.displayMedium?.copyWith(
              color: AppColors.textFieldText_Color,
            ),
          ),
        ),
        additionalButton ?? Container(),
      ],
    ));
  }

  static Future<int> checkWifiLevel() async {
    int level = 0;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.wifi)) {
      level = 3;
      // FIXME: check wifi level
    } else {
      level = 0;
    }
    return level;
  }

  Future<String> getExternalStoragePath() async {
    if (Platform.isAndroid) {
      // return '/storage/emulated/0/';
      var externalStoragePath =
          await getApplicationSupportDirectory().then((value) => value.path);
      return '$externalStoragePath/';
    } else if (Platform.isIOS) {
      var externalStoragePath =
          await getApplicationDocumentsDirectory().then((value) => value.path);
      return '$externalStoragePath/';
    } else {
      return "";
    }
  }

  Future<void> offlineLoadCommodityVarietyDocuments(
      String specNumber, String specVersion) async {
    String filename = FileManString.COMMODITYDOCS_JSON_STRING_FORMAT
        .replaceAll('%s', '${specNumber}_$specVersion');
    String? json = await loadFileToStringFromExternalStorage(
        filename, FileManString.jsonFilesCache);
    if (json != null) {
      _appStorage.commodityVarietyData =
          JsonFileOperations.parseCommodityToolbarDataJson(json);
    }
  }

  Future<String?> loadFileToStringFromExternalStorage(
      String filename, String directory) async {
    String externalStoragePath = await Utils().getExternalStoragePath();

    String path = '$externalStoragePath/$directory/$filename';
    File file = File(path);
    try {
      if (file.existsSync()) {
        List<int> bytes = file.readAsBytesSync();
        String contents = String.fromCharCodes(bytes);
        return contents;
      }
    } catch (e) {
      debugPrint('loadFileToStringFromExternalStorage error: $e');
    }
    return null;
  }

  static Future<String> createCommodityVarietyDocumentDirectory() async {
    String externalStoragePath = await Utils().getExternalStoragePath();
    var directory = Directory(
        '$externalStoragePath${FileManString.commodityVarietyDocument}');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    return directory.path;
  }

  static double parseDoubleDefault(value) {
    value = value.toString();
    if (value.isEmpty) {
      return 0.0;
    }
    RegExp regExp = RegExp(r'(\d+(\.\d+)?)');
    String numericPart = regExp.firstMatch(value)?.group(0) ?? '0';

    return double.parse(numericPart);
  }

  static int parseIntDefault(value) {
    value = value.toString();
    if (value.isEmpty) {
      return 0;
    }
    RegExp regExp = RegExp(r'(\d+(\.\d+)?)');
    String numericPart = regExp.firstMatch(value)?.group(0) ?? '0';

    return int.parse(numericPart);
  }

  int checkCacheDays() {
    DateTime currentDate = DateTime.now();

    int cacheTimestamp = _appStorage.getInt(StorageKey.kCacheDate) ??
        currentDate.millisecondsSinceEpoch;
    DateTime cacheDate = DateTime.fromMillisecondsSinceEpoch(cacheTimestamp);

    int daysDifference = currentDate.difference(cacheDate).inDays;

    return daysDifference;
  }

  static Future<void> showLoadingDialog() async {
    await Future.delayed(const Duration(milliseconds: 10));
    Get.dialog(
      Center(
        child: SizedBox(
          height: 25,
          width: 25,
          child: Transform.scale(
            scale: 2,
            child: Platform.isIOS
                ? const CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    backgroundColor: Colors.white,
                  )
                : const CircularProgressIndicator.adaptive(
                    backgroundColor: Colors.white,
                  ),
          ),
        ),
      ),
      barrierDismissible: false,
      transitionCurve: Curves.easeInOut,
      navigatorKey: Get.key,
      transitionDuration: const Duration(milliseconds: 200),
    );

    await Future.delayed(const Duration(milliseconds: 10));
  }

  // hide loading dialog using navigatorKey
  static Future<void> hideLoadingDialog() async {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    await Future.delayed(const Duration(milliseconds: 10));
  }

  static Future<void> showLinearProgressWithMessage(
      {String? message, required ProgressController progressController}) async {
    // ProgressController progressController = Get.find<ProgressController>();
    await Future.delayed(const Duration(milliseconds: 10));
    Get.dialog(
      Obx(() => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: SizedBox(
                  height: 25,
                  width: 25,
                  child: Transform.scale(
                    scale: 2,
                    child: LinearProgressIndicator(
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      backgroundColor: Colors.white,
                      value: progressController.progress.value.toDouble(),
                    ),
                  ),
                ),
              ),
              Text(
                message ?? 'Loading...',
                style: Get.textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 30.sp,
                ),
              )
            ],
          )),
      barrierDismissible: false,
      transitionCurve: Curves.easeInOut,
      navigatorKey: Get.key,
      transitionDuration: const Duration(milliseconds: 200),
    );

    await Future.delayed(const Duration(milliseconds: 10));
  }

  static Future<void> setInspectionUploadStatus(
      int inspectionId, int inspectionUploadReady) async {
    await _dao.updateInspectionUploadStatus(
        inspectionId, inspectionUploadReady);
  }

  static void showSnackBar({
    required BuildContext context,
    required String message,
    required MaterialColor backgroundColor,
    Duration? duration,
  }) {
/*
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
          ),
        ),
        backgroundColor: backgroundColor,
        duration: duration,
      ),
    );
*/

    showCustomSnackBar(
        context, message, Colors.red, duration ?? const Duration(seconds: 3));
  }

  static void showCustomSnackBar(BuildContext context, String message,
      Color backgroundColor, Duration duration) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(duration, () => overlayEntry.remove());
  }
}

void unFocus() {
  FocusManager.instance.primaryFocus?.unfocus();
}

enum PicDir {
  petPictures,
  profilePictures,
}

void printKeysAndValueTypes(Map<String, dynamic> json) {
  /*json.forEach((key, value) {
    log('$key (${value.runtimeType})');
  });*/

  log(json.entries
      .map(
          (entry) => '${entry.key} ${entry.value} (${entry.value.runtimeType})')
      .join(', '));
}

int? parseIntOrReturnNull(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.toInt();
  }
  if (value is String) {
    if (value.isEmpty) {
      return null;
    } else {
      return int.tryParse(value);
    }
  }
  String _value = value.toString();
  if (_value.isNotEmpty) {
    return int.tryParse(_value);
  }
  return null;
}

double? parseDoubleOrReturnNull(value) {
  if (value == null) {
    return null;
  }
  if (value is double) {
    return value;
  }
  if (value is int) {
    return value.toDouble();
  }
  if (value is String) {
    if (value.isEmpty) {
      return null;
    } else {
      return double.tryParse(value);
    }
  }
  String _value = value.toString();
  if (_value.isNotEmpty) {
    return double.tryParse(_value);
  }
  return null;
}

String generateUUID() {
  final math.Random random = math.Random();
  final StringBuffer buffer = StringBuffer();

  for (int i = 0; i < 32; i++) {
    if (i == 8 || i == 12 || i == 16 || i == 20) {
      buffer.write('-');
    }
    buffer.write(random.nextInt(16).toRadixString(16));
  }

  return buffer.toString();
}
