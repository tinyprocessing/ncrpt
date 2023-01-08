//
//  Appearance.swift
//  EncryptFile
//
//  Created by Kirill Anisimov on 02.01.2023.
//

import SwiftUI

enum Appearance: Int, CaseIterable, Identifiable {
  case light, dark, automatic
  
  var id: Int { self.rawValue }
  
  var name: String {
    switch self {
    case .light: return "Light"
    case .dark: return "Dark"
    case .automatic: return "Automatic"
    }
  }
  
  func getColorScheme() -> ColorScheme? {
    switch self {
    case .automatic: return nil
    case .light: return .light
    case .dark: return .dark
    }
  }
}
