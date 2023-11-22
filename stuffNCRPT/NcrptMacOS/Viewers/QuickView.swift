//
//  QuickView.swift
//  NcrptMacOS
//
//  Created by Michael Safir on 16.01.2023.
//

import Foundation
import Quartz
import SwiftUI

var print_view = QLPreviewView()

class PreviewItem: NSObject, QLPreviewItem {
    var previewItemURL: URL
    var previewItemTitle: String
    init(URL: Foundation.URL, title: String) {
        self.previewItemURL = URL
        self.previewItemTitle = title
    }
}


struct QuickKitRepresentedView: NSViewRepresentable {
    
    typealias NSViewType = QLPreviewView
    
    
    let url: URL
    let title: String
    
    init(_ url: URL, title: String = "") {
        self.url = url
        self.title = title
    }
    
    func makeNSView(context _: NSViewRepresentableContext<QuickKitRepresentedView>) -> NSViewType {
        let view = QLPreviewView()
        view.previewItem = PreviewItem(URL: self.url, title: self.title)
        view.shouldCloseWithWindow = false
        return view
    }
    
    func updateNSView(_ view: NSViewType, context _: NSViewRepresentableContext<QuickKitRepresentedView>) {
        
        
        if (view.previewItem != nil){
            view.previewItem = PreviewItem(URL: self.url, title: self.title)
            print_view = view
        }
        
    }
}


