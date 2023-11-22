//
//  NcrptMacOSApp.swift
//  NcrptMacOS
//
//  Created by Michael Safir on 16.01.2023.
//

import SwiftUI

extension Scene {
    func windowResizabilityContentSize() -> some Scene {
        if #available(macOS 13.0, *) {
            return windowResizability(.contentSize)
        } else {
            return self
        }
    }
}


@main
struct NcrptMacOSApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        
        WindowGroup{
            HomeView()
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowResizabilityContentSize()
        
        .commands {
            MenuCommands()
        }
    }
}

//MARK: - MenuCommands:
struct MenuCommands: Commands {
    var body: some Commands {
        
        CommandGroup(replacing: .appInfo) {
            
        }
        
        CommandGroup(after: .appInfo) {
            aboutAppButton
        }
        
        
        CommandGroup(after: .appInfo) {
            Button {
                
                let dateFormatterGet = DateFormatter()
                dateFormatterGet.dateFormat = "yyyy-MM-dd"
                
                showInFinderAndSelectLastComponent(of: FileManager.default.urls(for: .documentDirectory,
                                                                                in: .userDomainMask)[0].appendingPathComponent("\(Bundle.main.bundleIdentifier!)/logs/ncrpt_\(dateFormatterGet.string(from: Date())).log"))
            } label: {
                Text("Logs")
            }
        }
        
        CommandGroup(replacing: .appVisibility) {
            Button("Hide") {
                NSApplication.shared.hide(nil)
            }.keyboardShortcut("h")
        }
        
        CommandGroup(replacing: .appTermination) {
            Button("Close") {
                NSApplication.shared.terminate(nil)
            }.keyboardShortcut("q")
        }
        
        
        CommandGroup(replacing: .help) {
            Button("Support"){
                let sberIRMLink = URL(string: "https://ncrpt.io/support")
                NSWorkspace.shared.open(sberIRMLink!)
            }
        }
     
        
        //removed commands:
        CommandGroup(replacing: .systemServices) {}
        CommandGroup(replacing: .saveItem) {}
        CommandGroup(replacing: .undoRedo) {}
        
    }
    
    var aboutAppButton: some View {
        Button("About ncrpt.io") {
        }
    }
    
    
    
}
