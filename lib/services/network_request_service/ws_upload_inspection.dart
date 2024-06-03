import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/models/inspection.dart';
import 'package:pverify/models/inspection_defect.dart';
import 'package:pverify/models/inspection_defect_attachment.dart';
import 'package:pverify/models/inspection_sample.dart';
import 'package:pverify/models/overridden_result_item.dart';
import 'package:pverify/models/qc_header_details.dart';
import 'package:pverify/models/quality_control_item.dart';
import 'package:pverify/models/result_rejection_details.dart';
import 'package:pverify/models/specification.dart';
import 'package:pverify/models/specification_analytical_request_item.dart';
import 'package:pverify/models/trailer_temperature_item.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/services/network_request_service/api_urls.dart';
import 'package:pverify/ui/trailer_temp/trailertemprature_details.dart';

class WSUploadInspection {
  final int milliseconds = ApiUrls().webServiceTimeout;
  String parsedString = '';
  final String request = ApiUrls.UPLOAD_INSPECTION_REQUEST;
  final ApplicationDao dao = ApplicationDao();
  int? inspectionId;

  final GlobalConfigController globalConfigController =
      Get.find<GlobalConfigController>();
  WSUploadInspection();

  Future<Map<String, dynamic>> requestUpload(int inspectionId) async {
    this.inspectionId = inspectionId;
    Map<String, dynamic> jsonObj = await createJSONRequest();
    return jsonObj;
  }

  Future<Map<String, dynamic>> createJSONRequest() async {
    Inspection? inspection = await dao.findInspectionByID(inspectionId!);
    Specification? specification =
        await dao.findSpecificationByInspectionId(inspectionId!);
    QualityControlItem? qualityControl =
        await dao.findQualityControlDetails(inspectionId!);
    List<TrailerTemperatureItem> trailerTemps =
        await dao.findListTrailerTemperatureItems(inspectionId!);
    List<InspectionSample> samplesList =
        await dao.findInspectionSamples(inspectionId!);
    List<SpecificationAnalyticalRequest> specificationAnalyticalRequestList =
        await dao.findSpecificationAnalyticalRequest(inspectionId!);

    OverriddenResult? overriddenResult =
        await dao.getOverriddenResult(inspectionId!);
    QCHeaderDetails? qcHeaderDetails;

    if (inspection != null) {
      qcHeaderDetails = await dao.findTempQCHeaderDetails(inspection.poNumber!);
    }

    TrailerTemperatureDetails trailerTemperatureDetails =
        await dao.findTrailerTemperatureDetails(inspectionId!);

    ResultRejectionDetail? resultRejectionDetail =
        await dao.getResultRejectionDetails(inspectionId!);

    Map<String, dynamic> jsonObj = {};

    try {
      jsonObj['localInspectionId'] = inspection?.inspectionId;

      String appVersion = globalConfigController.appVersion.value;
      jsonObj['appVersion'] = appVersion;

      jsonObj['inspectionId'] = inspection?.serverInspectionId;

      // qualityControl
      Map<String, dynamic> qcObj = {
        'userId': inspection?.userId,
        'createdDate': inspection?.createdTime,
        'completedTimestamp': inspection?.completedTime,
        'status': 'IP', // inspection.status
        'reasonId': qualityControl?.reasonID,
        'result': inspection?.result,
        'managerStatus': inspection?.managerStatus,
        'managerComment': inspection?.managerComment,
        'quantityReceived': qualityControl?.qtyReceived,
        'packDate': qualityControl?.packDate,
        'contactName': '',
        'contactPhoneNumber': '',
        'inspectionComments': '',
        'qualityControlComments': qualityControl?.qcComments,
        'partnerComment': '',
        'claimFiledAgainst': qualityControl?.claimFiledAgainst,
        'completed': (inspection?.complete == '1').toString(),
        'quantityRejected': qualityControl?.qtyRejected,
        'unitOfMeasureReceivedId': qualityControl?.uomQtyReceivedID,
        'unitOfMeasureRejectedId': qualityControl?.uomQtyRejectedID,
        'supplierId': inspection?.partnerId,
        'gtin': qualityControl?.gtin,
        'dateType': qualityControl?.dateType,
        'pulpTemperatureMin': qualityControl?.pulpTempMin,
        'pulpTemperatureMax': qualityControl?.pulpTempMax,
        'recorderTemperatureMin': qualityControl?.recorderTempMin,
        'recorderTemperatureMax': qualityControl?.recorderTempMax,
        'carrierId': inspection?.carrierId,
        'deliverToId': null,
        'commodityId': inspection?.commodityId,
        'itemGroup1Id': inspection?.varietyId,
        'brandId': qualityControl?.brandID,
        'gradeId': inspection?.gradeId,
        'itemSkuId': inspection?.itemSKUId,
        'rpc': qualityControl?.rpc,
        'countryId': qualityControl?.originID,
        'lot': qualityControl?.lot,
        'quantityShipped': qualityControl?.qtyShipped,
        'unitOfMeasureShippedId': qualityControl?.uomQtyShippedID,
        'specificationNumber': specification?.name,
        'specificationVersion': specification?.value,
      };

      if (overriddenResult != null) {
        qcObj['overriddenResult'] = overriddenResult.oldResult;
        qcObj['overrriddenComments'] = overriddenResult.overrriddenComments;
        qcObj['overriddenBy'] = overriddenResult.overriddenBy;
        qcObj['overriddenTimestamp'] = overriddenResult.overriddenTimestamp;
        qcObj['originalQuantityAccepted'] = overriddenResult.originalQtyShipped;
        qcObj['originalQuantityRejected'] =
            overriddenResult.originalQtyRejected;
      } else {
        qcObj['overriddenResult'] = '';
        qcObj['overrriddenComments'] = '';
        qcObj['overriddenBy'] = null;
        qcObj['overriddenTimestamp'] = null;
      }

      if (resultRejectionDetail != null) {
        String rejectionDetail;
        if (resultRejectionDetail.defectComments != null &&
            resultRejectionDetail.defectComments!.isNotEmpty) {
          rejectionDetail =
              '${resultRejectionDetail.resultReason}\n \u25BA${resultRejectionDetail.defectComments}';
        } else {
          rejectionDetail = resultRejectionDetail.resultReason ?? '';
        }
        qcObj['rejectionDetail'] = rejectionDetail;
      } else {
        qcObj['rejectionDetail'] = null;
      }

      qcObj['qcdOpen1'] = qualityControl?.qcdOpen1;
      qcObj['qcdOpen3'] = qualityControl?.qcdOpen3;
      qcObj['qcdOpen4'] = qualityControl?.qcdOpen4;
      qcObj['qcdOpen5'] = qualityControl?.workDate;

      qcObj['po'] = qcHeaderDetails?.poNo;

      qcObj['poLineNumber'] = inspection?.poLineNo;

      qcObj['seal'] = qcHeaderDetails?.sealNo;

      qcObj['qchOpen1'] = qcHeaderDetails?.qchOpen1;
      qcObj['qchOpen2'] = qcHeaderDetails?.qchOpen2;
      qcObj['qchOpen3'] = qcHeaderDetails?.qchOpen3;
      qcObj['qchOpen4'] = qcHeaderDetails?.qchOpen4;
      qcObj['qchOpen5'] = qcHeaderDetails?.qchOpen5;
      qcObj['qchOpen6'] = qcHeaderDetails?.qchOpen6;
      qcObj['qchOpen7'] = qcHeaderDetails?.qchOpen9;
      qcObj['qchOpen8'] = qcHeaderDetails?.qchOpen10;
      qcObj['qchTruckTempOk'] = qcHeaderDetails?.truckTempOk;

      // Specification Analyticals
      List<Map<String, dynamic>> specAnalyticalArray = [];
      if (specificationAnalyticalRequestList.isNotEmpty) {
        for (SpecificationAnalyticalRequest specObj
            in specificationAnalyticalRequestList) {
          Map<String, dynamic> saa1 = {
            'analyticalID': specObj.analyticalID,
            'comply': specObj.comply == 'N/A' ? '' : specObj.comply,
            'sampleValue': specObj.sampleNumValue,
            'sampleTextValue': specObj.sampleTextValue,
            'comments': specObj.comment,
          };
          specAnalyticalArray.add(saa1);
        }
      }
      qcObj['specificationAnalyticals'] = specAnalyticalArray;

      // Specification Country

      List<Map<String, dynamic>> countryArray = [
        {'countryId': 1, 'countryName': ''}
      ];
      qcObj['specificationCountry'] = countryArray;

      // Specification Brand

      List<Map<String, dynamic>> originArray = [
        {'brandId': 1, 'brandName': '', 'privateLabel': false}
      ];
      qcObj['specificationBrand'] = originArray;

      // create an array of inspection samples
      List<Map<String, dynamic>> samplesArray = [];
      if (samplesList.isNotEmpty) {
        for (InspectionSample sampleItem in samplesList) {
          Map<String, dynamic> s_obj = {
            'setNumber': sampleItem.setNumber,
            'setSize': sampleItem.setSize,
            'createdTime': sampleItem.createdTime,
            'lastUpdatedTime':
                sampleItem.createdTime ?? sampleItem.lastUpdatedTime,
            'setName': sampleItem.sampleName,
          };

          List<Map<String, dynamic>> defectsArray = [];
          List<InspectionDefect> defectList =
              await dao.findInspectionDefects(sampleItem.sampleId!);
          if (defectList.isNotEmpty) {
            for (InspectionDefect defectItem in defectList) {
              Map<String, dynamic> d_obj = {
                'inspectionDefectId': null,
                'inspectionSampleId': null,
                'defectId': defectItem.defectId,
                'comments': defectItem.comment,
              };

              List<Map<String, dynamic>> defectsDetailArray = [];
              // add details for injury
              if (defectItem.injuryCnt! > 0) {
                Map<String, dynamic> dd_obj = {
                  'inspectionDefectId': null,
                  'severityDefectId': defectItem.severityInjuryId,
                  'numberOfDefects': defectItem.injuryCnt,
                };
                defectsDetailArray.add(dd_obj);
              }
              // add details for damage
              if (defectItem.damageCnt! > 0) {
                Map<String, dynamic> dd_obj = {
                  'inspectionDefectId': null,
                  'severityDefectId': defectItem.severityDamageId,
                  'numberOfDefects': defectItem.damageCnt,
                };
                defectsDetailArray.add(dd_obj);
              }
              // add details for serious damage
              if (defectItem.seriousDamageCnt! > 0) {
                Map<String, dynamic> dd_obj = {
                  'inspectionDefectId': null,
                  'severityDefectId': defectItem.severitySeriousDamageId,
                  'numberOfDefects': defectItem.seriousDamageCnt,
                };
                defectsDetailArray.add(dd_obj);
              }
              // add details for very serious damage
              if (defectItem.verySeriousDamageCnt! > 0) {
                Map<String, dynamic> dd_obj = {
                  'inspectionDefectId': null,
                  'severityDefectId': defectItem.severityVerySeriousDamageId,
                  'numberOfDefects': defectItem.verySeriousDamageCnt,
                };
                defectsDetailArray.add(dd_obj);
              }
              // add details for decay
              if (defectItem.decayCnt! > 0) {
                Map<String, dynamic> dd_obj = {
                  'inspectionDefectId': null,
                  'severityDefectId': defectItem.severityDecayId,
                  'numberOfDefects': defectItem.decayCnt,
                };
                defectsDetailArray.add(dd_obj);
              }
              d_obj['inspectionDefectDetails'] = defectsDetailArray;

              List<InspectionDefectAttachment> attachmentList =
                  await dao.findDefectAttachmentsByDefectId(
                          defectItem.inspectionDefectId!) ??
                      [];
              if (attachmentList.isNotEmpty) {
                List<Map<String, dynamic>> defectsAttachmentArray = [];
                for (InspectionDefectAttachment attachment in attachmentList) {
                  Map<String, dynamic> dd_obj = {
                    'localPictureId': attachment.attachmentId,
                  };
                  defectsAttachmentArray.add(dd_obj);
                }
                d_obj['inspectionDefectAttachments'] = defectsAttachmentArray;
              }
              defectsArray.add(d_obj);
            }
          }
          s_obj['inspectionDefects'] = defectsArray;
          samplesArray.add(s_obj);
        }
      }

      // put the samples array in our upload object
      Map<String, dynamic> inspectSampleObj = {
        'inspectionSamples': samplesArray
      };
      jsonObj['defect'] = inspectSampleObj;

      // create an array of trailer temperatures
      List<Map<String, dynamic>> trailerTempArray = [];
      if (trailerTemps.isNotEmpty) {
        for (TrailerTemperatureItem ttItem in trailerTemps) {
          Map<String, dynamic> tt_obj = {
            'serverTrailerTempId': null,
            'location': ttItem.location,
            'level': ttItem.level!.substring(0, 1),
            'trailerColumn': ttItem.level!.substring(1),
            'value': ttItem.value,
          };
          trailerTempArray.add(tt_obj);
        }
      }

      // put the trailer temperature array in our upload object
      Map<String, dynamic> trailerTempObj = {
        'localInspectionId': 1,
        'serverInspectionId': null,
        'tempOpen1': trailerTemperatureDetails.tempOpen1,
        'tempOpen2': trailerTemperatureDetails.tempOpen2,
        'tempOpen3': trailerTemperatureDetails.tempOpen3,
        'comments': trailerTemperatureDetails.comments,
        'trailerTemperatures': trailerTempArray,
      };
      jsonObj['trailerTemp'] = trailerTempObj;
      jsonObj['qualityControl'] = qcObj;
    } catch (e) {
      debugPrint('🔴 Error creating JSON request WsUploadInspection : $e');
    }
    log('🟢 JSON CREATED WsUploadInspection ${json.encode(jsonObj)}');
    return jsonObj;
  }
}
