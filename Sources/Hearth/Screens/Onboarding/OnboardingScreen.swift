import SwiftUI

// Screen 8 — first-run wizard (720×520). Frame + sidebar step indicator + footer.
struct OnboardingFrame<Content: View>: View {
    let step: Int
    @ViewBuilder var content: () -> Content
    @Environment(\.tk) private var tk

    private let steps: [(n: Int, t: String, d: String)] = [
        (1, "Connect a provider", "Anthropic, OpenAI, or Ollama"),
        (2, "Grant permissions", "Accessibility, Mail, Files"),
        (3, "Pick a first skill", "Or write your own later"),
    ]

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            VStack(alignment: .leading, spacing: 0) { content() }
                .padding(.top, 52).padding(.horizontal, 36)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(width: 720, height: 520)
        .background(tk.bg)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(tk.line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: tk.shadowStrong, radius: 30, y: 24)
        .overlay(alignment: .topLeading) { TrafficLights().padding(2) }
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                LogoMark(size: 20).foregroundStyle(tk.amber)
                Text("Hearth").font(F.sans(15, .semibold))
            }
            Text("v0.4.2 · local-first").font(F.sans(11)).foregroundStyle(tk.fg3).padding(.top, -8)

            VStack(alignment: .leading, spacing: 4) {
                ForEach(steps, id: \.n) { stepRow($0) }
            }
            .padding(.top, 16)

            Spacer()
            HStack(alignment: .top, spacing: 6) {
                HIcon(Ico.shield, size: 11).foregroundStyle(tk.amberText)
                Text("Everything stays on this Mac. No account, no sync, no telemetry.")
                    .font(F.sans(11)).foregroundStyle(tk.fg3).fixedSize(horizontal: false, vertical: true)
            }
            .padding(10)
            .background(tk.bg2)
            .overlay(RoundedRectangle(cornerRadius: Radius.r2).stroke(tk.line, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: Radius.r2))
        }
        .padding(.init(top: 54, leading: 18, bottom: 18, trailing: 18))
        .frame(width: 220)
        .background(tk.surface)
        .overlay(alignment: .trailing) { tk.line.frame(width: 1) }
    }

    private func stepRow(_ s: (n: Int, t: String, d: String)) -> some View {
        let state = s.n < step ? "done" : s.n == step ? "now" : "todo"
        return HStack(alignment: .top, spacing: 10) {
            Group {
                if state == "done" {
                    HIcon(Ico.check, size: 10).foregroundStyle(tk.onAmber)
                } else {
                    Text("\(s.n)").font(F.mono(11, .semibold))
                        .foregroundStyle(state == "now" ? tk.amberText : tk.fg3)
                }
            }
            .frame(width: 20, height: 20)
            .background(state == "done" ? tk.amber : tk.surface3)
            .overlay(Circle().stroke(state == "now" ? tk.amberLine : tk.line2, lineWidth: 1))
            .clipShape(Circle())
            VStack(alignment: .leading, spacing: 1) {
                Text(s.t).font(F.sans(12.5, .medium))
                    .foregroundStyle(state == "now" ? tk.amberText : state == "done" ? tk.fg : tk.fg2)
                Text(s.d).font(F.sans(11)).foregroundStyle(tk.fg3)
            }
        }
        .padding(8)
        .background(state == "now" ? tk.amberBg : .clear)
        .overlay(RoundedRectangle(cornerRadius: Radius.r2).stroke(state == "now" ? tk.amberLine : .clear, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: Radius.r2))
    }
}

struct OnboardingFooter: View {
    let step: Int
    let nextLabel: String
    var final = false
    @Environment(\.tk) private var tk

    var body: some View {
        HStack(spacing: 10) {
            HStack(spacing: 4) {
                ForEach(1...3, id: \.self) { n in
                    Capsule().fill(n <= step ? tk.amber : tk.surface3)
                        .frame(width: n == step ? 18 : 6, height: 6)
                }
                Text("Step \(step) of 3").font(F.sans(11.5)).foregroundStyle(tk.fg3).padding(.leading, 10)
            }
            Spacer()
            if step > 1 { HButton(kind: .ghost) { Text("Back") } }
            if !final { HButton(kind: .ghost) { Text("Skip") } }
            HButton(kind: .primary, hPad: 14) {
                HStack(spacing: 2) {
                    Text(nextLabel)
                    if !final { HIcon(Ico.chevron, size: 11) }
                }
            }
        }
        .padding(.top, 14).padding(.bottom, 18)
        .overlay(alignment: .top) { tk.line.frame(height: 1).padding(.top, -2) }
    }
}
