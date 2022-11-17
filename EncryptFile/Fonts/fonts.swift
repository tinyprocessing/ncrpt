//
//  fonts.swift
//  EncryptFile
//
//  Created by Сафир Михаил Дмитриевич [B] on 17.11.2022.
//

import Foundation
import SwiftUI

struct NCRPTTextSemibold: ViewModifier {
    var size: CGFloat
    
    func body(content: Content) -> some View {
        content
            .font(Font.custom("Poppins-SemiBold",size:size))
    }
}

struct NCRPTTextRegular: ViewModifier {
    var size: CGFloat
    
    func body(content: Content) -> some View {
        content
            .font(Font.custom("Poppins-Regular",size:size))
    }
}

struct NCRPTTextMedium: ViewModifier {
    var size: CGFloat
    
    func body(content: Content) -> some View {
        content
            .font(Font.custom("Poppins-Medium",size:size))
    }
}

