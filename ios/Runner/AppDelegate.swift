import Flutter 
import UIKit
import WidgetKit //ウィジェットの表示を新しくしてね！と命令する道具

@main //Method Channel使用するルートAで必要
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        
        // 💡 Flutterの「com.example.thaiclock/widget」という通り道とガッチャンコするよ！
        let widgetChannel = FlutterMethodChannel(name: "com.example.thaiclock/widget",
                                                  binaryMessenger: controller.binaryMessenger)
        
        widgetChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            
            // 📸 1. Flutterから「updateWidgetImage」という命令が来たら実行
            if call.method == "updateWidgetImage" {
                guard let args = call.arguments as? [String: Any],
                      let imageData = args["imageData"] as? FlutterStandardTypedData else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "画像データが正しくないよ", details: nil))
                    return
                }
                
                if let sharedContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.example.thaiclockNew") {
                    let fileURL = sharedContainer.appendingPathComponent("widget_image.png")
                    
                    do {
                        try imageData.data.write(to: fileURL)
                        
                        if #available(iOS 14.0, *) {
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                        
                        result(true)
                    } catch {
                        result(FlutterError(code: "SAVE_FAILED", message: "画像の保存に失敗しちゃった", details: nil))
                    }
                } else {
                    result(FlutterError(code: "CONTAINER_NOT_FOUND", message: "App Groupが見つからないよ", details: nil))
                }
                
            // 🧹 2. Flutterから「clearWidgetImage」という命令が来たら実行（ここを追加！）
            } else if call.method == "clearWidgetImage" {
                if let sharedContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.example.thaiclockNew") {
                    let fileURL = sharedContainer.appendingPathComponent("widget_image.png")
                    
                    // すでに画像ファイルが存在していたら削除するよ
                    if FileManager.default.fileExists(atPath: fileURL.path) {
                        do {
                            try FileManager.default.removeItem(at: fileURL)
                        } catch {
                            print("画像の削除に失敗しました: \(error)")
                        }
                    }
                    
                    // 画像を消したあと、iOSに「ウィジェットの画面を更新してね！」と通知するよ
                    if #available(iOS 14.0, *) {
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                    
                    result(true)
                } else {
                    result(FlutterError(code: "CONTAINER_NOT_FOUND", message: "App Groupが見つからないよ", details: nil))
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
