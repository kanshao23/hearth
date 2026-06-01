import SwiftUI

// Spec + paths transcribed verbatim from icons.jsx (14×14 viewBox, 1.5 stroke,
// round caps). Color is inherited from the caller's foregroundStyle.
struct IconSpec {
    let d: [String]
    var fill = false
    var stroke: CGFloat = 1.5
    var vb: CGFloat = 14
}

struct HIcon: View {
    let spec: IconSpec
    var size: CGFloat = 14

    init(_ spec: IconSpec, size: CGFloat = 14) {
        self.spec = spec
        self.size = size
    }

    var body: some View {
        let shape = SVGPath(spec.d, viewBox: spec.vb)
        Group {
            if spec.fill {
                shape.fill(style: FillStyle(eoFill: false))
            } else {
                shape.stroke(style: StrokeStyle(
                    lineWidth: spec.stroke * (size / spec.vb),
                    lineCap: .round, lineJoin: .round))
            }
        }
        .frame(width: size, height: size)
    }
}

// The four-tile hearth mark — drawn directly (rects with per-tile opacity).
struct LogoMark: View {
    var size: CGFloat = 16
    var body: some View {
        let s = size / 16
        ZStack {
            tile(1.5, 1.5, 0.95, s)
            tile(8.5, 1.5, 0.45, s)
            tile(1.5, 8.5, 0.45, s)
            tile(8.5, 8.5, 0.95, s)
        }
        .frame(width: size, height: size)
    }
    private func tile(_ x: CGFloat, _ y: CGFloat, _ op: Double, _ s: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 1.2 * s)
            .fill(.foreground.opacity(op))
            .frame(width: 6 * s, height: 6 * s)
            .position(x: (x + 3) * s, y: (y + 3) * s)
    }
}

enum Ico {
    static let chevron = IconSpec(d: ["M5 3l4 4-4 4"])
    static let chevronDown = IconSpec(d: ["M3 5l4 4 4-4"])
    static let chevronUp = IconSpec(d: ["M3 9l4-4 4 4"])
    static let plus = IconSpec(d: ["M7 2v10", "M2 7h10"])
    static let search = IconSpec(d: ["M6 11A5 5 0 1 0 6 1a5 5 0 0 0 0 10z", "M9.6 9.6L13 13"])
    static let folder = IconSpec(d: ["M1.5 4.5a1 1 0 0 1 1-1H5l1.5 1.5h5a1 1 0 0 1 1 1V10a1 1 0 0 1-1 1h-9a1 1 0 0 1-1-1V4.5z"])
    static let file = IconSpec(d: ["M3 1.5h5L11 4.5v8a1 1 0 0 1-1 1H3a1 1 0 0 1-1-1v-10a1 1 0 0 1 1-1z", "M8 1.5V4.5h3"])
    static let terminal = IconSpec(d: ["M1.5 2.5h11v9h-11z", "M3.5 5.5L5.5 7l-2 1.5", "M6.5 8.5h4"])
    static let cog = IconSpec(d: ["M7 9a2 2 0 1 0 0-4 2 2 0 0 0 0 4z", "M11.3 8.3l1 .6-1 1.7-1.1-.4a3.8 3.8 0 0 1-1 .6L9 12H7l-.2-1.2a3.8 3.8 0 0 1-1-.6l-1.1.4-1-1.7 1-.6a3.8 3.8 0 0 1 0-1.2l-1-.6 1-1.7 1.1.4a3.8 3.8 0 0 1 1-.6L7 2h2l.2 1.2a3.8 3.8 0 0 1 1 .6l1.1-.4 1 1.7-1 .6a3.8 3.8 0 0 1 0 1.2z"])
    static let bell = IconSpec(d: ["M3.5 10.5h7M5.5 12.5a1.5 1.5 0 0 0 3 0", "M4 10.5V7a3 3 0 0 1 6 0v3.5"])
    static let check = IconSpec(d: ["M2.5 7.5l3 3 6-6"])
    static let x = IconSpec(d: ["M3 3l8 8", "M11 3l-8 8"])
    static let clock = IconSpec(d: ["M7 12.5a5.5 5.5 0 1 0 0-11 5.5 5.5 0 0 0 0 11z", "M7 4v3l2 1.5"])
    static let bolt = IconSpec(d: ["M7.5 1L3 8h3.5L6 13l4.5-7H7L7.5 1z"])
    static let sparkle = IconSpec(d: ["M7 1l1.2 3.8L12 6l-3.8 1.2L7 11l-1.2-3.8L2 6l3.8-1.2z", "M11 10l.6 1.4L13 12l-1.4.6L11 14l-.6-1.4L9 12l1.4-.6z"])
    static let branch = IconSpec(d: ["M4 2v10", "M10 2a1.5 1.5 0 1 1 0 3 1.5 1.5 0 0 1 0-3z", "M4 2a1.5 1.5 0 1 0 0 3 1.5 1.5 0 0 0 0-3z", "M4 12a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3z", "M10 5v1a3 3 0 0 1-3 3H4"])
    static let lock = IconSpec(d: ["M3 7h8v5.5a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V7z", "M4.5 7V4.5a2.5 2.5 0 0 1 5 0V7"])
    static let shield = IconSpec(d: ["M7 1.5l4.5 1.5v4c0 3-2 5-4.5 6-2.5-1-4.5-3-4.5-6v-4L7 1.5z"])
    static let play = IconSpec(d: ["M4 2.5l7 4.5-7 4.5z"], fill: true, stroke: 0)
    static let pause = IconSpec(d: ["M4.5 2.5h2v9h-2z", "M7.5 2.5h2v9h-2z"], fill: true, stroke: 0)
    static let stop = IconSpec(d: ["M3 3h8v8h-8z"], fill: true, stroke: 0)
    static let undo = IconSpec(d: ["M2 6l3-3v6z", "M4 6h6a3 3 0 0 1 0 6H7"])
    static let send = IconSpec(d: ["M12.5 1.5L1.5 5.5l4.5 2 2 4.5z", "M12.5 1.5L6 8"])
    static let dots = IconSpec(d: ["M3.5 7a.5.5 0 1 0 0 1 .5.5 0 0 0 0-1z", "M7 7a.5.5 0 1 0 0 1 .5.5 0 0 0 0-1z", "M10.5 7a.5.5 0 1 0 0 1 .5.5 0 0 0 0-1z"], fill: true, stroke: 1)
    static let tree = IconSpec(d: ["M3 2h3v3h-3z", "M8 9.5h3v3h-3z", "M8 2.5h3v3h-3z", "M4.5 5v3a1 1 0 0 0 1 1H8", "M9.5 5.5v3"])
    static let wand = IconSpec(d: ["M2 12l7-7", "M9 3l2 2", "M11.5 6.5l1 1", "M5 1.5l1 1"])
    static let globe = IconSpec(d: ["M7 12.5a5.5 5.5 0 1 0 0-11 5.5 5.5 0 0 0 0 11z", "M1.5 7h11", "M7 1.5a8 8 0 0 1 0 11M7 1.5a8 8 0 0 0 0 11"])
    static let disk = IconSpec(d: ["M2 2h8l2.5 2.5V12a1 1 0 0 1-1 1h-9a1 1 0 0 1-1-1V2z", "M4 2v3h6V2", "M4.5 13V8.5h5V13"])
    static let cpu = IconSpec(d: ["M3.5 3.5h7v7h-7z", "M5.5 5.5h3v3h-3z", "M3.5 6h-1M3.5 8h-1M10.5 6h1M10.5 8h1M6 3.5v-1M8 3.5v-1M6 11.5v-1M8 11.5v-1"])
    static let pin = IconSpec(d: ["M9.5 1.5l3 3-2 2-1-1L7 8.5l1 1-3 3v-3l-3-3 3-3 1 1 3-2.5-1-1z"])
    static let grip = IconSpec(d: ["M5 3.5a.5.5 0 1 0 0 1 .5.5 0 0 0 0-1z", "M5 6.5a.5.5 0 1 0 0 1 .5.5 0 0 0 0-1z", "M5 9.5a.5.5 0 1 0 0 1 .5.5 0 0 0 0-1z", "M9 3.5a.5.5 0 1 0 0 1 .5.5 0 0 0 0-1z", "M9 6.5a.5.5 0 1 0 0 1 .5.5 0 0 0 0-1z", "M9 9.5a.5.5 0 1 0 0 1 .5.5 0 0 0 0-1z"], fill: true, stroke: 1)
    static let mail = IconSpec(d: ["M1.5 3.5h11v7h-11z", "M1.5 3.5L7 8l5.5-4.5"])
    static let calendar = IconSpec(d: ["M2 3.5h10v8H2z", "M2 6h10", "M4.5 2v3M9.5 2v3"])
    static let repoIcon = IconSpec(d: ["M3 1.5h7.5a1 1 0 0 1 1 1V11H4a1 1 0 0 0-1 1V2.5a1 1 0 0 1 1-1z", "M11.5 11v1.5H4"])
    static let activity = IconSpec(d: ["M1.5 7h2.5L6 3l2 8 2-4h2.5"])
    static let cmd = IconSpec(d: ["M5 5h4v4H5zM5 5a1.5 1.5 0 1 1-1.5 1.5M9 5a1.5 1.5 0 1 0 1.5 1.5M5 9a1.5 1.5 0 1 0-1.5-1.5M9 9a1.5 1.5 0 1 1 1.5-1.5"])
    static let shift = IconSpec(d: ["M7 2l4 4H9v5H5V6H3z"])
    static let returnKey = IconSpec(d: ["M11.5 3v3a2 2 0 0 1-2 2H3", "M5.5 6L3 8.5l2.5 2.5"])
    static let sliders = IconSpec(d: ["M2 4h7M11 4h1.5", "M2 10h2M6 10h6.5", "M10 2.5v3M4.5 8.5v3"])
    static let star = IconSpec(d: ["M7 1.7l1.7 3.5 3.9.5-2.8 2.7.7 3.8L7 10.4 3.5 12.2l.7-3.8L1.4 5.7l3.9-.5z"])
    static let starFilled = IconSpec(d: ["M7 1.7l1.7 3.5 3.9.5-2.8 2.7.7 3.8L7 10.4 3.5 12.2l.7-3.8L1.4 5.7l3.9-.5z"], fill: true, stroke: 0)
    static let copy = IconSpec(d: ["M4 4V2.5a1 1 0 0 1 1-1h6a1 1 0 0 1 1 1v6a1 1 0 0 1-1 1H10", "M2.5 4h6a1 1 0 0 1 1 1v6a1 1 0 0 1-1 1h-6a1 1 0 0 1-1-1V5a1 1 0 0 1 1-1z"])
    static let sun = IconSpec(d: ["M7 4.5a2.5 2.5 0 1 0 0 5 2.5 2.5 0 0 0 0-5z", "M7 1v1.5M7 11.5V13M1 7h1.5M11.5 7H13M2.8 2.8l1 1M10.2 10.2l1 1M2.8 11.2l1-1M10.2 3.8l1-1"])
    static let moon = IconSpec(d: ["M11.5 8.2A4.7 4.7 0 0 1 5.8 2.5 5 5 0 1 0 11.5 8.2z"], fill: true, stroke: 0)
}
