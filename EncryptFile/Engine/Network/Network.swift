//
//  Network.swift
//  EncryptFile
//
//  Created by Сафир Михаил Дмитриевич [B] on 31.10.2022.
//

import Foundation
import Alamofire
import SwiftyRSA
import SwiftyJSON

class Network: ObservableObject, Identifiable  {
    
    @Published var rsaServerKey : PublicKey? = nil
    
    static let shared = Network()
    
    func login(username: String, password: String, completion: @escaping (_ success:Bool) -> Void){
        let usernameServer : String = username.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        AF.request("https://api.ncrpt.io/certificate.php", method: .post, parameters: ["name":usernameServer, "password": password], encoding: URLEncoding.default).responseJSON { [self] (response) in
            if (response.value != nil) {
                let json = JSON(response.value!)
                let pfx = json["pfx"].stringValue
                let passwordServer = json["password"].stringValue
                if pfx != nil {
                    let decodedData = Data(base64Encoded: pfx)!
                    let keychain = Keychain()
                    if keychain.certification.importCertificate(decodedData, passwordServer) {
                        let defaults = UserDefaults.standard
                        defaults.set(username.lowercased(), forKey: "username")
                        completion(true)
                    }else{
                        completion(false)
                    }
                }
            }else{
                completion(false)
            }
        }
        
    }
    
    func publicServerKey(){
        do{
            var filePath = Bundle.main.url(forResource: "public", withExtension: "pem")
            var publicKey = try String(contentsOf: filePath!)
            let publicKeyClass = try PublicKey(pemEncoded: publicKey)
            log.debug(module: "Network", type: #function, object: try publicKeyClass.pemString())
            rsaServerKey = publicKeyClass
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
        }catch{
            print(error)
        }
    }
}


