// ignore_for_file: unnecessary_new, sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/controller/auth_controller.dart';
import 'package:pverify/ui/Setup%20Platfrom/Setup_Controller.dart';
import 'package:pverify/utils/Common%20Widget/Buttons.dart';
import 'package:pverify/utils/Common%20Widget/Header.dart';
import 'package:pverify/utils/Common%20Widget/Common%20TextField/textFields.dart';
import 'package:pverify/utils/app_const.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/strings.dart';
import 'package:pverify/utils/theme/colors.dart';

class SetupScreen extends GetView<SetupController> {
  SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: SetupController(),
        builder: (SetupController) {
          return Scaffold(
            backgroundColor: AppColors.white,
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 150.h,
              backgroundColor: AppColors.primary,
              title: baseHeaderView(Appstrings.Setup, false),
            ),
            body: Container(
              width: ResponsiveHelper.getDeviceWidth(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: 50.h,
                      ),
                      commonRowView(Appstrings.Banner1,
                          controller.banner1TextController.value),
                      SizedBox(
                        height: 40.h,
                      ),
                      commonRowView(Appstrings.Banner2,
                          controller.banner2TextController.value),
                      SizedBox(
                        height: 40.h,
                      ),
                      commonRowView(Appstrings.Server_URL,
                          controller.banner3TextController.value),
                      SizedBox(
                        height: 40.h,
                      ),
                      commonRowView(Appstrings.Date_Format,
                          controller.banner3TextController.value,
                          isDropdown: true),
                    ],
                  ),
                  SizedBox(
                    height: 70.h,
                  ),
                  customButton(
                      AppColors.primary, Appstrings.SAVE, double.infinity, 90,
                      onClickAction: () => {}),
                  SizedBox(
                    height: 40.h,
                  ),
                  customButton(AppColors.primary, Appstrings.CHECK_FOR_UPDATE,
                      double.infinity, 90,
                      onClickAction: () => {}),
                  SizedBox(
                    height: 40.h,
                  ),
                  customButton(
                      AppColors.graniteGray,
                      Appstrings.CACHE_ALL_DATA_FOR_OFFLINE_USE,
                      double.infinity,
                      90,
                      onClickAction: () => {}),
                ],
              ),
              padding: EdgeInsets.only(left: 20, right: 20),
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
              ? DropdownButton<String>(
                  items: <String>['A', 'B', 'C', 'D'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (_) {},
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
