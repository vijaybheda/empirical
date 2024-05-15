import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pverify/models/commodity_item.dart';
import 'package:pverify/models/defect_instruction_attachment.dart';
import 'package:pverify/models/defect_item.dart';
import 'package:pverify/utils/utils.dart';

class DefectsInfoDialog {
  List<DefectInstructionAttachment> attachments = [];
  String instruction = "";
  CommodityItem? item;
  late int defectid;
  late int position;
  late int commodityID;
  late List<CommodityItem> commodityList;
  late List<DefectItem> defectList;

  DefectsInfoDialog({
    required this.position,
    required this.commodityID,
    required this.commodityList,
    // required this.defectList,
  }) {
    defectid = defectList[position].id!;

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
          if (item!.defectList![i].instruction != null) {
            instruction = item!.defectList![i].instruction!;
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
        return Dialog(
          child: attachments.isNotEmpty
              ? Column(
                  children: <Widget>[
                    Text(defectList[position].name ?? ''),
                    Text(instruction),
                    for (var i = 0; i < attachments.length; i++)
                      FutureBuilder(
                        future: _loadImage(
                            'instruction_${commodityID}_${defectid}_$i.png'),
                        builder:
                            (BuildContext context, AsyncSnapshot<Image> image) {
                          if (image.hasData) {
                            return image.data!;
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      ),
                    ElevatedButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                  ],
                )
              : Column(
                  children: <Widget>[
                    Text(defectList[position].name ?? ''),
                    Text(instruction),
                    ElevatedButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                  ],
                ),
        );
      },
    );
  }

  Future<Image> _loadImage(String filename) async {
    String directoryPath =
        await Utils.createCommodityVarietyDocumentDirectory();

    final File file = File('$directoryPath/$filename');

    if (await file.exists()) {
      return Image.file(file);
    } else {
      final data = await rootBundle.load('assets/$filename');
      await file.writeAsBytes(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
      return Image.file(file);
    }
  }
}
