//
//  Strings.swift
//  EncryptFile
//
//  Created by Michael Safir on 16.01.2023.
//

import Foundation

extension String {

    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map {
                substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}

extension String {
    func stringByRemovingAll(characters: [Character]) -> String {
        return String(self.filter({ !characters.contains($0) }))
    }
}
