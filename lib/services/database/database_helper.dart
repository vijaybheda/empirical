// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:pverify/services/database/column_names.dart';
import 'package:pverify/services/database/db_tables.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = "inspection.db";
  static const _databaseVersion = 1;

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // lazy Database
  Database get lazyDatabase => _database!;

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    debugPrint('path:${path}');
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    db.execute("CREATE TABLE ${DBTables.USER} (${BaseColumns.ID} "
        "INTEGER PRIMARY KEY AUTOINCREMENT, "
        "${UserColumn.USER_NAME} CHAR NOT NULL, "
        "${UserColumn.LOGIN_TIME} INTEGER, "
        "${UserColumn.LANGUAGE} CHAR )");

    db.execute("CREATE TABLE ${DBTables.USER_OFFLINE} (${BaseColumns.ID} "
        "INTEGER PRIMARY KEY AUTOINCREMENT, "
        "${UserOfflineColumn.USER_ID} CHAR NOT NULL, "
        "${UserOfflineColumn.ACCESS} CHAR NOT NULL, "
        "${UserOfflineColumn.ENTERPRISEID} INTEGER, "
        "${UserOfflineColumn.STATUS} CHAR, "
        "${UserOfflineColumn.IS_SUBSCRIPTION_EXPIRED} CHAR, "
        "${UserOfflineColumn.SUPPLIER_ID} INTEGER, "
        "${UserOfflineColumn.HEADQUATER_SUPPLIER_ID} INTEGER, "
        "${UserOfflineColumn.GTIN_SCANNING} CHAR )");

    db.execute("CREATE TABLE ${DBTables.INSPECTION} (${BaseColumns.ID} "
        "INTEGER PRIMARY KEY AUTOINCREMENT, "
        "${InspectionColumn.USER_ID} INTEGER NOT NULL, "
        "${InspectionColumn.PARTNER_ID} INTEGER, "
        "${InspectionColumn.CARRIER_ID} INTEGER, "
        "${InspectionColumn.COMMODITY_ID} INTEGER, "
        "${InspectionColumn.VARIETY_ID} INTEGER, "
        "${InspectionColumn.VARIETY_NAME} CHAR, "
        "${InspectionColumn.CREATED_TIME} INTEGER, "
        "${InspectionColumn.RESULT} CHAR, "
        "${InspectionColumn.MANAGER_STATUS} CHAR, "
        "${InspectionColumn.MANAGER_COMMENT} CHAR, "
        "${InspectionColumn.STATUS} CHAR, "
        "${InspectionColumn.COMPLETE} CHAR, "
        "${InspectionColumn.GRADE_ID} INTEGER, "
        "${InspectionColumn.DOWNLOAD_ID} INTEGER, "
        "${InspectionColumn.UPLOAD_STATUS} INTEGER, "
        "${InspectionColumn.COMPLETED_TIME} INTEGER, "
        "${InspectionColumn.SPECIFICATION_NAME} CHAR, "
        "${InspectionColumn.SPECIFICATION_VERSION} CHAR, "
        "${InspectionColumn.SPECIFICATION_NUMBER} CHAR, "
        "${InspectionColumn.SPECIFICATION_TYPENAME} CHAR, "
        "${InspectionColumn.LOT_NO} CHAR, PackDate CHAR, "
        "${InspectionColumn.SAMPLE_SIZE_BY_COUNT} INTEGER, "
        "${InspectionColumn.ITEM_SKU} CHAR, "
        "${InspectionColumn.ITEM_SKU_ID} INTEGER, "
        "${InspectionColumn.COMMODITY_NAME} CHAR, "
        "${InspectionColumn.PO_NUMBER} CHAR, "
        "${InspectionColumn.INSPECTION_SERVER_ID} INTEGER, "
        "${InspectionColumn.RATING} INTEGER, "
        "${InspectionColumn.POLINENO} INTEGER, "
        "${InspectionColumn.PARTNER_NAME} CHAR, "
        "${InspectionColumn.TO_LOCATION_ID} INTEGER, "
        "${InspectionColumn.TO_LOCATION_NAME} CHAR, "
        "${InspectionColumn.CTE_TYPE} CHAR, "
        "${InspectionColumn.ITEM_SKU_NAME} CHAR )");

    db.execute("CREATE TABLE ${DBTables.INSPECTION_ATTACHMENT} "
        "(${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, "
        "${InspectionAttachmentColumn.INSPECTION_ID} INTEGER NOT NULL, "
        "${InspectionAttachmentColumn.ATTACHMENT_ID}, "
        "${InspectionAttachmentColumn.ATTACHMENT_TITLE}, "
        "${InspectionAttachmentColumn.CREATED_TIME} INTEGER, "
        "${InspectionAttachmentColumn.FILE_LOCATION} CHAR )");

    db.execute("CREATE TABLE ${DBTables.INSPECTION_SAMPLE} "
        "(${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, "
        "${InspectionSampleColumn.INSPECTION_ID} INTEGER NOT NULL, "
        "${InspectionSampleColumn.SET_SIZE} INTEGER, "
        "${InspectionSampleColumn.SET_NAME} CHAR, "
        "${InspectionSampleColumn.SET_NUMBER} INTEGER, "
        "${InspectionSampleColumn.CREATED_TIME} INTEGER, "
        "${InspectionSampleColumn.LAST_UPDATED_TIME} INTEGER, "
        "${InspectionSampleColumn.COMPLETE} INTEGER, "
        "${InspectionSampleColumn.SAMPLE_NAME} CHAR )");

    db.execute("CREATE TABLE ${DBTables.INSPECTION_DEFECT} "
        "(${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, "
        "${InspectionDefectColumn.INSPECTION_ID} INTEGER NOT NULL, "
        "${InspectionDefectColumn.INSPECTION_SAMPLE_ID} INTEGER NOT NULL, "
        "${InspectionDefectColumn.DEFECT_ID} INTEGER, "
        "${InspectionDefectColumn.DEFECT_NAME} CHAR, "
        "${InspectionDefectColumn.INJURY_CNT} INTEGER, "
        "${InspectionDefectColumn.DAMAGE_CNT} INTEGER, "
        "${InspectionDefectColumn.SERIOUS_DAMAGE_CNT} INTEGER, "
        "${InspectionDefectColumn.COMMENTS} CHAR, "
        "${InspectionDefectColumn.CREATED_TIME} INTEGER, "
        "${InspectionDefectColumn.LAST_UPDATED_TIME} INTEGER, "
        "${InspectionDefectColumn.IDT_COMPLETE} INTEGER, "
        "${InspectionDefectColumn.VERY_SERIOUS_DAMAGE_CNT} INTEGER, "
        "${InspectionDefectColumn.DECAY_CNT} INTEGER, "
        "${InspectionDefectColumn.INJURY_ID} INTEGER, "
        "${InspectionDefectColumn.DAMAGE_ID} INTEGER, "
        "${InspectionDefectColumn.SERIOUS_DAMAGE_ID} INTEGER, "
        "${InspectionDefectColumn.VERY_SERIOUS_DAMAGE_ID}  INTEGER, "
        "${InspectionDefectColumn.DECAY_ID} INTEGER, "
        "${InspectionDefectColumn.DEFECT_CATEGORY} CHAR )");

    db.execute("CREATE TABLE ${DBTables.INSPECTION_DEFECT_ATTACHMENT} "
        "(${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, "
        "${InspectionDefectAttachmentColumn.INSPECTION_ID} INTEGER NOT NULL, "
        "${InspectionDefectAttachmentColumn.INSPECTION_SAMPLE_ID} INTEGER NOT NULL, "
        "${InspectionDefectAttachmentColumn.INSPECTION_DEFECT_ID} INTEGER NOT NULL, "
        "${InspectionDefectAttachmentColumn.CREATED_TIME} INTEGER, "
        "${InspectionDefectAttachmentColumn.FILE_LOCATION} CHAR, "
        "${InspectionDefectAttachmentColumn.DEFECT_SAVED} CHAR DEFAULT ('N') )");

    db.execute("CREATE TABLE ${DBTables.TRAILER_TEMPERATURE} "
        "(${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, "
        "${TrailerTemperatureColumn.INSPECTION_ID} INTEGER NOT NULL, "
        "${TrailerTemperatureColumn.LOCATION} CHAR, "
        "${TrailerTemperatureColumn.LEVEL} CHAR, "
        "${TrailerTemperatureColumn.VALUE} INTEGER, "
        "${TrailerTemperatureColumn.COMPLETE} INTEGER, "
        "${TrailerTemperatureColumn.PO_NUMBER} CHAR )");

    db.execute("CREATE TABLE ${DBTables.QUALITY_CONTROL} "
        "(${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, "
        "${QualityControlColumn.INSPECTION_ID} INTEGER NOT NULL, "
        "${QualityControlColumn.BRAND_ID} INTEGER,"
        "${QualityControlColumn.ORIGIN_ID} INTEGER,"
        "${QualityControlColumn.QTY_SHIPPED} INTEGER,"
        "${QualityControlColumn.UOM_QTY_SHIPPED_ID} INTEGER,"
        "${QualityControlColumn.PO_NO} CHAR,"
        "${QualityControlColumn.PULP_TEMP_MIN} INTEGER,"
        "${QualityControlColumn.PULP_TEMP_MAX} INTEGER,"
        "${QualityControlColumn.RECORDER_TEMP_MIN} INTEGER,"
        "${QualityControlColumn.RECORDER_TEMP_MAX} INTEGER,"
        "${QualityControlColumn.SEAL} CHAR,"
        "${QualityControlColumn.RPC} CHAR,"
        "${QualityControlColumn.CLAIM_FILED_AGAINST} CHAR,"
        "${QualityControlColumn.QTY_REJECTED} INTEGER,"
        "${QualityControlColumn.UOM_QTY_REJECTED_ID} INTEGER,"
        "${QualityControlColumn.REASON_ID} INTEGER,"
        "${QualityControlColumn.QC_COMMENTS} CHAR,"
        "${QualityControlColumn.QTY_RECEIVED} INTEGER,"
        "${QualityControlColumn.UOM_QTY_RECEIVED} INTEGER,"
        "${QualityControlColumn.IS_COMPLETE} INTEGER,"
        "${QualityControlColumn.SPECIFICATION_NAME} CHAR,"
        "${QualityControlColumn.LOT_NUMBER} CHAR, "
        "${QualityControlColumn.PACK_DATE} CHAR, "
        "${QualityControlColumn.QCDOPEN1} CHAR, "
        "${QualityControlColumn.QCDOPEN2} CHAR, "
        "${QualityControlColumn.QCDOPEN3} CHAR, "
        "${QualityControlColumn.QCDOPEN4} CHAR, "
        "${QualityControlColumn.QCDOPEN5} CHAR, "
        "${QualityControlColumn.GTIN} CHAR, "
        "${QualityControlColumn.LOT_SIZE} INTEGER, "
        "${QualityControlColumn.SHIP_DATE} CHAR, "
        "${QualityControlColumn.DATE_TYPE} CHAR )");

    db.execute("CREATE TABLE ${DBTables.OVERRIDDEN_RESULT} "
        "(${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, "
        "${OverriddenResultColumn.INSPECTION_ID} INTEGER NOT NULL, "
        "${OverriddenResultColumn.OVERRIDDEN_BY} INTEGER, "
        "${OverriddenResultColumn.OVERRIDDEN_RESULT} CHAR, "
        "${OverriddenResultColumn.OVERRIDDEN_TIMESTAMP} INTEGER, "
        "${OverriddenResultColumn.OVERRIDDEN_COMMENTS} CHAR, "
        "${OverriddenResultColumn.OLD_RESULT} CHAR, "
        "${OverriddenResultColumn.ORIGINAL_QTY_SHIPPED} INTEGER, "
        "${OverriddenResultColumn.ORIGINAL_QTY_REJECTED} INTEGER, "
        "${OverriddenResultColumn.NEW_QTY_SHIPPED} INTEGER, "
        "${OverriddenResultColumn.NEW_QTY_REJECTED} INTEGER )");

    db.execute("CREATE TABLE ${DBTables.INSPECTION_SPECIFICATION} "
        "(${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, "
        "${InspectionSpecificationColumn.INSPECTION_ID} INTEGER NOT NULL, "
        "${InspectionSpecificationColumn.SPECIFICATION_NUMBER} CHAR, "
        "${InspectionSpecificationColumn.SPECIFICATION_VERSION} CHAR, "
        "${InspectionSpecificationColumn.SPECIFICATION_NAME} CHAR)");

    db.execute("CREATE TABLE ${DBTables.ITEM_SKU} "
        "(${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, "
        "${ItemSkuColumn.SKU_ID} INTEGER NOT NULL, "
        "${ItemSkuColumn.CODE} CHAR,"
        "${ItemSkuColumn.COMMODITY_ID} INTEGER,"
        "${ItemSkuColumn.NAME} CHAR,"
        "${ItemSkuColumn.DESCRIPTION} CHAR,"
        "${ItemSkuColumn.STATUS} CHAR,"
        "${ItemSkuColumn.ITEM_GROUP1_ID} INTEGER,"
        "${ItemSkuColumn.ITEM_GROUP2_ID} INTEGER,"
        "${ItemSkuColumn.GRADE_ID} INTEGER,"
        "${ItemSkuColumn.PACKAGING_ID} INTEGER,"
        "${ItemSkuColumn.USAGE_TYPE} CHAR,"
        "${ItemSkuColumn.COMMODITY_CATEGORY_ID} INTEGER,"
        "${ItemSkuColumn.ITEM_TYPE} CHAR, "
        "${ItemSkuColumn.GLOBAL_PARTNER_ID} INTEGER, "
        "${ItemSkuColumn.COMPANY_ID} INTEGER, "
        "${ItemSkuColumn.DIVISION_ID} INTEGER, "
        "${ItemSkuColumn.BRANDED} CHAR, "
        "${ItemSkuColumn.FTL} CHAR )");

    db.execute(
        "CREATE TABLE ${DBTables.ITEM_GROUP1} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT,"
        "${ItemGroup1Column.GROUP1_ID} INTEGER NOT NULL,"
        "${ItemGroup1Column.NAME} CHAR,"
        "${ItemGroup1Column.COMMODITY_ID} INTEGER)");

    db.execute(
        "CREATE TABLE ${DBTables.SPECIFICATION} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT,"
        "${SpecificationColumn.NUMBER} CHAR,"
        "${SpecificationColumn.VERSION} CHAR,"
        "${SpecificationColumn.NAME} CHAR,"
        "${SpecificationColumn.ITEM_GROUP1_ID} INTEGER,"
        "${SpecificationColumn.COMMODITY_ID} INTEGER,"
        "${SpecificationColumn.SPECIFICATION_TYPE_ID} INTEGER)");

    db.execute(
        "CREATE TABLE ${DBTables.SPECIFICATION_SUPPLIER} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT,"
        "${SpecificationSupplierColumn.NUMBER_SPECIFICATION} CHAR,"
        "${SpecificationSupplierColumn.VERSION_SPECIFICATION} CHAR,"
        "${SpecificationSupplierColumn.SUPPLIER_ID} INTEGER,"
        "${SpecificationSupplierColumn.NEGOTIATION_STATUS} CHAR,"
        "${SpecificationSupplierColumn.STATUS} CHAR,"
        "${SpecificationSupplierColumn.ITEM_SKU_ID} INTEGER,"
        "${SpecificationSupplierColumn.GTIN} CHAR,"
        "${SpecificationSupplierColumn.SPECIFICATION_SUPPLIER_ID} INTEGER)");

    db.execute("CREATE TABLE ${DBTables.SPECIFICATION_SUPPLIER_GTIN} ("
        "${SpecificationSupplierGtinColumn.SPECIFICATION_SUPPLIER_ID} INTEGER,"
        "${SpecificationSupplierGtinColumn.GTIN} CHAR)");

    db.execute(
        "CREATE TABLE ${DBTables.MATERIAL_SPECIFICATION} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT,"
        "${MaterialSpecificationColumn.NUMBER_SPECIFICATION} CHAR,"
        "${MaterialSpecificationColumn.VERSION_SPECIFICATION} CHAR,"
        "${MaterialSpecificationColumn.GRADE_ID} INTEGER,"
        "${MaterialSpecificationColumn.STATUS} CHAR)");

    db.execute(
        "CREATE TABLE ${DBTables.SPECIFICATION_GRADE_TOLERANCE} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT,"
        "${SpecificationGradeToleranceColumn.SPECIFICATION_GRADE_TOLERANCE_ID} INTEGER NOT NULL,"
        "${SpecificationGradeToleranceColumn.NUMBER_SPECIFICATION} CHAR,"
        "${SpecificationGradeToleranceColumn.VERSION_SPECIFICATION} CHAR,"
        "${SpecificationGradeToleranceColumn.SEVERITY_DEFECT_ID} INTEGER,"
        "${SpecificationGradeToleranceColumn.DEFECT_ID} INTEGER,"
        "${SpecificationGradeToleranceColumn.GRADE_TOLERANCE_PERCENTAGE} DECIMAL,"
        "${SpecificationGradeToleranceColumn.OVERRIDDEN} BOOLEAN,"
        "${SpecificationGradeToleranceColumn.DEFECT_NAME} CHAR,"
        "${SpecificationGradeToleranceColumn.DEFECT_CATEGORY_NAME} CHAR,"
        "${SpecificationGradeToleranceColumn.SEVERITY_DEFECT_NAME} CHAR)");

    db.execute(
        "CREATE TABLE ${DBTables.SPECIFICATION_ANALYTICAL} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT,"
        "${SpecificationAnalyticalColumn.NUMBER_SPECIFICATION} CHAR,"
        "${SpecificationAnalyticalColumn.VERSION_SPECIFICATION} CHAR,"
        "${SpecificationAnalyticalColumn.ANALYTICAL_ID} INTEGER,"
        "${SpecificationAnalyticalColumn.ANALYTICAL_NAME} CHAR,"
        "${SpecificationAnalyticalColumn.SPEC_MIN} DECIMAL,"
        "${SpecificationAnalyticalColumn.SPEC_MAX} DECIMAL,"
        "${SpecificationAnalyticalColumn.TARGET_NUM_VALUE} DECIMAL,"
        "${SpecificationAnalyticalColumn.TARGET_TEXT_VALUE} CHAR,"
        "${SpecificationAnalyticalColumn.UOM_NAME} CHAR,"
        "${SpecificationAnalyticalColumn.TYPE_ENTRY} INTEGER,"
        "${SpecificationAnalyticalColumn.DESCRIPTION} CHAR,"
        "${SpecificationAnalyticalColumn.ORDER_NO} INTEGER,"
        "${SpecificationAnalyticalColumn.PICTURE_REQUIRED} CHAR,"
        "${SpecificationAnalyticalColumn.TARGET_TEXT_DEFAULT} CHAR,"
        "${SpecificationAnalyticalColumn.INSPECTION_RESULT} CHAR)");

    db.execute("CREATE TABLE ${DBTables.AGENCY}  "
        "(${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
        "${AgencyColumn.ID} INTEGER NOT NULL, "
        "${AgencyColumn.NAME} CHAR)");

    db.execute("CREATE TABLE ${DBTables.GRADE}  "
        "(${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
        "${GradeColumn.ID} INTEGER NOT NULL, "
        "${GradeColumn.NAME} CHAR, "
        "${GradeColumn.AGENCY_ID} INTEGER )");

    db.execute("CREATE TABLE ${DBTables.GRADE_COMMODITY} "
        "(${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
        "${GradeCommodityColumn.ID} INTEGER NOT NULL, "
        "${GradeCommodityColumn.AGENCY_ID} INTEGER, "
        "${GradeCommodityColumn.COMMODITY_ID} INTEGER )");

    db.execute("CREATE TABLE ${DBTables.GRADE_COMMODITY_DETAIL}"
        " (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
        "${GradeCommodityDetailColumn.ID} INTEGER NOT NULL, "
        "${GradeCommodityDetailColumn.GRADE_ID} INTEGER, "
        "${GradeCommodityDetailColumn.GRADE_COMMODITY_ID} INTEGER, "
        "${GradeCommodityDetailColumn.STATUS} CHAR, "
        "${GradeCommodityDetailColumn.SORT_SEQUENCE_FIELD} INTEGER )");

    db.execute("CREATE TABLE ${DBTables.GRADE_COMMODITY_TOLERANCE}"
        " (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, "
        "${GradeCommodityToleranceColumn.SEVERITY_DEFECT_ID} INTEGER, "
        "${GradeCommodityToleranceColumn.DEFECT_ID} INTEGER, "
        "${GradeCommodityToleranceColumn.GRADE_TOLERANCE_PERCENTAGE} DECIMAL, "
        "${GradeCommodityToleranceColumn.GRADE_COMMODITY_DETAIL_ID} INTEGER)");

    db.execute(
        "CREATE TABLE ${DBTables.SPECIFICATION_ATTRIBUTES} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT,"
        "${SpecificationAttributesColumn.INSPECTION_ID} INTEGER NOT NULL,"
        "${SpecificationAttributesColumn.ANALYTICAL_ID} INTEGER,"
        "${SpecificationAttributesColumn.COMPLY} CHAR,"
        "${SpecificationAttributesColumn.SAMPLE_TEXT_VALUE} CHAR,"
        "${SpecificationAttributesColumn.SAMPLE_VALUE} INTEGER,"
        "${SpecificationAttributesColumn.COMMENT} CHAR,"
        "${SpecificationAttributesColumn.ANALYTICAL_NAME} CHAR,"
        "${SpecificationAttributesColumn.PICTURE_REQUIRED} BOOLEAN,"
        "${SpecificationAttributesColumn.INSPECTION_RESULT} CHAR )");

    db.execute(
        "CREATE TABLE ${DBTables.TEMP_TRAILER_TEMPERATURE} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT,"
        "${TempTrailerTemperatureColumn.PARTNER_ID} INTEGER NOT NULL,"
        "${TempTrailerTemperatureColumn.LOCATION} CHAR,"
        "${TempTrailerTemperatureColumn.LEVEL} CHAR,"
        "${TempTrailerTemperatureColumn.VALUE} INTEGER,"
        "${TempTrailerTemperatureColumn.COMPLETE} INTEGER,"
        "${TempTrailerTemperatureColumn.PO_NUMBER} CHAR )");

    db.execute(
        "CREATE TABLE ${DBTables.PARTNER_ITEMSKU} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT,"
        "${PartnerItemSkuColumn.PARTNER_ID} INTEGER NOT NULL,"
        "${PartnerItemSkuColumn.ITEM_SKU} CHAR,"
        "${PartnerItemSkuColumn.LOT_NO} CHAR,"
        "${PartnerItemSkuColumn.PACK_DATE} CHAR,"
        "${PartnerItemSkuColumn.INSPECTION_ID} INTEGER,"
        "${PartnerItemSkuColumn.COMPLETE} CHAR,"
        "${PartnerItemSkuColumn.LOT_SIZE} CHAR,"
        "${PartnerItemSkuColumn.UNIQUE_ID} CHAR,"
        "${PartnerItemSkuColumn.PO_LINE_NO} INTEGER,"
        "${PartnerItemSkuColumn.PO_NO} CHAR )");

    db.execute(
        "CREATE TABLE ${DBTables.SPECIFICATION_PACKAGING_FINISHED_GOODS} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT,"
        "${SpecificationPackagingFinishedGoodsColumn.FINISHED_GOODS_ID} INTEGER NOT NULL,"
        "${SpecificationPackagingFinishedGoodsColumn.NUMBER_SPECIFICATION} CHAR,"
        "${SpecificationPackagingFinishedGoodsColumn.VERSION_SPECIFICATION} CHAR,"
        "${SpecificationPackagingFinishedGoodsColumn.ITEM_SKU_ID} INTEGER)");

    db.execute("CREATE TABLE ${DBTables.COMMODITY} "
        "(${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
        "${CommodityColumn.ID} INTEGER NOT NULL, "
        "${CommodityColumn.NAME} CHAR, "
        "${CommodityColumn.SAMPLE_SIZE_BY_COUNT} INTEGER, "
        "${CommodityColumn.KEYWORDS} CHAR)");

    db.execute("CREATE TABLE ${DBTables.COMMODITY_CTE} "
        "(${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
        "${CommodityCteColumn.ID} INTEGER NOT NULL, "
        "${CommodityCteColumn.NAME} CHAR, "
        "${CommodityCteColumn.SAMPLE_SIZE_BY_COUNT} INTEGER, "
        "${CommodityCteColumn.KEYWORDS} CHAR)");

    db.execute(
        "CREATE TABLE ${DBTables.SPECIFICATION_TYPE} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT,"
        "${SpecificationTypeColumn.SPECIFICATION_TYPE_ID} INTEGER NOT NULL,"
        "${SpecificationTypeColumn.NAME} CHAR)");

    db.execute(
        "CREATE TABLE ${DBTables.TRAILER_TEMPERATURE_DETAILS} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT,"
        "${TrailerTemperatureDetailsColumn.PARTNER_ID} INTEGER NOT NULL,"
        "${TrailerTemperatureDetailsColumn.TEMP_OPEN1} CHAR,"
        "${TrailerTemperatureDetailsColumn.TEMP_OPEN2} CHAR,"
        "${TrailerTemperatureDetailsColumn.TEMP_OPEN3} CHAR,"
        "${TrailerTemperatureDetailsColumn.COMMENTS} CHAR,"
        "${TrailerTemperatureDetailsColumn.PO_NUMBER} CHAR )");

    db.execute(
        "CREATE TABLE ${DBTables.TEMP_TRAILER_TEMPERATURE_DETAILS} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT,"
        "${TempTrailerTemperatureDetailsColumn.PARTNER_ID} INTEGER NOT NULL,"
        "${TempTrailerTemperatureDetailsColumn.TEMP_OPEN1} CHAR,"
        "${TempTrailerTemperatureDetailsColumn.TEMP_OPEN2} CHAR,"
        "${TempTrailerTemperatureDetailsColumn.TEMP_OPEN3} CHAR,"
        "${TempTrailerTemperatureDetailsColumn.COMMENTS} CHAR,"
        "${TempTrailerTemperatureDetailsColumn.PO_NUMBER} CHAR )");

    db.execute(
        "CREATE TABLE ${DBTables.QC_HEADER_DETAILS} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT,"
        "${QcHeaderDetailsColumn.INSPECTION_ID} INTEGER NOT NULL,"
        "${QcHeaderDetailsColumn.PO_NUMBER} CHAR,"
        "${QcHeaderDetailsColumn.SEAL_NUMBER} CHAR,"
        "${QcHeaderDetailsColumn.QCH_OPEN1} CHAR,"
        "${QcHeaderDetailsColumn.QCH_OPEN2} CHAR,"
        "${QcHeaderDetailsColumn.QCH_OPEN3} CHAR,"
        "${QcHeaderDetailsColumn.QCH_OPEN4} CHAR,"
        "${QcHeaderDetailsColumn.QCH_OPEN5} CHAR,"
        "${QcHeaderDetailsColumn.QCH_OPEN6} CHAR,"
        "${QcHeaderDetailsColumn.QCH_OPEN9} CHAR,"
        "${QcHeaderDetailsColumn.QCH_OPEN10} CHAR,"
        "${QcHeaderDetailsColumn.QCH_TRUCK_TEMP_OK} CHAR )");

    db.execute(
        "CREATE TABLE ${DBTables.TEMP_QC_HEADER_DETAILS} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT,"
        "${TempQcHeaderDetailsColumn.PARTNER_ID} INTEGER NOT NULL,"
        "${TempQcHeaderDetailsColumn.PO_NUMBER} CHAR,"
        "${TempQcHeaderDetailsColumn.SEAL_NUMBER} CHAR,"
        "${TempQcHeaderDetailsColumn.QCH_OPEN1} CHAR,"
        "${TempQcHeaderDetailsColumn.QCH_OPEN2} CHAR,"
        "${TempQcHeaderDetailsColumn.QCH_OPEN3} CHAR,"
        "${TempQcHeaderDetailsColumn.QCH_OPEN4} CHAR,"
        "${TempQcHeaderDetailsColumn.QCH_OPEN5} CHAR,"
        "${TempQcHeaderDetailsColumn.QCH_OPEN6} CHAR,"
        "${TempQcHeaderDetailsColumn.QCH_OPEN9} CHAR,"
        "${TempQcHeaderDetailsColumn.QCH_OPEN10} CHAR,"
        "${TempQcHeaderDetailsColumn.TRUCK_TEMP_OK} CHAR,"
        "${TempQcHeaderDetailsColumn.PRODUCT_TRANSFER} CHAR,"
        "${TempQcHeaderDetailsColumn.CTE_TYPE} CHAR )");

    db.execute(
        "CREATE TABLE ${DBTables.SELECTED_ITEM_SKU_LIST} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT,"
        "${SelectedItemSkuListColumn.SKU_ID} INTEGER NOT NULL,"
        "${SelectedItemSkuListColumn.UNIQUE_ITEM_ID} INTEGER,"
        "${SelectedItemSkuListColumn.PO_NUMBER} CHAR,"
        "${SelectedItemSkuListColumn.LOT_NUMBER} CHAR,"
        "${SelectedItemSkuListColumn.SKU_CODE} CHAR,"
        "${SelectedItemSkuListColumn.SKU_NAME} CHAR,"
        "${SelectedItemSkuListColumn.COMMODITY_NAME} CHAR,"
        "${SelectedItemSkuListColumn.COMMODITY_ID} INTEGER,"
        "${SelectedItemSkuListColumn.DESCRIPTION} CHAR,"
        "${SelectedItemSkuListColumn.INSPECTION_ID} INTEGER,"
        "${SelectedItemSkuListColumn.COMPLETE} CHAR,"
        "${SelectedItemSkuListColumn.PARTNER_ID} INTEGER,"
        "${SelectedItemSkuListColumn.PARTIAL_COMPLETE} CHAR,"
        "${SelectedItemSkuListColumn.PACK_DATE} CHAR,"
        "${SelectedItemSkuListColumn.GTIN} CHAR,"
        "${SelectedItemSkuListColumn.PARTNER_NAME} CHAR,"
        "${SelectedItemSkuListColumn.FTL} CHAR,"
        "${SelectedItemSkuListColumn.BRANDED} CHAR,"
        "${SelectedItemSkuListColumn.DATE_TYPE} CHAR )");

    db.execute(
        "CREATE TABLE ${DBTables.RESULT_REJECTION_DETAILS} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT,"
        "${ResultRejectionDetailsColumn.INSPECTION_ID} INTEGER NOT NULL,"
        "${ResultRejectionDetailsColumn.RESULT} CHAR,"
        "${ResultRejectionDetailsColumn.RESULT_REASON} CHAR,"
        "${ResultRejectionDetailsColumn.DEFECT_COMMENTS} CHAR )");

    db.execute("CREATE TABLE ${DBTables.COMMODITY_KEYWORDS} "
        "(${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
        "${CommodityKeywordsColumn.ID} INTEGER NOT NULL, "
        "${CommodityKeywordsColumn.KEYWORDS} CHAR)");

    db.execute("CREATE TABLE ${DBTables.PO_HEADER}"
        "(${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, "
        "${POHeaderColumn.PO_HEADER_ID} CHAR NOT NULL, "
        "${POHeaderColumn.PO_NUMBER} CHAR, "
        "${POHeaderColumn.PO_DELIVER_TO_ID} INTEGER, "
        "${POHeaderColumn.PO_DELIVER_TO_NAME} CHAR, "
        "${POHeaderColumn.PO_PARTNER_ID} INTEGER, "
        "${POHeaderColumn.PO_PARTNER_NAME} CHAR )");

    db.execute("CREATE TABLE ${DBTables.PO_DETAIL} "
        "(${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, "
        "${PODetailColumn.PO_DETAIL_ID} CHAR NOT NULL, "
        "${PODetailColumn.PO_HEADER_ID} CHAR, "
        "${PODetailColumn.PO_DETAIL_NUMBER} CHAR, "
        "${PODetailColumn.PO_DELIVER_TO_ID} INTEGER, "
        "${PODetailColumn.PO_DELIVER_TO_NAME} CHAR, "
        "${PODetailColumn.PO_LINE_NUMBER} INTEGER, "
        "${PODetailColumn.PO_ITEM_SKU_ID} INTEGER, "
        "${PODetailColumn.PO_ITEM_SKU_CODE} CHAR, "
        "${PODetailColumn.PO_ITEM_SKU_NAME} CHAR, "
        "${PODetailColumn.PO_QUANTITY} INTEGER, "
        "${PODetailColumn.PO_QTY_UOM_ID} INTEGER, "
        "${PODetailColumn.PO_QTY_UOM_NAME} CHAR, "
        "${PODetailColumn.PO_NUMBER_SPEC} CHAR, "
        "${PODetailColumn.PO_VERSION_SPEC} CHAR, "
        "${PODetailColumn.PO_COMMODITY_ID} INTEGER, "
        "${PODetailColumn.PO_COMMODITY_NAME} CHAR )");
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (newVersion > oldVersion) {
      // Handle upgrades if needed
    }

    /// Drop existing tables one by one using forEach
    DataTables.values.forEach((table) async {
      await db.execute("DROP TABLE IF EXISTS ${table.name}");
    });

    // Recreate the database
    await _onCreate(db, newVersion);
  }

  Future<void> close() async {
    var dbClient = await instance.database;
    dbClient.close();
  }

  Future<void> deleteTable(String tableName) async {
    var dbClient = await instance.database;
    await dbClient.execute("DROP TABLE IF EXISTS $tableName");
  }

  Future<void> deleteAllTables() async {
    var db = await instance.database;

    /// Drop existing tables one by one using forEach
    DataTables.values.forEach((table) async {
      await db.execute("DROP TABLE IF EXISTS ${table.name}");
    });
  }
}

final class BaseColumns {
  BaseColumns();

  static const String ID = "_id";
  static const String COUNT = "count";
}
