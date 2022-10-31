//
//  FileEngine.swift
//  EncryptFile
//
//  Created by Michael Safir on 26.10.2022.
//

import Foundation
import ZIPFoundation

class FileEngine: ObservableObject, Identifiable  {
    
    func exportNCRPT(_ data: Data, filename : String, license: License = License()){
        let fileManager = FileManager.default
        let libraryDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let fileDirectory : String = UUID().uuidString
        
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        path += "/\(fileDirectory)"
        let url = URL(fileURLWithPath: path)
        
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            
        }
        let fileURLSecure = libraryDirectory[0].appendingPathComponent("/\(fileDirectory)/primary")
        let fileURLLicense = libraryDirectory[0].appendingPathComponent("/\(fileDirectory)/license.json")
        let fileURLFolder = libraryDirectory[0].appendingPathComponent("/\(fileDirectory)")
        let fileURLNCRPT = libraryDirectory[0].appendingPathComponent("\(filename).ncrpt")

        do {
            try! data.write(to: fileURLSecure)
            let jsonData = try JSONEncoder().encode(license)
            try! jsonData.write(to: fileURLLicense)
            try fileManager.zipItem(at: fileURLFolder, to: fileURLNCRPT)
            print(fileURLNCRPT)
            
            do {
                try FileManager.default.removeItem(atPath: (fileURLFolder.path().removingPercentEncoding)!)
            } catch {
                log.debug(module: "FileEngine", type: #function, object: "Could not delete file, probably read-only filesystem")
            }
            
        }catch{
            log.debug(module: "FileEngine", type: #function, object: "Error exportNCRPT")
        }
    }
    
}
