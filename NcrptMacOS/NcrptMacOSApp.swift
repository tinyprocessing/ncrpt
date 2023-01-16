//
//  NcrptMacOSApp.swift
//  NcrptMacOS
//
//  Created by Michael Safir on 16.01.2023.
//

import SwiftUI

@main
struct NcrptMacOSApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        DocumentGroup(viewing: DecryptDocument.self) { file in
            FileView(urlFromFinder: file.fileURL,
                        documentFromFinder: file.document,
                        file: file)
            .onAppear {
                NSWindow.allowsAutomaticWindowTabbing = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    NSApp.sendAction(#selector(NSWindow.mergeAllWindows(_:)), to: nil, from: nil)
                    NSApplication.shared.keyWindow?.titleVisibility = .hidden

                    NSApplication.shared.windows.forEach { window in
                        window.titleVisibility = .hidden
                    }
                }
            }

        }
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
                
                showInFinderAndSelectLastComponent(of: FileManager.default.urls(for: .libraryDirectory,
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
        Button("О программе") {
//            let contentView = AboutAppView().padding()
//
//            window = NSWindow(
//                contentRect: NSRect(x: 0, y: 0, width: 600, height: 640),
//                styleMask: [.closable, .miniaturizable, .fullSizeContentView, .titled, .resizable],
//                backing: .buffered, defer: false)
//
//            window.isReleasedWhenClosed = false
//            window.center()
//            window.setFrameAutosaveName("NCRPT - Settings")
//            window.contentView = NSHostingView(rootView: contentView)
//            window.makeKeyAndOrderFront(nil)
//            window.titlebarAppearsTransparent = true
//            window.titleVisibility = .visible
        }
    }
    
    
    
}
