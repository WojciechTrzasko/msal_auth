import Flutter
import MSAL
import UIKit

/// WebView support
public class MsalAuthWebViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    private var plugin: MsalAuthPlugin

    init(
        messenger: FlutterBinaryMessenger,
        plugin: MsalAuthPlugin
    ) {
        self.messenger = messenger
        self.plugin = plugin
        
        super.init()
    }
    
    public func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return MsalAuthWebView(
            plugin: plugin,
            frame: frame,
            viewIdentifier: viewId,
            arguments: args as? [String: Any],
            binaryMessenger: messenger
        )
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

public class MsalAuthWebView: NSObject, FlutterPlatformView {
    private var webView: WKWebView
    private var channel: FlutterMethodChannel?
    private var plugin: MsalAuthPlugin
    
    init(
        plugin: MsalAuthPlugin,
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: [String: Any]?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        self.plugin = plugin
        webView = WKWebView(frame: frame)
        channel = FlutterMethodChannel(name: "msal_auth_web_view_channel", binaryMessenger: messenger)
        
        super.init()
        
        guard
            let scopes = args?["scopes"] as? [String],
            let prompt = args?["prompt"] as? String
        else {
            let errorArguments: [String: Any] = [
                "code": "INTERNAL_ERROR",
                "message": "Invalid data has been provided to MsalAuthWebView.",
                "details": "invalid_data"
            ]
            
            channel?.invokeMethod("onAuthError", arguments: errorArguments)
            return
        }
        
        let promptType: MSALPromptType = plugin.parse(prompt: prompt)
        
        plugin.acquireToken(
            scopes: scopes,
            promptType: promptType,
            loginHint: nil,
            customWebView: webView,
            result: { [weak channel] result in
                if let error = result as? FlutterError {
                    let errorArguments: [String: Any] = [
                        "code": error.code,
                        "message": error.message ?? "",
                        "details": error.details ?? ""
                    ]
                    channel?.invokeMethod("onAuthError", arguments: errorArguments)
                } else {
                    channel?.invokeMethod("onAuthFinished", arguments: nil)
                }
            }
        )
    }

    public func view() -> UIView {
        return webView
    }
}
