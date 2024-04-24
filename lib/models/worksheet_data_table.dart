class WorksheetDataTable {
  List<String> defectType;
  List<List<String>> severity;
  List<num> qualityDefects;
  List<num> qualityDefectsPercentage;
  List<num> conditionDefects;
  List<num> conditionDefectsPercentage;
  List<List<num>> totalSeverity;
  List<List<num>> totalSeverityPercentage;
  List<num> sizeDefects;
  List<num> sizeDefectsPercentage;
  List<num> colorDefects;
  List<num> colorDefectsPercentage;

  WorksheetDataTable({
    required this.defectType,
    required this.severity,
    required this.qualityDefects,
    required this.qualityDefectsPercentage,
    required this.conditionDefects,
    required this.conditionDefectsPercentage,
    required this.totalSeverity,
    required this.totalSeverityPercentage,
    required this.sizeDefects,
    required this.sizeDefectsPercentage,
    required this.colorDefects,
    required this.colorDefectsPercentage,
  });
}
