//
//  Polygone.swift
//  EncryptFile
//
//  Created by Michael Safir on 25.10.2022.
//

import Foundation

class Polygone: ObservableObject, Identifiable {
    let aesHelper: AESHelper = AESHelper()

    func encryptFile(_ url: URL, users: [User] = [], completion: @escaping (_ success: Bool) -> Void) {
        do {
            let password: String = UUID().uuidString
            log.debug(module: "Polygone", type: #function, object: "Processing keys")
            let salt = self.aesHelper.randomSalt()
            let key: Data = try! self.aesHelper.createKey(
                password: password.data(using: .utf8)!,
                salt: salt
            )
            let iv: Data = self.aesHelper.randomIv()
            let aes: AES? = AES(key: key, iv: iv)
            log.debug(module: "Polygone", type: #function, object: "Keys ready")

            if let aesReady = aes {
                let engine: EncryptionEngine = EncryptionEngine(aes: aesReady)
                log.debug(
                    module: "Polygone",
                    type: #function,
                    object: "Encryption done"
                )
                let filePath = url
                let encryptedFile = engine.encryptFile(fileURL: filePath)
                if let encryptedFileReady = encryptedFile {
                    let fileEngine = FileEngine()

                    let certification = Certification()
                    certification.getCertificate()
                    let aesKey = engine.exportAES()
                    let md5Result =
                        UUID().uuidString + "."
                        + (md5File(url: url) ?? "")
                    var license: License = License()
                    license.owner =
                        certification.certificate.email
                        ?? ""
                    license.AESKey = "encrypted"
                    license.algorithm = "AES"
                    license.algorithm = "32"
                    license.fileMD5 = md5Result
                    license.fileName = url.lastPathComponent
                    license.description = "UPP"
                    license.fileSize = String(
                        format: "%f",
                        fileSize(forURL: url)
                    )
                    license.issuedDate = String(
                        format: "%f",
                        NSDate().timeIntervalSince1970
                    )
                    license.publicKey = ""
                    license.server = "https://secure.ncrpt.io"
                    license.templateID = ""
                    license.ext = url.pathExtension

                    var rights: Rights = Rights()
                    rights.owner =
                        certification.certificate.email
                        ?? ""
                    //                    users.forEach { user in
                    //                        rights.users.append(user.email)
                    //                        rights.rights.append(user.rights)
                    //                    }
                    users.forEach { user in
                        rights.users.append(user.email)
                        rights.rights.append(user.allRights)
                    }
                    let rightsJSONData = try JSONEncoder().encode(
                        rights
                    )
                    let encryptedFile = engine.encryptData(
                        data: rightsJSONData
                    )
                    license.userRights = encryptedFile?
                        .base64EncodedString()

                    log.debug(
                        module: "Polygone",
                        type: #function,
                        object: "License done"
                    )

                    let jsonData = try JSONEncoder().encode(license)
                    Network.shared.license(
                        license: String(
                            data: jsonData,
                            encoding: .utf8
                        )!,
                        fileAES: aesKey,
                        fileMD5: md5Result
                    ) { success in
                        if success {
                            fileEngine.exportNCRPT(
                                encryptedFileReady,
                                filename:
                                    url
                                    .deletingPathExtension()
                                    .lastPathComponent,
                                license:
                                    license
                            )
                            completion(true)
                        }
                    }
                }
            }
        }
        catch {
            log.debug(module: "Polygone", type: #function, object: "Error encrypt")
        }

    }

    func getFileMD5(_ url: URL) -> String? {
        do {
            let fileManager = FileManager()
            let documentDirectory = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            var destinationURL = documentDirectory
            let tmpUnZipDirectory: String = UUID().uuidString
            destinationURL.appendPathComponent("\(tmpUnZipDirectory)")
            try fileManager.createDirectory(
                at: destinationURL,
                withIntermediateDirectories: true,
                attributes: nil
            )

            let tmpNCRPTFileZip = destinationURL.appending(path: "/file.ncrpt")
            var dataNCRPT = try Data(contentsOf: url)
            dataNCRPT.remove(at: 0)
            dataNCRPT.remove(at: 0)
            dataNCRPT.remove(at: 0)
            dataNCRPT.remove(at: 0)
            try dataNCRPT.write(to: tmpNCRPTFileZip)
            try fileManager.unzipItem(at: tmpNCRPTFileZip, to: destinationURL)

            do {
                try FileManager.default.removeItem(
                    atPath: (tmpNCRPTFileZip.path()
                        .removingPercentEncoding)!
                )
            }
            catch {
                return nil
            }

            let subDirectory: URL? =
                try destinationURL.appending(path: "/").subDirectories().first
                ?? nil

            if let _ = subDirectory?.appending(path: "primary") {
            }
            else {
                return nil
            }

            if let _ = subDirectory?.appending(path: "license.json") {
            }
            else {
                return nil
            }

            let primary: URL = (subDirectory?.appending(path: "primary"))!
            let license: URL = (subDirectory?.appending(path: "license.json"))!

            let dataLicense = try Data(contentsOf: license, options: .mappedIfSafe)
            let dataPrimary = try Data(contentsOf: primary, options: .mappedIfSafe)
            let json = try JSONSerialization.jsonObject(
                with: dataLicense,
                options: .mutableLeaves
            )

            if let json = json as? [String: AnyObject],
                let fileMD5 = json["fileMD5"] as? String
            {
                return fileMD5
            }

        }
        catch {
            return nil
        }
        return nil
    }

    func decryptFile(
        _ url: URL,
        completion: @escaping (_ url: URL?, _ rights: Rights?, _ success: Bool) -> Void
    ) {
        do {
            let fileManager = FileManager()
            let documentDirectory = try FileManager.default.url(
                for: .cachesDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            var sourceURL = url
            var destinationURL = documentDirectory
            let tmpUnZipDirectory: String = UUID().uuidString
            destinationURL.appendPathComponent("\(tmpUnZipDirectory)")
            try fileManager.createDirectory(
                at: destinationURL,
                withIntermediateDirectories: true,
                attributes: nil
            )

            let tmpNCRPTFileZip = destinationURL.appending(path: "/file.ncrpt")
            var dataNCRPT = try Data(contentsOf: url)
            dataNCRPT.remove(at: 0)
            dataNCRPT.remove(at: 0)
            dataNCRPT.remove(at: 0)
            dataNCRPT.remove(at: 0)
            try dataNCRPT.write(to: tmpNCRPTFileZip)
            try fileManager.unzipItem(at: tmpNCRPTFileZip, to: destinationURL)

            do {
                try FileManager.default.removeItem(
                    atPath: (tmpNCRPTFileZip.path()
                        .removingPercentEncoding)!
                )
            }
            catch {
                completion(nil, nil, false)
                log.debug(
                    module: "FileEngine",
                    type: #function,
                    object:
                        "Could not delete file, probably read-only filesystem"
                )
            }

            let subDirectory: URL? =
                try destinationURL.appending(path: "/").subDirectories().first
                ?? nil

            if let _ = subDirectory?.appending(path: "primary") {
            }
            else {
                completion(nil, nil, false)
            }

            if let _ = subDirectory?.appending(path: "license.json") {
            }
            else {
                completion(nil, nil, false)
            }

            let primary: URL = (subDirectory?.appending(path: "primary"))!
            let license: URL = (subDirectory?.appending(path: "license.json"))!

            let dataLicense = try Data(contentsOf: license, options: .mappedIfSafe)
            let dataPrimary = try Data(contentsOf: primary, options: .mappedIfSafe)
            let json = try JSONSerialization.jsonObject(
                with: dataLicense,
                options: .mutableLeaves
            )

            if let json = json as? [String: AnyObject],
                let fileMD5 = json["fileMD5"] as? String,
                let ownerUser = json["owner"] as? String
            {
                Network.shared.licenseDecrypt(fileMD5: fileMD5) {
                    [self] aesServer, rights, success in
                    if success == true {
                        do {
                            let aesImport =
                                aesHelper
                                .importKey(
                                    aesServer
                                )
                            var aes = AES(
                                key:
                                    aesImport
                                    .0!,
                                iv:
                                    aesImport
                                    .1!
                            )
                            let engine: EncryptionEngine =
                                EncryptionEngine(
                                    aes:
                                        aes!
                                )
                            let decrypt =
                                engine
                                .decrypt(
                                    dataPrimary
                                )

                            var rightsWithUser =
                                rights
                            rightsWithUser?
                                .owner =
                                ownerUser

                            if let fileName =
                                json[
                                    "fileName"
                                ]
                                as? String
                            {
                                let ready: URL =
                                    (subDirectory?
                                    .appending(
                                        path:
                                            "\(fileName)"
                                    ))!
                                try decrypt?
                                    .write(
                                        to:
                                            ready
                                    )
                                completion(
                                    ready,
                                    rightsWithUser,
                                    true
                                )
                                return
                            }
                        }
                        catch {
                            completion(
                                nil,
                                nil,
                                false
                            )
                            log.debug(
                                module:
                                    "FileEngine",
                                type:
                                    #function,
                                object:
                                    "Could not delete file, probably read-only filesystem"
                            )
                        }
                    }
                    else {
                        completion(nil, nil, false)
                    }
                }
            }

            log.debug(module: "Polygone", type: #function, object: "Decrypt ready")
            log.debug(module: "Polygone", type: #function, object: destinationURL)
        }
        catch {
            log.debug(module: "Polygone", type: #function, object: "Error deencrypt")
            completion(nil, nil, false)
        }
    }
}

extension URL {
    func subDirectories() throws -> [URL] {
        // @available(macOS 10.11, iOS 9.0, *)
        guard hasDirectoryPath else { return [] }
        return try FileManager.default.contentsOfDirectory(
            at: self,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ).filter(\.hasDirectoryPath)
    }
}
