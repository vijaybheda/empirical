import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    content: ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * .5,
        minHeight: MediaQuery.of(context).size.height * .2,
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildTable(specData),
                ],
              ),
            ),
          ),
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

  // Extract entries and sort them
  List<MapEntry<String, Map<String, List<SpecificationGradeTolerance>>>>
      entries = categorizedData.entries.toList();

  entries.sort((a, b) {
    if (a.key.isEmpty) {
      return 1;
    } else if (b.key.isEmpty) {
      return -1;
    } else {
      return a.key.compareTo(b.key);
    }
  });

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

  Map<String, Map<String, List<SpecificationGradeTolerance>>>
      emptyKeyCategorizedData = {};

  emptyKeyCategorizedData.addEntries(categorizedData.entries
      .where((element) => element.key.isNotEmpty)
      .toList());
  categorizedData.removeWhere((key, value) => key.isNotEmpty);
  emptyKeyCategorizedData.addAll(categorizedData);

  return Table(
    border: TableBorder.all(color: AppColors.white),
    columnWidths: {0: FixedColumnWidth(220.w)},
    defaultColumnWidth: FlexColumnWidth(1.0),
    children: [
      ...rows,
      ...emptyKeyCategorizedData.entries.expand((categoryEntry) {
        print('categoryEntry: ${categoryEntry.key}');
        return categoryEntry.value.entries.map((defectEntry) {
          return TableRow(
            children: [
              if (categoryEntry.key.isNotEmpty && defectEntry.key.isNotEmpty)
                _contentCell("${categoryEntry.key} - ${defectEntry.key}")
              else
                _contentCell("Total Severity (%)"),
              ..._buildSeverityCells(defectEntry.value),
            ],
          );
        });
      }),
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
  return SizedBox(
    width: 150,
    child: Container(
      padding: EdgeInsets.all(8.w),
      alignment: Alignment.center,
      child: Text(text == 0.0.toString() ? '' : text,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 28.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.white,
          )),
    ),
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
