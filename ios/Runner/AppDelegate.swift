import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let mlChannel = FlutterMethodChannel(
      name: "com.tinyclaw/ml",
      binaryMessenger: controller.binaryMessenger
    )

    mlChannel.setMethodCallHandler { (call, result) in
      switch call.method {
      case "loadModel":
        // TODO: Load Core ML model
        result(nil)
      case "unloadModel":
        // TODO: Unload Core ML model
        result(nil)
      case "predict":
        // TODO: Run inference with Core ML
        result("Stub response from iOS")
      case "memoryUsage":
        // TODO: Query model memory usage
        result(0)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
