//
//  LocalFileEngine.swift
//  EncryptFile
//
//  Created by Michael Safir on 26.10.2022.
//

import Foundation

class LocalFileEngine: ObservableObject, Identifiable  {
    
    @Published var files : [fileItem] = []
    
    struct fileItem : Identifiable, Hashable {
        var id: Int = 0
        var name : String = ""
        var url : URL? = nil
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
            print("documentDirectory", documentDirectory.path)
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(
                at: documentDirectory,
                includingPropertiesForKeys: nil
            )

            // if you want to get all ncrpt files located at the documents directory:
            let ncrpt = directoryContents.filter(\.isNCRPT)
            self.objectWillChange.send()
            ncrpt.forEach { url in
                files.append(fileItem(name: url.lastPathComponent, url: url))
            }
            
            print("ncrpt:", ncrpt)
            
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
