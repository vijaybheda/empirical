import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/utils/common_widget/text_field/box_text_fieldcontroller.dart';
import 'package:pverify/utils/theme/colors.dart';
import 'package:get/state_manager.dart';
import 'package:pverify/utils/theme/theme.dart';

class BoxTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool obsecure;
  final bool readOnly;
  final VoidCallback onTap;
  final VoidCallback onEditingCompleted;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;
  final bool isMulti;
  final bool autofocus;
  final bool enabled;
  final String errorText;
  final String hintText;
  final bool isPasswordField;

  BoxTextField(
      {Key? key,
        required this.controller,
        this.keyboardType = TextInputType.text,
        this.obsecure = false,
        required this.onTap,
        this.isMulti = false,
        this.readOnly = false,
        this.hintText = "",
        this.autofocus = false,
        required this.errorText,
        this.enabled = true,
        this.isPasswordField = false,
        required this.onEditingCompleted,
        required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: BoxTextFieldController(),
        builder: (pwdController) {
          return Container(
            alignment: Alignment.center,
            height: 105.h,
            child: TextFormField(
              textAlignVertical: TextAlignVertical.center,
              onChanged: onChanged,
              onEditingComplete: onEditingCompleted,
              autofocus: autofocus,
              minLines: isMulti ? 4 : 1,
              maxLines: isMulti ? null : 1,
              onTap: onTap,
              enabled: enabled,
              readOnly: readOnly,
              obscureText: isPasswordField
                  ? pwdController.showPassword.value
                  ? false
                  : true
                  : false,
              keyboardType: keyboardType,
              controller: controller,
              style: TextStyle(color: AppColors.textFieldText_Color),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: AppColors.textFieldText_Color),
                border: InputBorder.none,
                isDense: true,
                contentPadding:
                EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                suffixIcon: isPasswordField
                    ? GestureDetector(
                  onTap: () => pwdController.changePwdVisibility(),
                  child: Icon(
                    size: 22,
                    pwdController.showPassword.value
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: AppColors.black,
                  ),
                )
                    : null,
              ),
            ),
          );
        });
  }

  textFieldfocused() {}
  errorrTextFieldBorder() {}
}

class BoxTextField1 extends StatelessWidget {
  final TextEditingController controller;
  final bool obsecure;
  final bool readOnly;
  final VoidCallback onTap;
  final VoidCallback onEditingCompleted;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;
  final bool isMulti;
  final bool autofocus;
  final bool enabled;
  final String errorText;
  final String hintText;
  final bool isPasswordField;

  BoxTextField1(
      {Key? key,
        required this.controller,
        this.keyboardType = TextInputType.text,
        this.obsecure = false,
        required this.onTap,
        this.isMulti = false,
        this.readOnly = false,
        this.hintText = "",
        this.autofocus = false,
        required this.errorText,
        this.enabled = true,
        this.isPasswordField = false,
        required this.onEditingCompleted,
        required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: BoxTextFieldController(),
        builder: (pwdController) {
          return Container(
            alignment: Alignment.center,
            height: 105.h,
            child: TextFormField(
              textAlignVertical: TextAlignVertical.center,
              onChanged: onChanged,
              onEditingComplete: onEditingCompleted,
              autofocus: autofocus,
              minLines: isMulti ? 4 : 1,
              maxLines: isMulti ? null : 1,
              onTap: onTap,
              enabled: enabled,
              readOnly: readOnly,
              keyboardType: keyboardType,
              controller: controller,
              style: GoogleFonts.poppins(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.normal,
                  textStyle: TextStyle(color: AppColors.textFieldText_Color)),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.black),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.red),
                ),
                hintText: hintText,
                hintStyle: GoogleFonts.poppins(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.normal,
                    textStyle: TextStyle(color: AppColors.textFieldText_Color)),
                border: InputBorder.none,
                isDense: true,
                contentPadding:
                EdgeInsets.symmetric(horizontal: 0, vertical: 5),
              ),
            ),
          );
        });
  }

  textFieldfocused() {}
  errorrTextFieldBorder() {}
}
