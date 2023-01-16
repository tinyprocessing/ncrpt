//
//  NcrptMacOSDocument.swift
//  NcrptMacOS
//
//  Created by Michael Safir on 16.01.2023.
//

import SwiftUI
import UniformTypeIdentifiers


extension UTType {
    static var ncrpt: UTType {
        UTType.types(tag: "ncrpt", tagClass: .filenameExtension, conformingTo: nil).first!
    }
    
    static var png: UTType {
        UTType.types(tag: "png", tagClass: .filenameExtension, conformingTo: nil).first!
    }
}

final class DecryptDocument: ReferenceFileDocument, ObservableObject {
    
    typealias Snapshot = ContentDecrypt
    
    
    
    static var readableContentTypes: [UTType] { [.ncrpt, .png] }
    
    func snapshot(contentType: UTType) throws -> ContentDecrypt {
        ContentDecrypt()
    }
    
    init() {
        
    }
    
    init(configuration: ReadConfiguration) throws {
        guard configuration.file.regularFileContents != nil
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    

    func fileWrapper(snapshot: ContentDecrypt, configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode("snapshot")
        let fileWrapper = FileWrapper(regularFileWithContents: data)
        return fileWrapper
    }
}

