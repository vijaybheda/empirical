class WorksheetDataTable {
  List<String> defectType;
  List<List<String>> severity;
  List<int> qualityDefects;
  List<int> qualityDefectsPercentage;
  List<int> conditionDefects;
  List<int> conditionDefectsPercentage;
  List<List<int>> totalSeverity;
  List<List<int>> totalSeverityPercentage;
  List<int> sizeDefects;
  List<int> sizeDefectsPercentage;
  List<int> colorDefects;
  List<int> colorDefectsPercentage;

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
