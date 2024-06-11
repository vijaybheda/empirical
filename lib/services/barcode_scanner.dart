import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class BarcodeScanner {

  static const _channel = MethodChannel('com.example.barcode_scan');

  static Future<String?> scanBarcode() async {
    try {
      final String? barcode = await _channel.invokeMethod('scanBarcode');
      return barcode;
    } on PlatformException catch (e) {
      debugPrint("Failed to scan barcode: ${e.message}");
      return null;
    }
  }
}