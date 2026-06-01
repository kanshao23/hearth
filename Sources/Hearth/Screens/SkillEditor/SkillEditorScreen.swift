import SwiftUI

// Screen 5 — Skill editor (1200×800). Library · markdown source+preview · dry-run.
struct SkillEditorScreen: View {
    @Environment(\.tk) private var tk
    @State private var tab = "source"

    var body: some View {
        VStack(spacing: 0) {
            titlebar
            HStack(spacing: 0) {
                SkillLibrary()
                editor
                SkillInspector()
            }
        }
        .frame(width: 1200, height: 800)
        .background(tk.bg)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(tk.line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: tk.shadowStrong, radius: 36, y: 28)
    }

    private var titlebar: some View {
        ZStack {
            HStack(spacing: 0) {
                TrafficLights()
                HStack(spacing: 8) {
                    LogoMark(size: 14).foregroundStyle(tk.amber)
                    Text("Hearth").font(F.sans(12, .semibold)).foregroundStyle(tk.fg)
                    Text("· skills").font(F.sans(11.5)).foregroundStyle(tk.fg3)
                }
                .padding(.leading, 4)
                Spacer()
                HStack(spacing: 6) {
                    ThemeToggle()
                    HButton(kind: .ghost, hPad: 8, vPad: 4) {
                        HStack(spacing: 4) { HIcon(Ico.disk, size: 12); Text("Save").font(F.sans(11.5)); Kbd("⌘S", fontSize: 11) }
                    }
                    HButton(kind: .ghost, hPad: 8, vPad: 4) { HStack(spacing: 4) { HIcon(Ico.play, size: 11); Text("Dry-run") } }
                    HButton(kind: .primary, hPad: 10, vPad: 4) { HStack(spacing: 4) { HIcon(Ico.bolt, size: 11); Text("Run skill") } }
                }
                .padding(.trailing, 10)
            }
            Text("~/.hearth/skills/morning.md").font(F.mono(12)).foregroundStyle(tk.fg2)
        }
        .frame(height: 36)
        .background(TitlebarBackground())
        .overlay(alignment: .bottom) { tk.line.frame(height: 1) }
    }

    private var editor: some View {
        VStack(spacing: 0) {
            editorTabBar
            HStack(spacing: 1) {
                ScrollView { SkillSource() }.background(tk.bg2)
                ScrollView { SkillPreview().padding(24) }.background(tk.surface)
            }
            .background(tk.line)
            statusBar
        }
        .frame(maxWidth: .infinity)
        .background(tk.bg)
    }

    private var editorTabBar: some View {
        HStack(spacing: 4) {
            ForEach([("source", "Source", Ico.file), ("split", "Split", Ico.sliders), ("preview", "Preview", Ico.wand)], id: \.0) { t in
                let active = tab == t.0
                Button { tab = t.0 } label: {
                    HStack(spacing: 5) { HIcon(t.2, size: 11); Text(t.1) }
                        .font(F.sans(11.5, .medium)).foregroundStyle(active ? tk.fg : tk.fg3)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(active ? tk.surface2 : .clear)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(active ? tk.line2 : .clear, lineWidth: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }.buttonStyle(.plain)
            }
            Spacer()
            Chip(.ok) { HStack(spacing: 4) { HIcon(Ico.check, size: 10); Text("frontmatter valid") } }
            Chip(.plain, mono: true) { Text("md · 1.2 KB") }
        }
        .padding(.horizontal, 12).frame(height: 36)
        .overlay(alignment: .bottom) { tk.line.frame(height: 1) }
    }

    private var statusBar: some View {
        HStack(spacing: 12) {
            Text("Ln 12, Col 18"); Text("UTF-8"); Text("LF")
            Spacer()
            Text("last run 7h ago · 4 messages · $0.003")
            HStack(spacing: 4) { Dot(kind: .ok); Text("validates") }
        }
        .font(F.mono(11)).foregroundStyle(tk.fg3)
        .padding(.horizontal, 12).frame(height: 28)
        .overlay(alignment: .top) { tk.line.frame(height: 1) }
    }
}
