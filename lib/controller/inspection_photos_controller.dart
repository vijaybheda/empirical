import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pverify/models/inspection_attachment.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';

class InspectionPhotosController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  var imagesList = <PictureData>[].obs;
  var imagesListBackup = <PictureData>[];
  final ApplicationDao dao = ApplicationDao();
  List<int> attachmentIds = [];

  get title => null;
  bool? hasAttachmentIds = false;

  String partnerName = '';
  int? partnerID;
  String carrierName = '';
  int? carrierID;
  String? commodityName;
  int commodityID = 0;
  String? varietyName;
  String? varietySize;
  int? varietyId;
  bool isViewOnlyMode = true;
  int inspectionId = -1;
  String callerActivity = '';

  @override
  void onInit() {
    super.onInit();
    Map<String, dynamic>? args = Get.arguments;
    if (args == null) {
      Get.back();
      throw Exception('Arguments not allowed');
    }

    inspectionId = args[Consts.INSPECTION_ID];
    partnerName = args[Consts.PARTNER_NAME] ?? '';
    partnerID = args[Consts.PARTNER_ID] ?? 0;
    carrierName = args[Consts.CARRIER_NAME] ?? '';
    carrierID = args[Consts.CARRIER_ID];
    commodityName = args[Consts.COMMODITY_NAME];
    commodityID = args[Consts.COMMODITY_ID] ?? 0;
    varietyName = args[Consts.VARIETY_NAME];
    varietySize = args[Consts.VARIETY_SIZE];
    varietyId = args[Consts.VARIETY_ID];
    isViewOnlyMode = args[Consts.IS_VIEW_ONLY_MODE] ?? true;
    inspectionId = args[Consts.INSPECTION_ID] ?? -1;
    callerActivity = args[Consts.CALLER_ACTIVITY] ?? '';

    isViewOnlyMode = false;
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
    final croppedImage = await getCroppedImageFile(imageFile);

    if (croppedImage != null) {
      imagesList.removeAt(index);
      PictureData pictureData = PictureData(
          image: croppedImage,
          Attachment_Title: '',
          createdTime: DateTime.now().millisecondsSinceEpoch,
          pathToPhoto: await saveImageToInternalStorage(croppedImage));

      imagesList.insert(index, pictureData);
      imagesListBackup.insert(index, pictureData);
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

  @override
  void onReady() {
    super.onReady();
    loadPicturesFromDB();
  }

  void saveAction() async {
    await savePicturesToDB();
    AppStorage.instance.attachmentIds = attachmentIds;
    /*Intent returnIntent = new Intent();
      returnIntent.putExtra("callerActivity", "InspectionPhotosActivity");
      setResult(RESULT_OK, returnIntent);
     */
    Get.back();
  }

  // TODO: FLUTTER CODE

  Future<void> savePicturesToDB() async {
    for (int i = 0; i < imagesList.length; i++) {
      if (imagesList[i].savedInDB == true) {
        attachmentIds.add(imagesList[i].pictureId ?? 0);
      } else {
        await dao
            .createInspectionAttachment(
                InspectionAttachment(
                    Inspection_ID: inspectionId ?? 0,
                    Attachment_ID: 0,
                    Attachment_Title: imagesList[i].Attachment_Title ?? '',
                    CREATED_TIME: imagesList[i].createdTime ?? 0,
                    FILE_LOCATION: imagesList[i].pathToPhoto ?? ''),
                imagesList[i].Attachment_Title ?? '',
                imagesList[i].createdTime ?? '',
                imagesList[i].pathToPhoto ?? '')
            .then((attachmentId) {
          attachmentIds.add(attachmentId);
          imagesListBackup.clear();
        }).catchError((error) {
          debugPrint('Error creating attachment: $error');
        });
      }
    }
  }

  Future<void> deletePicture(int position) async {
    if (imagesList[position].savedInDB == true) {
      try {
        await dao.deleteAttachmentByAttachmentId(
            imagesList[position].pictureId ?? 0);

        imagesList.removeAt(position);
        imagesListBackup.removeAt(position);
      } catch (e) {
        debugPrint('Error creating attachment: $e');
      }
    }
  }

  void backAction(BuildContext context) {
    if (imagesListBackup.isEmpty) {
      Get.back();
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
            Get.back();
          },
        );
      }
    }
  }

  Future<void> loadPicturesFromDB() async {
    List<InspectionAttachment> picsFromDB = [];
    if (AppStorage.instance.attachmentIds != null) {
      hasAttachmentIds =
          AppStorage.instance.attachmentIds!.isNotEmpty ? true : false;
    }

    try {
      if (hasAttachmentIds == true) {
        List<int>? attachmentIds = AppStorage.instance.attachmentIds;
        if (attachmentIds != null && attachmentIds.isNotEmpty) {
          for (int i = 0; i < attachmentIds.length; i++) {
            await dao
                .findAttachmentByAttachmentId(attachmentIds[i])
                .then((value) {
              if (value != null) {
                picsFromDB.add(value);
              }
            }).catchError((error) {
              debugPrint('Error fetching attachment: $error');
            });
          }
        }
      } else {
        if (inspectionId > 0) {
          await dao
              .findInspectionAttachmentsByInspectionId((inspectionId ?? 0))
              .then((value) {
            picsFromDB = value;
          }).catchError((error) {
            debugPrint('Error in else fetching attachment: $error');
          });
        }
      }
    } catch (e) {
      debugPrint(e.toString()); // Print any exceptions
    }

    if (picsFromDB.isNotEmpty) {
      for (int i = 0; i < picsFromDB.length; i++) {
        PictureData temp = PictureData();
        temp.setData(picsFromDB[i].Attachment_ID, picsFromDB[i].FILE_LOCATION,
            true, File(picsFromDB[i].FILE_LOCATION.toString()));
        imagesList.add(temp);
      }
    }
    log(imagesList.length);
    imagesListBackup.clear();
  }
}
