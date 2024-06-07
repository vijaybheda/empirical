part of '../../merge_table.dart';

abstract class BaseMRow {
  final List<Widget> inlineRow;

  BaseMRow(this.inlineRow);
}

class MRow extends BaseMRow {
  MRow(Widget rowValue) : super([rowValue]);
}

class MMergedRows extends BaseMRow {
  MMergedRows(super.mergedRowValues);
}

class VerticalMergedRow extends BaseMRow {
  final int rowSpan;
  final Widget child;

  VerticalMergedRow({required this.rowSpan, required this.child})
      : super([child]);
}
