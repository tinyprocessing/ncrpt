//
//  FileDocumentStruct.swift
//  EncryptFile
//
//  Created by Michael Safir on 26.10.2022.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var docx: UTType {
        UTType.types(tag: "docx", tagClass: .filenameExtension, conformingTo: nil).first!
    }
    
    static var pptx: UTType {
        UTType.types(tag: "pptx", tagClass: .filenameExtension, conformingTo: nil).first!
    }
    
    static var xlsx: UTType {
        UTType.types(tag: "xlsx", tagClass: .filenameExtension, conformingTo: nil).first!
    }
    
    static var png: UTType {
        UTType.types(tag: "png", tagClass: .filenameExtension, conformingTo: nil).first!
    }
    
    static var JPG: UTType {
        UTType.types(tag: "JPG", tagClass: .filenameExtension, conformingTo: nil).first!
    }
    
    static var jpg: UTType {
        UTType.types(tag: "jpg", tagClass: .filenameExtension, conformingTo: nil).first!
    }
    
    static var JPEG: UTType {
        UTType.types(tag: "JPEG", tagClass: .filenameExtension, conformingTo: nil).first!
    }
    
    static var txt: UTType {
        UTType.types(tag: "txt", tagClass: .filenameExtension, conformingTo: nil).first!
    }
    
    static var ncrpt: UTType {
        UTType.types(tag: "ncrpt", tagClass: .filenameExtension, conformingTo: nil).first!
    }
}


struct FileDocumentStruct: FileDocument {
    
    static var readableContentTypes: [UTType] { [.ncrpt] }
    var url: URL? = nil
    
    init() {}
    
    init(configuration: ReadConfiguration) throws {
        guard configuration.file.regularFileContents != nil
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode("snapshot")
        let fileWrapper = FileWrapper(regularFileWithContents: data)
        return fileWrapper
    }
    
}
