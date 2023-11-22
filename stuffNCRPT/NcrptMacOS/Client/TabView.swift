//
//  TabView.swift
//  NcrptMacOS
//
//  Created by Michael Safir on 16.03.2023.
//

import Foundation
import Cocoa
import Quartz
import SwiftUI

class TabsController: NSViewController {

    var tabView: LYTabView = LYTabView()
    var tabBarView: LYTabBarView!
    lazy var window: NSWindow! = self.view.window
    
    override func loadView() {
        
        view = NSView(frame: NSMakeRect(0.0, 0.0, 400, 400))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        
        self.view.addSubview(self.tabView)
        self.tabView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.tabView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.tabView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.tabView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tabView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarView = tabView.tabBarView
        self.tabBarView.minTabHeight = 30
        self.tabBarView.minTabItemWidth = 120
        self.tabBarView.addNewTabButtonAction = #selector(addNewTab)
        self.tabBarView.addNewTabButtonTarget = self
        
        
    }

    override func viewWillAppear() {
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func addViewWithLabel(_ label: String, aTabBarView: LYTabBarView, fromTabView: Bool = false) {
        let item = NSTabViewItem()
        item.label = label
        item.color = .white
        if let labelViewController = self.storyboard?.instantiateController(withIdentifier:
            "labelViewController") {
            (labelViewController as AnyObject).setTitle(label)
            item.view = (labelViewController as AnyObject).view
        }
        if fromTabView {
            tabView.tabView.addTabViewItem(item)
        } else {
            let labelViewController = FileRender()
            item.viewController = labelViewController
            aTabBarView.addTabViewItem(item, animated: true)
            aTabBarView.tabView?.selectTabViewItem(item)
        }
    }

//    @IBAction func toggleAddNewTabButton(_ sender: AnyObject?) {
//        tabBarView.showAddNewTabButton = !tabBarView.showAddNewTabButton
//    }

    @objc func addNewTab(_ sender: AnyObject?) {
        if let tabBarView = (sender as? LYTabBarView) ?? self.tabBarView {
            let count = tabBarView.tabViewItems.count
            let label = "Untitled \(count)"
            addViewWithLabel(label, aTabBarView: tabBarView)
        }
    }

//    @IBAction func performCloseTab(_ sender: AnyObject?) {
//        if tabBarView.tabViewItems.count > 1 {
//            tabBarView.closeCurrentTab(sender)
//        } else {
//            self.view.window?.performClose(sender)
//        }
//    }

//    @IBAction func toggleTitleBar(_ sender: AnyObject?) {
//        if let window = self.view.window {
//            if window.titlebarAppearsTransparent {
//                window.titlebarAppearsTransparent = false
//                window.titleVisibility = .visible
//                window.styleMask.remove(.fullSizeContentView)
//                tabBarView.paddingWindowButton = false
//            } else {
//                window.titlebarAppearsTransparent = true
//                window.titleVisibility = .hidden
//                _ = window.styleMask.update(with: .fullSizeContentView)
//                tabBarView.paddingWindowButton = true
//            }
//        }
//    }

//    @IBAction func toggleBorder(_ sender: AnyObject?) {
//        switch tabBarView.borderStyle {
//        case .none:
//            tabBarView.borderStyle = .top
//        case .top:
//            tabBarView.borderStyle = .bottom
//        case .bottom:
//            tabBarView.borderStyle = .both
//        case .both:
//            tabBarView.borderStyle = .none
//        }
//    }
//
//    @IBAction func toggleActivity(_ sender: AnyObject?) {
//        tabBarView.isActive = !tabBarView.isActive
//    }
}

public struct TabsControllerSwiftUI: NSViewControllerRepresentable {
    public typealias NSViewControllerType = TabsController
    
    public func makeNSViewController(context: Context) -> TabsController {
        let vc = TabsController()
        return vc
    }
    
    public func updateNSViewController(_ nsViewController: TabsController, context: Context) {
        
    }
   
}

