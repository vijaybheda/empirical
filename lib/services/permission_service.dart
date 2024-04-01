// ignore_for_file: unused_element

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  static PermissionsService get instance => _instance;
  static final PermissionsService _instance = PermissionsService._internal();
  PermissionsService._internal();

  static const kPermissionStateToBool = {
    PermissionStatus.granted: true,
    PermissionStatus.limited: true,
    PermissionStatus.denied: false,
    PermissionStatus.restricted: false,
    PermissionStatus.permanentlyDenied: false,
  };

  static const locationPermission = Permission.location;
  static const cameraPermission = Permission.camera;
  static const photoLibraryPermission = Permission.photos;
  static const microphonePermission = Permission.microphone;
  static const notificationsPermission = Permission.notification;

  Future<bool> _getPermissionStatus(Permission setting) async {
    if (kIsWeb) {
      return true;
    }
    final status = await setting.status;
    return kPermissionStateToBool[status]!;
  }

  Future<PermissionStatus> _requestPermission(Permission setting) async {
    PermissionStatus status = await setting.request();
    return status;
  }

  Future<bool> checkAndRequestExternalStoragePermissions() async {
    if (Platform.isAndroid) {
      final PermissionStatus storagePermissionStatus =
          await Permission.manageExternalStorage.status;
      await Permission.manageExternalStorage.request();
      if (!storagePermissionStatus.isGranted) {
        if (await Permission.manageExternalStorage.isRestricted) {
          // Permission is restricted, open app settings
          // openAppSettings();
          /*Utils.showInfoAlertDialog(
            AppStrings.storageDeniedMessage,
            onOk: () {
              Get.back();
            },
            additionalButton: TextButton(
              onPressed: () {
                Get.back();
                openAppSettings();
              },
              child: Text(
                'Open Settings',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          );*/
          return false;
        } else {
          // Request permission
          // await Permission.manageExternalStorage.request();
          PermissionStatus status =
              await _requestPermission(Permission.manageExternalStorage);
          return status.isGranted;
        }
      }
    }
    return true;
  }

  Future<bool> checkAndRequestCameraPhotosPermissions() async {
    final PermissionStatus cameraPermissionStatus =
        await Permission.camera.status;
    final PermissionStatus photoLibraryPermissionStatus =
        await Permission.photos.status;
    if (!cameraPermissionStatus.isGranted ||
        !photoLibraryPermissionStatus.isGranted) {
      if (await Permission.camera.isRestricted ||
          await Permission.photos.isRestricted) {
        // Permission is restricted, open app settings
        // openAppSettings();
        return false;
      } else {
        // Request permission
        // await Permission.camera.request();
        // await Permission.photos.request();

        PermissionStatus cameraStatus =
            await _requestPermission(Permission.camera);
        PermissionStatus photosStatus =
            await _requestPermission(Permission.photos);

        return photosStatus.isGranted && cameraStatus.isGranted;
      }
    }
    return true;
  }
}
