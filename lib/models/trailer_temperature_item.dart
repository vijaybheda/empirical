import 'package:pverify/services/database/column_names.dart';

class TrailerTemperatureItem {
  int? trailerTemperatureId;
  int? inspectionId;
  String? level;
  String? location;
  int? value;

  TrailerTemperatureItem({
    this.trailerTemperatureId,
    this.inspectionId,
    this.level,
    this.location,
    this.value,
  });

  factory TrailerTemperatureItem.fromMap(Map<String, dynamic> map) {
    return TrailerTemperatureItem(
      trailerTemperatureId: map[TrailerTemperatureColumn.ID],
      inspectionId: map[TrailerTemperatureColumn.INSPECTION_ID],
      level: map[TrailerTemperatureColumn.LEVEL],
      location: map[TrailerTemperatureColumn.LOCATION],
      value: map[TrailerTemperatureColumn.VALUE],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      TrailerTemperatureColumn.ID: trailerTemperatureId,
      TrailerTemperatureColumn.INSPECTION_ID: inspectionId,
      TrailerTemperatureColumn.LEVEL: level,
      TrailerTemperatureColumn.LOCATION: location,
      TrailerTemperatureColumn.VALUE: value,
    };
  }
}
