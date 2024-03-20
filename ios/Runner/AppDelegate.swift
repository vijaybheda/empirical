import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler{
    
var flutterEventChannel = FlutterEventChannel()
var eventSink: FlutterEventSink?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      
//      flutterEventChannel = FlutterEventChannel(name: "com.verify/wifiStrength", binaryMessenger: flutterViewController.binaryMessenger)
//      flutterEventChannel.setStreamHandler(self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        // Wifi strength function need to call
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
//        BeaconsSetting.shared.stopGettingRSSI()
        return nil
    }

    // After getting value of Network strength need to call this
//    func sendEventToFlutter(rssi: Int) {
//        print("RSSI ==========>>>>>>>>>> ", rssi)
//        eventSink?(rssi)
//    }
}
