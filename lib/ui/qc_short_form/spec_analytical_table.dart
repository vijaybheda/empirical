import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/qc_details_short_form_screen_controller.dart';
import 'package:pverify/models/specification_analytical.dart';
import 'package:pverify/models/specification_analytical_request_item.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';

class SpecAnalyticalTable
    extends GetWidget<QCDetailsShortFormScreenController> {
  const SpecAnalyticalTable({super.key});

  @override
  Widget build(BuildContext context) {
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
            reqobj: reqobj,
            dbobj: dbobj,
            onCommentSave: (String comment) {
              reqobj.comment ??= '';
              reqobj.comment = comment;
              reqobj.copyWith(comment: comment);
              controller.update();
            });
      },
    );
  }
}

class SpecificationAnalyticalWidget extends StatefulWidget {
  final SpecificationAnalytical item;
  final SpecificationAnalyticalRequest reqobj;
  final Function(String comment)? onCommentSave;
  final QCDetailsShortFormScreenController controller;
  final SpecificationAnalyticalRequest? dbobj;

  const SpecificationAnalyticalWidget({
    super.key,
    required this.item,
    required this.reqobj,
    this.onCommentSave,
    required this.controller,
    this.dbobj,
  });

  @override
  State<SpecificationAnalyticalWidget> createState() =>
      _SpecificationAnalyticalWidgetState();
}

class _SpecificationAnalyticalWidgetState
    extends State<SpecificationAnalyticalWidget> {
  String comply = 'N/A';
  late TextEditingController textEditingController;
  late bool hasErrors;
  bool isPictureRequired = false;
  List<String> operatorList = [];
  final ApplicationDao dao = ApplicationDao();
  String spinner_value = 'N/A';

  TextEditingController? editTextValue;

  bool hasErrors2 = false;
  late SpecificationAnalyticalRequest reqobj;
  SpecificationAnalyticalRequest? dbobj;

  @override
  void initState() {
    reqobj = widget.reqobj.copyWith();
    if (widget.dbobj != null) {
      dbobj = widget.dbobj!.copyWith();
    }
    hasErrors = false;
    textEditingController = TextEditingController();
    comply = "N/A";
    spinner_value = comply;
    operatorList = ['Select', 'Yes', 'No', 'N/A'];

    if (widget.item.specTargetTextDefault == 'Yes') {
      comply = 'Yes';
      spinner_value = comply;
    } else if (widget.item.specTargetTextDefault == 'No') {
      comply = 'No';
      spinner_value = comply;
    }
    spinner_value = operatorList.first;
    super.initState();

    if (widget.item.specTargetTextDefault == "Yes") {
      comply = "Yes";
      spinner_value = operatorList[1];
    } else if (widget.item.specTargetTextDefault == "No") {
      comply = "Yes";
      spinner_value = operatorList[2];
    }
    if (widget.item.specTypeofEntry == 1 || widget.item.specTypeofEntry == 3) {
      if (widget.item.isPictureRequired ?? false) {
        isPictureRequired = true;
      }
    }

    if (widget.item.analyticalName?.contains("Quality Check") ?? false) {
      editTextValue = TextEditingController();

      editTextValue?.addListener(() {
        String comply = "N/A";
        spinner_value = comply;
        if (editTextValue!.text.isEmpty) {
          editTextValue!.text = "0";
        }
        int userValue = int.tryParse(editTextValue!.text.trim()) ?? 0;
        if (userValue >= (widget.item.specMin ?? 0) &&
            userValue <= (widget.item.specMax ?? 0)) {
          comply = "Yes";
          spinner_value = comply;
        } else {
          comply = "No";
          spinner_value = comply;
        }

        if (editTextValue!.text.isEmpty) {
          comply = "N/A";
          hasErrors2 = true;
          spinner_value = comply;
        } else {
          hasErrors2 = false;
        }
        if (widget.item.specTypeofEntry == 3 && comply != "No") {
          if (comply == "N/A") {
            if (spinner_value == "No") {
              comply = "No";
              spinner_value = comply;
            } else if (spinner_value == "Yes") {
              comply = "Yes";
              spinner_value = comply;
            }
          } else if (spinner_value == "No") {
            comply = "No";
            spinner_value = comply;
          }
        }

        if (widget.item.inspectionResult == "No") {
          comply = "Yes";
          spinner_value = comply;
        }

        reqobj.copyWith(
          sampleNumValue: userValue,
          comply: comply,
        );
      });
    }

    if (widget.item.specTargetTextDefault == "Yes") {
      String textViewComply = "Yes";
      spinner_value = operatorList[1];
    } else if (widget.item.specTargetTextDefault == "No") {
      String textViewComply = "Yes";
      spinner_value = operatorList[2];
    } else if (widget.item.specTargetTextDefault == "") {
      operatorList.removeWhere((element) => ("N/A" == element));
      spinner_value = operatorList[0];
    } else if (widget.item.specTargetTextDefault == "N/A") {
      String textViewComply = "N/A";
      spinner_value = operatorList[3];
    }

    unawaited(() async {
      await initSetup();
      setState(() {});
    }());
  }

  Future<void> initSetup() async {
    if (widget.item.analyticalName?.contains("Branded") ?? false) {
      // TODO: implement this method
      String? brandedFlag =
          await dao.getBrandedFlagFromItemSku(widget.controller.itemSkuId!);

      String textViewComply = "Yes";
      spinner_value = textViewComply;
      if (brandedFlag == "1") {
        spinner_value = operatorList[1];
      } else {
        spinner_value = operatorList[2];
      }
    }

    if (widget.item.specTypeofEntry == 1) {
      if (dbobj != null) {
        reqobj.copyWith(sampleNumValue: dbobj?.sampleNumValue);
        if (editTextValue != null) {
          editTextValue!.text = ((dbobj?.sampleNumValue ?? 0) ?? '').toString();
        }
      }
    } else if (widget.item.specTypeofEntry == 2) {
      if (dbobj != null) {
        for (int i = 0; i < operatorList.length; i++) {
          if (dbobj?.sampleTextValue == operatorList[i]) {
            spinner_value = operatorList.elementAt(i);
            reqobj.copyWith(sampleTextValue: operatorList[i]);
          }
        }
      }
    } else if (widget.item.specTypeofEntry == 3) {
      if (dbobj != null) {
        reqobj.copyWith(
          sampleNumValue: dbobj?.sampleNumValue,
        );
        if (dbobj?.sampleNumValue != null) {
          editTextValue!.text = dbobj!.sampleNumValue.toString();
        }

        for (int i = 0; i < operatorList.length; i++) {
          if (dbobj?.sampleTextValue == operatorList[i]) {
            spinner_value = operatorList.elementAt(i);
            reqobj.copyWith(sampleTextValue: operatorList[i]);
          }
        }
      }
    }

    if (widget.item.specTypeofEntry == 1 || widget.item.specTypeofEntry == 3) {
      String editfield = editTextValue!.text;
      if (editfield.isEmpty) {
        hasErrors2 = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 10,
          child: Text(
            widget.item.description ?? '-',
            style:
                Get.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w300),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: getContent(),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            getComply(),
            style:
                Get.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w300),
          ),
        ),
        Expanded(
          flex: 1,
          child: IconButton(
            icon: Image.asset(
              (dbobj?.comment != null && (dbobj?.comment ?? '').isNotEmpty)
                  ? AppImages.commentAddedImage
                  : AppImages.commentImage,
              height: 50.w,
              width: 50.w,
            ),
            onPressed: () async {
              await showCommentInputDialog(context, comment: dbobj?.comment,
                  onCommentSave: (String comment) async {
                if (widget.onCommentSave != null) {
                  widget.onCommentSave?.call(comment);
                }

                setState(() {
                  reqobj.comment ??= '';
                  reqobj.copyWith(comment: comment);

                  dbobj?.comment ??= '';
                  dbobj?.copyWith(comment: comment);
                });
              });
            },
          ),
        ),
        Expanded(
          flex: 1,
          child: IconButton(
            icon: Image.asset(
              (widget.item.specTypeofEntry == 1 ||
                      widget.item.specTypeofEntry == 3)
                  ? AppImages.infoAddedImage
                  : AppImages.infoImage,
              height: 50.w,
              width: 50.w,
            ),
            onPressed: () => infoButtonTap(),
          ),
        ),
      ],
    );
  }

  String getComply() {
    String _comply = comply;
    if (_comply == 'N/A') {
      return 'N/A';
    } else if (_comply == 'Yes') {
      return 'Yes';
    } else if (_comply == 'No') {
      return 'No';
    } else {
      return 'N/A';
    }
  }

  Future<Function?> infoButtonTap() async {
    if ((widget.item.specTypeofEntry == 3 ||
        widget.item.specTypeofEntry == 1)) {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          title: Text(
            "Min/Max",
            style:
                Get.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w300),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.specTypeofEntry == 3
                      ? "Min: ${widget.item.specMin}\nMax: ${widget.item.specMax}\n${AppStrings.target}: ${widget.item.specTargetNumValue}\n\n${AppStrings.target} (${AppStrings.targetText}): ${widget.item.specTargetTextValue}"
                      : (widget.item.specTypeofEntry == 1
                          ? "Min: ${widget.item.specMin}\nMax: ${widget.item.specMax}\n${AppStrings.target}: ${widget.item.specTargetNumValue}"
                          : "${AppStrings.target}: ${widget.item.specTargetTextValue}"),
                  style: Get.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text(
                AppStrings.ok,
                style: Get.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w300),
              ),
            ),
          ],
        ),
      );
    } else {
      return null;
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

  void handleTextChanges(String value) {
    int userValue = int.tryParse(value) ?? 0;
    double specMin = widget.item.specMin ?? 0;
    double specMax = widget.item.specMax ?? 0;

    if (userValue >= specMin && userValue <= specMax) {
      comply = "Yes";
      spinner_value = comply;
    } else {
      comply = "No";
      spinner_value = comply;
    }

    if (value.isEmpty) {
      comply = "N/A";
      spinner_value = comply;
      hasErrors = true;
    } else {
      hasErrors = false;
    }
  }

  void handleComplianceChange(String value) {
    comply = value;
    spinner_value = comply;
    // Handle compliance changes
    if (widget.item.specTypeofEntry == 3 && comply != "No") {
      // int userValue = int.tryParse(textEditingController.text) ?? 0;

      if (comply == "N/A") {
        comply = "No";
        spinner_value = comply;
      } else if (comply == "No") {
        comply = "No";
        spinner_value = comply;
      }
    }
  }

  void updateCompliance(String value) {
    if (validInput()) {
      comply = "Yes";
      spinner_value = comply;
    } else {
      comply = "No";
      spinner_value = comply;
    }
  }

  bool validInput() {
    double? value = double.tryParse(textEditingController.text);
    return value != null &&
        value >= widget.item.specMin! &&
        value <= widget.item.specMax!;
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  Widget getContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.item.specTypeofEntry == 1 ||
            widget.item.specTypeofEntry == 3)
          Flexible(
            child: TextField(
              controller: textEditingController,
              decoration: InputDecoration(
                labelText: 'Enter Value',
                // errorText: validInput() ? null : 'Invalid!',
                // isDense: true,
                border: UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(),
                disabledBorder: UnderlineInputBorder(),
                enabledBorder: UnderlineInputBorder(),
                hintStyle: Get.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w300),
              ),
              onChanged: (value) => updateCompliance(value),
              style: Get.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w300),
            ),
          ),
        if (widget.item.specTypeofEntry == 2 ||
            widget.item.specTypeofEntry == 3)
          Flexible(
            child: DropdownButton<String>(
              value: spinner_value,
              items: operatorList.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: Get.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w300),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                comply = value!;
                spinner_value = value;
                setState(() {});
                onDropdownChanged(value);
              },
              /*decoration: InputDecoration(
                hintText: AppStrings.uom,
                hintStyle: Get.textTheme.bodyLarge!.copyWith(
                  fontSize: 26.sp,
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                border: const UnderlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),*/
              dropdownColor: AppColors.grey,
              alignment: Alignment.centerRight,
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<void> onDropdownChanged(String value) async {
    String comply = "N/A";
    String userValue = spinner_value;
    spinner_value = comply;
    if ((widget.item.analyticalName?.contains("Accept") ?? false) ||
        (widget.item.analyticalName?.contains("Protection") ?? false)) {
      if (userValue == "Yes") {
        comply = "No";
        spinner_value = comply;
      } else if (userValue == "No") {
        comply = "Yes";
        spinner_value = comply;
      }
    } else if (widget.item.analyticalName?.contains("Branded") ?? false) {
      String brandedFlag =
          await dao.getBrandedFlagFromItemSku(widget.controller.itemSkuId!);

      if (brandedFlag == "1" && userValue == "No") {
        comply = "No";
        spinner_value = comply;
      } else if (brandedFlag == "0" && userValue == "Yes") {
        comply = "No";
        spinner_value = comply;
      } else if (brandedFlag == "1" && userValue == "Yes") {
        comply = "Yes";
        spinner_value = comply;
      } else if (brandedFlag == "0" && userValue == "No") {
        comply = "Yes";
        spinner_value = comply;
      }
    } else {
      if (widget.item.specTargetTextDefault == "Yes" && userValue == "No") {
        comply = "No";
        spinner_value = comply;
      }

      if (widget.item.specTargetTextDefault == "No" && userValue == "Yes") {
        comply = "No";
        spinner_value = comply;
      }

      if (widget.item.specTargetTextDefault == "Yes" && userValue == "Yes") {
        comply = "Yes";
        spinner_value = comply;
      }

      if (widget.item.specTargetTextDefault == "No" && userValue == "No") {
        comply = "Yes";
        spinner_value = comply;
      }
    }

    if (widget.item.specTypeofEntry == 3 && comply != "No") {
      if (editTextValue!.text.isNotEmpty) {
        double userValue2 = double.tryParse(editTextValue!.text.trim()) ?? 0.0;
        if (comply == "N/A") {
          if (userValue2 != 0.0) {
            if (userValue2 >= (widget.item.specMin ?? 0) &&
                userValue2 <= (widget.item.specMax ?? 0)) {
              comply = "Yes";
              spinner_value = comply;
            } else {
              comply = "No";
              spinner_value = comply;
            }
          }
        }
        if (userValue2 != 0.0 &&
            (userValue2 < (widget.item.specMin ?? 0) ||
                userValue2 > (widget.item.specMax ?? 0))) {
          comply = "No";
          spinner_value = comply;
        }
      }
    }

    if (widget.item.inspectionResult == "No") {
      comply = "Yes";
      spinner_value = comply;
    }

    reqobj.copyWith(
      sampleTextValue: userValue,
      comply: comply,
    );
    spinner_value = comply;
    setState(() {});
  }
}
