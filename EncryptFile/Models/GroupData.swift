//
//  GroupData.swift
//  EncryptFile
//
//  Created by Kirill Anisimov on 28.10.2022.
//

import Foundation
import SwiftUI

struct GroupData: Hashable {
    let id = UUID()
    var name: String
    var logo: String?
    var accentColor: Color
    var teams = [TeamData]()

    func getFirstChar() -> String {
        return (name.first?.uppercased())!
    }
}

struct TeamData: Hashable {
    let id = UUID()
    var name: String
    var logo: String?
    var accentColor: Color

    func getFirstChar() -> String {
        return (name.first?.uppercased())!
    }
}
