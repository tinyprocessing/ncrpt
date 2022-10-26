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
            let password = "random"
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
            let password = "random"
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
                    license.fileName = url.deletingPathExtension().lastPathComponent
                    license.description = "UPP"
                    license.fileSize = String(format: "%f", fileSize(forURL: url))
                    license.issuedDate =  String(format: "%f", NSDate().timeIntervalSince1970)
                    license.publicKey = ""
                    license.server = "https://secure.ncrpt.io"
                    license.templateID = ""
                  
                    fileEngine.exportNCRPT(encryptedFileReady,
                                           filename: url.deletingPathExtension().lastPathComponent,
                                           license: license)
                }
            }
        }catch{
            debugPrint("Error: fileEncyptionTest cannot crypt file")
        }

    }
}
