import 'dart:async';

import 'package:path/path.dart';
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
        "User_Name CHAR NOT NULL, "
        "Login_Time INTEGER, "
        "Language CHAR )");

    db.execute("CREATE TABLE ${DBTables.USER_OFFLINE} (${BaseColumns.ID} "
        "INTEGER PRIMARY KEY AUTOINCREMENT, "
        "User_ID CHAR NOT NULL, "
        "Access CHAR NOT NULL, "
        "EnterpriseId INTEGER, "
        "Status CHAR, "
        "IsSubscriptionExpired CHAR, "
        "Supplier_Id INTEGER, "
        "Headquater_Supplier_Id INTEGER, "
        "GtinScanning CHAR )");

    db.execute("CREATE TABLE ${DBTables.INSPECTION} (${BaseColumns.ID} "
        "INTEGER PRIMARY KEY AUTOINCREMENT, "
        "User_ID INTEGER NOT NULL, "
        "Partner_ID INTEGER, "
        "Carrier_ID INTEGER, "
        "Commodity_ID INTEGER, "
        "Variety_ID INTEGER, "
        "Variety_Name CHAR, "
        "Created_Time INTEGER, "
        "Result CHAR, "
        "Manager_Status CHAR, "
        "Manager_Comment CHAR, "
        "Status CHAR, "
        "Complete CHAR, "
        "Grade_ID INTEGER, "
        "Download_ID INTEGER, "
        "UploadStatus INTEGER, "
        "Completed_Time INTEGER, "
        "Specification_Name CHAR, "
        "Specification_Version CHAR, "
        "Specification_Number CHAR, "
        "Specification_TypeName CHAR, "
        "Lot_No CHAR, PackDate CHAR, "
        "Sample_Size_By_Count INTEGER, "
        "Item_SKU CHAR, "
        "Item_SKU_Id INTEGER, "
        "Commodity_Name CHAR, "
        "PO_Number CHAR, "
        "InspectionServerID INTEGER, "
        "Rating INTEGER, "
        "POLineNo INTEGER, "
        "Partner_Name CHAR, "
        "To_Location_ID INTEGER, "
        "To_Location_Name CHAR, "
        "Cte_Type CHAR, "
        "Item_Sku_Name CHAR )");

    db.execute(
        "CREATE TABLE ${DBTables.INSPECTION_ATTACHMENT} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, Inspection_ID INTEGER NOT NULL, Attachment_ID, Attachment_Title, Created_Time INTEGER, "
        "File_Location CHAR )");

    db.execute(
        "CREATE TABLE ${DBTables.INSPECTION_SAMPLE} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, Inspection_ID INTEGER NOT NULL, Set_Size INTEGER, Set_Name CHAR, Set_Number INTEGER, Created_Time INTEGER, Last_Updated_Time INTEGER, complete INTEGER, Sample_Name CHAR )");

    db.execute(
        "CREATE TABLE ${DBTables.INSPECTION_DEFECT} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, Inspection_ID INTEGER NOT NULL, Inspection_Sample_ID INTEGER NOT NULL, Defect_ID INTEGER, Defect_Name CHAR, Injury_Cnt INTEGER, Damage_Cnt INTEGER, Serious_Damage_Cnt INTEGER, Comments CHAR, Created_Time INTEGER, Last_Updated_Time INTEGER, IDT_Complete INTEGER, Very_Serious_Damage_Cnt INTEGER, Decay_Cnt INTEGER, Injury_Id INTEGER, Damage_Id INTEGER, Serious_Damage_Id INTEGER, Very_Serious_Damage_Id  INTEGER, Decay_Id INTEGER, Defect_Category CHAR )");

    db.execute(
        "CREATE TABLE ${DBTables.INSPECTION_DEFECT_ATTACHMENT} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, Inspection_ID INTEGER NOT NULL, Inspection_Sample_ID INTEGER NOT NULL, Inspection_Defect_ID INTEGER NOT NULL, Created_Time INTEGER, File_Location CHAR, Defect_Saved CHAR DEFAULT ('N') )");

    db.execute(
        "CREATE TABLE ${DBTables.TRAILER_TEMPERATURE} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, Inspection_ID INTEGER NOT NULL, Location CHAR, Level CHAR, value INTEGER, complete INTEGER, po_number CHAR )");

    db.execute(
        "CREATE TABLE ${DBTables.QUALITY_CONTROL} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, Inspection_ID INTEGER NOT NULL, Brand_ID INTEGER,Origin_ID INTEGER,Qty_Shipped INTEGER,UOM_Qty_ShippedID INTEGER,PO_No CHAR,Pulp_Temp_Min INTEGER,Pulp_Temp_Max INTEGER,Recorder_Temp_Min INTEGER,Recorder_Temp_Max INTEGER,Seal CHAR,RPC CHAR,Claim_Filed_Against CHAR,Qty_Rejected INTEGER,UOM_Qty_Rejected_ID INTEGER,Reason_ID INTEGER,QC_Comments CHAR,Qty_Received INTEGER,UOM_Qty_Received INTEGER,Is_Complete INTEGER,Specification_Name CHAR,Lot_Number CHAR, Pack_Date CHAR, QCDOPEN1 CHAR, QCDOPEN2 CHAR, QCDOPEN3 CHAR, QCDOPEN4 CHAR, QCDOPEN5 CHAR, GTIN CHAR, Lot_Size INTEGER, Ship_Date CHAR, Date_Type CHAR )");

    db.execute(
        "CREATE TABLE ${DBTables.OVERRIDDEN_RESULT} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, Inspection_ID INTEGER NOT NULL, Overridden_By INTEGER, Overridden_Result CHAR, Overridden_Timestamp INTEGER, Overridden_Comments CHAR, Old_Result CHAR, Original_Qty_Shipped INTEGER, Original_Qty_Rejected INTEGER, New_Qty_Shipped INTEGER, New_Qty_Rejected INTEGER )");

    db.execute(
        "CREATE TABLE ${DBTables.INSPECTION_SPECIFICATION} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, Inspection_ID INTEGER NOT NULL, Specification_Number CHAR, Specification_Version CHAR, Specification_Name CHAR)");

    db.execute(
        "CREATE TABLE ${DBTables.ITEM_SKU} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, SKU_ID INTEGER NOT NULL, Code CHAR,Commodity_ID INTEGER,Name CHAR,Description CHAR,Status CHAR,ItemGroup1_ID INTEGER,ItemGroup2_ID INTEGER,GradeID INTEGER,Packaging_ID INTEGER,Usage_Type CHAR,Commodity_Category_ID INTEGER,Item_Type CHAR, Global_Partner_Id INTEGER, Company_Id INTEGER, Division_Id INTEGER, Branded CHAR, FTL CHAR )");

    db.execute(
        "CREATE TABLE ${DBTables.ITEM_GROUP1} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, Group1_ID INTEGER NOT NULL, Name CHAR,Commodity_ID INTEGER)");

    db.execute(
        "CREATE TABLE ${DBTables.SPECIFICATION} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, Number CHAR,Version CHAR,Name CHAR,Item_Group1_ID INTEGER,Commodity_ID INTEGER,Specification_Type_ID INTEGER)");

    db.execute(
        "CREATE TABLE ${DBTables.SPECIFICATION_SUPPLIER} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, Number_Specification CHAR,Version_Specification CHAR,Supplier_ID INTEGER,Negotiation_Status CHAR,Status CHAR,Item_SKU_ID INTEGER,Gtin CHAR,Specification_Supplier_ID INTEGER)");

    db.execute(
        "CREATE TABLE ${DBTables.SPECIFICATION_SUPPLIER_GTIN} (Specification_Supplier_ID INTEGER,Gtin CHAR)");

    db.execute(
        "CREATE TABLE ${DBTables.MATERIAL_SPECIFICATION} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, Number_Specification CHAR,Version_Specification CHAR,Grade_ID INTEGER,Status CHAR)");

    db.execute(
        "CREATE TABLE ${DBTables.SPECIFICATION_GRADE_TOLERANCE} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, Specification_Grade_Tolerance_ID INTEGER NOT NULL,Number_Specification CHAR,Version_Specification CHAR,Severity_Defect_ID INTEGER,Defect_ID INTEGER,Grade_Tolerance_Percentage DECIMAL,Overridden BOOLEAN,Defect_Name CHAR,Defect_Category_Name CHAR,Severity_Defect_Name CHAR)");

    db.execute(
        "CREATE TABLE ${DBTables.SPECIFICATION_ANALYTICAL} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, Number_Specification CHAR,Version_Specification CHAR,Analytical_ID INTEGER,Analytical_name CHAR,Spec_Min DECIMAL,Spec_Max DECIMAL,Target_Num_Value DECIMAL,Target_Text_Value CHAR,UOM_Name CHAR,Type_Entry INTEGER,Description CHAR,OrderNo INTEGER,Picture_Required CHAR,Target_Text_Default CHAR,Inspection_Result CHAR)");

    db.execute("CREATE TABLE ${DBTables.AGENCY}  "
        "(${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
        "ID INTEGER NOT NULL, "
        "Name CHAR)");

    db.execute("CREATE TABLE ${DBTables.GRADE}  "
        "(${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
        "ID INTEGER NOT NULL, "
        "Name CHAR, "
        "Agency_ID INTEGER )");

    db.execute("CREATE TABLE ${DBTables.GRADE_COMMODITY} "
        " (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
        "ID INTEGER NOT NULL, "
        "Agency_ID INTEGER, "
        "Commodity_ID INTEGER )");

    db.execute("CREATE TABLE ${DBTables.GRADE_COMMODITY_DETAIL}"
        "  (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
        "ID INTEGER NOT NULL, "
        "Grade_ID INTEGER, "
        "Grade_Commodity_ID INTEGER, "
        "Status CHAR, "
        "SORT_SEQUENCE_FIELD INTEGER )");

    db.execute("CREATE TABLE ${DBTables.GRADE_COMMODITY_TOLERANCE}"
        "  (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, "
        "Severity_Defect_ID INTEGER, "
        "Defect_ID INTEGER, "
        "Grade_Tolerance_Percentage DECIMAL, "
        "Grade_Commodity_Detail_ID INTEGER)");

    db.execute(
        "CREATE TABLE ${DBTables.SPECIFICATION_ATTRIBUTES} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, Inspection_ID INTEGER NOT NULL, Analytical_ID INTEGER,Comply CHAR,Sample_Text_Value CHAR,Sample_Value INTEGER,Comment CHAR,Analytical_Name CHAR,Picture_Required BOOLEAN, Inspection_Result CHAR )");

    db.execute(
        "CREATE TABLE ${DBTables.TEMP_TRAILER_TEMPERATURE} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, Partner_ID INTEGER NOT NULL, Location CHAR, Level CHAR, value INTEGER, complete INTEGER, po_number CHAR )");

    db.execute(
        "CREATE TABLE ${DBTables.PARTNER_ITEMSKU} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, Partner_ID INTEGER NOT NULL, ItemSKU CHAR, LotNo CHAR, PackDate CHAR, Inspection_ID INTEGER, Complete CHAR, LotSize CHAR, Unique_Id CHAR, POLineNo INTEGER, PoNo CHAR )");

    db.execute(
        "CREATE TABLE ${DBTables.SPECIFICATION_PACKAGING_FINISHED_GOODS} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, Finished_Goods_ID INTEGER NOT NULL, Number_Specification CHAR,Version_Specification CHAR,Item_SKU_ID INTEGER)");

    db.execute("CREATE TABLE ${DBTables.COMMODITY} "
        " (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
        "ID INTEGER NOT NULL, "
        "Name CHAR, "
        "Sample_Size_By_Count INTEGER, "
        "Keywords CHAR)");

    db.execute("CREATE TABLE ${DBTables.COMMODITY_CTE} "
        " (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
        "ID INTEGER NOT NULL, "
        "Name CHAR, "
        "Sample_Size_By_Count INTEGER, "
        "Keywords CHAR)");

    db.execute(
        "CREATE TABLE ${DBTables.SPECIFICATION_TYPE} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, Specification_Type_ID INTEGER NOT NULL, Name CHAR)");

    db.execute(
        "CREATE TABLE ${DBTables.TRAILER_TEMPERATURE_DETAILS} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, Partner_ID INTEGER NOT NULL, TempOpen1 CHAR, TempOpen2 CHAR, TempOpen3 CHAR, Comments CHAR, po_number CHAR )");

    db.execute(
        "CREATE TABLE ${DBTables.TEMP_TRAILER_TEMPERATURE_DETAILS} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, Partner_ID INTEGER NOT NULL, TempOpen1 CHAR, TempOpen2 CHAR, TempOpen3 CHAR, Comments CHAR, po_number CHAR )");

    db.execute(
        "CREATE TABLE ${DBTables.QC_HEADER_DETAILS} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, Inspection_ID INTEGER NOT NULL, PO_number CHAR, Seal_number CHAR, QCHOpen1 CHAR, QCHOpen2 CHAR, QCHOpen3 CHAR, QCHOpen4 CHAR, QCHOpen5 CHAR, QCHOpen6 CHAR, QCHOpen9 CHAR, QCHOpen10 CHAR, QCHTruckTempOk CHAR )");

    db.execute(
        "CREATE TABLE ${DBTables.TEMP_QC_HEADER_DETAILS} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, Partner_ID INTEGER NOT NULL, PO_number CHAR, Seal_number CHAR, QCHOpen1 CHAR, QCHOpen2 CHAR, QCHOpen3 CHAR, QCHOpen4 CHAR, QCHOpen5 CHAR, QCHOpen6 CHAR, QCHOpen9 CHAR, QCHOpen10 CHAR, TruckTempOk CHAR, ProductTransfer CHAR, CteType CHAR )");

    db.execute(
        "CREATE TABLE ${DBTables.SELECTED_ITEM_SKU_LIST} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, SKU_ID INTEGER NOT NULL, Unique_Item_ID INTEGER, PO_number CHAR, Lot_number CHAR, SKU_Code CHAR, SKU_Name CHAR, Commodity_Name CHAR, Commodity_Id INTEGER, Description CHAR, Inspection_ID INTEGER, Complete CHAR, Partner_ID INTEGER, Partial_Complete CHAR, PackDate CHAR, GTIN CHAR, PartnerName CHAR, FTL CHAR, Branded CHAR, DateType CHAR )");

    db.execute(
        "CREATE TABLE ${DBTables.RESULT_REJECTION_DETAILS} (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, Inspection_ID INTEGER NOT NULL, Result CHAR, Result_Reason CHAR, Defect_Comments CHAR )");

    db.execute("CREATE TABLE ${DBTables.COMMODITY_KEYWORDS} "
        " (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
        "ID INTEGER NOT NULL, "
        "Keywords CHAR)");

    db.execute("CREATE TABLE ${DBTables.PO_HEADER}"
        " (${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, "
        "PO_Header_ID CHAR NOT NULL, "
        "PO_Number CHAR, "
        "PO_Deliver_To_Id INTEGER, "
        "PO_Deliver_To_Name CHAR, "
        "PO_Partner_Id INTEGER, "
        "PO_Partner_Name CHAR )");

    db.execute("CREATE TABLE ${DBTables.PO_DETAIL} "
        "(${BaseColumns.ID} INTEGER PRIMARY KEY AUTOINCREMENT, "
        "PO_Detail_ID CHAR NOT NULL, "
        "PO_Header_ID CHAR, "
        "PO_Detail_Number CHAR, "
        "PO_Deliver_To_Id INTEGER, "
        "PO_Deliver_To_Name CHAR, "
        "PO_Line_Number INTEGER, "
        "PO_Item_Sku_Id INTEGER, "
        "PO_Item_Sku_Code CHAR, "
        "PO_Item_Sku_Name CHAR, "
        "PO_Quantity INTEGER, "
        "PO_Qty_UOM_Id INTEGER, "
        "PO_Qty_UOM_Name CHAR, "
        "PO_Number_Spec CHAR, "
        "PO_Version_Spec CHAR, "
        "PO_Commodity_Id INTEGER, "
        "PO_Commodity_Name CHAR )");
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
