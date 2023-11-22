//
//  ADFS.swift
//  EncryptFile
//
//  Created by Сафир Михаил Дмитриевич [B] on 31.10.2022.
//

import Alamofire
import Foundation
import SwiftyJSON
import SwiftyRSA
import UIKit

class ADFS: NSObject, ObservableObject, Identifiable, URLSessionDelegate, URLSessionTaskDelegate {

    static let shared = ADFS()

    @Published var jwt: String = ""
    @Published var publicKey: String = ""
    @Published var rsaServerKey: PublicKey? = nil

    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {

        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let server_trust = challenge.protectionSpace.serverTrust
            let exceptions = SecTrustCopyExceptions(server_trust!)
            SecTrustSetExceptions(server_trust!, exceptions)
            completionHandler(.useCredential, URLCredential(trust: server_trust!))
        }
        else {
            print(challenge.protectionSpace.authenticationMethod)

            if challenge.protectionSpace.authenticationMethod
                == NSURLAuthenticationMethodClientCertificate
            {
                let keychain = Keychain()
                var identity: SecIdentity? = nil
                identity = keychain.certification.loadIdentity(1)
                if identity == nil {
                    identity = keychain.certification.loadIdentity(0)
                }
                if keychain.certification.loadIdentity() != nil {
                    let config = URLCredential(
                        identity: keychain.certification
                            .loadIdentity()!,
                        certificates: nil,
                        persistence: .forSession
                    )

                    challenge.sender?.use(config, for: challenge)
                    completionHandler(.useCredential, config)
                }
                else {
                    completionHandler(.useCredential, nil)
                }

            }
            completionHandler(.useCredential, nil)

        }

        //        completionHandler(.useCredential, URLCredential(trust: trust))
        //        completionHandler(.cancelAuthenticationChallenge, nil)

    }

    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        completionHandler(nil)
    }

    func jwt(completion: @escaping (_ success: Bool) -> Void) {

        if self.jwt != "" {
            let time: Double = Date().timeIntervalSince1970
            let exp: Double = getDateFromJWT(self.jwt).timeIntervalSince1970
            if time < exp {
                completion(true)
                return
            }
        }

        let urlString: String = "https://authory.ncrpt.io"
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        var urlParser = URLComponents()
        urlParser.queryItems = []
        let httpBodyString = urlParser.percentEncodedQuery

        let postData = NSMutableData(data: httpBodyString!.data(using: String.Encoding.utf8)!)
        let request = NSMutableURLRequest(
            url: NSURL(string: urlString)! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0
        )
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: self,
            delegateQueue: nil
        )
        let dataTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: { [self] (data, response, error) -> Void in
                if error != nil {
                    completion(false)
                }
                else {
                    if let json = try? JSON(data: data!) {
                        self.jwt = json["jwt"].stringValue
                        self.publicKey =
                            json["public"]
                            .stringValue
                        do {
                            let publicKeyClass =
                                try PublicKey(
                                    pemEncoded:
                                        self
                                        .publicKey
                                )
                            log.debug(
                                module:
                                    "ADFS",
                                type:
                                    #function,
                                object:
                                    "RSA Public Key Imported"
                            )
                            self.rsaServerKey =
                                publicKeyClass
                        }
                        catch {
                            log.debug(
                                module:
                                    "ADFS",
                                type:
                                    #function,
                                object:
                                    "RSA error \(error)"
                            )
                        }
                        completion(true)
                        return
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        print(
                            "jwt \(httpResponse.statusCode)"
                        )
                        completion(false)
                        return
                    }
                    completion(false)
                }
            }
        )
        dataTask.resume()

    }

}

func getDateFromJWT(_ base64: String) -> Date {
    var time: Double = Date().timeIntervalSince1970
    if let data = base64.slice(from: ".", to: ".") {
        print("JWT удалось разбить")
        if let decodedData = data.base64Decoded() {
            print("JWT декодирован")
            print("JWT \(decodedData)")
            let json = JSON(parseJSON: decodedData)
            print(json["exp"].stringValue)
            time = Double(json["exp"].stringValue) ?? 1_668_552_938
        }
        else {
            print("❌ JWT не декодирован")
            print("JWT base64 \(base64)")
        }
    }
    let date = Date(timeIntervalSince1970: time)
    return date
}

extension String {
    func versionCompare(_ otherVersion: String) -> ComparisonResult {
        let versionDelimiter = "."

        var versionComponents = self.components(separatedBy: versionDelimiter)  // <1>
        var otherVersionComponents = otherVersion.components(separatedBy: versionDelimiter)

        let zeroDiff = versionComponents.count - otherVersionComponents.count  // <2>

        if zeroDiff == 0 {  // <3>
            // Same format, compare normally
            return self.compare(otherVersion, options: .numeric)
        }
        else {
            let zeros = Array(repeating: "0", count: abs(zeroDiff))  // <4>
            if zeroDiff > 0 {
                otherVersionComponents.append(contentsOf: zeros)  // <5>
            }
            else {
                versionComponents.append(contentsOf: zeros)
            }
            return versionComponents.joined(separator: versionDelimiter)
                .compare(
                    otherVersionComponents.joined(
                        separator: versionDelimiter
                    ),
                    options: .numeric
                )  // <6>
        }
    }

}

extension String {
    func base64Decoded() -> String? {
        var st = self
        st = st.replacingOccurrences(of: "_", with: "/")
        st = st.replacingOccurrences(of: "-", with: "+")
        if self.count % 4 <= 3 {
            st += String(repeating: "=", count: 4 - (self.count % 4))
        }
        guard let data = Data(base64Encoded: st) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
