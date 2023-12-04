//
//  URL+Ext.swift
//  EncryptFile
//
//  Created by Kirill Anisimov on 07.11.2022.
//

import Foundation

extension URL {
    var fileSizeExtension: Int? {
        let value = try? resourceValues(forKeys: [.fileSizeKey])
        return value?.fileSize
    }
    
    func fileSize() -> String? {
        if let fileSize = self.fileSizeExtension {
            // bytes
            if fileSize < 1023 {
                return String(format: "%lu bytes", CUnsignedLong(fileSize))
            }
            // KB
            var floatSize = Float(fileSize / 1024)
            if floatSize < 1023 {
                return String(format: "%.1f KB", floatSize)
            }
            // MB
            floatSize = floatSize / 1024
            if floatSize < 1023 {
                return String(format: "%.1f MB", floatSize)
            }
            // GB
            floatSize = floatSize / 1024
            return String(format: "%.1f GB", floatSize)
        }
        return nil
    }
}
