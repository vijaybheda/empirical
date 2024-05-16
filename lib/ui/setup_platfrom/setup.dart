// ignore_for_file: non_constant_identifier_names, avoid_types_as_parameter_names, prefer_const_constructors, must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/setup_controller.dart';
import 'package:pverify/ui/components/header_content_view.dart';
import 'package:pverify/utils/app_const.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/buttons.dart';
import 'package:pverify/utils/common_widget/textfield/text_fields.dart';
import 'package:pverify/utils/theme/colors.dart';

class SetupScreen extends GetView<SetupController> {
  SetupScreen({super.key});

  SetupController setupController = SetupController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: SetupController(),
        builder: (Controller) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 150.h,
              backgroundColor: AppColors.primary,
              title: HeaderContentView(
                  title: AppStrings.setup, isVersionShow: false),
            ),
            body: Container(
              width: ResponsiveHelper.getDeviceWidth(context),
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: 50.h,
                      ),
                      commonRowView(context, AppStrings.banner1Url,
                          controller.banner1TextController.value),
                      SizedBox(
                        height: 40.h,
                      ),
                      commonRowView(context, AppStrings.banner2Url,
                          controller.banner2TextController.value),
                      SizedBox(
                        height: 40.h,
                      ),
                      commonRowView(context, AppStrings.serverUrl,
                          controller.banner3TextController.value),
                      SizedBox(
                        height: 40.h,
                      ),
                      commonRowView(context, AppStrings.dateFormat,
                          controller.banner3TextController.value,
                          isDropdown: true),
                    ],
                  ),
                  SizedBox(
                    height: 70.h,
                  ),
                  customButton(
                      backgroundColor: AppColors.primary,
                      title: AppStrings.save.toUpperCase(),
                      width: double.infinity,
                      height: 90,
                      fontStyle: Get.textTheme.titleLarge!.copyWith(
                        fontSize: 25.sp,
                      ),
                      onClickAction: () => {
                            if (Controller.isSetupFieldsValidate(context))
                              {debugPrint('All Fields Are Validate')}
                          }),
                  SizedBox(
                    height: 40.h,
                  ),
                  customButton(
                      backgroundColor: AppColors.primary,
                      title: AppStrings.checkForUpdate.toUpperCase(),
                      width: double.infinity,
                      height: 90,
                      fontStyle: Get.textTheme.titleLarge!.copyWith(
                        fontSize: 25.sp,
                      ),
                      onClickAction: () => {}),
                  SizedBox(
                    height: 40.h,
                  ),
                  customButton(
                      backgroundColor: AppColors.graniteGray,
                      title: AppStrings.cacheForOfflineUse.toUpperCase(),
                      width: double.infinity,
                      height: 90,
                      fontStyle: Get.textTheme.titleLarge!.copyWith(
                        fontSize: 25.sp,
                      ),
                      onClickAction: () => {}),
                ],
              ),
            ),
          );
        });
  }

  Widget commonRowView(
      BuildContext context, String labelTitle, TextEditingController controller,
      {bool isDropdown = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            labelTitle,
            style: Get.textTheme.titleLarge!.copyWith(
              fontSize: 30.sp,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: isDropdown
              ? Obx(
                  () => DropdownButtonFormField<String>(
                    decoration: InputDecoration(border: InputBorder.none),
                    dropdownColor: Theme.of(context).colorScheme.background,
                    iconEnabledColor: AppColors.hintColor,
                    hint: Text(
                      'Select DateFormat',
                      style: Get.textTheme.titleLarge!.copyWith(
                        color: AppColors.sky,
                        fontSize: 30.sp,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    items: setupController.dateformats.map((selectedType) {
                      return DropdownMenuItem<String>(
                        value: selectedType,
                        child: Text(
                          selectedType,
                          style: Get.textTheme.titleLarge!.copyWith(
                            color: AppColors.sky,
                            fontSize: 30.sp,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                    value: setupController.selectetdDateFormat.value,
                    onChanged: (newValue) {
                      setupController.setSelected(newValue ?? '');
                    },
                  ),
                )
              : BoxTextField1(
                  isMulti: false,
                  controller: controller,
                  onTap: () {},
                  errorText: '',
                  onEditingCompleted: () {
                    FocusScope.of(context).unfocus();
                  },
                  onChanged: (value) {},
                  keyboardType: TextInputType.name,
                  hintText: labelTitle,
                  isPasswordField: true,
                ),
        ),
      ],
    );
  }
}
