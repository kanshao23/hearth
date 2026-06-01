import SwiftUI

struct SessionTreePane: View {
    @ObservedObject var st: MainWindowState
    @Environment(\.tk) private var tk

    private var wsStats: [String: (total: Int, active: Int, paused: Int)] {
        var m: [String: (Int, Int, Int)] = [:]
        for w in Mock.workspaces { m[w.id] = (0, 0, 0) }
        for s in Mock.sessions {
            guard var k = m[s.workspace] else { continue }
            k.0 += 1
            if s.status == .active { k.1 += 1 }
            if s.status == .paused { k.2 += 1 }
            m[s.workspace] = k
        }
        return m.mapValues { (total: $0.0, active: $0.1, paused: $0.2) }
    }
    private var totalActive: Int { wsStats.values.reduce(0) { $0 + $1.active } }

    var body: some View {
        VStack(spacing: 0) {
            scopeSwitcher
            newTask
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Mock.workspaces) { workspaceSection($0) }
                    recent
                }
                .padding(.horizontal, 4).padding(.bottom, 8)
            }
            footer
        }
        .frame(width: 256)
        .background(tk.surface)
        .overlay(alignment: .trailing) { tk.line.frame(width: 1) }
        .overlay(alignment: .top) { if st.switcherOpen { switcherDropdown.padding(.top, 56).padding(.horizontal, 8) } }
    }

    private var scopeSwitcher: some View {
        Button { st.switcherOpen.toggle() } label: {
            HStack(spacing: 8) {
                HIcon(Ico.globe, size: 13).foregroundStyle(tk.fg3)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Scope").font(F.sans(12)).foregroundStyle(tk.fg3)
                    Text("All workspaces · \(Mock.workspaces.count)").font(F.sans(12.5, .medium)).foregroundStyle(tk.fg)
                }
                Spacer()
                Chip(.amber, hPad: 5) { HStack(spacing: 4) { Spinner(size: 8, lineWidth: 1.25); Text("\(totalActive) live") } }
                HIcon(Ico.chevronDown, size: 11).foregroundStyle(tk.fg3)
                    .rotationEffect(.degrees(st.switcherOpen ? 180 : 0))
            }
            .padding(.horizontal, 8).padding(.vertical, 6)
            .background(st.switcherOpen ? tk.surface2 : .clear)
            .overlay(RoundedRectangle(cornerRadius: Radius.r2).stroke(st.switcherOpen ? tk.lineStrong : tk.line2, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: Radius.r2))
        }
        .buttonStyle(.plain)
        .padding(10)
        .overlay(alignment: .bottom) { tk.line.frame(height: 1) }
    }

    private var switcherDropdown: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text("FILTER SCOPE").font(F.sans(10.5, .semibold)).tracking(0.5).foregroundStyle(tk.fg3)
                Spacer()
                Kbd("⌘1–4", fontSize: 10)
            }
            .padding(.horizontal, 10).padding(.top, 8).padding(.bottom, 4)

            HStack(spacing: 8) {
                HIcon(Ico.globe, size: 12).foregroundStyle(tk.amberText)
                Text("All workspaces").font(F.sans(12.5, .medium)).foregroundStyle(tk.amberText)
                Spacer()
                HIcon(Ico.check, size: 11).foregroundStyle(tk.amberText)
            }
            .padding(.horizontal, 8).padding(.vertical, 6)
            .background(tk.amberBg)
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(tk.amberLine, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 5))

            ForEach(Mock.workspaces) { w in
                HStack(spacing: 8) {
                    WorkspaceGlyph(workspace: w, size: 16)
                    VStack(alignment: .leading, spacing: 0) {
                        Text(w.label).font(F.sans(12.5)).foregroundStyle(tk.fg).lineLimit(1)
                        Text(w.sub).font(F.mono(10.5)).foregroundStyle(tk.fg3).lineLimit(1)
                    }
                    Spacer()
                    let stat = wsStats[w.id] ?? (0, 0, 0)
                    (Text(stat.active > 0 ? "\(stat.active)↻ " : "").foregroundColor(tk.amberText)
                     + Text("\(stat.total)").foregroundColor(tk.fg3)).font(F.mono(10.5))
                }
                .padding(.horizontal, 8).padding(.vertical, 6)
            }

            tk.line.frame(height: 1).padding(.vertical, 2)
            HStack(spacing: 8) {
                HIcon(Ico.plus, size: 11)
                Text("Add workspace…").font(F.sans(12))
                Spacer()
                Kbd("⌘N", fontSize: 10)
            }
            .foregroundStyle(tk.fg2)
            .padding(.horizontal, 8).padding(.vertical, 6)
        }
        .padding(4)
        .background(tk.surface2)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(tk.lineStrong, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: tk.shadowStrong, radius: 30, y: 24)
    }

    private var newTask: some View {
        HStack(spacing: 8) {
            HIcon(Ico.plus, size: 12)
            Text("New task…").frame(maxWidth: .infinity, alignment: .leading)
            Kbd("⌘N", fontSize: 10)
        }
        .font(F.sans(12.5)).foregroundStyle(tk.fg2)
        .padding(.horizontal, 10).padding(.vertical, 8)
        .background(tk.bg2)
        .overlay(RoundedRectangle(cornerRadius: Radius.r2).strokeBorder(tk.lineStrong, style: StrokeStyle(lineWidth: 1, dash: [3, 3])))
        .clipShape(RoundedRectangle(cornerRadius: Radius.r2))
        .padding(8)
    }

    private func workspaceSection(_ w: Workspace) -> some View {
        let sessions = Mock.sessions.filter { $0.workspace == w.id }
        let wsKey = "ws:" + w.id
        let wsExpanded = st.expanded[wsKey] != false
        let stat = wsStats[w.id] ?? (0, 0, 0)
        return Group {
            if !sessions.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    Button { st.expanded[wsKey] = !wsExpanded } label: {
                        HStack(spacing: 6) {
                            HIcon(Ico.chevron, size: 9).foregroundStyle(tk.fg3)
                                .rotationEffect(.degrees(wsExpanded ? 90 : 0)).frame(width: 12)
                            WorkspaceGlyph(workspace: w, size: 14)
                            Text(w.label).font(F.sans(11.5, .semibold)).foregroundStyle(tk.fg).lineLimit(1)
                            Spacer()
                            HStack(spacing: 6) {
                                if stat.active > 0 { Spinner(size: 9, lineWidth: 1.25) }
                                if stat.paused > 0 { Dot(kind: .paused, size: 5) }
                                Text("\(sessions.count)").font(F.mono(10.5)).foregroundStyle(tk.fg4)
                            }
                        }
                        .padding(.horizontal, 8).padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                    if wsExpanded {
                        VStack(spacing: 0) {
                            ForEach(sessions) { SessionNode(node: $0, st: st) }
                        }
                        .padding(.leading, 8)
                    }
                }
            }
        }
    }

    private var recent: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("RECENT").font(F.sans(10.5, .semibold)).tracking(0.5).foregroundStyle(tk.fg3)
                .padding(.horizontal, 8).padding(.top, 12).padding(.bottom, 4)
            ForEach([("Generate release notes", "1d ago · orchid"), ("Vendor lockfile bump", "3d ago · marble")], id: \.0) { r in
                HStack(spacing: 8) {
                    Dot(kind: .ok)
                    Text(r.0).font(F.sans(12)).foregroundStyle(tk.fg2).lineLimit(1).frame(maxWidth: .infinity, alignment: .leading)
                    Text(r.1).font(F.sans(10.5)).foregroundStyle(tk.fg3)
                }
                .padding(.horizontal, 8).padding(.vertical, 5)
            }
        }
    }

    private var footer: some View {
        HStack(spacing: 8) {
            Dot(kind: .ok)
            Text("daemon · 0.4.2 · 38 MB").frame(maxWidth: .infinity, alignment: .leading)
            Text(":65432").font(F.mono(11))
        }
        .font(F.sans(11)).foregroundStyle(tk.fg3)
        .padding(.horizontal, 12).padding(.vertical, 8)
        .overlay(alignment: .top) { tk.line.frame(height: 1) }
    }
}
