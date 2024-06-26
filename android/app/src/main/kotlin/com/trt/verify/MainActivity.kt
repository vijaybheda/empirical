package com.trt.verify

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.barcode_scan"
    private var result: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "scanBarcode") {
//                setResultHandler(result)
//                initiateScan()
            } else {
                result.notImplemented()
            }
        }
    }

    /*private fun setResultHandler(res: MethodChannel.Result) {
        result = res
    }*/

    /*private fun initiateScan() {
        val integrator = IntentIntegrator(this)
        integrator.setDesiredBarcodeFormats(IntentIntegrator.ALL_CODE_TYPES)
        integrator.setPrompt("Scan a barcode")
        integrator.setCameraId(0)
        integrator.setBeepEnabled(true)
        integrator.setBarcodeImageEnabled(true)
        integrator.initiateScan()
    }*/

    /* override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
         super.onActivityResult(requestCode, resultCode, data)
         val scanResult = IntentIntegrator.parseActivityResult(requestCode, resultCode, data) as IntentResult
         if (scanResult != null) {
             if (scanResult.contents == null) {
                 result?.success("")
             } else {
                 result?.success(scanResult.contents)
             }
         } else {
             result?.error("UNAVAILABLE", "Barcode scan failed", null)
         }
     }*/
}
