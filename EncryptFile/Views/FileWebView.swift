//
//  FileWebView.swift
//  EncryptFile
//
//  Created by Kirill Anisimov on 02.01.2023.
//

import SwiftUI
import WebKit

struct FileWebView: UIViewRepresentable {
    typealias UIViewType = CustomWKWebView
    
    var url: URL
    
    func makeUIView(context: Context) -> CustomWKWebView {
        let webView = CustomWKWebView()
        webView.loadFileURL(url, allowingReadAccessTo: url)
        return webView
    }
    
    func updateUIView(_ uiView: CustomWKWebView, context: Context) { }
}

class CustomWKWebView: WKWebView {
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        disableDragAndDrop()
    }
    
    func disableDragAndDrop() {
        func findInteractionView(in subviews: [UIView]) -> UIView? {
            for subview in subviews {
                for interaction in subview.interactions {
                    if interaction is UIDragInteraction {
                        return subview
                    }
                }
                return findInteractionView(in: subview.subviews)
            }
            return nil
        }
        
        if let interactionView = findInteractionView(in: subviews) {
            for interaction in interactionView.interactions {
                if interaction is UIDragInteraction || interaction is UIDropInteraction {
                    interactionView.removeInteraction(interaction)
                    interactionView.isUserInteractionEnabled = false
                }
            }
        }
    }
}
