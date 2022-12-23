//
//  ProtectViewModel.swift
//  EncryptFile
//
//  Created by Kirill Anisimov on 06.11.2022.
//

import SwiftUI
import UniformTypeIdentifiers

class ProtectViewModel: ObservableObject {
    
    @Published var templates: [Template] = []
    @Published var recentUsers: [User] = []
    @Published var selectedResentUsers: [User] = []
    @Published var chosenFiles: [Attach] = []
    @Published var isRightsNoExpired: Bool = true
    @Published var untilDate: Date = Date()
    
    @Published var selectedTemplated: UUID = UUID()
    @Published var rights: Rights? = nil
    
    let permissionSet = ["View",
                         "Copy",
                         "Owner"]
    /*
     "Docedit",
     "Comment",
     "Export",
     "Forward",
     "Print",
     "Reply",
     "Replyall",
     "Extract",
     "Viewrightsdata",
     "Editrightsdata",
     "Objmodel"
     */
    
    init() {
        loadTemplates()
        loadUsers()
    }
    
    //helper methods
    
    func loadTemplates() {
        LocalStorageEngine.loadTemplates { result in
            switch result {
            case .failure(let error):
                fatalError(error.localizedDescription)
            case .success(let templates):
                self.templates = templates
            }
        }
    }
    
    func loadUsers() {
        LocalStorageEngine.loadUsers { result in
            switch result {
            case .failure(let error):
                fatalError(error.localizedDescription)
            case .success(let users):
                self.recentUsers = users
            }
        }
    }
    
    func isCurTemplate(_ templ: Template) -> Bool {
        return selectedTemplated == templ.id
    }
    
    func selectTemplate(_ id: UUID) {
        if selectedTemplated == id {
            selectedTemplated = UUID()
        } else {
            selectedTemplated = id
        }
    }
    
    func isSelUser(_ user: User) -> Bool {
        return selectedResentUsers.contains { $0.id == user.id }
    }
    
    func addSelectUser(_ user: User) {
        if selectedResentUsers.contains(where: { $0.id == user.id }) {
            let inx = selectedResentUsers.firstIndex { $0.id == user.id }!
            selectedResentUsers.remove(at: inx)
        } else {
            selectedResentUsers.append(user)
        }
    }
    
    func addFileURL(_ url: URL) {
        if !chosenFiles.contains(where: { $0.url == url }) {
            chosenFiles.append(Attach(url: url))
        }        
    }
    //UTType
    func getAtualTypes() -> [UTType]{
        return [.item]
    }
    
    func addTemplate(_ temp: Template, new: Bool = false) {
        if new {
            templates.append(temp)
        } else {
            if let inx = templates.firstIndex(where: { $0.id == temp.id }) {
                templates[inx] = temp
            }
        }
        LocalStorageEngine.saveTemplates(templates: templates) { result in
            if case .failure(let error) = result {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func addNewUser(_ user: User, new: Bool = false) {
        if new {
            recentUsers.append(user)
        } else {
            if let inx = recentUsers.firstIndex(where: { $0.id == user.id }) {
                recentUsers[inx] = user
            }
        }
        LocalStorageEngine.saveUsers(users: recentUsers) { result in
            if case .failure(let error) = result {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func removeTemplate(at offset: IndexSet) {
        templates.remove(atOffsets: offset)
        LocalStorageEngine.saveTemplates(templates: templates) { result in
            if case .failure(let error) = result {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func removeUser(at offset: IndexSet) {
        recentUsers.remove(atOffsets: offset)
        LocalStorageEngine.saveUsers(users: recentUsers) { result in
            if case .failure(let error) = result {
                fatalError(error.localizedDescription)
            }
        }
    }
    
}


extension ProtectViewModel {
    
    //Samples to UI
    static func getSampleTempl() -> [Template] {
        return [
            Template(name: "Developers",  rights: ["Owner"]),
            Template(name: "Accountants",  rights: ["View", "Edit"]),
        ]
    }
    
    static func getSampleRecentUsers() -> [User] {
        return [User(email: "mdsafir@ncrpt.io", rights: ["View"]),
                User(email: "kaanisimov@ncrpt.io", rights: ["View", "Edit"]),
                User(email: "nasozinov@ncrpt.io", rights: ["Owner"])]
    }
}
