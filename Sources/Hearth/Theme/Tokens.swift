import SwiftUI

// Direct port of tokens.css. Theme-dependent roles live on `Tokens` (built per
// light/dark). Chip / banner accent literals that tokens.css does NOT override
// per-theme live on `Sem` as constants.
struct Tokens {
    // Surfaces
    let bg, bg2, surface, surface2, surface3, hover, hoverSoft: Color
    // Borders
    let line, line2, lineStrong: Color
    // Text
    let fg, fg2, fg3, fg4: Color
    // Amber accent
    let amber, amber2, amberBg, amberLine, amberText: Color
    // Semantic
    let ok, warn, danger, info: Color
    // Diff
    let addBg, addFg, delBg, delFg: Color
    // Shadow tuning
    let shadowStrong: Color
    let isLight: Bool

    static let dark = Tokens(
        bg: Color(hex: "0b0b0e"), bg2: Color(hex: "111116"),
        surface: Color(hex: "15151b"), surface2: Color(hex: "1c1c24"),
        surface3: Color(hex: "23232c"), hover: Color(hex: "20202a"),
        hoverSoft: .whiteA(0.025),
        line: Color(hex: "26262e"), line2: Color(hex: "2e2e38"), lineStrong: Color(hex: "3a3a45"),
        fg: .whiteA(0.92), fg2: .whiteA(0.66), fg3: .whiteA(0.42), fg4: .whiteA(0.24),
        amber: Color(oklch: 0.76, 0.135, 65), amber2: Color(oklch: 0.82, 0.13, 70),
        amberBg: Color(oklch: 0.76, 0.135, 65, 0.14), amberLine: Color(oklch: 0.76, 0.135, 65, 0.35),
        amberText: Color(oklch: 0.82, 0.13, 70),
        ok: Color(oklch: 0.74, 0.13, 155), warn: Color(oklch: 0.78, 0.14, 85),
        danger: Color(oklch: 0.70, 0.17, 25), info: Color(oklch: 0.70, 0.09, 240),
        addBg: Color(oklch: 0.60, 0.13, 150, 0.12), addFg: Color(oklch: 0.82, 0.16, 150),
        delBg: Color(oklch: 0.60, 0.18, 25, 0.12), delFg: Color(oklch: 0.78, 0.16, 25),
        shadowStrong: .black.opacity(0.55), isLight: false
    )

    static let light = Tokens(
        bg: Color(hex: "faf9f5"), bg2: Color(hex: "f3f1ec"),
        surface: Color(hex: "ffffff"), surface2: Color(hex: "f5f3ee"),
        surface3: Color(hex: "ebe9e3"), hover: Color(hex: "efede8"),
        hoverSoft: .ink(0.03),
        line: Color(hex: "e2dfd9"), line2: Color(hex: "d3d0c8"), lineStrong: Color(hex: "b8b4ab"),
        fg: .ink(0.94), fg2: .ink(0.66), fg3: .ink(0.46), fg4: .ink(0.26),
        amber: Color(oklch: 0.62, 0.16, 60), amber2: Color(oklch: 0.56, 0.16, 55),
        amberBg: Color(oklch: 0.62, 0.16, 60, 0.12), amberLine: Color(oklch: 0.62, 0.16, 60, 0.32),
        amberText: Color(oklch: 0.46, 0.14, 50),
        ok: Color(oklch: 0.48, 0.14, 155), warn: Color(oklch: 0.58, 0.15, 75),
        danger: Color(oklch: 0.52, 0.18, 25), info: Color(oklch: 0.52, 0.11, 240),
        addBg: Color(oklch: 0.94, 0.07, 150, 0.9), addFg: Color(oklch: 0.38, 0.14, 150),
        delBg: Color(oklch: 0.94, 0.06, 25, 0.9), delFg: Color(oklch: 0.42, 0.17, 25),
        shadowStrong: .ink(0.14), isLight: true
    )

    /// Ink color for filled-amber foregrounds (button label on amber, etc.) — #1b1300.
    let onAmber = Color(hex: "1b1300")

    // OS-level translucent surfaces (menubar strip, notification, palette).
    var osStrip: Color {
        isLight ? Color(.sRGB, red: 248/255, green: 246/255, blue: 240/255, opacity: 0.88)
                : Color(.sRGB, red: 28/255, green: 28/255, blue: 36/255, opacity: 0.85)
    }
    var osStripLine: Color { isLight ? .ink(0.10) : .whiteA(0.06) }
    var osOverlay: Color {
        isLight ? Color(.sRGB, red: 255/255, green: 254/255, blue: 250/255, opacity: 0.94)
                : Color(.sRGB, red: 28/255, green: 28/255, blue: 36/255, opacity: 0.92)
    }
    var osOverlayLine: Color { isLight ? .ink(0.10) : .whiteA(0.08) }

    static func from(_ theme: AppTheme) -> Tokens { theme == .light ? .light : .dark }
}

// Accent literals used by chips / banners — tokens.css does not vary these by theme.
enum Sem {
    static let warnChipBg = Color(oklch: 0.78, 0.14, 85, 0.14)
    static let warnChipLine = Color(oklch: 0.78, 0.14, 85, 0.35)
    static let warnChipFg = Color(oklch: 0.85, 0.14, 85)
    static let okChipBg = Color(oklch: 0.74, 0.13, 155, 0.14)
    static let okChipLine = Color(oklch: 0.74, 0.13, 155, 0.35)
    static let okChipFg = Color(oklch: 0.82, 0.13, 155)
    static let dangerChipBg = Color(oklch: 0.70, 0.17, 25, 0.14)
    static let dangerChipLine = Color(oklch: 0.70, 0.17, 25, 0.35)
    static let dangerChipFg = Color(oklch: 0.78, 0.16, 25)

    // Banner tones (action-banner.jsx)
    static let okBannerBg = Color(oklch: 0.74, 0.13, 155, 0.10)
    static let warnBannerBg = Color(oklch: 0.78, 0.14, 85, 0.10)
    static let dangerBannerBg = Color(oklch: 0.70, 0.17, 25, 0.10)
    static let dangerBannerFg = Color(oklch: 0.82, 0.16, 25)

    // Blue repo glyph tone
    static let blueBg = Color(oklch: 0.70, 0.09, 240, 0.15)
    static let blueLine = Color(oklch: 0.70, 0.09, 240, 0.40)
    static let blueFg = Color(oklch: 0.82, 0.10, 240)

    // Code keyword colors (dark)
    static let codeK = Color(oklch: 0.78, 0.12, 290)
    static let codeS = Color(oklch: 0.78, 0.14, 130)
    static let codeN = Color(oklch: 0.78, 0.14, 60)
}

// Environment plumbing so leaf views can read tokens without the manager.
private struct TokensKey: EnvironmentKey {
    static let defaultValue: Tokens = .dark
}
extension EnvironmentValues {
    var tk: Tokens {
        get { self[TokensKey.self] }
        set { self[TokensKey.self] = newValue }
    }
}

enum Radius {
    static let r1: CGFloat = 4
    static let r2: CGFloat = 6
    static let r3: CGFloat = 8
}
