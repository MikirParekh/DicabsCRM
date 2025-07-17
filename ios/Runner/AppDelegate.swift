import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    private let channelName = "com.uniqtech.dicabs/tracking"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller = window?.rootViewController as! FlutterViewController
            let methodChannel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)

            methodChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
                switch call.method {
                case "startTracking":
                    self?.startTracking()
                    result(nil)
                case "stopTracking":
                    self?.stopTracking()
                    result(nil)
                default:
                    result(FlutterMethodNotImplemented)
                }
            }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func startTracking() {
          // Start location tracking
          LocationManager.shared.startTracking()
      }

      private func stopTracking() {
          // Stop location tracking
          LocationManager.shared.stopTracking()
      }
}
