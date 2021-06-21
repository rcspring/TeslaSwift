//
//  TeslaLoginView.swift
//  TeslaSwift
//
//  Created by Ryan Spring on 6/21/21.
//  Copyright © 2021 Joao Nunes. All rights reserved.
//

import SwiftUI
import WebKit

public struct TeslLoginView: UIViewRepresentable {
    public func makeCoordinator() -> WebCoordinator {
        return WebCoordinator()
    }
    
    
    private let initial: URL
    
    public init(url: URL) {
        self.initial = url
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        let WKWebview = WKWebView(frame: .zero)
        return WKWebview
    }
    
    public func updateUIView(_ uiView: WKWebView, context: Context) {
        print("Updated Web View \(initial.absoluteString) \(uiView.frame.width), \(uiView.frame.height)")
        
        guard uiView.frame.width != 0 else {
            return
        }
        
        uiView.load(URLRequest(url: initial))
    }
    
    public class WebCoordinator: NSObject, WKNavigationDelegate {
        public func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
            print("Did Receive Navigation \(navigation)")
        }
    }
  
}


