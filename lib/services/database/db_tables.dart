// ignore_for_file: constant_identifier_names

final class DBTables {
  DBTables();

  static const USER = "User";
  static const DUMMY = "DUMMY";
  static const USER_OFFLINE = "UserOffline";
  static const INSPECTION = "Inspection";
  static const INSPECTION_ATTACHMENT = "Inspection_Attachment";
  static const INSPECTION_SAMPLE = "Inspection_Sample";
  static const INSPECTION_DEFECT = "Inspection_Defect";
  static const INSPECTION_DEFECT_ATTACHMENT = "Inspection_Defect_Attachment";
  static const TRAILER_TEMPERATURE = "Trailer_Temperature";
  static const QUALITY_CONTROL = "Quality_Control";
  static const OVERRIDDEN_RESULT = "Overridden_Result";
  static const INSPECTION_SPECIFICATION = "Inspection_Specification";
  static const ITEM_SKU = "Item_SKU";
  static const ITEM_GROUP1 = "ItemGroup1";
  static const SPECIFICATION = "Specification";
  static const SPECIFICATION_SUPPLIER = "Specification_Supplier";
  static const MATERIAL_SPECIFICATION = "Material_Specification";
  static const SPECIFICATION_GRADE_TOLERANCE = "Specification_Grade_Tolerance";
  static const AGENCY = "Agency";
  static const GRADE = "Grade";
  static const GRADE_COMMODITY = "Grade_Commodity";
  static const GRADE_COMMODITY_DETAIL = "Grade_Commodity_Detail";
  static const GRADE_COMMODITY_TOLERANCE = "Grade_Commodity_Tolerance";
  static const SPECIFICATION_ATTRIBUTES = "Specification_Attributes";
  static const SPECIFICATION_ANALYTICAL = "Specification_Analytical";
  static const TRAILER_TEMPERATURE_DETAILS = "Trailer_Temperature_Details";
  static const TEMP_TRAILER_TEMPERATURE_DETAILS =
      "Temp_Trailer_Temperature_Details";
  static const QC_HEADER_DETAILS = "QC_Header_Details";
  static const TEMP_QC_HEADER_DETAILS = "Temp_QC_Header_Details";
  static const SELECTED_ITEM_SKU_LIST = "Selected_Item_SKU_List";
  static const TEMP_TRAILER_TEMPERATURE = "Temp_Trailer_Temperature";
  static const SPECIFICATION_PACKAGING_FINISHED_GOODS =
      "Specification_Packaging_Finished_Goods";
  static const PARTNER_ITEMSKU = "Partner_ItemSKU";
  static const COMMODITY = "Commodity";
  static const SPECIFICATION_TYPE = "Specification_Type";
  static const RESULT_REJECTION_DETAILS = "Result_Rejection_Details";
  static const COMMODITY_KEYWORDS = "Commodity_Keywords";
  static const PO_HEADER = "PO_Header";
  static const PO_DETAIL = "PO_Detail";
  static const SPECIFICATION_SUPPLIER_GTIN = "Specification_Supplier_GTIN";
  static const COMMODITY_CTE = "Commodity_CTE";
}

/// Enum for all the tables in the database
// FIXME: be careful with the name and order of the enum, it should be the same as the order of the tables in the database
enum DataTables {
  USER,
  USER_OFFLINE,
  INSPECTION,
  INSPECTION_ATTACHMENT,
  INSPECTION_SAMPLE,
  INSPECTION_DEFECT,
  INSPECTION_DEFECT_ATTACHMENT,
  TRAILER_TEMPERATURE,
  QUALITY_CONTROL,
  OVERRIDDEN_RESULT,
  INSPECTION_SPECIFICATION,
  ITEM_SKU,
  ITEM_GROUP1,
  SPECIFICATION,
  SPECIFICATION_SUPPLIER,
  MATERIAL_SPECIFICATION,
  SPECIFICATION_GRADE_TOLERANCE,
  AGENCY,
  GRADE,
  GRADE_COMMODITY,
  GRADE_COMMODITY_DETAIL,
  GRADE_COMMODITY_TOLERANCE,
  SPECIFICATION_ATTRIBUTES,
  SPECIFICATION_ANALYTICAL,
  TRAILER_TEMPERATURE_DETAILS,
  TEMP_TRAILER_TEMPERATURE_DETAILS,
  QC_HEADER_DETAILS,
  TEMP_QC_HEADER_DETAILS,
  SELECTED_ITEM_SKU_LIST,
  TEMP_TRAILER_TEMPERATURE,
  SPECIFICATION_PACKAGING_FINISHED_GOODS,
  PARTNER_ITEMSKU,
  COMMODITY,
  SPECIFICATION_TYPE,
  RESULT_REJECTION_DETAILS,
  COMMODITY_KEYWORDS,
  PO_HEADER,
  PO_DETAIL,
  SPECIFICATION_SUPPLIER_GTIN,
  COMMODITY_CTE;

  String get name => toString().split('.').last;

  static List<String> get tableNames =>
      DataTables.values.map((e) => e.name).toList();
}
