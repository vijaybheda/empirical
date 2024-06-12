import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pverify/models/commodity_item.dart';
import 'package:pverify/models/defect_instruction_attachment.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/theme/colors.dart';
import 'package:pverify/utils/utils.dart';

class DefectsInfoDialog {
  List<DefectInstructionAttachment> attachments = [];
  String? instruction;
  CommodityItem? item;
  int? defectid;
  String? name;
  late int position;
  late int commodityID;
  late List<CommodityItem> commodityList;

  DefectsInfoDialog({
    required this.position,
    required this.commodityID,
    required this.commodityList,
    required this.defectid,
    required this.name,
  }) {
    // get the list of defects for the commodity
    if (commodityList.isNotEmpty) {
      for (int i = 0; i < commodityList.length; i++) {
        if (commodityList[i].id == commodityID) {
          item = commodityList[i];
          break;
        }
      }
    }
    if (item != null &&
        item!.defectList != null &&
        item!.defectList!.isNotEmpty) {
      for (int i = 0; i < item!.defectList!.length; i++) {
        if (item!.defectList![i].id == defectid) {
          if (item!.defectList![i].inspectionInstruction != null) {
            instruction = item!.defectList![i].inspectionInstruction!;
          }
          if (item!.defectList![i].attachments != null) {
            attachments = item!.defectList![i].attachments!;
          }
          break;
        }
      }
    }
  }

  void showDefectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (attachments.isNotEmpty) {
          return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              title: null,
              contentPadding: const EdgeInsets.all(8),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              if (name != null && name!.isNotEmpty)
                                Text(name ?? '',
                                    style: Get.textTheme.titleMedium),
                              const SizedBox(height: 15),
                              if (instruction != null &&
                                  instruction!.isNotEmpty)
                                Text(instruction ?? '',
                                    style: Get.textTheme.titleMedium),
                              const SizedBox(height: 15),
                              for (var i = 0; i < attachments.length; i++)
                                FutureBuilder(
                                  future:
                                      _loadImage(context, getInstFileName(i)),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<Image> image) {
                                    if (image.hasData) {
                                      return image.data!;
                                    } else {
                                      // return const CircularProgressIndicator();
                                      return const SizedBox();
                                    }
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    OkWidget,
                  ],
                ),
              ));
        }
        return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            title: null,
            contentPadding: const EdgeInsets.all(8),
            content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              if (name != null && name!.isNotEmpty)
                                Text(name ?? '',
                                    style: Get.textTheme.titleMedium),
                              const SizedBox(height: 15),
                              if (instruction != null &&
                                  instruction!.isNotEmpty)
                                Text(instruction ?? '',
                                    style: Get.textTheme.titleMedium),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    OkWidget,
                  ],
                )));
      },
    );
  }

  Container get OkWidget {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: ElevatedButton(
        onPressed: () {
          Get.back();
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(AppColors.primary),
          foregroundColor: MaterialStateProperty.all(AppColors.primary),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
          minimumSize: MaterialStateProperty.all(const Size(100, 40)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Text(
            AppStrings.ok,
            style: Get.textTheme.labelLarge?.copyWith(
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }

  String getInstFileName(int i) =>
      'instruction_${commodityID}_$defectid-${(i + 1)}.png';

  Future<Image> _loadImage(BuildContext context, String filename) async {
    String directoryPath =
        await Utils.createCommodityVarietyDocumentDirectory();

    final File file = File('$directoryPath/$filename');

    if (!file.existsSync()) {
      final data = await rootBundle.load('assets/$filename');
      await file.writeAsBytes(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    }
    return Image.file(
      file,
      height: (MediaQuery.of(context).size.height * 0.4),
      fit: BoxFit.contain,
    );
  }
}
