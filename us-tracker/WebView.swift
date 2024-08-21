//
//  WebView.swift
//  us-tracker
//
//  Created by Jason Morales on 8/15/24.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let url = URL(string: "https://usmnt-tracker.com/")
        if let url = url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

}

#Preview {
    WebView()
}
