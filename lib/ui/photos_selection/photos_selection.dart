import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/components/header_content_view.dart';
import 'package:pverify/ui/photos_selection/photos_selection_controller.dart';
import 'package:pverify/utils/app_const.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/buttons.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
import 'package:pverify/utils/theme/colors.dart';

class PhotosSelection extends GetView<PhotoSelectionController> {
  final String? partnerName;
  final String? partnerID;
  final String? carrierName;
  final String? carrierID;
  final String? commodityName;
  final int? commodityID;
  final String? varietyName;
  final String? varietySize;
  final String? varietyId;
  final bool? isViewOnlyMode;
  final int? inspectionId;
  final String? callerActivity;
  const PhotosSelection(
      {super.key,
      this.partnerName,
      this.partnerID,
      this.carrierName,
      this.carrierID,
      this.commodityName,
      this.commodityID,
      this.varietyName,
      this.varietySize,
      this.varietyId,
      this.isViewOnlyMode,
      this.inspectionId,
      this.callerActivity});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PhotoSelectionController>(
        init: PhotoSelectionController(),
        builder: (controller) {
          controller.inspectionId = inspectionId;
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 150.h,
              backgroundColor: AppColors.primary,
              title: HeaderContentView(title: AppStrings.trailerTempRange),
            ),
            body: Container(
              color: Theme.of(context).colorScheme.background,
              child: contentView(context, controller),
            ),
          );
        });
  }

  Widget contentView(
      BuildContext context, PhotoSelectionController controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(left: 40.w),
          color: AppColors.orange,
          height: 70.h,
          width: ResponsiveHelper.getDeviceWidth(context),
          child: Text(
            'Cheese',
            style: GoogleFonts.poppins(
                fontSize: 35.sp,
                fontWeight: FontWeight.w600,
                textStyle: TextStyle(color: AppColors.white)),
          ),
        ),
        Expanded(
            child: Padding(
          padding: EdgeInsets.all(30.w),
          child: Obx(() => photosListView()),
        )),
        Container(
          padding: EdgeInsets.only(left: 35.w, right: 35.w),
          height: 150.h,
          color: AppColors.primaryColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              customButton(
                  AppColors.white,
                  AppStrings.savePhotosButton,
                  (MediaQuery.of(context).size.width / 3.5),
                  115,
                  GoogleFonts.poppins(
                      fontSize: 35.sp,
                      fontWeight: FontWeight.w600,
                      textStyle:
                          TextStyle(color: AppColors.textFieldText_Color)),
                  onClickAction: () {
                controller.saveAction();
              }),
              SizedBox(
                width: 38.w,
              ),
              customButton(
                  AppColors.white,
                  AppStrings.openPhotosButton,
                  (MediaQuery.of(context).size.width / 3.5),
                  115,
                  GoogleFonts.poppins(
                      fontSize: 35.sp,
                      fontWeight: FontWeight.w600,
                      textStyle:
                          TextStyle(color: AppColors.textFieldText_Color)),
                  onClickAction: () => {controller.getImageFromGallery()}),
              SizedBox(
                width: 38.w,
              ),
              customButton(
                  AppColors.white,
                  AppStrings.takePhotoButton,
                  (MediaQuery.of(context).size.width / 3.5),
                  115,
                  GoogleFonts.poppins(
                      fontSize: 35.sp,
                      fontWeight: FontWeight.w600,
                      textStyle:
                          TextStyle(color: AppColors.textFieldText_Color)),
                  onClickAction: () => {controller.getImageFromCamera()}),
            ],
          ),
        ),
        FooterContentView()
      ],
    );
  }

  Widget photosListView() {
    return GridView.builder(
      itemCount: controller.imagesList.length, // Number of rows
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 30.0.w,
          mainAxisSpacing: 30.0.w,
          childAspectRatio: 0.90),
      itemBuilder: (BuildContext context, int rowIndex) {
        return Container(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          alignment: Alignment.topCenter,
          color: AppColors.lightGrey,
          child: Column(
            children: [
              Expanded(
                child: Image.file(
                    fit: BoxFit.contain,
                    File(controller.imagesList[rowIndex].image?.path ?? '')),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 80.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                        onPressed: () {
                          AppAlertDialog.confirmationAlert(
                            context,
                            '',
                            AppStrings.pictureMessage,
                            onYesTap: () {
                              controller.removeImage(rowIndex);
                            },
                          );
                        },
                        child: Text(
                          AppStrings.delete,
                          style: TextStyle(color: AppColors.textBlue),
                        )),
                    TextButton(
                        onPressed: () {
                          controller.cropImage(
                              File(
                                  controller.imagesList[rowIndex].image?.path ??
                                      ''),
                              rowIndex);
                        },
                        child: Text(AppStrings.crop,
                            style: TextStyle(color: AppColors.textBlue))),
                    TextButton(
                        onPressed: () {
                          AppAlertDialog.textfiAlert(
                            context,
                            AppStrings.inspectionPhotoTitle,
                            '',
                            onYesTap: (b) {
                              controller.updateContent(rowIndex, b.toString());
                            },
                          );
                        },
                        child: Text(AppStrings.title,
                            style: TextStyle(color: AppColors.textBlue))),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
