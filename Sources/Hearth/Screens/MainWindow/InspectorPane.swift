import SwiftUI

struct InspectorPane: View {
    @ObservedObject var st: MainWindowState
    @Environment(\.tk) private var tk

    private struct Tab { let id: InspectorTab; let label: String; let count: Int?; let icon: IconSpec; var alert = false }
    private let tabs: [Tab] = [
        Tab(id: .diff, label: "Files", count: 2, icon: Ico.file),
        Tab(id: .approval, label: "Approvals", count: 1, icon: Ico.shield, alert: true),
        Tab(id: .events, label: "Events", count: nil, icon: Ico.activity),
        Tab(id: .repo, label: "Repo map", count: nil, icon: Ico.repoIcon),
    ]

    var body: some View {
        Group { if st.inspectorOpen { expanded } else { rail } }
            .background(tk.surface)
            .overlay(alignment: .leading) { tk.line.frame(width: 1) }
    }

    private var rail: some View {
        VStack(spacing: 4) {
            ForEach(tabs.indices, id: \.self) { i in
                let t = tabs[i]
                Button { st.tab = t.id; st.inspectorOpen = true } label: {
                    HIcon(t.icon, size: 13).foregroundStyle(tk.fg3)
                        .frame(width: 32, height: 32)
                        .overlay(alignment: .topTrailing) { if let c = t.count { railBadge(c, alert: t.alert) } }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 6)
                .help(t.label + (t.count != nil ? " · \(t.count!)" : ""))
                .accessibilityLabel(t.label)
            }
            Spacer()
            VStack(spacing: 2) {
                Text("12.4k").foregroundStyle(tk.fg3)
                Text("$0.83").foregroundStyle(tk.fg4)
            }
            .font(F.mono(10))
            .padding(.vertical, 8).frame(maxWidth: .infinity)
            .overlay(alignment: .top) { tk.line.frame(height: 1).padding(.horizontal, 6) }
        }
        .padding(.vertical, 12)
        .frame(width: 44)
    }

    private func railBadge(_ c: Int, alert: Bool) -> some View {
        Text("\(c)").font(F.sans(9.5, .bold))
            .foregroundStyle(alert ? tk.onAmber : tk.fg2)
            .frame(minWidth: 14, minHeight: 14)
            .background(alert ? tk.amber : tk.surface3)
            .overlay(Capsule().stroke(alert ? .clear : tk.line2, lineWidth: 1))
            .clipShape(Capsule())
    }

    private var expanded: some View {
        VStack(spacing: 0) {
            HStack(spacing: 2) {
                ForEach(tabs.indices, id: \.self) { i in tabButton(tabs[i]) }
                Spacer()
                Button { st.inspectorOpen = false } label: {
                    HIcon(Ico.chevron, size: 12).foregroundStyle(tk.fg3)
                }.buttonStyle(.plain)
                .help("Collapse inspector")
                .accessibilityLabel("Collapse inspector")
            }
            .padding(.horizontal, 8).frame(height: 44)
            .overlay(alignment: .bottom) { tk.line.frame(height: 1) }

            ScrollView {
                switch st.tab {
                case .diff: DiffTab()
                case .approval: ApprovalTab()
                case .events: EventsTab()
                case .repo: RepoMapTab()
                }
            }
            footer
        }
        .frame(width: 320)
    }

    private func tabButton(_ t: Tab) -> some View {
        let active = st.tab == t.id
        return Button { st.tab = t.id } label: {
            HStack(spacing: 5) {
                HIcon(t.icon, size: 13)
                Text(t.label)
                if let c = t.count {
                    Text("\(c)").font(F.sans(10, .semibold))
                        .foregroundStyle(active ? tk.amberText : tk.fg3)
                        .padding(.horizontal, 5).frame(minWidth: 14)
                        .background(active ? tk.amberBg : tk.surface3)
                        .clipShape(Capsule())
                }
            }
            .font(F.sans(11.5, .medium)).foregroundStyle(active ? tk.fg : tk.fg3)
            .padding(.horizontal, 10).padding(.vertical, 6)
            .background(active ? tk.surface2 : .clear)
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(active ? tk.line2 : .clear, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 5))
        }
        .buttonStyle(.plain)
    }

    private var footer: some View {
        let g = GridItem(.flexible())
        return LazyVGrid(columns: [g, g], alignment: .leading, spacing: 4) {
            (Text("12,438").font(F.mono(11)).foregroundColor(tk.fg2) + Text(" tokens").foregroundColor(tk.fg3)).font(F.sans(11))
            (Text("$0.83").font(F.mono(11)).foregroundColor(tk.fg2) + Text(" session").foregroundColor(tk.fg3)).font(F.sans(11)).frame(maxWidth: .infinity, alignment: .trailing)
            (Text("auto-compact at ").foregroundColor(tk.fg3) + Text("190k").font(F.mono(11)).foregroundColor(tk.fg2)).font(F.sans(11))
            (Text("shadow · ").foregroundColor(tk.fg3) + Text("3 commits").font(F.mono(11)).foregroundColor(tk.fg2)).font(F.sans(11)).frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .overlay(alignment: .top) { tk.line.frame(height: 1) }
    }
}
