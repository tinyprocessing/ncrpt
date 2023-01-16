//
//  PDFView.swift
//  NcrptMacOS
//
//  Created by Michael Safir on 16.01.2023.
//

import Foundation
import SwiftUI
import PDFKit

struct PDFKitRepresentedView: NSViewRepresentable {
    
    typealias NSViewType = PDFView
    
    @Binding var content: ContentDecrypt
    let data: URL
    let singlePage: Bool

    init(_ data: URL,_ content: Binding<ContentDecrypt>, singlePage: Bool = false) {
        self.data = data
        self._content = content
        self.singlePage = singlePage
    }

    func makeNSView(context _: NSViewRepresentableContext<PDFKitRepresentedView>) -> NSViewType {
        // Create a `PDFView` and set its `PDFDocument`.
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: self.data)
        pdfView.autoScales = true
        if singlePage {
            pdfView.displayMode = .singlePage
        }
        return pdfView
    }

    func updateNSView(_ pdfView: NSViewType, context _: NSViewRepresentableContext<PDFKitRepresentedView>) {
        pdfView.document =  PDFDocument(url: self.data)
        pdfView.scroll(NSPoint(x: 0, y: 0))
    }
}


struct ActivityIndicator: NSViewRepresentable {
    
    typealias NSViewType = NSProgressIndicator


    func makeNSView(context _: NSViewRepresentableContext<ActivityIndicator>) -> NSViewType {
        // Create a `PDFView` and set its `PDFDocument`.
        let pi = NSProgressIndicator(frame: NSRect(x: 0, y: 0, width: 30, height: 30))
        pi.style = .spinning
        pi.startAnimation(self)
        return pi
    }

    func updateNSView(_ pdfView: NSViewType, context _: NSViewRepresentableContext<ActivityIndicator>) {
      
    }
}
