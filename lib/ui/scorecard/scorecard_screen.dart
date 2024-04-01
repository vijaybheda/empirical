import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/controller/scorecard_screen_controller.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/components/header_content_view.dart';
import 'package:pverify/utils/enumeration.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';

class ScorecardScreen extends GetWidget<ScorecardScreenController> {
  final PartnerItem partner;
  const ScorecardScreen({super.key, required this.partner});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ScorecardScreenController>(
        init: ScorecardScreenController(partner),
        builder: (controller) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: Column(
              children: <Widget>[
                HeaderContentView(
                  title: partner.name ?? '-',
                ),
                Expanded(
                  child: Column(
                    children: [
                      TableHeader(),
                    ],
                  ),
                ),
                FooterContentView()
              ],
            ),
          );
        });
  }
}

class TableHeader extends GetWidget<ScorecardScreenController> {
  const TableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.grey,
      child: Row(
        children: [
          HeaderCell(
            title: 'Date',
            onTapped: () {
              print('Date');
            },
            shortType: controller.dateSort,
          ),
          HeaderCell(
            title: 'Commodity',
            onTapped: () {
              print('Commodity tapped');
            },
            shortType: controller.commoditySort,
          ),
          HeaderCell(
            title: 'Result',
            onTapped: () {
              print('Result tapped');
            },
            shortType: controller.resultSort,
          ),
          HeaderCell(
            title: 'Reason',
            onTapped: () {
              print('Reason tapped');
            },
            shortType: controller.reasonSort,
          ),
        ],
      ),
    );
  }
}

class HeaderCell extends GetWidget<ScorecardScreenController> {
  final String title;
  final Function() onTapped;
  final dynamic shortType;
  const HeaderCell({
    super.key,
    required this.title,
    required this.onTapped,
    required this.shortType,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTapped,
        child: Padding(
          padding: EdgeInsets.all(8.0.sp),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20.sp,
                    color: Colors.white,
                  ),
                ),
              ),
              Image.asset(
                getShortImage(shortType),
                width: 40.w,
                height: 40.h,
                color: AppColors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getShortImage(shortType) {
    if (shortType is DateSort) {
      switch (shortType) {
        case DateSort.none:
          return AppImages.ic_sortNone;
        case DateSort.asc:
          return AppImages.ic_sortUp;
        case DateSort.desc:
          return AppImages.ic_sortDown;
      }
    } else if (shortType is CommoditySort) {
      switch (shortType) {
        case CommoditySort.none:
          return AppImages.ic_sortNone;
        case CommoditySort.asc:
          return AppImages.ic_sortUp;
        case CommoditySort.desc:
          return AppImages.ic_sortDown;
      }
    } else if (shortType is ResultSort) {
      switch (shortType) {
        case ResultSort.none:
          return AppImages.ic_sortNone;
        case ResultSort.asc:
          return AppImages.ic_sortUp;
        case ResultSort.desc:
          return AppImages.ic_sortDown;
      }
    } else if (shortType is ReasonSort) {
      switch (shortType) {
        case ReasonSort.none:
          return AppImages.ic_sortNone;
        case ReasonSort.asc:
          return AppImages.ic_sortUp;
        case ReasonSort.desc:
          return AppImages.ic_sortDown;
      }
    }
    return AppImages.ic_sortNone;
  }
}
