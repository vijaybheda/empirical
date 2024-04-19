import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';

class SpecialInstructions extends StatefulWidget {
  const SpecialInstructions({super.key});

  @override
  State<SpecialInstructions> createState() => _SpecialInstructionsState();
}

class _SpecialInstructionsState extends State<SpecialInstructions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.blue,
        title: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Image.asset(
              AppImages.appLogo,
              width: 90.w,
              height: 90.h,
            ),
            Text(
              "Special Instructions",
              style: GoogleFonts.poppins(
                  fontSize: 38.sp,
                  fontWeight: FontWeight.w600,
                  textStyle: TextStyle(color: AppColors.white)),
            ),
          ],
        ),
      ),
      body: bodyWidget(context),
    );
  }

  bodyWidget(BuildContext context) {
    return ListView.builder(
        itemCount: 10,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (context, position) {
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [Image.asset(AppImages.appLogo)],
          );
        });
  }
}
