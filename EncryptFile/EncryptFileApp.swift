//
//  EncryptFileApp.swift
//  EncryptFile
//
//  Created by Michael Safir on 25.10.2022.
//

import SwiftUI

@main
struct EncryptFileApp: App {
    
    @State var isLoggedIn = true
    
    var body: some Scene {
        WindowGroup {
            Group {
                if !isLoggedIn {
                    LoginView(isLoggedIn: $isLoggedIn)
                } else {
                    ContentView()
                        .onAppear{
                            let rsa = RSA()
                            rsa.start()
                            let network = Network()
                            network.publicServerKey()
                        }
                        .transition(.move(edge: .trailing))
                }
            }.animation(.default, value: isLoggedIn)
        }
    }
}
