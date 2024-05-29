import 'package:flutter/material.dart';

class CustomProgressDialog {
  final BuildContext context;
  late AlertDialog _dialog;

  CustomProgressDialog({required this.context}) {
    _dialog = const AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 20),
          Text("Loading..."),
        ],
      ),
    );
  }

  void show() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => _dialog,
    );
  }

  void hide() {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
