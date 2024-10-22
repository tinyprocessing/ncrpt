//
//  Network.swift
//  EncryptFile
//
//  Created by Сафир Михаил Дмитриевич [B] on 31.10.2022.
//

import Alamofire
import Foundation
import SwiftyJSON
import SwiftyRSA

class Network: ObservableObject, Identifiable {

    static let shared = Network()

    func registration(username: String, password: String, completion: @escaping (_ success: Bool) -> Void) {
        let usernameServer: String = username.addingPercentEncoding(
            withAllowedCharacters: .urlHostAllowed
        )!
        AF.request(
            "https://api.ncrpt.io/registration.php",
            method: .post,
            parameters: ["name": usernameServer, "password": password],
            encoding: URLEncoding.default
        ).responseJSON { [self] (response) in
            if response.response?.statusCode == 200 {
                completion(true)
            }
            else {
                completion(false)
            }
        }
    }

    func login(username: String, password: String, completion: @escaping (_ success: Bool) -> Void) {
        let usernameServer: String = username.addingPercentEncoding(
            withAllowedCharacters: .urlHostAllowed
        )!

        AF.request(
            "https://api.ncrpt.io/certificate.php",
            method: .post,
            parameters: ["name": usernameServer, "password": password],
            encoding: URLEncoding.default
        ).responseJSON { [self] (response) in
            if response.value != nil {
                let json = JSON(response.value!)
                let pfx = json["pfx"].stringValue
                let passwordServer = json["password"].stringValue
                if pfx != nil {
                    let decodedData = Data(base64Encoded: pfx)!
                    let keychain = Keychain()
                    if keychain.certification.importCertificate(
                        decodedData,
                        passwordServer
                    ) {
                        let defaults = UserDefaults.standard
                        defaults.set(
                            username.lowercased(),
                            forKey: UserDefaults
                                .Keys
                                .AuthorizationUsername
                                .rawValue
                        )
                        completion(true)
                    }
                    else {
                        completion(false)
                    }
                }
            }
            else {
                completion(false)
            }
        }
    }

    func license(
        license: String,
        fileAES: String,
        fileMD5: String,
        completion: @escaping (_ success: Bool) -> Void
    ) {
        ADFS.shared.jwt { success in
            if success {
                let headers: HTTPHeaders = [
                    .authorization(bearerToken: ADFS.shared.jwt)
                ]
                let rsaAESKeyEncrypted = self.encodeAF(fileAES)
                if rsaAESKeyEncrypted != "" {
                    AF.request(
                        "https://secure.ncrpt.io/license.php",
                        method: .post,
                        parameters: [
                            "fileLicense":
                                license,
                            "fileAES":
                                rsaAESKeyEncrypted,
                            "fileMD5": fileMD5,
                        ],
                        headers: headers
                    ).responseJSON { [self] (response) in
                        if response.response?.statusCode
                            == 200
                        {
                            completion(true)
                        }
                        else {
                            completion(false)
                        }
                    }
                }
                else {
                    completion(false)
                }
            }
            else {
                completion(false)
            }
        }
    }

    func licenseDecrypt(
        fileMD5: String,
        completion: @escaping (_ aes: String, _ rights: Rights?, _ success: Bool) -> Void
    ) {
        ADFS.shared.jwt { success in
            let headers: HTTPHeaders = [.authorization(bearerToken: ADFS.shared.jwt)]
            let keychain = Keychain()
            var publicKey =
                keychain.helper.loadPassword(
                    service: "keychainPublicKey",
                    account: "NCRPT"
                ) ?? ""
            publicKey = publicKey.data(using: .utf8)?.base64EncodedString() ?? ""

            AF.request(
                "https://secure.ncrpt.io/decrypt.php",
                method: .post,
                parameters: [
                    "fileMD5": fileMD5,
                    "public": publicKey,
                ],
                headers: headers
            ).responseJSON { [self] (response) in

                if response.response?.statusCode == 200 {
                    if response.value != nil {
                        let json = JSON(response.value!)

                        let owner = json["owner"]
                            .stringValue
                        let rightsAllUsers = json[
                            "rightsAllUsers"
                        ]

                        // Users array
                        var users: [String] = []
                        rightsAllUsers["users"].arrayValue
                            .forEach { user in
                                users
                                    .append(
                                        user
                                            .stringValue
                                    )
                            }

                        // Rights array
                        var rights: [String] = []
                        rightsAllUsers["rights"].arrayValue
                            .forEach { right in
                                rights
                                    .append(
                                        right
                                            .stringValue
                                    )
                            }

                        // ID array
                        var ids: [Int] = []
                        rightsAllUsers["users"].arrayValue
                            .forEach { right in
                                ids
                                    .append(
                                        ids
                                            .count
                                            + 1
                                    )
                            }

                        if rightsAllUsers.isEmpty {
                            let certification =
                                Certification()
                            certification
                                .getCertificate()
                            users.append(
                                certification
                                    .certificate
                                    .email
                                    ?? "my rights"
                            )
                            rights.append(
                                json[
                                    "rights"
                                ]
                                .stringValue
                            )
                            ids.append(0)
                        }

                        var rightsDecrypted: Rights =
                            Rights()
                        rightsDecrypted.owner = owner
                        rightsDecrypted.id = ids
                        rightsDecrypted.users = users
                        rightsDecrypted.rights = rights

                        do {
                            let encrypted =
                                try EncryptedMessage(
                                    base64Encoded:
                                        json[
                                            "aes"
                                        ]
                                        .stringValue
                                )
                            let privateKeyPEM =
                                keychain
                                .helper
                                .loadPassword(
                                    service:
                                        "keychainPrivateKey",
                                    account:
                                        "NCRPT"
                                ) ?? ""
                            let privateKey =
                                try PrivateKey(
                                    pemEncoded:
                                        privateKeyPEM
                                )
                            let result =
                                try encrypted
                                .decrypted(
                                    with:
                                        privateKey,
                                    padding:
                                        .PKCS1
                                )
                            completion(
                                try result
                                    .string(
                                        encoding:
                                            .utf8
                                    ),
                                rightsDecrypted,
                                true
                            )
                        }
                        catch {
                            print(error)
                            completion(
                                "",
                                nil,
                                false
                            )
                        }
                    }
                    else {
                        completion("", nil, false)
                    }
                }
                else {
                    completion("", nil, false)
                }
            }
        }
    }

    func revoke(fileMD5: String, completion: @escaping (_ success: Bool) -> Void) {
        ADFS.shared.jwt { success in
            let headers: HTTPHeaders = [.authorization(bearerToken: ADFS.shared.jwt)]
            AF.request(
                "https://secure.ncrpt.io/revoke.php",
                method: .post,
                parameters: ["fileMD5": fileMD5],
                headers: headers
            ).responseJSON { [self] (response) in

                if response.response?.statusCode == 200 {
                    completion(true)
                }
                else {
                    completion(false)
                }
            }
        }
    }

    func contacts(completion: @escaping (_ contacts: [User], _ success: Bool) -> Void) {
        ADFS.shared.jwt { success in
            let headers: HTTPHeaders = [.authorization(bearerToken: ADFS.shared.jwt)]
            AF.request("https://api.ncrpt.io/contacts.php", headers: headers).responseJSON { [self] (response) in
                if response.response?.statusCode == 200 {
                    if response.value != nil {
                        let json = JSON(response.value!)
                        var users = [User]()
                        json.forEach { (_, jso) in
                            users.append(
                                User(
                                    name:
                                        jso[
                                            "name"
                                        ]
                                        .stringValue,
                                    email:
                                        jso[
                                            "email"
                                        ]
                                        .stringValue
                                )
                            )
                        }

                        completion(users, true)
                    }
                    else {
                        completion([], false)
                    }
                }
                else {
                    completion([], false)
                }
            }
        }
    }

    func encodeAF(_ body: String) -> String {
        do {
            let clear = try ClearMessage(string: body, using: .utf8)
            if let rsaServerKey = ADFS.shared.rsaServerKey {
                let encrypted = try clear.encrypted(
                    with: rsaServerKey,
                    padding: .PKCS1
                )
                let base64String = encrypted.base64String
                log.debug(type: "Network", object: "Encrypted body")
                return base64String
            }
            else {
                return ""
            }
        }
        catch {
            return ""
        }
    }
}
