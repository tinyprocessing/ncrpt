//
//  FileEngine.swift
//  EncryptFile
//
//  Created by Michael Safir on 26.10.2022.
//

import Foundation
import ZIPFoundation

let avalibleExtensions : [String:String] = [
    "pdf" : "0001",
    "docx" : "0002",
    "pptx" : "0003",
    "xlsx" : "0004",
    "jpg" : "0005",
    "png" : "0006",
    "gif" : "0007",
    "doc" : "0008",
    "bmp" : "0009",
    "pub" : "0010",
    "tiff" : "0011",
    "tif" : "0012",
    "ppt" : "0013",
    "zip" : "0014",
    "rar" : "0015",
    "gzip" : "0016",
    "7z" : "0017",
    "xls" : "0018",
    "txt" : "0019",
    "html" : "0020",
    "htm" : "0021",
    "mkt" : "0022",
    "djvu" : "0023",
    "fb2" : "0024",
    "epub" : "0025",
    "mp4" : "0026",
    "avi" : "0027",
    "mp3" : "0028",
    "wav" : "0029",
    "mkv" : "0030",
    "midi" : "0031",
    "aac" : "0032",
    "flv" : "0033",
    "mpeg" : "0034",
    "exe" : "0035",
    "ncrpt" : "0036",
    "m4a" : "0037",
    "csv" : "0038",
]


class FileEngine: ObservableObject, Identifiable  {
    
    func byteHeader(_ data: Data,_ ext: String) -> Data{
        var header = (avalibleExtensions[ext] ?? "0000").data(using: .utf8)
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
