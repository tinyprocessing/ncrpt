//
//  FileEngine.swift
//  EncryptFile
//
//  Created by Michael Safir on 26.10.2022.
//

import Foundation
import ZIPFoundation

class FileEngine: ObservableObject, Identifiable  {
    
    func byteHeader(_ data: Data,_ ext: String) -> Data{
        var header = "0000".data(using: .utf8)
        if ext == "pdf"{
            header = "0001".data(using: .utf8)
        }
        if ext == "docx"{
            header = "0002".data(using: .utf8)
        }
        if ext == "pptx"{
            header = "0003".data(using: .utf8)
        }
        if ext == "xlsx"{
            header = "0004".data(using: .utf8)
        }
        if ext == "jpg"{
            header = "0005".data(using: .utf8)
        }
        if ext == "png"{
            header = "0006".data(using: .utf8)
        }
        if ext == "gif"{
            header = "0007".data(using: .utf8)
        }
        return header! + data
    }
    
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
        var fileFullName = "\(filename).ncrpt"
        
        LocalFileEngine.shared.getLocalFiles()
        let filesWithSameName = LocalFileEngine.shared.files.filter({ $0.name == fileFullName})
        if filesWithSameName.count > 0 {
            fileFullName = "\(filename)_\(filesWithSameName.count+1).ncrpt"
        }
        
        let fileURLNCRPT = libraryDirectory[0].appendingPathComponent(fileFullName)

        do {
            try! data.write(to: fileURLSecure)
            let jsonData = try JSONEncoder().encode(license)
            try! jsonData.write(to: fileURLLicense)
            try fileManager.zipItem(at: fileURLFolder, to: fileURLNCRPT)
            var fileURLNCRPTData = try Data(contentsOf: fileURLNCRPT)
            try! byteHeader(fileURLNCRPTData, license.ext.lowercased()).write(to: fileURLNCRPT)
            
            do {
                try FileManager.default.removeItem(atPath: (fileURLFolder.path().removingPercentEncoding)!)
            } catch {
                log.debug(module: "FileEngine", type: #function, object: "Could not delete file, probably read-only filesystem")
            }
            
        }catch{
            print(error)
            log.debug(module: "FileEngine", type: #function, object: "Error exportNCRPT")
        }
    }
    
}
