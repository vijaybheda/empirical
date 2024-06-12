part of '../../merge_table.dart';

abstract class BaseMRow {
  final List<Widget> inlineRow;

  BaseMRow(this.inlineRow);

  TableRow getRow() {
    return TableRow(
      children: inlineRow.map((e) => TableCell(child: e)).toList(),
    );
  }

  @override
  String toString() {
    return 'BaseMRow{inlineRow: $inlineRow}';
  }
}

class MRow extends BaseMRow {
  MRow(Widget rowValue) : super([rowValue]);

  MRow.multiple(List<Widget> rowValues) : super(rowValues);

  MRow.fromRowValues(List<dynamic> rowValues)
      : super(rowValues
            .map((e) => e is Widget ? e : Text(e.toString()))
            .toList());
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
