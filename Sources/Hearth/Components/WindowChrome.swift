import SwiftUI

struct TrafficLights: View {
    var body: some View {
        HStack(spacing: 8) {
            dot(Color(hex: "ff5f57"))
            dot(Color(hex: "febc2e"))
            dot(Color(hex: "28c840"))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }
    private func dot(_ c: Color) -> some View {
        Circle().fill(c)
            .frame(width: 12, height: 12)
            .overlay(Circle().stroke(.black.opacity(0.25), lineWidth: 0.5))
    }
}

struct ThemeToggle: View {
    var size: CGFloat = 12
    @EnvironmentObject private var theme: ThemeManager
    var body: some View {
        HButton(kind: .ghost, hPad: 6, vPad: 3, action: { theme.toggle() }) {
            HIcon(theme.isLight ? Ico.moon : Ico.sun, size: size)
        }
    }
}

// Window titlebar background (.win-titlebar) — gradient differs by theme.
struct TitlebarBackground: View {
    @Environment(\.tk) private var tk
    var body: some View {
        LinearGradient(
            colors: tk.isLight ? [Color(hex: "f4f2ed"), Color(hex: "ece9e3")]
                               : [Color(hex: "18181f"), Color(hex: "131319")],
            startPoint: .top, endPoint: .bottom)
    }
}
