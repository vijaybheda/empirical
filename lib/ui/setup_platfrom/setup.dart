// ignore_for_file: non_constant_identifier_names, avoid_types_as_parameter_names, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/ui/setup_platfrom/setup_controller.dart';
import 'package:pverify/utils/app_const.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/buttons.dart';
import 'package:pverify/utils/common_widget/header/header.dart';
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
            backgroundColor: AppColors.white,
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 150.h,
              backgroundColor: AppColors.primary,
              title: baseHeaderView(AppStrings.setup, false),
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
                      commonRowView(AppStrings.banner1Url,
                          controller.banner1TextController.value),
                      SizedBox(
                        height: 40.h,
                      ),
                      commonRowView(AppStrings.banner2Url,
                          controller.banner2TextController.value),
                      SizedBox(
                        height: 40.h,
                      ),
                      commonRowView(AppStrings.serverUrl,
                          controller.banner3TextController.value),
                      SizedBox(
                        height: 40.h,
                      ),
                      commonRowView(AppStrings.dateFormat,
                          controller.banner3TextController.value,
                          isDropdown: true),
                    ],
                  ),
                  SizedBox(
                    height: 70.h,
                  ),
                  customButton(AppColors.primary, AppStrings.save.toUpperCase(),
                      double.infinity, 90,
                      onClickAction: () => {
                            if (Controller.isSetupFieldsValidate())
                              {debugPrint('All Fields Are Validate')}
                          }),
                  SizedBox(
                    height: 40.h,
                  ),
                  customButton(
                      AppColors.primary,
                      AppStrings.checkForUpdate.toUpperCase(),
                      double.infinity,
                      90,
                      onClickAction: () => {}),
                  SizedBox(
                    height: 40.h,
                  ),
                  customButton(
                      AppColors.graniteGray,
                      AppStrings.cacheForOfflineUse.toUpperCase(),
                      double.infinity,
                      90,
                      onClickAction: () => {}),
                ],
              ),
            ),
          );
        });
  }

  Widget commonRowView(String labelTitle, TextEditingController controller,
      {bool isDropdown = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            labelTitle,
            style: GoogleFonts.poppins(
                fontSize: 30.sp,
                fontWeight: FontWeight.normal,
                textStyle: TextStyle(color: AppColors.textFieldText_Color)),
          ),
        ),
        Expanded(
          flex: 2,
          child: isDropdown
              ? Obx(
                  () => DropdownButtonFormField<String>(
                    decoration: InputDecoration(border: InputBorder.none),
                    dropdownColor: AppColors.white,
                    hint: Text(
                      'Select DateFormat',
                      style: GoogleFonts.poppins(
                          fontSize: 30.sp,
                          fontWeight: FontWeight.normal,
                          textStyle: TextStyle(color: AppColors.sky)),
                    ),
                    items: setupController.dateformats.map((selectedType) {
                      return DropdownMenuItem<String>(
                        value: selectedType,
                        child: Text(
                          selectedType,
                          style: GoogleFonts.poppins(
                              fontSize: 30.sp,
                              fontWeight: FontWeight.normal,
                              textStyle: TextStyle(color: AppColors.sky)),
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
                  onEditingCompleted: () {},
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
