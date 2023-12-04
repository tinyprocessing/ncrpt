import CommonCrypto
import Foundation
import openssl
import Security
import SwiftUI

let kSecClassValue = kSecClass as String
let kSecAttrAccountValue = kSecAttrAccount as String
let kSecValueDataValue = kSecValueData as String
let kSecClassGenericPasswordValue = kSecClassGenericPassword as String
let kSecAttrServiceValue = kSecAttrService as String
let kSecMatchLimitValue = kSecMatchLimit as String
let kSecReturnDataValue = kSecReturnData as String
let kSecMatchLimitOneValue = kSecMatchLimitOne as String

class Keychain: ObservableObject, Identifiable {
    @Published var helper = KeychainHelper()
    @Published var certification = Certification()
}
