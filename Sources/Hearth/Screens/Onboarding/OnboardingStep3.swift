import SwiftUI

struct OnboardingStep3: View {
    @Environment(\.tk) private var tk
    @State private var picked = "git:commit"

    private let skills: [(id: String, t: String, d: String, icon: IconSpec)] = [
        ("git:commit", "Stage & commit", "Summarize changes, write conventional commit", Ico.branch),
        ("review:diff", "Walk a diff", "Talk you through a pending change", Ico.file),
        ("morning", "Morning digest", "Daily 8am Gmail → Notes", Ico.mail),
        ("swift:lint", "Swift lint", "Auto-fix on save", Ico.wand),
    ]

    private let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]

    var body: some View {
        OnboardingFrame(step: 3) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Install a starter skill").font(F.sans(22, .semibold)).foregroundStyle(tk.fg)
                (Text("Skills are plain markdown in ").foregroundColor(tk.fg2)
                 + Text("~/.hearth/skills").font(F.mono(13.5)).foregroundColor(tk.fg2)
                 + Text(". Pick one to get going — you can edit it any time.").foregroundColor(tk.fg2))
                    .font(F.sans(13.5)).frame(maxWidth: 460, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true).padding(.top, 8)

                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(skills, id: \.id) { skillCard($0) }
                }
                .padding(.top, 22)

                HStack(spacing: 8) {
                    HIcon(Ico.check, size: 10).foregroundStyle(tk.onAmber)
                        .frame(width: 14, height: 14).background(tk.amber)
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                    (Text("Bind ").foregroundColor(tk.fg2)) .font(F.sans(12))
                    Kbd("⌘⇧M")
                    Text("to open the command palette").font(F.sans(12)).foregroundStyle(tk.fg2)
                }
                .padding(.top, 16)
                Spacer()
                OnboardingFooter(step: 3, nextLabel: "Open Hearth", final: true)
            }
        }
    }

    private func skillCard(_ s: (id: String, t: String, d: String, icon: IconSpec)) -> some View {
        let sel = picked == s.id
        return VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                HIcon(s.icon, size: 14).foregroundStyle(sel ? tk.amberText : tk.fg3)
                Text(s.id).font(F.mono(12)).foregroundStyle(sel ? tk.amberText : tk.fg)
                Spacer()
                if sel { HIcon(Ico.check, size: 11).foregroundStyle(tk.amberText) }
            }
            Text(s.t).font(F.sans(13, .medium)).foregroundStyle(tk.fg)
            Text(s.d).font(F.sans(11.5)).foregroundStyle(tk.fg3).fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(sel ? tk.amberBg : tk.surface)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(sel ? tk.amberLine : tk.line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .contentShape(Rectangle())
        .onTapGesture { picked = s.id }
    }
}
