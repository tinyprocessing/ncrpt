//
//  User.swift
//  EncryptFile
//
//  Created by Kirill Anisimov on 16.12.2022.
//

import Foundation

struct User: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var email: String
    var rights: Set<String>

    var allRights: String {
        rights.joined(separator: ",")
    }

    init(id: UUID = UUID(), name: String = "", email: String = "", rights: Set<String> = Set<String>()) {
        self.id = id
        self.name = name
        self.email = email
        self.rights = rights
    }
}
