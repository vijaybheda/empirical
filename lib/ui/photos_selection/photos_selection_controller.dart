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
}
