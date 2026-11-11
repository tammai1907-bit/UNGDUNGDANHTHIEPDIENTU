import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let channel = FlutterMethodChannel(
      name: "com.digitalbusinesscard.digital_business_card/gallery",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      if call.method == "saveImage",
         let args = call.arguments as? [String: Any],
         let typedData = args["bytes"] as? FlutterStandardTypedData,
         let image = UIImage(data: typedData.data) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        result("saved_to_photos")
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
