//
//  Rsa.swift
//  EncryptFile
//
//  Created by Сафир Михаил Дмитриевич [B] on 31.10.2022.
//

import Foundation
import SwiftyRSA
import EllipticCurveKeyPair

struct KeyPair {
    static let manager: EllipticCurveKeyPair.Manager = {
        let publicAccessControl = EllipticCurveKeyPair.AccessControl(protection: kSecAttrAccessibleAlwaysThisDeviceOnly, flags: [])
        let privateAccessControl = EllipticCurveKeyPair.AccessControl(protection: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly, flags: [])
        let config = EllipticCurveKeyPair.Config(
            publicLabel: "ncrpt.aes.public",
            privateLabel: "ncrpt.aes.private",
            operationPrompt: "Server Operation",
            publicKeyAccessControl: publicAccessControl,
            privateKeyAccessControl: privateAccessControl,
            token: .keychain)
        return EllipticCurveKeyPair.Manager(config: config)
    }()
}

class RSA: ObservableObject, Identifiable  {
     
    func start(){
        
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: UserDefaults.Keys.RSASetup.rawValue)
        log.debug(module: "RSA", type: #function, object: "Loading RSA module")
        let keychainStatus : Bool = defaults.bool(forKey: UserDefaults.Keys.RSASetup.rawValue)
        
        do {
            log.debug(module: "RSA", type: #function, object: "User is first time")
            defaults.set(true, forKey: UserDefaults.Keys.RSASetup.rawValue)
            
            try KeyPair.manager.deleteKeyPair()
            let keyPublic = try KeyPair.manager.publicKey().data().PEM
            
            let keychain = Keychain()
            keychain.helper.removePassword(service: "keychainPublicKey", account: "NCRPT")
            keychain.helper.removePassword(service: "keychainPrivateKey", account: "NCRPT")
//            keychain.helper.savePassword(service: "keychainPrivateKey", account: "NCRPT", data: keys.0 ?? "")
            keychain.helper.savePassword(service: "keychainPublicKey", account: "NCRPT", data: keyPublic)
            log.debug(module: "RSA", type: #function, object: "Keys saved to keychain")
            
            print(keyPublic)
        } catch {
            // handle error
            print(error)
        }
    }
    
    func getPublicKey() -> String?{
        let keychain = Keychain()
        return keychain.helper.loadPassword(service: "keychainPublicKey", account: "NCRPT")
    }
}
