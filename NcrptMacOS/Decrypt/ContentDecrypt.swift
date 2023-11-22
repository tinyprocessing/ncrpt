//
//  ContentDecrypt.swift
//  NcrptMacOS
//
//  Created by Michael Safir on 16.01.2023.
//
import SwiftUI
import Foundation
import UniformTypeIdentifiers


class ContentDecrypt: Identifiable, ObservableObject {
    
    
    @Published var id = UUID()
    
    @Published var content : Data? = nil
    @Published var type : UTType? = nil
    @Published var url : URL? = nil
    @Published var urlSource : URL? = nil
    @Published var secure : Bool = false
    @Published var name : String = ""
    @Published var isUpdating : Bool = false
    
    @Published var error : NCRPTError? = nil
    
    struct NCRPTError: Identifiable, Hashable, Codable {
        var id = 0
        var title: String = ""
        var about: String = ""
        var owner: String = ""
        var repeatUrl: URL?
    }
    
    
    func clear() {
        self.objectWillChange.send()
        self.content = nil
        self.type = nil
        self.url = nil
        self.urlSource = nil
        self.secure = false
        self.name = ""
        self.isUpdating = false
    }
    
    
    func changeTabTitle(_ name: String, _ title : String, _ image: String?){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            DispatchQueue.main.async {
                NSApplication.shared.mainWindow?.tabGroup?.windows.forEach({ window in
                    print(window.tab.title.lowercased())
                    if (window.tab.title.lowercased().contains(name.lowercased())){
                        window.title = ""
                        window.tab.title = title
                        
                        if image != nil {
                            if image == "checkmark.shield" {
                                let view  = NSHostingView(rootView: Image(systemName: "lock").padding(.trailing, 5).foregroundColor(.black))
                                window.tab.accessoryView = view
                            }
                            
                            if image == "exclamationmark.triangle" {
                                let view  = NSHostingView(rootView:  Image(systemName: "lock").padding(.trailing, 5).foregroundColor(.red))
                                window.tab.accessoryView = view
                            }
                        }
                    }
                })
            }
        }
    }
    
    
    func openFile(inputURL: URL) {
        
        self.objectWillChange.send()
        self.urlSource = inputURL
        self.isUpdating = true
        
        let fileUTType = UTType.types(tag: inputURL.pathExtension, tagClass: .filenameExtension, conformingTo: nil).first!
        let avalibeUTTypes : [UTType] = [.ncrpt, .png]
        
        if avalibeUTTypes.contains(fileUTType) {
            let polygone = Polygone()
            if fileUTType == .ncrpt{
                self.changeTabTitle(inputURL.lastPathComponent,  inputURL.lastPathComponent, "lock.shield")
                polygone.decryptFile(inputURL) { url, rights, success in
                    if success{
                        DispatchQueue.main.async {
                            self.isUpdating = false
                            self.url = url
                        }
                    }else{
                        log.debug(module: "ContentDecrypt", type: #function, object: "error decrypt file")
                        self.isUpdating = false
                        self.error = NCRPTError(id: 0, title: "Error",
                                                about: "You do not have enough permissions to open this file, contact your administrator.",
                                                owner: "",
                                                repeatUrl: nil)
                    }
                }
            }else{
                self.isUpdating = false
                self.url = inputURL
            }
        }else{
            self.isUpdating = false
            self.error = NCRPTError(id: 0, title: "Error",
                                    about: "This file type is not supported",
                                    owner: "",
                                    repeatUrl: nil)
        }
    }
    
}

extension ContentDecrypt: Equatable {
    public static func == (lhs: ContentDecrypt, rhs: ContentDecrypt) -> Bool {
        return lhs.id == rhs.id
    }
}
