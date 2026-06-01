import SwiftUI

// SwiftUI has no native oklch(). The design tokens (tokens.css) are authored in
// oklch, so we convert exactly — OKLab → linear sRGB → gamma-encoded sRGB — to
// keep the amber / semantic / diff colors faithful instead of eyeballing hex.
extension Color {
    /// `l` in 0…1 (the CSS "76%" → 0.76), `c` absolute chroma, `h` hue degrees.
    init(oklch l: Double, _ c: Double, _ h: Double, _ alpha: Double = 1) {
        let hr = h * .pi / 180
        let a = c * cos(hr)
        let b = c * sin(hr)

        // OKLab → LMS (cubed)
        let l_ = l + 0.3963377774 * a + 0.2158037573 * b
        let m_ = l - 0.1055613458 * a - 0.0638541728 * b
        let s_ = l - 0.0894841775 * a - 1.2914855480 * b
        let lc = l_ * l_ * l_
        let mc = m_ * m_ * m_
        let sc = s_ * s_ * s_

        // LMS → linear sRGB
        let rl =  4.0767416621 * lc - 3.3077115913 * mc + 0.2309699292 * sc
        let gl = -1.2684380046 * lc + 2.6097574011 * mc - 0.3413193965 * sc
        let bl = -0.0041960863 * lc - 0.7034186147 * mc + 1.7076147010 * sc

        func gamma(_ x: Double) -> Double {
            let v = max(0, min(1, x))
            return v <= 0.0031308 ? v * 12.92 : 1.055 * pow(v, 1 / 2.4) - 0.055
        }
        self.init(.sRGB, red: gamma(rl), green: gamma(gl), blue: gamma(bl), opacity: alpha)
    }

    /// `#rrggbb` or `#rrggbbaa` hex (with or without leading `#`).
    init(hex: String) {
        var s = hex
        if s.hasPrefix("#") { s.removeFirst() }
        var value: UInt64 = 0
        Scanner(string: s).scanHexInt64(&value)
        let r, g, b, a: Double
        if s.count == 8 {
            r = Double((value >> 24) & 0xff) / 255
            g = Double((value >> 16) & 0xff) / 255
            b = Double((value >> 8) & 0xff) / 255
            a = Double(value & 0xff) / 255
        } else {
            r = Double((value >> 16) & 0xff) / 255
            g = Double((value >> 8) & 0xff) / 255
            b = Double(value & 0xff) / 255
            a = 1
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }

    /// White at a given opacity — matches `rgba(255,255,255,α)` in the tokens.
    static func whiteA(_ alpha: Double) -> Color { Color(.sRGB, white: 1, opacity: alpha) }
    /// Warm near-black ink (1c1a16) at a given opacity — light-theme text.
    static func ink(_ alpha: Double) -> Color {
        Color(.sRGB, red: 28 / 255, green: 26 / 255, blue: 22 / 255, opacity: alpha)
    }
}
