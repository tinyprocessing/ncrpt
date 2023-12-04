import SwiftUI

enum Appearance: Int, CaseIterable, Identifiable {
    case light, dark, automatic

    var id: Int { rawValue }

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
