//
//  Template.swift
//  EncryptFile
//
//  Created by Kirill Anisimov on 16.12.2022.
//

import Foundation

struct Template: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var rights: Set<String>
    var users: Set<User>
    
    init(id: UUID = UUID(),
         name: String = "",
         rights: Set<String> = Set<String>(),
         users: Set<User> = Set<User>()
    ) {
        self.id = id
        self.name = name
        self.rights = rights
        self.users = users
    }
}
