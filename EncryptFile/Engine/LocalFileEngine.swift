//
//  LocalFileEngine.swift
//  EncryptFile
//
//  Created by Michael Safir on 26.10.2022.
//

import Foundation


struct fileItem : Identifiable, Hashable {
    var id: Int = 0
    var name : String = ""
    var url : URL? = nil
    var ext : String = ""
}

class LocalFileEngine: ObservableObject, Identifiable  {
    
    @Published var files : [fileItem] = []
    static let shared = LocalFileEngine()
    
    func decodeFileExtension(_ ext: String) -> String{
        var header = "file"
        if ext == "0001"{
            header = "pdf"
        }
        if ext == "0002"{
            header = "docx"
        }
        if ext == "0003"{
            header = "pptx"
        }
        if ext == "0004"{
            header = "xlsx"
        }
        if ext == "0005"{
            header = "jpg"
        }
        if ext == "0006"{
            header = "png"
        }
        return header
    }
    
    func getLocalFiles(){
        
        self.files.removeAll()
        do {
            // Get the document directory url
            let documentDirectory = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(
                at: documentDirectory,
                includingPropertiesForKeys: nil
            )
            
            directoryContents.forEach { item in
                let name = item.localizedName ?? ""
                if item.typeIdentifier == "public.folder" && !item.isNCRPT && !name.contains("thenoco.co.EncryptFile") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                        do {
                            try FileManager.default.removeItem(atPath: (item.path().removingPercentEncoding)!)
                        } catch {
                            print("removeItem error")
                            print(error)
                        }
                    }
                }
            }
            
            // if you want to get all ncrpt files located at the documents directory:
            let ncrpt = directoryContents.filter(\.isNCRPT)
            self.objectWillChange.send()
            autoreleasepool{
                ncrpt.forEach { url in
                    do {
                        let fileURLNCRPTData = try Data(contentsOf: url)
                        let fileExtension = String(decoding: fileURLNCRPTData[0...3], as: UTF8.self)
                        self.objectWillChange.send()
                        files.append(fileItem(name: url.lastPathComponent, url: url, ext: decodeFileExtension(fileExtension)))
//                        print(url)
                    }catch{
//                        print("getLocalFiles error")
                    }
                }
            }
        } catch {
            print(error)
        }
        
    }
    
}

extension URL {
    var typeIdentifier: String? { (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier }
    var isNCRPT: Bool { self.lastPathComponent.contains(".ncrpt") }
    var localizedName: String? { (try? resourceValues(forKeys: [.localizedNameKey]))?.localizedName }
    var hasHiddenExtension: Bool {
        get { (try? resourceValues(forKeys: [.hasHiddenExtensionKey]))?.hasHiddenExtension == true }
        set {
            var resourceValues = URLResourceValues()
            resourceValues.hasHiddenExtension = newValue
            try? setResourceValues(resourceValues)
        }
    }
}
