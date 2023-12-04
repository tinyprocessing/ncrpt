import Combine
import Foundation
import SwiftUI
import SwiftyJSON
import UIKit

public class NCRPTAuthSDK: NSObject, ObservableObject, Identifiable, URLSessionDelegate, URLSessionTaskDelegate {
    @Published var login = ""
    @Published var password = ""
    @Published var passwordRecover = false

    static var shared: NCRPTAuthSDK = {
        let instance = NCRPTAuthSDK()
        return instance
    }()

    public func loadFromKeychain(_ path: String) -> String {
        let service = "NCRPTAuth"
        let account = path
        let keychain = Keychain()
        if let search = keychain.helper.loadPassword(service: service, account: account) {
            if !search.isEmpty {
                return search
            }
        }

        return ""
    }

    public func saveToKeychain(_ path: String, _ data: String) {
        let service = "NCRPTAuth"
        let account = path
        let keychain = Keychain()
        keychain.helper.removePassword(service: service, account: account)
        keychain.helper.savePassword(service: service, account: account, data: data)
    }

    public func removeFromKeychain(_ path: String) {
        let service = "NCRPTAuth"
        let account = path
        let keychain = Keychain()
        keychain.helper.removePassword(service: service, account: account)
    }

    public func containsCachePasscode() {
        let passCache: String = loadFromKeychain("IRMPin")
        if passCache == "" {
            let keychain = Keychain()
            keychain.helper.deleteKeyChain()
        }
    }

    public func verifyPasscode(passcode: String) -> Bool {
        let passCache: String = loadFromKeychain("IRMPin")
        if passcode == passCache {
            DispatchQueue.main.async {
                NCRPTWatchSDK.shared.objectWillChange.send()
                withAnimation {
                    NCRPTWatchSDK.shared.ui = .loading
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NCRPTWatchSDK.shared.ui = .ready
            }
            return true
        } else {
            return false
        }
    }

    public func savePasscode(passcode: String) {
        saveToKeychain("IRMPin", passcode)
        DispatchQueue.main.async {
            withAnimation {
                NCRPTWatchSDK.shared.ui = .loading
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                NCRPTWatchSDK.shared.ui = .ready
            }
            // close screen
        }
    }
}
