import 'package:pverify/models/inspection.dart';
import 'package:pverify/models/inspection_attachment.dart';
import 'package:pverify/models/inspection_defect.dart';
import 'package:pverify/models/inspection_sample.dart';
import 'package:pverify/models/inspection_specification.dart';
import 'package:pverify/models/my_inspection_48hour_item.dart';
import 'package:pverify/models/specification.dart';
import 'package:pverify/models/user.dart';
import 'package:pverify/models/user_offline.dart';
import 'package:pverify/services/database/column_names.dart';
import 'package:pverify/services/database/database_helper.dart';
import 'package:pverify/services/database/db_tables.dart';
import 'package:sqflite/sqflite.dart';

class ApplicationDao {
  // instance

  final dbProvider = DatabaseHelper.instance;

  Future<int> createOrUpdateUser(User user) async {
    final db = await DatabaseHelper.instance.database;
    if (user.id == null) {
      // Insert
      return await db.insert(DBTables.USER, user.toMap());
    } else {
      // Update
      return await db.update(
        DBTables.USER,
        user.toMap(),
        where: '${BaseColumns.ID} = ?',
        whereArgs: [user.id],
      );
    }
  }

  Future<int> getEnterpriseIdByUserId(String userId) async {
    final db = await DatabaseHelper.instance.database;

    int enterpriseId = 0;
    List<Map<String, dynamic>> result = await db.query(
      'user_table_offline',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (result.isNotEmpty) {
      enterpriseId = result.first['enterprise_id'];
    }

    await db.close();

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
          'SELECT COUNT(*) FROM user_table_offline WHERE user_id = ?',
          [userId]));

      if (userIdExists == 0) {
        result = await txn.insert('user_table_offline', {
          'user_id': userId,
          'access': userHash,
          'enterprise_id': enterpriseId,
          'status': status,
          'supplier_id': supplierId,
          'headquarter_supplier_id': headquarterSupplierId,
          'expiration_date': isSubscriptionExpired ? 'true' : 'false',
          'gtin_scanning': gtinScanning ? 'true' : 'false'
        });
      } else {
        result = await txn.update(
          'user_table_offline',
          {
            'user_id': userId,
            'access': userHash,
            'enterprise_id': enterpriseId,
            'status': status,
            'supplier_id': supplierId,
            'headquarter_supplier_id': headquarterSupplierId,
            'expiration_date': isSubscriptionExpired ? 'true' : 'false',
            'gtin_scanning': gtinScanning ? 'true' : 'false'
          },
          where: 'user_id = ?',
          whereArgs: [userId],
        );
      }
    });

    await db.close();
    return result;
  }

  Future<String?> getOfflineUserHash(String userId) async {
    final db = await DatabaseHelper.instance.database;
    String? userHash;
    List<Map<String, dynamic>> result = await db.query(
      'user_table_offline',
      columns: ['access'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (result.isNotEmpty) {
      userHash = result.first['access'];
    }

    await db.close();
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
}
