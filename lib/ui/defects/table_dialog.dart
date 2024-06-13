import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/models/specification_grade_tolerance.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/theme/colors.dart';

Widget tableDialog(BuildContext context) {
  List<SpecificationGradeTolerance> specData =
      AppStorage.instance.specificationGradeToleranceTable;
  specData.sort((a, b) {
    if (a.defectCategoryName == b.defectCategoryName) {
      return a.defectName!.compareTo(b.defectName!);
    }
    return a.defectCategoryName!.compareTo(b.defectCategoryName!);
  });
  return AlertDialog(
    backgroundColor: Theme.of(context).colorScheme.background,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(0),
    ),
    title: null,
    contentPadding: const EdgeInsets.all(8),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildTable(specData),
          SizedBox(height: 40.h),
          closeDialogButton(context),
        ],
      ),
    ),
  );
}

Widget buildTable(List<SpecificationGradeTolerance> specData) {
  Map<String, Map<String, List<SpecificationGradeTolerance>>> categorizedData =
      {};
  for (SpecificationGradeTolerance spec in specData) {
    categorizedData.putIfAbsent(spec.defectCategoryName!, () => {});
    categorizedData[spec.defectCategoryName]!
        .putIfAbsent(spec.defectName!, () => []);
    categorizedData[spec.defectCategoryName]![spec.defectName]!.add(spec);
  }

  List<TableRow> rows = [
    TableRow(
      children: [
        buildHeaderCell(''),
        buildHeaderCell('Injury (%)'),
        buildHeaderCell('D (%)'),
        buildHeaderCell('SD (%)'),
        buildHeaderCell('VSD (%)'),
        buildHeaderCell('Decay (%)'),
        buildHeaderCell('Total Defects(%)'),
      ],
    ),
  ];

  return Table(
    border: TableBorder.all(color: AppColors.white),
    columnWidths: {0: FixedColumnWidth(160.w)},
    children: [
      ...rows,
      ...categorizedData.entries.expand(
          (categoryEntry) => categoryEntry.value.entries.map((defectEntry) {
                return TableRow(
                  children: [
                    _contentCell("${categoryEntry.key} - ${defectEntry.key}"),
                    ..._buildSeverityCells(defectEntry.value),
                  ],
                );
              })),
    ],
  );
}

TableRow buildSpecRow(
    String category, String defect, List<SpecificationGradeTolerance> specs) {
  int? injury = specs
      .firstWhereOrNull((s) => s.severityDefectName == "Injury")
      ?.specTolerancePercentage;
  int? damage = specs
      .firstWhereOrNull((s) => s.severityDefectName == "Damage")
      ?.specTolerancePercentage;
  int? seriousDamage = specs
      .firstWhereOrNull((s) => s.severityDefectName == "Serious Damage")
      ?.specTolerancePercentage;
  int? verySeriousDamage = specs
      .firstWhereOrNull((s) => s.severityDefectName == "Very Serious Damage")
      ?.specTolerancePercentage;
  int? decay = specs
      .firstWhereOrNull((s) => s.severityDefectName == "Decay")
      ?.specTolerancePercentage;
  int total = 0;
  if (injury != null) {
    total = injury;
  } else if (damage != null) {
    total = damage;
  } else if (seriousDamage != null) {
    total = seriousDamage;
  } else if (verySeriousDamage != null) {
    total = verySeriousDamage;
  } else if (decay != null) {
    total = decay;
  }

  return TableRow(
    children: [
      buildTableCell('$category - $defect'),
      buildTableCell('${injury! > 0.0 ? injury : ""}'),
      buildTableCell('${damage! > 0.0 ? damage : ""}'),
      buildTableCell('${seriousDamage! > 0.0 ? seriousDamage : ""}'),
      buildTableCell('${verySeriousDamage! > 0.0 ? verySeriousDamage : ""}'),
      buildTableCell('${decay! > 0.0 ? decay : ""}'),
      buildTableCell('${total > 0.0 ? total : ""}'),
    ],
  );
}

Widget buildHeaderCell(String text) {
  return Center(
    child: Container(
      padding: const EdgeInsets.all(8),
      // color: Colors.grey[300],
      child: Text(text,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 28.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.white,
          )),
    ),
  );
}

List<Widget> _buildSeverityCells(List<SpecificationGradeTolerance> specs) {
  Map<String, double> severities = {
    "Injury": 0,
    "Damage": 0,
    "Serious Damage": 0,
    "Very Serious Damage": 0,
    "Decay": 0
  };
  for (var spec in specs) {
    severities[spec.severityDefectName ?? ''] =
        (spec.specTolerancePercentage?.toDouble() ?? 0.0);
  }

  return severities.entries
      .map((entry) => _contentCell(entry.value.toString()))
      .toList();
}

Widget _contentCell(String text) {
  return Container(
    padding: EdgeInsets.all(8.w),
    alignment: Alignment.center,
    child: Text(text == 0.0.toString() ? '' : text,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 28.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.white,
        )),
  );
}

Widget buildTableCell(String text) {
  return Container(
    padding: const EdgeInsets.all(8),
    child: Text(text,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 28.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.white,
        )),
  );
}

Widget closeDialogButton(BuildContext context) {
  return GestureDetector(
    onTap: () => Navigator.pop(context),
    child: Container(
      height: 90.h,
      width: MediaQuery.of(context).size.width,
      color: AppColors.greenButtonColor,
      child: Center(
        child: Text(
          'OK',
          style: GoogleFonts.poppins(
            fontSize: 28.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.white,
          ),
        ),
      ),
    ),
  );
}

/*

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
          child: false
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
*/
