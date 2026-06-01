import SwiftUI

// Screen 1 — Menubar popover (280×470), dropping from a faux macOS menubar strip.
struct MenubarScreen: View {
    @Environment(\.tk) private var tk
    @State private var hover: Int? = nil

    private struct ActiveRow {
        let t, s, state, pct: String
        var badge: Int? = nil
        let ws: Workspace
    }
    private let actives: [ActiveRow] = [
        ActiveRow(t: "Refactor auth → JWT", s: "agent · editing AuthService.swift", state: "active", pct: "42%",
                  ws: Workspace(id: "o", kind: .repo, label: "", sub: "", glyph: "o", tone: .amber)),
        ActiveRow(t: "Port `mb serve` to async-std", s: "drafting migration RFC", state: "active", pct: "18%",
                  ws: Workspace(id: "m", kind: .repo, label: "", sub: "", glyph: "m", tone: .blue)),
        ActiveRow(t: "Morning routine", s: "reading Gmail · 3 unread", state: "active", pct: "—",
                  ws: Workspace(id: "g", kind: .global, label: "", sub: "")),
        ActiveRow(t: "PDF invoice scan", s: "paused · awaiting approval", state: "paused", pct: "—", badge: 1,
                  ws: Workspace(id: "d", kind: .folder, label: "", sub: "")),
    ]
    private let skills: [(i: String, d: String, k: String)] = [
        ("git:commit", "Stage, summarize, commit", "⌃G"),
        ("morning", "Daily 8:00 routine", "cron"),
        ("review:diff", "Walk through unstaged diff", "⌃D"),
        ("pdf:invoice", "Extract invoice totals → csv", "⌃I"),
        ("swift:lint", "SwiftLint + auto-fix", "⌃L"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            strip
            popover.padding(.top, 8)
        }
        .frame(width: 280, height: 470)
        .overlay(alignment: .topTrailing) { arrow.padding(.top, 22).padding(.trailing, 30) }
    }

    private var strip: some View {
        HStack(spacing: 14) {
            Spacer()
            Text("Wed 14:32").foregroundStyle(tk.fg3)
            Text("100%").foregroundStyle(tk.fg3)
            Text("􀊨").foregroundStyle(tk.fg3)
            HStack(spacing: 5) {
                Spinner(size: 11, lineWidth: 1.5)
                Badge(text: "2", minWidth: 14, height: 14, fontSize: 9.5)
            }
            .padding(.horizontal, 6).padding(.vertical, 2)
            .background(tk.fg.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .font(F.sans(11))
        .padding(.horizontal, 8)
        .frame(height: 22)
        .background(tk.osStrip)
        .overlay(alignment: .bottom) { tk.osStripLine.frame(height: 1) }
        .clipShape(.rect(topLeadingRadius: 6, topTrailingRadius: 6))
    }

    private var arrow: some View {
        Rectangle()
            .fill(tk.surface)
            .frame(width: 10, height: 10)
            .overlay(Rectangle().stroke(tk.line, lineWidth: 1))
            .rotationEffect(.degrees(45))
            .frame(width: 12, height: 6, alignment: .top)
            .clipped()
    }

    private var popover: some View {
        VStack(spacing: 0) {
            taskInput
            sectionHeader("Active", trailing: "3 running · 1 paused")
            VStack(spacing: 0) { ForEach(actives.indices, id: \.self) { activeRow($0) } }
                .padding(.horizontal, 6)
            sectionHeader("Skills", trailing: "browse all").padding(.top, 4)
            VStack(spacing: 0) { ForEach(skills.indices, id: \.self) { skillRow($0) } }
                .padding(.horizontal, 6)
            Spacer(minLength: 0)
            footer
        }
        .background(tk.surface)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(tk.line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: tk.shadowStrong, radius: 30, y: 24)
    }

    private var taskInput: some View {
        HStack(spacing: 0) {
            HIcon(Ico.plus, size: 12).foregroundStyle(tk.fg3)
            Text("New task… or ⌘⇧M for palette")
                .font(F.sans(12.5)).foregroundStyle(tk.fg4)
                .padding(.leading, 8)
            Spacer()
            HStack(spacing: 2) { Kbd("⌘", fontSize: 11); Kbd("↵", fontSize: 11) }
        }
        .padding(.horizontal, 10).padding(.vertical, 7)
        .background(tk.bg2)
        .overlay(RoundedRectangle(cornerRadius: Radius.r2).stroke(tk.line2, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: Radius.r2))
        .padding(10)
        .overlay(alignment: .bottom) { tk.line.frame(height: 1) }
    }

    private func sectionHeader(_ title: String, trailing: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title.uppercased()).font(F.sans(10.5, .semibold)).tracking(0.5).foregroundStyle(tk.fg3)
            Spacer()
            Text(trailing).font(F.sans(10.5)).foregroundStyle(tk.fg4)
        }
        .padding(.horizontal, 10).padding(.top, 8).padding(.bottom, 4)
    }

    private func activeRow(_ i: Int) -> some View {
        let row = actives[i]
        return HStack(spacing: 8) {
            Group {
                if row.state == "active" { Spinner(size: 12) }
                else if row.state == "paused" { Dot(kind: .paused) }
                else { Dot(kind: .ok) }
            }.frame(width: 14)
            WorkspaceGlyph(workspace: row.ws, size: 16)
            VStack(alignment: .leading, spacing: 1) {
                Text(row.t).font(F.sans(12.5, .medium)).foregroundStyle(tk.fg).lineLimit(1)
                Text(row.s).font(F.sans(11)).foregroundStyle(tk.fg3).lineLimit(1)
            }
            Spacer()
            if let b = row.badge { Badge(text: "\(b)") }
            else { Text(row.pct).font(F.mono(10)).foregroundStyle(tk.fg3) }
        }
        .padding(.horizontal, 8).padding(.vertical, 7)
        .background(hover == i ? tk.hover : .clear)
        .clipShape(RoundedRectangle(cornerRadius: Radius.r2))
        .onHover { hover = $0 ? i : (hover == i ? nil : hover) }
    }

    private func skillRow(_ i: Int) -> some View {
        let s = skills[i]
        return HStack(spacing: 8) {
            HIcon(Ico.bolt, size: 11).foregroundStyle(tk.fg3).frame(width: 14)
            HStack(spacing: 8) {
                Text(s.i).font(F.mono(11.5)).foregroundStyle(tk.fg)
                Text(s.d).font(F.sans(11)).foregroundStyle(tk.fg3).lineLimit(1)
            }
            Spacer()
            if s.k == "cron" { Chip(.plain, mono: true) { Text("cron") } }
            else { Kbd(s.k, fontSize: 10) }
        }
        .padding(.horizontal, 8).padding(.vertical, 6)
    }

    private var footer: some View {
        HStack {
            HStack(spacing: 6) { HIcon(Ico.cog, size: 12); Text("Settings") }
            Spacer()
            HStack(spacing: 6) { Kbd("⌘Q", fontSize: 10); Text("Quit") }
        }
        .font(F.sans(11.5)).foregroundStyle(tk.fg3)
        .padding(.horizontal, 10).padding(.vertical, 8)
        .overlay(alignment: .top) { tk.line.frame(height: 1) }
    }
}
