import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/controller/purchase_order_details_controller.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/models/commodity_item.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/models/purchase_order_item.dart';
import 'package:pverify/models/qc_header_details.dart';
import 'package:pverify/ui/components/bottom_custom_button_view.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/components/header_content_view.dart';
import 'package:pverify/ui/components/progress_adaptive.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
import 'package:pverify/utils/theme/colors.dart';

class PurchaseOrderDetailsScreen
    extends GetWidget<PurchaseOrderDetailsController> {
  final PartnerItem partner;
  final CarrierItem carrier;
  final CommodityItem commodity;
  final QCHeaderDetails? qcHeaderDetails;
  const PurchaseOrderDetailsScreen({
    super.key,
    required this.partner,
    required this.carrier,
    required this.commodity,
    required this.qcHeaderDetails,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PurchaseOrderDetailsController>(
        init: PurchaseOrderDetailsController(
            partner: partner,
            carrier: carrier,
            commodity: commodity,
            qcHeaderDetails: qcHeaderDetails),
        builder: (controller) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              toolbarHeight: 150.h,
              leading: const Offstage(),
              leadingWidth: 0,
              centerTitle: false,
              backgroundColor: Theme.of(context).primaryColor,
              title: HeaderContentView(
                title: AppStrings.beginInspection,
                message: 'PO# ${qcHeaderDetails?.poNo ?? '-'}',
              ),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  color: AppColors.textFieldText_Color,
                  width: double.infinity,
                  child: Text(
                    partner.name ?? '-',
                    textAlign: TextAlign.start,
                    maxLines: 3,
                    style: GoogleFonts.poppins(
                        fontSize: 38.sp,
                        fontWeight: FontWeight.w600,
                        textStyle: TextStyle(color: AppColors.white)),
                  ),
                ),
                const SearchOrderItemsWidget(),
                Expanded(flex: 10, child: _purchaseOrderItemSection(context)),
                BottomCustomButtonView(
                  title: AppStrings.save,
                  onPressed: () async {
                    // await controller.navigateToPurchaseOrderDetails(
                    //     context, partner, carrier, commodity);
                  },
                ),
                FooterContentView()
              ],
            ),
          );
        });
  }

  GetBuilder<PurchaseOrderDetailsController> _purchaseOrderItemSection(
      BuildContext context) {
    return GetBuilder<PurchaseOrderDetailsController>(
      id: 'inspectionItems',
      builder: (controller) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              controller.listAssigned.value
                  ? Expanded(
                      flex: 10,
                      child: controller.filteredInspectionsList.isNotEmpty
                          ? _inspectionsListView(context, controller)
                          : noDataFoundWidget(),
                    )
                  : const Center(
                      child: SizedBox(
                          height: 25, width: 25, child: ProgressAdaptive())),
            ],
          ),
        );
      },
    );
  }

  Center noDataFoundWidget() {
    return Center(
      child: Text(
        'No data found',
        style: Get.textTheme.displayMedium?.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _inspectionsListView(
    BuildContext context,
    PurchaseOrderDetailsController controller,
  ) {
    return ListView.separated(
      itemCount: controller.filteredInspectionsList.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        PurchaseOrderItem goodsItem =
            controller.filteredInspectionsList.elementAt(index);
        return PurchaseOrderListViewItem(
          goodsItem: goodsItem,
          sku: goodsItem.sku,
          inspectButtonCallback: () {
            // Implement your logic
          },
          poNumber: goodsItem.poNumber,
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(
          height: 5,
          indent: 0,
          endIndent: 0,
          color: AppColors.white,
          thickness: 1,
        );
      },
    );
  }
}

class PurchaseOrderListViewItem extends StatefulWidget {
  const PurchaseOrderListViewItem({
    super.key,
    required this.sku,
    required this.poNumber,
    required this.inspectButtonCallback,
    required this.goodsItem,
  });
  final String? sku;
  final String? poNumber;
  final Function inspectButtonCallback;

  final PurchaseOrderItem goodsItem;

  @override
  State<PurchaseOrderListViewItem> createState() =>
      _PurchaseOrderListViewItemState();
}

class _PurchaseOrderListViewItemState extends State<PurchaseOrderListViewItem> {
  late TextEditingController lotNumberController;

  late TextEditingController qtyRejectedController;

  late TextEditingController qtyShippedController;

  bool isComplete = false;

  bool isPartialComplete = false;

  @override
  void initState() {
    super.initState();
    lotNumberController = TextEditingController();
    qtyRejectedController = TextEditingController();
    qtyShippedController = TextEditingController();
  }

  @override
  void dispose() {
    lotNumberController.dispose();
    qtyRejectedController.dispose();
    qtyShippedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.goodsItem.description ?? '-'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.sku ?? '-'),
          Text(widget.poNumber ?? '-'),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.play_arrow),
        onPressed: () {
          if (lotNumberController.text.isEmpty) {
            AppAlertDialog.validateAlerts(
                context, AppStrings.alert, AppStrings.lotnoRequired);
          } else {
            bool checkItemSKUAndLot = false; // Implement your logic
            bool isValid = true; // Implement your logic

            if (isValid) {
              if (isComplete || isPartialComplete || !checkItemSKUAndLot) {
                widget.inspectButtonCallback(); // Navigate to QC details
              } else {
                AppAlertDialog.validateAlerts(
                    context, 'Alert', AppStrings.lotnoRequired);
              }
            } else {
              AppAlertDialog.validateAlerts(
                  context, 'Alert', 'Quantity rejected is not valid');
            }
          }
        },
      ),
    );
  }
}

class SearchOrderItemsWidget extends StatelessWidget {
  const SearchOrderItemsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 25.h),
        child: TextField(
          onChanged: (value) {
            Get.find<PurchaseOrderDetailsController>()
                .searchAndAssignItems(value);
          },
          controller:
              Get.find<PurchaseOrderDetailsController>().searchController,
          decoration: InputDecoration(
            hintText: AppStrings.searchItem,
            hintStyle: Get.textTheme.bodyLarge?.copyWith(
                fontSize: 25.sp, color: AppColors.white.withOpacity(0.5)),
            isDense: true,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
            prefixIcon: Icon(Icons.search, color: AppColors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: AppColors.white),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: AppColors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: AppColors.white),
            ),
            suffixIcon: IconButton(
              onPressed: () {
                Get.find<PurchaseOrderDetailsController>().clearSearch();
              },
              icon: Icon(
                Icons.clear,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
