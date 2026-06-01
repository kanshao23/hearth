import SwiftUI

struct ConversationPane: View {
    @ObservedObject var st: MainWindowState
    @Environment(\.tk) private var tk

    private var root: Session { st.activeRoot }
    private var child: ChildSession? { st.activeChild }
    private var ws: Workspace { st.activeWs }
    private var rootUnread: Bool { st.unread.contains(root.id) }

    private var bannerState: BannerState {
        if st.hasCheckIn { return .question }
        if child?.id == "auth.patch" { return .approval }
        if child?.id == "i.extract" { return .paused }
        switch root.status {
        case .done: return .done
        case .failed: return .failed
        case .active: return .working
        default: return .idle
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ActionBanner(state: bannerState, st: st)
                    Messages(st: st).padding(.top, 24)
                }
                .padding(.bottom, 24)
            }
            Composer(working: root.status == .active)
        }
        .frame(maxWidth: .infinity)
        .background(tk.bg)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 10) {
                Button { st.toggleUnread(root.id) } label: {
                    HIcon(rootUnread ? Ico.starFilled : Ico.star, size: 14)
                        .foregroundStyle(rootUnread ? tk.amber : tk.fg4)
                }.buttonStyle(.plain)
                WorkspaceGlyph(workspace: ws, size: 16)
                Text(ws.label).font(F.sans(13)).foregroundStyle(tk.fg3)
                HIcon(Ico.chevron, size: 10).foregroundStyle(tk.fg4)
                Text(root.title).font(F.sans(13, child == nil ? .semibold : .regular))
                    .foregroundStyle(child == nil ? tk.fg : tk.fg3)
                if let child {
                    HIcon(Ico.chevron, size: 10).foregroundStyle(tk.fg4)
                    Text(child.title).font(F.sans(13, .semibold)).foregroundStyle(tk.fg).lineLimit(1)
                }
                Spacer()
                HButton(kind: .ghost, hPad: 8, vPad: 4) { HIcon(Ico.dots, size: 12) }
            }
            if let wt = root.worktree {
                HStack(spacing: 6) {
                    HIcon(Ico.branch, size: 10).foregroundStyle(tk.fg3)
                    Text(wt).font(F.mono(11.5)).foregroundStyle(tk.fg3)
                    Text("·").foregroundStyle(tk.fg4)
                    Text(root.wtPath ?? "").font(F.mono(11.5)).foregroundStyle(tk.fg3)
                    HIcon(Ico.copy, size: 10).foregroundStyle(tk.fg4)
                }
                .padding(.leading, 24)
            }
        }
        .padding(.horizontal, 20).padding(.top, 10).padding(.bottom, 12)
        .overlay(alignment: .bottom) { tk.line.frame(height: 1) }
    }
}

struct Composer: View {
    let working: Bool
    @Environment(\.tk) private var tk

    var body: some View {
        HStack(spacing: 10) {
            Group {
                if working {
                    Text("Drop a course-correction or hint — it queues for the next step…")
                } else {
                    Text("Reply, drop files, or ") + Text("/skill morning").foregroundColor(tk.fg2) + Text("…")
                }
            }
            .font(F.sans(13.5)).foregroundStyle(tk.fg3)
            Spacer()
            if working {
                Chip(.amber, hPad: 6) { HStack(spacing: 4) { HIcon(Ico.bolt, size: 10); Text("queues, doesn't interrupt") } }
            }
            HStack(spacing: 2) { Kbd("⌘"); Kbd("↵") }.foregroundStyle(tk.fg4)
            HButton(kind: .primary, hPad: 12, vPad: 5) {
                HStack(spacing: 4) {
                    HIcon(working ? Ico.bolt : Ico.send, size: 11)
                    Text(working ? "Queue" : "Send")
                }
            }
        }
        .padding(.horizontal, 12).padding(.vertical, 10)
        .background(tk.surface)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(working ? tk.amberLine : tk.line2, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 16)
    }
}
