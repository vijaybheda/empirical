import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';

class SpecialInstructions extends StatefulWidget {
  final List<Map<String, String>> exceptionCollection;
  const SpecialInstructions({super.key, required this.exceptionCollection});

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
      body: bodyWidget(context, widget.exceptionCollection),
    );
  }

  bodyWidget(
      BuildContext context, List<Map<String, String>> exceptionCollection) {
    return ListView.builder(
        itemCount: 10,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (context, position) {
          return GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Column(
              children: [
                SizedBox(
                  height: 15.h,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Image.asset(
                      AppImages.ic_special_instruction,
                      width: 150.w,
                      height: 150.h,
                    ),
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Deviation",
                            style: GoogleFonts.poppins(
                                fontSize: 42.sp,
                                fontWeight: FontWeight.bold,
                                textStyle: TextStyle(color: AppColors.black)),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Text(
                            "Any Deviation to be Submitted and approved by sourcing",
                            style: GoogleFonts.poppins(
                                fontSize: 30.sp,
                                fontWeight: FontWeight.normal,
                                textStyle: TextStyle(color: AppColors.black)),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 15.h,
                )
              ],
            ),
          );
        });
  }
}
