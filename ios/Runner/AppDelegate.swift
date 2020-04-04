import UIKit
import Flutter
import GoogleMaps


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    var keys: NSDictionary?
    if let path = NSBundle.mainBundle().pathForResource("Constants", ofType: "plist") {
        keys = NSDictionary(contentsOfFile: path)
    }
    if let dict = keys {
        let GoogleCloudAPI = dict["GoogleMapAPI"] as? String

        GMSServices.provideAPIKey(GoogleCloudAPI!)
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
