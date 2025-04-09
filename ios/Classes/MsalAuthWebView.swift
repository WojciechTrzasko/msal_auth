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
    private var plugin: MsalAuthPlugin
    
    init(
        plugin: MsalAuthPlugin,
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: [String: Any]?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        self.plugin = plugin
        webView = WKWebView(frame: frame)
        
        super.init()
        
        guard let scopes = args?["scopes"] as? [String] else {
            // TODO(wtrzasko): Throw error?
            return
        }
        
        plugin.acquireToken(
            scopes: scopes,
            promptType: .login,
            loginHint: nil,
            customWebview: webView,
            result: { _ in
            }
        )
    }

    public func view() -> UIView {
        return webView
    }
}
