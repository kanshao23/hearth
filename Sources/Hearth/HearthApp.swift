import SwiftUI

@main
struct HearthApp: App {
    @StateObject private var theme = ThemeManager()
    private let launch = LaunchOptions.parse(CommandLine.arguments)

    init() {
        // `--list` prints the screen registry and exits before any UI loads.
        if CommandLine.arguments.contains("--list") {
            for s in GalleryView.screenList { print("\(s.id)\t\(s.label)") }
            exit(0)
        }
    }

    var body: some Scene {
        WindowGroup {
            GalleryView(initialScreen: launch.screen)
                .environmentObject(theme)
                .environment(\.tk, Tokens.from(theme.theme))
                .frame(minWidth: 900, minHeight: 640)
                .preferredColorScheme(theme.isLight ? .light : .dark)
        }
        .windowStyle(.hiddenTitleBar)
    }
}

struct LaunchOptions {
    var screen: String? = nil

    /// Parses `--screen <id>` from the argument vector.
    static func parse(_ args: [String]) -> LaunchOptions {
        var opts = LaunchOptions()
        if let i = args.firstIndex(of: "--screen"), i + 1 < args.count {
            opts.screen = args[i + 1]
        }
        return opts
    }
}
