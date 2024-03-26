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
        
        let flutterViewController : FlutterViewController = window?.rootViewController as! FlutterViewController
        
        flutterEventChannel = FlutterEventChannel(name: "ver-ify/wifi-channel", binaryMessenger: flutterViewController.binaryMessenger)
        flutterEventChannel.setStreamHandler(self)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        self.sendEventToFlutter(rssi: AppDelegate.getSignal())
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        //        BeaconsSetting.shared.stopGettingRSSI()
        return nil
    }
    
    func sendEventToFlutter(rssi: Int) {
        print("RSSI ==========>>>>>>>>>> ", rssi)
        eventSink?(rssi)
    }
    
}

// MARK: Get singal strenght

extension AppDelegate
{
    static func getSignal() -> Int {
        if #available(iOS 13.0, *) {
            if let statusBarManager = UIApplication.shared.keyWindow?.windowScene?.statusBarManager,
               let localStatusBar = statusBarManager.value(forKey: "createLocalStatusBar") as? NSObject,
               let statusBar = localStatusBar.value(forKey: "statusBar") as? NSObject,
               let _statusBar = statusBar.value(forKey: "_statusBar") as? UIView,
               let currentData = _statusBar.value(forKey: "currentData")  as? NSObject,
               let celluar = currentData.value(forKey: "cellularEntry") as? NSObject,
               let signalStrength = celluar.value(forKey: "displayValue") as? Int {
                return signalStrength
            } else {
                return 0
            }
        } else {
            var signalStrength = -1
            let application = UIApplication.shared
            let statusBarView = application.value(forKey: "statusBar") as! UIView
            let foregroundView = statusBarView.value(forKey: "foregroundView") as! UIView
            let foregroundViewSubviews = foregroundView.subviews
            var dataNetworkItemView: UIView!
            for subview in foregroundViewSubviews {
                if subview.isKind(of: NSClassFromString("UIStatusBarSignalStrengthItemView")!) {
                    dataNetworkItemView = subview
                    break
                } else {
                    signalStrength = -1
                }
            }
            signalStrength = dataNetworkItemView.value(forKey: "signalStrengthBars") as! Int
            if signalStrength == -1 {
                return 0
            } else {
                return signalStrength
            }
        }
    }
}


extension UIApplication {
    var statusBarUIView: UIView? {
        if #available(iOS 13.0, *) {
            let tag = 38482458385
            if let statusBar = self.keyWindow?.viewWithTag(tag) {
                return statusBar
            } else {
                let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
                statusBarView.tag = tag
                
                self.keyWindow?.addSubview(statusBarView)
                return statusBarView
            }
        } else {
            if responds(to: Selector(("statusBar"))) {
                return value(forKey: "statusBar") as? UIView
            }
        }
        return nil
    }
}
