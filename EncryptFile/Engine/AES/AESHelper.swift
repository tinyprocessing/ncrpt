//
//  AESHelper.swift
//  EncryptFile
//
//  Created by Michael Safir on 25.10.2022.
//

import Foundation
import CommonCrypto

struct AESHelper {
    
    func importKey(_ base64: String) -> (Data?, Data?) {
        if base64.components(separatedBy: ".").count > 1 {
            let keyBase64 =  base64.components(separatedBy: ".")[0]
            let ivBase64 = base64.components(separatedBy: ".")[1]
            return (Data(base64Encoded: keyBase64), Data(base64Encoded: ivBase64))
        }else{
            return (nil, nil)
        }
    }
    
    func createKey(password: Data, salt: Data) throws -> Data {
        let length = kCCKeySizeAES256
        var status = Int32(0)
        var derivedBytes = [UInt8](repeating: 0, count: length)
        password.withUnsafeBytes { (passwordBytes: UnsafePointer<Int8>!) in
            salt.withUnsafeBytes { (saltBytes: UnsafePointer<UInt8>!) in
                status = CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2),                  // algorithm
                                              passwordBytes,                                // password
                                              password.count,                               // passwordLen
                                              saltBytes,                                    // salt
                                              salt.count,                                   // saltLen
                                              CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1),   // prf
                                              10000,                                        // rounds
                                              &derivedBytes,                                // derivedKey
                                              length)                                       // derivedKeyLen
            }
        }
        guard status == 0 else {
            throw NSError(domain: "AESHelper", code: 1)
        }
        return Data(bytes: UnsafePointer<UInt8>(derivedBytes), count: length)
    }
    
    func randomIv() -> Data {
        return randomData(length: kCCBlockSizeAES128)
    }
    
    func randomSalt() -> Data {
        return randomData(length: 8)
    }
    
    func randomData(length: Int) -> Data {
        var data = Data(count: length)
        let status = data.withUnsafeMutableBytes { mutableBytes in
            SecRandomCopyBytes(kSecRandomDefault, length, mutableBytes)
        }
        assert(status == Int32(0))
        return data
    }
}

extension Data {
    var hexString: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
