import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/inspection_photos_controller.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/components/header_content_view.dart';
import 'package:pverify/utils/app_const.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/buttons.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
import 'package:pverify/utils/theme/colors.dart';

class InspectionPhotos extends GetView<InspectionPhotosController> {
  final String? tag;

  const InspectionPhotos({
    super.key,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InspectionPhotosController>(
        init: InspectionPhotosController(),
        tag: tag,
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
            controller.commodityName ?? '',
            style: Get.textTheme.titleLarge!.copyWith(
              fontSize: 35.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
            child: Padding(
          padding: EdgeInsets.all(30.w),
          child: Obx(() => photosListView(controller)),
        )),
        if (!controller.isViewOnlyMode)
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
                    fontStyle: Get.textTheme.titleLarge!.copyWith(
                      fontSize: 35.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textFieldText_Color,
                    ),
                    onClickAction: () async {
                      await controller.saveAction();
                    }),
                SizedBox(
                  width: 38.w,
                ),
                customButton(
                    backgroundColor: AppColors.white,
                    title: AppStrings.openPhotosButton,
                    width: (MediaQuery.of(context).size.width / 3.5),
                    height: 115,
                    fontStyle: Get.textTheme.titleLarge!.copyWith(
                      fontSize: 35.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textFieldText_Color,
                    ),
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
                    fontStyle: Get.textTheme.titleLarge!.copyWith(
                      fontSize: 35.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textFieldText_Color,
                    ),
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

  Widget photosListView(InspectionPhotosController controller) {
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
                          style: TextStyle(
                            color: AppColors.textBlue,
                          ),
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
