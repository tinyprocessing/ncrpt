//
//  TabRender.swift
//  NcrptMacOS
//
//  Created by Michael Safir on 16.03.2023.
//

import Foundation
import Cocoa
import QuickLookUI
import SwiftUI

class FileRender: NSViewController {
    
    override func loadView() {
        
        view = NSView(frame: NSMakeRect(0.0, 0.0, 0, 0))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        
        let controller = NSHostingController(rootView: QLViewer(url: Bundle.main.url(forResource: "Bar_1_2015",
                                                                                                  withExtension: "pdf")!))
        let viewVC = controller.view

        DispatchQueue.main.async {
            self.view.addSubview(viewVC)

            viewVC.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                viewVC.topAnchor.constraint(equalTo: self.view.topAnchor),
                viewVC.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                viewVC.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                viewVC.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            ])
        }
    }
    
    override func viewDidLoad() {
        
    }
    
    override func viewWillAppear() {

    }
    
    override func viewWillDisappear() {

    }
}
