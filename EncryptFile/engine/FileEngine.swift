//
//  FileEngine.swift
//  EncryptFile
//
//  Created by Michael Safir on 26.10.2022.
//

import Foundation

class FileEngine: ObservableObject, Identifiable  {
    
    func exportNCRPT(_ data: Data, filename : String){
        let fileManager = FileManager.default
        let libraryDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let fileDirectory : String = UUID().uuidString
        
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//        path += "/\(Bundle.main.bundleIdentifier!)/ncrpt/\(fileDirectory)"
        let url = URL(fileURLWithPath: path)
        
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            
        }
        let fileURLUnsecure = libraryDirectory[0].appendingPathComponent("\(filename).ncrpt")
        do {
            try! data.write(to: fileURLUnsecure)
            print(fileURLUnsecure)
        }catch{
            debugPrint("Error exportNCRPT")
        }
    }
    
}
