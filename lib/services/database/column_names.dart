// ignore_for_file: constant_identifier_names, unused_field

import 'package:pverify/services/database/database_helper.dart';

class UserColumn {
  static const String ID = BaseColumns.ID;
  static const String USER_NAME = 'User_Name';
  static const String PASSWORD = 'Password';
  static const String EMAIL = 'Email';
  static const String PHONE = 'Phone';
  static const String ADDRESS = 'Address';
  static const String CREATED_AT = 'Created_At';
  static const String UPDATED_AT = 'Updated_At';
  static const String LOGIN_TIME = 'Login_Time';
  static const String LANGUAGE = 'Language';
}

class UserOfflineColumn {
  static const String ID = BaseColumns.ID;
  static const String USER_ID = 'User_ID';
  static const String USER_NAME = 'User_Name';
  static const String ACCESS = 'Access';
  static const String ENTERPRISEID = 'EnterpriseId';
  static const String STATUS = 'Status';
  static const String IS_SUBSCRIPTION_EXPIRED = 'IsSubscriptionExpired';
  static const String SUPPLIER_ID = 'Supplier_Id';
  static const String HEADQUATER_SUPPLIER_ID = 'Headquater_Supplier_Id';
  static const String GTIN_SCANNING = 'GtinScanning';
}

class InspectionColumn {
  static const String ID = BaseColumns.ID;
  static const String TABLE_NAME = 'INSPECTION';
  static const String USER_ID = 'User_ID';
  static const String PARTNER_ID = 'Partner_ID';
  static const String CARRIER_ID = 'Carrier_ID';
  static const String COMMODITY_ID = 'Commodity_ID';
  static const String VARIETY_ID = 'Variety_ID';
  static const String VARIETY_NAME = 'Variety_Name';
  static const String CREATED_TIME = 'Created_Time';
  static const String RESULT = 'Result';
  static const String MANAGER_STATUS = 'Manager_Status';
  static const String MANAGER_COMMENT = 'Manager_Comment';
  static const String STATUS = 'Status';
  static const String COMPLETE = 'Complete';
  static const String GRADE_ID = 'Grade_ID';
  static const String DOWNLOAD_ID = 'Download_ID';
  static const String UPLOAD_STATUS = 'UploadStatus';
  static const String COMPLETED_TIME = 'Completed_Time';
  static const String SPECIFICATION_NAME = 'Specification_Name';
  static const String SPECIFICATION_VERSION = 'Specification_Version';
  static const String SPECIFICATION_NUMBER = 'Specification_Number';
  static const String SPECIFICATION_TYPENAME = 'Specification_TypeName';
  static const String LOT_NO = 'Lot_No';
  static const String PACK_DATE = 'PackDate';
  static const String SAMPLE_SIZE_BY_COUNT = 'Sample_Size_By_Count';
  static const String ITEM_SKU = 'Item_SKU';
  static const String ITEM_SKU_ID = 'Item_SKU_Id';
  static const String COMMODITY_NAME = 'Commodity_Name';
  static const String PO_NUMBER = 'PO_Number';
  static const String INSPECTION_SERVER_ID = 'InspectionServerID';
  static const String RATING = 'Rating';
  static const String POLINENO = 'POLineNo';
  static const String PARTNER_NAME = 'Partner_Name';
  static const String TO_LOCATION_ID = 'To_Location_ID';
  static const String TO_LOCATION_NAME = 'To_Location_Name';
  static const String CTE_TYPE = 'Cte_Type';
  static const String ITEM_SKU_NAME = 'Item_Sku_Name';
  static const String GTIN = 'GTIN';
}

class InspectionAttachmentColumn {
  static const String ID = BaseColumns.ID;
  static const String INSPECTION_ID = 'Inspection_ID';
  static const String ATTACHMENT_ID =
      'Attachment_ID'; // Ensure to define the appropriate data type in the database if missed
  static const String ATTACHMENT_TITLE = 'Attachment_Title';
  static const String CREATED_TIME = 'Created_Time';
  static const String FILE_LOCATION = 'File_Location';
}

class InspectionSampleColumn {
  static const String ID = BaseColumns.ID;
  static const String INSPECTION_ID = 'Inspection_ID';
  static const String SET_SIZE = 'Set_Size';
  static const String SET_NAME = 'Set_Name';
  static const String SET_NUMBER = 'Set_Number';
  static const String CREATED_TIME = 'Created_Time';
  static const String LAST_UPDATED_TIME = 'Last_Updated_Time';
  static const String COMPLETE = 'complete';
  static const String SAMPLE_NAME = 'Sample_Name';
}

class InspectionDefectColumn {
  static const String ID = BaseColumns.ID;
  static const String INSPECTION_ID = 'Inspection_ID';
  static const String INSPECTION_SAMPLE_ID = 'Inspection_Sample_ID';
  static const String DEFECT_ID = 'Defect_ID';
  static const String DEFECT_NAME = 'Defect_Name';
  static const String INJURY_CNT = 'Injury_Cnt';
  static const String DAMAGE_CNT = 'Damage_Cnt';
  static const String SERIOUS_DAMAGE_CNT = 'Serious_Damage_Cnt';
  static const String COMMENTS = 'Comments';
  static const String CREATED_TIME = 'Created_Time';
  static const String LAST_UPDATED_TIME = 'Last_Updated_Time';
  static const String IDT_COMPLETE = 'IDT_Complete';
  static const String VERY_SERIOUS_DAMAGE_CNT = 'Very_Serious_Damage_Cnt';
  static const String DECAY_CNT = 'Decay_Cnt';
  static const String INJURY_ID = 'Injury_Id';
  static const String DAMAGE_ID = 'Damage_Id';
  static const String SERIOUS_DAMAGE_ID = 'Serious_Damage_Id';
  static const String VERY_SERIOUS_DAMAGE_ID = 'Very_Serious_Damage_Id';
  static const String DECAY_ID = 'Decay_Id';
  static const String DEFECT_CATEGORY = 'Defect_Category';
}

class InspectionDefectAttachmentColumn {
  static const String ID = BaseColumns.ID;
  static const String ATTACHMENT_ID = 'Attachment_ID';
  static const String INSPECTION_ID = 'Inspection_ID';
  static const String INSPECTION_SAMPLE_ID = 'Inspection_Sample_ID';
  static const String INSPECTION_DEFECT_ID = 'Inspection_Defect_ID';
  static const String CREATED_TIME = 'Created_Time';
  static const String FILE_LOCATION = 'File_Location';
  static const String DEFECT_SAVED = 'Defect_Saved';
}

class TrailerTemperatureColumn {
  static const String ID = BaseColumns.ID;
  static const String INSPECTION_ID = 'Inspection_ID';
  static const String LOCATION = 'Location';
  static const String LEVEL = 'Level';
  static const String VALUE = 'value';
  static const String COMPLETE = 'complete';
  static const String PO_NUMBER = 'po_number';
}

class QualityControlColumn {
  static const String ID = BaseColumns.ID;
  static const String INSPECTION_ID = 'Inspection_ID';
  static const String BRAND_ID = 'Brand_ID';
  static const String ORIGIN_ID = 'Origin_ID';
  static const String QTY_SHIPPED = 'Qty_Shipped';
  static const String UOM_QTY_SHIPPED_ID = 'UOM_Qty_ShippedID';
  static const String PO_NO = 'PO_No';
  static const String PULP_TEMP_MIN = 'Pulp_Temp_Min';
  static const String PULP_TEMP_MAX = 'Pulp_Temp_Max';
  static const String RECORDER_TEMP_MIN = 'Recorder_Temp_Min';
  static const String RECORDER_TEMP_MAX = 'Recorder_Temp_Max';
  static const String SEAL = 'Seal';
  static const String RPC = 'RPC';
  static const String CLAIM_FILED_AGAINST = 'Claim_Filed_Against';
  static const String QTY_REJECTED = 'Qty_Rejected';
  static const String UOM_QTY_REJECTED_ID = 'UOM_Qty_Rejected_ID';
  static const String REASON_ID = 'Reason_ID';
  static const String QC_COMMENTS = 'QC_Comments';
  static const String QTY_RECEIVED = 'Qty_Received';
  static const String UOM_QTY_RECEIVED = 'UOM_Qty_Received';
  static const String IS_COMPLETE = 'Is_Complete';
  static const String SPECIFICATION_NAME = 'Specification_Name';
  static const String LOT_NUMBER = 'Lot_Number';
  static const String PACK_DATE = 'Pack_Date';
  static const String QCDOPEN1 = 'QCDOPEN1';
  static const String QCDOPEN2 = 'QCDOPEN2';
  static const String QCDOPEN3 = 'QCDOPEN3';
  static const String QCDOPEN4 = 'QCDOPEN4';
  static const String QCDOPEN5 = 'QCDOPEN5';
  static const String GTIN = 'GTIN';
  static const String LOT_SIZE = 'Lot_Size';
  static const String SHIP_DATE = 'Ship_Date';
  static const String DATE_TYPE = 'Date_Type';
}

class OverriddenResultColumn {
  static const String ID = BaseColumns.ID;
  static const String INSPECTION_ID = 'Inspection_ID';
  static const String OVERRIDDEN_BY = 'Overridden_By';
  static const String OVERRIDDEN_RESULT = 'Overridden_Result';
  static const String OVERRIDDEN_TIMESTAMP = 'Overridden_Timestamp';
  static const String OVERRIDDEN_COMMENTS = 'Overridden_Comments';
  static const String OLD_RESULT = 'Old_Result';
  static const String ORIGINAL_QTY_SHIPPED = 'Original_Qty_Shipped';
  static const String ORIGINAL_QTY_REJECTED = 'Original_Qty_Rejected';
  static const String NEW_QTY_SHIPPED = 'New_Qty_Shipped';
  static const String NEW_QTY_REJECTED = 'New_Qty_Rejected';
}

class InspectionSpecificationColumn {
  static const String ID = BaseColumns.ID;
  static const String INSPECTION_ID = 'Inspection_ID';
  static const String SPECIFICATION_NUMBER = 'Specification_Number';
  static const String SPECIFICATION_VERSION = 'Specification_Version';
  static const String SPECIFICATION_NAME = 'Specification_Name';
}

class ItemSkuColumn {
  static const String ID = BaseColumns.ID;
  static const String SKU_ID = 'SKU_ID';
  static const String CODE = 'Code';
  static const String COMMODITY_ID = 'Commodity_ID';
  static const String NAME = 'Name';
  static const String DESCRIPTION = 'Description';
  static const String STATUS = 'Status';
  static const String ITEM_GROUP1_ID = 'ItemGroup1_ID';
  static const String ITEM_GROUP2_ID = 'ItemGroup2_ID';
  static const String GRADE_ID = 'GradeID';
  static const String PACKAGING_ID = 'Packaging_ID';
  static const String USAGE_TYPE = 'Usage_Type';
  static const String COMMODITY_CATEGORY_ID = 'Commodity_Category_ID';
  static const String ITEM_TYPE = 'Item_Type';
  static const String GLOBAL_PARTNER_ID = 'Global_Partner_Id';
  static const String COMPANY_ID = 'Company_Id';
  static const String DIVISION_ID = 'Division_Id';
  static const String BRANDED = 'Branded';
  static const String FTL = 'FTL';
}

class ItemGroup1Column {
  static const String ID = BaseColumns.ID;
  static const String GROUP1_ID = 'Group1_ID';
  static const String NAME = 'Name';
  static const String COMMODITY_ID = 'Commodity_ID';
}

class SpecificationColumn {
  static const String ID = BaseColumns.ID;
  static const String NUMBER = 'Number';
  static const String VERSION = 'Version';
  static const String NAME = 'Name';
  static const String ITEM_GROUP1_ID = 'Item_Group1_ID';
  static const String COMMODITY_ID = 'Commodity_ID';
  static const String SPECIFICATION_TYPE_ID = 'Specification_Type_ID';
}

class SpecificationSupplierColumn {
  static const String ID = BaseColumns.ID;
  static const String NUMBER_SPECIFICATION = "Number_Specification";
  static const String VERSION_SPECIFICATION = "Version_Specification";
  static const String SUPPLIER_ID = "Supplier_ID";
  static const String NEGOTIATION_STATUS = "Negotiation_Status";
  static const String STATUS = "Status";
  static const String ITEM_SKU_ID = "Item_SKU_ID";
  static const String GTIN = "Gtin";
  static const String SPECIFICATION_SUPPLIER_ID = "Specification_Supplier_ID";
}

class SpecificationSupplierGtinColumn {
  static const String SPECIFICATION_SUPPLIER_ID = 'Specification_Supplier_ID';
  static const String GTIN = 'Gtin';
}

class MaterialSpecificationColumn {
  static const String ID = BaseColumns.ID;
  static const String NUMBER_SPECIFICATION = 'Number_Specification';
  static const String VERSION_SPECIFICATION = 'Version_Specification';
  static const String GRADE_ID = 'Grade_ID';
  static const String STATUS = 'Status';
}

class SpecificationGradeToleranceColumn {
  static const String ID = BaseColumns.ID;
  static const String SPECIFICATION_GRADE_TOLERANCE_ID =
      'Specification_Grade_Tolerance_ID';
  static const String NUMBER_SPECIFICATION = 'Number_Specification';
  static const String VERSION_SPECIFICATION = 'Version_Specification';
  static const String SEVERITY_DEFECT_ID = 'Severity_Defect_ID';
  static const String DEFECT_ID = 'Defect_ID';
  static const String GRADE_TOLERANCE_PERCENTAGE = 'Grade_Tolerance_Percentage';
  static const String OVERRIDDEN = 'Overridden';
  static const String DEFECT_NAME = 'Defect_Name';
  static const String DEFECT_CATEGORY_NAME = 'Defect_Category_Name';
  static const String SEVERITY_DEFECT_NAME = 'Severity_Defect_Name';
}

class SpecificationAnalyticalColumn {
  static const String ID = BaseColumns.ID;
  static const String NUMBER_SPECIFICATION = 'Number_Specification';
  static const String VERSION_SPECIFICATION = 'Version_Specification';
  static const String ANALYTICAL_ID = 'Analytical_ID';
  static const String ANALYTICAL_NAME = 'Analytical_name';
  static const String SPEC_MIN = 'Spec_Min';
  static const String SPEC_MAX = 'Spec_Max';
  static const String TARGET_NUM_VALUE = 'Target_Num_Value';
  static const String TARGET_TEXT_VALUE = 'Target_Text_Value';
  static const String UOM_NAME = 'UOM_Name';
  static const String TYPE_ENTRY = 'Type_Entry';
  static const String DESCRIPTION = 'Description';
  static const String ORDER_NO = 'OrderNo';
  static const String PICTURE_REQUIRED = 'Picture_Required';
  static const String TARGET_TEXT_DEFAULT = 'Target_Text_Default';
  static const String INSPECTION_RESULT = 'Inspection_Result';
}

class AgencyColumn {
  static const String ID = 'ID';
  static const String _ID = BaseColumns.ID;
  static const String NAME = 'Name';
}

class GradeColumn {
  static const String ID = 'ID';
  static const String _ID = BaseColumns.ID;
  static const String NAME = 'Name';
  static const String AGENCY_ID = 'Agency_ID';
}

class GradeCommodityColumn {
  static const String ID = 'ID';
  static const String _ID = BaseColumns.ID;
  static const String AGENCY_ID = 'Agency_ID';
  static const String COMMODITY_ID = 'Commodity_ID';
}

class GradeCommodityDetailColumn {
  static const String ID = 'ID';
  static const String _ID = BaseColumns.ID;
  static const String GRADE_ID = 'Grade_ID';
  static const String GRADE_COMMODITY_ID = 'Grade_Commodity_ID';
  static const String STATUS = 'Status';
  static const String SORT_SEQUENCE_FIELD = 'SORT_SEQUENCE_FIELD';
}

class GradeCommodityToleranceColumn {
  static const String ID = BaseColumns.ID;
  static const String SEVERITY_DEFECT_ID = 'Severity_Defect_ID';
  static const String DEFECT_ID = 'Defect_ID';
  static const String GRADE_TOLERANCE_PERCENTAGE = 'Grade_Tolerance_Percentage';
  static const String GRADE_COMMODITY_DETAIL_ID = 'Grade_Commodity_Detail_ID';
}

class SpecificationAttributesColumn {
  static const String ID = BaseColumns.ID;
  static const String INSPECTION_ID = 'Inspection_ID';
  static const String ANALYTICAL_ID = 'Analytical_ID';
  static const String COMPLY = 'Comply';
  static const String SAMPLE_TEXT_VALUE = 'Sample_Text_Value';
  static const String SAMPLE_VALUE = 'Sample_Value';
  static const String COMMENT = 'Comment';
  static const String ANALYTICAL_NAME = 'Analytical_Name';
  static const String PICTURE_REQUIRED = 'Picture_Required';
  static const String INSPECTION_RESULT = 'Inspection_Result';
}

class TempTrailerTemperatureColumn {
  static const String ID = BaseColumns.ID;
  static const String PARTNER_ID = 'Partner_ID';
  static const String LOCATION = 'Location';
  static const String LEVEL = 'Level';
  static const String VALUE = 'value';
  static const String COMPLETE = 'complete';
  static const String PO_NUMBER = 'po_number';
}

class PartnerItemSkuColumn {
  static const String ID = BaseColumns.ID;
  static const String PARTNER_ID = 'Partner_ID';
  static const String ITEM_SKU = 'ItemSKU';
  static const String LOT_NO = 'LotNo';
  static const String PACK_DATE = 'PackDate';
  static const String INSPECTION_ID = 'Inspection_ID';
  static const String COMPLETE = 'Complete';
  static const String LOT_SIZE = 'LotSize';
  static const String UNIQUE_ID = 'Unique_Id';
  static const String PO_LINE_NO = 'POLineNo';
  static const String PO_NO = 'PoNo';
}

class SpecificationPackagingFinishedGoodsColumn {
  static const String ID = BaseColumns.ID;
  static const String FINISHED_GOODS_ID = 'Finished_Goods_ID';
  static const String NUMBER_SPECIFICATION = 'Number_Specification';
  static const String VERSION_SPECIFICATION = 'Version_Specification';
  static const String ITEM_SKU_ID = 'Item_SKU_ID';
}

class CommodityColumn {
  static const String ID = 'ID';
  static const String _ID = BaseColumns.ID;
  static const String NAME = 'Name';
  static const String SAMPLE_SIZE_BY_COUNT = 'Sample_Size_By_Count';
  static const String KEYWORDS = 'Keywords';
}

class CommodityCteColumn {
  static const String ID = 'ID';
  static const String _ID = BaseColumns.ID;
  static const String NAME = 'Name';
  static const String SAMPLE_SIZE_BY_COUNT = 'Sample_Size_By_Count';
  static const String KEYWORDS = 'Keywords';
}

class SpecificationTypeColumn {
  static const String ID = BaseColumns.ID;
  static const String SPECIFICATION_TYPE_ID = 'Specification_Type_ID';
  static const String NAME = 'Name';
}

class TrailerTemperatureDetailsColumn {
  static const String ID = BaseColumns.ID;
  static const String PARTNER_ID = 'Partner_ID';
  static const String TEMP_OPEN1 = 'TempOpen1';
  static const String TEMP_OPEN2 = 'TempOpen2';
  static const String TEMP_OPEN3 = 'TempOpen3';
  static const String COMMENTS = 'Comments';
  static const String PO_NUMBER = 'po_number';
}

class TempTrailerTemperatureDetailsColumn {
  static const String ID = BaseColumns.ID;
  static const String PARTNER_ID = 'Partner_ID';
  static const String TEMP_OPEN1 = 'TempOpen1';
  static const String TEMP_OPEN2 = 'TempOpen2';
  static const String TEMP_OPEN3 = 'TempOpen3';
  static const String COMMENTS = 'Comments';
  static const String PO_NUMBER = 'po_number';
}

class QcHeaderDetailsColumn {
  static const String ID = BaseColumns.ID;
  static const String INSPECTION_ID = 'Inspection_ID';
  static const String PO_NUMBER = 'PO_number';
  static const String SEAL_NUMBER = 'Seal_number';
  static const String QCH_OPEN1 = 'QCHOpen1';
  static const String QCH_OPEN2 = 'QCHOpen2';
  static const String QCH_OPEN3 = 'QCHOpen3';
  static const String QCH_OPEN4 = 'QCHOpen4';
  static const String QCH_OPEN5 = 'QCHOpen5';
  static const String QCH_OPEN6 = 'QCHOpen6';
  static const String QCH_OPEN9 = 'QCHOpen9';
  static const String QCH_OPEN10 = 'QCHOpen10';
  static const String QCH_TRUCK_TEMP_OK = 'QCHTruckTempOk';
}

class TempQcHeaderDetailsColumn {
  static const String ID = BaseColumns.ID;
  static const String PARTNER_ID = 'Partner_ID';
  static const String PO_NUMBER = 'PO_number';
  static const String SEAL_NUMBER = 'Seal_number';
  static const String QCH_OPEN1 = 'QCHOpen1';
  static const String QCH_OPEN2 = 'QCHOpen2';
  static const String QCH_OPEN3 = 'QCHOpen3';
  static const String QCH_OPEN4 = 'QCHOpen4';
  static const String QCH_OPEN5 = 'QCHOpen5';
  static const String QCH_OPEN6 = 'QCHOpen6';
  static const String QCH_OPEN9 = 'QCHOpen9';
  static const String QCH_OPEN10 = 'QCHOpen10';
  static const String TRUCK_TEMP_OK = 'TruckTempOk';
  static const String PRODUCT_TRANSFER = 'ProductTransfer';
  static const String CTE_TYPE = 'CteType';
}

class SelectedItemSkuListColumn {
  static const String ID = BaseColumns.ID;
  static const String SKU_ID = 'SKU_ID';
  static const String UNIQUE_ITEM_ID = 'Unique_Item_ID';
  static const String PO_NUMBER = 'PO_number';
  static const String LOT_NUMBER = 'Lot_number';
  static const String SKU_CODE = 'SKU_Code';
  static const String SKU_NAME = 'SKU_Name';
  static const String COMMODITY_NAME = 'Commodity_Name';
  static const String COMMODITY_ID = 'Commodity_Id';
  static const String DESCRIPTION = 'Description';
  static const String INSPECTION_ID = 'Inspection_ID';
  static const String COMPLETE = 'Complete';
  static const String PARTNER_ID = 'Partner_ID';
  static const String PARTIAL_COMPLETE = 'Partial_Complete';
  static const String PACK_DATE = 'PackDate';
  static const String GTIN = 'GTIN';
  static const String PARTNER_NAME = 'PartnerName';
  static const String FTL = 'FTL';
  static const String BRANDED = 'Branded';
  static const String DATE_TYPE = 'DateType';
}

class ResultRejectionDetailsColumn {
  static const String ID = BaseColumns.ID;
  static const String INSPECTION_ID = 'Inspection_ID';
  static const String RESULT = 'Result';
  static const String RESULT_REASON = 'Result_Reason';
  static const String DEFECT_COMMENTS = 'Defect_Comments';
}

class CommodityKeywordsColumn {
  static const String ID = 'ID';
  static const String _ID = BaseColumns.ID;
  static const String KEYWORDS = 'Keywords';
}

class POHeaderColumn {
  static const String ID = BaseColumns.ID;
  static const String PO_HEADER_ID = 'PO_Header_ID';
  static const String PO_NUMBER = 'PO_Number';
  static const String PO_DELIVER_TO_ID = 'PO_Deliver_To_Id';
  static const String PO_DELIVER_TO_NAME = 'PO_Deliver_To_Name';
  static const String PO_PARTNER_ID = 'PO_Partner_Id';
  static const String PO_PARTNER_NAME = 'PO_Partner_Name';
}

class PODetailColumn {
  static const String ID = BaseColumns.ID;
  static const String PO_DETAIL_ID = 'PO_Detail_ID';
  static const String PO_HEADER_ID = 'PO_Header_ID';
  static const String PO_DETAIL_NUMBER = 'PO_Detail_Number';
  static const String PO_DELIVER_TO_ID = 'PO_Deliver_To_Id';
  static const String PO_DELIVER_TO_NAME = 'PO_Deliver_To_Name';
  static const String PO_LINE_NUMBER = 'PO_Line_Number';
  static const String PO_ITEM_SKU_ID = 'PO_Item_Sku_Id';
  static const String PO_ITEM_SKU_CODE = 'PO_Item_Sku_Code';
  static const String PO_ITEM_SKU_NAME = 'PO_Item_Sku_Name';
  static const String PO_QUANTITY = 'PO_Quantity';
  static const String PO_QTY_UOM_ID = 'PO_Qty_UOM_Id';
  static const String PO_QTY_UOM_NAME = 'PO_Qty_UOM_Name';
  static const String PO_NUMBER_SPEC = 'PO_Number_Spec';
  static const String PO_VERSION_SPEC = 'PO_Version_Spec';
  static const String PO_COMMODITY_ID = 'PO_Commodity_Id';
  static const String PO_COMMODITY_NAME = 'PO_Commodity_Name';
}
