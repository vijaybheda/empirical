import UIKit
import Flutter
import CoreLocation
import Network

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler{
    
    var flutterEventChannel = FlutterEventChannel()
    var eventSink: FlutterEventSink?
    let monitor = NWPathMonitor()
    var isConnected = false

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
}

// MARK: Get singal strenght

extension AppDelegate : CLLocationManagerDelegate
{
    func isConnectedToNetwork() -> Bool {
        return self.isConnected
    }
}
