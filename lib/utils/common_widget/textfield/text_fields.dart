// ignore_for_file: prefer_const_constructors, unnecessary_this, must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/utils/common_widget/textfield/textfield_controller.dart';
import 'package:pverify/utils/theme/colors.dart';
import 'package:get/state_manager.dart';
import 'package:pverify/utils/theme/theme.dart';

class BoxTextFieldLogin extends StatelessWidget {
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

  BoxTextFieldLogin(
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
        init: TextFieldController(),
        builder: (pwdController) {
          return Container(
            alignment: Alignment.center,
            height: 105.h,
            child: TextFormField(
              autofillHints: !isPasswordField
                  ? [AutofillHints.username]
                  : [AutofillHints.password],
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
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
  final Color? textColor;
  final Color? hintColor;
  final TextEditingController? controller;
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
  final String? intialValue;

  const BoxTextField1({
    Key? key,
    this.textColor = Colors.white,
    this.hintColor = Colors.grey,
    this.controller,
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
    required this.onChanged,
    this.intialValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 105.h,
      child: TextFormField(
        initialValue: intialValue,
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
            fontSize: 32.sp,
            fontWeight: FontWeight.w400,
            textStyle: TextStyle(color: textColor)),
        cursorColor: Theme.of(context).textSelectionTheme.cursorColor,
        decoration: InputDecoration(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.hintColor),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
              fontSize: 32.sp,
              fontWeight: FontWeight.w400,
              textStyle: TextStyle(color: hintColor)),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
        ),
      ),
    );
    return GetBuilder(
        init: TextFieldController(),
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
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w400,
                  textStyle: TextStyle(color: textColor)),
              cursorColor: Theme.of(context).textSelectionTheme.cursorColor,
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.hintColor),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                hintText: hintText,
                hintStyle: GoogleFonts.poppins(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w400,
                    textStyle: TextStyle(color: hintColor)),
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

class BoxTextField2 extends StatelessWidget {
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
  final FocusNode focusNode;

  const BoxTextField2(
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
      required this.onChanged,
      required this.focusNode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: TextFieldController(),
        builder: (pwdController) {
          return Container(
            alignment: Alignment.center,
            height: 105.h,
            child: TextFormField(
              onFieldSubmitted: (value) {
                debugPrint('Submitted');
              },
              maxLength: 3,
              focusNode: focusNode,
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
                  fontSize: 28.sp,
                  fontWeight: FontWeight.normal,
                  textStyle: TextStyle(color: AppColors.white)),
              cursorColor: Theme.of(context).textSelectionTheme.cursorColor,
              decoration: InputDecoration(
                counterText: "",
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.hintColor),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                hintText: hintText,
                hintStyle: GoogleFonts.poppins(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.normal,
                    textStyle: TextStyle(color: AppColors.hintColor)),
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
