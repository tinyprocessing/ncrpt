//
//  FileWebView.swift
//  EncryptFile
//
//  Created by Kirill Anisimov on 02.01.2023.
//

import SwiftUI
import WebKit

struct FileWebView: UIViewRepresentable {
    let webView = CustomWKWebView()

    func updateUIView(_ uiView: UIView, context: Context) {

    }

    private func dismissMenu() {
        DispatchQueue.main.async {
            UIView.performWithoutAnimation {

            }
        }
    }

    var url: URL
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            if navigationAction.navigationType == .linkActivated {
                decisionHandler(.cancel)
            }
            else {
                decisionHandler(.allow)
            }
        }
    }

    func makeUIView(context: Context) -> UIView {
        self.webView.navigationDelegate = context.coordinator
        webView.loadFileURL(url, allowingReadAccessTo: url)

        NotificationCenter.default.addObserver(
            forName: UIMenuController.willShowMenuNotification,
            object: nil,
            queue: OperationQueue.main
        ) { (notification) in
            self.dismissMenu()
        }

        return webView
    }
}

class CustomWKWebView: WKWebView {

    override func didMoveToWindow() {
        super.didMoveToWindow()
        disableDragAndDrop()
    }

    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)

        builder.replaceChildren(ofMenu: .root) { oldChildren in
            return []
        }

        builder.replaceChildren(ofMenu: .share) { oldChildren in
            return []
        }

        builder.replaceChildren(ofMenu: .standardEdit) { oldChildren in
            return []
        }

        builder.replaceChildren(ofMenu: .lookup) { oldChildren in
            return []
        }

        //        builder.remove(menu: .root)
        builder.remove(menu: .share)
        builder.remove(menu: .lookup)
        builder.remove(menu: .standardEdit)

        UIView.performWithoutAnimation {

        }

    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
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
                if interaction is UIDragInteraction
                    || interaction is UIDropInteraction
                {
                    interactionView.removeInteraction(interaction)
                    interactionView.isUserInteractionEnabled = false
                }
            }
        }
    }
}
