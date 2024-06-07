part of '../../merge_table.dart';

abstract class BaseMColumn {
  final String header;
  final List<String>? columns;

  bool get isMergedColumn => columns != null;

  BaseMColumn({
    required this.header,
    this.columns,
  });
}

class MColumn extends BaseMColumn {
  MColumn({
    required super.header,
  }) : super(columns: null);
}

class MMergedColumns extends BaseMColumn {
  @override
  List<String> get columns => super.columns!;

  MMergedColumns({
    required super.header,
    required List<String> super.columns,
  });
}
