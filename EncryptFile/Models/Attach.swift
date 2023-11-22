//
//  Attach.swift
//  EncryptFile
//
//  Created by Kirill Anisimov on 16.12.2022.
//

import Foundation

struct Attach: Identifiable, Codable, Hashable {
    var id: Int = 0
    var url: URL?
    var size: String {
        let isAccessing = url?.startAccessingSecurityScopedResource() ?? false
        if isAccessing {
            return url?.fileSize() ?? ""
        }
        return ""
    }
    var name: String {
        url?.lastPathComponent ?? ""
    }
    var ext: String {
        url?.pathExtension ?? ""
    }
}
