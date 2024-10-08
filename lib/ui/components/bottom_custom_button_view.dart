import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/utils/theme/colors.dart';

class BottomCustomButtonView extends StatelessWidget {
  final Function()? onPressed;
  final String title;
  final Color? backgroundColor;

  const BottomCustomButtonView({
    super.key,
    this.onPressed,
    required this.title,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? AppColors.hintColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: TextButton(
              onPressed: () async {
                onPressed!();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(AppColors.white),
                padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                minimumSize: MaterialStateProperty.all(Size(.8.sw, .07.sw)),
              ),
              child: Text(title,
                  style: Get.textTheme.titleLarge!.copyWith(
                      color: AppColors.textFieldText_Color,
                      fontSize: 30.sp,
                      fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}
