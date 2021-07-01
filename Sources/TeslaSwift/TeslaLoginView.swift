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
    let model: TeslaModel
    
    public func makeCoordinator() -> WebCoordinator {
        return WebCoordinator(presentation: mode, model: model)
    }
    
    private let initial: URL
    
    init(url: URL, model: TeslaModel) {
        self.initial = url
        self.model = model
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        let WKWebview = WKWebView(frame: .zero)
        WKWebview.navigationDelegate = context.coordinator
        return WKWebview
    }
    
    public func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: initial))
    }
    
    
}

public class WebCoordinator: NSObject, WKNavigationDelegate {
    private let presentation: Binding<PresentationMode>
    private let model: TeslaModel
    
    init(presentation: Binding<PresentationMode>, model: TeslaModel) {
        self.presentation = presentation
        self.model = model
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    
        print("RCS Navigation \(navigationAction)")
        if let url = navigationAction.request.url, url.absoluteString.starts(with: "https://auth.tesla.com/void/callback")  {
            decisionHandler(.cancel)
            presentation.wrappedValue.dismiss()
            model.handleCode(url)
        } else {
            decisionHandler(.allow)
        }
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        // Handle failure here
//        self.result?(Result.failure(TeslaError.authenticationFailed))
        presentation.wrappedValue.dismiss()
    }
}


