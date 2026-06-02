import Testing
import SwiftUI
import AppKit
@testable import Hearth

private func rgba(_ c: Color) -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
    let ns = NSColor(c).usingColorSpace(.sRGB) ?? NSColor(c)
    return (ns.redComponent, ns.greenComponent, ns.blueComponent, ns.alphaComponent)
}
private func near(_ a: CGFloat, _ b: CGFloat, _ tol: CGFloat = 0.02) -> Bool { abs(a - b) <= tol }

@Suite struct ColorTests {
    @Test func oklchWhiteAndBlack() {
        let w = rgba(Color(oklch: 1.0, 0.0, 0.0))
        #expect(near(w.r, 1) && near(w.g, 1) && near(w.b, 1))
        let k = rgba(Color(oklch: 0.0, 0.0, 0.0))
        #expect(near(k.r, 0) && near(k.g, 0) && near(k.b, 0))
    }

    @Test func oklchAmberIsWarm() {
        let a = rgba(Color(oklch: 0.76, 0.135, 65))
        #expect(a.r > a.g && a.g > a.b)
        #expect([a.r, a.g, a.b].allSatisfy { $0 >= 0 && $0 <= 1 })
    }

    @Test func oklchAlphaPassthrough() {
        #expect(near(rgba(Color(oklch: 0.5, 0.1, 30, 0.3)).a, 0.3))
    }

    @Test func hexParsing() {
        let r = rgba(Color(hex: "ff0000"))
        #expect(near(r.r, 1) && near(r.g, 0) && near(r.b, 0) && near(r.a, 1))
    }

    @Test func hexWithAlpha() {
        #expect(near(rgba(Color(hex: "00000080")).a, 0.5))
    }

    @Test func hexLeadingHashTolerated() {
        let a = rgba(Color(hex: "#15151b"))
        let b = rgba(Color(hex: "15151b"))
        #expect(near(a.r, b.r, 0.001) && near(a.b, b.b, 0.001))
    }

    @Test func gamutClamp() {
        let c = rgba(Color(oklch: 0.6, 0.4, 25))
        #expect([c.r, c.g, c.b].allSatisfy { $0 >= 0 && $0 <= 1 })
    }
}
