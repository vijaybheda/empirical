// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void customAlert(
  context, {
  required Text title,
  required Text content,
  required List<Widget> actions,
}) {
  Platform.isIOS || Platform.isMacOS
      ? showCupertinoDialog<String>(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
            title: title,
            content: content,
            actions: actions,
          ),
        )
      : showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))),
            backgroundColor: Theme.of(context).colorScheme.background,
            title: title,
            content: content,
            actions: actions,
          ),
        );
}
