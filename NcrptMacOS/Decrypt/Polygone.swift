//
//  Polygone.swift
//  NcrptMacOS
//
//  Created by Michael Safir on 16.01.2023.
//

import Foundation
import SSZipArchive

class Polygone: ObservableObject, Identifiable  {
    let aesHelper : AESHelper = AESHelper()
    
    
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
            let tmpUnZipDirectory : String = UUID().uuidString
            destinationURL.appendPathComponent("\(tmpUnZipDirectory)")
            try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
            
            
            let tmpNCRPTFileZip = destinationURL.appending(path: "/file.ncrpt")
            var dataNCRPT = try Data(contentsOf: url)
            dataNCRPT.remove(at: 0)
            dataNCRPT.remove(at: 0)
            dataNCRPT.remove(at: 0)
            dataNCRPT.remove(at: 0)
            try dataNCRPT.write(to: tmpNCRPTFileZip)
        
            
            let success: Bool = SSZipArchive.unzipFile(atPath: tmpNCRPTFileZip.path(),
                                                       toDestination: destinationURL.path(),
                                                       preserveAttributes: true,
                                                       overwrite: true,
                                                       nestedZipLevel: 1, password: nil,
                                                       error: nil,
                                                       delegate: nil,
                                                       progressHandler: nil) { file, result, data_error in
                
            }
            
            
            do {
                try FileManager.default.removeItem(atPath: (tmpNCRPTFileZip.path().removingPercentEncoding)!)
            } catch {
               return nil
            }
            
            let subDirectory : URL? = try destinationURL.appending(path: "/").subDirectories().first ?? nil
            
            if let _ = subDirectory?.appending(path: "primary") {}else{
                return nil
            }
            
            if let _ = subDirectory?.appending(path: "license.json") {}else{
                return nil
            }
            
            let primary : URL = (subDirectory?.appending(path: "primary"))!
            let license : URL = (subDirectory?.appending(path: "license.json"))!
            
            let dataLicense = try Data(contentsOf: license, options: .mappedIfSafe)
            let dataPrimary = try Data(contentsOf: primary, options: .mappedIfSafe)
            let json = try JSONSerialization.jsonObject(with: dataLicense, options: .mutableLeaves)
            
            
            if let json = json as? Dictionary<String, AnyObject>, let fileMD5 = json["fileMD5"] as? String {
                return fileMD5
            }
            
        }catch{
            return nil
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
