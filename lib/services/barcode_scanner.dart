import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:get/get.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  Code? result;

  int failedScans = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ReaderWidget(
            onScan: _onScanSuccess,
            onScanFailure: _onScanFailure,
            onControllerCreated: _onControllerCreated,
            scanDelay: const Duration(milliseconds: 500),
            resolution: ResolutionPreset.high,
            lensDirection: CameraLensDirection.back,
            tryHarder: true,
            codeFormat: Format.code128,
            showGallery: false,
            isMultiScan: false,
            allowPinchZoom: true,
          ),
        ],
      ),
    );
  }

  void _onControllerCreated(_, Exception? error) {
    if (error != null) {
      // Handle permission or unknown errors
      // _showMessage(context, 'Error: $error');
    }
  }

  _onScanSuccess(Code? code) {
    result = code;
    Get.back(result: result?.text);
  }

  _onScanFailure(Code? code) {
    failedScans++;
    if (code != null) {
      result = code;
    }
    // if (failedScans > 10) {
    //   Get.back();
    // }
  }

  /*_showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }*/
}
