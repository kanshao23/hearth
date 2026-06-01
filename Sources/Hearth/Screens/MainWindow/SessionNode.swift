import SwiftUI

struct SessionNode: View {
    let node: Session
    @ObservedObject var st: MainWindowState
    @Environment(\.tk) private var tk
    @State private var hovering = false

    private var isSelected: Bool { st.selected == node.id }
    private var childSelected: Bool { node.children.contains { $0.id == st.selected } }
    private var isUnread: Bool { st.unread.contains(node.id) }
    private var expanded: Bool { st.expanded[node.id] == true }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            row
            if expanded, !node.children.isEmpty {
                VStack(spacing: 0) { ForEach(node.children) { childRow($0) } }
                    .padding(.leading, 4)
                    .overlay(alignment: .leading) { tk.line.frame(width: 1) }
                    .padding(.leading, 14)
            }
        }
    }

    private var row: some View {
        HStack(spacing: 6) {
            Button { st.expanded[node.id] = !expanded } label: {
                HIcon(Ico.chevron, size: 10).foregroundStyle(tk.fg3)
                    .rotationEffect(.degrees(expanded ? 90 : 0))
                    .frame(width: 14, height: 14)
            }
            .buttonStyle(.plain)
            statusDot(node.status, size: 12).frame(width: 14)
            VStack(alignment: .leading, spacing: 1) {
                Text(node.title).font(F.sans(12.5, isUnread ? .semibold : .medium))
                    .foregroundStyle(isSelected ? tk.amberText : tk.fg).lineLimit(1)
                subline
            }
            Spacer()
            if hovering || isUnread {
                Button { st.toggleUnread(node.id) } label: {
                    HIcon(isUnread ? Ico.starFilled : Ico.star, size: 11)
                        .foregroundStyle(isUnread ? tk.amber : tk.fg3)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.leading, 8).padding(.trailing, 6).padding(.vertical, 6)
        .background(isSelected ? tk.amberBg : childSelected ? tk.hoverSoft : (hovering ? tk.hover : .clear))
        .overlay(RoundedRectangle(cornerRadius: 5).stroke(isSelected ? tk.amberLine : .clear, lineWidth: 1))
        .overlay(alignment: .leading) {
            if isUnread { tk.amber.frame(width: 2).cornerRadius(1).padding(.vertical, 8) }
        }
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .contentShape(Rectangle())
        .onTapGesture { st.selected = node.id }
        .onHover { hovering = $0 }
    }

    @ViewBuilder private var subline: some View {
        HStack(spacing: 4) {
            if let wt = node.worktree {
                HIcon(Ico.branch, size: 9).foregroundStyle(tk.fg3)
                Text(wt).font(F.mono(10.5)).foregroundStyle(tk.fg3)
                Text("·").foregroundStyle(tk.fg4)
            }
            Text(node.meta).font(F.sans(10.5)).foregroundStyle(tk.fg3).lineLimit(1)
        }
    }

    private func childRow(_ c: ChildSession) -> some View {
        let sel = st.selected == c.id
        return HStack(spacing: 6) {
            statusDot(c.status, size: 10).frame(width: 12)
            Text(c.title).font(F.sans(12)).foregroundStyle(sel ? tk.amberText : tk.fg2).lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(c.meta).font(F.mono(10)).foregroundStyle(tk.fg3)
        }
        .padding(.horizontal, 6).padding(.vertical, 5)
        .background(sel ? tk.amberBg : .clear)
        .overlay(RoundedRectangle(cornerRadius: 4).stroke(sel ? tk.amberLine : .clear, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .padding(.vertical, 1)
        .contentShape(Rectangle())
        .onTapGesture { st.selected = c.id }
    }

    @ViewBuilder
    private func statusDot(_ status: SessionStatus, size: CGFloat) -> some View {
        switch status {
        case .active: Spinner(size: size, lineWidth: size > 11 ? 1.5 : 1.25)
        case .paused: Dot(kind: .paused, size: 5)
        case .failed: Dot(kind: .fail, size: 5)
        case .pending: Dot(kind: .idle, size: 5)
        case .done: Dot(kind: .ok, size: 5)
        }
    }
}
