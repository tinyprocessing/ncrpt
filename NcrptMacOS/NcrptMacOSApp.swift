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
        DocumentGroup(newDocument: NcrptMacOSDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
