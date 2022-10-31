//
//  IconMenuView.swift
//  EncryptFile
//
//  Created by Kirill Anisimov on 28.10.2022.
//

import SwiftUI

struct IconMenuView: View {
    var icon: String
    var body: some View {
        Image(icon)
            .resizable()
            .frame(width: 48, height: 48)
            .clipShape(Circle())
    }
}
