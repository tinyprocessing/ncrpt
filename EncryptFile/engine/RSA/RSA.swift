//
//  Rsa.swift
//  EncryptFile
//
//  Created by Сафир Михаил Дмитриевич [B] on 31.10.2022.
//

import Foundation
import SwiftyRSA

class RSA: ObservableObject, Identifiable  {
    
    func generatePairKeys() -> (String?, String?){
        do {
            let keyPair = try SwiftyRSA.generateRSAKeyPair(sizeInBits: 2048)
            let privateKey = keyPair.privateKey
            let publicKey = keyPair.publicKey
            return (try privateKey.pemString(), try publicKey.pemString())
        }catch{
            print(error)
        }
        return (nil, nil)
    }
    
    func start(){
        log.debug(module: "RSA", type: #function, object: self.getPublicKey() ?? "RSA key not found")
        let defaults = UserDefaults.standard
        let keychainStatus : Bool = defaults.bool(forKey: "keychain")
        if (keychainStatus == false){
            log.debug(module: "RSA", type: #function, object: "User is first time")
            defaults.set(true, forKey: "keychain")
            let keys = self.generatePairKeys()
            if (keys.1 != nil && keys.0 != nil){
                let keychain = Keychain()
                keychain.helper.removePassword(service: "keychainPublicKey", account: "NCRPT")
                keychain.helper.removePassword(service: "keychainPrivateKey", account: "NCRPT")
                keychain.helper.savePassword(service: "keychainPrivateKey", account: "NCRPT", data: keys.0 ?? "")
                keychain.helper.savePassword(service: "keychainPublicKey", account: "NCRPT", data: keys.1 ?? "")
                log.debug(module: "RSA", type: #function, object: "Keys saved to keychain")
            }
        }
    }
    
    func getPublicKey() -> String?{
        let keychain = Keychain()
        return keychain.helper.loadPassword(service: "keychainPublicKey", account: "NCRPT")
    }
}
