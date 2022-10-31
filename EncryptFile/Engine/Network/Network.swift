//
//  Network.swift
//  EncryptFile
//
//  Created by Сафир Михаил Дмитриевич [B] on 31.10.2022.
//

import Foundation
import Alamofire
import SwiftyRSA

class Network: ObservableObject, Identifiable  {
    
    @Published var rsaServerKey : PublicKey? = nil
    
    func publicServerKey(){
        do{
            var filePath = Bundle.main.url(forResource: "public", withExtension: "pem")
            var publicKey = try String(contentsOf: filePath!)
            let publicKeyClass = try PublicKey(pemEncoded: publicKey)
            log.debug(module: "Network", type: #function, object: try publicKeyClass.pemString())
            rsaServerKey = publicKeyClass
            encodePOST()
        }catch{
            log.debug(module: "Network", type: #function, object: "error \(error)")
        }
    }
    
    func encodePOST(){
        do{
            let message = "Hello!"
            let clear = try ClearMessage(string: message, using: .utf8)
            let encrypted = try clear.encrypted(with: rsaServerKey!, padding: .PKCS1)
            let base64String = encrypted.base64String
            print(base64String)
        }catch{
            print(error)
        }
    }
}
