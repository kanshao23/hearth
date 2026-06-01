import SwiftUI

struct SkillLibrary: View {
    @Environment(\.tk) private var tk

    private let groups: [(name: String, items: [(id: String, desc: String, meta: String, sel: Bool)])] = [
        ("~/.hearth/skills", [
            ("morning", "Daily 8am inbox digest", "cron", true),
            ("pdf:invoice", "Extract invoice totals → csv", "⌃I", false),
            ("review:diff", "Walk through unstaged diff", "⌃D", false),
            ("swift:lint", "SwiftLint + auto-fix", "⌃L", false),
        ]),
        ("orchid/.hearth/skills", [
            ("git:commit", "Stage, summarize, commit", "⌃G", false),
            ("git:release", "Bump tag, write changelog", "manual", false),
            ("tests:flaky", "Find flaky XCTests", "manual", false),
        ]),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                HIcon(Ico.search, size: 12).foregroundStyle(tk.fg3)
                Text("Search skills…").font(F.sans(12)).foregroundStyle(tk.fg4).padding(.leading, 8)
                Spacer()
            }
            .padding(.horizontal, 10).padding(.vertical, 7)
            .background(tk.bg2)
            .overlay(RoundedRectangle(cornerRadius: Radius.r2).stroke(tk.line2, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: Radius.r2))
            .padding(10)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(groups.indices, id: \.self) { gi in
                        Text(groups[gi].name).font(F.mono(10.5)).foregroundStyle(tk.fg4)
                            .padding(.horizontal, 8).padding(.top, 8).padding(.bottom, 6)
                        ForEach(groups[gi].items.indices, id: \.self) { row(groups[gi].items[$0]) }
                    }
                }
                .padding(.horizontal, 6).padding(.bottom, 8)
            }

            HButton(hPad: 8, vPad: 5) { HStack(spacing: 4) { HIcon(Ico.plus, size: 11); Text("New skill") } }
                .frame(maxWidth: .infinity)
                .padding(8)
                .overlay(alignment: .top) { tk.line.frame(height: 1) }
        }
        .frame(width: 240)
        .background(tk.surface)
        .overlay(alignment: .trailing) { tk.line.frame(width: 1) }
    }

    private func row(_ it: (id: String, desc: String, meta: String, sel: Bool)) -> some View {
        HStack(spacing: 8) {
            HIcon(Ico.bolt, size: 11).foregroundStyle(it.sel ? tk.amberText : tk.fg3)
            VStack(alignment: .leading, spacing: 0) {
                Text(it.id).font(F.mono(12)).foregroundStyle(it.sel ? tk.amberText : tk.fg)
                Text(it.desc).font(F.sans(10.5)).foregroundStyle(tk.fg3).lineLimit(1)
            }
            Spacer()
            Text(it.meta).font(F.mono(10)).foregroundStyle(tk.fg3)
        }
        .padding(.horizontal, 8).padding(.vertical, 6)
        .background(it.sel ? tk.amberBg : .clear)
        .overlay(RoundedRectangle(cornerRadius: 5).stroke(it.sel ? tk.amberLine : .clear, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}
