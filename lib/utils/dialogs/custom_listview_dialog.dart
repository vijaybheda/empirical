import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/models/exception_item.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/theme/colors.dart';

class CustomListViewDialog {
  BuildContext context;
  final AppStorage _appStorage = AppStorage.instance;
  bool canCanceledOnTouchOutside = false;
  final Function(String selectedValue) onSelected;
  CustomListViewDialog(
    this.context,
    this.onSelected,
  );

  Future show() {
    List<Map<String, String>> exceptionCollection = [];
    Map<String, String>? map;

    for (ExceptionItem item
        in (_appStorage.commodityVarietyData?.exceptions ?? []).toList()) {
      map = {};
      map['title'] = item.shortDescription ?? "";

      if (item.expirationDate != null &&
          item.expirationDate != "null" &&
          item.expirationDate != "") {
        String description = "\n\nExp Date: ${item.expirationDate ?? ''}";
        map['detail'] = '${item.longDescription ?? ''}$description';
      } else {
        map['detail'] = item.longDescription ?? '';
      }
      exceptionCollection.add(map);
    }

    return showDialog(
      context: context,
      barrierDismissible: canCanceledOnTouchOutside,
      builder: (BuildContext context) {
        return CustomListView(
          exceptions:
              (_appStorage.commodityVarietyData?.exceptions ?? []).toList(),
          onSelected: onSelected,
        );
      },
    );
  }

  void setCanceledOnTouchOutside(bool b) {
    canCanceledOnTouchOutside = b;
  }
}

class CustomListView extends StatelessWidget {
  final List<ExceptionItem> exceptions;
  final Function(String selectedValue) onSelected;
  const CustomListView(
      {super.key, required this.exceptions, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: Text(
        AppStrings.exceptions,
        style: Get.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: Get.height * 0.6,
              width: Get.width,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: exceptions.length,
                itemBuilder: (context, index) {
                  final item = exceptions[index];
                  return ListTile(
                    onTap: () {
                      Get.back(result: item);
                    },
                    title: Text(
                      item.shortDescription ?? '',
                      style: Get.textTheme.titleMedium
                          ?.copyWith(color: AppColors.white),
                    ),
                    subtitle: Text(
                      item.shortDescription ?? '',
                      style: Get.textTheme.titleSmall
                          ?.copyWith(color: AppColors.white),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
      actions: <Widget>[
        Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
            ],
          ),
        )
      ],
    );
  }
}
