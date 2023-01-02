//
//  EncryptFileApp.swift
//  EncryptFile
//
//  Created by Michael Safir on 25.10.2022.
//

import SwiftUI
import Foundation
import LocalAuthentication

@main
struct EncryptFileApp: App {
    @AppStorage("appearance") var appearance: Appearance = .automatic
    
    @State var isLoggedIn = true
    @State var opacity : Double = 1.0
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject var api: NCRPTWatchSDK = NCRPTWatchSDK.shared
    
    
    var body: some Scene {
        WindowGroup {
            Group {
                ZStack{
                    switch api.ui {
                    case .auth:
                        LoginView()
                    case .pin:
                        PinEntryView()
                    case .pinCreate:
                        PinEntryView()
                    case .error:
                        Text("Error")
                    case .loading:
                        Loading()
                    case .ready:
                        ContentView()
                            .transition(.move(edge: .trailing))
                    default:
                        Loading()
                    }
                    if self.api.needBlur {
                        VisualEffect(style: .prominent)
                            .edgesIgnoringSafeArea(.all)
                    }
                }
            }
            .opacity(self.opacity)
            .navigationViewStyle(StackNavigationViewStyle())
            .accentColor(.black)
            .preferredColorScheme(appearance.getColorScheme())
            .onAppear{
                
                let rsa = RSA()
                rsa.start()
                
                api.setupSecureView()
                log.debug(module: "EncryptFileApp", type: #function, object: "Application Started")
                Settings.shared.cleanCache()
                let defaults = UserDefaults.standard
                let username = defaults.string(forKey: UserDefaults.Keys.AuthorizationUsername.rawValue) ?? ""
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    if username.isEmpty {
                        defaults.reset()
                        log.debug(type: "EncryptFileApp", object: "User is not logged")
                        self.api.ui = .auth
                    }else{
                        log.debug(type: "EncryptFileApp", object: "User need pin code")
                        self.api.ui = .pin
                        if defaults.bool(forKey: UserDefaults.Keys.SettingsFaceID.rawValue) {
                            let context = LAContext()
                            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Please authenticate to proceed.") { (success, error) in
                                    if success {
                                        DispatchQueue.main.async {
                                            withAnimation{
                                                NCRPTWatchSDK.shared.ui = .loading
                                            }
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            withAnimation{
                                                NCRPTWatchSDK.shared.ui = .ready
                                            }
                                            //close screen
                                        }
                                    } else {
                                        guard let error = error else { return }
                                        print(error.localizedDescription)
                                    }
                                }
                            }
                        }
                    }
                })
            }
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
}



struct Loading: View {
    
    @State var animating : Bool = true
    
    var body: some View {
        VStack(spacing: 20){
            Image("NCRPTBlue")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 126, height: 157, alignment: .center)
            
            ActivityIndicator(isAnimating: self.$animating, style: .large)
                .padding()
            
        }
    }
}


