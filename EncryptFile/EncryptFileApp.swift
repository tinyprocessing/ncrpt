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
    @State var opacity : Double = 0.0
    
    var body: some Scene {
        WindowGroup {
            Group {
                if !isLoggedIn {
                    LoginView(isLoggedIn: $isLoggedIn)
                } else {
                    ContentView()
                        .onAppear{
//                            let rsa = RSA()
//                            rsa.start()
//                            let network = Network()
//                            network.publicServerKey()
                        }
                        .transition(.move(edge: .trailing))
                }
            }
            .opacity(self.opacity)
            .onAppear{
                let defaults = UserDefaults.standard
                let username = defaults.string(forKey: "username") ?? ""
                if username.isEmpty {
                    self.isLoggedIn = false
                }else{
                    self.isLoggedIn = true
                    let keychain = Keychain()
                    keychain.certification.getCertificate()
                    print(keychain.certification.loadIdentity())
                }
                withAnimation{
                    self.opacity = 1.0
                }
            }
        }
    }
}
