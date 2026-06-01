import SwiftUI

// Screen 6 — Command palette (640×480), ⌘⇧M. Fuzzy search across skills/sessions/files.
struct PaletteScreen: View {
    var onClose: (() -> Void)? = nil
    var chromeless = false
    @Environment(\.tk) private var tk
    @State private var q = "refac"
    @State private var sel = 2

    private struct Item {
        let group, icon, primary, secondary, meta: String
    }
    private let items: [Item] = [
        .init(group: "Skills", icon: "bolt", primary: "git:commit", secondary: "Stage, summarize, commit", meta: "⌃G"),
        .init(group: "Skills", icon: "bolt", primary: "review:diff", secondary: "Walk through unstaged diff", meta: "⌃D"),
        .init(group: "Sessions", icon: "spin", primary: "Refactor auth → JWT", secondary: "active · 1h 04m · opus-4.7 · 42%", meta: "open"),
        .init(group: "Sessions", icon: "paused", primary: "PDF invoice scan", secondary: "paused · awaiting approval · 1 pending", meta: "resume"),
        .init(group: "Sessions", icon: "ok", primary: "Refactor onboarding copy", secondary: "completed 2d ago · 7 files · merged", meta: "open"),
        .init(group: "Files", icon: "file", primary: "AuthService.swift", secondary: "~/code/orchid/Sources/Auth", meta: "open"),
        .init(group: "Files", icon: "file", primary: "AuthRouter.swift", secondary: "~/code/orchid/Sources/Auth", meta: "open"),
        .init(group: "Actions", icon: "plus", primary: "New task in current workspace", secondary: "⌘N to skip palette", meta: "↵"),
    ]

    var body: some View {
        if chromeless {
            panel
        } else {
            ZStack {
                Color(.sRGB, red: 8/255, green: 8/255, blue: 11/255, opacity: 0.72).ignoresSafeArea()
                panel
            }
            .frame(width: 640, height: 480)
        }
    }

    private var panel: some View {
        VStack(spacing: 0) {
            searchRow
            tk.line.frame(height: 1)
            ScrollView { results.padding(.vertical, 6) }
            tk.line.frame(height: 1)
            footer
        }
        .frame(width: 560)
        .frame(maxHeight: 420)
        .background(tk.osOverlay)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(tk.osOverlayLine, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: tk.shadowStrong, radius: 30, y: 24)
    }

    private var searchRow: some View {
        HStack(spacing: 10) {
            HIcon(Ico.search, size: 16).foregroundStyle(tk.fg3)
            TextField("Search skills, sessions, files…", text: $q)
                .textFieldStyle(.plain)
                .font(F.sans(16)).foregroundStyle(tk.fg)
            HStack(spacing: 6) {
                Chip(.plain) { Text("scope: all") }
                Kbd("esc")
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
    }

    private var results: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(items.indices, id: \.self) { i in
                if i == 0 || items[i].group != items[i - 1].group {
                    Text(items[i].group.uppercased())
                        .font(F.sans(10.5, .semibold)).tracking(0.5).foregroundStyle(tk.fg4)
                        .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 4)
                }
                row(i)
            }
        }
    }

    private func row(_ i: Int) -> some View {
        let it = items[i]
        let selected = sel == i
        let mono = it.group == "Files" || it.group == "Skills"
        return HStack(spacing: 10) {
            iconFor(it.icon, selected: selected).frame(width: 18)
            VStack(alignment: .leading, spacing: 1) {
                Text(it.primary)
                    .font(mono ? F.mono(13) : F.sans(13.5, .medium))
                    .foregroundStyle(tk.fg)
                Text(it.secondary).font(F.sans(11.5)).foregroundStyle(tk.fg3).lineLimit(1)
            }
            Spacer()
            HStack(spacing: 4) {
                if selected { Kbd("↵", fg: tk.amberText, border: tk.amberLine) }
                Chip(.plain, mono: true) { Text(it.meta).foregroundStyle(tk.fg3) }
            }
        }
        .padding(.horizontal, 10).padding(.vertical, 7)
        .background(selected ? tk.amberBg : .clear)
        .overlay(RoundedRectangle(cornerRadius: Radius.r2).stroke(selected ? tk.amberLine : .clear, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: Radius.r2))
        .padding(.horizontal, 6)
        .onHover { if $0 { sel = i } }
    }

    @ViewBuilder
    private func iconFor(_ icon: String, selected: Bool) -> some View {
        let c = selected ? tk.amberText : tk.fg3
        switch icon {
        case "bolt": HIcon(Ico.bolt, size: 13).foregroundStyle(c)
        case "spin": Spinner(size: 11)
        case "paused": Dot(kind: .paused)
        case "ok": Dot(kind: .ok)
        case "file": HIcon(Ico.file, size: 13).foregroundStyle(c)
        default: HIcon(Ico.plus, size: 13).foregroundStyle(c)
        }
    }

    private var footer: some View {
        HStack {
            HStack(spacing: 6) {
                Kbd("↑"); Kbd("↓"); Text("navigate")
                Kbd("↵").padding(.leading, 10); Text("open")
                Kbd("⌘").padding(.leading, 10); Kbd("↵"); Text("run in new session")
            }
            Spacer()
            HStack(spacing: 6) {
                LogoMark(size: 11).foregroundStyle(tk.amber)
                Text("Hearth · 8 matches")
            }
        }
        .font(F.sans(11)).foregroundStyle(tk.fg3)
        .padding(.horizontal, 14).padding(.vertical, 8)
    }
}
