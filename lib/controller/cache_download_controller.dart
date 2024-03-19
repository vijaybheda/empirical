import 'package:get/get.dart';
import 'package:pverify/services/database/application_dao.dart';

class CacheDownloadController extends GetxController {
  ApplicationDao dao = ApplicationDao();

  @override
  void onInit() {
    super.onInit();
    processCsvAndInsertToDatabase();
  }

  Future<void> processCsvAndInsertToDatabase() async {
    try {
      await dao.csvImportItemGroup1();

      //TODO: implement below methods to add csv files

      // dao.csvImportItemSKU();
      // dao.csvImportAgency();
      // dao.csvImportGrade();
      // dao.csvImportGradeCommodity();
      // dao.csvImportGradeCommodityDetail();
      // dao.csvImportSpecfication();
      // dao.csvImportMaterialSpecification();
      // dao.csvImportSpecificationSupplier();
      // dao.csvImportSpecificationGradeTolerance();
      // dao.csvImportSpecificationAnalytical();
      // dao.csvImportSpecficationPackagingFinishedGoods();
      // dao.csvImportSpecificationType();
      // dao.csvImportCommodity();
      // dao.csvImportCommodityKeywords();
      // dao.csvImportPOHeader();
      // dao.csvImportPODetail();
      // dao.csvImportSpecificationSupplierGtins();
      // dao.csvImportCommodityCTE();
    } catch (e) {}
  }
}
