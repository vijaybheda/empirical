import UIKit
import Flutter
import CoreLocation
import Network
import MTBBarcodeScanner

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler{
    
    var flutterEventChannel = FlutterEventChannel()
    var eventSink: FlutterEventSink?
    let monitor = NWPathMonitor()
    var isConnected = false
    private var scanner: MTBBarcodeScanner?
    private var result: FlutterResult?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        let flutterViewController : FlutterViewController = window?.rootViewController as! FlutterViewController
        flutterEventChannel = FlutterEventChannel(name: "ver-ify/wifi-channel", binaryMessenger: flutterViewController.binaryMessenger)
        flutterEventChannel.setStreamHandler(self)

        monitor.start(queue: DispatchQueue(label: "NetworkMonitor"))
        monitor.pathUpdateHandler = { (path) in
            if path.status == .satisfied {
                print("Connected")
                self.sendEventToFlutter(rssi: true)
            } else {
                print("Not Connected")
                self.sendEventToFlutter(rssi: false)
            }
        }

        // Setup method channel for barcode scanning
        let channel = FlutterMethodChannel(name: "com.example.barcode_scan", binaryMessenger: flutterViewController.binaryMessenger)
        channel.setMethodCallHandler(handleMethodCall)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        //        BeaconsSetting.shared.stopGettingRSSI()
        return nil
    }
    
    func sendEventToFlutter(rssi: Bool) {
        print("RSSI ==========>>>>>>>>>> ", rssi)
        eventSink?(rssi)
    }

    // Method to handle method calls
    private func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "scanBarcode" {
            self.result = result
            startScanning()
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    // Method to start barcode scanning
    private func startScanning() {
        guard let controller = window?.rootViewController else {
            result?("Failed to start scanning: No root view controller")
            return
        }

        let scanView = UIView(frame: controller.view.bounds)
        scanView.backgroundColor = .white
        controller.view.addSubview(scanView)

        scanner = MTBBarcodeScanner(previewView: scanView)
        MTBBarcodeScanner.requestCameraPermission { [weak self] success in
            guard let self = self else { return }
            if success {
                do {
                    try self.scanner?.startScanning(resultBlock: { codes in
                        if let codes = codes {
                            let codeString = codes.compactMap { $0.stringValue }.joined(separator: "\n")
                            self.scanner?.stopScanning()
                            scanView.removeFromSuperview()
                            self.result?(codeString)
                        }
                    })
                } catch {
                    self.result?("Failed to start scanning: \(error.localizedDescription)")
                }
            } else {
                self.result?("Failed to get camera permission")
            }
        }
    }
}

// MARK: Get singal strenght

extension AppDelegate : CLLocationManagerDelegate
{
    func isConnectedToNetwork() -> Bool {
        return self.isConnected
    }
}
