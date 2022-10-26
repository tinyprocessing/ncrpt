//
//  AES.swift
//  EncryptFile
//
//  Created by Michael Safir on 25.10.2022.
//

import Foundation
import CommonCrypto

struct AES {
    
    // MARK: - Value
    public let key: Data
    public let iv: Data
    
    // MARK: - Initialzier
    init?(key: Data, iv: Data) {
        self.key = key
        self.iv  = iv
        print("AES processing sucess")
    }
       
}
