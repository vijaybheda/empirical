import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/dialogs/user_logout.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';
import 'package:pverify/utils/utils.dart';

class SideDrawer extends StatelessWidget {
  final Function onDefectSaveAndCompleteTap;
  final Function onDiscardTap;
  final Function onCameraTap;
  final Function onSpecInstructionTap;
  final Function onSpecificationTap;
  final Function onGradeTap;
  final Function onInspectionTap;
  final bool isSpecialInstructionTextVisible;
  SideDrawer({
    super.key,
    required this.onDefectSaveAndCompleteTap,
    required this.onDiscardTap,
    required this.onCameraTap,
    required this.onSpecInstructionTap,
    required this.onSpecificationTap,
    required this.onGradeTap,
    required this.onInspectionTap,
    this.isSpecialInstructionTextVisible = false,
  });

  final GlobalConfigController globalConfigController =
      Get.find<GlobalConfigController>();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      elevation: 10,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primary,
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.primary.withOpacity(0.5),
                  AppColors.primary,
                ],
              ),
            ),
            curve: Curves.easeIn,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  fit: BoxFit.contain,
                  AppImages.appLogo,
                  width: 150.w,
                  height: 150.h,
                ),
                Text(
                    '${AppStrings.appNameInspection}\n${AppStrings.version.capitalizeFirst} ${globalConfigController.appVersion.value}',
                    style: Get.textTheme.headlineLarge),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.build),
            title: Text(
              AppStrings.defectSaveAndComplete,
              style: Get.textTheme.bodyLarge!.copyWith(
                fontSize: 26.sp,
              ),
            ),
            onTap: () {
              Get.back();
              onDefectSaveAndCompleteTap();
            },
          ),
          ListTile(
            leading: const Icon(Icons.build),
            title: Text(
              AppStrings.defectDiscard,
              style: Get.textTheme.bodyLarge!.copyWith(
                fontSize: 26.sp,
              ),
            ),
            onTap: () {
              Get.back();
              onDiscardTap();
            },
          ),
          const Divider(
            indent: 0,
            endIndent: 0,
          ),
          _titleText(AppStrings.inspectionPhotoHeading),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: Text(
              AppStrings.camera,
              style: Get.textTheme.bodyLarge!.copyWith(
                fontSize: 26.sp,
              ),
            ),
            onTap: () {
              Get.back();
              onCameraTap();
            },
          ),
          const Divider(
            indent: 0,
            endIndent: 0,
          ),
          _titleText(AppStrings.referencesHeading),
          ListTile(
            leading: const Icon(Icons.edit_document),
            title: Text(
              isSpecialInstructionTextVisible
                  ? AppStrings.specException
                  : AppStrings.specInstrunction,
              style: Get.textTheme.bodyLarge!.copyWith(
                fontSize: 26.sp,
              ),
            ),
            onTap: () {
              Get.back();
              onSpecInstructionTap();
            },
          ),
          ListTile(
            leading: Image.asset(
              fit: BoxFit.contain,
              AppImages.appLogo,
              width: 24,
              height: 24,
            ),
            title: Text(
              AppStrings.specification,
              style: Get.textTheme.bodyLarge!.copyWith(
                fontSize: 26.sp,
              ),
            ),
            onTap: () {
              Get.back();
              onSpecificationTap();
            },
          ),
          ListTile(
            leading: const Icon(Icons.grade),
            title: Text(
              AppStrings.grade,
              style: Get.textTheme.bodyLarge!.copyWith(
                fontSize: 26.sp,
              ),
            ),
            onTap: () {
              Get.back();
              onGradeTap();
            },
          ),
          ListTile(
            leading: const Icon(Icons.fact_check_outlined),
            title: Text(
              AppStrings.inspectionAndroid,
              style: Get.textTheme.bodyLarge!.copyWith(
                fontSize: 26.sp,
              ),
            ),
            onTap: () {
              Get.back();
              onInspectionTap();
            },
          ),
          const Divider(
            indent: 0,
            endIndent: 0,
          ),
          _titleText(AppStrings.connectionHeading),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(
              AppStrings.logOut,
              style: Get.textTheme.bodyLarge!.copyWith(
                fontSize: 26.sp,
              ),
            ),
            onTap: () {
              Get.back();
              UserLogoutDialog.showLogoutConfirmation(context,
                  onYesTap: () async {
                Utils.showLoadingDialog();
                await globalConfigController.appLogoutAction(
                  onSuccess: () {
                    Utils.hideLoadingDialog();
                  },
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Container _titleText(String title) {
    return Container(
      padding: const EdgeInsets.only(left: 16, top: 10),
      child: Text(
        title,
        style: Get.textTheme.bodyLarge!
            .copyWith(fontSize: 26.sp, color: AppColors.lightGrey),
      ),
    );
  }
}
