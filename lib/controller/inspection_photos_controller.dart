import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pverify/models/inspection_attachment.dart';
import 'package:pverify/models/inspection_defect_attachment.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
import 'package:pverify/utils/utils.dart';

class InspectionPhotosController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  List<PictureData> imagesList = <PictureData>[].obs;
  List<PictureData> imagesListBackup = <PictureData>[];
  final ApplicationDao dao = ApplicationDao();
  List<int> attachmentIds = [];

  bool forDefect = false;

  bool hasAttachmentIds = false;

  String partnerName = '';
  int? partnerID;
  String carrierName = '';
  int? carrierID;
  String? commodityName;
  int commodityID = 0;
  String? varietyName;
  String? varietySize;
  int? varietyId;
  int sampleId = -1;
  int defectId = -1;
  bool isViewOnlyMode = true;
  int inspectionId = -1;
  String callerActivity = '';

  @override
  void onInit() {
    super.onInit();
    Map<String, dynamic>? args = Get.arguments;
    if (args == null) {
      Get.back();
      throw Exception('Arguments required!');
    }

    partnerName = args[Consts.PARTNER_NAME] ?? '';
    partnerID = args[Consts.PARTNER_ID] ?? 0;
    carrierName = args[Consts.CARRIER_NAME] ?? '';
    carrierID = args[Consts.CARRIER_ID];
    commodityName = args[Consts.COMMODITY_NAME];
    commodityID = args[Consts.COMMODITY_ID] ?? 0;
    varietyName = args[Consts.VARIETY_NAME];
    varietySize = args[Consts.VARIETY_SIZE];
    varietyId = args[Consts.VARIETY_ID];
    isViewOnlyMode = args[Consts.IS_VIEW_ONLY_MODE] ?? false;
    inspectionId = args[Consts.INSPECTION_ID] ?? -1;

    sampleId = args[Consts.SAMPLE_ID] ?? -1;
    defectId = args[Consts.DEFECT_ID] ?? -1;
    hasAttachmentIds = args[Consts.HAS_INSPECTION_IDS] ?? false;

    callerActivity = args[Consts.CALLER_ACTIVITY] ?? '';
    forDefect = args[Consts.FOR_DEFECT_ATTACHMENT] ?? false;

    if (forDefect) {
      loadDefectPicturesFromDB();
    } else {
      loadPicturesFromDB();
    }
  }

  Future<String> saveImageToInternalStorage(File imageFile) async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String documentsPath = appDir.path;
    String appFolderPath = '$documentsPath/MyAppFolder';
    Directory(appFolderPath).createSync(recursive: true);

    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    String uniqueFileName = "insp_$timeStamp";
    File newImageFile = File('$appFolderPath/$uniqueFileName.jpg');
    await newImageFile.writeAsBytes(imageFile.readAsBytesSync());
    debugPrint('Image saved to: ${newImageFile.path}');

    return newImageFile.path;
  }

  Future getImageFromGallery() async {
    _picker.supportsImageSource(ImageSource.gallery);
    final List<XFile> image = await _picker.pickMultiImage();
    for (var element in image) {
      File file = File(element.path);

      PictureData pictureData = PictureData(
          image: file,
          Attachment_Title: '',
          createdTime: DateTime.now().millisecondsSinceEpoch,
          pathToPhoto: await saveImageToInternalStorage(file));

      imagesList.add(pictureData);
      imagesListBackup.add(pictureData);
    }
  }

  Future<File?> getImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      File imagePath = File(image.path);
      PictureData pictureData = PictureData(
          image: imagePath,
          Attachment_Title: '',
          createdTime: DateTime.now().millisecondsSinceEpoch,
          pathToPhoto: await saveImageToInternalStorage(imagePath));

      imagesList.add(pictureData);
      imagesListBackup.add(pictureData);
      return imagePath;
    }
    return null;
  }

  Future<void> cropImage(File imageFile, int index) async {
    final File? croppedImage = await getCroppedImageFile(imageFile);

    if (croppedImage != null) {
      // compressedImage =
      final XFile? compressedImage = await Utils.compressImage(croppedImage);
      if (compressedImage != null) {
        File compressedImageFile = File(compressedImage.path);
        imagesList.removeAt(index);
        PictureData pictureData = PictureData(
            image: compressedImageFile,
            Attachment_Title: '',
            createdTime: DateTime.now().millisecondsSinceEpoch,
            pathToPhoto: await saveImageToInternalStorage(compressedImageFile));

        imagesList.insert(index, pictureData);
        imagesListBackup.insert(index, pictureData);
      }
    }
  }

  Future<File?> getCroppedImageFile(File imageFile) async {
    return await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: const AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: const IOSUiSettings(
          title: 'Cropper',
          minimumAspectRatio: 1.0,
        ));
  }

  removeImage(int index) {
    imagesList.removeAt(index);
    imagesListBackup.removeAt(index);
  }

  updateContent(int index, String title) {
    var data = imagesList[index];
    imagesList.removeAt(index);
    PictureData pictureData = PictureData(
        image: data.image,
        Attachment_Title: title,
        createdTime: data.createdTime,
        pathToPhoto: data.pathToPhoto);

    imagesList.add(pictureData);
    imagesListBackup.add(pictureData);
  }

  Future<void> saveAction() async {
    await savePicturesToDB();
    appStorage.attachmentIds = attachmentIds;
    Get.back(result: appStorage.attachmentIds);
  }

  Future<void> savePicturesToDB() async {
    for (int i = 0; i < imagesList.length; i++) {
      if (imagesList[i].savedInDB == true) {
        attachmentIds.add(imagesList[i].pictureId ?? 0);
      } else {
        if (forDefect) {
          int? attachmentId = await dao.createDefectAttachment(
            inspectionId: inspectionId,
            sampleId: sampleId,
            defectId: defectId,
            createdTime: imagesList[i].createdTime,
            fileLocation: imagesList[i].pathToPhoto ?? '',
          );
          if (attachmentId != null) {
            attachmentIds.add(attachmentId);
            imagesListBackup.clear();
          }
        } else {
          int? attachmentId = await dao.createInspectionAttachment(
              InspectionAttachment(
                Inspection_ID: inspectionId,
                Attachment_ID: 0,
                Attachment_Title: imagesList[i].Attachment_Title ?? '',
                CREATED_TIME: imagesList[i].createdTime ?? 0,
                filelocation: imagesList[i].pathToPhoto ?? '',
                title: imagesList[i].Attachment_Title ?? '',
              ),
              imagesList[i].Attachment_Title ?? '',
              imagesList[i].createdTime ?? '',
              imagesList[i].pathToPhoto ?? '');

          if (attachmentId != null) {
            attachmentIds.add(attachmentId);
            imagesListBackup.clear();
          }
        }
      }
    }
  }

  Future<void> deletePicture(int position) async {
    if (imagesList[position].savedInDB == true) {
      try {
        if (forDefect) {
          await dao.deleteDefectAttachmentByAttachmentId(
              imagesList[position].pictureId ?? 0);
        } else {
          await dao.deleteAttachmentByAttachmentId(
              imagesList[position].pictureId ?? 0);
        }

        imagesList.removeAt(position);
        imagesListBackup.removeAt(position);
      } catch (e) {
        debugPrint('Error creating attachment: $e');
      }
    }
  }

  void backAction(BuildContext context) {
    if (imagesListBackup.isEmpty) {
      Get.back(result: true);
    } else {
      if (imagesListBackup.length == 1) {
        AppAlertDialog.confirmationAlert(
          context,
          AppStrings.error,
          AppStrings.pic1NotSave,
          onYesTap: () {
            Get.back();
          },
        );
      } else {
        AppAlertDialog.confirmationAlert(
          context,
          AppStrings.error,
          'There are ${imagesListBackup.length} pictures not saved, are you sure you want to back?',
          onYesTap: () {
            Get.back(result: true);
          },
        );
      }
    }
  }

  Future<void> loadPicturesFromDB() async {
    List<InspectionAttachment> picsFromDB = [];
    if (appStorage.attachmentIds != null) {
      hasAttachmentIds =
          (appStorage.attachmentIds!.isNotEmpty ? true : false) && forDefect;
    }

    try {
      if (hasAttachmentIds == true) {
        List<int>? attachmentIds = appStorage.attachmentIds;
        if (attachmentIds != null && attachmentIds.isNotEmpty) {
          for (int i = 0; i < attachmentIds.length; i++) {
            var value = await dao
                .findAttachmentByAttachmentId(attachmentIds[i])
                .catchError((error) {
              debugPrint('Error fetching attachment: $error');
            });
            if (value != null) {
              picsFromDB.add(value);
            }
          }
        }
      } else {
        if (inspectionId > 0) {
          var value = await dao
              .findInspectionAttachmentsByInspectionId((inspectionId))
              .catchError((error) {
            debugPrint('Error in else fetching attachment: $error');
          });
          picsFromDB = value;
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    if (picsFromDB.isNotEmpty) {
      for (int i = 0; i < picsFromDB.length; i++) {
        PictureData temp = PictureData();
        temp.setData(picsFromDB[i].Attachment_ID, picsFromDB[i].filelocation,
            true, File(picsFromDB[i].filelocation.toString()));
        imagesList.add(temp);
      }
    }
    log(imagesList.length);
    imagesListBackup.clear();
    update();
  }

  AppStorage get appStorage => AppStorage.instance;

  Future<void> loadDefectPicturesFromDB() async {
    List<InspectionDefectAttachment> picsFromDB = [];

    try {
      if (isViewOnlyMode) {
        if (sampleId != -1) {
          picsFromDB =
              await dao.findDefectAttachmentsBySampleId(sampleId) ?? [];
        }
      } else {
        if (defectId != -1) {
          picsFromDB =
              await dao.findDefectAttachmentsByDefectId(defectId) ?? [];
        } else if (hasAttachmentIds) {
          List<int> attachmentIds = appStorage.attachmentIds ?? [];
          if (attachmentIds.isNotEmpty) {
            for (var id in attachmentIds) {
              InspectionDefectAttachment? inspectionDefectAttachment =
                  await dao.findDefectAttachmentByAttachmentId(id);
              if (inspectionDefectAttachment != null) {
                picsFromDB.add(inspectionDefectAttachment);
              }
            }
          }
        }
      }
    } catch (e) {
      print(e.toString());
    }

    if (picsFromDB.isNotEmpty) {
      for (var pic in picsFromDB) {
        PictureData temp = PictureData();
        temp.setData(pic.attachmentId, pic.fileLocation, true,
            File(pic.fileLocation.toString()));
        imagesList.add(temp);
      }
    }
    update();
  }
}
