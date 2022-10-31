//
//  Polygone.swift
//  EncryptFile
//
//  Created by Michael Safir on 25.10.2022.
//

import Foundation

class Polygone: ObservableObject, Identifiable  {
    let aesHelper : AESHelper = AESHelper()
    func fileEncyptionTest(){
        do {
            let password : String = UUID().uuidString
            print("fileEncyptionTest processing")
            let salt = self.aesHelper.randomSalt()
            let key : Data = try! self.aesHelper.createKey(password: password.data(using: .utf8)!, salt: salt)
            print("fileEncyptionTest key ready")
            let iv : Data = try! self.aesHelper.randomIv()
            print("fileEncyptionTest iv ready")
            var aes : AES? = AES(key: key, iv: iv)
            print("fileEncyptionTest AES ready")
            if let aesReady = aes {
                let engine : EncryptionEngine = EncryptionEngine(aes: aesReady)
                print("fileEncyptionTest EncryptionEngine ready")
                var filePath = Bundle.main.url(forResource: "test", withExtension: "txt")
                if let filePathReady = filePath{
                    let encryptedFile = engine.encryptFile(fileURL: filePathReady)
                    print("fileEncyptionTest encryptedFile done")
                    print(encryptedFile)
                    if let encryptedFileReady = encryptedFile{
                        //                        Build test with exported AES
                        let aesExport = engine.exportAES()
                        print(aesExport)
                        let aesImport = aesHelper.importKey(aesExport)
                        aes = AES(key: aesImport.0!, iv: aesImport.1!)
                        engine.aes = aes!
                        
                        //                        Decrypt with exported AES
                        let decrypedFile = engine.decrypt(encryptedFileReady)
                        print("fileEncyptionTest decrypedFile done")
                        let fileEngine = FileEngine()
                        fileEngine.exportNCRPT(encryptedFileReady, filename: "test")
                        
                    }
                }
            }
        }catch{
            debugPrint("Error: fileEncyptionTest cannot crypt file")
        }
    }
    
    func encryptFile(_ url: URL){
        do {
            let password : String = UUID().uuidString
            print("fileEncyptionTest processing")
            let salt = self.aesHelper.randomSalt()
            let key : Data = try! self.aesHelper.createKey(password: password.data(using: .utf8)!, salt: salt)
            print("fileEncyptionTest key ready")
            let iv : Data = try! self.aesHelper.randomIv()
            print("fileEncyptionTest iv ready")
            var aes : AES? = AES(key: key, iv: iv)
            print("fileEncyptionTest AES ready")
            if let aesReady = aes {
                let engine : EncryptionEngine = EncryptionEngine(aes: aesReady)
                print("fileEncyptionTest EncryptionEngine ready")
                var filePath = url
                let encryptedFile = engine.encryptFile(fileURL: filePath)
                if let encryptedFileReady = encryptedFile{
                    let fileEngine = FileEngine()
                    
                    var license : License = License()
                    license.owner = "safir@ncrpt.io"
                    license.AESKey = engine.exportAES()
                    license.algorithm = "AES"
                    license.algorithm = "32"
                    license.fileMD5 = md5File(url: url) ?? ""
                    license.fileName = url.lastPathComponent
                    license.description = "UPP"
                    license.fileSize = String(format: "%f", fileSize(forURL: url))
                    license.issuedDate =  String(format: "%f", NSDate().timeIntervalSince1970)
                    license.publicKey = ""
                    license.server = "https://secure.ncrpt.io"
                    license.templateID = ""
                    
                    var rights : Rights = Rights()
                    rights.owner = "safir@ncrpt.io"
                    rights.users = ["safir@nrcpt.io", "anisimov@ncrpt.io"]
                    rights.rights = ["OWNER", "VIEW"]
                    
                    var rsa = RSA()
                    rsa.generatePairKeys()
                    
                    fileEngine.exportNCRPT(encryptedFileReady,
                                           filename: url.deletingPathExtension().lastPathComponent,
                                           license: license)
                }
            }
        }catch{
            debugPrint("Error: encryptFile cannot encrypt file")
        }
        
    }
    
    func decryptFile(_ url: URL) -> URL? {
        do {
            let fileManager = FileManager()
            let documentDirectory = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            var sourceURL = url
            var destinationURL = documentDirectory
            let tmpUnZipDirectory : String = UUID().uuidString
            destinationURL.appendPathComponent("\(tmpUnZipDirectory)")
            try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
            try fileManager.unzipItem(at: sourceURL, to: destinationURL)
            let subDirectory : URL? = try destinationURL.appending(path: "/").subDirectories().first ?? nil
            
            let primary : URL = (subDirectory?.appending(path: "primary"))!
            let license : URL = (subDirectory?.appending(path: "license.json"))!

            let dataLicense = try Data(contentsOf: license, options: .mappedIfSafe)
            let dataPrimary = try Data(contentsOf: primary, options: .mappedIfSafe)
            let json = try JSONSerialization.jsonObject(with: dataLicense, options: .mutableLeaves)
            if let json = json as? Dictionary<String, AnyObject>, let AESKey = json["AESKey"] as? String {
                let aesImport = aesHelper.importKey(AESKey)
                var aes = AES(key: aesImport.0!, iv: aesImport.1!)
                let engine : EncryptionEngine = EncryptionEngine(aes: aes!)
                let decrypt = engine.decrypt(dataPrimary)
                
                if let fileName = json["fileName"] as? String{
                    let ready : URL = (subDirectory?.appending(path: "\(fileName)"))!
                    try decrypt?.write(to: ready)
                    return ready
                }

                
            }
            
            print(destinationURL)
            print(subDirectory)
            
        }catch{
            debugPrint("Error: decryptFile cannot crypt file")
        }
        
        return nil
    }
}

extension URL {
    func subDirectories() throws -> [URL] {
        // @available(macOS 10.11, iOS 9.0, *)
        guard hasDirectoryPath else { return [] }
        return try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]).filter(\.hasDirectoryPath)
    }
}
