//
//  AppDelegate.swift
//  NcrptMacOS
//
//  Created by Michael Safir on 16.01.2023.
//

import Foundation
import Cocoa
import SwiftUI

var window: NSWindow!

//@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var nsstatusitem : NSStatusItem?
    var nspopover = NSPopover()
    @ObservedObject var privacy : PrivacyMonitor = PrivacyMonitor.shared
    
    @State var isPopover = false
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        NSWindow.allowsAutomaticWindowTabbing = true
        UserDefaults.standard.set(false, forKey: "NSQuitAlwaysKeepsWindows")
        
        NSUpdateDynamicServices();
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            NSApp.sendAction(#selector(NSWindow.mergeAllWindows(_:)), to: nil, from: nil)
        }

    }
    
    //Removing unwanted menu items
    func applicationWillUpdate(_ notification: Notification) {
        if let menu = NSApplication.shared.mainMenu {
            if let file = menu.items.first(where: { $0.title == "Правка" || $0.title == "Edit"}) {
                menu.removeItem(file);
            }

            if let view = menu.items.first(where: { $0.title == "Вид" || $0.title == "View"}) {
                menu.removeItem(view);
            }
        }
    }
    
    
    
    @objc func menu_action(){
        if let menu_button = nsstatusitem?.button{
            self.nspopover.show(relativeTo: menu_button.bounds, of: menu_button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        self.privacy.hide = false
        return false
    }
    
    func applicationDidResignActive(_ notification: Notification) {
        withAnimation{
            self.privacy.hide = true
        }
        self.privacy.scene = "background"
    }
    func applicationDidBecomeActive(_ notification: Notification) {
        withAnimation{
            self.privacy.hide = false
        }
        self.privacy.scene = "active"

    }
    func applicationWillTerminate(_ aNotification: Notification) {
        print("close application")
    }
}


func alert(question: String, text: String) {
    let alert = NSAlert()
    alert.messageText = question
    alert.informativeText = text
    alert.alertStyle = .warning
    alert.addButton(withTitle: "ok")
    alert.addButton(withTitle: "cancel")
    alert.runModal()
}


