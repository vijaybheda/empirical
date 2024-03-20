import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:pverify/controller/auth_controller.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/header/header.dart';
import 'package:pverify/utils/theme/colors.dart';

class Home extends GetView<AuthController> {
  Home({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: AuthController(),
        builder: (authController) {
          return Scaffold(
              backgroundColor: AppColors.textBody,
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                automaticallyImplyLeading: false,
                toolbarHeight: 150.h,
                backgroundColor: AppColors.primary,
                title: baseHeaderView(AppStrings.home, false),
              ));
        });
  }

  Widget contentView() {
    return Column();
  }

  Widget bottomContent() {
    return Container(
      height: 150.h,
      color: AppColors.primary,
    );
  }
}
