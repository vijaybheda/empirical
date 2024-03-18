class ApiUrls {
  static const String serverUrl = "https://appqa.share-ify.com/PM/rest/ws/";

  static const String LOGIN_REQUEST = "user/validateUser";
  static const String GET_USERS = "user/users";
  static const String SUPPLIER_REQUEST = "partner/getPartnerSupplier";
  static const String CARRIER_REQUEST = "partner/getPartnerCarrier";
  static const String COMMODITIES_REQUEST =
      "commodity/getCommodityWithItemGroup1";
  static const String COMMODITY_ITEM_GOURP_1_REQUEST =
      "commodity/getCommodityItemGroup1";
  static const String DELIVERY_TO_REQUEST = "supplier/getDeliveryTo";
  static const String UOM_REQUEST = "masterData/getUOM";
  static const String REASON_REQUEST = "masterData/getReason";
  static const String TRENDING_REPORT_REQUEST = "commodity/getTrendingData";
  static const String COMPLETED_INSPECTIONS_REQUEST =
      "partner/getMyLast48HrInspections";
  static const String UPLOAD_INSPECTION_REQUEST = "partner/uploadInspection";
  static const String DOWNLOAD_INSPECTION_REQUEST =
      "partner/downloadInspection";
  static const String UPLOAD_MOBILE_FILES_REQUEST =
      "inspection/uploadInspection";
  static const String UPLOAD_INSPECTION_DEFECT_ATTACHMENT_REQUEST =
      "inspection/updateInspectionDefectAttachment";
  static const String APPLICATION_UPDATE_INFO_REQUEST =
      "inspection/getAndroidUpdateInfo";
  static const String DEFECT_CATEGORIES = "masterData/defectCategories";
  static const String UPLOAD_INSPECTION_ATTACHMENT_REQUEST =
      "inspection/uploadInspectionPictures";
  static const String COMMODITYLIST_REQUEST = "commodity/commodityWithItemSku";

  static const String UPLOAD_INSPECTION_REQUEST_CTE =
      "criticalTrackingEvents/add";

  static const String BRAND_REQUEST = "masterData/getBrand";
  static const String COUNTRY_REQUEST = "masterData/getCountry";
  static const String AGENCY_REQUEST = "commodity/getAgency";
  static const String GRADE_COMMODITY_DETAIL_REQUEST =
      "commodity/getGradeCommodityDetail";
  static const String GRADE_SETTING_BY_COMMODITY_REQUEST =
      "commodity/getGradeSettingByCommodity";
  static const String LAST_INSPECTIONS_REQUEST = "partner/getLastInspections";
  static const String SPECIFICATION_REQUEST = "specification/getSpecification";
  static const String SPECIFICATION_GRADE_TOLERANCE =
      "specification/getSpecificationGradeTolerance";
  static const String SPECIFICATION_PACKAGING_GTIN_REQUEST =
      "specification/getSpecificationPackagingGTIN";
  static const String SPECIFICATION_ANALYTICAL_COUNTRY_BRAND =
      "specification/getSpecificationAnalyticalCountryBrand";
  static const String COMMODITY_SEVERITIES = "commodity/getSeverities";
  static const String FINISHED_GOODS_ITEM_SKU =
      "masterData/finishedGoodsItemSku";
  static const String SPECIFICATION_BY_ITEM_SKU =
      "specification/getSpecificationByItemSku";

//static const  String SPECIFICATION_SUPPLIER_GTIN = "specification/getSpecificationSupplier";
  static const String SPECIFICATION_SUPPLIER_GTIN =
      "specification/specificationSuppliersByGtin";

  static const String SPECIFICATION_GRADE_TOLERANCE_TABLE =
      "specification/gradeTolerance/all";

  static const String TOOLBAR_DATA_REQUEST = "specification/bannerDatas";
  static const String OFFLINE_CSV_DATA_REQUEST = "mobile/csv";
  static const String OFFLINE_JSON_DATA_REQUEST = "mobile/json";

  static const bool HASH_PASSWORD = false;

  int webServiceTimeout = 90000;
  int deviceId = 1;
  String banner1 = "https://www.ams.usda.gov/grades-standards";
  String banner2 = "https://www.ams.usda.gov/grades-standards";
}
