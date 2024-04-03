// ignore_for_file: no_leading_underscores_for_local_identifiers, use_rethrow_when_possible

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:pverify/models/finished_goods_item_sku.dart';
import 'package:pverify/models/inspection.dart';
import 'package:pverify/models/inspection_attachment.dart';
import 'package:pverify/models/inspection_defect.dart';
import 'package:pverify/models/inspection_defect_attachment.dart';
import 'package:pverify/models/inspection_sample.dart';
import 'package:pverify/models/inspection_specification.dart';
import 'package:pverify/models/my_inspection_48hour_item.dart';
import 'package:pverify/models/overridden_result_item.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/models/purchase_order_details.dart';
import 'package:pverify/models/qc_header_details.dart';
import 'package:pverify/models/quality_control_item.dart';
import 'package:pverify/models/specification.dart';
import 'package:pverify/models/specification_analytical_request_item.dart';
import 'package:pverify/models/specification_supplier_gtin.dart';
import 'package:pverify/models/trailer_temperature_item.dart';
import 'package:pverify/models/user.dart';
import 'package:pverify/models/user_offline.dart';
import 'package:pverify/services/database/column_names.dart';
import 'package:pverify/services/database/database_helper.dart';
import 'package:pverify/services/database/db_tables.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/utils.dart';
import 'package:sqflite/sqflite.dart';

class ApplicationDao {
  // instance

  final dbProvider = DatabaseHelper.instance;

  final AppStorage _appStorage = AppStorage.instance;

  AppStorage get appStorage => _appStorage;

  Future<int> createOrUpdateUser(User user) async {
    try {
      final db = await DatabaseHelper.instance.database;
      if (user.id == null) {
        // Insert
        return await db.insert(DBTables.USER, user.toJson());
      } else {
        // Update
        return await db.update(
          DBTables.USER,
          user.toJson(),
          where: '${BaseColumns.ID} = ?',
          whereArgs: [user.id],
        );
      }
    } catch (e) {
      log('failed to add-update user');
      return -1;
    }
  }

  Future<int> getEnterpriseIdByUserId(String userId) async {
    final db = await DatabaseHelper.instance.database;

    int enterpriseId = 0;
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
    final db = await DatabaseHelper.instance.database;
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
            isSubscriptionExpired ? 'true' : 'false',
        UserOfflineColumn.GTIN_SCANNING: gtinScanning ? 'true' : 'false'
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
    final db = await DatabaseHelper.instance.database;
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
  Future<List<User>> findAllUsers() async {
    final db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> maps = await db.query(DBTables.USER);
    return List.generate(maps.length, (mapData) {
      return User.fromMap(maps.elementAt(mapData));
    });
  }

  Future<User?> findUserByUserName(String name) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DBTables.USER,
      where: '${UserColumn.USER_NAME} = ?',
      whereArgs: [name],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int?> findUserIDByUserName(String name) async {
    final db = await DatabaseHelper.instance.database;
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
    final db = await DatabaseHelper.instance.database;
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
    final db = await DatabaseHelper.instance.database;
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
    final db = await DatabaseHelper.instance.database;
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
    final db = await dbProvider.database;
    var res = await db.insert(DBTables.INSPECTION, inspection.toMap());
    return res;
  }

  Future<int> createInspectionAttachment(
      InspectionAttachment attachment) async {
    final db = await dbProvider.database;
    var res =
        await db.insert(DBTables.INSPECTION_ATTACHMENT, attachment.toMap());
    return res;
  }

  Future<List<InspectionAttachment>> findInspectionAttachmentsByInspectionId(
      int inspectionId) async {
    final db = await dbProvider.database;
    List<Map> maps = await db.query(DBTables.INSPECTION_ATTACHMENT,
        where: '${InspectionAttachmentColumn.INSPECTION_ID} = ?',
        whereArgs: [inspectionId]);
    List<InspectionAttachment> attachments = [];
    if (maps.isNotEmpty) {
      for (Map<dynamic, dynamic> map in maps) {
        attachments
            .add(InspectionAttachment.fromMap(map as Map<String, dynamic>));
      }
    }
    return attachments;
  }

  Future<InspectionAttachment?> findAttachmentByAttachmentId(
      int attachmentId) async {
    final db = await dbProvider.database;
    List<Map> maps = await db.query(DBTables.INSPECTION_ATTACHMENT,
        where: '${BaseColumns.ID} = ?', whereArgs: [attachmentId]);
    if (maps.isNotEmpty) {
      return InspectionAttachment.fromMap(maps.first as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> deleteAttachmentByAttachmentId(int attachmentId) async {
    final db = await dbProvider.database;
    await db.delete(DBTables.INSPECTION_ATTACHMENT,
        where: '${BaseColumns.ID} = ?', whereArgs: [attachmentId]);
  }

// Additional methods like updateInspectionStatus, updateInspectionResult, etc., to be added here

  // updateInspectionStatus
  Future<int> updateInspectionStatus(int inspectionId, String status) async {
    final db = await dbProvider.database;
    return await db.update(
        DBTables.INSPECTION, {InspectionColumn.STATUS: status},
        where: '${BaseColumns.ID} = ?', whereArgs: [inspectionId]);
  }

  // updateInspectionResult
  Future<int> updateInspectionResult(int inspectionId, String result) async {
    final db = await dbProvider.database;
    return await db.update(
        DBTables.INSPECTION, {InspectionColumn.RESULT: result},
        where: '${BaseColumns.ID} = ?', whereArgs: [inspectionId]);
  }

  Future<int> createOrUpdateInspectionSpecification(
      InspectionSpecification spec) async {
    final db = await DatabaseHelper.instance.database;
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
  }

  Future<void> updateInspectionRating(int inspectionID, int rating) async {
    final db = await dbProvider.database;
    await db.update(
      DBTables.INSPECTION,
      {InspectionColumn.RATING: rating},
      where: '${BaseColumns.ID} = ?',
      whereArgs: [inspectionID],
    );
  }

  Future<bool> checkInspections() async {
    final db = await dbProvider.database;
    List<Map> result = await db.query(DBTables.INSPECTION);
    return result.isNotEmpty;
  }

  Future<void> updateInspectionComplete(int inspectionID, bool complete) async {
    final db = await dbProvider.database;
    await db.update(
      DBTables.INSPECTION,
      {
        InspectionColumn.COMPLETE: complete ? 1 : 0,
        'Complete_Date': DateTime.now().millisecondsSinceEpoch
        // FIXME: Assuming 'Complete_Date' is the column name
      },
      where: '${BaseColumns.ID} = ?',
      whereArgs: [inspectionID],
    );
  }

  Future<void> updateInspectionUploadStatus(
      int inspectionID, int status) async {
    final db = await dbProvider.database;
    await db.update(
      DBTables.INSPECTION,
      {InspectionColumn.UPLOAD_STATUS: status},
      where: '${BaseColumns.ID} = ?',
      whereArgs: [inspectionID],
    );
  }

  Future<void> updateInspectionServerId(int inspectionID, int serverID) async {
    final db = await dbProvider.database;
    await db.update(
      DBTables.INSPECTION,
      {'ServerID': serverID},
      where: '${BaseColumns.ID} = ?',
      whereArgs: [inspectionID],
    );
  }

  Future<void> updateInspection(
      int inspectionID, Map<String, dynamic> values) async {
    final db = await dbProvider.database;
    await db.update(
      DBTables.INSPECTION,
      values,
      where: '${BaseColumns.ID} = ?',
      whereArgs: [inspectionID],
    );
  }

  Future<Inspection?> findInspectionByID(int inspectionID) async {
    final db = await dbProvider.database;
    List<Map> maps = await db.query(
      DBTables.INSPECTION,
      where: '${BaseColumns.ID} = ?',
      whereArgs: [inspectionID],
    );

    if (maps.isNotEmpty) {
      return Inspection.fromMap(maps.first as Map<String, dynamic>);
    }
    return null;
  }

  // Fetch all inspections created within the last 48 hours
  Future<List<MyInspection48HourItem>> getAllLocalInspections() async {
    final db = await dbProvider.database;
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
      list.add(MyInspection48HourItem.fromMap(map as Map<String, dynamic>));
    }

    return list;
  }

  // Get all incomplete inspection IDs
  Future<List<int>> getAllIncompleteInspectionIDs() async {
    final db = await dbProvider.database;
    List<int> ids = [];

    List<Map> result = await db.query(
      DBTables.INSPECTION,
      columns: [(BaseColumns.ID)],
      where: 'Complete = ?',
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
    final db = await dbProvider.database;

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
    final db = await dbProvider.database;
    List<int> ids = [];

    List<Map> result = await db.query(
      DBTables.INSPECTION,
      columns: [(BaseColumns.ID)],
      where: '${InspectionColumn.UPLOAD_STATUS} = ?',
      // whereArgs: [Consts.INSPECTION_UPLOAD_READY],
// FIXME: Uncomment the line above and replace Consts.INSPECTION_UPLOAD_READY with the actual value
    );

    for (Map map in result) {
      ids.add(map[BaseColumns.ID]);
    }

    return ids;
  }

  // Delete an inspection by ID
  Future<void> deleteInspection(int inspectionId) async {
    final db = await dbProvider.database;

    // Here you would call the methods to delete related entries from other tables, if necessary.
    // For example: await deleteTrailerTemperatureEntriesByInspectionId(inspectionId);

    await db.delete(
      DBTables.INSPECTION,
      where: '${BaseColumns.ID} = ?',
      whereArgs: [inspectionId],
    );
  }

  // Delete an inspection after upload
  Future<void> deleteInspectionAfterUpload(int inspectionId) async {
    // This would be similar to deleteInspection, possibly with additional steps before the deletion.
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
    final db = await dbProvider.database;
    var sampleId = await db.insert(
      DBTables.INSPECTION_SAMPLE,
      {
        InspectionSampleColumn.INSPECTION_ID: inspectionId,
        InspectionSampleColumn.SET_SIZE: setSize,
        InspectionSampleColumn.SET_NAME: setName,
        InspectionSampleColumn.SET_NUMBER: setNumber,
        InspectionSampleColumn.CREATED_TIME: createdTime,
        'UpdatedTime': updatedTime,
        InspectionSampleColumn.COMPLETE: 1,
        'SampleNameUser': sampleNameUser,
      },
    );
    return sampleId;
  }

  Future<void> deleteInspectionSamples(int inspectionId) async {
    final db = await dbProvider.database;
    await db.delete(
      DBTables.INSPECTION_SAMPLE,
      where: 'InspectionID = ?',
      whereArgs: [inspectionId],
    );
  }

  Future<List<InspectionSample>> findInspectionSamples(int inspectionId) async {
    final db = await dbProvider.database;
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
    final db = await dbProvider.database;
    await db.update(
      DBTables.INSPECTION_SAMPLE,
      {
        'SampleNameUser': sampleNameUser
      }, // Assuming the column is named 'SampleNameUser'
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
    final db = await dbProvider.database;
    var defectId0 = await db.insert(
      DBTables.INSPECTION_DEFECT,
      {
        'InspectionID': inspectionId,
        'SampleID': sampleId,
        'DefectID': defectId,
        'DefectName': defectName,
        'InjuryCnt': injuryCnt,
        'DamageCnt': damageCnt,
        'SeriousDamageCnt': seriousDamageCnt,
        'Comments': comments ?? '',
        'Timestamp': timestamp,
        'VerySeriousDamageCnt': verySeriousDamageCnt,
        'DecayCnt': decayCnt,
        'SeverityInjuryId': severityInjuryId,
        'SeverityDamageId': severityDamageId,
        'SeveritySeriousDamageId': severitySeriousDamageId,
        'SeverityVerySeriousDamageId': severityVerySeriousDamageId,
        'SeverityDecayId': severityDecayId,
        'DefectCategory': defectCategory,
      },
    );
    return defectId0;
  }

  Future<void> deleteInspectionDefectByInspectionId(int inspectionId) async {
    final db = await dbProvider.database;
    await db.delete(
      DBTables.INSPECTION_DEFECT,
      where: 'InspectionID = ?',
      whereArgs: [inspectionId],
    );
  }

  Future<List<InspectionDefect>> findInspectionDefects(int sampleId) async {
    final db = await dbProvider.database;
    var results = await db.query(
      DBTables.INSPECTION_DEFECT,
      where: 'SampleID = ?',
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
    final db = await dbProvider.database;
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
        'SeverityInjuryId': severityInjuryId,
        'SeverityDamageId': severityDamageId,
        'SeveritySeriousDamageId': severitySeriousDamageId,
        'SeverityVerySeriousDamageId': severityVerySeriousDamageId,
        'SeverityDecayId': severityDecayId,
        InspectionDefectColumn.DEFECT_CATEGORY: defectCategory,
      },
      where: '${BaseColumns.ID} = ?',
      whereArgs: [inspectionDefectId],
    );
  }

  Future<void> deleteInspectionDefectBySampleId(int sampleId) async {
    final db = await dbProvider.database;
    await db.delete(
      DBTables.INSPECTION_DEFECT,
      where: 'SampleID = ?',
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

      final Database db = await dbProvider.database;

      await db.transaction((txn) async {
        await txn.rawDelete('DELETE FROM ${DBTables.ITEM_GROUP1}');
        debugPrint('fields ${fields.length} ${DBTables.ITEM_GROUP1}');
        for (var row in fields.skip(1).toList()) {
          // log('rowData $row');
          int igrId = row[0];
          String igrName = row[1];
          int igrCommodityId = row[2];

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
      log(e.toString());
      return false;
    }
  }

  Future<int> deletePartnerItemSKUForUpdateCache() async {
    try {
      final db = await dbProvider.database;

      return await db.transaction((txn) async {
        return await txn.delete(DBTables.PARTNER_ITEMSKU);
      });
    } catch (e) {
      log(e.toString());
      return -1;
    }
  }

  Future<bool> csvImportItemSKU() async {
    debugPrint('Importing Item SKU');

    try {
      final Database db = await dbProvider.database;
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
        debugPrint('fields ${fields.length} ${DBTables.ITEM_SKU}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemSkuData = {
            ItemSkuColumn.SKU_ID: row[0],
            ItemSkuColumn.CODE: row[1],
            ItemSkuColumn.COMMODITY_ID: row[2],
            ItemSkuColumn.NAME: row[3],
            ItemSkuColumn.DESCRIPTION: row[4],
            ItemSkuColumn.STATUS: row[5],
            ItemSkuColumn.ITEM_GROUP1_ID: row[6],
            ItemSkuColumn.ITEM_GROUP2_ID: row[7],
            ItemSkuColumn.GRADE_ID: row[8],
            ItemSkuColumn.PACKAGING_ID: row[9],
            ItemSkuColumn.USAGE_TYPE: row[10],
            ItemSkuColumn.COMMODITY_CATEGORY_ID: row[11],
            ItemSkuColumn.ITEM_TYPE: row[12],
            ItemSkuColumn.GLOBAL_PARTNER_ID: row[13],
            ItemSkuColumn.COMPANY_ID: row[14],
            ItemSkuColumn.DIVISION_ID: row[15],
            ItemSkuColumn.BRANDED: row[16],
            ItemSkuColumn.FTL: row[17],
          };
          await txn.insert(DBTables.ITEM_SKU, itemSkuData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      debugPrint('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Item SKU $e');
      return false;
    }
  }

  Future<bool> csvImportAgency() async {
    debugPrint('Importing Item Agency');

    try {
      final Database db = await dbProvider.database;
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
        debugPrint('fields ${fields.length} ${DBTables.AGENCY}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemAgencyData = {
            AgencyColumn.ID: row[0],
            AgencyColumn.NAME: row[1],
          };
          await txn.insert(DBTables.AGENCY, itemAgencyData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      debugPrint('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Item Agency $e');
      return false;
    }
  }

  Future<bool> csvImportGrade() async {
    debugPrint('Importing Item Grade');

    try {
      final Database db = await dbProvider.database;
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
        debugPrint('fields ${fields.length} ${DBTables.GRADE}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemGradeData = {
            GradeColumn.ID: row[0],
            GradeColumn.NAME: row[1],
            GradeColumn.AGENCY_ID: row[2],
          };
          await txn.insert(DBTables.GRADE, itemGradeData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      debugPrint('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Item Grade $e');
      return false;
    }
  }

  Future<bool> csvImportGradeCommodity() async {
    debugPrint('Importing Item Grade Commodity');

    try {
      final Database db = await dbProvider.database;
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
        debugPrint('fields ${fields.length} ${DBTables.GRADE_COMMODITY}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemGradeCommodityData = {
            GradeCommodityColumn.ID: row[0],
            GradeCommodityColumn.AGENCY_ID: row[1],
            GradeCommodityColumn.COMMODITY_ID: row[2],
          };
          await txn.insert(DBTables.GRADE_COMMODITY, itemGradeCommodityData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      debugPrint('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Item Grade Commodity $e');
      return false;
    }
  }

  Future<bool> csvImportGradeCommodityDetail() async {
    debugPrint('Importing Item Grade Commodity Detail');

    try {
      final Database db = await dbProvider.database;
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
        debugPrint(
            'fields ${fields.length} ${DBTables.GRADE_COMMODITY_DETAIL}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemGradeCommodityDetailData = {
            GradeCommodityDetailColumn.ID: row[0],
            GradeCommodityDetailColumn.GRADE_ID: row[1],
            GradeCommodityDetailColumn.GRADE_COMMODITY_ID: row[2],
            GradeCommodityDetailColumn.STATUS: row[3],
            GradeCommodityDetailColumn.SORT_SEQUENCE_FIELD: row[4],
          };
          await txn.insert(
              DBTables.GRADE_COMMODITY_DETAIL, itemGradeCommodityDetailData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      debugPrint('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Item Grade Commodity Detail $e');
      return false;
    }
  }

  Future<bool> csvImportSpecification() async {
    debugPrint('Importing Item specification');

    try {
      final Database db = await dbProvider.database;
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
        debugPrint('fields ${fields.length} ${DBTables.SPECIFICATION}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemSpecificationData = {
            SpecificationColumn.NUMBER: row[0],
            SpecificationColumn.VERSION: row[1],
            SpecificationColumn.NAME: row[2],
            SpecificationColumn.ITEM_GROUP1_ID: row[3],
            SpecificationColumn.COMMODITY_ID: row[4],
            SpecificationColumn.SPECIFICATION_TYPE_ID: row[5],
          };
          await txn.insert(DBTables.SPECIFICATION, itemSpecificationData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      debugPrint('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Item specification $e');
      return false;
    }
  }

  Future<bool> csvImportMaterialSpecification() async {
    debugPrint('Importing Item Material Specification');

    try {
      final Database db = await dbProvider.database;
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
        debugPrint(
            'fields ${fields.length} ${DBTables.MATERIAL_SPECIFICATION}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemMaterialSpecificationData = {
            MaterialSpecificationColumn.NUMBER_SPECIFICATION: row[0],
            MaterialSpecificationColumn.VERSION_SPECIFICATION: row[1],
            MaterialSpecificationColumn.GRADE_ID: row[2],
            MaterialSpecificationColumn.STATUS: row[3],
          };
          await txn.insert(
              DBTables.MATERIAL_SPECIFICATION, itemMaterialSpecificationData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      debugPrint('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Item Material Specification $e');
      return false;
    }
  }

  Future<bool> csvImportSpecificationSupplier() async {
    debugPrint('Importing Item Specification Supplier');

    try {
      final Database db = await dbProvider.database;
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
        debugPrint(
            'fields ${fields.length} ${DBTables.SPECIFICATION_SUPPLIER}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemSpecificationSupplierData = {
            SpecificationSupplierColumn.NUMBER_SPECIFICATION: row[0],
            SpecificationSupplierColumn.VERSION_SPECIFICATION: row[1],
            SpecificationSupplierColumn.SUPPLIER_ID: row[2],
            SpecificationSupplierColumn.NEGOTIATION_STATUS: row[3],
            SpecificationSupplierColumn.STATUS: row[4],
            SpecificationSupplierColumn.ITEM_SKU_ID: row[5],
            SpecificationSupplierColumn.GTIN: row[6],
            SpecificationSupplierColumn.SPECIFICATION_SUPPLIER_ID: row[7],
          };
          await txn.insert(
              DBTables.SPECIFICATION_SUPPLIER, itemSpecificationSupplierData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      debugPrint('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Item Specification Supplier $e');
      return false;
    }
  }

  Future<bool> csvImportSpecificationGradeTolerance() async {
    debugPrint('Importing Item Specification Grade Tolerance');

    try {
      final Database db = await dbProvider.database;
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
        debugPrint(
            'fields ${fields.length} ${DBTables.SPECIFICATION_GRADE_TOLERANCE}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemSpecificationGradeToleranceData = {
            SpecificationGradeToleranceColumn.SPECIFICATION_GRADE_TOLERANCE_ID:
                row[0],
            SpecificationGradeToleranceColumn.NUMBER_SPECIFICATION: row[1],
            SpecificationGradeToleranceColumn.VERSION_SPECIFICATION: row[2],
            SpecificationGradeToleranceColumn.SEVERITY_DEFECT_ID: row[3],
            SpecificationGradeToleranceColumn.DEFECT_ID: row[4],
            SpecificationGradeToleranceColumn.GRADE_TOLERANCE_PERCENTAGE:
                row[5].toString().isEmpty
                    ? row[5]
                    : Utils().parseDoubleDefault(row[5].toString().trim()),
            SpecificationGradeToleranceColumn.OVERRIDDEN: row[6],
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
      debugPrint('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Item Specification Grade Tolerance $e');
      return false;
    }
  }

  Future<bool> csvImportSpecificationAnalytical() async {
    debugPrint('Importing Item Specification Analytical');

    try {
      final Database db = await dbProvider.database;
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
        debugPrint(
            'fields ${fields.length} ${DBTables.SPECIFICATION_ANALYTICAL}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemSpecificationAnalyticalData = {
            SpecificationAnalyticalColumn.NUMBER_SPECIFICATION: row[0],
            SpecificationAnalyticalColumn.VERSION_SPECIFICATION: row[1],
            SpecificationAnalyticalColumn.ANALYTICAL_ID: row[2],
            SpecificationAnalyticalColumn.ANALYTICAL_NAME: row[3],
            SpecificationAnalyticalColumn.SPEC_MIN: row[4],
            SpecificationAnalyticalColumn.SPEC_MAX: row[5].toString().isEmpty
                ? row[5]
                : Utils().parseDoubleDefault(row[5].toString().trim()),
            SpecificationAnalyticalColumn.TARGET_NUM_VALUE: row[6],
            SpecificationAnalyticalColumn.TARGET_TEXT_VALUE: row[7],
            SpecificationAnalyticalColumn.UOM_NAME: row[8],
            SpecificationAnalyticalColumn.TYPE_ENTRY: row[9],
            SpecificationAnalyticalColumn.DESCRIPTION: row[10],
            SpecificationAnalyticalColumn.ORDER_NO: row[11],
            SpecificationAnalyticalColumn.PICTURE_REQUIRED: row[12],
            SpecificationAnalyticalColumn.TARGET_TEXT_DEFAULT: row[13],
            SpecificationAnalyticalColumn.INSPECTION_RESULT: row[14],
          };
          await txn.insert(DBTables.SPECIFICATION_ANALYTICAL,
              itemSpecificationAnalyticalData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      debugPrint('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Item Specification Analytical $e');
      return false;
    }
  }

  Future<bool> csvImportSpecificationPackagingFinishedGoods() async {
    debugPrint('Importing Item Specification Analytical');

    try {
      final Database db = await dbProvider.database;
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
        debugPrint(
            'fields ${fields.length} ${DBTables.SPECIFICATION_PACKAGING_FINISHED_GOODS}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemSpecificationAnalyticalData = {
            SpecificationPackagingFinishedGoodsColumn.FINISHED_GOODS_ID: row[0],
            SpecificationPackagingFinishedGoodsColumn.NUMBER_SPECIFICATION:
                row[1],
            SpecificationPackagingFinishedGoodsColumn.VERSION_SPECIFICATION:
                row[2],
            SpecificationPackagingFinishedGoodsColumn.ITEM_SKU_ID: row[3],
          };
          await txn.insert(DBTables.SPECIFICATION_PACKAGING_FINISHED_GOODS,
              itemSpecificationAnalyticalData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      debugPrint('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Item Specification Analytical $e');
      return false;
    }
  }

  Future<bool> csvImportSpecificationType() async {
    debugPrint('Importing Item Specification Type');

    try {
      final Database db = await dbProvider.database;
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
        debugPrint('fields ${fields.length} ${DBTables.SPECIFICATION_TYPE}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemSpecificationTypeData = {
            SpecificationTypeColumn.SPECIFICATION_TYPE_ID: row[0],
            SpecificationTypeColumn.NAME: row[1],
          };
          await txn.insert(
              DBTables.SPECIFICATION_TYPE, itemSpecificationTypeData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      debugPrint('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Item Specification Type $e');
      return false;
    }
  }

  Future<bool> csvImportCommodity() async {
    debugPrint('Importing Item Commodity');

    try {
      final Database db = await dbProvider.database;
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
        debugPrint('fields ${fields.length} ${DBTables.COMMODITY}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemCommodityData = {
            CommodityColumn.ID: row[0],
            CommodityColumn.NAME: row[1],
            CommodityColumn.SAMPLE_SIZE_BY_COUNT: row[2],
            CommodityColumn.KEYWORDS: row[3],
          };
          await txn.insert(DBTables.COMMODITY, itemCommodityData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      debugPrint('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Item Commodity $e');
      return false;
    }
  }

  Future<bool> csvImportCommodityKeywords() async {
    debugPrint('Importing Item Commodity Keywords');

    try {
      final Database db = await dbProvider.database;
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
        debugPrint('fields ${fields.length} ${DBTables.COMMODITY_KEYWORDS}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemCommodityKeywordsData = {
            CommodityKeywordsColumn.ID: row[0],
            CommodityKeywordsColumn.KEYWORDS: row[1],
          };
          await txn.insert(
              DBTables.COMMODITY_KEYWORDS, itemCommodityKeywordsData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      debugPrint('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Item Commodity Keywords $e');
      return false;
    }
  }

  Future<bool> csvImportPOHeader() async {
    debugPrint('Importing Item POHeader');

    try {
      final Database db = await dbProvider.database;
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
        debugPrint('fields ${fields.length} ${DBTables.PO_HEADER}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemPOHeaderData = {
            POHeaderColumn.PO_HEADER_ID: row[0],
            POHeaderColumn.PO_NUMBER: row[1],
            POHeaderColumn.PO_DELIVER_TO_ID: row[2],
            POHeaderColumn.PO_DELIVER_TO_NAME: row[3],
            POHeaderColumn.PO_PARTNER_ID: row[4],
            POHeaderColumn.PO_PARTNER_NAME: row[5],
          };
          await txn.insert(DBTables.PO_HEADER, itemPOHeaderData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      debugPrint('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Item POHeader $e');
      return false;
    }
  }

  Future<bool> csvImportPODetail() async {
    debugPrint('Importing Item PODetail');

    try {
      final Database db = await dbProvider.database;
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
        debugPrint('fields ${fields.length} ${DBTables.PO_DETAIL}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemPODetailData = {
            PODetailColumn.PO_DETAIL_ID: row[0],
            PODetailColumn.PO_HEADER_ID: row[1],
            PODetailColumn.PO_DETAIL_NUMBER: row[2],
            PODetailColumn.PO_DELIVER_TO_ID: row[3],
            PODetailColumn.PO_DELIVER_TO_NAME: row[4],
            PODetailColumn.PO_LINE_NUMBER: row[5],
            PODetailColumn.PO_ITEM_SKU_ID: row[6],
            PODetailColumn.PO_ITEM_SKU_CODE: row[7],
            PODetailColumn.PO_ITEM_SKU_NAME: row[8],
            PODetailColumn.PO_QUANTITY: row[9],
            PODetailColumn.PO_QTY_UOM_ID: row[10],
            PODetailColumn.PO_QTY_UOM_NAME: row[11],
            PODetailColumn.PO_NUMBER_SPEC: row[12],
            PODetailColumn.PO_VERSION_SPEC: row[13],
            PODetailColumn.PO_COMMODITY_ID: row[14],
            PODetailColumn.PO_COMMODITY_NAME: row[15],
          };
          await txn.insert(DBTables.PO_DETAIL, itemPODetailData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      debugPrint('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Item PODetail $e');
      return false;
    }
  }

  Future<bool> csvImportSpecificationSupplierGtins() async {
    debugPrint('Importing Item Specification SupplierGtins');

    try {
      final Database db = await dbProvider.database;
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
        debugPrint(
            'fields ${fields.length} ${DBTables.SPECIFICATION_SUPPLIER_GTIN}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemSpecificationSupplierGtinsData = {
            SpecificationSupplierGtinColumn.SPECIFICATION_SUPPLIER_ID: row[0],
            SpecificationSupplierGtinColumn.GTIN: row[1],
          };
          await txn.insert(DBTables.SPECIFICATION_SUPPLIER_GTIN,
              itemSpecificationSupplierGtinsData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      debugPrint('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Specification Supplier Gtins $e');
      return false;
    }
  }

  Future<bool> csvImportCommodityCTE() async {
    debugPrint('Importing Item Commodity CTE');

    try {
      final Database db = await dbProvider.database;
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
        debugPrint('fields ${fields.length} ${DBTables.COMMODITY_CTE}');
        for (List<dynamic> row in fields.skip(1).toList()) {
          Map<String, dynamic> itemCommodityCteData = {
            CommodityCteColumn.ID: row[0],
            CommodityCteColumn.NAME: row[1],
            CommodityCteColumn.SAMPLE_SIZE_BY_COUNT: row[2],
            CommodityCteColumn.KEYWORDS: row[3],
          };
          await txn.insert(DBTables.COMMODITY_CTE, itemCommodityCteData);
        }
      });
      return true;
    } on FileSystemException catch (e) {
      debugPrint('File operation failed: $e');
      return false;
    } catch (e) {
      log('Error: while adding Commodity CTE $e');
      return false;
    }
  }

  Future<QCHeaderDetails?> findTempQCHeaderDetails(String poNumber) async {
    QCHeaderDetails? qcItem; // Make qcItem nullable by adding '?'
    final database = await DatabaseHelper.instance.database;

    try {
      List<Map<String, dynamic>> result = await database.query(
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
          id: row['Temp_QCH_BASE_ID'],
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
      debugPrint("Error has occurred while finding quality control items: $e");
    }
    return qcItem;
  }

  Future<List<PurchaseOrderDetails>> getPODetailsFromTable(
      String poNumber, int inspectorSupplierId) async {
    List<PurchaseOrderDetails> purchaseOrderDetailsList = [];

    final _db = await DatabaseHelper.instance.database;

    try {
      List<Map<String, dynamic>> results = await _db.rawQuery('''
        SELECT poh.PO_Number, poh.PO_Deliver_To_Id, poh.PO_Deliver_To_Name, poh.PO_Partner_Id,
        poh.PO_Partner_Name,
        pod.PO_Line_Number, pod.PO_Item_Sku_Id, pod.PO_Item_Sku_Code, pod.PO_Item_Sku_Name,
        pod.PO_Quantity, pod.PO_Qty_UOM_Id, pod.PO_Qty_UOM_Name,
        pod.PO_Number_Spec, pod.PO_Version_Spec, pod.PO_Commodity_Id, pod.PO_Commodity_Name
        FROM PO_Detail pod
        INNER JOIN PO_Header poh ON pod.PO_Header_ID=poh.PO_Header_ID
        WHERE poh.PO_Number='$poNumber' AND poh.PO_Deliver_To_Id=$inspectorSupplierId
      ''');

      // List<Map<String, dynamic>> results = await _db.rawQuery(
      //   "SELECT ${POHeaderColumn.PO_NUMBER}, ${POHeaderColumn.PO_DELIVER_TO_ID}, ${POHeaderColumn.PO_DELIVER_TO_NAME}, ${POHeaderColumn.PO_PARTNER_ID}, "
      //   "${POHeaderColumn.PO_PARTNER_NAME}, "
      //   "${PODetailColumn.PO_LINE_NUMBER}, ${PODetailColumn.PO_ITEM_SKU_ID}, ${PODetailColumn.PO_ITEM_SKU_CODE}, ${PODetailColumn.PO_ITEM_SKU_NAME}, "
      //   "${PODetailColumn.PO_QUANTITY}, ${PODetailColumn.PO_QTY_UOM_ID}, ${PODetailColumn.PO_QTY_UOM_NAME}, "
      //   "${PODetailColumn.PO_NUMBER_SPEC}, ${PODetailColumn.PO_VERSION_SPEC}, ${PODetailColumn.PO_COMMODITY_ID}, ${PODetailColumn.PO_COMMODITY_NAME} "
      //   "FROM ${DBTables.PO_DETAIL} pod "
      //   "INNER JOIN PO_Header poh ON ${PODetailColumn.PO_HEADER_ID}=${POHeaderColumn.PO_HEADER_ID} "
      //   "WHERE ${POHeaderColumn.PO_NUMBER}='$poNumber' AND ${POHeaderColumn.PO_DELIVER_TO_ID}=$inspectorSupplierId",
      // );
      for (var result in results) {
        purchaseOrderDetailsList.add(PurchaseOrderDetails.fromMap(result));
      }
    } catch (e) {
      debugPrint('Error has occurred while finding quality control items: $e');
    }
    return purchaseOrderDetailsList;
  }

  Future<List<int>> getPartnerSKUInspectionIDsByPONo(String poNumber) async {
    List<int> inspIDs = [];
    final _db = await DatabaseHelper.instance.database;
    try {
      List<Map<String, dynamic>> results = await _db.rawQuery('''
        SELECT ${PartnerItemSkuColumn.INSPECTION_ID} FROM ${DBTables.PARTNER_ITEMSKU} WHERE ${PartnerItemSkuColumn.PO_NO}=?
      ''', [poNumber]);

      for (var result in results) {
        inspIDs.add(result['inspection_id']);
      }
    } catch (e) {
      debugPrint('Error has occurred while finding pfg: $e');
    }
    return inspIDs;
  }

  Future<int?> createTempQCHeaderDetails(
    int partnerID,
    String poNo,
    String sealNo,
    String qchOpen1,
    String qchOpen2,
    String qchOpen3,
    String qchOpen4,
    String qchOpen5,
    String qchOpen6,
    String qchOpen9,
    String qchOpen10,
    String truckTempOk,
    String productTransfer,
    String cteType,
  ) async {
    int? ttId;
    final _db = await DatabaseHelper.instance.database;
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
      debugPrint('Error has occurred while creating a trailer temperature: $e');
      rethrow;
    }
    return ttId;
  }

  Future<void> updateTempQCHeaderDetails(
    int baseId,
    String poNo,
    String sealNo,
    String qchOpen1,
    String qchOpen2,
    String qchOpen3,
    String qchOpen4,
    String qchOpen5,
    String qchOpen6,
    String qchOpen9,
    String qchOpen10,
    String truckTempOk,
    String productTransfer,
    String cteType,
  ) async {
    // Open the db
    final Database db = await dbProvider.database;

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
      debugPrint('Error has occurred while updating a trailer temperature: $e');
      throw e;
    }
  }

  Future<List<SpecificationSupplierGTIN>?>
      getSpecificationSupplierGTINFromTable(String gtin) async {
    List<SpecificationSupplierGTIN> itemSKUList = [];
    SpecificationSupplierGTIN item;
    final db = await dbProvider.database;

    try {
      String? specNo = "";
      String? specVersion = "";

      String query =
          "Select distinct number_specification, version_specification from Specification_Supplier ss " +
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
          "FROM SPECIFICATION_SUPPLIER SS JOIN SPECIFICATION SP ON (SS.NUMBER_SPECIFICATION,SS.VERSION_SPECIFICATION)=(SP.NUMBER,SP.VERSION) " +
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
      debugPrint("Error has occurred while finding quality control items.");
      debugPrint(e as String?);
      return null;
    }

    return itemSKUList;
  }

  Future<int> deleteRowsTempTrailerTable() async {
    try {
      final Database db = await dbProvider.database;
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
      final Database db = await dbProvider.database;
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
      final Database db = await dbProvider.database;
      return await db.transaction((txn) async {
        return await txn.delete(DBTables.SELECTED_ITEM_SKU_LIST);
      });
    } catch (e) {
      debugPrint(
          'Error has occurred while deleting selected item SKU list: $e');
      return -1;
    }
  }

  Future<List<InspectionDefectAttachment>?> findDefectAttachmentsByInspectionId(
      int inspectionId) async {
    final Database db = await dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
        DBTables.INSPECTION_DEFECT_ATTACHMENT,
        where: '${InspectionDefectAttachmentColumn.INSPECTION_ID} = ?',
        whereArgs: [inspectionId]);
    return List.generate(maps.length, (i) {
      return InspectionDefectAttachment.fromJson(maps[i]);
    });
  }

  Future<List<FinishedGoodsItemSKU>?> getFinishedGoodItemSkuFromTable(
      Database database,
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
      bool hqUser = supplierId == headquarterId;

      if (hqUser) {
        query = "select distinct(itemSku.SKU_ID), itemSku.Name, itemSku.Code, itemSku.FTL, itemSku.Branded from Specification_Supplier SS " +
            "inner join Material_Specification MS on (SS.Number_Specification, SS.Version_Specification)=(MS.Number_Specification,MS.Version_Specification) " +
            "inner join Item_SKU itemSku on SS.Item_SKU_ID=itemSku.SKU_ID " +
            "inner join Commodity C on itemSku.Commodity_ID=C.ID " +
            "where SS.Status='A' and SS.supplier_id=? " +
            "AND itemSku.Usage_Type='FG' and itemSku.Status='AC' " +
            "AND itemSku.Company_Id =? " +
            "And MS.Status = 'A' and C.ID=?";
      } else {
        query = "select distinct(itemSku.SKU_ID), itemSku.Name, itemSku.Code, itemSku.FTL, itemSku.Branded from Specification_Supplier SS " +
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

      List<Map<String, dynamic>> results = await database.rawQuery(query, args);

      for (Map<String, dynamic> row in results) {
        item = FinishedGoodsItemSKU.fromMap(row);
        item.copyWith(
          commodityName: commodityName,
          partnerId: supplierId,
          partnerName: partnerName,
        );

        itemSKUList.add(item);
      }
    } catch (e) {
      print("Error occurred while finding quality control items: $e");
      return null;
    }
    return itemSKUList;
  }

  Future<QualityControlItem?> findQualityControlDetails(
      int inspectionId) async {
    final Database db = await dbProvider.database;
    List<Map> results = await db.query(
      DBTables.QUALITY_CONTROL,
      where: '${QualityControlColumn.INSPECTION_ID} = ?',
      whereArgs: [inspectionId],
    );

    if (results.isNotEmpty) {
      return QualityControlItem.fromJson(results.first as Map<String, dynamic>);
    }

    return null;
  }

  Future<List<TrailerTemperatureItem>> findListTrailerTemperatureItems(
      int inspectionId) async {
    final Database db = await dbProvider.database;
    List<TrailerTemperatureItem> trailerTempList = [];
    List<Map> results = await db.query(
      DBTables.TRAILER_TEMPERATURE,
      where: '${TrailerTemperatureColumn.INSPECTION_ID} = ?',
      whereArgs: [inspectionId],
    );

    for (Map<dynamic, dynamic> map in results) {
      trailerTempList
          .add(TrailerTemperatureItem.fromMap(map as Map<String, dynamic>));
    }

    return trailerTempList;
  }

  Future<List<SpecificationAnalyticalRequest>>
      findSpecificationAnalyticalRequest(int inspectionId) async {
    final Database db = await dbProvider.database;
    List<SpecificationAnalyticalRequest> list = [];

    List<Map> results = await db.query(
      DBTables.SPECIFICATION_ATTRIBUTES,
      where: '${SpecificationAttributesColumn.INSPECTION_ID} = ?',
      whereArgs: [inspectionId],
    );

    for (Map<dynamic, dynamic> map in results) {
      list.add(
          SpecificationAnalyticalRequest.fromMap(map as Map<String, dynamic>));
    }

    return list;
  }

  Future<OverriddenResult?> getOverriddenResult(int inspectionId) async {
    final Database db = await dbProvider.database;
    OverriddenResult? item;

    List<Map> results = await db.rawQuery(
      'SELECT Overridden_By, Overridden_Result, Overridden_Timestamp, Overridden_Comments, Old_Result, Original_Qty_Shipped, Original_Qty_Rejected, New_Qty_Shipped, New_Qty_Rejected FROM ${DBTables.OVERRIDDEN_RESULT} WHERE Inspection_ID = ?',
      [inspectionId.toString()],
    );

    if (results.isNotEmpty) {
      item = OverriddenResult.fromMap(results.first as Map<String, dynamic>);
    }

    return item;
  }
}
