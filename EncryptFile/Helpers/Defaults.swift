import Foundation

extension UserDefaults {
    enum Keys: String, CaseIterable {
        case AuthorizationUsername
        case SettingsFaceID
        case SettingsTrust
        case SettingsCrashReporting
        case SettingsRSA
        case SettingsCompress
        case SettingsServer

        case RSASetup
    }

    func reset() {
        Keys.allCases.forEach { removeObject(forKey: $0.rawValue) }
        set(true, forKey: UserDefaults.Keys.SettingsFaceID.rawValue)
        set(true, forKey: UserDefaults.Keys.SettingsTrust.rawValue)

        set(true, forKey: UserDefaults.Keys.SettingsCrashReporting.rawValue)
        set(true, forKey: UserDefaults.Keys.SettingsRSA.rawValue)
        set(true, forKey: UserDefaults.Keys.SettingsCompress.rawValue)
        set("https://secure.ncrpt.io", forKey: UserDefaults.Keys.SettingsServer.rawValue)

        set(false, forKey: UserDefaults.Keys.RSASetup.rawValue)
    }
}
