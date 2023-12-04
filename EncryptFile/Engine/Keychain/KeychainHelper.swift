import Foundation
import openssl
import Security

public class KeychainHelper: ObservableObject, Identifiable {
    public func deleteKeyChain() {
        let secItemClasses = [kSecClassGenericPassword, kSecClassInternetPassword, kSecClassCertificate, kSecClassKey, kSecClassIdentity]
        for itemClass in secItemClasses {
            let spec: NSDictionary = [kSecClass: itemClass]
            SecItemDelete(spec)
        }
    }

    private func keychainAccessGroupIdentifier() -> String? {
        return Bundle.main.bundleIdentifier
    }

    func updatePassword(service: String, account: String, data: String, _ needLog: Bool = true) {
        if needLog {}

        if let dataFromString: Data = data.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            // Instantiate a new default keychain query
            let keychainQuery: [String: Any] = [kSecClassValue: kSecClassGenericPassword,
                                                kSecAttrServiceValue: service,
                                                kSecAttrAccountValue: account]

            let status = SecItemUpdate(keychainQuery as CFDictionary, [kSecValueDataValue: dataFromString] as CFDictionary)

            if status != errSecSuccess {
                if let err = SecCopyErrorMessageString(status, nil) {
                    if needLog {}
                }
            }
        }
    }

    func removePassword(service: String, account: String, _ needLog: Bool = true) {
        if needLog {}

        // Instantiate a new default keychain query
        let keychainQuery: [String: Any] = [kSecClassValue: kSecClassGenericPassword,
                                            kSecAttrServiceValue: service,
                                            kSecAttrAccountValue: account,
                                            kSecReturnDataValue: true]

        // Delete any existing items
        let status = SecItemDelete(keychainQuery as CFDictionary)
        if status != errSecSuccess {
            if let err = SecCopyErrorMessageString(status, nil) {
                if needLog {}
            }
        }
    }

    func savePassword(service: String, account: String, data: String, _ needLog: Bool = true) {
        if needLog {}

        if let dataFromString = data.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            // Instantiate a new default keychain query
            let keychainQuery: [String: Any] = [kSecClassValue: kSecClassGenericPassword,
                                                kSecAttrServiceValue: service,
                                                kSecAttrAccountValue: account,
                                                kSecValueDataValue: dataFromString]

            // Add the new keychain item
            let status = SecItemAdd(keychainQuery as CFDictionary, nil)

            if status != errSecSuccess { // Always check the status
                if let err = SecCopyErrorMessageString(status, nil) {
                    if needLog {}
                }
            }
        }
    }

    func loadPassword(service: String, account: String, _ needLog: Bool = true) -> String? {
        if needLog {}

        // Instantiate a new default keychain query
        // Tell the query to return a result
        // Limit our results to one item
        let keychainQuery: [String: Any] = [kSecClassValue: kSecClassGenericPassword,
                                            kSecAttrServiceValue: service,
                                            kSecAttrAccountValue: account,
                                            kSecReturnDataValue: true,
                                            kSecMatchLimitValue: kSecMatchLimitOneValue]

        var dataTypeRef: AnyObject?

        // Search for the keychain items
        let status: OSStatus = SecItemCopyMatching(keychainQuery as CFDictionary, &dataTypeRef)
        var contentsOfKeychain: String?

        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? Data {
                contentsOfKeychain = String(data: retrievedData, encoding: String.Encoding.utf8)
            }
        } else {
            if needLog {}
        }

        return contentsOfKeychain
    }
}
