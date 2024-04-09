import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/controller/qc_details_short_form_screen_controller.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/models/commodity_item.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/models/purchase_order_item.dart';
import 'package:pverify/models/qc_header_details.dart';
import 'package:pverify/ui/components/drawer_header_content_view.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/theme/colors.dart';

class QCDetailsShortFormScreen
    extends GetWidget<QCDetailsShortFormScreenController> {
  final PartnerItem partner;
  final CarrierItem carrier;
  final CommodityItem commodity;
  final QCHeaderDetails? qcHeaderDetails;
  final PurchaseOrderItem purchaseOrderItem;
  const QCDetailsShortFormScreen({
    super.key,
    required this.partner,
    required this.carrier,
    required this.commodity,
    this.qcHeaderDetails,
    required this.purchaseOrderItem,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<QCDetailsShortFormScreenController>(
      init: QCDetailsShortFormScreenController(partner: partner),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            toolbarHeight: 150.h,
            leadingWidth: 0,
            automaticallyImplyLeading: false,
            leading: const Offstage(),
            centerTitle: false,
            backgroundColor: Theme.of(context).primaryColor,
            titleSpacing: 0,
            title: DrawerHeaderContentView(
              title: AppStrings.title_activity_q_c__details_short_form,
            ),
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.green,
                  ),
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.message),
                  title: Text('Toast Message 1'),
                  onTap: () {
                    Navigator.pop(context); // close the drawer
                  },
                ),
                ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text('Toast Message 2'),
                  onTap: () {
                    Navigator.pop(context); // close the drawer
                  },
                ),
                // Add more ListTiles...
              ],
            ),
          ),
          body: Center(
            child: Column(
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
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Name Placeholder",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "12345643",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
