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
    
    let permissionSet = ["View", "Edit", "Owner"]
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
        getSampleTempl()
        getSampleRecentUsers()
    }
    
    //Samples to UI
    func getSampleTempl() {
        templates = [
            Template(name: "Developers", users: ["mdsafir@ncrpt.io", "kaanisimov@ncrpt.io"], rights: ["Owner"]),
            Template(name: "Accountants", users: ["nasozinov@ncrpt.io"], rights: ["View", "Edit"]),
        ]
    }
    
    func getSampleRecentUsers() {
        recentUsers = [User(email: "mdsafir@ncrpt.io", rights: ["View"]),
                       User(email: "kaanisimov@ncrpt.io", rights: ["View", "Edit"]),
                       User(email: "nasozinov@ncrpt.io", rights: ["Owner"])]
    }
    
    //helper methods
    
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
    
    func addNewUser(_ user: User) {
        recentUsers.append(user)
    }
    
    func addFileURL(_ url: URL) {
        if !chosenFiles.contains(where: { $0.url == url }) {
            chosenFiles.append(Attach(url: url))
        }        
    }
    //UTType
    func getAtualTypes() -> [UTType]{
        return [.pdf, .docx, .png, .jpg, .jpeg, .zip, .image, .tiff, .gif, .pptx, .xlsx, .plainText]
    }
    
}

struct Template: Identifiable, Hashable {
    let id = UUID()
    var name: String = ""
    var users: [String] = []
    var rights: Set<String>
    
    var allRights: String {
        rights.joined(separator: ", ")
    }
}

struct User: Identifiable, Hashable {
    let id = UUID()
    var name: String = ""
    var email: String = ""
    var rights: Set<String>
    
    var allRights: String {
        rights.joined(separator: ", ")
    }
}

struct Attach: Hashable {
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
    var ext : String = ""
}

