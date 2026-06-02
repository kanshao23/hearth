import SwiftUI

// ── Button (.btn / .primary / .danger / .ghost) ──
struct HButton<Label: View>: View {
    enum Kind { case normal, primary, danger, ghost }
    var kind: Kind = .normal
    var hPad: CGFloat = 12
    var vPad: CGFloat = 6
    var fontSize: CGFloat = 12
    var radius: CGFloat = Radius.r2
    var action: () -> Void = {}
    @ViewBuilder var label: () -> Label

    @Environment(\.tk) private var tk
    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) { label() }
                .font(F.sans(fontSize, .medium))
                .foregroundStyle(fg)
                .padding(.horizontal, hPad)
                .padding(.vertical, vPad)
                .background(bg)
                .overlay(RoundedRectangle(cornerRadius: radius).stroke(border, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: radius))
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
    }

    private var fg: Color {
        switch kind {
        case .primary: return tk.onAmber
        case .danger: return tk.danger
        case .ghost: return hovering ? tk.fg : tk.fg2
        case .normal: return tk.fg
        }
    }
    private var bg: Color {
        switch kind {
        case .primary: return hovering ? tk.amber2 : tk.amber
        case .danger: return hovering ? Color(oklch: 0.70, 0.17, 25, 0.12) : .clear
        case .ghost: return hovering ? tk.surface2 : .clear
        case .normal: return hovering ? tk.surface3 : tk.surface2
        }
    }
    private var border: Color {
        switch kind {
        case .primary: return .clear
        case .danger: return Color(oklch: 0.70, 0.17, 25, 0.35)
        case .ghost: return .clear
        case .normal: return hovering ? tk.lineStrong : tk.line2
        }
    }
}

// ── Chip ──
struct Chip: View {
    enum Kind { case plain, amber, warn, danger, ok }
    var kind: Kind = .plain
    var mono = false
    var hPad: CGFloat = 7
    @ViewBuilder var label: () -> AnyView
    @Environment(\.tk) private var tk

    init(_ kind: Kind = .plain, mono: Bool = false, hPad: CGFloat? = nil, @ViewBuilder label: @escaping () -> some View) {
        self.kind = kind
        self.mono = mono
        self.hPad = hPad ?? (mono ? 6 : 7)
        self.label = { AnyView(label()) }
    }

    var body: some View {
        HStack(spacing: 4) { label() }
            .font(mono ? F.mono(10.5, .medium) : F.sans(11, .medium))
            .foregroundStyle(fg)
            .padding(.horizontal, hPad)
            .padding(.vertical, mono ? 1 : 2)
            .background(bg)
            .overlay(RoundedRectangle(cornerRadius: Radius.r1).stroke(border, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: Radius.r1))
            .fixedSize()
    }

    private var fg: Color {
        switch kind {
        case .plain: return tk.fg2
        case .amber: return tk.amberText
        case .warn: return Sem.warnChipFg
        case .danger: return Sem.dangerChipFg
        case .ok: return Sem.okChipFg
        }
    }
    private var bg: Color {
        switch kind {
        case .plain: return tk.surface2
        case .amber: return tk.amberBg
        case .warn: return Sem.warnChipBg
        case .danger: return Sem.dangerChipBg
        case .ok: return Sem.okChipBg
        }
    }
    private var border: Color {
        switch kind {
        case .plain: return tk.line2
        case .amber: return tk.amberLine
        case .warn: return Sem.warnChipLine
        case .danger: return Sem.dangerChipLine
        case .ok: return Sem.okChipLine
        }
    }
}

// ── Keyboard key ──
struct Kbd: View {
    let text: String
    var fontSize: CGFloat = 11
    var fg: Color?
    var border: Color?
    @Environment(\.tk) private var tk

    init(_ text: String, fontSize: CGFloat = 11, fg: Color? = nil, border: Color? = nil) {
        self.text = text; self.fontSize = fontSize; self.fg = fg; self.border = border
    }

    var body: some View {
        Text(text)
            .font(F.mono(fontSize))
            .foregroundStyle(fg ?? tk.fg2)
            .frame(minWidth: 16)
            .padding(.horizontal, 5)
            .padding(.vertical, 1)
            .background(tk.surface3)
            .overlay(RoundedRectangle(cornerRadius: Radius.r1).stroke(border ?? tk.line2, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: Radius.r1))
    }
}

// ── Status dot ──
struct Dot: View {
    enum Kind { case active, idle, ok, fail, paused }
    let kind: Kind
    var size: CGFloat = 6
    @Environment(\.tk) private var tk

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .background(
                kind == .active
                    ? Circle().fill(Color(oklch: 0.76, 0.135, 65, 0.18)).frame(width: size + 6, height: size + 6)
                    : nil
            )
    }
    private var color: Color {
        switch kind {
        case .active: return tk.amber
        case .idle: return tk.fg4
        case .ok: return tk.ok
        case .fail: return tk.danger
        case .paused: return tk.warn
        }
    }
}

// ── Spinner (TimelineView-driven, ~60fps, off main work) ──
struct Spinner: View {
    var size: CGFloat = 12
    var lineWidth: CGFloat = 1.5
    @Environment(\.tk) private var tk
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if reduceMotion {
                ring(angle: 0)
            } else {
                TimelineView(.animation) { ctx in
                    let t = ctx.date.timeIntervalSinceReferenceDate
                    ring(angle: (t.truncatingRemainder(dividingBy: 0.9) / 0.9) * 360)
                }
            }
        }
        .frame(width: size, height: size)
        .accessibilityLabel("Working")
    }

    private func ring(angle: Double) -> some View {
        ZStack {
            Circle().stroke(tk.line2, lineWidth: lineWidth)
            Circle().trim(from: 0, to: 0.25)
                .stroke(tk.amber, style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt))
                .rotationEffect(.degrees(angle))
        }
        .frame(width: size, height: size)
    }
}

// ── Streaming caret ──
struct Caret: View {
    @Environment(\.tk) private var tk
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if reduceMotion {
                bar.opacity(1)
            } else {
                TimelineView(.periodic(from: .now, by: 0.5)) { ctx in
                    let on = Int(ctx.date.timeIntervalSinceReferenceDate * 2) % 2 == 0
                    bar.opacity(on ? 1 : 0)
                }
            }
        }
        .frame(width: 7, height: 14)
        .accessibilityHidden(true)
    }
    private var bar: some View {
        RoundedRectangle(cornerRadius: 1).fill(tk.amber).frame(width: 7, height: 14)
    }
}

// ── Numeric badge ──
struct Badge: View {
    let text: String
    var minWidth: CGFloat = 16
    var height: CGFloat = 16
    var fontSize: CGFloat = 10
    @Environment(\.tk) private var tk

    var body: some View {
        Text(text)
            .font(F.sans(fontSize, .semibold))
            .foregroundStyle(tk.onAmber)
            .frame(minWidth: minWidth, minHeight: height)
            .padding(.horizontal, 5)
            .background(tk.amber)
            .clipShape(Capsule())
    }
}
