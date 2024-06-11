package com.trt.verify

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.zxing.integration.android.IntentIntegrator
import com.google.zxing.integration.android.IntentResult
import android.content.Intent
class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.barcode_scan"
    private var result: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == "scanBarcode") {
                setResultHandler(res)
                scanBarcode(result)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun setResultHandler(res: MethodChannel.Result) { result = res
        // Set the result handler in a method to avoid scope issues
        }

    private fun scanBarcode(result: MethodChannel.Result) {
        initiateScan()
        //IntentIntegrator(this).initiateScan()
    }

    private fun initiateScan() {
        val integrator = IntentIntegrator(this)
        integrator.setDesiredBarcodeFormats(IntentIntegrator.ALL_CODE_TYPES)
        integrator.setPrompt("Scan a barcode")
        integrator.setCameraId(0)  // Use a specific camera of the device
        integrator.setBeepEnabled(true)
        integrator.setBarcodeImageEnabled(true)
        integrator.initiateScan()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
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
    }
}
