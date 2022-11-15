//
//  ADFS.swift
//  EncryptFile
//
//  Created by Сафир Михаил Дмитриевич [B] on 31.10.2022.
//

import Foundation
import Alamofire
import SwiftyRSA
import SwiftyJSON
import UIKit

class ADFS: NSObject, ObservableObject, Identifiable, URLSessionDelegate, URLSessionTaskDelegate {
    
    static let shared = ADFS()
    
    @Published var jwt : String = "";
    
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
//        var certificates: [Data] = {
//            let url = Bundle.main.url(forResource: "GlobalSign", withExtension: "cer")!
//            let data = try! Data(contentsOf: url)
//            return [data]
//        }()
//
//        let urlCA = Bundle.main.url(forResource: "SberCA_Root_Ext", withExtension: "cer")!
//        if let data = try? Data(contentsOf: urlCA) {
//            certificates.append(data)
//        }
//
//        let urlMC = Bundle.main.url(forResource: "mc_root_ca", withExtension: "cer")!
//        if let data = try? Data(contentsOf: urlMC) {
//            certificates.append(data)
//        }
//
//        if let trust = challenge.protectionSpace.serverTrust, SecTrustGetCertificateCount(trust) > 0 {
//            let stackServerCertificates : Int = SecTrustGetCertificateCount(trust)
//            if let certificate = SecTrustGetCertificateAtIndex(trust, stackServerCertificates-1) {
//                let data = SecCertificateCopyData(certificate) as Data
//                if certificates.contains(data) {
//                    completionHandler(.useCredential, URLCredential(trust: trust))
//                    return
//                }
//            }
//        }
        
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust){
            let server_trust = challenge.protectionSpace.serverTrust
            let exceptions = SecTrustCopyExceptions(server_trust!)
            SecTrustSetExceptions(server_trust!, exceptions)
            completionHandler(.useCredential, URLCredential(trust: server_trust!))
        }else{
            print(challenge.protectionSpace.authenticationMethod)
            
            if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate){
                    let keychain = Keychain()
                    let identity = keychain.certification.loadIdentity()!
                    let config = URLCredential(identity: keychain.certification.loadIdentity()!,
                                               certificates: nil,
                                               persistence: .forSession)
                    
                    challenge.sender?.use(config, for: challenge)
                    completionHandler(.useCredential, config)
                
            }
            completionHandler(.useCredential, nil)
            
        }
        
//        completionHandler(.useCredential, URLCredential(trust: trust))
//        completionHandler(.cancelAuthenticationChallenge, nil)
        
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        completionHandler(nil)
    }
    
    func jwt(completion: @escaping (_ success:Bool) -> Void){
        let urlString : String = "https://authory.ncrpt.io"
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        var urlParser = URLComponents()
        urlParser.queryItems = [
           
        ]
        let httpBodyString = urlParser.percentEncodedQuery
        
        let postData = NSMutableData(data: httpBodyString!.data(using: String.Encoding.utf8)!)
        let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { [self] (data, response, error) -> Void in
            if (error != nil) {
                completion(false)
            } else {
                if let json = try? JSON(data: data!) {
                    let newJWT = json["jwt"].stringValue
                    self.jwt = newJWT
                    print(self.jwt)
                    completion(true)
                    return 
                }
                if let httpResponse = response as? HTTPURLResponse {
                    print("jwt \(httpResponse.statusCode)")
                    completion(false)
                    return
                }
                completion(false)
            }
        })
        dataTask.resume()

    }
    
}


