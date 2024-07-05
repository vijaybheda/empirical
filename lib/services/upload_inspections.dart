import 'package:get/get.dart';
import 'package:pverify/controller/dialog_progress_controller.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/models/inspection.dart';
import 'package:pverify/models/inspection_defect_attachment.dart';
import 'package:pverify/models/qc_header_details.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/services/network_request_service/ws_upload_inspection.dart';
import 'package:pverify/services/network_request_service/ws_upload_mobile_files.dart';
import 'package:pverify/ui/cache_download_screen.dart';
import 'package:pverify/utils/app_snackbar.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/dialogs/update_data_dialog.dart';
import 'package:pverify/utils/utils.dart';

class UploadInspections {
  final AppStorage appStorage = AppStorage.instance;
  final GlobalConfigController globalConfigController =
      Get.find<GlobalConfigController>();
  final ApplicationDao dao = ApplicationDao();

  Future<void> onDownloadTap({Function()? onUpdateAppCallback}) async {
    if (globalConfigController.hasStableInternet.value) {
      bool hasValue = await dao.checkInspections();
      if (hasValue) {
        UpdateDataAlert.showUpdateDataDialog(Get.context!,
            onOkPressed: () async {
          await uploadAllInspections(onUpdateAppCallback: onUpdateAppCallback);
        }, message: AppStrings.updateDataMessage);
      } else {
        if (onUpdateAppCallback != null) {
          onUpdateAppCallback();
          // appUpdateFunction
        } else {
          Get.off(() => const CacheDownloadScreen());
        }
      }
    } else {
      UpdateDataAlert.showUpdateDataDialog(Get.context!,
          onOkPressed: () async {}, message: AppStrings.downloadWifiError);
    }
  }

  Future<void> uploadAllInspections({Function()? onUpdateAppCallback}) async {
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
      int numberOfInspections = uploadCheckedList.length;
      Utils.showLinearProgressWithMessage(
        message: AppStrings.uploadMessage,
        progressController: progressController,
        totalInspection: numberOfInspections,
      );

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
        progressController.updateProgress(progressDialogStatus.toDouble());

        if (progressDialogStatus >= numberOfInspections) {
          await Future.delayed(const Duration(milliseconds: 500));
          Utils.hideLoadingDialog();
          if (onUpdateAppCallback != null) {
            onUpdateAppCallback();
          }
        }
      }
    } else {
      List<int> incompleteInspectionList =
          await dao.getAllIncompleteInspectionIDs();

      for (int i = 0; i < incompleteInspectionList.length; i++) {
        await dao.deleteInspection(incompleteInspectionList.elementAt(i));
      }

      if (onUpdateAppCallback != null) {
        onUpdateAppCallback();
      } else {
        Get.off(() => const CacheDownloadScreen());
      }
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
        // TODO: Implement CTE flow
      } else {
        Map<String, dynamic>? jsonObject =
            await WSUploadInspection().requestUpload(inspectionId);

        if (jsonObject.isNotEmpty) {
          List<InspectionDefectAttachment>? attachments =
              await dao.findDefectAttachmentsByInspectionId(inspectionId);

          var isApiCallSuccess = await WSUploadMobileFiles(
            inspectionId,
            attachments ?? [],
            jsonObject,
          ).requestUploadMobileFiles(
            attachments ?? [],
            jsonObject,
            inspectionId,
          );
        }
      }
    }
  }
}
