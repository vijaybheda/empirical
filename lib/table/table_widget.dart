import 'package:flutter/material.dart';
import 'package:pverify/table/merge_table.dart';
import 'package:pverify/utils/theme/colors.dart';

class TableWidget extends StatelessWidget {
  // final List<List<Widget>> datas;
  final List<List<BaseMRow>> datas;

  const TableWidget({super.key, required this.datas});

  Widget createRow(List<dynamic> data) {
    List<Widget> w = [];

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      if (item is BaseMRow) {
        for (int j = 0; j < item.inlineRow.length; j++) {
          if (item.inlineRow[j] is Offstage) {
            // if j is last element border right side
            if (j == item.inlineRow.length - 1) {
              final c = Container(
                color: AppColors.defectOrange,
                child: Row(
                  children: [
                    Center(
                      child: Container(
                        width: 100,
                        height: 65,
                        decoration: const BoxDecoration(
                            border: Border.symmetric(
                                horizontal: BorderSide(color: Colors.black))),
                      ),
                    ),
                    Container(
                      color: Colors.black,
                      height: 65,
                      width: 1,
                    )
                  ],
                ),
              );
              w.add(c);
            } else {
              final c = Container(
                color: AppColors.defectOrange,
                child: Center(
                  child: Container(
                    width: 100,
                    height: 65,
                    decoration: const BoxDecoration(
                        border: Border.symmetric(
                            horizontal: BorderSide(color: Colors.black))),
                  ),
                ),
              );
              w.add(c);
            }
          } else {
            final c = Center(
              child: Container(
                width: 100,
                height: 65,
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.black)),
                child: item.inlineRow[j],
              ),
            );
            w.add(c);
          }
        }
      }
      if (item == null) {
        final c = Center(
          child: Container(
            width: 100,
            height: 65,
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            child: const Text(""),
          ),
        );
        w.add(c);
      }

      if (item is List) {
        final c = createColumn(item);
        w.add(c);
      }
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: w,
    );
  }

  Widget createColumn(List<dynamic> data) {
    List<Widget> w = [];

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      if (item is BaseMRow) {
        if (item.inlineRow[0] is Offstage) {
          final c = Container(
            color: AppColors.defectOrange,
            child: const Center(
              child: SizedBox(
                width: 100,
                height: 65,
              ),
            ),
          );
          w.add(c);
          continue;
        }
        final c = Container(
          color: AppColors.defectOrange,
          child: Center(
            child: Container(
              width: 100,
              height: 65,
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              child: item.inlineRow[0],
            ),
          ),
        );
        w.add(c);
      }

      if (item == null) {
        final c = Center(
          child: Container(
            width: 100,
            height: 65,
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            child: const Text(""),
          ),
        );
        w.add(c);
      }

      if (item is List) {
        final c = createRow(item);
        w.add(c);
      }
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: w,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: createColumn(datas),
      ),
    );
  }
}
