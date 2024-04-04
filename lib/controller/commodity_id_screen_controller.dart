import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/dialog_progress_controller.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/models/commodity_item.dart';
import 'package:pverify/models/inspection.dart';
import 'package:pverify/models/login_data.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/models/qc_header_details.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/ui/cache_download_screen.dart';
import 'package:pverify/ui/purchase_order/purchase_order_screen.dart';
import 'package:pverify/utils/app_snackbar.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/dialogs/update_data_dialog.dart';
import 'package:pverify/utils/utils.dart';

class CommodityIDScreenController extends GetxController {
  final PartnerItem partner;
  final CarrierItem carrier;
  CommodityIDScreenController({required this.partner, required this.carrier});

  final ScrollController scrollController = ScrollController();
  final AppStorage appStorage = AppStorage.instance;
  final GlobalConfigController globalConfigController =
      Get.find<GlobalConfigController>();
  final ApplicationDao dao = ApplicationDao();

  RxList<CommodityItem> filteredCommodityList = <CommodityItem>[].obs;
  RxList<CommodityItem> commodityList = <CommodityItem>[].obs;
  RxBool listAssigned = false.obs;

  double get listHeight => 130.h;

  @override
  void onInit() {
    super.onInit();
    assignInitialData();
  }

  Future<void> assignInitialData() async {
    LoginData? currentUser = appStorage.getLoginData();
    if (currentUser == null) {
      return;
    }
    int enterpriseId =
        await dao.getEnterpriseIdByUserId(currentUser.userName!.toLowerCase());

    List<CommodityItem>? _commoditiesList =
        await dao.getCommodityByPartnerFromTable(partner.id!, enterpriseId,
            currentUser.supplierId!, currentUser.headquarterSupplierId!);
    appStorage.saveMainCommodityList(_commoditiesList ?? []);

    if (_commoditiesList == null) {
      commodityList.value = [];
      filteredCommodityList.value = [];
      listAssigned.value = true;
      update(['commodityList']);
    } else {
      commodityList.value = [];
      filteredCommodityList.value = [];

      commodityList.addAll(_commoditiesList);

      commodityList.sort((a, b) => a.name!.compareTo(b.name!));

      filteredCommodityList.addAll(_commoditiesList);
      filteredCommodityList.sort((a, b) => a.name!.compareTo(b.name!));
      listAssigned.value = true;
      update(['commodityList']);
    }
  }

  void searchAndAssignCommodity(String searchValue) {
    filteredCommodityList.clear();
    if (searchValue.isEmpty) {
      filteredCommodityList.addAll(commodityList);
    } else {
      filteredCommodityList.value = commodityList
          .where((element) => element.keywords!
              .toLowerCase()
              .contains(searchValue.toLowerCase()))
          .toList();
    }
    update(['commodityList']);
  }

  List<String> getListOfAlphabets() {
    Set<String> uniqueAlphabets = {};

    for (CommodityItem supplier in commodityList) {
      if (supplier.name!.isNotEmpty &&
          supplier.name![0].toUpperCase().contains(RegExp(r'[A-Z0-9]'))) {
        uniqueAlphabets.add(supplier.name![0].toUpperCase());
      }
    }

    return uniqueAlphabets.toList();
  }

  void scrollToSection(String letter, int index) {
    int targetIndex = filteredCommodityList
        .indexWhere((supplier) => supplier.name!.startsWith(letter));
    if (targetIndex != -1) {
      scrollController.animateTo(
        (targetIndex * listHeight) + (index * (listHeight * .45)),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    }
  }

  void navigateToPurchaseOrderScreen(CommodityItem commodity) {
    Get.to(() => PurchaseOrderScreen(
        partner: partner, carrier: carrier, commodity: commodity));
  }

  Future<void> onDownloadTap() async {
    if (globalConfigController.hasStableInternet.value) {
      bool hasValue = await dao.checkInspections();
      if (hasValue) {
        UpdateDataAlert.showUpdateDataDialog(Get.context!,
            onOkPressed: () async {
          await uploadAllInspections();
        }, message: AppStrings.updateDataMessage);
      } else {
        Get.to(() => const CacheDownloadScreen());
      }
    } else {
      UpdateDataAlert.showUpdateDataDialog(Get.context!,
          onOkPressed: () async {}, message: AppStrings.downloadWifiError);
    }
  }

  Future<void> uploadAllInspections() async {
    List<int> uploadCheckedList = await dao.findReadyToUploadInspectionIDs();
    if (uploadCheckedList.isNotEmpty) {
      List<int> failedList = [];

      for (int i = 0; i < uploadCheckedList.length; i++) {
        Inspection? inspection =
            await dao.findInspectionByID(uploadCheckedList[i]);

        if (inspection?.commodityId == 0) {
          uploadCheckedList.removeAt(i);
          failedList.add(uploadCheckedList[i]);
        }
      }

      final progressController = Get.put(ProgressController());

      Utils.showLinearProgressWithMessage(
          message: AppStrings.uploadMessage,
          progressController: progressController);

      int numberOfInspections = uploadCheckedList.length;
      int listIndex = 0;
      int progressDialogStatus = 0;
      while (progressDialogStatus < numberOfInspections) {
        try {
          await uploadInspection(uploadCheckedList[listIndex]);
        } catch (e) {
          AppSnackBar.error(message: AppStrings.uploadError);
          Utils.hideLoadingDialog();
        }

        progressDialogStatus = ++listIndex;

        // Update the progress bar
        progressController.updateProgress(progressDialogStatus);

        if (progressDialogStatus >= numberOfInspections) {
          await Future.delayed(const Duration(seconds: 1));
          Utils.hideLoadingDialog();
        }
      }
    } else {
      List<int> incompleteInspectionList =
          await dao.getAllIncompleteInspectionIDs();

      for (int i = 0; i < incompleteInspectionList.length; i++) {
        await dao.deleteInspection(incompleteInspectionList.elementAt(i));
      }

      Get.to(() => const CacheDownloadScreen());
    }
  }

  Future<void> uploadInspection(int inspectionId) async {
    Inspection? inspection = await dao.findInspectionByID(inspectionId);
    if (inspection != null) {
      QCHeaderDetails? qcHeaderDetails =
          await dao.findTempQCHeaderDetails(inspection.poNumber!);
      if (qcHeaderDetails != null &&
          qcHeaderDetails.cteType != null &&
          qcHeaderDetails.cteType != "") {
        // TODO: Implement the below code for (WSUploadInspectionCTE, WSUploadMobileFilesCTE)
        /*// Start the webservice to upload the inspection
        Map<String, dynamic>? jsonObject =
            await WSUploadInspectionCTE.RequestUploadCTE(
                inspectionId, qcHeaderDetails.cteType);

        if (jsonObject != null) {
          WSUploadMobileFilesCTE.RequestUploadMobileFiles(
              null, jsonObject, inspectionId);
        }*/
      } else {
        // Start the webservice to upload the inspection

        // TODO: Implement the below code for (WSUploadInspection, WSUploadMobileFiles)
        /*Map<String, dynamic>? jsonObject =
            await requestUploadInspection(inspectionId);

        if (jsonObject != null) {
          List<InspectionDefectAttachment>? attachments =
              await dao.findDefectAttachmentsByInspectionId(inspectionId);

          requestUploadMobileFiles(attachments, jsonObject, inspectionId);
        }*/
      }
    }
  }

  /*Future<Map<String, dynamic>?> requestUploadMobileFiles(
      List<InspectionDefectAttachment>? attachments,
      Map<String, dynamic> jsonObject,
      int inspectionId) async {
    String requestString = "";
    if (attachments == null || attachments.isEmpty) {
      requestString = "?localPictureId=0";
    } else {
      requestString = "?localPictureId=0&";
    }
    for (int i = 0; i < (attachments?.length ?? 0); i++) {
      InspectionDefectAttachment att = attachments!.elementAt(i);
      requestString += "localPictureId=${att.attachmentId}";
      if (i < (attachments.length - 1)) {
        requestString += "&";
      }
    }
    String requestUrl =
        ApiUrls.serverUrl + ApiUrls.UPLOAD_MOBILE_FILES_REQUEST + requestString;

    List<InspectionAttachment> inspectionAttachments =
        await dao.findInspectionAttachmentsByInspectionId(inspectionId);

    Map<String, dynamic> jsonInspection2 =
        createInspectionAttachmentJSONRequest(
            inspectionAttachments, inspectionId);

    await doFileUpload(
      url: requestUrl,
      attachments: attachments,
      inspectionAttachments: inspectionAttachments,
      jsonInspection: jsonInspection,
      jsonInspection2: jsonInspection2,
      onUploadProgress: (int bytes, int total) {
        log("Uploading: $bytes/$total");
      },
    );
    // TODO: above method is not implemented, implement it
    return null;
  }*/

  /*Map<String, dynamic> createInspectionAttachmentJSONRequest(
      List<InspectionAttachment> inspectionAttachments,
      int? serverInspectionId) {
    List<Map<String, dynamic>> defectsArray = [];

    for (InspectionAttachment attachment in inspectionAttachments) {
      var dObj = {
        'inspectionId': serverInspectionId,
        'attachmentId': attachment.attachmentId,
        'attachmentTitle': attachment.title,
      };
      defectsArray.add(dObj);
    }

    var jsonObj = {'attachments': defectsArray};
    return jsonObj;
  }*/

  /*Future<String> doFileUpload({
    required String url,
    required List<File> attachments,
    required List<File> inspectionAttachments,
    required Map<String, dynamic> jsonInspection,
    required Map<String, dynamic> jsonInspection2,
    OnUploadProgressCallback? onUploadProgress,
  }) async {
    Dio dio = Dio();

    // Create a FormData
    FormData? formData = FormData();

    // Add the inspection JSON as a file
    File inspectionFile =
        File('${(await getTemporaryDirectory()).path}/inspection.txt');
    await inspectionFile.writeAsString(jsonEncode(jsonInspection));
    formData.files.add(MapEntry(
      "file",
      MultipartFile(inspectionFile.path, filename: "inspection.txt"),
    ));

    // Add attachments
    for (File attachment in attachments) {
      String fileName = attachment.path.split('/').last;
      formData.files.add(MapEntry(
        "file",
        MultipartFile(attachment.path, filename: fileName),
      ));
    }

    // Add inspectionAttachments
    for (File inspectionAttachment in inspectionAttachments) {
      String fileName = inspectionAttachment.path.split('/').last;
      formData.files.add(MapEntry(
        "inspectionAttachments",
        MultipartFile(inspectionAttachment.path, filename: fileName),
      ));
    }

    // Add the inspectionAttachments JSON as a file
    File inspectionFile2 =
        File('${(await getTemporaryDirectory()).path}/inspection2.txt');
    await inspectionFile2.writeAsString(jsonEncode(jsonInspection2));
    formData.files.add(MapEntry(
      "inspectionAttachments",
      MultipartFile(inspectionFile2.path, filename: "inspection2.txt"),
    ));

    Map<String, dynamic> headerData = {
      "Accept": "application/json",
    };
    try {
      Response<dynamic> response = (await FileService.uploadFileWithProgress(
          url, fileResult, headerData: headerData,
          onUploadProgress: (int bytes, int total) {
        if (onUploadProgress != null) {
          onUploadProgress(bytes, total);
        }
      })) as Response;

      // if (response == null) {
      //   return "Error: Response is null";
      // }
      // Check the response status code
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body.toString();
      } else {
        print("Failed with status code: ${response.statusCode}");
        return "Error: Failed with status code: ${response.statusCode}";
      }
    } on DioException catch (e) {
      print("DioError: ${e.message}");
      return "DioError: ${e.message}";
    } catch (e) {
      print("Error: $e");
      return "Error: $e";
    }
  }*/

  /*Future<Map<String, dynamic>> requestUploadInspection(int inspectionId) async {
    Map<String, dynamic> jsonObj = await createJSONRequest(inspectionId);
  }*/

  /*Future<Map<String, dynamic>> createJSONRequest(int inspectionId) async {
    // Mocked methods to fetch data, replace with your actual data fetching logic
    final Inspection? inspection = await dao.findInspectionByID(inspectionId);
    final Specification? specification =
        await dao.findSpecificationByInspectionId(inspectionId);
    final QualityControlItem? qualityControl =
        await dao.findQualityControlDetails(inspectionId);
    final List<TrailerTemperatureItem> trailerTemps =
        await dao.findListTrailerTemperatureItems(inspectionId);
    final List<InspectionSample> samplesList =
        await dao.findInspectionSamples(inspectionId);
    final List<SpecificationAnalyticalRequest>
        specificationAnalyticalRequestList =
        await dao.findSpecificationAnalyticalRequest(inspectionId);
    final OverriddenResult? overriddenResult =
        await dao.getOverriddenResult(inspectionId);
    // Assuming similar data model classes exist in Dart

    QCHeaderDetails qcHeaderDetails =
        await dao.findTempQCHeaderDetails(inspection!.poNumber!) ??
            QCHeaderDetails();

    final Map<String, dynamic> jsonObj = {
      'localInspectionId': inspection.inspectionId,
      // Assuming app version fetching logic is handled elsewhere or hardcoded
      'appVersion': '1.0.0',
      'inspectionId': inspection.serverInspectionId,
      // Add other properties as needed
      'qualityControl': {
        'userId': inspection.userId,
        'createdDate': inspection.createdTime,
        'completedTimestamp': inspection.completedTime,
        // Add other QC related fields
      },
      // Similarly add other parts of the JSON as needed
    };

    // Specifying analyticals, you would follow a similar pattern
    final List<Map<String, dynamic>> specAnalyticalArray = [];
    for (final specObj in specificationAnalyticalRequestList) {
      specAnalyticalArray.add({
        'analyticalID': specObj.analyticalID,
        'comply': specObj.comply == 'N/A' ? '' : specObj.comply,
        'sampleValue': specObj.sampleNumValue,
        // Add other fields
      });
    }
    jsonObj['qualityControl']['specificationAnalyticals'] = specAnalyticalArray;

    // Trailer temperatures and other arrays are handled similarly

    // Logging converted JSON for debugging
    print(jsonEncode(jsonObj));

    return jsonObj;
  }*/
}
