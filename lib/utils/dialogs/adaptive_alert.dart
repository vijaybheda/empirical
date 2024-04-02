import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptiveAlert {
  static void customAlert(
    context, {
    required Text title,
    required Text content,
    required List<Widget> actions,
  }) {
    Platform.isIOS || Platform.isMacOS
        ? showCupertinoDialog<String>(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) => Theme(
              data: ThemeData.dark(),
              child: CupertinoAlertDialog(
                title: title,
                content: content,
                actions: actions,
              ),
            ),
          )
        : showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) => AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              backgroundColor: Theme.of(context).colorScheme.background,
              title: title,
              content: content,
              actions: actions,
            ),
          );
  }
}
