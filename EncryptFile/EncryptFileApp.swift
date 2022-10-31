//
//  EncryptFileApp.swift
//  EncryptFile
//
//  Created by Michael Safir on 25.10.2022.
//

import SwiftUI

@main
struct EncryptFileApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear{
                    let rsa = RSA()
                    rsa.start()
                    let network = Network()
                    network.publicServerKey()
                }
        }
    }
}
