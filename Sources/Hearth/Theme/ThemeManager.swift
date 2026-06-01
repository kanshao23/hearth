import SwiftUI

enum AppTheme: String {
    case dark, light
}

// Global theme, mirrors theme.jsx — toggles [data-theme] and persists across
// launches. Injected as an EnvironmentObject so every token reads the live mode.
final class ThemeManager: ObservableObject {
    @Published var theme: AppTheme {
        didSet { UserDefaults.standard.set(theme.rawValue, forKey: Self.key) }
    }

    private static let key = "hearth-theme"

    init() {
        let saved = UserDefaults.standard.string(forKey: Self.key)
        theme = AppTheme(rawValue: saved ?? "") ?? .dark
    }

    var isLight: Bool { theme == .light }

    func toggle() {
        theme = isLight ? .dark : .light
    }
}
