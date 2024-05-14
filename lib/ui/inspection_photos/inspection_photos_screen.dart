import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/controller/inspection_photos_controller.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/components/header_content_view.dart';
import 'package:pverify/utils/app_const.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/buttons.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
import 'package:pverify/utils/theme/colors.dart';

class InspectionPhotos extends GetView<InspectionPhotosController> {
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

  const InspectionPhotos({
    super.key,
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
    this.callerActivity,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InspectionPhotosController>(
        init: InspectionPhotosController(),
        builder: (controller) {
          return WillPopScope(
            onWillPop: () async {
              controller.backAction(context);
              return true;
            },
            child: Scaffold(
              backgroundColor: Theme.of(context).colorScheme.background,
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                automaticallyImplyLeading: false,
                toolbarHeight: 150.h,
                backgroundColor: AppColors.primary,
                title: HeaderContentView(
                    title: controller.partnerName.toUpperCase()),
              ),
              body: Container(
                color: Theme.of(context).colorScheme.background,
                child: contentView(context, controller),
              ),
            ),
          );
        });
  }

  Widget contentView(
      BuildContext context, InspectionPhotosController controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(left: 40.w),
          color: AppColors.orange,
          width: ResponsiveHelper.getDeviceWidth(context),
          child: Text(
            controller.carrierName ?? '',
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
                  backgroundColor: AppColors.white,
                  title: AppStrings.savePhotosButton,
                  width: (MediaQuery.of(context).size.width / 3.5),
                  height: 115,
                  fontStyle: GoogleFonts.poppins(
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
                  backgroundColor: AppColors.white,
                  title: AppStrings.openPhotosButton,
                  width: (MediaQuery.of(context).size.width / 3.5),
                  height: 115,
                  fontStyle: GoogleFonts.poppins(
                      fontSize: 35.sp,
                      fontWeight: FontWeight.w600,
                      textStyle:
                          TextStyle(color: AppColors.textFieldText_Color)),
                  onClickAction: () async {
                    await controller.getImageFromGallery();
                  }),
              SizedBox(
                width: 38.w,
              ),
              customButton(
                  backgroundColor: AppColors.white,
                  title: AppStrings.takePhotoButton,
                  width: (MediaQuery.of(context).size.width / 3.5),
                  height: 115,
                  fontStyle: GoogleFonts.poppins(
                      fontSize: 35.sp,
                      fontWeight: FontWeight.w600,
                      textStyle:
                          TextStyle(color: AppColors.textFieldText_Color)),
                  onClickAction: () async {
                    await controller.getImageFromCamera();
                  }),
            ],
          ),
        ),
        FooterContentView(
          onBackTap: () {
            controller.backAction(context);
          },
        )
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
                            onYesTap: () async {
                              await controller.deletePicture(rowIndex);
                              controller.removeImage(rowIndex);
                            },
                          );
                        },
                        child: Text(
                          AppStrings.delete,
                          style: TextStyle(color: AppColors.textBlue),
                        )),
                    TextButton(
                        onPressed: () async {
                          await controller.cropImage(
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
