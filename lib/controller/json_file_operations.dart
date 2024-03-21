import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:path/path.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/models/commodity_item.dart';
import 'package:pverify/models/commodity_variety_data.dart';
import 'package:pverify/models/defect_instruction_attachment.dart';
import 'package:pverify/models/defect_item.dart';
import 'package:pverify/models/document_item.dart';
import 'package:pverify/models/document_item_data.dart';
import 'package:pverify/models/exception_item.dart';
import 'package:pverify/models/offline_commodity.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/models/severity_defect.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/utils.dart';

class JsonFileOperations {
  final AppStorage appStorage = AppStorage.instance;

  static JsonFileOperations get instance => _instance;
  static final JsonFileOperations _instance = JsonFileOperations._internal();
  JsonFileOperations._internal();

  Future<bool> offlineLoadSuppliersData() async {
    var storagePath = await Utils().getExternalStoragePath();
    final Directory directory =
        Directory("$storagePath${AppStrings.jsonFilesCache}/");

    File file = File(join(
      directory.path,
      'suppliers.json',
    ));
    if (!(await file.exists())) {
      return false;
    }
    String content =
        await getJsonFileContent(directory, fileName: 'suppliers.json');

    List<PartnerItem>? data = parseSupplierJson(content);

    if (data != null && data.isNotEmpty) {
      await appStorage.savePartnerList(data);
    }
    return (data != null && data.isNotEmpty);
  }

  Future<bool> offlineLoadCarriersData() async {
    var storagePath = await Utils().getExternalStoragePath();
    final Directory directory =
        Directory("$storagePath${AppStrings.jsonFilesCache}/");

    File file = File(join(
      directory.path,
      'carriers.json',
    ));
    if (!(await file.exists())) {
      return false;
    }

    String content =
        await getJsonFileContent(directory, fileName: 'carriers.json');

    List<CarrierItem>? data = parseCarrierJson(content);

    if (data != null && data.isNotEmpty) {
      await appStorage.saveCarrierList(data);
    }
    return (data != null && data.isNotEmpty);
  }

  Future<bool> offlineLoadCommodityData() async {
    var storagePath = await Utils().getExternalStoragePath();
    final Directory directory =
        Directory("$storagePath${AppStrings.jsonFilesCache}/");

    File file = File(join(
      directory.path,
      'commodity.json',
    ));
    if (!(await file.exists())) {
      return false;
    }

    String commodityJsonContent =
        await getJsonFileContent(directory, fileName: 'commodity.json');

    List<CommodityItem>? commodityDataList =
        await parseCommodityJson(commodityJsonContent);
    if (commodityDataList != null && commodityDataList.isNotEmpty) {
      await appStorage.saveCommodityList(commodityDataList);
    }
    List<DefectItem>? defectDataList =
        parseDefectListJson(commodityJsonContent);
    if (defectDataList != null && defectDataList.isNotEmpty) {
      await appStorage.saveDefectList(defectDataList);
    }

    List<SeverityDefect>? parseSeverityDefectList =
        parseSeverityDefectJson(commodityJsonContent);
    if (parseSeverityDefectList != null && parseSeverityDefectList.isNotEmpty) {
      await appStorage.saveSeverityDefectList(parseSeverityDefectList);
    }
    List<OfflineCommodity>? offlineCommodityIDList =
        parseOfflineCommodityID(commodityJsonContent);
    if (offlineCommodityIDList != null && offlineCommodityIDList.isNotEmpty) {
      await appStorage.saveOfflineCommodityList(offlineCommodityIDList);
    }

    return (commodityDataList != null && commodityDataList.isNotEmpty) &&
        (defectDataList != null && defectDataList.isNotEmpty) &&
        (parseSeverityDefectList != null &&
            parseSeverityDefectList.isNotEmpty) &&
        (offlineCommodityIDList != null && offlineCommodityIDList.isNotEmpty);
  }

  Future<String> getJsonFileContent(
    Directory directory, {
    required String fileName,
  }) async {
    String content = await File(join(
      directory.path,
      fileName,
    )).readAsString();
    return content;
  }

  List<PartnerItem>? parseSupplierJson(String response) {
    List<PartnerItem>? list;
    try {
      Map<String, dynamic> jsonResponse = json.decode(response);
      List<dynamic> partnersArray = jsonResponse["partners"];

      for (int i = 0; i < partnersArray.length; i++) {
        Map<String, dynamic> item = partnersArray[i];
        int id = item["id"];
        String name = item["name"];
        double redPercentage = item["redPercentage"];
        double yellowPercentage = item["yellowPercentage"];
        double orangePercentage = item["orangePercentage"];
        double greenPercentage = item["greenPercentage"];
        String recordType = item["recordType"];

        PartnerItem listItem = PartnerItem(
          id: id,
          name: name,
          redPercentage: redPercentage,
          yellowPercentage: yellowPercentage,
          orangePercentage: orangePercentage,
          greenPercentage: greenPercentage,
          recordType: recordType,
        );
        list ??= [];
        list.add(listItem);
      }
    } catch (e) {
      log(e.toString());
      return null;
    }
    return list;
  }

  List<CarrierItem>? parseCarrierJson(String response) {
    List<CarrierItem> list = [];

    try {
      Map<String, dynamic> jsonResponse = json.decode(response);
      List<dynamic> partnersArray = jsonResponse["partners"];

      for (int i = 0; i < partnersArray.length; i++) {
        Map<String, dynamic> item = partnersArray[i];
        int id = item["id"];
        String name = item["name"];
        double redPercentage = item["redPercentage"];
        double yellowPercentage = item["yellowPercentage"];
        double orangePercentage = item["orangePercentage"];
        double greenPercentage = item["greenPercentage"];
        String recordType = item["recordType"];

        CarrierItem listItem = CarrierItem(id, name, redPercentage,
            yellowPercentage, orangePercentage, greenPercentage, recordType);
        list.add(listItem);
      }
    } catch (e) {
      log("Error while parsing JSON: $e");
      return null;
    }

    return list;
  }

  Future<List<CommodityItem>?> parseCommodityJson(String response) async {
    List<CommodityItem>? list;
    var jsonResponse = jsonDecode(response);
    var commodityArray = jsonResponse['commodities'];

    for (var item in commodityArray) {
      List<DefectItem> defectList = [];
      List<SeverityDefect> severityDefectList = [];
      List<DocumentItem> documents = [];

      int id = item['id'];
      String name = item['name'];
      int? numberSamplesSet = item['numberSamplesSet'];
      int? sampleSizeByCount = item['minSampleSetByCount'];
      double? sampleSizeByWeight = item['sampleSizeByWeight'];
      String? keywords = item['keywords'];

      // Parsing defectList
      for (var defectItem in item['defectList']) {
        int dId = defectItem['id'];
        String? dName = defectItem['name'];
        String? dInstruction = defectItem['inspectionInstruction'];

        List<DefectInstructionAttachment> attachments = [];
        for (var attachmentObject in defectItem['attachments']) {
          DefectInstructionAttachment attachmentItem =
              DefectInstructionAttachment();
          attachmentItem.attachmentId = attachmentObject['attachmentId'];
          attachmentItem.url = attachmentObject['url'];
          attachmentItem.name = attachmentObject['name'];
          attachments.add(attachmentItem);
        }

        defectList.add(DefectItem(
            id: dId,
            name: dName,
            instruction: dInstruction,
            attachments: attachments));
      }

      // Parsing severityDefectList
      for (var severityDefectItem in item['severityDefectList']) {
        int sdId = severityDefectItem['id'];
        String? sdName = severityDefectItem['name'];
        severityDefectList.add(SeverityDefect(id: sdId, name: sdName));
      }

      // Parsing documents
      for (var documentItem in item['documents']) {
        String type = documentItem['type'];
        String? fileContent = documentItem['fileContent'];

        if (fileContent != null) {
          // Write file content to local storage (assuming you have file write permissions)
          String directoryPath =
              await Utils.createCommodityVarietyDocumentDirectory();
          File pdfFile = File('$directoryPath/${type}_$id.pdf');
          pdfFile.writeAsStringSync(fileContent);

          documents.add(DocumentItem(
              type: type,
              fileUrl: documentItem['fileURL'],
              filePath: pdfFile.path));
        }
      }

      list ??= [];
      list.add(CommodityItem(
          id: id,
          name: name,
          numberSamplesSet: numberSamplesSet,
          sampleSizeByCount: sampleSizeByCount,
          sampleSizeByWeight: sampleSizeByWeight,
          defectList: defectList,
          severityDefectList: severityDefectList,
          keywords: keywords,
          documents: documents));
    }

    return list;
  }

  List<DefectItem>? parseDefectListJson(String response) {
    List<DefectItem> list = [];
    var jsonResponse = jsonDecode(response);
    var defectArray = jsonResponse['defects'];

    for (var defectObject in defectArray) {
      List<DefectInstructionAttachment> attachments = [];
      String? name;
      int id = defectObject['id'];

      if (defectObject.containsKey('name')) {
        name = defectObject['name'];
      }

      String? instruction;
      if (defectObject.containsKey('inspectionInstruction')) {
        instruction = defectObject['inspectionInstruction'];
      }

      // Get the defect attachments
      if (defectObject.containsKey('attachments')) {
        for (var attachmentObject in defectObject['attachments']) {
          DefectInstructionAttachment attachmentItem =
              DefectInstructionAttachment();
          attachmentItem.attachmentId = attachmentObject['attachmentId'];
          attachmentItem.url = attachmentObject['url'];
          attachmentItem.name = attachmentObject['name'];

          // Add the defect attachment Id.
          attachments.add(attachmentItem);
        }
      }

      list.add(DefectItem(
          id: id,
          name: name,
          instruction: instruction,
          attachments: attachments));
    }

    return list;
  }

  List<SeverityDefect>? parseSeverityDefectJson(String response) {
    List<SeverityDefect>? list;
    var jsonResponse = jsonDecode(response);
    var defectArray = jsonResponse['severityDefects'];

    for (var defectObject in defectArray) {
      String? name;
      int id = defectObject['id'];

      if (defectObject.containsKey('name')) {
        name = defectObject['name'];
      }
      list ??= [];

      list.add(SeverityDefect(id: id, name: name));
    }

    return list;
  }

  List<OfflineCommodity>? parseOfflineCommodityID(String response) {
    List<OfflineCommodity>? list;
    var jsonObject = jsonDecode(response);
    var jsonResponse = jsonObject['commodities'];

    for (var item in jsonResponse) {
      int id = item['id'];
      String name = item['name'];
      String keywords = item['keywords'];
      list ??= [];
      list.add(OfflineCommodity(id: id, name: name, keywords: keywords));
    }
    return list;
  }

  Future<bool> offlineLoadSpecificationBannerData() async {
    var storagePath = await Utils().getExternalStoragePath();
    final Directory directory =
        Directory("$storagePath${AppStrings.jsonFilesCache}/");

    File file = File(join(
      directory.path,
      'specificationBannerData.json',
    ));
    if (!(await file.exists())) {
      return false;
    }

    String specificationBannerJsonContent = await getJsonFileContent(directory,
        fileName: 'specificationBannerData.json');

    List<CommodityVarietyData>? list;

    try {
      List<dynamic> jsonArray = jsonDecode(specificationBannerJsonContent);

      for (var element in jsonArray) {
        String specificationNumber = element['specificationNumber'];
        String specificationVersion = element['specificationVersion'];
        String commodityId = element['commodityId'];
        String varietyId = element['varietyId'];
        String varietyName = element['varietyName'];

        CommodityVarietyData commodityVarietyData =
            CommodityVarietyData(commodityId, varietyId, varietyName);

        if (element['documents'] != null) {
          for (var doc in element['documents']) {
            String type = doc['type'];
            String? fileContent = doc['fileContent'];

            DocumentItemData docItem = DocumentItemData(
                type: type, fileURL: doc['fileURL'], fileContent: fileContent);
            commodityVarietyData.addDocumentItem(docItem);

            File pdfFile = File(type == 'SPEC'
                ? 'SPEC_$commodityId.pdf'
                : 'OTHER_$commodityId.pdf');

            log(" inside commodityvarietyData - ${pdfFile.path}");
            if (fileContent != null) {
              pdfFile.writeAsStringSync(fileContent);
            }
          }
        }

        if (element['exception'] != null) {
          for (var ex in element['exception']) {
            String shortDescription = ex['shortDescription'];
            String longDescription = ex['longDescription'];
            String expirationDate = ex['expirationDateStr'];

            ExceptionItem exItem = ExceptionItem(
              shortDescription: shortDescription,
              longDescription: longDescription,
              expirationDate: expirationDate,
            );
            commodityVarietyData.addExceptionItem(exItem);
          }
        }

        String name = '${specificationNumber}_$specificationVersion';
        name = name.replaceAll(' ', '');
        String filename = '${'specificationBannerData'}_$name.json';

        File(filename).writeAsStringSync(jsonEncode(element));
        list ??= [];
        list.add(commodityVarietyData);
      }
    } catch (e) {
      log(e.toString());
      return false;
    }
    return list != null && list.isNotEmpty;
  }
}
