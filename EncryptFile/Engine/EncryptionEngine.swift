//
//  EncriptionEngine.swift
//  EncryptFile
//
//  Created by Michael Safir on 25.10.2022.
//

import Foundation
import CommonCrypto

// class is supported for encryption by AES
class EncryptionEngine: ObservableObject, Identifiable  {
    public var id: Int = 0
    public var aes: AES
    
    init(id: Int = 0, aes: AES) {
        self.id = id
        self.aes = aes
    }
    
    func exportAES() -> String{
        let keybase64 = self.aes.key.base64EncodedString()
        let ivbase64 = self.aes.iv.base64EncodedString()
        return keybase64 + "." + ivbase64
    }
    
    func encryptFile(fileURL: URL) -> Data?{
        do {
            let fileData = try Data(contentsOf: fileURL)
            return crypt(data: fileData, option: CCOperation(kCCEncrypt))
        }catch {
            log.debug(module: "EncryptionEngine", type: #function, object: "Cannot convert file to Data")
            return nil
        }
    }
    
    func encryptData(data: Data) -> Data?{
        return crypt(data: data, option: CCOperation(kCCEncrypt))
    }
    
    func decrypt(_ encrypted: Data) -> Data? {
        do {
            let fileData = crypt(data: encrypted, option: CCOperation(kCCDecrypt))!
            return fileData
        }catch {
            log.debug(module: "EncryptionEngine", type: #function, object: "Decrypt")
            return nil
        }
    }
    
    func crypt(data: Data?, option: CCOperation) -> Data? {
        guard let data = data else { return nil }
        
        let cryptLength = data.count + self.aes.key.count
        var cryptData   = Data(count: cryptLength)
        
        var bytesLength = Int(0)
        
        let status = cryptData.withUnsafeMutableBytes { cryptBytes in
            data.withUnsafeBytes { dataBytes in
                self.aes.iv.withUnsafeBytes { ivBytes in
                    self.aes.key.withUnsafeBytes { keyBytes in
                        CCCrypt(option, CCAlgorithm(kCCAlgorithmAES),
                                CCOptions(kCCOptionPKCS7Padding),
                                keyBytes.baseAddress,
                                self.aes.key.count,
                                ivBytes.baseAddress,
                                dataBytes.baseAddress,
                                data.count,
                                cryptBytes.baseAddress,
                                cryptLength, &bytesLength)
                    }
                }
            }
        }
        
        guard Int32(status) == Int32(kCCSuccess) else {
            log.debug(module: "EncryptionEngine", type: #function, object: "Failed to crypt data \(status)")
            return nil
        }
        
        cryptData.removeSubrange(bytesLength..<cryptData.count)
        return cryptData
    }
    
}
