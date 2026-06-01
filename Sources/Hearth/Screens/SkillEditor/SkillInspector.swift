import SwiftUI

struct SkillInspector: View {
    @Environment(\.tk) private var tk

    private let vars: [(k: String, v: String, auto: Bool)] = [
        ("$DATE", "2026-05-25", true), ("$N", "3", true), ("$INBOX", "jenlim@…", false),
    ]
    private let plan: [(icon: IconSpec, t: String, d: String)] = [
        (Ico.mail, "mail.fetchUnread", "limit 10 · skip promotions"),
        (Ico.sparkle, "claude.summarize", "≤ 2 sentences"),
        (Ico.disk, "fs.append", "~/Documents/Notes/$DATE.md"),
        (Ico.bell, "notification.show", "\"Inbox digest\", \"$N messages\""),
    ]

    var body: some View {
        VStack(spacing: 0) {
            label("Variables").padding(.horizontal, 12).padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .bottom) { tk.line.frame(height: 1) }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(vars.indices, id: \.self) { varRow(vars[$0]) }
            }
            .padding(.horizontal, 12).padding(.vertical, 8)

            label("Tool plan").padding(.horizontal, 12).padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .top) { tk.line.frame(height: 1) }
                .overlay(alignment: .bottom) { tk.line.frame(height: 1) }

            ScrollView {
                VStack(spacing: 0) { ForEach(plan.indices, id: \.self) { planRow(plan[$0]) } }
            }
            .frame(maxHeight: .infinity)

            VStack(spacing: 8) {
                HButton(kind: .primary, hPad: 10, vPad: 6) {
                    HStack(spacing: 4) { HIcon(Ico.play, size: 11); Text("Dry-run with these values") }
                }.frame(maxWidth: .infinity)
                Text("no side effects · tools mocked").font(F.sans(10.5)).foregroundStyle(tk.fg3)
            }
            .padding(10)
            .overlay(alignment: .top) { tk.line.frame(height: 1) }
        }
        .frame(width: 280)
        .background(tk.surface)
        .overlay(alignment: .leading) { tk.line.frame(width: 1) }
    }

    private func label(_ s: String) -> some View {
        Text(s.uppercased()).font(F.sans(10.5, .semibold)).tracking(0.5).foregroundStyle(tk.fg3)
    }

    private func varRow(_ v: (k: String, v: String, auto: Bool)) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text(v.k).font(F.mono(11.5)).foregroundStyle(tk.amberText)
                if v.auto { Chip(.plain, hPad: 5) { Text("auto") } }
            }
            Text(v.v).font(F.mono(11.5)).foregroundStyle(tk.fg)
                .padding(.horizontal, 8).padding(.vertical, 4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(tk.bg2)
                .overlay(RoundedRectangle(cornerRadius: Radius.r2).stroke(tk.line2, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: Radius.r2))
        }
    }

    private func planRow(_ s: (icon: IconSpec, t: String, d: String)) -> some View {
        HStack(spacing: 8) {
            HIcon(s.icon, size: 11).foregroundStyle(tk.amberText)
            VStack(alignment: .leading, spacing: 0) {
                Text(s.t).font(F.mono(11.5)).foregroundStyle(tk.fg)
                Text(s.d).font(F.sans(10.5)).foregroundStyle(tk.fg3)
            }
            Spacer()
            HIcon(Ico.check, size: 11).foregroundStyle(tk.ok)
        }
        .padding(.horizontal, 8).padding(.vertical, 6)
    }
}
