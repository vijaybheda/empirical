import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart';
import 'package:pverify/models/brand_item.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/models/commodity_item.dart';
import 'package:pverify/models/commodity_variety_data.dart';
import 'package:pverify/models/country_item.dart';
import 'package:pverify/models/defect_categories.dart';
import 'package:pverify/models/defect_instruction_attachment.dart';
import 'package:pverify/models/defect_item.dart';
import 'package:pverify/models/delivery_to_item.dart';
import 'package:pverify/models/document_item.dart';
import 'package:pverify/models/document_item_data.dart';
import 'package:pverify/models/exception_item.dart';
import 'package:pverify/models/offline_commodity.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/models/reason_item.dart';
import 'package:pverify/models/severity.dart';
import 'package:pverify/models/severity_defect.dart';
import 'package:pverify/models/uom_item.dart';
import 'package:pverify/utils/app_snackbar.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/utils.dart';

class JsonFileOperations {
  final AppStorage _appStorage = AppStorage.instance;

  static JsonFileOperations get instance => _instance;
  static final JsonFileOperations _instance = JsonFileOperations._internal();
  JsonFileOperations._internal();

  Future<bool> offlineLoadSuppliersData() async {
    var storagePath = await Utils().getExternalStoragePath();
    final Directory directory =
        Directory("$storagePath${FileManString.jsonFilesCache}/");

    File file = File(join(
      directory.path,
      FileManString.suppliersJson,
    ));
    if (!(await file.exists())) {
      return false;
    }
    String content = await getJsonFileContent(directory,
        fileName: FileManString.suppliersJson);

    List<PartnerItem>? data = parseSupplierJson(content);

    if (data != null && data.isNotEmpty) {
      await _appStorage.savePartnerList(data);
    }
    return (data != null && data.isNotEmpty);
  }

  Future<bool> offlineLoadDeliveredFrom() async {
    var storagePath = await Utils().getExternalStoragePath();
    final Directory directory =
        Directory("$storagePath${FileManString.jsonFilesCache}/");

    File file =
        File(join(directory.path, FileManString.DELIVERYTO_JSON_FILENAME));
    if (!(await file.exists())) {
      return false;
    }

    String content = await file.readAsString();

    List<DeliveryToItem>? data = parseDeliveryToJson(content);

    if (data != null && data.isNotEmpty) {
      await _appStorage.saveDeliveredList(data);
    }

    return (data != null && data.isNotEmpty);
  }

  Future<bool> offlineLoadCarriersData() async {
    var storagePath = await Utils().getExternalStoragePath();
    final Directory directory =
        Directory("$storagePath${FileManString.jsonFilesCache}/");

    File file = File(join(
      directory.path,
      FileManString.carriersJson,
    ));
    if (!(await file.exists())) {
      return false;
    }

    String content = await getJsonFileContent(directory,
        fileName: FileManString.carriersJson);

    List<CarrierItem>? data = parseCarrierJson(content);

    if (data != null && data.isNotEmpty) {
      await _appStorage.saveCarrierList(data);
    }
    return (data != null && data.isNotEmpty);
  }

  Future<bool> offlineLoadCommodityData() async {
    var storagePath = await Utils().getExternalStoragePath();
    final Directory directory =
        Directory("$storagePath${FileManString.jsonFilesCache}/");

    File file = File(join(
      directory.path,
      FileManString.commodityJson,
    ));
    if (!(await file.exists())) {
      return false;
    }

    String commodityJsonContent = await getJsonFileContent(directory,
        fileName: FileManString.commodityJson);

    List<CommodityItem>? commodityDataList =
        await parseCommodityJson(commodityJsonContent);
    if (commodityDataList != null && commodityDataList.isNotEmpty) {
      await _appStorage.saveCommodityList(commodityDataList);
    }
    List<DefectItem>? defectDataList =
        parseDefectListJson(commodityJsonContent);
    if (defectDataList != null && defectDataList.isNotEmpty) {
      await _appStorage.saveDefectList(defectDataList);
    }

    List<SeverityDefect>? parseSeverityDefectList =
        parseSeverityDefectJson(commodityJsonContent);
    if (parseSeverityDefectList != null && parseSeverityDefectList.isNotEmpty) {
      await _appStorage.saveSeverityDefectList(parseSeverityDefectList);
    }
    List<OfflineCommodity>? offlineCommodityIDList =
        parseOfflineCommodityID(commodityJsonContent);
    if (offlineCommodityIDList != null && offlineCommodityIDList.isNotEmpty) {
      await _appStorage.saveOfflineCommodityList(offlineCommodityIDList);
    }

    return (commodityDataList != null && commodityDataList.isNotEmpty) &&
        (defectDataList != null && defectDataList.isNotEmpty) &&
        (parseSeverityDefectList != null &&
            parseSeverityDefectList.isNotEmpty) &&
        (offlineCommodityIDList != null && offlineCommodityIDList.isNotEmpty);
  }

  Future<bool> offlineLoadSeverities(String commodityId) async {
    String filename = 'SEV_$commodityId.json';
    var storagePath = await Utils().getExternalStoragePath();
    final Directory directory =
        Directory("$storagePath${FileManString.jsonFilesCache}/");

    File file = File(join(
      directory.path,
      filename,
    ));
    if (!(await file.exists())) {
      return false;
    }

    String content = await getJsonFileContent(directory, fileName: filename);
    _appStorage.severityList = parseSeverityJson(content);
    return true;
  }

  List<Severity> parseSeverityJson(String response) {
    List<Severity> list = [];
    var jsonResponse = jsonDecode(response);
    for (var item in jsonResponse) {
      Severity severity = Severity.fromJson(item);
      list.add(severity);
    }
    return list;
  }

  Future<bool> offlineLoadDefectCategories() async {
    String filename = 'defectcategories.json';
    var storagePath = await Utils().getExternalStoragePath();
    final Directory directory =
        Directory("$storagePath${FileManString.jsonFilesCache}/");

    File file = File(join(
      directory.path,
      filename,
    ));
    if (!(await file.exists())) {
      return false;
    }

    String content = await getJsonFileContent(directory, fileName: filename);
    _appStorage.defectCategoriesList = parseDefectCategoriesJson(content);
    return true;
  }

  List<DefectCategories> parseDefectCategoriesJson(String response) {
    List<DefectCategories> list = [];
    var jsonResponse = jsonDecode(response);
    for (var item in jsonResponse) {
      DefectCategories defectCategory = DefectCategories.fromJson(item);
      list.add(defectCategory);
    }
    return list;
  }

  static Future<String> getJsonFileContent(
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
        int? id = item["id"];
        String? name = item["name"];
        double? redPercentage = item["redPercentage"];
        double? yellowPercentage = item["yellowPercentage"];
        double? orangePercentage = item["orangePercentage"];
        double? greenPercentage = item["greenPercentage"];
        String? recordType = item["recordType"];

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

  List<DeliveryToItem>? parseDeliveryToJson(String response) {
    List<DeliveryToItem>? list = [];
    try {
      List<dynamic> deliveryToArray = jsonDecode(response);

      for (int i = 0; i < deliveryToArray.length; i++) {
        Map<String, dynamic> item = deliveryToArray[i];
        int id = item['partnerID'];
        String name = item['partnerName'];

        DeliveryToItem listItem = DeliveryToItem(id, name);
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
        int? id = item["id"];
        String? name = item["name"];
        double? redPercentage = item["redPercentage"];
        double? yellowPercentage = item["yellowPercentage"];
        double? orangePercentage = item["orangePercentage"];
        double? greenPercentage = item["greenPercentage"];
        String? recordType = item["recordType"];

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

    log('parseCommodityJson of commodities called');
    for (var item in commodityArray) {
      List<DefectItem> defectList = [];
      List<SeverityDefect> severityDefectList = [];
      List<DocumentItem> documents = [];

      int? id = item['id'];
      String? name = item['name'];
      int? numberSamplesSet = item['numberSamplesSet'];
      int? sampleSizeByCount = item['minSampleSetByCount'];
      double? sampleSizeByWeight = item['sampleSizeByWeight'];
      String? keywords = item['keywords'];

      log('parseCommodityJson of defectList called');

      // Parsing defectList
      for (var defectItem in item['defectList']) {
        int? dId = defectItem['id'];
        String? dName = defectItem['name'];
        String? dInstruction = defectItem['inspectionInstruction'];

        List<DefectInstructionAttachment> attachments = [];
        int l = 0;
        for (var attachmentObject in defectItem['attachments']) {
          l = l++;
          DefectInstructionAttachment attachmentItem =
              DefectInstructionAttachment();
          attachmentItem.attachmentId = attachmentObject['attachmentId'];
          attachmentItem.url = attachmentObject['url'];
          attachmentItem.name = attachmentObject['name'];

          String fileContent = attachmentObject["fileContent"];

          List<int> bytes = base64Decode(fileContent);

          String directoryPath =
              await Utils.createCommodityVarietyDocumentDirectory();
          File pdfFile =
              File('$directoryPath/instruction_${id}_$dId${l - 1}.png');

          await pdfFile.writeAsBytes(bytes);

          attachments.add(attachmentItem);
        }

        defectList.add(DefectItem(
            id: dId,
            name: dName,
            inspectionInstruction: dInstruction,
            attachments: attachments));
      }

      // Parsing severityDefectList
      for (var severityDefectItem in item['severityDefectList']) {
        int? sdId = severityDefectItem['id'];
        String? sdName = severityDefectItem['name'];
        severityDefectList.add(SeverityDefect(id: sdId, name: sdName));
      }

      log('parseCommodityJson of documents called');
      // Parsing documents
      for (var documentItem in item['documents']) {
        String? type = documentItem['type'];
        String? fileContent = documentItem['fileContent'];

        if (fileContent != null) {
          // Write file content to local storage (assuming you have file write permissions)
          String directoryPath =
              await Utils.createCommodityVarietyDocumentDirectory();
          File pdfFile = File('$directoryPath/${type}_$id.pdf');
          // await pdfFile.writeAsString(fileContent);
          base64ToFile(fileContent, pdfFile.path);

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
    log('parseDefectListJson called');
    for (var defectObject in defectArray) {
      List<DefectInstructionAttachment> attachments = [];
      String? name;
      int? id = defectObject['id'];

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
          inspectionInstruction: instruction,
          attachments: attachments));
    }

    return list;
  }

  List<SeverityDefect>? parseSeverityDefectJson(String response) {
    List<SeverityDefect>? list;
    var jsonResponse = jsonDecode(response);
    var defectArray = jsonResponse['severityDefects'];
    log('parseSeverityDefectJson called');
    for (var defectObject in defectArray) {
      String? name;
      int? id = defectObject['id'];

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
    log('parseOfflineCommodityID called');
    for (var item in jsonResponse) {
      int? id = item['id'];
      String? name = item['name'];
      String? keywords = item['keywords'];
      list ??= [];
      list.add(OfflineCommodity(id: id, name: name, keywords: keywords));
    }
    return list;
  }

  Future<bool> offlineLoadSpecificationBannerData() async {
    var storagePath = await Utils().getExternalStoragePath();
    final Directory directory =
        Directory("$storagePath${FileManString.jsonFilesCache}/");

    File file = File(join(
      directory.path,
      FileManString.specificationBannerDataJson,
    ));
    if (!(await file.exists())) {
      return false;
    }

    String specificationBannerJsonContent = await getJsonFileContent(directory,
        fileName: FileManString.specificationBannerDataJson);

    List<CommodityVarietyData>? list;

    try {
      List<dynamic> jsonArray = jsonDecode(specificationBannerJsonContent);

      log('offlineLoadSpecificationBannerData called');
      for (var element in jsonArray) {
        String? specificationNumber = element['specificationNumber'];
        String? specificationVersion = element['specificationVersion'];
        int? commodityId = element['commodityId'];
        int? varietyId = element['varietyId'];
        String? varietyName = element['varietyName'];

        CommodityVarietyData commodityVarietyData = CommodityVarietyData(
          commodityId: commodityId,
          varietyId: varietyId,
          varietyName: varietyName,
        );

        if (element['documents'] != null) {
          for (var doc in element['documents']) {
            String? type = doc['type'];
            String? fileContent = doc['fileContent'];

            DocumentItemData docItem = DocumentItemData(
                type: type, fileURL: doc['fileURL'], fileContent: fileContent);
            commodityVarietyData.addDocumentItem(docItem);

            File pdfFile = File(join(
                directory.path,
                type == 'SPEC'
                    ? 'SPEC_$commodityId.pdf'
                    : 'OTHER_$commodityId.pdf'));

            if (fileContent != null) {
              pdfFile.writeAsStringSync(fileContent);
            }
          }
        }

        if (element['exception'] != null) {
          for (var ex in element['exception']) {
            String? shortDescription = ex['shortDescription'];
            String? longDescription = ex['longDescription'];
            String? expirationDate = ex['expirationDateStr'];

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
        String filename = FileManString.COMMODITYDOCS_JSON_STRING_FORMAT
            .replaceAll('%s', name);

        await File(join(directory.path, filename))
            .writeAsString(jsonEncode(element));
        list ??= [];
        list.add(commodityVarietyData);
      }
    } catch (e) {
      log(e.toString());
      return false;
    }
    return list != null && list.isNotEmpty;
  }

  File base64ToFile(String base64String, String filePath) {
    List<int> bytes = base64.decode(base64String);

    File file = File(filePath);
    file.writeAsBytesSync(bytes);

    return file;
  }

  static CommodityVarietyData? parseCommodityToolbarDataJson(String response) {
    CommodityVarietyData? commodityVarietyData;

    try {
      Map<String, dynamic> jsonResponse = json.decode(response);
      int? commodityId = jsonResponse['commodityId'];
      int? varietyId = jsonResponse['varietyId'];
      String? varietyName = jsonResponse['varietyName'];

      commodityVarietyData = CommodityVarietyData(
          commodityId: commodityId,
          varietyId: varietyId,
          varietyName: varietyName);

      List<dynamic>? documentsArray = jsonResponse['documents'];
      if (documentsArray != null) {
        for (int i = 0; i < documentsArray.length; i++) {
          Map<String, dynamic>? item = documentsArray[i];
          if (item != null) {
            String? type = item['type'];
            commodityVarietyData.addDocumentItem(
                DocumentItemData(type: type, fileURL: item['fileURL']));
          }
        }
      }

      List<dynamic>? exceptionArray = jsonResponse['exception'];
      if (exceptionArray != null) {
        for (int i = 0; i < exceptionArray.length; i++) {
          Map<String, dynamic>? item = exceptionArray[i];
          if (item != null) {
            String? shortDescription = item['shortDescription'];
            String? longDescription = item['longDescription'];
            String? expirationDate = item['expirationDateStr'];

            commodityVarietyData.addExceptionItem(ExceptionItem(
                shortDescription: shortDescription,
                longDescription: longDescription,
                expirationDate: expirationDate));
          }
        }
      }
    } catch (e) {
      log('failed to parseCommodityToolbarDataJson ${e.toString()}');
      return null;
    }

    return commodityVarietyData;
  }

  static Future<List<UOMItem>?> parseUOMJson() async {
    var storagePath = await Utils().getExternalStoragePath();
    final Directory directory =
        Directory("$storagePath${FileManString.jsonFilesCache}/");
    log('UOMJson directory ${directory.path}');

    String jsonLoadText = await getJsonFileContent(directory,
        fileName: FileManString.UOM_FILENAME);

    List<UOMItem> list = [];
    try {
      List<dynamic> uomArray = jsonDecode(jsonLoadText);
      for (int i = 0; i < uomArray.length; i++) {
        int? id = uomArray[i]['uomID'];
        String? name = uomArray[i]['uomName'];

        UOMItem listItem = UOMItem(id, name);
        list.add(listItem);
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
    return list;
  }

  static Future<List<BrandItem>?> parseBrandJson() async {
    var storagePath = await Utils().getExternalStoragePath();
    final Directory directory =
        Directory("$storagePath${FileManString.jsonFilesCache}/");
    log('BrandJson directory ${directory.path}');

    String jsonLoadText = await getJsonFileContent(directory,
        fileName: FileManString.BRAND_FILENAME);

    List<BrandItem> list = [];
    try {
      List<dynamic> brandArray = jsonDecode(jsonLoadText);
      for (int i = 0; i < brandArray.length; i++) {
        int? id = brandArray[i]['brandID'];
        String? name = brandArray[i]['brandName'];

        BrandItem listItem = BrandItem(brandID: id, brandName: name);
        list.add(listItem);
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
    return list;
  }

  static Future<List<CountryItem>?> parseCountryJson() async {
    var storagePath = await Utils().getExternalStoragePath();
    final Directory directory =
        Directory("$storagePath${FileManString.jsonFilesCache}/");
    log('CountryJson directory ${directory.path}');
    String jsonLoadText = await getJsonFileContent(directory,
        fileName: FileManString.COUNTRY_FILENAME);

    List<CountryItem> list = [];

    try {
      List<dynamic> countryArray = jsonDecode(jsonLoadText);
      for (int i = 0; i < countryArray.length; i++) {
        int id = countryArray[i]['countryID'];
        String name = countryArray[i]['countryName'];

        CountryItem listItem = CountryItem(id, name);
        list.add(listItem);
      }
    } catch (e) {
      print(e.toString());
    }

    return list;
  }

  static Future<List<ReasonItem>?> parseReasonJson() async {
    var storagePath = await Utils().getExternalStoragePath();
    final Directory directory =
        Directory("$storagePath${FileManString.jsonFilesCache}/");
    log('CountryJson directory ${directory.path}');
    String jsonLoadText = await getJsonFileContent(directory,
        fileName: FileManString.REASON_FILENAME);
    List<ReasonItem> list = [];

    try {
      List<dynamic> reasonArray = jsonDecode(jsonLoadText);
      for (int i = 0; i < reasonArray.length; i++) {
        int id = reasonArray[i]['reasonID'];
        String name = reasonArray[i]['reasonName'];

        ReasonItem listItem = ReasonItem(id, name);
        list.add(listItem);
      }
    } catch (e) {
      print(e.toString());
    }

    return list;
  }

  static String? jsonLoadTextFile(String path) {
    StringBuffer buf = StringBuffer();
    try {
      File file = File(path);
      if (file.existsSync()) {
        // Read the file using a StreamReader with UTF-8 encoding
        file
            .openRead()
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .forEach((line) {
          buf.write(line);
        });
      } else {
        debugPrint('File not found: $path');
        return null;
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
    return buf.toString();
  }

  Future<void> viewGradePdf() async {
    return await _viewPdf(isGradePdf: true);
  }

  Future<void> viewSpecInsPdf() async {
    return await _viewPdf(isGradePdf: false);
  }

  Future<void> _viewPdf({required bool isGradePdf}) async {
    String filename2 = '';
    if (!isGradePdf) {
      filename2 =
          "II_${AppStorage.instance.commodityVarietyData?.commodityId.toString()}.pdf";
    } else {
      filename2 =
          "GRADE_${AppStorage.instance.commodityVarietyData?.commodityId.toString()}.pdf";
    }

    var storagePath = await Utils().getExternalStoragePath();
    final Directory directory =
        Directory("$storagePath${FileManString.commodityVarietyDocument}/");

    String path2 = '${directory.path}/$filename2';
    File fileLocation2 = File(path2);

    if (await fileLocation2.exists()) {
      // final Uri data2 = Uri.file(path2);
      // bool hasStorageAccess = await _grantPermissions(data2);
      // if (hasStorageAccess) {
      await openFile(path2);
      // } else {
      //   AppSnackBar.error(message: AppStrings.noStoragePermission);
      // }
    } else {
      AppSnackBar.info(
          message: isGradePdf
              ? AppStrings.noGradeDocument
              : AppStrings.noSpecificationInstructions);
    }
  }

  /*Future<bool> _grantPermissions(Uri uri) async {
    final permissions = <Permission>[Permission.storage];
    for (final permission in permissions) {
      if (await permission.status.isGranted) continue;
      await permission.request();
    }
    return await permissions.first.status.isGranted;
  }*/

  Future<bool> openFile(String filePath) async {
    File file = File(filePath);
    if (await file.exists()) {
      OpenResult resultType = await OpenFile.open(filePath);
      return resultType.type == ResultType.done;
    } else {
      return false;
    }
  }
}
