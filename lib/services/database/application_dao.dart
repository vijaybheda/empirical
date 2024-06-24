// ignore_for_file: no_leading_underscores_for_local_identifiers, use_rethrow_when_possible, prefer_adjacent_string_concatenation, prefer_interpolation_to_compose_strings, unused_local_variable, unnecessary_brace_in_string_interps, non_constant_identifier_names, unnecessary_string_interpolations, unrelated_type_equality_checks, unnecessary_cast

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:pverify/models/commodity_data.dart';
import 'package:pverify/models/commodity_keywords.dart';
import 'package:pverify/models/inspection.dart';
import 'package:pverify/models/inspection_attachment.dart';
import 'package:pverify/models/inspection_defect.dart';
import 'package:pverify/models/inspection_defect_attachment.dart';
import 'package:pverify/models/inspection_sample.dart';
import 'package:pverify/models/item_sku_data.dart';
import 'package:pverify/models/my_inspection_48hour_item.dart';
import 'package:pverify/models/overridden_result_item.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/models/partner_item_sku_inspections.dart';
import 'package:pverify/models/purchase_order_details.dart';
import 'package:pverify/models/qc_header_details.dart';
import 'package:pverify/models/quality_control_item.dart';
import 'package:pverify/models/result_rejection_details.dart';
import 'package:pverify/models/specification.dart';
import 'package:pverify/models/specification_analytical.dart';
import 'package:pverify/models/specification_analytical_request_item.dart';
import 'package:pverify/models/specification_by_item_sku.dart';
import 'package:pverify/models/specification_grade_tolerance.dart';
import 'package:pverify/models/specification_supplier_gtin.dart';
import 'package:pverify/models/trailer_temperature_item.dart';
import 'package:pverify/models/user_data.dart';
import 'package:pverify/models/user_offline.dart';
import 'package:pverify/services/database/column_names.dart';
import 'package:pverify/services/database/database_helper.dart';
import 'package:pverify/services/database/db_tables.dart';
import 'package:pverify/ui/trailer_temp/trailertemprature_details.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/utils.dart';
import 'package:sqflite/sqflite.dart';

class ApplicationDao {
  // instance

  final dbProvider = DatabaseHelper.instance;

  final AppStorage _appStorage = AppStorage.instance;

  AppStorage get appStorage => _appStorage;

  Future<int> createOrUpdateUser(UserData user) async {
    try {
      final Database db = dbProvider.lazyDatabase;
      if (user.id == null) {
        // Insert
        return await db.insert(DBTables.USER, user.toUserDBJson());
      } else {
        // Update
        return await db.update(
          DBTables.USER,
          user.toUserDBJson(),
          where: '${BaseColumns.ID} = ?',
          whereArgs: [user.id],
        );
      }
    } catch (e) {
      log('failed to add-update user');
      return -1;
    }
  }

  Future<int?> getEnterpriseIdByUserId(String userId) async {
    final Database db = dbProvider.lazyDatabase;

    int? enterpriseId;
    List<Map<String, dynamic>> result = await db.query(
      DBTables.USER_OFFLINE,
      where: '${UserOfflineColumn.USER_ID} = ?',
      whereArgs: [userId],
    );

    if (result.isNotEmpty) {
      enterpriseId = result.first[UserOfflineColumn.ENTERPRISEID];
    }

    return enterpriseId;
  }

  Future<int> createOrUpdateOfflineUser(
    String userId,
    String userHash,
    int enterpriseId,
    String status,
    bool isSubscriptionExpired,
    int supplierId,
    int headquarterSupplierId,
    bool gtinScanning,
  ) async {
    int result = -1;
    final Database db = dbProvider.lazyDatabase;
    await db.transaction((txn) async {
      int? userIdExists = Sqflite.firstIntValue(await txn.rawQuery(
          'SELECT COUNT(*) FROM ${DBTables.USER_OFFLINE} WHERE ${UserOfflineColumn.USER_ID} = ?',
          [userId]));

      Map<String, dynamic> data = {
        UserOfflineColumn.USER_ID: userId,
        UserOfflineColumn.ACCESS: userHash,
        UserOfflineColumn.ENTERPRISEID: enterpriseId,
        UserOfflineColumn.STATUS: status,
        UserOfflineColumn.SUPPLIER_ID: supplierId,
        UserOfflineColumn.HEADQUATER_SUPPLIER_ID: headquarterSupplierId,
        UserOfflineColumn.IS_SUBSCRIPTION_EXPIRED:
            isSubscriptionExpired ? '1' : '0',
        UserOfflineColumn.GTIN_SCANNING: gtinScanning ? '1' : '0'
      };
      if (userIdExists == 0) {
        result = await txn.insert(DBTables.USER_OFFLINE, data);
      } else {
        result = await txn.update(
          DBTables.USER_OFFLINE,
          data,
          where: '${UserOfflineColumn.USER_ID} = ?',
          whereArgs: [userId],
        );
      }
    });

    return result;
  }

  Future<String?> getOfflineUserHash(String userId) async {
    final Database db = dbProvider.lazyDatabase;
    String? userHash;
    List<Map<String, dynamic>> result = await db.query(
      DBTables.USER_OFFLINE,
      columns: [UserOfflineColumn.ACCESS],
      where: '${UserOfflineColumn.USER_ID} = ?',
      whereArgs: [userId],
    );

    if (result.isNotEmpty) {
      userHash = result.first[UserOfflineColumn.ACCESS];
    }

    return userHash;
  }

  // find all users
  Future<List<UserData>> findAllUsers() async {
    final Database db = dbProvider.lazyDatabase;
    List<Map<String, dynamic>> maps = await db.query(DBTables.USER);
    return List.generate(maps.length, (mapData) {
      return UserData.fromJson(maps.elementAt(mapData));
    });
  }

  Future<UserData?> findUserByUserName(String name) async {
    final Database db = dbProvider.lazyDatabase;
    final List<Map<String, dynamic>> maps = await db.query(
      DBTables.USER,
      where: '${UserColumn.USER_NAME} = ?',
      whereArgs: [name],
    );

    if (maps.isNotEmpty) {
      return UserData.fromJson(maps.first);
    }
    return null;
  }

  Future<int?> findUserIDByUserName(String name) async {
    final Database db = dbProvider.lazyDatabase;
    final List<Map<String, dynamic>> maps = await db.query(
      DBTables.USER,
      columns: [BaseColumns.ID],
      where: '${UserColumn.USER_NAME} = ?',
      whereArgs: [name],
    );

    if (maps.isNotEmpty) {
      return maps.first[BaseColumns.ID] as int?;
    }
    return null;
  }

  Future<int> createOrUpdateUserOffline(UserOffline userOffline) async {
    final Database db = dbProvider.lazyDatabase;
    var existingUserOffline = await findOfflineUserID(userOffline.userId);
    if (existingUserOffline == null) {
      // Insert
      return await db.insert(DBTables.USER_OFFLINE, userOffline.toMap());
    } else {
      // Update
      return await db.update(
        DBTables.USER_OFFLINE,
        userOffline.toMap(),
        where: '${UserOfflineColumn.USER_ID} = ?',
        whereArgs: [userOffline.userId],
      );
    }
  }

  Future<int?> findOfflineUserID(String userId) async {
    final Database db = dbProvider.lazyDatabase;
    final List<Map<String, dynamic>> results = await db.query(
      DBTables.USER_OFFLINE,
      columns: [BaseColumns.ID],
      where: '${UserOfflineColumn.USER_ID} = ?',
      whereArgs: [userId],
    );
    if (results.isNotEmpty) {
      return results.first[BaseColumns.ID] as int?;
    }
    return null;
  }

  Future<UserOffline?> getOfflineUserData(String userId) async {
    final Database db = dbProvider.lazyDatabase;
    final List<Map<String, dynamic>> results = await db.query(
      DBTables.USER_OFFLINE,
      where: '${UserOfflineColumn.USER_ID} = ?',
      whereArgs: [userId],
    );
    if (results.isNotEmpty) {
      return UserOffline.fromMap(results.first);
    }
    return null;
  }

  Future<int> createInspection(Inspection inspection) async {
    final Database db = dbProvider.lazyDatabase;
    print('DBRequest createInspection');
    try {
      int newInspId = await db.insert(DBTables.INSPECTION, inspection.toJson());
      print(
          'DBResponse createInspection newInspId $newInspId ${inspection.toJson()}');
      return newInspId;
    } catch (e) {
      log('Error has occurred while creating an inspection: $e');
      return -1;
    }
  }

  Future<int?> createInspectionAttachment(InspectionAttachment attachment,
      photoTitle, createdTime, pathToPhoto) async {
    final Database db = dbProvider.lazyDatabase;

    int attachmentId = 0;
    try {
      await db.transaction((txn) async {
        var values = {
          InspectionDefectAttachmentColumn.INSPECTION_ID:
              attachment.Inspection_ID,
          InspectionDefectAttachmentColumn.ATTACHMENT_ID: 0,
          InspectionDefectAttachmentColumn.CREATED_TIME:
              attachment.CREATED_TIME,
          InspectionDefectAttachmentColumn.FILE_LOCATION:
              attachment.filelocation.toString(),
        };

        attachmentId = await txn.insert(DBTables.INSPECTION_ATTACHMENT, values);

        // Update record with attachment_id
        await txn.update(
          DBTables.INSPECTION_ATTACHMENT,
          {
            InspectionDefectAttachmentColumn.ATTACHMENT_ID: attachmentId,
            InspectionDefectAttachmentColumn.INSPECTION_ID:
                attachment.Inspection_ID,
            InspectionDefectAttachmentColumn.CREATED_TIME:
                attachment.CREATED_TIME,
            InspectionDefectAttachmentColumn.FILE_LOCATION:
                attachment.filelocation.toString(),
          },
          where: '${InspectionDefectAttachmentColumn.ID} = ?',
          whereArgs: [attachmentId],
        );
      });
      return attachmentId;
    } catch (e) {
      log('Error creating inspection attachment: $e');
      // throw e;
      return null;
    }
  }

  Future<List<InspectionAttachment>> findInspectionAttachmentsByInspectionId(
      int inspectionId) async {
    print('DBRequest findInspectionAttachmentsByInspectionId');
    final Database db = dbProvider.lazyDatabase;
    List<Map> maps = await db.query(DBTables.INSPECTION_ATTACHMENT,
        where: '${InspectionDefectAttachmentColumn.INSPECTION_ID} = ?',
        whereArgs: [inspectionId]);
    List<InspectionAttachment> attachments = [];
    if (maps.isNotEmpty) {
      for (Map<dynamic, dynamic> map in maps) {
        attachments
            .add(InspectionAttachment.fromMap(map as Map<String, dynamic>));
      }
    }
    print(
        'DBResponse findInspectionAttachmentsByInspectionId attachments ${attachments.length}');
    return attachments;
  }

  Future<InspectionAttachment?> findAttachmentByAttachmentId(
      int attachmentId) async {
    final Database db = dbProvider.lazyDatabase;
    // List<Map> maps = await db.query(DBTables.INSPECTION_ATTACHMENT,
    //     where: '${int.tryParse(BaseColumns.ID)} = ?',
    //     whereArgs: [attachmentId]);

    String query = "SELECT * FROM " +
        DBTables.INSPECTION_ATTACHMENT +
        " WHERE " +
        BaseColumns.ID.toString() +
        " = " +
        attachmentId.toString();

    var result = await db.rawQuery(query);
    if (result.isNotEmpty) {
      return InspectionAttachment.fromMap(result.first);
    }

    // if (maps.isNotEmpty) {
    //   return InspectionAttachment.fromMap(maps.first as Map<String, dynamic>);
    // }
    return null;
  }

  Future<void> deleteAttachmentByAttachmentId(int attachmentId) async {
    final Database db = dbProvider.lazyDatabase;
    await db.delete(DBTables.INSPECTION_ATTACHMENT,
        where: '${BaseColumns.ID.toString()} = ?',
        whereArgs: [attachmentId.toString()]);
  }

// Additional methods like updateInspectionStatus, updateInspectionResult, etc., to be added here

  // updateInspectionStatus
  Future<int> updateInspectionStatus(int inspectionId, String status) async {
    final Database db = dbProvider.lazyDatabase;
    return await db.update(
        DBTables.INSPECTION, {InspectionColumn.STATUS: status},
        where: '${BaseColumns.ID} = ?', whereArgs: [inspectionId]);
  }

  // updateInspectionResult
  Future<int> updateInspectionResult(int inspectionId, String result) async {
    print('DBRequest updateInspectionResult');
    final Database db = dbProvider.lazyDatabase;

    int updatedInspId = await db.update(
        DBTables.INSPECTION, {InspectionColumn.RESULT: result},
        where: '${BaseColumns.ID} = ?', whereArgs: [inspectionId]);
    return updatedInspId;
  }

  /*Future<int> createOrUpdateInspectionSpecification(
      InspectionSpecification spec) async {
    final Database db = await DatabaseHelper.instance.lazyDatabase;
    if (spec.id == null) {
      // If there's no ID, we insert a new record
      return await db.insert(DBTables.INSPECTION_SPECIFICATION, spec.toMap());
    } else {
      // If an ID is provided, we update the record with the matching ID
      return await db.update(
        DBTables.INSPECTION_SPECIFICATION,
        spec.toMap(),
        where: '${BaseColumns.ID} = ?',
        whereArgs: [spec.id],
      );
    }
  }*/

  Future<int> createOrUpdateInspectionSpecification(
      int inspectionID, String? number, String? version, String? name) async {
    int? inspectionId;
    final Database db = dbProvider.lazyDatabase;
    print('DBRequest createOrUpdateInspectionSpecification');
    try {
      try {
        String query =
            "SELECT Inspection_ID FROM ${DBTables.INSPECTION_SPECIFICATION} WHERE Inspection_ID = $inspectionID";
        List<Map<String, dynamic>> result = await db.rawQuery(query);

        if (result.isNotEmpty) {
          inspectionId = result[0]["Inspection_ID"];
        }
      } catch (e) {
        log("Error has occurred while finding a user id: $e");
        return -1;
      }

      if (inspectionId == null) {
        await db.transaction((txn) async {
          var values = {
            InspectionSpecificationColumn.INSPECTION_ID: inspectionID,
            InspectionSpecificationColumn.SPECIFICATION_NUMBER: number,
            InspectionSpecificationColumn.SPECIFICATION_VERSION: version,
            InspectionSpecificationColumn.SPECIFICATION_NAME: name,
          };

          inspectionId =
              await txn.insert(DBTables.INSPECTION_SPECIFICATION, values);
        });
      } else {
        await db.transaction((txn) async {
          var values = <String, dynamic>{};
          if (number != null) {
            values[InspectionSpecificationColumn.SPECIFICATION_NUMBER] = number;
            values[InspectionSpecificationColumn.SPECIFICATION_VERSION] =
                version;
            values[InspectionSpecificationColumn.SPECIFICATION_NAME] = name;
          }
          await txn.update(DBTables.INSPECTION_SPECIFICATION, values,
              where: "${InspectionSpecificationColumn.INSPECTION_ID} = ?",
              whereArgs: [inspectionID]);
        });
      }

      log("Inside specification table");
    } catch (e) {
      log("Error has occurred while creating an inspection: $e");
      return -1;
    }

    return inspectionId ?? -1;
  }

  Future<void> updateInspectionRating(int inspectionID, int rating) async {
    final Database db = dbProvider.lazyDatabase;
    print('DBRequest updateInspectionRating');
    await db.update(
      DBTables.INSPECTION,
      {InspectionColumn.RATING: rating},
      where: '${BaseColumns.ID} = ?',
      whereArgs: [inspectionID],
    );
  }

  Future<bool> checkInspections() async {
    final Database db = dbProvider.lazyDatabase;
    List<Map> result = await db.query(DBTables.INSPECTION);
    return result.isNotEmpty;
  }

  Future<int> updateInspectionComplete(int inspectionID, bool complete) async {
    final Database db = dbProvider.lazyDatabase;
    print('DBRequest updateInspectionComplete');
    return await db.update(
      DBTables.INSPECTION,
      {
        InspectionColumn.COMPLETE: complete ? 1 : 0,
        InspectionColumn.COMPLETED_TIME: DateTime.now().millisecondsSinceEpoch
      },
      where: '${BaseColumns.ID} = ?',
      whereArgs: [inspectionID],
    );
  }

  Future<void> updateInspectionUploadStatus(
      int inspectionID, int status) async {
    final Database db = dbProvider.lazyDatabase;
    await db.update(
      DBTables.INSPECTION,
      {InspectionColumn.UPLOAD_STATUS: status},
      where: '${BaseColumns.ID} = ?',
      whereArgs: [inspectionID],
    );
  }

  Future<void> updateInspectionServerId(int inspectionID, int serverID) async {
    final Database db = dbProvider.lazyDatabase;
    await db.update(
      DBTables.INSPECTION,
      {InspectionColumn.INSPECTION_SERVER_ID: serverID},
      where: '${BaseColumns.ID} = ?',
      whereArgs: [inspectionID],
    );
  }

  /*Future<void> updateInspection(
      int inspectionID, Map<String, dynamic> values) async {
    final Database db = dbProvider.lazyDatabase;
    await db.update(
      DBTables.INSPECTION,
      values,
      where: '${BaseColumns.ID} = ?',
      whereArgs: [inspectionID],
    );
  }*/

  Future<int> updateInspection({
    required int? serverInspectionID,
    required int? commodityID,
    required String? commodityName,
    required int? varietyId,
    required String? varietyName,
    required int? gradeId,
    required String? specificationNumber,
    required String? specificationVersion,
    required String? specificationName,
    required String? specificationTypeName,
    required int? sampleSizeByCount,
    required String? itemSKU,
    required int? itemSKUId,
    required String? po_number,
    required String? lotNo,
    required int? rating,
    required String? cteType,
    required String? itemSkuName,
  }) async {
    final Database db = dbProvider.lazyDatabase;
    print('DBRequest updateInspection');
    try {
      return await db.transaction((txn) async {
        return await txn.update(
          DBTables.INSPECTION,
          {
            InspectionColumn.COMMODITY_ID: commodityID,
            InspectionColumn.COMMODITY_NAME: commodityName,
            InspectionColumn.VARIETY_ID: varietyId,
            InspectionColumn.VARIETY_NAME: varietyName,
            InspectionColumn.GRADE_ID: gradeId,
            InspectionColumn.SPECIFICATION_NAME: specificationName,
            InspectionColumn.SPECIFICATION_VERSION: specificationVersion,
            InspectionColumn.SPECIFICATION_NUMBER: specificationNumber,
            InspectionColumn.SPECIFICATION_TYPENAME: specificationTypeName,
            InspectionColumn.SAMPLE_SIZE_BY_COUNT: sampleSizeByCount,
            InspectionColumn.ITEM_SKU: itemSKU,
            InspectionColumn.ITEM_SKU_ID: itemSKUId,
            InspectionColumn.PO_NUMBER: po_number,
            InspectionColumn.RATING: rating,
            InspectionColumn.CTE_TYPE: cteType,
            InspectionColumn.ITEM_SKU_NAME: itemSkuName,
            InspectionColumn.LOT_NO: lotNo,
          },
          where: '${InspectionColumn.ID} = ?',
          whereArgs: [serverInspectionID],
        );
      });
    } catch (e) {
      log('Error has occurred while updating an inspection: $e');
      return -1;
    }
  }

  Future<Inspection?> findInspectionByID(int inspectionID) async {
    final Database db = dbProvider.lazyDatabase;
    print('DBRequest findInspectionByID');
    List<Map> maps = await db.query(
      DBTables.INSPECTION,
      where: '${BaseColumns.ID} = ?',
      whereArgs: [inspectionID],
    );

    if (maps.isNotEmpty) {
      return Inspection.fromJson(maps.first as Map<String, dynamic>);
    }
    return null;
  }

  // Fetch all inspections created within the last 48 hours
  Future<List<MyInspection48HourItem>> getAllLocalInspections() async {
    final Database db = dbProvider.lazyDatabase;
    List<MyInspection48HourItem> list = [];

    // Calculate the timestamp for 48 hours ago
    int fortyEightHoursAgo = DateTime.now()
        .subtract(const Duration(hours: 48))
        .millisecondsSinceEpoch;

    List<Map> result = await db.query(
      DBTables.INSPECTION,
      where: 'Created_Time >= ?',
      whereArgs: [fortyEightHoursAgo],
    );

    for (Map map in result) {
      list.add(MyInspection48HourItem.fromJson(map as Map<String, dynamic>));
    }

    return list;
  }

  // Get all incomplete inspection IDs
  Future<List<int>> getAllIncompleteInspectionIDs() async {
    final Database db = dbProvider.lazyDatabase;
    List<int> ids = [];

    List<Map> result = await db.query(
      DBTables.INSPECTION,
      columns: [(BaseColumns.ID)],
      where: '${InspectionColumn.COMPLETE} = ?',
      whereArgs: [0], // Assuming 'Complete' is stored as 0 for false
    );

    for (Map map in result) {
      ids.add(map[BaseColumns.ID]);
    }

    return ids;
  }

  // Find a specification by inspection ID
  Future<Specification?> findSpecificationByInspectionId(
      int inspectionId) async {
    final Database db = dbProvider.lazyDatabase;

    List<Map> result = await db.query(
      DBTables.INSPECTION_SPECIFICATION,
      where: '${InspectionSpecificationColumn.INSPECTION_ID} = ?',
      whereArgs: [inspectionId],
    );

    if (result.isNotEmpty) {
      return Specification.fromMap(result.first as Map<String, dynamic>);
    }

    return null;
  }

  // Find IDs of inspections ready to upload
  Future<List<int>> findReadyToUploadInspectionIDs() async {
    final Database db = dbProvider.lazyDatabase;
    List<int> ids = [];

    try {
      List<Map> result = await db.query(
        DBTables.INSPECTION,
        columns: [BaseColumns.ID],
        where: '${InspectionColumn.UPLOAD_STATUS} = ?',
        whereArgs: [Consts.INSPECTION_UPLOAD_READY],
      );

      for (Map map in result) {
        ids.add(map[BaseColumns.ID]);
      }
    } catch (e) {
      debugPrint(
          'Error occurred while finding ready-to-upload inspection IDs: $e');
    }

    return ids;
  }

  // Delete an inspection by ID
  Future<void> deleteInspection(int inspectionId) async {
    try {
      final Database db = dbProvider.lazyDatabase;

      await deleteTrailerTemperatureEntriesByInspectionId(inspectionId);
      await deleteQualityControlEntries(inspectionId);
      await deleteSpecAttributesByInspectionId(inspectionId);
      await deleteInspectionPicturesByInspectionId(inspectionId);
      await deleteInspectionDefectByInspectionId(inspectionId);
      await deleteInspectionSamples(inspectionId);
      await deletePartnerItemSKUByInspectionId(inspectionId);

      await deleteDefectAttachmentsByInspectionId(inspectionId);
      await db.delete(
        DBTables.INSPECTION,
        where: '${BaseColumns.ID} = ?',
        whereArgs: [inspectionId],
      );
    } catch (e) {
      log('Error deleting inspection: $e');
      throw e;
    }
  }

  Future<void> deleteTrailerTemperatureEntriesByInspectionId(
      int inspectionId) async {
    try {
      final Database db = dbProvider.lazyDatabase;
      await db.transaction((txn) async {
        await txn.rawDelete(
          'DELETE FROM ${DBTables.TRAILER_TEMPERATURE} WHERE ${TrailerTemperatureColumn.INSPECTION_ID} = ?',
          [inspectionId],
        );
      });
    } catch (e) {
      print(
          'Error has occurred while deleting a trailer temperature entries: $e');
    }
  }

  Future<void> deleteQualityControlEntries(int inspectionId) async {
    try {
      final Database db = dbProvider.lazyDatabase;
      await db.transaction((txn) async {
        await txn.rawDelete(
          'DELETE FROM ${DBTables.QUALITY_CONTROL} WHERE ${QualityControlColumn.INSPECTION_ID} = ?',
          [inspectionId],
        );
      });
    } catch (e) {
      print('Error has occurred while deleting a quality control entries: $e');
    }
  }

  Future<void> deleteInspectionPicturesByInspectionId(int inspectionId) async {
    try {
      final Database db = dbProvider.lazyDatabase;
      await db.transaction((txn) async {
        await txn.rawDelete(
          'DELETE FROM ${DBTables.INSPECTION_ATTACHMENT} WHERE ${InspectionAttachmentColumn.INSPECTION_ID} = ?',
          [inspectionId],
        );
      });
    } catch (e) {
      print('Error has occurred while deleting inspection defect entries: $e');
    }
  }

  Future<void> deletePartnerItemSKUByInspectionId(int inspectionId) async {
    try {
      final Database db = dbProvider.lazyDatabase;
      await db.transaction((txn) async {
        await txn.rawDelete(
          'DELETE FROM ${DBTables.PARTNER_ITEMSKU} WHERE ${PartnerItemSkuColumn.INSPECTION_ID} = ?',
          [inspectionId],
        );
      });
    } catch (e) {
      print('Error has occurred while deleting a quality control entries: $e');
    }
  }

  Future<void> deleteDefectAttachmentsByInspectionId(int inspectionId) async {
    final Database db = dbProvider.lazyDatabase;
    List<InspectionDefectAttachment>? attachments =
        await findDefectAttachmentsByInspectionId(inspectionId);

    if (attachments != null && attachments.isNotEmpty) {
      for (var attachment in attachments) {
        if (attachment.fileLocation != null) {
          File file = File(attachment.fileLocation!);
          if (file.existsSync()) {
            file.deleteSync();
          }
        }
      }
    }

    try {
      await db.transaction((txn) async {
        await txn.rawDelete(
          'DELETE FROM ${DBTables.INSPECTION_DEFECT_ATTACHMENT} WHERE ${InspectionDefectAttachmentColumn.INSPECTION_ID} = ?',
          [inspectionId],
        );
      });
    } catch (e) {
      print('Error has occurred while deleting a defect attachment: $e');
    }
  }

  // Delete an inspection after upload
  Future<void> deleteInspectionAfterUpload(int inspectionId) async {
    await deleteTrailerTemperatureEntriesByInspectionId(inspectionId);
    await deleteQualityControlEntries(inspectionId);
    await deleteSpecAttributesByInspectionId(inspectionId);
    await deleteInspectionPicturesByInspectionId(inspectionId);
    await deleteInspectionDefectByInspectionId(inspectionId);
    await deleteInspectionSamples(inspectionId);

    await deleteDefectAttachmentsByInspectionId(inspectionId);

    await deleteInspection(inspectionId);
  }

  Future<int> createInspectionSample(
      int inspectionId,
      int setSize,
      String setName,
      int setNumber,
      int createdTime,
      int updatedTime,
      String sampleNameUser) async {
    final Database db = dbProvider.lazyDatabase;
    var sampleId = await db.insert(
      DBTables.INSPECTION_SAMPLE,
      {
        InspectionSampleColumn.INSPECTION_ID: inspectionId,
        InspectionSampleColumn.SET_SIZE: setSize,
        InspectionSampleColumn.SET_NAME: setName,
        InspectionSampleColumn.SET_NUMBER: setNumber,
        InspectionSampleColumn.CREATED_TIME: createdTime,
        InspectionSampleColumn.LAST_UPDATED_TIME: updatedTime,
        InspectionSampleColumn.COMPLETE: 1.toString(),
        InspectionSampleColumn.SAMPLE_NAME: sampleNameUser,
      },
    );
    return sampleId;
  }

  Future<void> deleteInspectionSamples(int inspectionId) async {
    final Database db = dbProvider.lazyDatabase;
    await db.delete(
      DBTables.INSPECTION_SAMPLE,
      where: '${InspectionSampleColumn.INSPECTION_ID} = ?',
      whereArgs: [inspectionId],
    );
  }

  Future<List<InspectionSample>> findInspectionSamples(int inspectionId) async {
    final Database db = dbProvider.lazyDatabase;
    List<Map> maps = await db.query(
      DBTables.INSPECTION_SAMPLE,
      where: '${InspectionSampleColumn.INSPECTION_ID} = ?',
      whereArgs: [inspectionId],
    );

    return List.generate(maps.length, (i) {
      return InspectionSample.fromJson(maps[i] as Map<String, dynamic>);
    });
  }

  Future<void> updateInspectionSample(
      int sampleId, String sampleNameUser) async {
    final Database db = dbProvider.lazyDatabase;
    await db.update(
      DBTables.INSPECTION_SAMPLE,
      {InspectionSampleColumn.SAMPLE_NAME: sampleNameUser},
      where: '${BaseColumns.ID} = ?',
      whereArgs: [sampleId],
    );
  }

  Future<int> createInspectionDefect({
    required int inspectionId,
    required int sampleId,
    required int defectId,
    required String defectName,
    required int injuryCnt,
    required int damageCnt,
    required int seriousDamageCnt,
    String? comments,
    required int timestamp,
    required int verySeriousDamageCnt,
    required int decayCnt,
    required int severityInjuryId,
    required int severityDamageId,
    required int severitySeriousDamageId,
    required int severityVerySeriousDamageId,
    required int severityDecayId,
    required String defectCategory,
  }) async {
    final Database db = dbProvider.lazyDatabase;
    var defectId0 = await db.insert(
      DBTables.INSPECTION_DEFECT,
      {
        InspectionDefectColumn.INSPECTION_ID: inspectionId,
        InspectionDefectColumn.INSPECTION_SAMPLE_ID: sampleId,
        InspectionDefectColumn.DEFECT_ID: defectId,
        InspectionDefectColumn.DEFECT_NAME: defectName,
        InspectionDefectColumn.INJURY_CNT: injuryCnt,
        InspectionDefectColumn.DAMAGE_CNT: damageCnt,
        InspectionDefectColumn.SERIOUS_DAMAGE_CNT: seriousDamageCnt,
        InspectionDefectColumn.COMMENTS: comments ?? '',
        InspectionDefectColumn.CREATED_TIME: timestamp,
        InspectionDefectColumn.VERY_SERIOUS_DAMAGE_CNT: verySeriousDamageCnt,
        InspectionDefectColumn.DECAY_CNT: decayCnt,
        InspectionDefectColumn.INJURY_ID: severityInjuryId,
        InspectionDefectColumn.DAMAGE_ID: severityDamageId,
        InspectionDefectColumn.SERIOUS_DAMAGE_ID: severitySeriousDamageId,
        InspectionDefectColumn.VERY_SERIOUS_DAMAGE_ID:
            severityVerySeriousDamageId,
        InspectionDefectColumn.DECAY_ID: severityDecayId,
        InspectionDefectColumn.DEFECT_CATEGORY: defectCategory,
      },
    );
    return defectId0;
  }

  Future<void> deleteInspectionDefectByInspectionId(int inspectionId) async {
    final Database db = dbProvider.lazyDatabase;
    await db.delete(
      DBTables.INSPECTION_DEFECT,
      where: '${InspectionDefectColumn.INSPECTION_ID} = ?',
      whereArgs: [inspectionId],
    );
  }

  Future<List<InspectionDefect>> findInspectionDefects(int sampleId) async {
    final Database db = dbProvider.lazyDatabase;
    var results = await db.query(
      DBTables.INSPECTION_DEFECT,
      where: '${InspectionDefectColumn.INSPECTION_SAMPLE_ID} = ?',
      whereArgs: [sampleId],
    );

    return results.map((map) => InspectionDefect.fromJson(map)).toList();
  }

  Future<void> updateInspectionDefect({
    required int inspectionDefectId,
    required int defectId,
    required String defectName,
    required int injuryCnt,
    required int damageCnt,
    required int seriousDamageCnt,
    required String comments,
    required int verySeriousDamageCnt,
    required int decayCnt,
    required int severityInjuryId,
    required int severityDamageId,
    required int severitySeriousDamageId,
    required int severityVerySeriousDamageId,
    required int severityDecayId,
    required String defectCategory,
  }) async {
    final Database db = dbProvider.lazyDatabase;
    await db.update(
      DBTables.INSPECTION_DEFECT,
      {
        InspectionDefectColumn.DEFECT_ID: defectId,
        InspectionDefectColumn.DEFECT_NAME: defectName,
        InspectionDefectColumn.INJURY_CNT: injuryCnt,
        InspectionDefectColumn.DAMAGE_CNT: damageCnt,
        InspectionDefectColumn.SERIOUS_DAMAGE_CNT: seriousDamageCnt,
        InspectionDefectColumn.COMMENTS: comments,
        InspectionDefectColumn.VERY_SERIOUS_DAMAGE_CNT: verySeriousDamageCnt,
        InspectionDefectColumn.DECAY_CNT: decayCnt,
        InspectionDefectColumn.INJURY_ID: severityInjuryId,
        InspectionDefectColumn.DAMAGE_ID: severityDamageId,
        InspectionDefectColumn.SERIOUS_DAMAGE_ID: severitySeriousDamageId,
        InspectionDefectColumn.VERY_SERIOUS_DAMAGE_ID:
            severityVerySeriousDamageId,
        InspectionDefectColumn.DECAY_ID: severityDecayId,
        InspectionDefectColumn.DEFECT_CATEGORY: defectCategory,
      },
      where: '${BaseColumns.ID} = ?',
      whereArgs: [inspectionDefectId],
    );
  }

  Future<void> updateDefectAttachment(
    int attachmentId,
    int? sampleId,
    int? defectId,
  ) async {
    final Database database = dbProvider.lazyDatabase;
    try {
      await database.transaction((txn) async {
        var values = <String, dynamic>{};
        if (sampleId != null) {
          values[InspectionDefectAttachmentColumn.INSPECTION_SAMPLE_ID] =
              sampleId;
        }
        if (defectId != null) {
          values[InspectionDefectAttachmentColumn.INSPECTION_DEFECT_ID] =
              defectId;
        }

        if (sampleId != null && defectId != null) {
          values[InspectionDefectAttachmentColumn.DEFECT_SAVED] = 'Y';
        }

        await txn.update(
          DBTables.INSPECTION_DEFECT_ATTACHMENT,
          values,
          where: '${InspectionDefectAttachmentColumn.ID}=?',
          whereArgs: [attachmentId.toString()],
        );
      });
    } catch (e) {
      log('Error has occurred while updating an inspection defect attachment: $e');
      rethrow;
    }
  }

  Future<void> deleteInspectionDefectBySampleId(int sampleId) async {
    final Database db = dbProvider.lazyDatabase;
    await db.delete(
      DBTables.INSPECTION_DEFECT,
      where: '${InspectionDefectColumn.INSPECTION_SAMPLE_ID} = ?',
      whereArgs: [sampleId],
    );
  }

  Future<bool> csvImportItemGroup1() async {
    try {
      var storagePath = await Utils().getExternalStoragePath();
      final File file =
          File("$storagePath${FileManString.csvFilesCache}/item_group1.csv");
      if (!file.existsSync()) {
        log('CSV file not found');
        return false;
      }
      final inputStream = file.openRead();
      final fields = await inputStream
          .transform(utf8.decoder)
          .transform(const CsvToListConverter(eol: '\n', fieldDelimiter: '|'))
          .toList();

      final Database db = dbProvider.lazyDatabase;

      await db.transaction((txn) async {
        await txn.rawDelete('DELETE FROM ${DBTables.ITEM_GROUP1}');
        log('fields ${fields.length} ${DBTables.ITEM_GROUP1}');
        for (var row in fields.skip(1).toList()) {
          // log('rowData $row');
          int igrId = Utils.parseIntDefault(row[0]);
          String igrName = row[1];
          int igrCommodityId = Utils.parseIntDefault(row[2]);

          await txn.insert(
            DBTables.ITEM_GROUP1,
            {
              ItemGroup1Column.GROUP1_ID: igrId,
              ItemGroup1Column.NAME: igrName,
              ItemGroup1Column.COMMODITY_ID: igrCommodityId,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });

      log('CSV data inserted into the database successfully.');
      return true;
    } catch (e) {
      log('Error: while adding Item Group1 $e');
      return false;
    }
  }

  Future<int> deletePartnerItemSKUForUpdateCache() async {
    try {
      final Database db = dbProvider.lazyDatabase;

      return await db.transaction((txn) async {
        return await txn.delete(DBTables.PARTNER_ITEMSKU);
      });
    } catch (e) {
      log('Error: while deleting Partner Item SKU $e');
      return -1;
    }
  }

  Future<bool> csvImportItemSKU() async {
    log('Importing Item SKU');

    try {
      final Database db = dbProvider.lazyDatabase;
      var storagePath = await Utils().getExternalStoragePath();
      final File file =
          File("$storagePath${FileManString.csvFilesCache}/item_sku.csv");
      if (!file.existsSync()) {
        log('item_sku CSV file not found');
        return false;
      }

      final inputStream = file.openRead();
      final fields = await inputStream
          .transform(utf8.decoder)
          .transform(const CsvToListConverter(eol: '\n', fieldDelimiter: '|'))
          .toList();

      await db.transaction((txn) async {
        await txn.rawDelete('DELETE FROM ${DBTables.ITEM_SKU}');
        log('fields ${fields.length} ${DBTables.ITEM_SKU}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemSkuData = {
            ItemSkuColumn.SKU_ID: Utils.parseIntDefault(row[0]),
            ItemSkuColumn.CODE: row[1],
            ItemSkuColumn.COMMODITY_ID: Utils.parseIntDefault(row[2]),
            ItemSkuColumn.NAME: row[3],
            ItemSkuColumn.DESCRIPTION: row[4],
            ItemSkuColumn.STATUS: row[5],
            ItemSkuColumn.ITEM_GROUP1_ID: Utils.parseIntDefault(row[6]),
            ItemSkuColumn.ITEM_GROUP2_ID: Utils.parseIntDefault(row[7]),
            ItemSkuColumn.GRADE_ID: Utils.parseIntDefault(row[8]),
            ItemSkuColumn.PACKAGING_ID: Utils.parseIntDefault(row[9]),
            ItemSkuColumn.USAGE_TYPE: row[10],
            ItemSkuColumn.COMMODITY_CATEGORY_ID: Utils.parseIntDefault(row[11]),
            ItemSkuColumn.ITEM_TYPE: row[12],
            ItemSkuColumn.GLOBAL_PARTNER_ID: Utils.parseIntDefault(row[13]),
            ItemSkuColumn.COMPANY_ID: Utils.parseIntDefault(row[14]),
            ItemSkuColumn.DIVISION_ID: Utils.parseIntDefault(row[15]),
            ItemSkuColumn.BRANDED: row[16],
            ItemSkuColumn.FTL: row[17],
          };
          await txn.insert(DBTables.ITEM_SKU, itemSkuData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      log('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Item SKU $e');
      return false;
    }
  }

  Future<bool> csvImportAgency() async {
    log('Importing Item Agency');

    try {
      final Database db = dbProvider.lazyDatabase;
      var storagePath = await Utils().getExternalStoragePath();
      final File file =
          File("$storagePath${FileManString.csvFilesCache}/agency.csv");
      if (!file.existsSync()) {
        log('agency CSV file not found');
        return false;
      }

      final inputStream = file.openRead();
      final fields = await inputStream
          .transform(utf8.decoder)
          .transform(const CsvToListConverter(eol: '\n', fieldDelimiter: '|'))
          .toList();

      await db.transaction((txn) async {
        await txn.rawDelete('DELETE FROM ${DBTables.AGENCY}');
        log('fields ${fields.length} ${DBTables.AGENCY}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemAgencyData = {
            AgencyColumn.ID: Utils.parseIntDefault(row[0]),
            AgencyColumn.NAME: row[1],
          };
          await txn.insert(DBTables.AGENCY, itemAgencyData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      log('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Item Agency $e');
      return false;
    }
  }

  Future<bool> csvImportGrade() async {
    log('Importing Item Grade');

    try {
      final Database db = dbProvider.lazyDatabase;
      var storagePath = await Utils().getExternalStoragePath();
      final File file =
          File("$storagePath${FileManString.csvFilesCache}/grade.csv");
      if (!file.existsSync()) {
        log('grade CSV file not found');
        return false;
      }

      final inputStream = file.openRead();
      final fields = await inputStream
          .transform(utf8.decoder)
          .transform(const CsvToListConverter(eol: '\n', fieldDelimiter: '|'))
          .toList();

      await db.transaction((txn) async {
        await txn.rawDelete('DELETE FROM ${DBTables.GRADE}');
        log('fields ${fields.length} ${DBTables.GRADE}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemGradeData = {
            GradeColumn.ID: Utils.parseIntDefault(row[0]),
            GradeColumn.NAME: row[1],
            GradeColumn.AGENCY_ID: Utils.parseIntDefault(row[2]),
          };
          await txn.insert(DBTables.GRADE, itemGradeData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      log('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Item Grade $e');
      return false;
    }
  }

  Future<bool> csvImportGradeCommodity() async {
    log('Importing Item Grade Commodity');

    try {
      final Database db = dbProvider.lazyDatabase;
      var storagePath = await Utils().getExternalStoragePath();
      final File file = File(
          "$storagePath${FileManString.csvFilesCache}/grade_commodity.csv");
      if (!file.existsSync()) {
        log('grade_commodity CSV file not found');
        return false;
      }

      final inputStream = file.openRead();
      final fields = await inputStream
          .transform(utf8.decoder)
          .transform(const CsvToListConverter(eol: '\n', fieldDelimiter: '|'))
          .toList();

      await db.transaction((txn) async {
        await txn.rawDelete('DELETE FROM ${DBTables.GRADE_COMMODITY}');
        log('fields ${fields.length} ${DBTables.GRADE_COMMODITY}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemGradeCommodityData = {
            GradeCommodityColumn.ID: Utils.parseIntDefault(row[0]),
            GradeCommodityColumn.AGENCY_ID: Utils.parseIntDefault(row[1]),
            GradeCommodityColumn.COMMODITY_ID: Utils.parseIntDefault(row[2]),
          };
          await txn.insert(DBTables.GRADE_COMMODITY, itemGradeCommodityData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      log('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Item Grade Commodity $e');
      return false;
    }
  }

  Future<bool> csvImportGradeCommodityDetail() async {
    log('Importing Item Grade Commodity Detail');

    try {
      final Database db = dbProvider.lazyDatabase;
      var storagePath = await Utils().getExternalStoragePath();
      final File file = File(
          "$storagePath${FileManString.csvFilesCache}/grade_commodity_detail.csv");
      if (!file.existsSync()) {
        log('grade_commodity_detail CSV file not found');
        return false;
      }

      final inputStream = file.openRead();
      final fields = await inputStream
          .transform(utf8.decoder)
          .transform(const CsvToListConverter(eol: '\n', fieldDelimiter: '|'))
          .toList();

      await db.transaction((txn) async {
        await txn.rawDelete('DELETE FROM ${DBTables.GRADE_COMMODITY_DETAIL}');
        log('fields ${fields.length} ${DBTables.GRADE_COMMODITY_DETAIL}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemGradeCommodityDetailData = {
            GradeCommodityDetailColumn.ID: Utils.parseIntDefault(row[0]),
            GradeCommodityDetailColumn.GRADE_ID: Utils.parseIntDefault(row[1]),
            GradeCommodityDetailColumn.GRADE_COMMODITY_ID:
                Utils.parseIntDefault(row[2]),
            GradeCommodityDetailColumn.STATUS: row[3],
            GradeCommodityDetailColumn.SORT_SEQUENCE_FIELD:
                Utils.parseIntDefault(row[4]),
          };
          await txn.insert(
              DBTables.GRADE_COMMODITY_DETAIL, itemGradeCommodityDetailData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      log('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Item Grade Commodity Detail $e');
      return false;
    }
  }

  Future<bool> csvImportSpecification() async {
    log('Importing Item specification');

    try {
      final Database db = dbProvider.lazyDatabase;
      var storagePath = await Utils().getExternalStoragePath();
      final File file =
          File("$storagePath${FileManString.csvFilesCache}/specification.csv");
      if (!file.existsSync()) {
        log('specification CSV file not found');
        return false;
      }

      final inputStream = file.openRead();
      final fields = await inputStream
          .transform(utf8.decoder)
          .transform(const CsvToListConverter(eol: '\n', fieldDelimiter: '|'))
          .toList();

      await db.transaction((txn) async {
        await txn.rawDelete('DELETE FROM ${DBTables.SPECIFICATION}');
        log('fields ${fields.length} ${DBTables.SPECIFICATION}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemSpecificationData = {
            SpecificationColumn.NUMBER: row[0],
            SpecificationColumn.VERSION: row[1],
            SpecificationColumn.NAME: row[2],
            SpecificationColumn.ITEM_GROUP1_ID: Utils.parseIntDefault(row[3]),
            SpecificationColumn.COMMODITY_ID: Utils.parseIntDefault(row[4]),
            SpecificationColumn.SPECIFICATION_TYPE_ID:
                Utils.parseIntDefault(row[5]),
          };
          await txn.insert(DBTables.SPECIFICATION, itemSpecificationData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      log('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Item specification $e');
      return false;
    }
  }

  Future<bool> csvImportMaterialSpecification() async {
    log('Importing Item Material Specification');

    try {
      final Database db = dbProvider.lazyDatabase;
      var storagePath = await Utils().getExternalStoragePath();
      final File file = File(
          "$storagePath${FileManString.csvFilesCache}/material_specification.csv");
      if (!file.existsSync()) {
        log('material_specification CSV file not found');
        return false;
      }

      final inputStream = file.openRead();
      final fields = await inputStream
          .transform(utf8.decoder)
          .transform(const CsvToListConverter(eol: '\n', fieldDelimiter: '|'))
          .toList();

      await db.transaction((txn) async {
        await txn.rawDelete('DELETE FROM ${DBTables.MATERIAL_SPECIFICATION}');
        log('fields ${fields.length} ${DBTables.MATERIAL_SPECIFICATION}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemMaterialSpecificationData = {
            MaterialSpecificationColumn.NUMBER_SPECIFICATION: row[0],
            MaterialSpecificationColumn.VERSION_SPECIFICATION: row[1],
            MaterialSpecificationColumn.GRADE_ID: Utils.parseIntDefault(row[2]),
            MaterialSpecificationColumn.STATUS: row[3],
          };
          await txn.insert(
              DBTables.MATERIAL_SPECIFICATION, itemMaterialSpecificationData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      log('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Item Material Specification $e');
      return false;
    }
  }

  Future<bool> csvImportSpecificationSupplier() async {
    log('Importing Item Specification Supplier');

    try {
      final Database db = dbProvider.lazyDatabase;
      var storagePath = await Utils().getExternalStoragePath();
      final File file = File(
          "$storagePath${FileManString.csvFilesCache}/specification_supplier.csv");
      if (!file.existsSync()) {
        log('specification_supplier CSV file not found');
        return false;
      }

      final inputStream = file.openRead();
      final fields = await inputStream
          .transform(utf8.decoder)
          .transform(const CsvToListConverter(eol: '\n', fieldDelimiter: '|'))
          .toList();

      await db.transaction((txn) async {
        await txn.rawDelete('DELETE FROM ${DBTables.SPECIFICATION_SUPPLIER}');
        log('fields ${fields.length} ${DBTables.SPECIFICATION_SUPPLIER}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemSpecificationSupplierData = {
            SpecificationSupplierColumn.NUMBER_SPECIFICATION: row[0],
            SpecificationSupplierColumn.VERSION_SPECIFICATION: row[1],
            SpecificationSupplierColumn.SUPPLIER_ID:
                Utils.parseIntDefault(row[2]),
            SpecificationSupplierColumn.NEGOTIATION_STATUS: row[3],
            SpecificationSupplierColumn.STATUS: row[4],
            SpecificationSupplierColumn.ITEM_SKU_ID:
                Utils.parseIntDefault(row[5]),
            SpecificationSupplierColumn.GTIN: row[6],
            SpecificationSupplierColumn.SPECIFICATION_SUPPLIER_ID:
                Utils.parseIntDefault(row[7]),
          };
          await txn.insert(
              DBTables.SPECIFICATION_SUPPLIER, itemSpecificationSupplierData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      log('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Item Specification Supplier $e');
      return false;
    }
  }

  Future<bool> csvImportSpecificationGradeTolerance() async {
    log('Importing Item Specification Grade Tolerance');

    try {
      final Database db = dbProvider.lazyDatabase;
      var storagePath = await Utils().getExternalStoragePath();
      final File file = File(
          "$storagePath${FileManString.csvFilesCache}/specification_grade_tolerance.csv");
      if (!file.existsSync()) {
        log('specification_grade_tolerance CSV file not found');
        return false;
      }

      final inputStream = file.openRead();
      final fields = await inputStream
          .transform(utf8.decoder)
          .transform(const CsvToListConverter(eol: '\n', fieldDelimiter: '|'))
          .toList();

      await db.transaction((txn) async {
        await txn
            .rawDelete('DELETE FROM ${DBTables.SPECIFICATION_GRADE_TOLERANCE}');
        log('fields ${fields.length} ${DBTables.SPECIFICATION_GRADE_TOLERANCE}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemSpecificationGradeToleranceData = {
            SpecificationGradeToleranceColumn.SPECIFICATION_GRADE_TOLERANCE_ID:
                row[0],
            SpecificationGradeToleranceColumn.NUMBER_SPECIFICATION: row[1],
            SpecificationGradeToleranceColumn.VERSION_SPECIFICATION: row[2],
            SpecificationGradeToleranceColumn.SEVERITY_DEFECT_ID: row[3],
            SpecificationGradeToleranceColumn.DEFECT_ID:
                Utils.parseIntDefault(row[4]),
            SpecificationGradeToleranceColumn.GRADE_TOLERANCE_PERCENTAGE:
                Utils.parseDoubleDefault(row[5].toString().trim()),
            SpecificationGradeToleranceColumn.OVERRIDDEN:
                Utils.parseIntDefault(row[6]),
            SpecificationGradeToleranceColumn.DEFECT_NAME: row[7],
            SpecificationGradeToleranceColumn.DEFECT_CATEGORY_NAME: row[8],
            SpecificationGradeToleranceColumn.SEVERITY_DEFECT_NAME: row[9],
          };
          await txn.insert(DBTables.SPECIFICATION_GRADE_TOLERANCE,
              itemSpecificationGradeToleranceData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      log('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Item Specification Grade Tolerance $e');
      return false;
    }
  }

  Future<bool> csvImportSpecificationAnalytical() async {
    log('Importing Item Specification Analytical');

    try {
      final Database db = dbProvider.lazyDatabase;
      var storagePath = await Utils().getExternalStoragePath();
      final File file = File(
          "$storagePath${FileManString.csvFilesCache}/specification_analytical.csv");
      if (!file.existsSync()) {
        log('specification_analytical CSV file not found');
        return false;
      }

      final inputStream = file.openRead();
      final fields = await inputStream
          .transform(utf8.decoder)
          .transform(const CsvToListConverter(eol: '\n', fieldDelimiter: '|'))
          .toList();

      await db.transaction((txn) async {
        await txn.rawDelete('DELETE FROM ${DBTables.SPECIFICATION_ANALYTICAL}');
        log('fields ${fields.length} ${DBTables.SPECIFICATION_ANALYTICAL}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemSpecificationAnalyticalData = {
            SpecificationAnalyticalColumn.NUMBER_SPECIFICATION: row[0],
            SpecificationAnalyticalColumn.VERSION_SPECIFICATION: row[1],
            SpecificationAnalyticalColumn.ANALYTICAL_ID:
                Utils.parseIntDefault(row[2]),
            SpecificationAnalyticalColumn.ANALYTICAL_NAME: row[3],
            SpecificationAnalyticalColumn.DESCRIPTION: row[5],
            SpecificationAnalyticalColumn.SPEC_MIN:
                Utils.parseDoubleDefault(row[6].toString().trim()),
            SpecificationAnalyticalColumn.SPEC_MAX:
                Utils.parseDoubleDefault(row[7].toString().trim()),
            SpecificationAnalyticalColumn.TARGET_NUM_VALUE:
                Utils.parseDoubleDefault(row[8]),
            SpecificationAnalyticalColumn.TARGET_TEXT_VALUE: row[9],
            SpecificationAnalyticalColumn.UOM_NAME: row[10],
            SpecificationAnalyticalColumn.TYPE_ENTRY:
                Utils.parseIntDefault(row[11]),
            SpecificationAnalyticalColumn.ORDER_NO:
                Utils.parseIntDefault(row[12]),
            SpecificationAnalyticalColumn.PICTURE_REQUIRED: row[13],
            SpecificationAnalyticalColumn.TARGET_TEXT_DEFAULT: row[14],
            SpecificationAnalyticalColumn.INSPECTION_RESULT: row[15],
          };
          await txn.insert(DBTables.SPECIFICATION_ANALYTICAL,
              itemSpecificationAnalyticalData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      log('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Item Specification Analytical $e');
      return false;
    }
  }

  Future<bool> csvImportSpecificationPackagingFinishedGoods() async {
    log('Importing Item Specification Analytical');

    try {
      final Database db = dbProvider.lazyDatabase;
      var storagePath = await Utils().getExternalStoragePath();
      final File file = File(
          "$storagePath${FileManString.csvFilesCache}/specification_packaging_finished_goods.csv");
      if (!file.existsSync()) {
        log('specification_analytical CSV file not found');
        return false;
      }

      final inputStream = file.openRead();
      final fields = await inputStream
          .transform(utf8.decoder)
          .transform(const CsvToListConverter(eol: '\n', fieldDelimiter: '|'))
          .toList();

      await db.transaction((txn) async {
        await txn.rawDelete(
            'DELETE FROM ${DBTables.SPECIFICATION_PACKAGING_FINISHED_GOODS}');
        log('fields ${fields.length} ${DBTables.SPECIFICATION_PACKAGING_FINISHED_GOODS}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemSpecificationAnalyticalData = {
            SpecificationPackagingFinishedGoodsColumn.FINISHED_GOODS_ID:
                Utils.parseIntDefault(row[0]),
            SpecificationPackagingFinishedGoodsColumn.NUMBER_SPECIFICATION:
                row[1],
            SpecificationPackagingFinishedGoodsColumn.VERSION_SPECIFICATION:
                row[2],
            SpecificationPackagingFinishedGoodsColumn.ITEM_SKU_ID:
                Utils.parseIntDefault(row[3]),
          };
          await txn.insert(DBTables.SPECIFICATION_PACKAGING_FINISHED_GOODS,
              itemSpecificationAnalyticalData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      log('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Item Specification Analytical $e');
      return false;
    }
  }

  Future<bool> csvImportSpecificationType() async {
    log('Importing Item Specification Type');

    try {
      final Database db = dbProvider.lazyDatabase;
      var storagePath = await Utils().getExternalStoragePath();
      final File file = File(
          "$storagePath${FileManString.csvFilesCache}/specification_type.csv");
      if (!file.existsSync()) {
        log('specification_type CSV file not found');
        return false;
      }

      final inputStream = file.openRead();
      final fields = await inputStream
          .transform(utf8.decoder)
          .transform(const CsvToListConverter(eol: '\n', fieldDelimiter: '|'))
          .toList();

      await db.transaction((txn) async {
        await txn.rawDelete('DELETE FROM ${DBTables.SPECIFICATION_TYPE}');
        log('fields ${fields.length} ${DBTables.SPECIFICATION_TYPE}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemSpecificationTypeData = {
            SpecificationTypeColumn.SPECIFICATION_TYPE_ID:
                Utils.parseIntDefault(row[0]),
            SpecificationTypeColumn.NAME: row[1],
          };
          await txn.insert(
              DBTables.SPECIFICATION_TYPE, itemSpecificationTypeData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      log('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Item Specification Type $e');
      return false;
    }
  }

  Future<bool> csvImportCommodity() async {
    log('Importing Item Commodity');

    try {
      final Database db = dbProvider.lazyDatabase;
      var storagePath = await Utils().getExternalStoragePath();
      final File file =
          File("$storagePath${FileManString.csvFilesCache}/commodity.csv");
      if (!file.existsSync()) {
        log('commodity CSV file not found');
        return false;
      }

      final inputStream = file.openRead();
      final fields = await inputStream
          .transform(utf8.decoder)
          .transform(const CsvToListConverter(eol: '\n', fieldDelimiter: '|'))
          .toList();

      await db.transaction((txn) async {
        await txn.rawDelete('DELETE FROM ${DBTables.COMMODITY}');
        log('fields ${fields.length} ${DBTables.COMMODITY}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemCommodityData = {
            CommodityColumn.ID: Utils.parseIntDefault(row[0]),
            CommodityColumn.NAME: row[1],
            CommodityColumn.SAMPLE_SIZE_BY_COUNT: row[4],
            CommodityColumn.KEYWORDS: row[7],
          };
          await txn.insert(DBTables.COMMODITY, itemCommodityData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      log('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Item Commodity $e');
      return false;
    }
  }

  Future<bool> csvImportCommodityKeywords() async {
    log('Importing Item Commodity Keywords');

    try {
      final Database db = dbProvider.lazyDatabase;
      var storagePath = await Utils().getExternalStoragePath();
      final File file = File(
          "$storagePath${FileManString.csvFilesCache}/commodity_keywords.csv");
      if (!file.existsSync()) {
        log('commodity_keywords CSV file not found');
        return false;
      }

      final inputStream = file.openRead();
      final fields = await inputStream
          .transform(utf8.decoder)
          .transform(const CsvToListConverter(eol: '\n', fieldDelimiter: '|'))
          .toList();

      await db.transaction((txn) async {
        await txn.rawDelete('DELETE FROM ${DBTables.COMMODITY_KEYWORDS}');
        log('fields ${fields.length} ${DBTables.COMMODITY_KEYWORDS}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemCommodityKeywordsData = {
            CommodityKeywordsColumn.ID: Utils.parseIntDefault(row[0]),
            CommodityKeywordsColumn.KEYWORDS: row[1],
          };
          await txn.insert(
              DBTables.COMMODITY_KEYWORDS, itemCommodityKeywordsData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      log('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Item Commodity Keywords $e');
      return false;
    }
  }

  Future<bool> csvImportPOHeader() async {
    log('Importing Item POHeader');

    try {
      final Database db = dbProvider.lazyDatabase;
      var storagePath = await Utils().getExternalStoragePath();
      final File file = File(
          "$storagePath${FileManString.csvFilesCache}/purchase_order_header.csv");
      if (!file.existsSync()) {
        log('purchase_order_header CSV file not found');
        return false;
      }

      final inputStream = file.openRead();
      final fields = await inputStream
          .transform(utf8.decoder)
          .transform(const CsvToListConverter(eol: '\n', fieldDelimiter: '|'))
          .toList();

      await db.transaction((txn) async {
        await txn.rawDelete('DELETE FROM ${DBTables.PO_HEADER}');
        log('fields ${fields.length} ${DBTables.PO_HEADER}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemPOHeaderData = {
            POHeaderColumn.PO_HEADER_ID: row[0],
            POHeaderColumn.PO_NUMBER: row[1],
            POHeaderColumn.PO_DELIVER_TO_ID: Utils.parseIntDefault(row[2]),
            POHeaderColumn.PO_DELIVER_TO_NAME: row[3],
            POHeaderColumn.PO_PARTNER_ID: Utils.parseIntDefault(row[4]),
            POHeaderColumn.PO_PARTNER_NAME: row[5],
          };
          await txn.insert(DBTables.PO_HEADER, itemPOHeaderData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      log('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Item POHeader $e');
      return false;
    }
  }

  Future<bool> csvImportPODetail() async {
    log('Importing Item PODetail');

    try {
      final Database db = dbProvider.lazyDatabase;
      var storagePath = await Utils().getExternalStoragePath();
      final File file = File(
          "$storagePath${FileManString.csvFilesCache}/purchase_order_detail.csv");
      if (!file.existsSync()) {
        log('purchase_order_detail CSV file not found');
        return false;
      }

      final inputStream = file.openRead();
      final fields = await inputStream
          .transform(utf8.decoder)
          .transform(const CsvToListConverter(eol: '\n', fieldDelimiter: '|'))
          .toList();

      await db.transaction((txn) async {
        await txn.rawDelete('DELETE FROM ${DBTables.PO_DETAIL}');
        log('fields ${fields.length} ${DBTables.PO_DETAIL}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemPODetailData = {
            PODetailColumn.PO_DETAIL_ID: row[0],
            PODetailColumn.PO_HEADER_ID: row[1],
            PODetailColumn.PO_DETAIL_NUMBER: row[2],
            PODetailColumn.PO_DELIVER_TO_ID: Utils.parseIntDefault(row[3]),
            PODetailColumn.PO_DELIVER_TO_NAME: row[4],
            PODetailColumn.PO_LINE_NUMBER: Utils.parseIntDefault(row[5]),
            PODetailColumn.PO_ITEM_SKU_ID: Utils.parseIntDefault(row[6]),
            PODetailColumn.PO_ITEM_SKU_CODE: row[7],
            PODetailColumn.PO_ITEM_SKU_NAME: row[8],
            PODetailColumn.PO_QUANTITY: Utils.parseDoubleDefault(row[9]),
            PODetailColumn.PO_QTY_UOM_ID: Utils.parseIntDefault(row[10]),
            PODetailColumn.PO_QTY_UOM_NAME: row[11],
            PODetailColumn.PO_NUMBER_SPEC: row[12],
            PODetailColumn.PO_VERSION_SPEC: row[13],
            PODetailColumn.PO_COMMODITY_ID: Utils.parseIntDefault(row[14]),
            PODetailColumn.PO_COMMODITY_NAME: row[15],
            PODetailColumn.PO_ORDER_TYPE: row[16],
            PODetailColumn.PO_FTL: row[17],
            PODetailColumn.PO_BRANDED: row[18],
            PODetailColumn.PO_CREATED_DATE: row[19],
          };
          await txn.insert(DBTables.PO_DETAIL, itemPODetailData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      log('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Item PODetail $e');
      return false;
    }
  }

  Future<bool> csvImportSpecificationSupplierGtins() async {
    log('Importing Item Specification SupplierGtins');

    try {
      final Database db = dbProvider.lazyDatabase;
      var storagePath = await Utils().getExternalStoragePath();
      final File file = File(
          "$storagePath${FileManString.csvFilesCache}/specification_supplier_gtins.csv");
      if (!file.existsSync()) {
        log('specification_supplier_gtins CSV file not found');
        return false;
      }

      final inputStream = file.openRead();
      final fields = await inputStream
          .transform(utf8.decoder)
          .transform(const CsvToListConverter(eol: '\n', fieldDelimiter: '|'))
          .toList();

      await db.transaction((txn) async {
        await txn
            .rawDelete('DELETE FROM ${DBTables.SPECIFICATION_SUPPLIER_GTIN}');
        log('fields ${fields.length} ${DBTables.SPECIFICATION_SUPPLIER_GTIN}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemSpecificationSupplierGtinsData = {
            SpecificationSupplierGtinColumn.SPECIFICATION_SUPPLIER_ID:
                Utils.parseIntDefault(row[0]),
            SpecificationSupplierGtinColumn.GTIN: row[1],
          };
          await txn.insert(DBTables.SPECIFICATION_SUPPLIER_GTIN,
              itemSpecificationSupplierGtinsData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      log('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Specification Supplier Gtins $e');
      return false;
    }
  }

  Future<bool> csvImportCommodityCTE() async {
    log('Importing Item Commodity CTE');

    try {
      final Database db = dbProvider.lazyDatabase;
      var storagePath = await Utils().getExternalStoragePath();
      final File file = File(
          "$storagePath${FileManString.csvFilesCache}/supplier_commodity.csv");
      if (!file.existsSync()) {
        log('supplier_commodity CSV file not found');
        return false;
      }

      final inputStream = file.openRead();
      final fields = await inputStream
          .transform(utf8.decoder)
          .transform(const CsvToListConverter(eol: '\n', fieldDelimiter: '|'))
          .toList();

      await db.transaction((txn) async {
        await txn.rawDelete('DELETE FROM ${DBTables.COMMODITY_CTE}');
        log('fields ${fields.length} ${DBTables.COMMODITY_CTE}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemCommodityCteData = {
            CommodityCteColumn.ID: Utils.parseIntDefault(row[0]),
            CommodityCteColumn.NAME: row[1],
            CommodityCteColumn.SAMPLE_SIZE_BY_COUNT: row[4],
            CommodityCteColumn.KEYWORDS: row[7],
          };
          await txn.insert(DBTables.COMMODITY_CTE, itemCommodityCteData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      log('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Commodity CTE $e');
      return false;
    }
  }

  Future<QCHeaderDetails?> findTempQCHeaderDetails(String poNumber) async {
    QCHeaderDetails? qcItem;
    final Database db = dbProvider.lazyDatabase;

    try {
      List<Map<String, dynamic>> result = await db.query(
        DBTables.TEMP_QC_HEADER_DETAILS,
        where: '${TempQcHeaderDetailsColumn.PO_NUMBER} == ?',
        whereArgs: [poNumber],
      );

      // try {
      //   List<Map<String, dynamic>> result = await database.query(
      //     'TEMP_QC_HEADER_DETAILS_TABLE',
      //     where: 'TEMP_QC_HEADER_DETAILS_COLUMNS[Temp_QCHPoNo] = ?',
      //     whereArgs: [poNumber],
      //   );

      if (result.isNotEmpty) {
        Map<String, dynamic> row = result.first;
        qcItem = QCHeaderDetails(
          id: row[TempQcHeaderDetailsColumn.ID],
          poNo: row[TempQcHeaderDetailsColumn.PO_NUMBER],
          sealNo: row[TempQcHeaderDetailsColumn.SEAL_NUMBER],
          qchOpen1: row[TempQcHeaderDetailsColumn.QCH_OPEN1],
          qchOpen2: row[TempQcHeaderDetailsColumn.QCH_OPEN2],
          qchOpen3: row[TempQcHeaderDetailsColumn.QCH_OPEN3],
          qchOpen4: row[TempQcHeaderDetailsColumn.QCH_OPEN4],
          qchOpen5: row[TempQcHeaderDetailsColumn.QCH_OPEN5],
          qchOpen6: row[TempQcHeaderDetailsColumn.QCH_OPEN6],
          qchOpen9: row[TempQcHeaderDetailsColumn.QCH_OPEN9],
          qchOpen10: row[TempQcHeaderDetailsColumn.QCH_OPEN10],
          truckTempOk: row[TempQcHeaderDetailsColumn.TRUCK_TEMP_OK],
          productTransfer: row[TempQcHeaderDetailsColumn.PRODUCT_TRANSFER],
          cteType: row[TempQcHeaderDetailsColumn.CTE_TYPE],
        );
      }
    } catch (e) {
      log('Error has occurred while finding qcItem: $e');
    }
    return qcItem;
  }

  Future<List<PurchaseOrderDetails>> getPODetailsFromTable(
      String poNumber, int inspectorSupplierId) async {
    List<PurchaseOrderDetails> purchaseOrderDetailsList = [];

    final Database _db = dbProvider.lazyDatabase;
    print('DBRequest getPODetailsFromTable');
    try {
      List<Map<String, dynamic>> results = await _db.rawQuery('''
      SELECT poh.PO_Number, poh.PO_Deliver_To_Id, poh.PO_Deliver_To_Name, poh.PO_Partner_Id,
      poh.PO_Partner_Name,
      pod.PO_Line_Number, pod.PO_Item_Sku_Id, pod.PO_Item_Sku_Code, pod.PO_Item_Sku_Name,
      pod.PO_Quantity, pod.PO_Qty_UOM_Id, pod.PO_Qty_UOM_Name,
      pod.PO_Number_Spec, pod.PO_Version_Spec, pod.PO_Commodity_Id, pod.PO_Commodity_Name
      FROM ${DBTables.PO_DETAIL} pod
      INNER JOIN ${DBTables.PO_HEADER} poh ON pod.PO_Header_ID=poh.PO_Header_ID
      WHERE poh.PO_Number='$poNumber' AND poh.PO_Deliver_To_Id=$inspectorSupplierId
    ''');

      for (var result in results) {
        purchaseOrderDetailsList.add(PurchaseOrderDetails.fromMap(result));
      }
    } catch (e) {
      log('Error has occurred while finding pfg: $e');
    }
    return purchaseOrderDetailsList;
  }

  Future<List<int>> getPartnerSKUInspectionIDsByPONo(String poNumber) async {
    List<int> inspIDs = [];
    final Database _db = dbProvider.lazyDatabase;
    try {
      List<Map<String, dynamic>> results = await _db.rawQuery('''
        SELECT ${PartnerItemSkuColumn.INSPECTION_ID} FROM ${DBTables.PARTNER_ITEMSKU} WHERE ${PartnerItemSkuColumn.PO_NO}=?
      ''', [poNumber]);

      for (var result in results) {
        inspIDs.add(result[PartnerItemSkuColumn.INSPECTION_ID]);
      }
    } catch (e) {
      log('Error has occurred while finding partner sku inspection ids: $e');
    }
    return inspIDs;
  }

  Future<int?> createTempQCHeaderDetails({
    required int partnerID,
    required String poNo,
    required String sealNo,
    required String qchOpen1,
    required String qchOpen2,
    required String qchOpen3,
    required String qchOpen4,
    required String qchOpen5,
    required String qchOpen6,
    required String qchOpen9,
    required String qchOpen10,
    required String truckTempOk,
    required String productTransfer,
    required String cteType,
  }) async {
    int? ttId;
    final Database _db = dbProvider.lazyDatabase;
    try {
      await _db.transaction((txn) async {
        ttId = await txn.insert(DBTables.TEMP_QC_HEADER_DETAILS, {
          TempQcHeaderDetailsColumn.PARTNER_ID: partnerID,
          TempQcHeaderDetailsColumn.PO_NUMBER: poNo,
          TempQcHeaderDetailsColumn.SEAL_NUMBER: sealNo,
          TempQcHeaderDetailsColumn.QCH_OPEN1: qchOpen1,
          TempQcHeaderDetailsColumn.QCH_OPEN2: qchOpen2,
          TempQcHeaderDetailsColumn.QCH_OPEN3: qchOpen3,
          TempQcHeaderDetailsColumn.QCH_OPEN4: qchOpen4,
          TempQcHeaderDetailsColumn.QCH_OPEN5: qchOpen5,
          TempQcHeaderDetailsColumn.QCH_OPEN6: qchOpen6,
          TempQcHeaderDetailsColumn.QCH_OPEN9: qchOpen9,
          TempQcHeaderDetailsColumn.QCH_OPEN10: qchOpen10,
          TempQcHeaderDetailsColumn.TRUCK_TEMP_OK: truckTempOk,
          TempQcHeaderDetailsColumn.PRODUCT_TRANSFER: productTransfer,
          TempQcHeaderDetailsColumn.CTE_TYPE: cteType,
        });
      });
    } catch (e) {
      log('Error has occurred while creating a trailer temperature: $e');
      rethrow;
    }
    return ttId;
  }

  Future<void> updateTempQCHeaderDetails({
    required int baseId,
    required String poNo,
    required String sealNo,
    required String qchOpen1,
    required String qchOpen2,
    required String qchOpen3,
    required String qchOpen4,
    required String qchOpen5,
    required String qchOpen6,
    required String qchOpen9,
    required String qchOpen10,
    required String truckTempOk,
    required String productTransfer,
    required String cteType,
  }) async {
    // Open the db
    final Database db = dbProvider.lazyDatabase;

    try {
      // Begin a transaction
      await db.transaction((txn) async {
        await txn.update(
          DBTables.TEMP_QC_HEADER_DETAILS,
          {
            TempQcHeaderDetailsColumn.PO_NUMBER: poNo,
            TempQcHeaderDetailsColumn.SEAL_NUMBER: sealNo,
            TempQcHeaderDetailsColumn.QCH_OPEN1: qchOpen1,
            TempQcHeaderDetailsColumn.QCH_OPEN2: qchOpen2,
            TempQcHeaderDetailsColumn.QCH_OPEN3: qchOpen3,
            TempQcHeaderDetailsColumn.QCH_OPEN4: qchOpen4,
            TempQcHeaderDetailsColumn.QCH_OPEN5: qchOpen5,
            TempQcHeaderDetailsColumn.QCH_OPEN6: qchOpen6,
            TempQcHeaderDetailsColumn.QCH_OPEN9: qchOpen9,
            TempQcHeaderDetailsColumn.QCH_OPEN10: qchOpen10,
            TempQcHeaderDetailsColumn.TRUCK_TEMP_OK: truckTempOk,
            TempQcHeaderDetailsColumn.PRODUCT_TRANSFER: productTransfer,
            TempQcHeaderDetailsColumn.CTE_TYPE: cteType,
          },
          where: '${BaseColumns.ID} = ?',
          whereArgs: [baseId],
        );
      });
    } catch (e) {
      log('Error has occurred while updating a trailer temperature: $e');
      throw e;
    }
  }

  Future<void> updateTempQCHeaderDetailComments({
    required String poNo,
    required String comments,
  }) async {
    final Database db = dbProvider.lazyDatabase;

    try {
      await db.transaction((txn) async {
        Map<String, dynamic> values = {};

        if (comments.isNotEmpty) {
          values[TempQcHeaderDetailsColumn.QCH_OPEN10] = comments;
        }

        await txn.update(
          DBTables.TEMP_QC_HEADER_DETAILS,
          values,
          where: '${TempQcHeaderDetailsColumn.PO_NUMBER} = ?',
          whereArgs: [poNo],
        );
      });
    } catch (e) {
      log('Update Temp QC Header Details Comments : $e');
      throw e;
    }
  }

  Future<String> getTempQCHeaderDetailsComments(String poNumber) async {
    final Database db = dbProvider.lazyDatabase;

    String comments = '';
    List<dynamic> args = [poNumber];

    try {
      String query = '''
      SELECT * FROM ${DBTables.TEMP_QC_HEADER_DETAILS} 
      WHERE ${TempQcHeaderDetailsColumn.PO_NUMBER} = ?
    ''';

      List<Map<String, dynamic>> result = await db.rawQuery(query, args);

      if (result.isNotEmpty) {
        comments = result.first[TempQcHeaderDetailsColumn.QCH_OPEN10] ?? '';
      }
    } catch (e) {
      log('Error Get Temp QC Header Details Comments: $e');
    }

    return comments;
  }

  Future<List<SpecificationSupplierGTIN>?>
      getSpecificationSupplierGTINFromTable(String gtin) async {
    List<SpecificationSupplierGTIN> itemSKUList = [];
    SpecificationSupplierGTIN item;
    final Database db = dbProvider.lazyDatabase;

    try {
      String? specNo = "";
      String? specVersion = "";

      String query =
          "Select distinct number_specification, version_specification from ${DBTables.SPECIFICATION_SUPPLIER} ss " +
              "inner join specification_supplier_gtin sgtin on sgtin.Specification_Supplier_ID=ss.Specification_Supplier_ID " +
              "where sgtin.gtin='" +
              gtin +
              "'";

      db.rawQuery(query).then((cursor) {
        if (cursor.isNotEmpty) {
          for (var row in cursor) {
            specNo = row["number_specification"] as String?;
            specVersion = row["version_specification"] as String?;
          }
        }
      });

      String query2 = "SELECT SP.NUMBER, SP.VERSION, SP.NAME, SS.SUPPLIER_ID, SGTIN.GTIN, SPECTYPE.NAME AS SPECIFICATION_TYPE," +
          "SKU.SKU_ID AS ITEM_SKU_ID, SKU.NAME AS ITEM_SKU_NAME, SKU.CODE AS ITEM_SKU_CODE," +
          "COMMODITY.ID AS COMMODITY_ID, COMMODITY.NAME AS COMMODITY_NAME, COMMODITY.Sample_Size_By_Count," +
          "VARIETY.Group1_ID AS VARIETY_ID, VARIETY.NAME AS VARIETY_NAME, GRADE.ID AS GRADE_ID, GRADE.NAME AS GRADE_NAME, AGENCY.ID AS AGENCY_ID, AGENCY.NAME AS AGENCY_NAME " +
          "FROM ${DBTables.SPECIFICATION_SUPPLIER} SS JOIN SPECIFICATION SP ON (SS.NUMBER_SPECIFICATION,SS.VERSION_SPECIFICATION)=(SP.NUMBER,SP.VERSION) " +
          "INNER JOIN SPECIFICATION_SUPPLIER_GTIN SGTIN ON SGTIN.SPECIFICATION_SUPPLIER_ID=SS.Specification_Supplier_ID " +
          "JOIN MATERIAL_SPECIFICATION MS ON (SP.NUMBER,SP.VERSION)=(MS.NUMBER_SPECIFICATION,MS.VERSION_SPECIFICATION) " +
          "JOIN SPECIFICATION_TYPE SPECTYPE ON SP.SPECIFICATION_TYPE_ID=SPECTYPE.Specification_Type_ID " +
          "LEFT JOIN ITEM_SKU SKU ON SS.ITEM_SKU_ID=SKU.SKU_ID " +
          "LEFT JOIN COMMODITY COMMODITY ON SP.COMMODITY_ID = COMMODITY.ID " +
          "LEFT JOIN ItemGroup1 VARIETY ON SP.Item_Group1_ID=VARIETY.Group1_ID " +
          "LEFT JOIN GRADE ON MS.GRADE_ID=GRADE.ID " +
          "LEFT JOIN AGENCY ON GRADE.AGENCY_ID=AGENCY.ID " +
          "WHERE SGTIN.GTIN='" +
          gtin +
          "'";

      db.rawQuery(query2).then((cursorList) {
        if (cursorList.isNotEmpty) {
          for (var cursor in cursorList) {
            item = SpecificationSupplierGTIN();
            // item.specificationNumber = cursor[0];
            // item.specificationVersion = cursor[1];
            // item.specificationName = cursor[2];
            // item.supplierId = cursor[3];
            // item.specificationTypeName = cursor[5];
            // item.itemSkuId = cursor[6];
            // item.itemSkuName = cursor[7];
            // item.itemSkuCode = cursor[8];
            // item.commodityId = cursor[9];
            // item.commodityName = cursor[10];
            // item.varietyId = cursor[11];
            // item.varietyName = cursor[12];
            // item.gradeId = cursor[13];
            // item.gradeName = cursor[14];
            // item.agencyId = cursor[15];
            // item.agencyName = cursor[16];
            List<PartnerItem> partnersList = appStorage.getPartnerList() ?? [];
            for (PartnerItem partnerItem in partnersList) {
              if (partnerItem.id != null && partnerItem.id == item.supplierId) {
                item.supplierName = partnerItem.name;
                break;
              }
            }

            SpecificationSupplierGTIN listItem = SpecificationSupplierGTIN(
              specificationNumber: item.specificationNumber,
              specificationVersion: item.specificationVersion,
              specificationName: item.specificationName,
              supplierName: item.supplierName,
              supplierId: item.supplierId,
              varietyId: item.varietyId,
              varietyName: item.varietyName,
              commodityId: item.commodityId,
              commodityName: item.commodityName,
              gtin: gtin,
              itemSkuId: item.itemSkuId,
              itemSkuName: item.itemSkuName,
              agencyId: item.agencyId,
              agencyName: item.agencyName,
              gradeId: item.gradeId,
              gradeName: item.gradeName,
              samplesizecount: item.samplesizecount,
              specificationTypeName: item.specificationTypeName,
              itemSkuCode: item.itemSkuCode,
            );

            itemSKUList.add(listItem);
          }
        }
      });
    } catch (e) {
      log("Error has occurred while finding supplier gtin: $e");
      return null;
    }

    return itemSKUList;
  }

  Future<int> createTempTrailerTemperature(int partnerID, String location,
      String level, String value, String poNumber) async {
    final Database db = dbProvider.lazyDatabase;
    int? ttId;
    try {
      await db.transaction((txn) async {
        ttId = await txn.insert(DBTables.TEMP_TRAILER_TEMPERATURE, {
          TrailerTemperatureDetailsColumn.PARTNER_ID: partnerID,
          TempTrailerTemperatureColumn.LOCATION: location,
          TempTrailerTemperatureColumn.LEVEL: level,
          TempTrailerTemperatureColumn.VALUE: value,
          TempTrailerTemperatureColumn.COMPLETE: 1,
          TempTrailerTemperatureColumn.PO_NUMBER: poNumber,
        });
      });
    } catch (e) {
      log("Error has occurred while creating a trailer temperature: $e");
    }
    return ttId ?? -1;
  }

  Future<List?> findTempTrailerTemperatureItems(
      int partnerId, String poNumber) async {
    List data = [];

    final Database db = dbProvider.lazyDatabase;
    try {
      List<Map<String, dynamic>> results = await db.query(
        DBTables.TEMP_TRAILER_TEMPERATURE,
        where:
            'po_number = ? and ${TrailerTemperatureDetailsColumn.PARTNER_ID} = ?',
        whereArgs: [poNumber, partnerId],
      );

      if (results.isNotEmpty) {
        for (Map<String, dynamic> row in results) {
          data.add(row);
        }
        for (var element in data) {
          log('element: ${element}');
        }
      }
    } catch (e) {
      log('Error has occurred while finding trailer temperature items: $e');
      return null;
      // Handle the error
    }

    return data;
  }

  Future<TrailerTemperatureDetails> findTempTrailerTemperatureDetails(
      int partnerID, String poNumber) async {
    TrailerTemperatureDetails trailerTempMap = TrailerTemperatureDetails();
    final Database db = dbProvider.lazyDatabase;
    try {
      String query =
          "SELECT * FROM ${DBTables.TEMP_TRAILER_TEMPERATURE_DETAILS} WHERE " +
              "${TempTrailerTemperatureDetailsColumn.PARTNER_ID}=? and ${TempTrailerTemperatureDetailsColumn.PO_NUMBER}=?";
      List<String> args = [partnerID.toString(), poNumber];
      List<Map> result = await db.rawQuery(query, args);

      if (result.isNotEmpty) {
        trailerTempMap.tempOpen1 =
            result[0]['${TempTrailerTemperatureDetailsColumn.TEMP_OPEN1}'];
        trailerTempMap.tempOpen2 =
            result[0]['${TempTrailerTemperatureDetailsColumn.TEMP_OPEN2}'];
        trailerTempMap.tempOpen3 =
            result[0]['${TempTrailerTemperatureDetailsColumn.TEMP_OPEN3}'];
        trailerTempMap.comments =
            result[0]['${TempTrailerTemperatureDetailsColumn.COMMENTS}'];
        trailerTempMap.poNumber =
            result[0]['${TempTrailerTemperatureDetailsColumn.PO_NUMBER}'];
      }
    } catch (e) {
      log("Error has occurred while finding trailer temperature items: $e");
      // rethrow e;
    }

    return trailerTempMap;
  }

  Future<TrailerTemperatureDetails> findTrailerTemperatureDetails(
      int inspectionId) async {
    TrailerTemperatureDetails trailerTempMap = TrailerTemperatureDetails();
    final Database db = dbProvider
        .lazyDatabase; // Assuming you have a dbProvider instance for database operations

    try {
      String query =
          "SELECT * FROM ${DBTables.TRAILER_TEMPERATURE_DETAILS} WHERE ${TrailerTemperatureDetailsColumn.ID} = ?";
      List<Map> result = await db.rawQuery(query, [inspectionId]);

      if (result.isNotEmpty) {
        trailerTempMap.tempOpen1 =
            result.first[TrailerTemperatureDetailsColumn.TEMP_OPEN1];
        trailerTempMap.tempOpen2 =
            result.first[TrailerTemperatureDetailsColumn.TEMP_OPEN2];
        trailerTempMap.tempOpen3 =
            result.first[TrailerTemperatureDetailsColumn.TEMP_OPEN3];
        trailerTempMap.comments =
            result.first[TrailerTemperatureDetailsColumn.COMMENTS];
        trailerTempMap.poNumber =
            result.first[TrailerTemperatureDetailsColumn.PO_NUMBER];
      }
    } catch (e) {
      print('Error has occurred while finding trailer temperature items: $e');
    }

    return trailerTempMap;
  }

  Future<bool> checkDataExists(txn, String columnName, String poNumber) async {
    try {
      var result = await txn.query(
        DBTables.TEMP_TRAILER_TEMPERATURE_DETAILS,
        where: '${TempTrailerTemperatureDetailsColumn.PO_NUMBER} = ?',
        whereArgs: [poNumber],
      );
      if (result.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log("Error occurred while checking data existence: $e");
      return false;
    }
  }

  Future<void> createTempTrailerTemperatureDetails(
      String partnerID,
      String tempOpen1,
      String tempOpen2,
      String tempOpen3,
      String comments,
      String poNumber) async {
    final Database db = dbProvider.lazyDatabase;
    int? ttId;
    try {
      await db.transaction((txn) async {
        var values = <String, dynamic>{
          TempTrailerTemperatureDetailsColumn.PARTNER_ID: partnerID,
          TempTrailerTemperatureDetailsColumn.TEMP_OPEN1: tempOpen1,
          TempTrailerTemperatureDetailsColumn.TEMP_OPEN2: tempOpen2,
          TempTrailerTemperatureDetailsColumn.TEMP_OPEN3: tempOpen3,
          TempTrailerTemperatureDetailsColumn.COMMENTS: comments,
          TempTrailerTemperatureDetailsColumn.PO_NUMBER: poNumber,
        };

        bool tempIsExists = await checkDataExists(txn,
            TempTrailerTemperatureDetailsColumn.PO_NUMBER, poNumber.toString());

        if (tempIsExists == true) {
          ttId = await txn.update(
              DBTables.TEMP_TRAILER_TEMPERATURE_DETAILS, values);
        } else {
          ttId = await txn.insert(
              DBTables.TEMP_TRAILER_TEMPERATURE_DETAILS, values);
        }
      });
    } catch (e) {
      log('Error occurred while creating a trailer temperature: $e');
      rethrow;
    }
  }

  Future<int> deleteRowsTempTrailerTable() async {
    try {
      final Database db = dbProvider.lazyDatabase;
      return await db.transaction((txn) async {
        return await txn.delete(DBTables.TEMP_TRAILER_TEMPERATURE);
      });
    } catch (e) {
      log('Error has deleting temp trailer temperature table: ${e.toString()}');
      return -1;
    }
  }

  Future<int> deleteTempTrailerTemperatureDetails() async {
    try {
      final Database db = dbProvider.lazyDatabase;
      return await db.transaction((txn) async {
        return await txn.delete(DBTables.TEMP_TRAILER_TEMPERATURE_DETAILS);
      });
    } catch (e) {
      log('Error has deleting temp trailer temperature details: ${e.toString()}');
      return -1;
    }
  }

  Future<int> deleteSelectedItemSKUList() async {
    try {
      final Database db = dbProvider.lazyDatabase;
      return await db.transaction((txn) async {
        return await txn.delete(DBTables.SELECTED_ITEM_SKU_LIST);
      });
    } catch (e) {
      log('Error has occurred while deleting selected item SKU list: $e');
      return -1;
    }
  }

  Future<List<InspectionDefectAttachment>?> findDefectAttachmentsByInspectionId(
      int inspectionId) async {
    final Database db = dbProvider.lazyDatabase;
    final List<Map<String, dynamic>> maps = await db.query(
        DBTables.INSPECTION_DEFECT_ATTACHMENT,
        where: '${InspectionDefectAttachmentColumn.INSPECTION_ID} = ?',
        whereArgs: [inspectionId]);
    return List.generate(maps.length, (i) {
      return InspectionDefectAttachment.fromJson(maps[i]);
    });
  }

  Future<List<FinishedGoodsItemSKU>?> getFinishedGoodItemSkuFromTable(
      int supplierId,
      int enterpriseId,
      int commodityId,
      String commodityName,
      int supplier_Id,
      int headquarterId,
      String partnerName) async {
    List<FinishedGoodsItemSKU> itemSKUList = [];
    FinishedGoodsItemSKU? item;
    String query;
    try {
      bool hqUser = (supplierId == headquarterId);

      if (hqUser) {
        query = "select distinct(itemSku.SKU_ID), itemSku.Name, itemSku.Code, itemSku.FTL, itemSku.Branded from ${DBTables.SPECIFICATION_SUPPLIER} SS " +
            "inner join Material_Specification MS on (SS.Number_Specification, SS.Version_Specification)=(MS.Number_Specification,MS.Version_Specification) " +
            "inner join Item_SKU itemSku on SS.Item_SKU_ID=itemSku.SKU_ID " +
            "inner join Commodity C on itemSku.Commodity_ID=C.ID " +
            "where SS.Status='A' and SS.supplier_id=? " +
            "AND itemSku.Usage_Type='FG' and itemSku.Status='AC' " +
            "AND itemSku.Company_Id =? " +
            "And MS.Status = 'A' and C.ID=?";
      } else {
        query = "select distinct(itemSku.SKU_ID), itemSku.Name, itemSku.Code, itemSku.FTL, itemSku.Branded from ${DBTables.SPECIFICATION_SUPPLIER} SS " +
            "inner join Material_Specification MS on (SS.Number_Specification, SS.Version_Specification)=(MS.Number_Specification,MS.Version_Specification) " +
            "inner join Item_SKU itemSku on SS.Item_SKU_ID=itemSku.SKU_ID " +
            "inner join Commodity C on itemSku.Commodity_ID=C.ID " +
            "where SS.Status='A' and SS.supplier_id=? " +
            "AND itemSku.Usage_Type='FG' and itemSku.Status='AC' " +
            "AND (itemSku.Company_Id =? or itemSku.Company_Id=?) " +
            "And MS.Status = 'A' and C.ID=?";
      }

      List<dynamic> args;
      if (hqUser) {
        args = [supplierId, headquarterId, commodityId];
      } else {
        args = [supplierId, headquarterId, supplierId, commodityId];
      }
      final Database db = dbProvider.lazyDatabase;

      List<Map<String, dynamic>> results = await db.rawQuery(query, args);

      for (Map<String, dynamic> row in results) {
        item = FinishedGoodsItemSKU();
        item = item.copyWith(
          id: row['SKU_ID'],
          name: row['Name'],
          sku: row['Code'],
          commodityName: commodityName,
          partnerId: supplierId,
          partnerName: partnerName,
          commodityID: commodityId,
          FTLflag: row['FTL'],
          Branded: row['Branded'],
        );

        itemSKUList.add(item);
      }
    } catch (e) {
      log('Error finding finished goods item SKU: $e');
      return null;
    }
    return itemSKUList;
  }

  Future<List<FinishedGoodsItemSKU>?> getFinishedGoodItemSkuFromTableCTE(
      int supplierId,
      int commodityId,
      String commodityName,
      int supplier_id,
      int headquarter_id) async {
    List<FinishedGoodsItemSKU> itemSKUList = [];
    final Database db = dbProvider.lazyDatabase;

    try {
      bool hqUser = (supplier_id == headquarter_id);

      String query2 =
          'SELECT DISTINCT itemSku.SKU_ID, itemSku.Name, itemSku.Code '
          'FROM Item_SKU itemSku '
          'WHERE Commodity_ID = ?';

      List<dynamic> args = [commodityId];

      List<Map<String, dynamic>> results = await db.rawQuery(query2, args);

      for (Map<String, dynamic> row in results) {
        FinishedGoodsItemSKU item = FinishedGoodsItemSKU(
          id: row['SKU_ID'],
          name: row['Name'],
          sku: row['Code'],
          commodityID: commodityId,
          commodityName: commodityName,
          partnerId: supplierId,
        );

        itemSKUList.add(item);
      }
    } catch (e) {
      debugPrint('DB 🔴 getFinishedGoodItemSkuFromTableCTE: $e');
      return null;
    }

    return itemSKUList;
  }

  Future<QualityControlItem?> findQualityControlDetails(
      int inspectionId) async {
    try {
      print('DBRequest findQualityControlDetails');
      final Database db = dbProvider.lazyDatabase;
      List<Map> results = await db.query(
        DBTables.QUALITY_CONTROL,
        where: '${QualityControlColumn.INSPECTION_ID} = ?',
        whereArgs: [inspectionId],
      );

      if (results.isNotEmpty) {
        return QualityControlItem.fromJson(
            results.first as Map<String, dynamic>);
      }
    } catch (e) {
      log('Error has occurred while finding quality control item: $e');
    }

    return null;
  }

  Future<List<TrailerTemperatureItem>> findListTrailerTemperatureItems(
      int inspectionId) async {
    List<TrailerTemperatureItem> trailerTempList = [];
    try {
      final Database db = dbProvider.lazyDatabase;
      List<Map> results = await db.query(
        DBTables.TRAILER_TEMPERATURE,
        where: '${TrailerTemperatureColumn.INSPECTION_ID} = ?',
        whereArgs: [inspectionId],
      );

      for (Map<dynamic, dynamic> map in results) {
        trailerTempList
            .add(TrailerTemperatureItem.fromMap(map as Map<String, dynamic>));
      }
    } catch (e) {
      log('Error has occurred while finding trailer temperature items: $e');
      return [];
    }

    return trailerTempList;
  }

  Future<List<SpecificationAnalyticalRequest>>
      findSpecificationAnalyticalRequest(int inspectionId) async {
    final Database db = dbProvider.lazyDatabase;
    List<SpecificationAnalyticalRequest> list = [];

    try {
      List<Map> results = await db.query(
        DBTables.SPECIFICATION_ATTRIBUTES,
        where: '${SpecificationAttributesColumn.INSPECTION_ID} = ?',
        whereArgs: [inspectionId],
      );

      for (Map<dynamic, dynamic> map in results) {
        list.add(SpecificationAnalyticalRequest.fromJson(
            map as Map<String, dynamic>));
      }
    } catch (e) {
      log('Error has occurred while finding specification analytical request: $e');
    }

    return list;
  }

  Future<OverriddenResult?> getOverriddenResult(int inspectionId) async {
    final Database db = dbProvider.lazyDatabase;
    print('DBRequest getOverriddenResult');
    OverriddenResult? item;
    try {
      List<Map> results = await db.rawQuery(
        'SELECT Overridden_By, Overridden_Result, Overridden_Timestamp, Overridden_Comments, Old_Result, Original_Qty_Shipped, Original_Qty_Rejected, New_Qty_Shipped, New_Qty_Rejected FROM ${DBTables.OVERRIDDEN_RESULT} WHERE Inspection_ID = ?',
        [inspectionId.toString()],
      );

      if (results.isNotEmpty) {
        item = OverriddenResult.fromMap(results.first as Map<String, dynamic>);
      }
    } catch (e) {
      log('Error has occurred while finding overridden result: $e');
      return null;
    }

    return item;
  }

  Future<List<Commodity>?> getCommodityByPartnerFromTable(int supplierId,
      int enterpriseId, int supplierIdParam, int headquarterId) async {
    List<Commodity> itemSKUList = [];
    Commodity item;
    final Database db = dbProvider.lazyDatabase;
    try {
      bool hqUser = (supplierIdParam == headquarterId);
      List<dynamic> args = [
        'A',
        supplierId,
        'FG',
        'AC',
        headquarterId,
        supplierId,
        'A'
      ];
      String query1 =
          'select distinct(c.id), c.name, c.keywords from ${DBTables.SPECIFICATION_SUPPLIER} SS '
          'inner join Material_Specification MS on (SS.Number_Specification, SS.Version_Specification)=(MS.Number_Specification,MS.Version_Specification) '
          'inner join Item_SKU itemSku on SS.Item_SKU_ID=itemSku.SKU_ID '
          'inner join Commodity C on itemSku.Commodity_ID=C.ID '
          'where SS.Status=? and SS.supplier_id=? '
          'AND itemSku.Usage_Type=? and itemSku.Status=? '
          'AND (itemSku.Company_Id =? or itemSku.Company_Id=?) '
          'AND MS.Status = ?';

      if (hqUser) {
        query1 =
            'select distinct(c.id), c.name, c.keywords from ${DBTables.SPECIFICATION_SUPPLIER} SS '
            'inner join Material_Specification MS on (SS.Number_Specification, SS.Version_Specification)=(MS.Number_Specification,MS.Version_Specification) '
            'inner join Item_SKU itemSku on SS.Item_SKU_ID=itemSku.SKU_ID '
            'inner join Commodity C on itemSku.Commodity_ID=C.ID '
            'where SS.Status=? and SS.supplier_id=? '
            'AND itemSku.Usage_Type=? and itemSku.Status=? and itemSku.Company_Id=? '
            'AND MS.Status = ?';
        args = ['A', supplierId, 'FG', 'AC', headquarterId, 'A'];
      }

      List<Map<String, dynamic>> cursor = await db.rawQuery(query1, args);

      for (Map<String, dynamic> row in cursor) {
        item = Commodity.fromJson(row as Map<String, dynamic>);
        itemSKUList.add(item);
      }
    } catch (e) {
      log('Error has occurred while finding commodity: $e');
      return null;
    }
    return itemSKUList;
  }

  Future<List<Commodity>?> getCommodityByDeliveryToFromTable(int supplierId,
      int enterpriseId, int supplierIdParam, int headquarterId) async {
    List<Commodity> itemSKUList = [];
    Commodity? item;
    final Database db = dbProvider.lazyDatabase;

    try {
      bool hqUser = (supplierIdParam == headquarterId);

      String query1 =
          "select distinct(c.id), c.name, c.keywords from Commodity C";

      List<Map<String, dynamic>> cursor = await db.rawQuery(query1);

      for (Map<String, dynamic> row in cursor) {
        item = Commodity.fromJson(row);
        itemSKUList.add(item);
      }
    } catch (e) {
      debugPrint(
          'Error has occurred while finding commodities Delivery From table: $e');
      return null;
    }

    return itemSKUList;
  }

  Future<int> getHeadquarterIdByUserId(String userID) async {
    final Database db = dbProvider.lazyDatabase;
    int enterpriseId = 0;
    List<dynamic> args = [userID];
    try {
      String query =
          'SELECT * FROM ${DBTables.USER_OFFLINE} WHERE ${UserOfflineColumn.USER_ID} = ?';
      List<Map<String, dynamic>> result = await db.rawQuery(query, args);

      if (result.isNotEmpty) {
        enterpriseId = result.first[UserOfflineColumn.HEADQUATER_SUPPLIER_ID];
      }
    } catch (e) {
      log('Error has occurred while finding a user id: $e');
      return -1;
    }
    return enterpriseId;
  }

  Future<bool> isInspectionComplete(
      int partnerId, String itemSKU, String? lotNo) async {
    List<dynamic> args = ['1', partnerId.toString(), itemSKU, lotNo];
    print('DBRequest isInspectionComplete');
    try {
      final Database db = dbProvider.lazyDatabase;
      String query =
          "Select * from ${DBTables.PARTNER_ITEMSKU} where ${PartnerItemSkuColumn.COMPLETE}=?"
          " and ${PartnerItemSkuColumn.PARTNER_ID}=?"
          " and ${PartnerItemSkuColumn.ITEM_SKU}=?"
          " and ${PartnerItemSkuColumn.UNIQUE_ID}=?";

      var cursor = await db.rawQuery(query, args);
      if (cursor.isNotEmpty) {
        return true;
      }
    } catch (e) {
      log("Error has occurred while finding pfg: $e");
      return false;
    }
    return false;
  }

  Future<PartnerItemSKUInspections?> findPartnerItemSKU(
      int partnerId, String itemSKU, String? uniqueId) async {
    List<dynamic> args = [partnerId.toString(), itemSKU, uniqueId];
    try {
      print('DBRequest findPartnerItemSKU');
      String query =
          "Select * from ${DBTables.PARTNER_ITEMSKU} where ${PartnerItemSkuColumn.PARTNER_ID}=?" +
              " and ${PartnerItemSkuColumn.ITEM_SKU}=?" +
              " and ${PartnerItemSkuColumn.UNIQUE_ID}=?";

      final Database db = dbProvider.lazyDatabase;
      var cursor = await db.rawQuery(query, args);

      if (cursor.isNotEmpty) {
        PartnerItemSKUInspections? item =
            PartnerItemSKUInspections.fromMap(cursor.first);
        return item;
      }
    } catch (e) {
      log("Error has occurred while finding pfg: $e");
      return null;
    }
    return null;
  }

  Future<List<SpecificationAnalytical>?> getSpecificationAnalyticalFromDB(
      String number, String version) async {
    List<SpecificationAnalytical> list = [];
    SpecificationAnalytical item;

    try {
      List<dynamic> args = [number, version];

      String query = "Select * from ${DBTables.SPECIFICATION_ANALYTICAL} where "
              "${SpecificationAnalyticalColumn.NUMBER_SPECIFICATION}=?" +
          " and ${SpecificationAnalyticalColumn.VERSION_SPECIFICATION}=?";
      final Database db = dbProvider.lazyDatabase;
      var cursor = await db.rawQuery(query, args);

      for (Map<String, dynamic> row in cursor) {
        item = SpecificationAnalytical.fromMap(row);
        list.add(item);
      }
    } catch (e) {
      log("Error has occurred while finding specification analytical: $e");
      return null;
    }
    return list;
  }

  Future<SpecificationAnalyticalRequest?> findSpecAnalyticalObj(
      int? inspectionId, int analyticalID) async {
    try {
      List<dynamic> args = [inspectionId.toString(), analyticalID.toString()];
      String query = "SELECT * FROM ${DBTables.SPECIFICATION_ATTRIBUTES} WHERE "
          "${SpecificationAttributesColumn.INSPECTION_ID}=? AND "
          "${SpecificationAttributesColumn.ANALYTICAL_ID}=?";
      final Database db = dbProvider.lazyDatabase;
      var cursor = await db.rawQuery(query, args);

      if (cursor.isNotEmpty) {
        SpecificationAnalyticalRequest? item =
            SpecificationAnalyticalRequest.fromJson(cursor.first);
        return item;
      }
      return null;
    } catch (e) {
      log("Error has occurred while finding spec analytical obj: $e");
      return null;
    }
  }

  Future<int> createOrUpdateResultReasonDetails(int inspectionID, String result,
      String resultReason, String comment) async {
    int? inspectionId;
    print('DBRequest createOrUpdateResultReasonDetails');
    final Database db = dbProvider.lazyDatabase;
    try {
      try {
        String query =
            "Select ${ResultRejectionDetailsColumn.INSPECTION_ID} from ${DBTables.RESULT_REJECTION_DETAILS} where ${ResultRejectionDetailsColumn.INSPECTION_ID} = $inspectionID";
        List<dynamic> cursor = await db.rawQuery(query);

        if (cursor.isNotEmpty) {
          inspectionId = cursor[0][ResultRejectionDetailsColumn.INSPECTION_ID];
        }
      } catch (e) {
        log("Error has occurred while finding a user id: $e");
        return -1;
      }

      if (inspectionId == null) {
        var values = <String, dynamic>{
          ResultRejectionDetailsColumn.INSPECTION_ID: inspectionID,
          ResultRejectionDetailsColumn.RESULT: result,
          ResultRejectionDetailsColumn.RESULT_REASON: resultReason,
          ResultRejectionDetailsColumn.DEFECT_COMMENTS: comment,
        };

        inspectionId =
            await db.insert(DBTables.RESULT_REJECTION_DETAILS, values);
      } else {
        var values = <String, dynamic>{
          ResultRejectionDetailsColumn.RESULT: result,
          ResultRejectionDetailsColumn.RESULT_REASON: resultReason,
          ResultRejectionDetailsColumn.DEFECT_COMMENTS: comment,
        };

        await db.update(DBTables.RESULT_REJECTION_DETAILS, values,
            where: '${ResultRejectionDetailsColumn.INSPECTION_ID} = ?',
            whereArgs: [inspectionID]);
      }
    } catch (e) {
      log("Error has occurred while creating an inspection: $e");
      return -1;
    }
    return inspectionId;
  }

  Future<ResultRejectionDetail?> getResultRejectionDetails(
    int inspectionId,
  ) async {
    ResultRejectionDetail? details;
    final Database db = dbProvider.lazyDatabase;

    try {
      String query =
          'SELECT ${ResultRejectionDetailsColumn.RESULT}, ${ResultRejectionDetailsColumn.RESULT_REASON}, ${ResultRejectionDetailsColumn.DEFECT_COMMENTS} '
          'FROM ${DBTables.RESULT_REJECTION_DETAILS} '
          'WHERE Inspection_ID = ?';

      List<Map<String, dynamic>> result =
          await db.rawQuery(query, [inspectionId]);
      if (result.isNotEmpty) {
        details = ResultRejectionDetail(
            result: result.first[ResultRejectionDetailsColumn.RESULT],
            resultReason:
                result.first[ResultRejectionDetailsColumn.RESULT_REASON],
            defectComments:
                result.first[ResultRejectionDetailsColumn.DEFECT_COMMENTS]);
      } else {
        debugPrint(" 🔴 getResultRejectionDetails is empty 🔴 ");
      }
    } catch (e) {
      print('getResultRejectionDetails ${e.toString()}');
      rethrow;
    }

    return details;
  }

  Future<int> createIsPictureReqSpecAttribute(
    int inspectionID,
    String result,
    String resultReason,
    bool isPictureRequired,
    // String comment,
  ) async {
    final Database db = dbProvider.lazyDatabase;
    int? inspectionId;
    try {
      try {
        String query =
            "Select ${ResultRejectionDetailsColumn.INSPECTION_ID} from ${DBTables.RESULT_REJECTION_DETAILS} where ${ResultRejectionDetailsColumn.INSPECTION_ID}=$inspectionID";
        var cursor = await db.rawQuery(query);

        if (cursor.isNotEmpty) {
          inspectionId =
              cursor.first[ResultRejectionDetailsColumn.INSPECTION_ID] as int?;
        }
      } catch (e) {
        log("Error has occurred while finding a user id. $e");
        return -1;
      }

      if (inspectionId == null) {
        await db.transaction((txn) async {
          var values = <String, dynamic>{
            ResultRejectionDetailsColumn.INSPECTION_ID: inspectionID,
            ResultRejectionDetailsColumn.RESULT: result,
            ResultRejectionDetailsColumn.RESULT_REASON: resultReason,
            // ResultRejectionDetailsColumn.DEFECT_COMMENTS: comment,
          };
          inspectionId =
              await txn.insert(DBTables.RESULT_REJECTION_DETAILS, values);
        });
      } else {
        await db.transaction((txn) async {
          var values = <String, dynamic>{
            ResultRejectionDetailsColumn.RESULT: result,
            ResultRejectionDetailsColumn.RESULT_REASON: resultReason,
            // ResultRejectionDetailsColumn.DEFECT_COMMENTS: comment,
          };
          await txn.update(DBTables.RESULT_REJECTION_DETAILS, values,
              where: "${ResultRejectionDetailsColumn.INSPECTION_ID} = ?",
              whereArgs: [inspectionID]);
        });
      }
    } catch (e) {
      log("Error has occurred while creating an inspection. $e");
      return -1;
    }
    return inspectionId ?? -1;
  }

  Future<bool> updateQuantityRejected(
      int inspectionID, int qtyRejected, int qtyReceived) async {
    try {
      print('DBRequest updateQuantityRejected');
      final Database db = dbProvider.lazyDatabase;
      await db.transaction((txn) async {
        var values = <String, dynamic>{
          QualityControlColumn.QTY_REJECTED: qtyRejected,
          QualityControlColumn.QTY_RECEIVED: qtyReceived,
        };

        await txn.update(
          DBTables.QUALITY_CONTROL,
          values,
          where: "${QualityControlColumn.INSPECTION_ID} = ?",
          whereArgs: [inspectionID],
        );

        return true;
      });
    } catch (e) {
      log("Error has occurred while updating an inspection. $e");
      return false;
    }
    return false;
  }

  Future<bool> updateItemSKUInspectionComplete(
    int inspectionID,
    bool? complete,
  ) async {
    print('DBRequest updateItemSKUInspectionComplete');
    try {
      final Database db = dbProvider.lazyDatabase;
      await db.transaction((txn) async {
        var values = <String, dynamic>{};
        if (complete != null) {
          values[PartnerItemSkuColumn.COMPLETE] = complete ? '1' : '0';
        }

        await txn.update(
          DBTables.PARTNER_ITEMSKU,
          values,
          where: "${PartnerItemSkuColumn.INSPECTION_ID} = ?",
          whereArgs: [inspectionID],
        );

        return true;
      });
    } catch (e) {
      log("Error has occurred while updating an inspection. $e");
      return false;
    }
    return false;
  }

  Future<List<SpecificationAnalytical>> getSpecificationAnalyticalFromTable(
    String number,
    String version,
  ) async {
    List<SpecificationAnalytical> list = [];
    print('DBRequest getSpecificationAnalyticalFromTable');
    try {
      final Database db = dbProvider.lazyDatabase;
      String query =
          "SELECT Number_Specification, Version_Specification, Analytical_ID, Analytical_name, Spec_Min, Spec_Max, "
          "Target_Num_Value, Target_Text_Value, UOM_Name, Type_Entry, Description, OrderNo, Picture_Required, "
          "Target_Text_Default, Inspection_Result FROM ${DBTables.SPECIFICATION_ANALYTICAL} "
          "WHERE Number_Specification=? AND Version_Specification=?";
      List<Map<String, dynamic>> cursor =
          await db.rawQuery(query, [number, version]);

      for (Map<String, dynamic> row in cursor.toList()) {
        SpecificationAnalytical item = SpecificationAnalytical.fromMap(row);
        list.add(item);
      }
    } catch (e) {
      log('Error has occurred while finding specification analytical: $e');
      return [];
    }

    return list;
  }

  Future<bool> isInspectionPartialComplete(
      int partnerId, String itemSKU, String lotNo) async {
    final Database db = dbProvider.lazyDatabase;
    print('DBRequest isInspectionPartialComplete');
    try {
      List<dynamic> args = ["0", partnerId.toString(), itemSKU, lotNo];

      String query = "SELECT * FROM ${DBTables.PARTNER_ITEMSKU} WHERE " +
          "${PartnerItemSkuColumn.COMPLETE}=? AND " +
          "${PartnerItemSkuColumn.PARTNER_ID}=? AND " +
          "${PartnerItemSkuColumn.ITEM_SKU}=? AND " +
          "${PartnerItemSkuColumn.UNIQUE_ID}=?";

      var cursor = await db.rawQuery(query, args);
      if (cursor.isNotEmpty) {
        return true;
      }
    } catch (e) {
      log("Error has occurred while finding pfg: $e");
      return false;
    }

    return false;
  }

  Future<List<SpecificationByItemSKU>?>
      getSpecificationByItemSKUFromTableForTransfer(
    int supplierId,
    String itemSkuName,
    String itemSkuCode,
  ) async {
    print('DBRequest getSpecificationByItemSKUFromTableForTransfer');
    List<SpecificationByItemSKU> specificationList = [];
    SpecificationByItemSKU? item;
    final Database db = dbProvider.lazyDatabase;

    try {
      String query3 = "Select Distinct(SP.Name), SP.Number, SP.Version, SpecType.Name," +
          " agency.ID, agency.Name, grade.ID, grade.Name," +
          " commodity.ID, commodity.Name, commodity.Sample_Size_By_Count," +
          " itemGroup1.Group1_ID, itemgroup1.Name" +
          " from Specification_Supplier SS" +
          " inner join Specification SP on SS.Number_Specification=SP.Number and SS.Version_Specification=SP.Version" +
          " inner join Material_Specification MS on SP.Number=MS.Number_Specification and SP.Version=MS.Version_Specification" +
          " inner join Specification_Type SpecType on SP.Specification_Type_Id=SpecType.Specification_Type_ID" +
          " left join ItemGroup1 itemGroup1 on SP.Item_Group1_ID=itemGroup1.Group1_ID" +
          " left join Commodity commodity on SP.Commodity_ID=commodity.ID" +
          " left join Grade grade ON MS.Grade_ID=grade.ID" +
          " left join Agency agency ON grade.Agency_ID=agency.ID" +
          " inner join Item_SKU itemSku on SS.Item_SKU_ID=itemSku.SKU_ID" +
          " where SS.status = 'A'" +
          " AND MS.Status = 'A'" +
          " AND (itemSku.Name = '$itemSkuName' or itemSku.Code='$itemSkuCode')" +
          " order by SP.Name";

      List<Map<dynamic, dynamic>> results = await db.rawQuery(query3);

      for (Map<dynamic, dynamic> row in results) {
        item = SpecificationByItemSKU(
          specificationName: row['Name'],
          specificationNumber: row['Number'],
          specificationVersion: row['Version'],
          specificationTypeName: row['Name'],
          agencyId: row['ID'],
          agencyName: row['Name'],
          gradeId: row['ID'],
          gradeName: row['Name'],
          commodityId: row['ID'],
          commodityName: row['Name'],
          sampleSizeByCount: row['Sample_Size_By_Count'],
          itemGroup1Id: row['Group1_ID'],
          itemGroup1Name: row['Name'],
        );
        specificationList.add(item);
      }
    } catch (e) {
      log('Error has occurred while finding specification by item SKU: $e');
      return null;
    }

    return specificationList;
  }

  Future<List<SpecificationByItemSKU>> getSpecificationByItemSKUFromTable(
      int supplierId, String itemSkuName, String itemSkuCode) async {
    List<SpecificationByItemSKU> specificationList = [];
    SpecificationByItemSKU? item;
    final Database db = dbProvider.lazyDatabase;
    print('DBRequest getSpecificationByItemSKUFromTable');
    try {
      String query3 = "SELECT Distinct(SP.Name) AS Name, SP.Number, SP.Version, SpecType.Name AS SpecTypeName," +
          " agency.ID AS AgencyID, agency.Name AS AgencyName, grade.ID AS GradeID, grade.Name AS GradeName," +
          " commodity.ID AS CommodityID, commodity.Name AS CommodityName, commodity.Sample_Size_By_Count AS SampleSizeByCount," +
          " itemGroup1.Group1_ID AS Group1ID, itemgroup1.Name AS Group1Name" +
          " FROM Specification_Supplier SS" +
          " INNER JOIN Specification SP ON SS.Number_Specification=SP.Number AND SS.Version_Specification=SP.Version" +
          " INNER JOIN Material_Specification MS ON SP.Number=MS.Number_Specification AND SP.Version=MS.Version_Specification" +
          " INNER JOIN Specification_Type SpecType ON SP.Specification_Type_Id=SpecType.Specification_Type_ID" +
          " LEFT JOIN ItemGroup1 itemGroup1 ON SP.Item_Group1_ID=itemGroup1.Group1_ID" +
          " LEFT JOIN Commodity commodity ON SP.Commodity_ID=commodity.ID" +
          " LEFT JOIN Grade grade ON MS.Grade_ID=grade.ID" +
          " LEFT JOIN Agency agency ON grade.Agency_ID=agency.ID" +
          " INNER JOIN Item_SKU itemSku ON SS.Item_SKU_ID=itemSku.SKU_ID" +
          " WHERE SS.Supplier_ID = $supplierId" +
          " AND SS.status = 'A'" +
          " AND MS.Status = 'A'" +
          " AND (itemSku.Name = '$itemSkuName' OR itemSku.Code='$itemSkuCode')" +
          " ORDER BY SP.Name";

      List<Map<dynamic, dynamic>> results = await db.rawQuery(query3);

      for (Map<dynamic, dynamic> row in results) {
        item = SpecificationByItemSKU(
          specificationName: row['Name'],
          specificationNumber: row['Number'],
          specificationVersion: row['Version'],
          specificationTypeName: row['SpecTypeName'],
          agencyId: row['AgencyID'],
          agencyName: row['AgencyName'],
          gradeId: row['GradeID'],
          gradeName: row['GradeName'],
          commodityId: row['CommodityID'],
          commodityName: row['CommodityName'],
          sampleSizeByCount: row['SampleSizeByCount'],
          itemGroup1Id: row['Group1ID'],
          itemGroup1Name: row['Group1Name'],
        );
        specificationList.add(item);
      }
    } catch (e) {
      log('Error specifying item SKU: $e');
    }

    return specificationList;
  }

  Future<String?> getLotNoFromQCDetails(int inspectionId) async {
    List<int> args = [inspectionId];
    String? lot_no;
    print('DBRequest getLotNoFromQCDetails');
    try {
      final Database db = dbProvider.lazyDatabase;
      String query = "Select * from " +
          DBTables.QUALITY_CONTROL +
          " where " +
          QualityControlColumn.INSPECTION_ID +
          "=?";

      List<Map<dynamic, dynamic>> cursor = await db.rawQuery(query, args);
      if (cursor.isNotEmpty) {
        lot_no = cursor.first[QualityControlColumn.LOT_NUMBER];
      }
    } catch (e) {
      log('Error lot number from quality control details: ${e.toString()}');
      return null;
    }
    return lot_no;
  }

  Future<void> updateLotNoPartnerItemSKU(int inspectionId, String lotNo) async {
    final Database db = dbProvider.lazyDatabase;
    print('DBRequest updateLotNoPartnerItemSKU');
    try {
      await db.transaction((txn) async {
        Map<String, dynamic> values = {
          PartnerItemSkuColumn.LOT_NO: lotNo,
        };

        await txn.update(
          DBTables.PARTNER_ITEMSKU,
          values,
          where: '${PartnerItemSkuColumn.INSPECTION_ID} = ?',
          whereArgs: [inspectionId],
        );
      });
    } catch (e) {
      log('Error occurred while updating an inspection: $e');
      return;
    }
  }

  Future<String?> getDateTypeFromQCDetails(int inspectionId) async {
    final Database db = dbProvider.lazyDatabase;
    String? dateType;
    print('DBRequest getDateTypeFromQCDetails');
    try {
      List<Map> result = await db.query(
        DBTables.QUALITY_CONTROL,
        where: '${QualityControlColumn.INSPECTION_ID} = ?',
        whereArgs: [inspectionId],
      );

      if (result.isNotEmpty) {
        dateType = result.first[QualityControlColumn.DATE_TYPE];
      }
    } catch (e) {
      log('Error occurred while finding quality control items: $e');
      return null;
    }

    return dateType;
  }

  Future<int> getPackDateFromQCDetails(int inspectionId) async {
    final Database db = dbProvider.lazyDatabase;
    int packDate = 0;
    print('DBRequest getPackDateFromQCDetails');
    try {
      List<Map> result = await db.query(
        DBTables.QUALITY_CONTROL,
        where: '${QualityControlColumn.INSPECTION_ID} = ?',
        whereArgs: [inspectionId],
      );

      if (result.isNotEmpty) {
        String packDateString = result.first[QualityControlColumn.PACK_DATE];
        packDate = int.tryParse(packDateString) ?? 0;
      }
    } catch (e) {
      log('Error occurred while finding quality control items: $e');
      return 0;
    }

    return packDate;
  }

  Future<void> updatePackdatePartnerItemSKU(
      int inspectionId, String packdate) async {
    final Database db = dbProvider.lazyDatabase;
    print('DBRequest updatePackdatePartnerItemSKU');
    try {
      await db.transaction((txn) async {
        Map<String, dynamic> values = {
          PartnerItemSkuColumn.PACK_DATE: packdate,
        };

        await txn.update(
          DBTables.PARTNER_ITEMSKU,
          values,
          where: '${PartnerItemSkuColumn.INSPECTION_ID} = ?',
          whereArgs: [inspectionId],
        );
      });
    } catch (e) {
      log('Error occurred while updating an inspection: $e');
      return;
    }
  }

  Future<bool> checkItemSKUAndLotNo(String itemSKU, String lotNo) async {
    final Database db = dbProvider.lazyDatabase;
    List<Map> result = await db.query(
      DBTables.PARTNER_ITEMSKU,
      where:
          '${PartnerItemSkuColumn.ITEM_SKU}= ? AND ${PartnerItemSkuColumn.UNIQUE_ID} = ?',
      whereArgs: [itemSKU, lotNo],
    );

    if (result.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<int?> createQualityControl({
    required int inspectionId,
    required int brandID,
    required int originID,
    required int qtyShipped,
    required int uomQtyShippedID,
    required String poNumber,
    required double pulpTempMin,
    required double pulpTempMax,
    required double recorderTempMin,
    required double recorderTempMax,
    required String rpc,
    required String claimFiledAgainst,
    required int qtyRejected,
    required int uomQtyRejectedID,
    required int reasonID,
    required String qcComments,
    required int qtyReceived,
    required int uomQtyReceivedID,
    required String specificationName,
    required int packDate,
    required String seal_no,
    required String lot_no,
    required String? qcdOpen1,
    required String qcdOpen2,
    required String qcdOpen3,
    required String qcdOpen4,
    required int workDate,
    required String? gtin,
    required int lot_size,
    required int shipDate,
    required String dateType,
    required String? gln,
    required String? glnType,
  }) async {
    int? qc_id;
    final Database db = dbProvider.lazyDatabase;
    print('DBRequest createQualityControl');
    try {
      await db.transaction((txn) async {
        Map<String, dynamic> values = {
          QualityControlColumn.INSPECTION_ID: inspectionId,
          QualityControlColumn.BRAND_ID: brandID,
          QualityControlColumn.ORIGIN_ID: originID,
          QualityControlColumn.QTY_SHIPPED: qtyShipped,
          QualityControlColumn.UOM_QTY_SHIPPED_ID: uomQtyShippedID,
          QualityControlColumn.PO_NO: poNumber,
          QualityControlColumn.PACK_DATE: packDate,
          QualityControlColumn.DATE_TYPE: dateType,
          QualityControlColumn.PULP_TEMP_MIN: pulpTempMin,
          QualityControlColumn.PULP_TEMP_MAX: pulpTempMax,
          QualityControlColumn.RECORDER_TEMP_MIN: recorderTempMin,
          QualityControlColumn.RECORDER_TEMP_MAX: recorderTempMax,
          QualityControlColumn.LOT_NUMBER: lot_no,
          QualityControlColumn.SEAL: seal_no,
          QualityControlColumn.RPC: rpc,
          QualityControlColumn.CLAIM_FILED_AGAINST: claimFiledAgainst,
          QualityControlColumn.QTY_REJECTED: qtyRejected,
          QualityControlColumn.UOM_QTY_REJECTED_ID: uomQtyRejectedID,
          QualityControlColumn.REASON_ID: reasonID,
          QualityControlColumn.QC_COMMENTS: qcComments,
          QualityControlColumn.QTY_RECEIVED: qtyReceived,
          QualityControlColumn.UOM_QTY_RECEIVED: uomQtyReceivedID,
          QualityControlColumn.IS_COMPLETE: 1,
          QualityControlColumn.SPECIFICATION_NAME: specificationName,
          QualityControlColumn.QCDOPEN1: qcdOpen1,
          QualityControlColumn.QCDOPEN2: qcdOpen2,
          QualityControlColumn.QCDOPEN3: qcdOpen3,
          QualityControlColumn.QCDOPEN4: qcdOpen4,
          QualityControlColumn.QCDOPEN5: workDate,
          QualityControlColumn.GTIN: gtin,
          QualityControlColumn.LOT_SIZE: lot_size,
          QualityControlColumn.SHIP_DATE: shipDate,
          QualityControlColumn.GLN: gln,
          QualityControlColumn.GLN_TYPE: glnType,
        };

        qc_id = await txn.insert(DBTables.QUALITY_CONTROL, values);
      });
    } catch (e) {
      log('Error has occurred while creating a quality control entry: $e');
      return null;
    }

    return qc_id;
  }

  Future<void> updateQualityControlShortForm({
    required int qcID,
    required int qtyShipped,
    required int uomQtyShippedID,
    required int qtyRejected,
    required int uomQtyRejectedID,
    required int qtyReceived,
    required int uomQtyReceivedID,
    required String selectedSpecification,
    required int packDate,
    required String lot_no,
    required String gtin,
    required int shipDate,
    required String dateType,
    required String gln,
    required String glnType,
  }) async {
    final Database db = dbProvider.lazyDatabase;
    print('DBRequest updateQualityControlShortForm');
    try {
      await db.transaction((txn) async {
        Map<String, dynamic> values = {
          QualityControlColumn.QTY_SHIPPED: qtyShipped,
          QualityControlColumn.UOM_QTY_SHIPPED_ID: uomQtyShippedID,
          QualityControlColumn.PACK_DATE: packDate,
          QualityControlColumn.LOT_NUMBER: lot_no,
          QualityControlColumn.QTY_REJECTED: qtyRejected,
          QualityControlColumn.UOM_QTY_REJECTED_ID: uomQtyRejectedID,
          QualityControlColumn.QTY_RECEIVED: qtyReceived,
          QualityControlColumn.UOM_QTY_RECEIVED: uomQtyReceivedID,
          QualityControlColumn.IS_COMPLETE: 1,
          QualityControlColumn.SPECIFICATION_NAME: selectedSpecification,
          QualityControlColumn.GTIN: gtin,
          QualityControlColumn.SHIP_DATE: shipDate,
          QualityControlColumn.DATE_TYPE: dateType,
          QualityControlColumn.GLN: gln,
          QualityControlColumn.GLN_TYPE: glnType,
        };

        await txn.update(
          DBTables.QUALITY_CONTROL,
          values,
          where: '${QualityControlColumn.ID} = ?',
          whereArgs: [qcID],
        );
      });
    } catch (e) {
      log('Error has occurred while updating a quality control item: $e');
      throw e;
    }
  }

  Future<int?> updateQualityControl({
    required int qcID,
    required int inspectionId,
    required int brandID,
    required int originID,
    required int qtyShipped,
    required int uomQtyShippedID,
    required String poNumber,
    required double pulpTempMin,
    required double pulpTempMax,
    required double recorderTempMin,
    required double recorderTempMax,
    required String rpc,
    required String claimFiledAgainst,
    required int qtyRejected,
    required int uomQtyRejectedID,
    required int reasonID,
    required String qcComments,
    required int qtyReceived,
    required int uomQtyReceivedID,
    required String specificationName,
    required int packDate,
    required String seal_no,
    required String lot_no,
    required String qcdOpen1,
    required String qcdOpen2,
    required String qcdOpen3,
    required String qcdOpen4,
    required int workDate,
    required String gtin,
    required int lot_size,
    required int shipDate,
    required String dateType,
  }) async {
    final Database db = dbProvider.lazyDatabase;
    int? rowsAffected;
    try {
      rowsAffected = await db.transaction((txn) async {
        Map<String, dynamic> values = {
          QualityControlColumn.INSPECTION_ID: inspectionId,
          QualityControlColumn.BRAND_ID: brandID,
          QualityControlColumn.ORIGIN_ID: originID,
          QualityControlColumn.QTY_SHIPPED: qtyShipped,
          QualityControlColumn.UOM_QTY_SHIPPED_ID: uomQtyShippedID,
          QualityControlColumn.PO_NO: poNumber,
          QualityControlColumn.PACK_DATE: packDate,
          QualityControlColumn.DATE_TYPE: dateType,
          QualityControlColumn.PULP_TEMP_MIN: pulpTempMin,
          QualityControlColumn.PULP_TEMP_MAX: pulpTempMax,
          QualityControlColumn.RECORDER_TEMP_MIN: recorderTempMin,
          QualityControlColumn.RECORDER_TEMP_MAX: recorderTempMax,
          QualityControlColumn.LOT_NUMBER: lot_no,
          QualityControlColumn.SEAL: seal_no,
          QualityControlColumn.RPC: rpc,
          QualityControlColumn.CLAIM_FILED_AGAINST: claimFiledAgainst,
          QualityControlColumn.QTY_REJECTED: qtyRejected,
          QualityControlColumn.UOM_QTY_REJECTED_ID: uomQtyRejectedID,
          QualityControlColumn.REASON_ID: reasonID,
          QualityControlColumn.QC_COMMENTS: qcComments,
          QualityControlColumn.QTY_RECEIVED: qtyReceived,
          QualityControlColumn.UOM_QTY_RECEIVED: uomQtyReceivedID,
          QualityControlColumn.IS_COMPLETE: 1,
          QualityControlColumn.SPECIFICATION_NAME: specificationName,
          QualityControlColumn.QCDOPEN1: qcdOpen1,
          QualityControlColumn.QCDOPEN2: qcdOpen2,
          QualityControlColumn.QCDOPEN3: qcdOpen3,
          QualityControlColumn.QCDOPEN4: qcdOpen4,
          QualityControlColumn.QCDOPEN5: workDate,
          QualityControlColumn.GTIN: gtin,
          QualityControlColumn.LOT_SIZE: lot_size,
          QualityControlColumn.SHIP_DATE: shipDate,
        };

        return await txn.update(
          DBTables.QUALITY_CONTROL,
          values,
          where: '${QualityControlColumn.ID} = ?',
          whereArgs: [qcID],
        );
      });
    } catch (e) {
      log('Error has occurred while updating a quality control entry: $e');
      return null;
    }

    return rowsAffected;
  }

  Future<void> deleteSpecAttributesByInspectionId(int inspectionId) async {
    final Database db = dbProvider.lazyDatabase;

    try {
      print('DBRequest deleteSpecAttributesByInspectionId');
      await db.transaction((txn) async {
        String query =
            'DELETE FROM ${DBTables.SPECIFICATION_ATTRIBUTES} WHERE ${SpecificationAttributesColumn.INSPECTION_ID} = ?';
        List<dynamic> args = [inspectionId];

        await txn.rawDelete(query, args);
      });
    } catch (e) {
      log('Error has occurred while deleting a attachment: $e');
      throw e;
    }
  }

  Future<int?> createSpecificationAttributes(
    int inspectionId,
    int analyticalId,
    String sampleTextValue,
    int sampleValue,
    String comply,
    String comment,
    String analyticalName,
    bool isPictureRequired,
    String inspectionResult,
  ) async {
    final Database db = dbProvider.lazyDatabase;
    int? ttId;
    print('DBRequest createSpecificationAttributes');
    try {
      await db.transaction((txn) async {
        Map<String, dynamic> values = {
          SpecificationAttributesColumn.INSPECTION_ID: inspectionId,
          SpecificationAttributesColumn.ANALYTICAL_ID: analyticalId,
          SpecificationAttributesColumn.COMPLY: comply,
          SpecificationAttributesColumn.SAMPLE_TEXT_VALUE: sampleTextValue,
          SpecificationAttributesColumn.SAMPLE_VALUE: sampleValue,
          SpecificationAttributesColumn.COMMENT: comment,
          SpecificationAttributesColumn.ANALYTICAL_NAME: analyticalName,
          SpecificationAttributesColumn.PICTURE_REQUIRED:
              isPictureRequired ? 1 : 0,
          SpecificationAttributesColumn.INSPECTION_RESULT: inspectionResult,
        };

        ttId = await txn.insert(DBTables.SPECIFICATION_ATTRIBUTES, values);
        log('insert into ${DBTables.SPECIFICATION_ATTRIBUTES} - withValueOf ${json.encode(values)}');
      });
    } catch (e) {
      log('Error has occurred while creating a specification attributes: $e');
      return null;
    }

    return ttId;
  }

  Future<int?> createPartnerItemSKU(
    int partnerID,
    String itemSKU,
    String lotNo,
    String packDate,
    int inspectionId,
    String lotSize,
    String uniqueId,
    int poLineNo,
    String poNo,
  ) async {
    final Database db = dbProvider.lazyDatabase;
    int? ttId;
    print('DBRequest createPartnerItemSKU');
    try {
      await db.transaction((txn) async {
        Map<String, dynamic> values = {
          PartnerItemSkuColumn.PARTNER_ID: partnerID,
          PartnerItemSkuColumn.ITEM_SKU: itemSKU,
          PartnerItemSkuColumn.LOT_NO: lotNo,
          PartnerItemSkuColumn.PACK_DATE: packDate,
          PartnerItemSkuColumn.INSPECTION_ID: inspectionId,
          PartnerItemSkuColumn.LOT_SIZE: lotSize,
          PartnerItemSkuColumn.UNIQUE_ID: uniqueId,
          PartnerItemSkuColumn.PO_LINE_NO: poLineNo,
          PartnerItemSkuColumn.PO_NO: poNo,
        };

        ttId = await txn.insert(DBTables.PARTNER_ITEMSKU, values);
      });
    } catch (e) {
      log('Error has occurred while creating a trailer temperature: $e');
      return null;
    }

    return ttId;
  }

  Future<void>
      copyTempTrailerTemperaturesToInspectionTrailerTemperatureTableByPartnerID(
    int inspectionID,
    int partnerID,
    String poNumber,
  ) async {
    final Database db = dbProvider.lazyDatabase;
    print(
        'DBRequest copyTempTrailerTemperaturesToInspectionTrailerTemperatureTableByPartnerID');
    try {
      await db.transaction((txn) async {
        List<Map> result = await txn.rawQuery(
          'SELECT * FROM ${DBTables.TEMP_TRAILER_TEMPERATURE} WHERE ${TempTrailerTemperatureColumn.PO_NUMBER} = ?',
          [poNumber],
        );

        if (result.isNotEmpty) {
          for (var row in result) {
            String location = row[TempTrailerTemperatureColumn.LOCATION];
            String level = row[TempTrailerTemperatureColumn.LEVEL];
            int value = row[TempTrailerTemperatureColumn.VALUE];
            int complete = row[TempTrailerTemperatureColumn.COMPLETE];
            String ponumber = row[TempTrailerTemperatureColumn.PO_NUMBER];

            Map<String, dynamic> values = {
              TrailerTemperatureColumn.INSPECTION_ID: inspectionID,
              TrailerTemperatureColumn.LOCATION: location,
              TrailerTemperatureColumn.LEVEL: level,
              TrailerTemperatureColumn.VALUE: value,
              TrailerTemperatureColumn.COMPLETE: 1,
              TrailerTemperatureColumn.PO_NUMBER: ponumber,
            };

            await txn.insert(DBTables.TRAILER_TEMPERATURE, values);
          }
        }
      });
    } catch (e) {
      log('Error has occurred while copying trailer temp: $e');
      rethrow;
    }
  }

  Future<void>
      copyTempTrailerTemperaturesDetailsToInspectionTrailerTemperatureDetailsTableByPartnerID(
    int inspectionID,
    int partnerID,
    String poNumber,
  ) async {
    final Database db = dbProvider.lazyDatabase;
    print(
        'DBRequest copyTempTrailerTemperaturesDetailsToInspectionTrailerTemperatureDetailsTableByPartnerID');
    try {
      await db.transaction((txn) async {
        List<Map> result = await txn.rawQuery(
          'SELECT * FROM ${DBTables.TEMP_TRAILER_TEMPERATURE_DETAILS} WHERE ${TempTrailerTemperatureDetailsColumn.PO_NUMBER} = ?',
          [poNumber],
        );

        if (result.isNotEmpty) {
          for (var row in result) {
            Map<String, dynamic> values = {
              TempTrailerTemperatureDetailsColumn.ID: inspectionID,
              TempTrailerTemperatureDetailsColumn.TEMP_OPEN1:
                  row[TempTrailerTemperatureDetailsColumn.TEMP_OPEN1],
              TempTrailerTemperatureDetailsColumn.TEMP_OPEN2:
                  row[TempTrailerTemperatureDetailsColumn.TEMP_OPEN2],
              TempTrailerTemperatureDetailsColumn.TEMP_OPEN3:
                  row[TempTrailerTemperatureDetailsColumn.TEMP_OPEN3],
              TempTrailerTemperatureDetailsColumn.COMMENTS:
                  row[TempTrailerTemperatureDetailsColumn.COMMENTS],
              TempTrailerTemperatureDetailsColumn.PO_NUMBER:
                  row[TempTrailerTemperatureDetailsColumn.PO_NUMBER],
              TempTrailerTemperatureDetailsColumn.PARTNER_ID:
                  row[TempTrailerTemperatureDetailsColumn.PARTNER_ID],
            };

            await txn.insert(DBTables.TRAILER_TEMPERATURE_DETAILS, values);
          }
        }
      });
    } catch (e) {
      log('Error has occurred while copying trailer temp: $e');
      throw e;
    }
  }

  Future<void> updateSelectedItemSKU(
    int inspectionId,
    int partnerID,
    int itemSkuId,
    String itemSku,
    String itemUniqueId,
    bool isComplete,
    bool partialComplete,
  ) async {
    print('DBRequest updateSelectedItemSKU');
    final Database db = dbProvider.lazyDatabase;

    try {
      await db.transaction((txn) async {
        Map<String, dynamic> values = {
          SelectedItemSkuListColumn.COMPLETE: isComplete ? '1' : '0',
          SelectedItemSkuListColumn.PARTIAL_COMPLETE:
              partialComplete ? '1' : '0',
          SelectedItemSkuListColumn.INSPECTION_ID: inspectionId,
          SelectedItemSkuListColumn.PARTNER_ID: partnerID,
        };

        int count = await txn.update(
          DBTables.SELECTED_ITEM_SKU_LIST,
          values,
          where:
              '${SelectedItemSkuListColumn.SKU_ID} = ? AND ${SelectedItemSkuListColumn.UNIQUE_ITEM_ID} = ?',
          whereArgs: [itemSkuId, itemUniqueId],
        );
      });
    } catch (e) {
      log('Error has occurred while updating an inspection: $e');
      throw e;
    }
  }

  Future<List<SpecificationGradeTolerance>> getSpecificationGradeTolerance(
      String number, String version) async {
    List<SpecificationGradeTolerance> list = [];
    print('DBRequest getSpecificationGradeTolerance');
    try {
      final Database db = dbProvider.lazyDatabase;
      String query =
          "SELECT Number_Specification, Version_Specification, Severity_Defect_ID, Defect_ID, "
          "Grade_Tolerance_Percentage, Overridden, Defect_Name, Defect_Category_Name, Severity_Defect_Name "
          "FROM ${DBTables.SPECIFICATION_GRADE_TOLERANCE} "
          "WHERE Number_Specification=? AND Version_Specification=?";

      List<Map> result = await db.rawQuery(query, [number, version]);

      for (Map<dynamic, dynamic> map in result) {
        list.add(
            SpecificationGradeTolerance.fromJson(map as Map<String, dynamic>));
      }
    } catch (e) {
      log('Error has occurred while finding specification grade tolerance: $e');
      return [];
    }

    return list;
  }

  Future<List<SpecificationGradeTolerance>> getSpecificationGradeToleranceTable(
      String number, String version) async {
    List<SpecificationGradeTolerance> list = [];
    SpecificationGradeTolerance item;

    try {
      String query = '''
      SELECT Number_Specification, Version_Specification, Severity_Defect_ID, Defect_ID,
      Grade_Tolerance_Percentage, Overridden, Defect_Name, Defect_Category_Name, Severity_Defect_Name
      FROM ${DBTables.SPECIFICATION_GRADE_TOLERANCE}
      WHERE Number_Specification=? AND Version_Specification=?
    ''';
      final Database db = dbProvider.lazyDatabase;
      List<Map<String, dynamic>> result =
          await db.rawQuery(query, [number, version]);

      for (Map<String, dynamic> map in result) {
        item = SpecificationGradeTolerance(
          specificationNumber:
              map[SpecificationGradeToleranceColumn.NUMBER_SPECIFICATION],
          specificationVersion:
              map[SpecificationGradeToleranceColumn.VERSION_SPECIFICATION],
          severityDefectID: int.tryParse(
              map[SpecificationGradeToleranceColumn.SEVERITY_DEFECT_ID]),
          defectID: map[SpecificationGradeToleranceColumn.DEFECT_ID],
          specTolerancePercentage:
              map[SpecificationGradeToleranceColumn.GRADE_TOLERANCE_PERCENTAGE],
          overridden: map[SpecificationGradeToleranceColumn.OVERRIDDEN],
          defectName: map[SpecificationGradeToleranceColumn.DEFECT_NAME],
          defectCategoryName:
              map[SpecificationGradeToleranceColumn.DEFECT_CATEGORY_NAME],
          severityDefectName:
              map[SpecificationGradeToleranceColumn.SEVERITY_DEFECT_NAME],
        );

        print(
            'spec tolerance - ${item.defectName}--${item.severityDefectName}');
        list.add(item);
      }
    } catch (e) {
      print('Error has occurred while finding quality control items. $e');
    }

    return list;
  }

  Future<List<FinishedGoodsItemSKU>> getSelectedItemSKUList() async {
    List<FinishedGoodsItemSKU> list = [];
    try {
      final Database db = dbProvider.lazyDatabase;
      String query = "SELECT * FROM ${DBTables.SELECTED_ITEM_SKU_LIST}";
      List<Map> result = await db.rawQuery(query);
      for (Map<dynamic, dynamic> item in result) {
        bool isComplete = item[SelectedItemSkuListColumn.COMPLETE] == '1';
        bool isPartialComplete =
            item[SelectedItemSkuListColumn.PARTIAL_COMPLETE] == '1';
        list.add(FinishedGoodsItemSKU(
          id: item[SelectedItemSkuListColumn.SKU_ID],
          sku: item[SelectedItemSkuListColumn.SKU_CODE],
          name: item[SelectedItemSkuListColumn.SKU_NAME],
          uniqueItemId: item[SelectedItemSkuListColumn.UNIQUE_ITEM_ID],
          commodityName: item[SelectedItemSkuListColumn.COMMODITY_NAME],
          commodityID: item[SelectedItemSkuListColumn.COMMODITY_ID],
          lotNo: item[SelectedItemSkuListColumn.LOT_NUMBER],
          inspectionId: item[SelectedItemSkuListColumn.INSPECTION_ID],
          partnerId: item[SelectedItemSkuListColumn.PARTNER_ID],
          packDate: item[SelectedItemSkuListColumn.PACK_DATE],
          gtin: item[SelectedItemSkuListColumn.GTIN],
          partnerName: item[SelectedItemSkuListColumn.PARTNER_NAME],
          FTLflag: item[SelectedItemSkuListColumn.FTL],
          Branded: item[SelectedItemSkuListColumn.BRANDED],
          dateType: item[SelectedItemSkuListColumn.DATE_TYPE],
          is_Complete: isComplete,
          isPartialComplete: isPartialComplete,
        ));
      }
    } catch (e) {
      log('Error selected item sku list: $e');
      return [];
    }
    return list;
  }

  Future<int> createSelectedItemSKU({
    required int? skuId,
    required String? itemSKUCode,
    required String? poNo,
    required String? lotNo,
    required String? itemSKUName,
    required String? commodityName,
    required String? uniqueId,
    required int? commodityId,
    required String? description,
    required int? partnerID,
    required String? packDate,
    required String? GTIN,
    required String? partnerName,
    required String? ftl,
    required String? branded,
    required String? dateType,
  }) async {
    int ttId = 0;
    try {
      final Database db = dbProvider.lazyDatabase;
      Map<String, dynamic> values = {
        SelectedItemSkuListColumn.SKU_ID: skuId,
        SelectedItemSkuListColumn.UNIQUE_ITEM_ID: uniqueId,
        SelectedItemSkuListColumn.PO_NUMBER: poNo,
        SelectedItemSkuListColumn.LOT_NUMBER: lotNo,
        SelectedItemSkuListColumn.SKU_CODE: itemSKUCode,
        SelectedItemSkuListColumn.SKU_NAME: itemSKUName,
        SelectedItemSkuListColumn.COMMODITY_NAME: commodityName,
        SelectedItemSkuListColumn.COMMODITY_ID: commodityId,
        SelectedItemSkuListColumn.DESCRIPTION: description,
        SelectedItemSkuListColumn.COMPLETE: '0',
        SelectedItemSkuListColumn.PARTIAL_COMPLETE: '0',
        SelectedItemSkuListColumn.PARTNER_ID: partnerID,
        SelectedItemSkuListColumn.PACK_DATE: packDate,
        SelectedItemSkuListColumn.GTIN: GTIN,
        SelectedItemSkuListColumn.PARTNER_NAME: partnerName,
        SelectedItemSkuListColumn.FTL: ftl,
        SelectedItemSkuListColumn.BRANDED: branded,
        SelectedItemSkuListColumn.DATE_TYPE: dateType,
      };
      ttId = await db.insert(DBTables.SELECTED_ITEM_SKU_LIST, values);
    } catch (e) {
      log('Error has occurred while creating a trailer temperature: $e');
      rethrow;
    }
    return ttId;
  }

  Future<void> deleteSelectedItemSKUByUniqueId({
    required String? uniqueId,
    required int? itemId,
    required String? itemCode,
  }) async {
    final Database db = dbProvider.lazyDatabase;
    try {
      await db.transaction((txn) async {
        String query = '''
        DELETE FROM ${DBTables.SELECTED_ITEM_SKU_LIST}
        WHERE ${SelectedItemSkuListColumn.UNIQUE_ITEM_ID} = ? AND
              ${SelectedItemSkuListColumn.SKU_ID} = ? AND
              ${SelectedItemSkuListColumn.SKU_CODE} = ?
      ''';
        List<dynamic> arguments = [uniqueId, itemId.toString(), itemCode];
        await txn.rawDelete(query, arguments);
      });
    } catch (e) {
      log('Error has occurred while deleting a quality control entries: $e');
      rethrow;
    }
  }

  Future<void> updateOverriddenResult(int inspectionID, String result) async {
    try {
      final Database db = dbProvider.lazyDatabase;
      await db.transaction((txn) async {
        Map<String, dynamic> values = {};
        if (result.isNotEmpty) {
          values[OverriddenResultColumn.OVERRIDDEN_RESULT] = result;
        }
        await txn.update(
          DBTables.OVERRIDDEN_RESULT,
          values,
          where: '${OverriddenResultColumn.INSPECTION_ID} = ?',
          whereArgs: [inspectionID],
        );
      });
    } catch (e) {
      log('Error has occurred while updating an inspection: $e');
      throw e;
    }
  }

  Future<void> deleteRejectionDetailByInspectionId(int inspectionId) async {
    try {
      final Database db = dbProvider.lazyDatabase;
      await db.transaction((txn) async {
        String query =
            'DELETE FROM ${DBTables.RESULT_REJECTION_DETAILS} WHERE Inspection_ID = $inspectionId';
        await txn.rawDelete(query);
      });
    } catch (e) {
      log('Error has occurred while deleting a trailer temperature entries: $e');

      rethrow;
    }
  }

  Future<List<CommodityKeywords>> getCommodityKeywordsFromTable(
      int commodityId) async {
    List<CommodityKeywords> itemSKUList = [];
    CommodityKeywords? item;
    final Database db = dbProvider.lazyDatabase;

    try {
      String query1 = "Select * from commodity_keywords where ID=$commodityId";
      List<Map> result = await db.rawQuery(query1);

      if (result.isNotEmpty) {
        for (Map map in result) {
          item = CommodityKeywords(
              id: map[CommodityKeywordsColumn.ID],
              keywords: map[CommodityKeywordsColumn.KEYWORDS]);
          itemSKUList.add(item);
        }
      }
    } catch (e) {
      print('Error has occurred while finding quality control items: $e');
      return [];
    }

    return itemSKUList;
  }

  Future<String> getBrandedFlagFromItemSku(int itemSkuId) async {
    String branded = "";
    Database db = dbProvider.lazyDatabase;
    print('DBRequest getBrandedFlagFromItemSku');
    try {
      String query =
          "SELECT Branded FROM ${DBTables.ITEM_SKU} WHERE Item_SKU.SKU_ID=$itemSkuId";
      List<Map> result = await db.rawQuery(query);

      if (result.isNotEmpty) {
        branded = result.first[ItemSkuColumn.BRANDED];
      }
    } catch (e) {
      print('Error has occurred while finding quality control items: $e');
    }

    return branded;
  }

  Future<int?> createOrUpdateOverriddenResult(
    int inspectionID,
    int overriddenBy,
    String overriddenResult,
    String overriddenComments,
    int overriddenTimestamp,
    String inspectionOldResult,
    int originalQtyShipped,
    int originalQtyRejected,
    int qtyShipped,
    int qtyRejected,
  ) async {
    int? inspectionId;
    Database database = dbProvider.lazyDatabase;

    try {
      String query =
          'SELECT ${OverriddenResultColumn.INSPECTION_ID} FROM ${DBTables.OVERRIDDEN_RESULT} WHERE ${OverriddenResultColumn.INSPECTION_ID} = ?';
      List<Map<String, dynamic>> result =
          await database.rawQuery(query, [inspectionID]);

      if (result.isNotEmpty) {
        inspectionId = result.first[OverriddenResultColumn.INSPECTION_ID];
      }

      if (inspectionId == null) {
        await database.transaction((txn) async {
          var values = {
            OverriddenResultColumn.INSPECTION_ID: inspectionID,
            OverriddenResultColumn.OVERRIDDEN_BY: overriddenBy,
            OverriddenResultColumn.OVERRIDDEN_RESULT: overriddenResult,
            OverriddenResultColumn.OVERRIDDEN_TIMESTAMP: overriddenTimestamp,
            OverriddenResultColumn.OVERRIDDEN_COMMENTS: overriddenComments,
            OverriddenResultColumn.OLD_RESULT: inspectionOldResult,
            OverriddenResultColumn.ORIGINAL_QTY_SHIPPED: originalQtyShipped,
            OverriddenResultColumn.ORIGINAL_QTY_REJECTED: originalQtyRejected,
            OverriddenResultColumn.NEW_QTY_SHIPPED: qtyShipped,
            OverriddenResultColumn.NEW_QTY_REJECTED: qtyRejected,
          };
          inspectionId = await txn.insert(DBTables.OVERRIDDEN_RESULT, values);
        });
      } else {
        await database.transaction((txn) async {
          var values = {
            OverriddenResultColumn.OVERRIDDEN_BY: overriddenBy,
            OverriddenResultColumn.OVERRIDDEN_RESULT: overriddenResult,
            OverriddenResultColumn.OVERRIDDEN_TIMESTAMP: overriddenTimestamp,
            OverriddenResultColumn.OVERRIDDEN_COMMENTS: overriddenComments,
            OverriddenResultColumn.OLD_RESULT: inspectionOldResult,
            OverriddenResultColumn.ORIGINAL_QTY_SHIPPED: originalQtyShipped,
            OverriddenResultColumn.ORIGINAL_QTY_REJECTED: originalQtyRejected,
            OverriddenResultColumn.NEW_QTY_SHIPPED: qtyShipped,
            OverriddenResultColumn.NEW_QTY_REJECTED: qtyRejected,
          };
          await txn.update(DBTables.OVERRIDDEN_RESULT, values,
              where: '${OverriddenResultColumn.INSPECTION_ID} = ?',
              whereArgs: [inspectionID]);
        });
      }
    } catch (e) {
      throw Exception(
          'Error occurred while creating or updating inspection: $e');
    }
    return inspectionId;
  }

  Future<void> updateInspectionResultReason(
      int inspectionId, String result) async {
    final Database db = dbProvider.lazyDatabase;

    try {
      await db.transaction((txn) async {
        var values = {
          ResultRejectionDetailsColumn.RESULT_REASON: result,
        };
        await txn.update(DBTables.RESULT_REJECTION_DETAILS, values,
            where: '${ResultRejectionDetailsColumn.INSPECTION_ID} = ?',
            whereArgs: [inspectionId]);
      });
    } catch (e) {
      print('Error has occurred while updating an inspection: $e');
      rethrow;
    }
  }

  Future<void> deleteInspectionDefectByDefectId(int defectId) async {
    final Database db = dbProvider.lazyDatabase;
    try {
      await db.transaction((txn) async {
        String query =
            'DELETE FROM ${DBTables.INSPECTION_DEFECT} WHERE ${InspectionDefectColumn.ID} = ?';
        List<dynamic> arguments = [defectId];
        await txn.rawDelete(query, arguments);
      });
    } catch (e) {
      log('Error has occurred while deleting an inspection defect: $e');
    }
  }

  Future<void> deleteDefectAttachmentsByDefectId(int defectId) async {
    // delete the actual pictures from the phones memory
    List<InspectionDefectAttachment>? attachments =
        await findDefectAttachmentsByDefectId(defectId);

    if (attachments != null && attachments.isNotEmpty) {
      for (var attachment in attachments) {
        if (attachment.fileLocation == null) {
          continue;
        }
        File file = File(attachment.fileLocation!);
        if (file.existsSync()) {
          file.deleteSync();
        }
      }
    }

    final Database db = dbProvider.lazyDatabase;
    try {
      await db.transaction((txn) async {
        String query =
            'DELETE FROM ${DBTables.INSPECTION_DEFECT_ATTACHMENT} WHERE ${InspectionDefectAttachmentColumn.INSPECTION_DEFECT_ID} = ?';
        List<dynamic> arguments = [defectId];
        await txn.rawDelete(query, arguments);
      });
    } catch (e) {
      print('Error has occurred while deleting a defect attachment: $e');
    }
  }

  Future<List<InspectionDefectAttachment>?> findDefectAttachmentsByDefectId(
      int defectId) async {
    List<InspectionDefectAttachment> attachments = [];
    final Database db = dbProvider.lazyDatabase;

    try {
      String query =
          'SELECT * FROM ${DBTables.INSPECTION_DEFECT_ATTACHMENT} WHERE ${InspectionDefectAttachmentColumn.INSPECTION_DEFECT_ID} = ?';
      List<Map> result = await db.rawQuery(query, [defectId]);

      if (result.isNotEmpty) {
        for (Map map in result) {
          InspectionDefectAttachment temp = InspectionDefectAttachment(
            attachmentId: map[InspectionDefectAttachmentColumn.ID],
            inspectionId: map[InspectionDefectAttachmentColumn.INSPECTION_ID],
            sampleId:
                map[InspectionDefectAttachmentColumn.INSPECTION_SAMPLE_ID],
            defectId:
                map[InspectionDefectAttachmentColumn.INSPECTION_DEFECT_ID],
            createdTime: map[InspectionDefectAttachmentColumn.CREATED_TIME],
            fileLocation: map[InspectionDefectAttachmentColumn.FILE_LOCATION],
          );

          attachments.add(temp);
        }
      }
    } catch (e) {
      print(
          'Error has occurred while finding an inspection defect attachment: $e');
    }

    return attachments;
  }

  Future<void> deleteDefectAttachmentByAttachmentId(int attachmentId) async {
    // delete the actual picture from the phones memory
    InspectionDefectAttachment? attachment =
        await findDefectAttachmentByAttachmentId(attachmentId);

    if (attachment != null) {
      if (attachment.fileLocation != null) {
        File file = File(attachment.fileLocation!);
        if (file.existsSync()) {
          file.deleteSync();
        }
      }
    }

    // delete the attachment from the database
    final Database db = dbProvider.lazyDatabase;
    try {
      await db.transaction((txn) async {
        String query =
            'DELETE FROM ${DBTables.INSPECTION_DEFECT_ATTACHMENT} WHERE ${InspectionDefectAttachmentColumn.ID} = ?';
        List<dynamic> arguments = [attachmentId];
        await txn.rawDelete(query, arguments);
      });
    } catch (e) {
      print('Error has occurred while deleting a defect attachment: $e');
    }
  }

  Future<InspectionDefectAttachment?> findDefectAttachmentByAttachmentId(
      int attachmentId) async {
    InspectionDefectAttachment? attachment;
    final Database db = dbProvider.lazyDatabase;

    try {
      String query =
          'SELECT * FROM ${DBTables.INSPECTION_DEFECT_ATTACHMENT} WHERE ${InspectionDefectAttachmentColumn.ID} = ?';
      List<Map> result = await db.rawQuery(query, [attachmentId]);

      if (result.isNotEmpty) {
        attachment = InspectionDefectAttachment(
          attachmentId: result.first[InspectionDefectAttachmentColumn.ID],
          inspectionId:
              result.first[InspectionDefectAttachmentColumn.INSPECTION_ID],
          sampleId: result
              .first[InspectionDefectAttachmentColumn.INSPECTION_SAMPLE_ID],
          defectId: result
              .first[InspectionDefectAttachmentColumn.INSPECTION_DEFECT_ID],
          createdTime:
              result.first[InspectionDefectAttachmentColumn.CREATED_TIME],
          fileLocation:
              result.first[InspectionDefectAttachmentColumn.FILE_LOCATION],
        );
      }
    } catch (e) {
      print(
          'Error has occurred while finding an inspection defect attachment: $e');
    }

    return attachment;
  }

  Future<void> deleteInspectionSamplesBySampleId(int sampleId) async {
    final Database db = dbProvider.lazyDatabase;
    try {
      await db.transaction((txn) async {
        String query =
            'DELETE FROM ${DBTables.INSPECTION_SAMPLE} WHERE ${InspectionSampleColumn.ID} = ?';
        List<dynamic> arguments = [sampleId];
        await txn.rawDelete(query, arguments);
      });
    } catch (e) {
      print('Error has occurred while deleting inspection sample entries: $e');
    }
  }

  Future<void> deleteDefectAttachmentsBySampleId(int sampleId) async {
    final Database db = dbProvider.lazyDatabase;
    try {
      await db.transaction((txn) async {
        // delete the actual pictures from the phones memory
        List<InspectionDefectAttachment>? attachments =
            await findDefectAttachmentsBySampleId(sampleId);

        if (attachments != null && attachments.isNotEmpty) {
          for (var attachment in attachments) {
            if (attachment.fileLocation != null) {
              File file = File(attachment.fileLocation!);
              if (file.existsSync()) {
                file.deleteSync();
              }
            }
          }
        }

        // delete the attachments from the database
        String query =
            'DELETE FROM ${DBTables.INSPECTION_DEFECT_ATTACHMENT} WHERE ${InspectionDefectAttachmentColumn.INSPECTION_SAMPLE_ID} = ?';
        List<dynamic> arguments = [sampleId];
        await txn.rawDelete(query, arguments);
      });
    } catch (e) {
      print('Error has occurred while deleting a defect attachment: $e');
    }
  }

  Future<List<InspectionDefectAttachment>?> findDefectAttachmentsBySampleId(
      int sampleId) async {
    final Database db = dbProvider.lazyDatabase;
    List<InspectionDefectAttachment> attachments = [];

    try {
      String query =
          'SELECT * FROM ${DBTables.INSPECTION_DEFECT_ATTACHMENT} WHERE ${InspectionDefectAttachmentColumn.INSPECTION_SAMPLE_ID} = ?';
      List<Map> result = await db.rawQuery(query, [sampleId]);

      if (result.isNotEmpty) {
        for (var item in result) {
          InspectionDefectAttachment temp = InspectionDefectAttachment(
            attachmentId: item[InspectionDefectAttachmentColumn.ID],
            inspectionId: item[InspectionDefectAttachmentColumn.INSPECTION_ID],
            sampleId:
                item[InspectionDefectAttachmentColumn.INSPECTION_SAMPLE_ID],
            defectId:
                item[InspectionDefectAttachmentColumn.INSPECTION_DEFECT_ID],
            createdTime: item[InspectionDefectAttachmentColumn.CREATED_TIME],
            fileLocation: item[InspectionDefectAttachmentColumn.FILE_LOCATION],
          );
          attachments.add(temp);
        }
      }
    } catch (e) {
      print(
          'Error has occurred while finding an inspection defect attachment: $e');
      return null;
    }

    return attachments;
  }

  Future<List<int>> findInspectionsByPartner(
      int partnerID, String poNumber) async {
    List<int> inspectionIds = [];
    final Database db = dbProvider.lazyDatabase;

    try {
      List<Map> result = await db.rawQuery(
        'SELECT * FROM ${DBTables.INSPECTION} WHERE ${InspectionColumn.CARRIER_ID} = ? AND ${InspectionColumn.PO_NUMBER} = ?',
        [partnerID, poNumber],
      );

      for (Map map in result) {
        int inspectionId = map[InspectionColumn.ID];
        inspectionIds.add(inspectionId);
      }
    } catch (e) {
      print('Error has occurred while finding trailer temperature items: $e');
    }

    return inspectionIds;
  }

  Future<void> deleteTrailerTemperatureDetailsByInspectionId(
      int inspectionId) async {
    final Database db = dbProvider.lazyDatabase;

    try {
      await db.transaction((txn) async {
        String query =
            'DELETE FROM ${DBTables.TRAILER_TEMPERATURE_DETAILS} WHERE ${TrailerTemperatureDetailsColumn.ID} = ?';
        List<dynamic> arguments = [inspectionId];

        await txn.rawDelete(query, arguments);
      });
    } catch (e) {
      print(
          'Error has occurred while deleting a trailer temperature entries: $e');
    }
  }

  Future<int?> createDefectAttachment({
    int? inspectionId,
    int? sampleId,
    int? defectId,
    int? createdTime,
    String? fileLocation,
  }) async {
    int attachmentId;
    try {
      final Database db = dbProvider.lazyDatabase;

      Map<String, dynamic> values = {
        InspectionDefectAttachmentColumn.INSPECTION_ID: inspectionId,
        InspectionDefectAttachmentColumn.INSPECTION_SAMPLE_ID: sampleId,
        InspectionDefectAttachmentColumn.INSPECTION_DEFECT_ID: defectId,
        InspectionDefectAttachmentColumn.CREATED_TIME: createdTime,
        InspectionDefectAttachmentColumn.FILE_LOCATION: fileLocation,
        InspectionDefectAttachmentColumn.DEFECT_SAVED:
            (sampleId != null && defectId != null) ? 'Y' : 'N'
      };

      attachmentId =
          await db.insert(DBTables.INSPECTION_DEFECT_ATTACHMENT, values);
    } catch (e) {
      print('Error has occurred while creating a defect attachment: $e');
      return null;
    }

    return attachmentId;
  }

  Future<bool> isQCTIsComplete(int inspectionId) async {
    final Database db = await dbProvider.database;
    List<Map<String, dynamic>> result;

    try {
      String query =
          'SELECT * FROM ${DBTables.QUALITY_CONTROL} WHERE ${QualityControlColumn.INSPECTION_ID} = ?';
      result = await db.rawQuery(query, [inspectionId]);

      if (result.isNotEmpty) {
        return result.first[QualityControlColumn.IS_COMPLETE] == 1;
      }
    } catch (e) {
      debugPrint('Error has occurred while finding quality control items: $e');
    }
    return false;
  }

  Future<bool> isISTIsComplete(int inspectionId) async {
    final Database db = await dbProvider.database;
    List<Map<String, dynamic>> result;

    try {
      String query =
          'SELECT * FROM ${DBTables.INSPECTION_SAMPLE} WHERE ${InspectionSampleColumn.INSPECTION_ID} = ?';
      result = await db.rawQuery(query, [inspectionId]);

      if (result.isNotEmpty) {
        return result.first[InspectionSampleColumn.COMPLETE] == 1;
      }
    } catch (e) {
      debugPrint(
          'Error has occurred while finding trailer temperature items: $e');
    }
    return false;
  }

  Future<PartnerItemSKUInspections?> findPartnerItemSKUPOLine(
      int partnerId, String itemSKU, int poLineNo, String poNo) async {
    PartnerItemSKUInspections? item;

    final Database db = dbProvider.lazyDatabase;
    try {
      const query = '''
      SELECT * FROM ${DBTables.PARTNER_ITEMSKU}
      WHERE ${PartnerItemSkuColumn.PARTNER_ID} = ?
      AND ${PartnerItemSkuColumn.ITEM_SKU} = ?
      AND ${PartnerItemSkuColumn.PO_LINE_NO} = ?
      AND ${PartnerItemSkuColumn.PO_NO} = ?
    ''';

      List<Map> result =
          await db.rawQuery(query, [partnerId, itemSKU, poLineNo, poNo]);

      if (result.isNotEmpty) {
        item = PartnerItemSKUInspections.fromMap(
            result.first as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error has occurred while finding quality control items: $e');
    }

    return item;
  }

  Future<void> updateSpecificationAttributeNumValue(
      int inspectionId, int analyticalID, int rating, String comply) async {
    final db = DatabaseHelper.instance.lazyDatabase;

    try {
      await db.transaction((txn) async {
        await txn.update(
          DBTables.SPECIFICATION_ATTRIBUTES,
          {
            SpecificationAttributesColumn.SAMPLE_VALUE: rating,
            SpecificationAttributesColumn.COMPLY: comply,
          },
          where:
              '${SpecificationAttributesColumn.INSPECTION_ID} = ? AND ${SpecificationAttributesColumn.ANALYTICAL_ID} = ?',
          whereArgs: [inspectionId, analyticalID],
        );
      });
    } catch (e) {
      print('Error has occurred while updating an inspection: $e');
      rethrow;
    }
  }

  Future<void> updateSpecificationAttributeBrandedValue(
      int inspectionId, int analyticalID, String branded, String comply) async {
    final db = DatabaseHelper.instance.lazyDatabase;

    try {
      await db.transaction((txn) async {
        await txn.update(
          DBTables.SPECIFICATION_ATTRIBUTES,
          {
            SpecificationAttributesColumn.SAMPLE_TEXT_VALUE: branded,
            SpecificationAttributesColumn.COMPLY: comply,
          },
          where:
              '${SpecificationAttributesColumn.INSPECTION_ID} = ? AND ${SpecificationAttributesColumn.ANALYTICAL_ID} = ?',
          whereArgs: [inspectionId, analyticalID],
        );
      });
    } catch (e) {
      print('Error has occurred while updating an inspection: $e');
      rethrow;
    }
  }
}
