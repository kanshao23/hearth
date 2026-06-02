import SwiftUI

// Screen 9 — Settings (760×560). Sidebar nav + panes, in the Hearth chrome.
struct SettingsScreen: View {
    @Environment(\.tk) private var tk
    @EnvironmentObject private var theme: ThemeManager
    @State private var section = "general"

    private let nav: [(id: String, label: String, icon: IconSpec)] = [
        ("general", "General", Ico.cog),
        ("providers", "Providers", Ico.cpu),
        ("permissions", "Permissions", Ico.shield),
        ("sandbox", "Sandbox", Ico.lock),
        ("about", "About", Ico.sparkle),
    ]

    var body: some View {
        VStack(spacing: 0) {
            titlebar
            HStack(spacing: 0) {
                sidebar
                ScrollView { content.padding(24).frame(maxWidth: .infinity, alignment: .leading) }
                    .frame(maxWidth: .infinity)
                    .background(tk.bg)
            }
        }
        .frame(width: 760, height: 560)
        .background(tk.bg)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(tk.line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: tk.shadowStrong, radius: 36, y: 28)
    }

    private var titlebar: some View {
        ZStack {
            HStack { TrafficLights(); Spacer() }
            Text("Settings").font(F.sans(12, .medium)).foregroundStyle(tk.fg2)
        }
        .frame(height: 36)
        .background(TitlebarBackground())
        .overlay(alignment: .bottom) { tk.line.frame(height: 1) }
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(nav, id: \.id) { item in
                let sel = section == item.id
                Button { section = item.id } label: {
                    HStack(spacing: 8) {
                        HIcon(item.icon, size: 13).foregroundStyle(sel ? tk.amberText : tk.fg3)
                        Text(item.label).font(F.sans(12.5, sel ? .medium : .regular)).foregroundStyle(sel ? tk.amberText : tk.fg2)
                        Spacer()
                    }
                    .padding(.horizontal, 10).padding(.vertical, 7)
                    .background(sel ? tk.amberBg : .clear)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(sel ? tk.amberLine : .clear, lineWidth: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(item.label)
            }
            Spacer()
        }
        .padding(8).frame(width: 190)
        .background(tk.surface)
        .overlay(alignment: .trailing) { tk.line.frame(width: 1) }
    }

    @ViewBuilder private var content: some View {
        switch section {
        case "providers": providers
        case "permissions": permissions
        case "sandbox": sandbox
        case "about": about
        default: general
        }
    }

    // ── General ──
    private var general: some View {
        VStack(alignment: .leading, spacing: 0) {
            heading("General")
            card {
                rowToggle("Appearance", "Light theme", isOn: Binding(get: { theme.isLight }, set: { _ in theme.toggle() }))
                divider
                rowStatic("Command palette", trailing: AnyView(Kbd("⌘⇧M")))
                divider
                rowToggle("Launch at login", "Start Hearth when you log in", isOn: .constant(true))
                divider
                rowToggle("Show menubar icon", "Keep Hearth in the menubar", isOn: .constant(true))
            }
        }
    }

    private var providers: some View {
        VStack(alignment: .leading, spacing: 0) {
            heading("Providers")
            card {
                providerRow("Anthropic", "Claude opus / sonnet / haiku", .ok, "active")
                divider
                providerRow("OpenAI · compatible", "OpenAI, Groq, OpenRouter, Azure", .plain, "add key")
                divider
                providerRow("Local · Ollama", "localhost:11434", .ok, "detected")
            }
            Text("Keys live in Keychain. One session can route summarizer→haiku, coder→opus.")
                .font(F.sans(11.5)).foregroundStyle(tk.fg3).padding(.top, 10)
        }
    }

    private var permissions: some View {
        let rows: [(IconSpec, String, String, Chip.Kind, String)] = [
            (Ico.file, "Full Disk Access", "Read files outside the workspace", .ok, "granted"),
            (Ico.folder, "Files & Folders", "Read/write any targeted path", .ok, "granted"),
            (Ico.mail, "Mail", "For Mail skills like inbox digest", .warn, "prompt"),
            (Ico.calendar, "Calendar", "Read/write events", .plain, "off"),
            (Ico.activity, "Accessibility", "Required for AppleScript bridge", .warn, "prompt"),
            (Ico.bell, "Notifications", "Banners on session complete", .ok, "granted"),
        ]
        return VStack(alignment: .leading, spacing: 0) {
            heading("Permissions")
            card {
                ForEach(rows.indices, id: \.self) { i in
                    let r = rows[i]
                    HStack(spacing: 10) {
                        HIcon(r.0, size: 14).foregroundStyle(tk.fg3).frame(width: 18)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(r.1).font(F.sans(13, .medium)).foregroundStyle(tk.fg)
                            Text(r.2).font(F.sans(11.5)).foregroundStyle(tk.fg3)
                        }
                        Spacer()
                        Chip(r.3) { Text(r.4) }
                    }
                    .padding(.horizontal, 12).padding(.vertical, 10)
                    if i < rows.count - 1 { divider }
                }
            }
            Text("Revoke any of these from System Settings → Privacy at any time.")
                .font(F.sans(11.5)).foregroundStyle(tk.fg3).padding(.top, 10)
        }
    }

    private var sandbox: some View {
        VStack(alignment: .leading, spacing: 0) {
            heading("Sandbox")
            card {
                ForEach(["read-only", "workspace-write", "workspace + network", "full"], id: \.self) { lvl in
                    radioRow(lvl, selected: lvl == "workspace-write", note: lvl == "workspace-write" ? "default" : nil)
                    if lvl != "full" { divider }
                }
            }
            card {
                rowToggle("Auto-approve in dry-run", "Skip approval sheets when tools are mocked", isOn: .constant(true))
            }.padding(.top, 10)
        }
    }

    private var about: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                LogoMark(size: 40).foregroundStyle(tk.amber)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Hearth").font(F.sans(20, .semibold)).foregroundStyle(tk.fg)
                    Text("v0.4.2 · local-first · macOS native").font(F.sans(12)).foregroundStyle(tk.fg3)
                }
            }
            card {
                rowStatic("Daemon", trailing: AnyView(Text("0.4.2 · :65432").font(F.mono(11)).foregroundColor(tk.fg2)))
                divider
                rowStatic("Build", trailing: AnyView(Text("SwiftUI · no Electron").font(F.mono(11)).foregroundColor(tk.fg2)))
                divider
                rowStatic("License", trailing: AnyView(Text("MIT").font(F.mono(11)).foregroundColor(tk.fg2)))
            }
            Text("Your machine. Your agents. Your rules.").font(F.sans(11.5)).foregroundStyle(tk.fg3)
        }
    }

    // ── building blocks ──
    private func heading(_ s: String) -> some View {
        Text(s).font(F.sans(17, .semibold)).foregroundStyle(tk.fg).padding(.bottom, 14)
    }
    private func card<C: View>(@ViewBuilder _ c: () -> C) -> some View {
        VStack(spacing: 0) { c() }
            .background(tk.surface)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(tk.line, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    private var divider: some View { tk.line.frame(height: 1) }

    private func rowToggle(_ title: String, _ sub: String, isOn: Binding<Bool>) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(F.sans(13, .medium)).foregroundStyle(tk.fg)
                Text(sub).font(F.sans(11.5)).foregroundStyle(tk.fg3)
            }
            Spacer()
            Toggle("", isOn: isOn).labelsHidden().toggleStyle(.switch).tint(tk.amber)
        }
        .padding(.horizontal, 12).padding(.vertical, 10)
    }
    private func rowStatic(_ title: String, trailing: AnyView) -> some View {
        HStack {
            Text(title).font(F.sans(13, .medium)).foregroundStyle(tk.fg)
            Spacer()
            trailing
        }
        .padding(.horizontal, 12).padding(.vertical, 10)
    }
    private func providerRow(_ t: String, _ d: String, _ chip: Chip.Kind, _ tag: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 1) {
                Text(t).font(F.sans(13, .medium)).foregroundStyle(tk.fg)
                Text(d).font(F.sans(11.5)).foregroundStyle(tk.fg3)
            }
            Spacer()
            Chip(chip) { Text(tag) }
        }
        .padding(.horizontal, 12).padding(.vertical, 10)
    }
    private func radioRow(_ t: String, selected: Bool, note: String?) -> some View {
        HStack(spacing: 10) {
            ZStack {
                Circle().stroke(selected ? tk.amber : tk.lineStrong, lineWidth: 1.5).frame(width: 15, height: 15)
                if selected { Circle().fill(tk.amber).frame(width: 7, height: 7) }
            }
            Text(t).font(F.mono(12.5)).foregroundStyle(selected ? tk.amberText : tk.fg)
            if let note { Chip(.ok) { Text(note) } }
            Spacer()
        }
        .padding(.horizontal, 12).padding(.vertical, 9)
    }
}
