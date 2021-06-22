//
//  TeslaLoginView.swift
//  TeslaSwift
//
//  Created by Ryan Spring on 6/21/21.
//  Copyright © 2021 Joao Nunes. All rights reserved.
//

import SwiftUI
import WebKit

public struct TeslaLoginView: UIViewRepresentable {
    @Environment(\.presentationMode) var mode
    
    public func makeCoordinator() -> WebCoordinator {
        return WebCoordinator(presentation: mode)
    }
    
    private let initial: URL
    
    public init(url: URL) {
        self.initial = url
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        let WKWebview = WKWebView(frame: .zero)
        WKWebview.navigationDelegate = context.coordinator
        return WKWebview
    }
    
    public func updateUIView(_ uiView: WKWebView, context: Context) {
        print("Updated Web View \(initial.absoluteString) \(uiView.frame.width), \(uiView.frame.height)")
        
        guard uiView.frame.width != 0 else {
            return
        }
        
        uiView.load(URLRequest(url: initial))
    }
}

public class WebCoordinator: NSObject, WKNavigationDelegate {
    private let presentation: Binding<PresentationMode>
    
    public init(presentation: Binding<PresentationMode>) {
        self.presentation = presentation
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        presentation.wrappedValue.dismiss()
        print("RCS Navigation \(navigationAction)")
//        if let url = navigationAction.request.url, url.absoluteString.starts(with: "https://auth.tesla.com/void/callback")  {
//            decisionHandler(.cancel)
////            self.dismiss(animated: true, completion: nil)
////            self.result?(Result.success(url))
//        } else {
            decisionHandler(.allow)
//        }
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        // Handle failure here
//        self.result?(Result.failure(TeslaError.authenticationFailed))
//        self.dismiss(animated: true, completion: nil)
    }
}


