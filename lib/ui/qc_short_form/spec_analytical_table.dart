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
import 'package:pverify/utils/utils.dart';

class SpecAnalyticalTable
    extends GetWidget<QCDetailsShortFormScreenController> {
  final String tag;
  const SpecAnalyticalTable({
    super.key,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    QCDetailsShortFormScreenController controller =
        Get.find<QCDetailsShortFormScreenController>(tag: tag);
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
            },
            hasErrors2: (bool hasErrors2) {
              controller.hasErrors2 = hasErrors2;
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
  final QCDetailsShortFormScreenController controller;
  final SpecificationAnalyticalRequest? dbobj;
  final int index;
  final void Function(bool hasErrors2) hasErrors2;

  const SpecificationAnalyticalWidget({
    super.key,
    required this.item,
    required this.reqobj,
    this.onCommentSave,
    this.onComplySave,
    required this.controller,
    this.dbobj,
    required this.index,
    required this.hasErrors2,
  });

  @override
  State<SpecificationAnalyticalWidget> createState() =>
      _SpecificationAnalyticalWidgetState();
}

class _SpecificationAnalyticalWidgetState
    extends State<SpecificationAnalyticalWidget> {
  String comply = '';
  late bool hasErrors;
  bool isPictureRequired = false;
  List<String> operatorList = [];
  final ApplicationDao dao = ApplicationDao();
  String spinner_value = 'Select';

  TextEditingController editTextValue = TextEditingController();

  bool hasErrors2 = false;
  late SpecificationAnalyticalRequest reqobj;
  SpecificationAnalyticalRequest? dbobj;

  @override
  void initState() {
    reqobj = widget.reqobj.copyWith();
    if (widget.dbobj != null) {
      dbobj = widget.dbobj!.copyWith();
      reqobj.comply = dbobj?.comply;
      comply = dbobj?.comply ?? '';
    } else {
      reqobj.comply = "N/A";
      comply = "N/A";
    }

    hasErrors = false;
    operatorList = ['Select', 'Yes', 'No', 'N/A'];

    unawaited(() async {
      await initSetup();
      onDropdownChanged(spinner_value, hasChanged: false);
      setState(() {});
    }());
    super.initState();
  }

  void manageAnalyticalName() {
    if (widget.item.analyticalName?.contains("Branded") ?? false) {
      comply = "Y";
      spinner_value = operatorList.elementAt(0);

      // String? brandedFlag =
      //     await dao.getBrandedFlagFromItemSku(widget.controller.itemSkuId!);
      //
      // String textViewComply = "Y";
      // comply = textViewComply;
      // // spinner_value = comply;
      // if (brandedFlag == "0") {
      //   spinner_value = operatorList.elementAt(0);
      // } else if (brandedFlag == "1") {
      //   spinner_value = operatorList.elementAt(1);
      // } else {
      //   spinner_value = operatorList.elementAt(2);
      // }
    }
  }

  Future<void> initSetup() async {
    spinner_value = operatorList.elementAt(0);

    if (widget.item.specTargetTextDefault == "Y") {
      String textViewComply = "Y";
      comply = textViewComply;
      spinner_value = operatorList.elementAt(1);
    } else if (widget.item.specTargetTextDefault == "N") {
      String textViewComply = "Y";
      comply = textViewComply;
      spinner_value = operatorList.elementAt(2);
    } else if (widget.item.specTargetTextDefault == "") {
      operatorList.removeWhere((element) => ("N/A" == element));
      spinner_value = operatorList.elementAt(0);
    } else if (widget.item.specTargetTextDefault == "N/A") {
      String textViewComply = "N/A";
      comply = textViewComply;
      spinner_value = operatorList.elementAt(3);
    }

    manageAnalyticalName();

    if (widget.item.specTypeofEntry == 1) {
      if (dbobj != null) {
        reqobj = reqobj.copyWith(sampleNumValue: dbobj?.sampleNumValue);
        widget.controller.listSpecAnalyticalsRequest[widget.index] = reqobj;
        if (editTextValue != null && dbobj?.sampleNumValue != null) {
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
            comply = operatorList.elementAt(i);
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
            widget.controller.listSpecAnalyticalsRequest[widget.index] = reqobj;
          }
        }

        if (dbobj?.comply != null) {
          comply = dbobj!.comply!;
        }
      }
    }

    if (widget.item.specTypeofEntry == 1 || widget.item.specTypeofEntry == 3) {
      String editfield = editTextValue.text;
      if (editfield.isEmpty) {
        hasErrors2 = true;
        widget.hasErrors2(hasErrors2);
      }
    }
    if (dbobj?.comply != null) {
      comply = dbobj!.comply!;
    }
    setState(() {});
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

    return SizedBox(
      height: itemHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 10,
            child: Text(
              widget.item.description ?? '-',
              style: Get.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w300),
            ),
          ),
          _divider(),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
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
          _divider(),
          Expanded(
            flex: 2,
            child: IconButton(
              icon: Image.asset(
                (widget.item.specTypeofEntry == 1 ||
                        widget.item.specTypeofEntry == 3)
                    ? AppImages.infoAddedImage
                    : AppImages.infoImage,
                height: 65.w,
                width: 65.w,
              ),
              onPressed: () => infoButtonTap(),
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
    } else if (_comply == 'Y' || _comply == 'Yes') {
      return 'Y';
    } else if (_comply == 'N' || _comply == 'No') {
      return 'N';
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
      widget.hasErrors2(hasErrors2);
    } else {
      hasErrors2 = false;
      widget.hasErrors2(hasErrors2);
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
    return (editTextValue.text ?? '').isNotEmpty;
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
                // hintText: 'Enter Value',
                errorText: validInput() ? null : '',
                counter: const Offstage(),
                counterText: '',
                errorMaxLines: 1,
                error: null,
                errorStyle: Get.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w300,
                    color: Colors.red,
                    fontSize: 11),
                isDense: true,
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                disabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                errorBorder: const UnderlineInputBorder(
                  // borderRadius: BorderRadius.all(Radius.circular(5)),
                  borderSide: BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                hintStyle: Get.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w300, fontSize: 12),
                suffixIcon: !validInput()
                    ? IconButton(
                        icon:
                            const Icon(Icons.info_outlined, color: Colors.red),
                        onPressed: () {
                          Utils.showSnackBar(
                            context: Get.overlayContext!,
                            message: 'Please enter a valid value',
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 2),
                          );
                        },
                      )
                    : null,
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
                    value: spinner_value,
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

  Future<void> onDropdownChanged(String value,
      {bool hasChanged = false}) async {
    if (widget.item.specTypeofEntry == 3) {
      String comply = "N/A";
      String userValue = spinner_value;

      if ((widget.item.analyticalName?.contains("Accept") ?? false) ||
          (widget.item.analyticalName?.contains("Protection") ?? false)) {
        if (userValue == "Yes") {
          comply = "N";
        } else if (userValue == "No") {
          comply = "Y";
        }
      } else if (widget.item.analyticalName?.contains("Branded") ?? false) {
        comply = "Y";
        this.comply = "Y";
        /*String brandedFlag =
            await dao.getBrandedFlagFromItemSku(widget.controller.itemSkuId!);

        if (brandedFlag == "1" && userValue == "No") {
          comply = "N";
        } else if (brandedFlag == "0" && userValue == "Yes") {
          comply = "N";
        } else if (brandedFlag == "1" && userValue == "Yes") {
          comply = "Y";
        } else if (brandedFlag == "0" && userValue == "No") {
          comply = "Y";
        }*/
      } else {
        if ((widget.item.specTargetTextDefault == "Y") && userValue == "No") {
          comply = "N";
        }
        if ((widget.item.specTargetTextDefault == "N") && userValue == "Yes") {
          comply = "N";
        }
        if ((widget.item.specTargetTextDefault == "Y") && userValue == "Yes") {
          comply = "Y";
        }
        if ((widget.item.specTargetTextDefault == "N") && userValue == "No") {
          comply = "Y";
        }
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
              !(userValue2 >= widget.item.specMin! &&
                  userValue2 <= widget.item.specMax!)) {
            comply = "N";
          }
        }
      }

      if (widget.item.inspectionResult == "No" ||
          widget.item.inspectionResult == "N") {
        comply = "Y";
      }

      this.comply = comply;
      reqobj = reqobj.copyWith(
        sampleTextValue: userValue,
        comply: comply,
      );
      widget.controller.listSpecAnalyticalsRequest[widget.index] = reqobj;
    }

    if (widget.item.specTypeofEntry == 2) {
      // String comply = "N/A";
      comply = "Y";
      String userValue = spinner_value;

      if ((widget.item.analyticalName?.contains("Accept") ?? false) ||
          (widget.item.analyticalName?.contains("Protection") ?? false)) {
        if (userValue == "Yes") {
          comply = "N";
        } else if (userValue == "No") {
          comply = "Y";
        }
      } else if ((widget.item.analyticalName?.contains("Branded") ?? false)) {
        comply = "Y";

        /*String brandedFlag =
            await dao.getBrandedFlagFromItemSku(widget.controller.itemSkuId!);

        if (brandedFlag == "1" && userValue == "No") {
          comply = "N";
        } else if (brandedFlag == "0" && userValue == "Yes") {
          comply = "N";
        } else if (brandedFlag == "1" && userValue == "Yes") {
          comply = "Y";
        } else if (brandedFlag == "0" && userValue == "No") {
          comply = "Y";
        }*/
      } else {
        if ((widget.item.specTargetTextDefault == "Y") && userValue == "No") {
          comply = "N";
        } else if ((widget.item.specTargetTextDefault == "N") &&
            userValue == "Yes") {
          comply = "N";
        } else if ((widget.item.specTargetTextDefault == "Y") &&
            userValue == "Yes") {
          comply = "Y";
        } else if ((widget.item.specTargetTextDefault == "N") &&
            userValue == "No") {
          comply = "Y";
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

    if (hasChanged) {
      setState(() {});
    }
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
