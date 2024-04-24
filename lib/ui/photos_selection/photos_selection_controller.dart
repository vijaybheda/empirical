// ignore_for_file: unused_local_variable, unused_field, prefer_const_constructors, depend_on_referenced_packages, unused_element, unnecessary_null_comparison, empty_catches

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pverify/models/inspection_attachment.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/utils/app_storage.dart';

class PhotoSelectionController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  var imagesList = <PictureData>[].obs;
  final ApplicationDao dao = ApplicationDao();
  int? inspectionId;
  List<int> attachmentIds = [];
  get title => null;
  bool? hasAttachmentIds = false;

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

      imagesList.add(PictureData(
          image: file,
          photoTitle: '',
          createdTime: DateTime.now().millisecondsSinceEpoch,
          pathToPhoto: await saveImageToInternalStorage(file)));
    }
  }

  Future getImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    File file = File(image?.path ?? '');
    imagesList.add(PictureData(
        image: file,
        photoTitle: '',
        createdTime: DateTime.now().millisecondsSinceEpoch,
        pathToPhoto: await saveImageToInternalStorage(file)));
  }

  Future<void> cropImage(File imageFile, int index) async {
    final croppedImage = await ImageCropper().cropImage(
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
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
          minimumAspectRatio: 1.0,
        ));

    if (croppedImage != null) {
      imagesList.removeAt(index);
      imagesList.insert(
          index,
          PictureData(
              image: croppedImage,
              photoTitle: '',
              createdTime: DateTime.now().millisecondsSinceEpoch,
              pathToPhoto: await saveImageToInternalStorage(croppedImage)));
    }
  }

  removeImage(int index) {
    imagesList.removeAt(index);
  }

  updateContent(int index, String title) {
    var data = imagesList[index];
    imagesList.removeAt(index);
    imagesList.add(PictureData(
        image: data.image,
        photoTitle: title,
        createdTime: data.createdTime,
        pathToPhoto: data.pathToPhoto));
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
                    ATTACHMENT_TITLE: imagesList[i].photoTitle ?? '',
                    CREATED_TIME: imagesList[i].createdTime ?? 0,
                    FILE_LOCATION: imagesList[i].pathToPhoto ?? ''),
                imagesList[i].photoTitle ?? '',
                imagesList[i].createdTime ?? '',
                imagesList[i].pathToPhoto ?? '')
            .then((attachmentId) {
          attachmentIds.add(attachmentId);
        }).catchError((error) {
          debugPrint('Error creating attachment: $error');
        });
        //attachmentIds.add(attachmentId);
      }
      // recycle the bitmaps to free up memory
      // pictureList[i].photoBitmap?.recycle();
    }
  }

  void deletePicture(int position) {
    if (imagesList[position].savedInDB == true) {
      try {
        dao.deleteAttachmentByAttachmentId(imagesList[position].pictureId ?? 0);
      } catch (e) {}
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
        if (inspectionId != null) {
          await dao
              .findInspectionAttachmentsByInspectionId(inspectionId!.toInt())
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

    if (picsFromDB != null && picsFromDB.isNotEmpty) {
      for (int i = 0; i < picsFromDB.length; i++) {
        PictureData temp = PictureData();
        /*  temp.setData(
          picsFromDB[i].attachmentId,
          picsFromDB[i].fileLocation,
          getPic(picsFromDB[i].fileLocation),
          true,
        );*/
        imagesList.add(temp);
      }
    }
  }
}
