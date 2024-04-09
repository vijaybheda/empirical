import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/models/exception_item.dart';
import 'package:pverify/utils/app_storage.dart';

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
      {Key? key, required this.exceptions, required this.onSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Exceptions',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: exceptions.length,
            itemBuilder: (context, index) {
              final item = exceptions[index];
              return ListTile(
                onTap: () {
                  Get.back(result: item);
                },
                title: Text(item.shortDescription ?? ''),
                subtitle: Text(item.shortDescription ?? ''),
              );
            },
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
