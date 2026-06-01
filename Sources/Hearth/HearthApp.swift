import SwiftUI

@main
struct HearthApp: App {
    @StateObject private var theme = ThemeManager()

    var body: some Scene {
        WindowGroup {
            GalleryView()
                .environmentObject(theme)
                .environment(\.tk, Tokens.from(theme.theme))
                .frame(minWidth: 900, minHeight: 640)
                .preferredColorScheme(theme.isLight ? .light : .dark)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
