//
//  Keychain.swift
//  EncryptFile
//
//  Created by Сафир Михаил Дмитриевич [B] on 31.10.2022.
//

import CommonCrypto
import Foundation
import Security
import SwiftUI
import openssl

let kSecClassValue = kSecClass as String
let kSecAttrAccountValue = kSecAttrAccount as String
let kSecValueDataValue = kSecValueData as String
let kSecClassGenericPasswordValue = kSecClassGenericPassword as String
let kSecAttrServiceValue = kSecAttrService as String
let kSecMatchLimitValue = kSecMatchLimit as String
let kSecReturnDataValue = kSecReturnData as String
let kSecMatchLimitOneValue = kSecMatchLimitOne as String

class Keychain: ObservableObject, Identifiable {
    @Published var helper: KeychainHelper = KeychainHelper()
    @Published var certification: Certification = Certification()
}
