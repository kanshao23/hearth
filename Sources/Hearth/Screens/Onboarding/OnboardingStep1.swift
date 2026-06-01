import SwiftUI

struct OnboardingStep1: View {
    @Environment(\.tk) private var tk
    @State private var provider = "anthropic"

    private let providers: [(id: String, t: String, d: String, tag: String)] = [
        ("anthropic", "Anthropic", "Claude opus / sonnet / haiku", "recommended"),
        ("openai", "OpenAI · compatible", "OpenAI, Groq, OpenRouter, Azure", "optional"),
        ("local", "Local · Ollama / LM Studio", "Ollama running on localhost:11434", "detected"),
    ]

    var body: some View {
        OnboardingFrame(step: 1) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Connect a provider").font(F.sans(22, .semibold)).foregroundStyle(tk.fg)
                (Text("API keys are stored in ").foregroundColor(tk.fg2)
                 + Text("Keychain").font(F.mono(13.5)).foregroundColor(tk.fg2)
                 + Text(". You can add more later, or route each session to a different model.").foregroundColor(tk.fg2))
                    .font(F.sans(13.5)).frame(maxWidth: 440, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true).padding(.top, 8)

                VStack(spacing: 8) { ForEach(providers, id: \.id) { providerRow($0) } }
                    .padding(.top, 22)

                if provider == "anthropic" { apiKey.padding(.top, 18) }
                Spacer()
                OnboardingFooter(step: 1, nextLabel: "Continue")
            }
        }
    }

    private func providerRow(_ p: (id: String, t: String, d: String, tag: String)) -> some View {
        let sel = provider == p.id
        return HStack(spacing: 12) {
            ZStack {
                Circle().fill(sel ? tk.amber : .clear)
                Circle().stroke(sel ? tk.amber : tk.lineStrong, lineWidth: 1.5)
                if sel { Circle().fill(tk.onAmber).frame(width: 6, height: 6) }
            }
            .frame(width: 16, height: 16)
            VStack(alignment: .leading, spacing: 1) {
                Text(p.t).font(F.sans(13.5, .medium)).foregroundStyle(sel ? tk.amberText : tk.fg)
                Text(p.d).font(F.sans(11.5)).foregroundStyle(tk.fg3)
            }
            Spacer()
            chip(p.tag)
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .background(sel ? tk.amberBg : tk.surface)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(sel ? tk.amberLine : tk.line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .contentShape(Rectangle())
        .onTapGesture { provider = p.id }
    }

    @ViewBuilder private func chip(_ tag: String) -> some View {
        switch tag {
        case "recommended": Chip(.amber) { Text(tag) }
        case "detected": Chip(.ok) { Text(tag) }
        default: Chip(.plain) { Text(tag) }
        }
    }

    private var apiKey: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("API KEY").font(F.sans(11, .semibold)).tracking(0.5).foregroundStyle(tk.fg3)
            HStack(spacing: 0) {
                HIcon(Ico.lock, size: 12).foregroundStyle(tk.fg3)
                Text("sk-ant-api03-•••••••••••••••••••••••••••••YnJX")
                    .font(F.mono(12)).foregroundStyle(tk.fg).padding(.leading, 8)
                Spacer()
                HButton(kind: .ghost, hPad: 8, vPad: 3, fontSize: 11) {
                    HStack(spacing: 4) { HIcon(Ico.check, size: 10).foregroundStyle(tk.ok); Text("Valid · 3 models") }
                }
            }
            .padding(.horizontal, 10).padding(.vertical, 7)
            .background(tk.bg2)
            .overlay(RoundedRectangle(cornerRadius: Radius.r2).stroke(tk.line2, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: Radius.r2))
            Text("Saved to Keychain. Hearth never reads this from disk.")
                .font(F.sans(11)).foregroundStyle(tk.fg3)
        }
    }
}
