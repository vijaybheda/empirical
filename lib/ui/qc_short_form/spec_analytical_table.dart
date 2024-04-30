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
        SpecificationAnalyticalRequest reqobj = SpecificationAnalyticalRequest(
          analyticalID: item.analyticalID,
          analyticalName: item.description,
          specTypeofEntry: item.specTypeofEntry,
          isPictureRequired: item.isPictureRequired,
          specMin: item.specMin,
          specMax: item.specMax,
          description: item.description,
          inspectionResult: item.inspectionResult,
        );

        return SpecificationAnalyticalWidget(
            item: item,
            reqobj: reqobj,
            onCommentSave: (String comment) {
              reqobj.comment ??= '';
              reqobj.comment = comment;
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
  const SpecificationAnalyticalWidget({
    super.key,
    required this.item,
    required this.reqobj,
    this.onCommentSave,
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

  final ApplicationDao dao = ApplicationDao();

  @override
  void initState() {
    hasErrors = false;
    super.initState();
    textEditingController = TextEditingController();

    if (widget.item.specTargetTextDefault == "Yes") {
      comply = "Yes";
    } else if (widget.item.specTargetTextDefault == "No") {
      comply = "Yes";
    }
    if (widget.item.specTypeofEntry == 1 || widget.item.specTypeofEntry == 3) {
      if (widget.item.isPictureRequired ?? false) {
        isPictureRequired = true;
      }
    }

    if (widget.item.analyticalName?.contains("Quality Check") ?? false) {
      // In Flutter, you can limit the length of the text in a TextField using the maxLength property
      // and restrict the input using the inputFormatters property
      TextEditingController editTextValue = TextEditingController();
      editTextValue.text = '12345';
    }

    if (widget.item.specTargetTextDefault == "Y") {
      String textViewComply = "Y";
      int spinnerValue = 1;
    } else if (widget.item.specTargetTextDefault == "N") {
      String textViewComply = "Y";
      int spinnerValue = 2;
    } else if (widget.item.specTargetTextDefault == "") {
      // TODO: handle this conditions
      // operatorList.remove("N/A");
      int spinnerValue = 0;
    } else if (widget.item.specTargetTextDefault == "N/A") {
      String textViewComply = "N/A";
      int spinnerValue = 3;
    }

    if (widget.item.analyticalName?.contains("Branded") ?? false) {
      // TODO: implement this method
      /*dao.getBrandedFlagFromItemSku(item_sku_id).then((String? brandedFlag) {
        String textViewComply = "Y";

        if (brandedFlag == "1") {
          int spinnerValue = 1;
        } else {
          int spinnerValue = 2;
        }
      });*/
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            widget.item.description ?? '-',
            style: Get.textTheme.bodyMedium,
          ),
        ),
        Expanded(child: getContent()),
        Text(
          getComply(),
          style: Get.textTheme.bodyMedium?.copyWith(
              // color: AppColors.textFieldText_Color,
              ),
        ),
        IconButton(
          icon: Image.asset(
            (widget.reqobj.comment != null && widget.reqobj.comment!.isNotEmpty)
                ? AppImages.commentAddedImage
                : AppImages.commentImage,
            height: 50.w,
            width: 50.w,
          ),
          onPressed: () async {
            await showCommentInputDialog(context,
                onCommentSave: (String comment) async {
              setState(() {
                widget.reqobj.comment ??= '';
                widget.reqobj.comment = comment;
              });
            });
          },
        ),
        IconButton(
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
      ],
    );
  }

  String getComply() {
    String _comply = comply;
    if (_comply == 'N/A') {
      return 'N/A';
    } else if (_comply == 'Yes') {
      return 'Y';
    } else if (_comply == 'No') {
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
          title: const Text("Min/Max"),
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
                  style: Get.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text(
                AppStrings.ok,
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
  }) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        String comment = widget.reqobj.comment ?? '';
        TextEditingController commentController =
            TextEditingController(text: comment);
        commentController.selection = TextSelection.fromPosition(
          TextPosition(offset: comment.length),
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
            maxLines: 3,
            minLines: 1,
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
                  if (widget.reqobj.comment != comment) {
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
    } else {
      comply = "No";
    }

    if (value.isEmpty) {
      comply = "N/A";
      hasErrors = true;
    } else {
      hasErrors = false;
    }
  }

  void handleComplianceChange(String value) {
    comply = value;

    // Handle compliance changes
    if (widget.item.specTypeofEntry == 3 && comply != "No") {
      // int userValue = int.tryParse(textEditingController.text) ?? 0;

      if (comply == "N/A") {
        comply = "No";
      } else if (comply == "No") {
        comply = "No";
      }
    }
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
              onChanged: (value) {
                handleTextChanges(value);
              },
              decoration: InputDecoration(
                labelText: 'Value',
                errorText: hasErrors
                    ? 'Please enter a valid value'
                    : null, // Show error if necessary
              ),
            ),
          ),
        if (widget.item.specTypeofEntry == 2 ||
            widget.item.specTypeofEntry == 3)
          Flexible(
            child: DropdownButton<String>(
              value: comply,
              items: <String>['N/A', 'Yes', 'No']
                  .map((String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(),
              onChanged: (value) {
                comply = value!;
                handleComplianceChange(value);
                setState(() {});
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
            ),
          ),
        const SizedBox(height: 20),
        Flexible(
          child: TextField(
              onChanged: (value) {
                // TODO: Your logic for handling text changes
              },
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(),
                disabledBorder: UnderlineInputBorder(),
                enabledBorder: UnderlineInputBorder(),
              )),
        ),
      ],
    );
  }
}
