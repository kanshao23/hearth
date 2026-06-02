import Testing
import SwiftUI
import AppKit
@testable import Hearth

@Suite struct TokensTests {
    @Test func themesDiffer() {
        #expect(!Tokens.dark.isLight)
        #expect(Tokens.light.isLight)
        let d = NSColor(Tokens.dark.bg).usingColorSpace(.sRGB)!
        let l = NSColor(Tokens.light.bg).usingColorSpace(.sRGB)!
        #expect(d.brightnessComponent < 0.2)
        #expect(l.brightnessComponent > 0.8)
    }

    @Test func radiiOrdered() {
        #expect(Radius.r1 < Radius.r2)
        #expect(Radius.r2 < Radius.r3)
    }

    @Test func themeManagerToggle() {
        let m = ThemeManager()
        let start = m.theme
        m.toggle()
        #expect(m.theme != start)
        m.toggle()
        #expect(m.theme == start)
    }

    @Test func tokensFromTheme() {
        #expect(Tokens.from(.light).isLight)
        #expect(!Tokens.from(.dark).isLight)
    }
}
