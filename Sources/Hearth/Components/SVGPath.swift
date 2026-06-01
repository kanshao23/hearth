import SwiftUI

// Minimal SVG path renderer so the custom icon set (icons.jsx) reproduces
// faithfully instead of being approximated with SF Symbols. Parses the path `d`
// commands the icon set uses (M m L l H h V v C c S s Q q T t A a Z z); elliptical
// arcs are flattened to short line segments — fine at icon scale.
struct SVGPath: Shape {
    let commands: [String]   // one or more `d` strings, unioned
    let viewBox: CGFloat     // square viewBox edge (14 for icons, 16 for logo)

    init(_ commands: [String], viewBox: CGFloat = 14) {
        self.commands = commands
        self.viewBox = viewBox
    }

    func path(in rect: CGRect) -> Path {
        let s = min(rect.width, rect.height) / viewBox
        let ox = rect.minX + (rect.width - viewBox * s) / 2
        let oy = rect.minY + (rect.height - viewBox * s) / 2
        func map(_ p: CGPoint) -> CGPoint { CGPoint(x: ox + p.x * s, y: oy + p.y * s) }

        var path = Path()
        for d in commands {
            appendSubpath(d, into: &path, map: map)
        }
        return path
    }

    private func appendSubpath(_ d: String, into path: inout Path, map: (CGPoint) -> CGPoint) {
        var scanner = PathScanner(d)
        var cur = CGPoint.zero
        var start = CGPoint.zero
        var cmd: Character = " "
        while let next = scanner.nextCommandOrNil(after: cmd) {
            cmd = next
            let rel = cmd.isLowercase
            switch Character(cmd.lowercased()) {
            case "m":
                let p = scanner.point(rel: rel, cur: cur)
                cur = p; start = p
                path.move(to: map(cur))
                // subsequent implicit pairs are lineto
                while scanner.peekIsNumber {
                    cur = scanner.point(rel: rel, cur: cur)
                    path.addLine(to: map(cur))
                }
            case "l":
                while scanner.peekIsNumber {
                    cur = scanner.point(rel: rel, cur: cur)
                    path.addLine(to: map(cur))
                }
            case "h":
                while scanner.peekIsNumber {
                    let x = scanner.number()
                    cur.x = rel ? cur.x + x : x
                    path.addLine(to: map(cur))
                }
            case "v":
                while scanner.peekIsNumber {
                    let y = scanner.number()
                    cur.y = rel ? cur.y + y : y
                    path.addLine(to: map(cur))
                }
            case "c":
                while scanner.peekIsNumber {
                    let c1 = scanner.point(rel: rel, cur: cur)
                    let c2 = scanner.point(rel: rel, cur: cur)
                    let p = scanner.point(rel: rel, cur: cur)
                    path.addCurve(to: map(p), control1: map(c1), control2: map(c2))
                    cur = p
                }
            case "q":
                while scanner.peekIsNumber {
                    let c1 = scanner.point(rel: rel, cur: cur)
                    let p = scanner.point(rel: rel, cur: cur)
                    path.addQuadCurve(to: map(p), control: map(c1))
                    cur = p
                }
            case "a":
                while scanner.peekIsNumber {
                    let rx = scanner.number(), ry = scanner.number()
                    let rot = scanner.number()
                    let large = scanner.flag(), sweep = scanner.flag()
                    let p = scanner.point(rel: rel, cur: cur)
                    appendArc(from: cur, to: p, rx: rx, ry: ry, rotDeg: rot,
                              large: large, sweep: sweep, into: &path, map: map)
                    cur = p
                }
            case "z":
                path.closeSubpath()
                cur = start
            default:
                _ = scanner.number()   // skip unknown
            }
        }
    }

    // Endpoint → center parametrization, then flatten to segments.
    private func appendArc(from p0: CGPoint, to p1: CGPoint, rx: CGFloat, ry: CGFloat,
                           rotDeg: CGFloat, large: Bool, sweep: Bool,
                           into path: inout Path, map: (CGPoint) -> CGPoint) {
        var rx = abs(rx), ry = abs(ry)
        if rx == 0 || ry == 0 { path.addLine(to: map(p1)); return }
        let phi = rotDeg * .pi / 180
        let cosP = cos(phi), sinP = sin(phi)
        let dx = (p0.x - p1.x) / 2, dy = (p0.y - p1.y) / 2
        let x1 = cosP * dx + sinP * dy
        let y1 = -sinP * dx + cosP * dy
        var lambda = (x1 * x1) / (rx * rx) + (y1 * y1) / (ry * ry)
        if lambda > 1 { let s = sqrt(lambda); rx *= s; ry *= s; lambda = 1 }
        let num = max(0, rx * rx * ry * ry - rx * rx * y1 * y1 - ry * ry * x1 * x1)
        let den = rx * rx * y1 * y1 + ry * ry * x1 * x1
        var coef = den == 0 ? 0 : sqrt(num / den)
        if large == sweep { coef = -coef }
        let cxp = coef * rx * y1 / ry
        let cyp = -coef * ry * x1 / rx
        let cx = cosP * cxp - sinP * cyp + (p0.x + p1.x) / 2
        let cy = sinP * cxp + cosP * cyp + (p0.y + p1.y) / 2

        func angle(_ ux: CGFloat, _ uy: CGFloat, _ vx: CGFloat, _ vy: CGFloat) -> CGFloat {
            let dot = ux * vx + uy * vy
            let len = sqrt((ux * ux + uy * uy) * (vx * vx + vy * vy))
            var a = acos(max(-1, min(1, len == 0 ? 1 : dot / len)))
            if ux * vy - uy * vx < 0 { a = -a }
            return a
        }
        let theta1 = angle(1, 0, (x1 - cxp) / rx, (y1 - cyp) / ry)
        var dTheta = angle((x1 - cxp) / rx, (y1 - cyp) / ry, (-x1 - cxp) / rx, (-y1 - cyp) / ry)
        if !sweep && dTheta > 0 { dTheta -= 2 * .pi }
        if sweep && dTheta < 0 { dTheta += 2 * .pi }

        let steps = max(2, Int(abs(dTheta) / (.pi / 16)))
        for i in 1...steps {
            let t = theta1 + dTheta * CGFloat(i) / CGFloat(steps)
            let ex = cx + rx * cos(t) * cosP - ry * sin(t) * sinP
            let ey = cy + rx * cos(t) * sinP + ry * sin(t) * cosP
            path.addLine(to: map(CGPoint(x: ex, y: ey)))
        }
    }
}

// Tiny stateful scanner over a path `d` string.
private struct PathScanner {
    private let chars: [Character]
    private var i = 0
    init(_ s: String) { chars = Array(s) }

    private mutating func skipSep() {
        while i < chars.count, chars[i] == " " || chars[i] == "," || chars[i] == "\n" || chars[i] == "\t" {
            i += 1
        }
    }

    var peekIsNumber: Bool {
        var j = i
        while j < chars.count, chars[j] == " " || chars[j] == "," || chars[j] == "\n" || chars[j] == "\t" { j += 1 }
        guard j < chars.count else { return false }
        let c = chars[j]
        return c.isNumber || c == "-" || c == "+" || c == "."
    }

    mutating func nextCommandOrNil(after prev: Character) -> Character? {
        skipSep()
        guard i < chars.count else { return nil }
        let c = chars[i]
        if c.isLetter { i += 1; return c }
        // Implicit repeat of previous command with new coordinates.
        return prev == " " ? nil : prev
    }

    mutating func number() -> CGFloat {
        skipSep()
        var s = ""
        var seenDot = false, seenE = false
        while i < chars.count {
            let c = chars[i]
            if c.isNumber { s.append(c); i += 1 }
            else if c == "-" || c == "+" {
                if s.isEmpty || s.last == "e" || s.last == "E" { s.append(c); i += 1 } else { break }
            } else if c == "." {
                if seenDot { break }; seenDot = true; s.append(c); i += 1
            } else if c == "e" || c == "E" {
                if seenE { break }; seenE = true; s.append(c); i += 1
            } else { break }
        }
        return CGFloat(Double(s) ?? 0)
    }

    // SVG arc flags are single 0/1 digits, possibly not separated.
    mutating func flag() -> Bool {
        skipSep()
        guard i < chars.count else { return false }
        let c = chars[i]; i += 1
        return c == "1"
    }

    mutating func point(rel: Bool, cur: CGPoint) -> CGPoint {
        let x = number(), y = number()
        return rel ? CGPoint(x: cur.x + x, y: cur.y + y) : CGPoint(x: x, y: y)
    }
}
