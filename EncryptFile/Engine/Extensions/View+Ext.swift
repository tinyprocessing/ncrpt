//
//  View+Ext.swift
//  EncryptFile
//
//  Created by Kirill Anisimov on 01.11.2022.
//

import SwiftUI

extension View {
    func `if`<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> some View {
         if conditional {
             return AnyView(content(self))
         } else {
             return AnyView(self)
         }
     }
}
