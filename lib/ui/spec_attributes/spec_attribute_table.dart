import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/specification_attributes_controller.dart';
import 'package:pverify/models/specification_analytical.dart';
import 'package:pverify/models/specification_analytical_request_item.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';

class SpecAttributeTable extends GetWidget<SpecificationAttributesController> {
  final String uniqueTag;
  const SpecAttributeTable({
    super.key,
    required this.uniqueTag,
  });

  @override
  Widget build(BuildContext context) {
    SpecificationAttributesController controller =
        Get.find<SpecificationAttributesController>(tag: uniqueTag);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.listSpecAnalyticals.length,
      itemBuilder: (context, index) {
        SpecificationAnalytical item = controller.listSpecAnalyticals[index];
        SpecificationAnalyticalRequest reqobj =
            controller.listSpecAnalyticalsRequest[index];
        SpecificationAnalyticalRequest? dbobj = controller.dbobjList[index];

        return SpecificationAnalyticalWidget(
            controller: controller,
            item: item,
            index: index,
            reqobj: reqobj,
            dbobj: dbobj,
            onCommentSave: (String comment) {
              reqobj.comment ??= '';
              reqobj.comment = comment;
              reqobj = reqobj.copyWith(comment: comment);
              controller.listSpecAnalyticalsRequest[index] = reqobj;
              if (dbobj != null) {
                dbobj?.comment ??= '';
                dbobj?.comment = comment;
                dbobj = dbobj?.copyWith(comment: comment);
              }
              controller.update();
              controller.listSpecAnalyticalsRequest[index] = reqobj;
            },
            onComplySave: (String comply) {
              reqobj.comply ??= '';
              reqobj.comply = comply;
              reqobj = reqobj.copyWith(comply: comply);
              controller.listSpecAnalyticalsRequest[index] = reqobj;
              if (dbobj != null) {
                dbobj?.comply ??= '';
                dbobj?.comply = comply;
                dbobj = dbobj?.copyWith(comply: comply);
              }
              controller.update();
              controller.listSpecAnalyticalsRequest[index] = reqobj;
            });
      },
    );
  }
}

class SpecificationAnalyticalWidget extends StatefulWidget {
  final SpecificationAnalytical item;
  final SpecificationAnalyticalRequest reqobj;
  final Function(String comment)? onCommentSave;
  final Function(String comply)? onComplySave;
  final SpecificationAttributesController controller;
  final SpecificationAnalyticalRequest? dbobj;
  final int index;

  const SpecificationAnalyticalWidget({
    super.key,
    required this.item,
    required this.reqobj,
    this.onCommentSave,
    this.onComplySave,
    required this.controller,
    this.dbobj,
    required this.index,
  });

  @override
  State<SpecificationAnalyticalWidget> createState() =>
      _SpecificationAnalyticalWidgetState();
}

class _SpecificationAnalyticalWidgetState
    extends State<SpecificationAnalyticalWidget> {
  String comply = 'Y';
  late bool hasErrors;
  bool isPictureRequired = false;
  List<String> operatorList = [];
  final ApplicationDao dao = ApplicationDao();
  String spinner_value = 'Yes';

  TextEditingController editTextValue = TextEditingController();

  bool hasErrors2 = false;
  late SpecificationAnalyticalRequest reqobj;
  SpecificationAnalyticalRequest? dbobj;

  @override
  void initState() {
    reqobj = widget.reqobj.copyWith();
    comply = "Y";
    spinner_value = "Yes";
    operatorList = ['Select', 'Yes', 'No', 'N/A'];

    if (widget.dbobj != null) {
      dbobj = widget.dbobj!.copyWith();
      reqobj.comply = dbobj?.comply;
      comply = dbobj?.comply ?? '';
    } else {
      reqobj.comply = "N/A";
      comply = "N/A";
    }
    hasErrors = false;
    spinner_value = operatorList.elementAt(0);

    widget.controller.listSpecAnalyticalsRequest[widget.index] = reqobj;
    spinner_value = operatorList.first;

    unawaited(() async {
      initSetup();
    }());
    super.initState();
  }

  void initSetup() {
    if (widget.item.specTargetTextDefault == "Y") {
      comply = "Y";
      spinner_value = operatorList.elementAt(1);
    } else if (widget.item.specTargetTextDefault == "N") {
      comply = "Y";
      spinner_value = operatorList.elementAt(2);
    } else if (widget.item.specTargetTextDefault == "") {
      operatorList.removeWhere((element) => ("N/A" == element));
      spinner_value = operatorList.elementAt(0);
    } else if (widget.item.specTargetTextDefault == "N/A") {
      comply = "N/A";
      spinner_value = operatorList.elementAt(3);
    }

    if (widget.item.analyticalName?.contains("Branded") ?? false) {
      comply = "Y";
      spinner_value = operatorList.elementAt(2);
    }

    if (widget.item.specTypeofEntry == 1) {
      if (dbobj != null) {
        reqobj = reqobj.copyWith(sampleNumValue: dbobj?.sampleNumValue);
        widget.controller.listSpecAnalyticalsRequest[widget.index] = reqobj;
        if (dbobj?.sampleNumValue != null) {
          editTextValue.text = (dbobj!.sampleNumValue!).toString();
        }
        if (dbobj?.comply != null) {
          comply = dbobj!.comply!;
        }
      }
    } else if (widget.item.specTypeofEntry == 2) {
      if (dbobj != null) {
        for (int i = 0; i < operatorList.length; i++) {
          if (dbobj?.sampleTextValue == operatorList[i]) {
            spinner_value = operatorList.elementAt(i);
            reqobj = reqobj.copyWith(sampleTextValue: operatorList[i]);
            comply = dbobj!.comply!;
            widget.controller.listSpecAnalyticalsRequest[widget.index] = reqobj;
          }
        }
      }
    } else if (widget.item.specTypeofEntry == 3) {
      if (dbobj != null) {
        reqobj = reqobj.copyWith(
          sampleNumValue: dbobj?.sampleNumValue,
        );
        widget.controller.listSpecAnalyticalsRequest[widget.index] = reqobj;
        if (dbobj?.sampleNumValue != null) {
          editTextValue.text = dbobj!.sampleNumValue.toString();
        }

        for (int i = 0; i < operatorList.length; i++) {
          if (dbobj?.sampleTextValue == operatorList[i]) {
            spinner_value = operatorList.elementAt(i);
            reqobj = reqobj.copyWith(sampleTextValue: operatorList[i]);
            if (dbobj?.comply != null) {
              comply = dbobj!.comply!;
            }
            widget.controller.listSpecAnalyticalsRequest[widget.index] = reqobj;
          }
        }
      }
    }

    if (widget.item.specTypeofEntry == 1 || widget.item.specTypeofEntry == 3) {
      String editfield = editTextValue.text;
      if (editfield.isEmpty) {
        hasErrors2 = true;
      }
    }

    onDropdownChanged(spinner_value, hasChanged: false);
    Future.delayed(const Duration(milliseconds: 200)).then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    _itemHeight = 150.h;
    bool hasTextField =
        (widget.item.specTypeofEntry == 1 || widget.item.specTypeofEntry == 3);
    bool hasDropDown =
        (widget.item.specTypeofEntry == 2 || widget.item.specTypeofEntry == 3);
    if (hasTextField && hasDropDown) {
      _itemHeight = _itemHeight + 100.h;
    }

    return Container(
      decoration: const BoxDecoration(
        color: Color(
          0xFF424242,
        ),
      ),
      height: itemHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text(
                widget.item.description ?? '-',
                style: Get.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w300),
              ),
            ),
          ),
          _divider(),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "Target: ${widget.item.specTargetTextValue}",
              ),
            ),
          ),
          _divider(),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "${widget.item.uomName}",
              ),
            ),
          ),
          _divider(),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: getContent(hasTextField, hasDropDown),
            ),
          ),
          _divider(),
          Expanded(
            flex: 2,
            child: Text(
              getComply(),
              textAlign: TextAlign.center,
              style: Get.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w300),
            ),
          ),
          _divider(),
          Expanded(
            flex: 2,
            child: IconButton(
              icon: Image.asset(
                (reqobj.comment != null && (reqobj.comment ?? '').isNotEmpty)
                    ? AppImages.commentAddedImage
                    : AppImages.commentImage,
                height: 65.w,
                width: 65.w,
              ),
              onPressed: () async {
                await showCommentInputDialog(context, comment: reqobj.comment,
                    onCommentSave: (String comment) async {
                  saveComment(comment);

                  reqobj.comment ??= '';
                  reqobj = reqobj.copyWith(comment: comment);
                  widget.controller.listSpecAnalyticalsRequest[widget.index] =
                      reqobj;
                  dbobj?.comment ??= '';
                  dbobj = dbobj?.copyWith(comment: comment);
                  setState(() {});
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  double _itemHeight = 150.h;
  double get itemHeight => _itemHeight;

  Container _divider() {
    return Container(
      color: Colors.grey,
      width: 1,
      height: itemHeight,
      margin: const EdgeInsets.symmetric(horizontal: 5),
    );
  }

  void saveComment(String comment) {
    if (widget.onCommentSave != null) {
      widget.onCommentSave?.call(comment);
    }
  }

  void saveComply(String comply) {
    this.comply = comply;
    if (widget.onComplySave != null) {
      widget.onComplySave?.call(comply);
    }
    widget.controller.listSpecAnalyticalsRequest[widget.index].sampleTextValue =
        comply;
  }

  String getComply() {
    String _comply = comply;
    if (_comply == 'N/A') {
      return 'N/A';
    } else if (_comply == 'Y') {
      return 'Y';
    } else if (_comply == 'N') {
      return 'N';
    } else {
      return 'N/A';
    }
  }

  Future showCommentInputDialog(
    BuildContext context, {
    Function(String comment)? onCommentSave,
    String? comment,
  }) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        String commentData = comment ?? '';
        TextEditingController commentController =
            TextEditingController(text: commentData);
        commentController.selection = TextSelection.fromPosition(
          TextPosition(offset: commentData.length),
        );
        return AlertDialog(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          backgroundColor: Theme.of(context).colorScheme.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          title: Text(
            AppStrings.comments,
            style: Get.textTheme.titleMedium,
          ),
          content: TextField(
            autofocus: false,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            controller: commentController,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              focusedBorder: UnderlineInputBorder(),
              disabledBorder: UnderlineInputBorder(),
              enabledBorder: UnderlineInputBorder(),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Get.back();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(AppColors.primary),
                foregroundColor: MaterialStateProperty.all(AppColors.primary),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                minimumSize: MaterialStateProperty.all(const Size(100, 40)),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Text(
                  AppStrings.cancel,
                  style: Get.textTheme.labelLarge?.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (onCommentSave != null) {
                  String comment = commentController.text.trim();
                  if (reqobj.comment != comment) {
                    onCommentSave(comment);
                  }
                }
                Get.back();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(AppColors.primary),
                foregroundColor: MaterialStateProperty.all(AppColors.primary),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                minimumSize: MaterialStateProperty.all(const Size(100, 40)),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Text(
                  AppStrings.save,
                  style: Get.textTheme.labelLarge?.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
      barrierDismissible: false,
    );
  }

  void updateCompliance(String userValue) {
    if (isValidInput()) {
      comply = "Y";
      saveComply(comply);
    } else {
      comply = "N";
    }
    if (editTextValue.text.trim().isEmpty) {
      comply = "N/A";
      hasErrors2 = true;
    } else {
      hasErrors2 = false;
    }

    if (widget.item.specTypeofEntry == 3 && comply != "N") {
      if (comply == "N/A") {
        if (spinner_value == "No") {
          comply = "N";
        } else if (spinner_value == "Yes") {
          comply = "Y";
        }
      } else if (spinner_value == "No") {
        comply = "N";
      }
    }

    if (widget.item.inspectionResult == "No" ||
        widget.item.inspectionResult == "N") {
      comply = "Y";
    }

    int? p = int.tryParse(userValue);
    reqobj = reqobj.copyWith(
      sampleNumValue: p,
      comply: comply,
    );

    widget.controller.listSpecAnalyticalsRequest[widget.index] = reqobj;
    setState(() {});
  }

  bool isValidInput() {
    double? value = double.tryParse(editTextValue.text ?? '');
    if (value == null) {
      return false;
    }
    return value >= widget.item.specMin! && value <= widget.item.specMax!;
  }

  bool validInput() {
    double? value = double.tryParse(editTextValue.text ?? '');
    if (value == null) {
      return false;
    }
    return value >= widget.item.specMin! && value <= widget.item.specMax!;
  }

  @override
  void dispose() {
    // textEditingController.dispose();
    editTextValue.dispose();
    super.dispose();
  }

  Widget getContent(bool hasTextField, bool hasDropDown) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasTextField)
          Expanded(
            child: TextField(
              controller: editTextValue,
              keyboardType: TextInputType.number,
              maxLength: getMaxLength(),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Enter Value',
                // errorText: validInput() ? null : 'Invalid!',
                counter: const Offstage(),
                counterText: '',
                errorStyle: Get.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w300,
                    color: Colors.red,
                    fontSize: 11),
                isDense: true,
                border: const UnderlineInputBorder(),
                focusedErrorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                errorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                disabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                hintStyle: Get.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w300, fontSize: 12),
              ),
              onChanged: (value) => updateCompliance(value),
              style: Get.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w300),
            ),
          ),
        if (hasDropDown)
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: getSpinnerValue(),
                    items: operatorList.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        alignment: Alignment.center,
                        child: Text(
                          value,
                          style: Get.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w300),
                        ),
                      );
                    }).toList(),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        spinner_value = value;
                        setState(() {});
                        onDropdownChanged(value, hasChanged: true);
                      }
                    },
                    dropdownColor: AppColors.grey,
                    alignment: Alignment.centerRight,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> onDropdownChanged(String userValue,
      {bool hasChanged = false}) async {
    if (widget.item.specTypeofEntry == 3) {
      comply = "N/A";

      if (userValue == "Yes") {
        comply = "Y";
      } else if (userValue == "No") {
        comply = "N";
      }

      if (widget.item.specTargetTextDefault == "Y" && userValue == "No") {
        comply = "N";
      }

      if (widget.item.specTargetTextDefault == "N" && userValue == "Yes") {
        comply = "N";
      }

      if (widget.item.specTargetTextDefault == "Y" && userValue == "Yes") {
        comply = "Y";
      }

      if (widget.item.specTargetTextDefault == "N" && userValue == "No") {
        comply = "Y";
      }

      if (widget.item.specTypeofEntry == 3 && comply != "N") {
        if (editTextValue.text.isNotEmpty) {
          double userValue2 = double.tryParse(editTextValue.text.trim()) ?? 0.0;
          if (comply == "N/A") {
            if (!(userValue2 == 0.0)) {
              if (userValue2 >= widget.item.specMin! &&
                  userValue2 <= widget.item.specMax!) {
                comply = "Y";
              } else {
                comply = "N";
              }
            }
          }
          if (!(userValue2 == 0.0) &&
              !(userValue2 >= widget.item.specMin! ||
                  userValue2 <= widget.item.specMax!)) {
            comply = "N";
          }
        }
      }

      if (widget.item.inspectionResult == "No" ||
          widget.item.inspectionResult == "N") {
        comply = "Y";
      }

      reqobj = reqobj.copyWith(
        sampleTextValue: userValue,
        comply: comply,
      );
      widget.controller.listSpecAnalyticalsRequest[widget.index] = reqobj;
    }

    if (widget.item.specTypeofEntry == 2) {
      String comply = "N/A";
      if (userValue == "Yes") {
        comply = "Y";
      } else if (userValue == "No") {
        comply = "N";
      }

      if (widget.item.specTargetTextDefault == "Y" && userValue == "No") {
        comply = "N";
      }

      if (widget.item.specTargetTextDefault == "N" && userValue == "Yes") {
        comply = "N";
      }

      if (widget.item.specTargetTextDefault == "Y" && userValue == "Yes") {
        comply = "Y";
      }

      if (widget.item.specTargetTextDefault == "N" && userValue == "No") {
        comply = "Y";
      }

      if (widget.item.inspectionResult == "No" ||
          widget.item.inspectionResult == "N") {
        comply = "Y";
      }

      reqobj = reqobj.copyWith(
        sampleTextValue: userValue,
        comply: comply,
      );

      widget.controller.listSpecAnalyticalsRequest[widget.index] = reqobj;
    }

    if (hasChanged) {
      setState(() {});
    }
  }

  String? getSpinnerValue() {
    if (spinner_value == 'Y' || spinner_value == 'Yes') {
      return 'Yes';
    }
    if (spinner_value == 'N' || spinner_value == 'No') {
      return 'No';
    }
    return spinner_value;
  }

  int getMaxLength() {
    int specMax = (widget.item.specMax ?? 1.0).toInt().toString().length;
    return specMax;
  }

  int getMinLength() {
    int specMax = (widget.item.specMin ?? 1.0).toInt().toString().length;
    return specMax;
  }
}
