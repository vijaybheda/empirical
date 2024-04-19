// ignore_for_file: unused_local_variable, unused_field, prefer_const_constructors, depend_on_referenced_packages, unused_element, unnecessary_null_comparison

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class PhotoSelectionController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  RxList imgList = [].obs;

  Future getImageFromGallery() async {
    _picker.supportsImageSource(ImageSource.gallery);
    final List<XFile> image = await _picker.pickMultiImage();
    imgList.addAll(image);
  }

  Future getImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    imgList.add(image);
  }

  removeImage(int index) {
    imgList.removeAt(index);
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
      imgList.removeAt(index);
      imgList.insert(index, croppedImage);
    }
  }

  // ANDROID CODE

  void saveAction() {
    /* savePicturesToDB();
      AppInfo.attachmentIds = attachmentIds;
      Intent returnIntent = new Intent();
      returnIntent.putExtra("callerActivity", "InspectionPhotosActivity");
      setResult(RESULT_OK, returnIntent);
      finish(); */
    Get.back();
  }

  // TODO: ANDROID CODE

  void savePicturesToDB() {
    // MainApplicationContext appContext = (MainApplicationContext) getApplicationContext();
    // ApplicationDao dao = appContext.getDao();

    // // Loop through and find the pictures that are not already saved in the database
    // for (int i = 0; i < pictureList.size(); i++) {
    //     if (!pictureList.get(i).getSavedInDB()) {
    //         Long attachmentId = dao.createInspectionAttachment(inspectionId, pictureList.get(i).getPhotoTitle(),
    //                 pictureList.get(i).getCreatedTime(), pictureList.get(i).getPathToPhoto());
    //         attachmentIds.add(attachmentId);
    //     } else {
    //         attachmentIds.add(pictureList.get(i).getPictureId());
    //     }

    //     // recycle the bitmaps to free up memory
    //     //pictureList.get(i).getPhotoBitmap().recycle();
    // }
  }

  // THIS METHOD WILL CALL WHILE TAP ON DELETE BUTTON

  void deletePicture(int position) {
//         MainApplicationContext appContext = (MainApplicationContext) getApplicationContext();
//         ApplicationDao dao = appContext.getDao();

//         // remove the picture from the database
//         if (pictureList.get(position).getSavedInDB()) {
//             try {
//                 dao.deleteAttachmentByAttachmentId(pictureList.get(position).getPictureId());
//             } catch (Exception e) {
//                 e.printStackTrace();
//             }
//         }

// //         delete the actual picture from the phones memory
// //        new File(pictureList.get(position).getPathToPhoto()).delete();
  }

  // ANDROID CODE - THIS FUNCTION CALL WHEN VIEW INITIALIZE

  void loadPicturesFromDB() {
    // MainApplicationContext appContext = (MainApplicationContext) getApplicationContext();
    // ApplicationDao dao = appContext.getDao();

    // List<InspectionAttachment> picsFromDB = new ArrayList<InspectionAttachment>();

    // try {
    //     if (hasAttachmentIds) {
    //         List<Long> attachmentIds = AppInfo.attachmentIds;
    //         if (attachmentIds != null && !attachmentIds.isEmpty()) {
    //             for (int i = 0; i < attachmentIds.size(); i++) {
    //                 picsFromDB.add(dao.findAttachmentByAttachmentId(attachmentIds.get(i)));
    //             }
    //         }
    //     } else {
    //         picsFromDB = dao.findInspectionAttachmentsByInspectionId(inspectionId);
    //     }

    // } catch (Exception e) {
    //     e.printStackTrace();
    // }

    // if (picsFromDB != null && !picsFromDB.isEmpty()) {
    //     for (int i = 0; i < picsFromDB.size(); i++) {
    //         PictureData temp = new PictureData();
    //         temp.setData(picsFromDB.get(i).getAttachmentId(),
    //                 picsFromDB.get(i).getFileLocation(),
    //                 getPic(picsFromDB.get(i).getFileLocation()),
    //                 true);
    //         pictureList.add(temp);
    //     }
    // }
  }
}
