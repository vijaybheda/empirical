import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/models/specification_grade_tolerance.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/theme/colors.dart';

Widget tableDialog(BuildContext context) {
  return AlertDialog(
    backgroundColor: Theme.of(context).colorScheme.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(0.0), // Set radius to 0 for no rounding
      ),
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.maxFinite,
          child: true
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _buildTable(
                      AppStorage.instance.specificationGradeToleranceTable),
                )
              : Table(
                  border: TableBorder.all(color: AppColors.white),
                  columnWidths: {0: FixedColumnWidth(160.w)},
                  children: [
                    TableRow(
                      children: [
                        setTableCell(""),
                        setTableCell(AppStrings.injury_per),
                        setTableCell(AppStrings.d_per),
                        setTableCell(AppStrings.sd_per),
                        setTableCell(AppStrings.vsd_per),
                        setTableCell(AppStrings.decay_per),
                        setTableCell(AppStrings.total_defects),
                      ],
                    ),
                    TableRow(
                      children: [
                        setTableCell(AppStrings.condition_decay,
                            leftAlign: true),
                        setTableCell(""),
                        setTableCell(""),
                        setTableCell("0.5"),
                        setTableCell(""),
                        setTableCell(""),
                        setTableCell("5.0"),
                      ],
                    ),
                    TableRow(
                      children: [
                        setTableCell(AppStrings.quality_trimming,
                            leftAlign: true),
                        setTableCell(""),
                        setTableCell(""),
                        setTableCell(""),
                        setTableCell(""),
                        setTableCell(""),
                        setTableCell("10.0"),
                      ],
                    ),
                    TableRow(
                      children: [
                        setTableCell(AppStrings.size_offsize, leftAlign: true),
                        setTableCell(""),
                        setTableCell(""),
                        setTableCell(""),
                        setTableCell(""),
                        setTableCell(""),
                        setTableCell("10.0"),
                      ],
                    ),
                    TableRow(
                      children: [
                        setTableCell(AppStrings.color_color, leftAlign: true),
                        setTableCell(""),
                        setTableCell(""),
                        setTableCell(""),
                        setTableCell(""),
                        setTableCell(""),
                        setTableCell("10.0"),
                      ],
                    ),
                    TableRow(
                      children: [
                        setTableCell(AppStrings.total_severity,
                            leftAlign: true),
                        setTableCell(""),
                        setTableCell(""),
                        setTableCell("5.0"),
                        setTableCell(""),
                        setTableCell(""),
                        setTableCell("10.0"),
                      ],
                    ),
                  ],
                ),
        ),
        SizedBox(height: 40.h),
        Center(
          child: GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Container(
              height: 90.h,
              width: MediaQuery.of(context).size.width,
              color: AppColors.greenButtonColor,
              child: Center(
                child: Text(
                  AppStrings.ok,
                  style: GoogleFonts.poppins(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w400,
                      textStyle: TextStyle(color: AppColors.white)),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildTable(List<SpecificationGradeTolerance> specData) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildTableHeader(),
      ...specData.map((spec) => _buildTableRow(spec)),
    ],
  );
}

Widget _buildTableHeader() {
  return Row(
    children: [
      _buildTableCell('', isHeader: true),
      _buildTableCell('Injury (%)', isHeader: true),
      _buildTableCell('D (%)', isHeader: true),
      _buildTableCell('SD (%)', isHeader: true),
      _buildTableCell('VSD (%)', isHeader: true),
      _buildTableCell('Decay (%)', isHeader: true),
      _buildTableCell('Total Defects (%)', isHeader: true),
    ],
  );
}

Widget _buildTableRow(SpecificationGradeTolerance spec) {
  return Row(
    children: [
      _buildTableCell('${spec.defectCategoryName} - ${spec.defectName}'),
      _buildTableCell(spec.specTolerancePercentage?.toString() ?? ''),
      _buildTableCell(spec.specTolerancePercentage?.toString() ?? ''),
      _buildTableCell(spec.specTolerancePercentage?.toString() ?? ''),
      _buildTableCell(spec.specTolerancePercentage?.toString() ?? ''),
      _buildTableCell(spec.specTolerancePercentage?.toString() ?? ''),
      _buildTableCell(spec.specTolerancePercentage?.toString() ?? ''),
    ],
  );
}

Widget _buildTableCell(String text, {bool isHeader = false}) {
  return Container(
    padding: const EdgeInsets.all(8),
    width: 120,
    height: 80,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black),
      color: isHeader ? Colors.grey : null,
    ),
    child: Text(
      text,
      style: Get.textTheme.bodyMedium?.copyWith(
        fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        fontSize: 14,
      ),
    ),
  );
}

Widget setTableCell(String tableText, {bool leftAlign = false}) {
  return TableCell(
    child: Padding(
      padding: EdgeInsets.all(8.h),
      child: Center(
        child: Text(
          tableText,
          textAlign: leftAlign ? TextAlign.left : TextAlign.center,
          style: GoogleFonts.poppins(
              fontSize: 25.sp,
              fontWeight: FontWeight.w400,
              textStyle: TextStyle(color: AppColors.white)),
        ),
      ),
    ),
  );
}
