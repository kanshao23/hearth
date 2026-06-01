import SwiftUI

// SF Pro = system; SF Mono ≈ monospaced system design. Matches --sans / --mono.
enum F {
    static func sans(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }
    static func mono(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

// Type scale from tokens.css (--t-11 … --t-32). Kept as plain numbers since most
// call-sites in the design use literal fractional sizes (12.5, 13.5, …).
enum T {
    static let t11: CGFloat = 11
    static let t12: CGFloat = 12
    static let t13: CGFloat = 13
    static let t14: CGFloat = 14
    static let t15: CGFloat = 15
    static let t17: CGFloat = 17
    static let t20: CGFloat = 20
    static let t24: CGFloat = 24
    static let t32: CGFloat = 32
}
