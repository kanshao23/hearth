import SwiftUI

private struct Artboard: Identifiable {
    let id: String
    let label: String
    let w: CGFloat
    let h: CGFloat
    let make: () -> AnyView
}
private struct GallerySection: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let boards: [Artboard]
}

// Navigator hosting all screens — mirrors the DCSection/DCArtboard structure of
// Hearth.html. Sidebar picks an artboard; detail shows it at its design size.
struct GalleryView: View {
    @Environment(\.tk) private var tk
    @EnvironmentObject private var theme: ThemeManager
    @State private var selected = "menubar"

    private var sections: [GallerySection] {
        [
            GallerySection(id: "surfaces", title: "System surfaces",
                           subtitle: "Menubar popover · approval sheet · notification cards", boards: [
                Artboard(id: "menubar", label: "02 · Menubar popover", w: 300, h: 490) { AnyView(MenubarScreen()) },
                Artboard(id: "approval", label: "03 · Approval sheet", w: 660, h: 760) { AnyView(ApprovalScreen()) },
                Artboard(id: "notifs", label: "07 · Notifications", w: 404, h: 420) { AnyView(NotificationScreen()) },
            ]),
            GallerySection(id: "app", title: "Main app",
                           subtitle: "Three-column workspace · steerable · ⌘⇧M for palette", boards: [
                Artboard(id: "main", label: "04a · Steerable while working", w: 1200, h: 800) { AnyView(MainWindow(initialSelected: "auth.patch")) },
                Artboard(id: "main-checkin", label: "04b · Agent check-in", w: 1200, h: 800) { AnyView(MainWindow(initialSelected: "cli.rfc")) },
                Artboard(id: "main-switcher", label: "04c · Workspace switcher", w: 1200, h: 800) { AnyView(MainWindow(initialSelected: "auth.patch", showWorkspaceSwitcher: true)) },
                Artboard(id: "skill", label: "05 · Skill editor", w: 1200, h: 800) { AnyView(SkillEditorScreen()) },
            ]),
            GallerySection(id: "discovery", title: "Discovery",
                           subtitle: "⌘⇧M from anywhere — skills, sessions, files", boards: [
                Artboard(id: "palette", label: "06 · Command palette", w: 640, h: 480) { AnyView(PaletteScreen()) },
            ]),
            GallerySection(id: "onboarding", title: "Onboarding",
                           subtitle: "Three-step first-run wizard", boards: [
                Artboard(id: "ob1", label: "08a · Provider", w: 720, h: 520) { AnyView(OnboardingStep1()) },
                Artboard(id: "ob2", label: "08b · Permissions", w: 720, h: 520) { AnyView(OnboardingStep2()) },
                Artboard(id: "ob3", label: "08c · First skill", w: 720, h: 520) { AnyView(OnboardingStep3()) },
            ]),
        ]
    }

    private var current: Artboard? {
        sections.flatMap(\.boards).first { $0.id == selected }
    }

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            detail
        }
        .background(tk.bg)
    }

    private var sidebar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                LogoMark(size: 18).foregroundStyle(tk.amber)
                VStack(alignment: .leading, spacing: 0) {
                    Text("Hearth").font(F.sans(14, .semibold)).foregroundStyle(tk.fg)
                    Text("design · 7 screens").font(F.sans(10.5)).foregroundStyle(tk.fg3)
                }
                Spacer()
                ThemeToggle(size: 14)
            }
            .padding(12)
            .overlay(alignment: .bottom) { tk.line.frame(height: 1) }

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(sections) { section in
                        Text(section.title.uppercased()).font(F.sans(10.5, .semibold)).tracking(0.5)
                            .foregroundStyle(tk.fg3)
                            .padding(.horizontal, 12).padding(.top, 14).padding(.bottom, 6)
                        ForEach(section.boards) { board in
                            sidebarRow(board)
                        }
                    }
                }
                .padding(.bottom, 12)
            }
        }
        .frame(width: 240)
        .background(tk.surface)
        .overlay(alignment: .trailing) { tk.line.frame(width: 1) }
    }

    private func sidebarRow(_ board: Artboard) -> some View {
        let sel = selected == board.id
        return Button { selected = board.id } label: {
            Text(board.label).font(F.sans(12.5, sel ? .medium : .regular))
                .foregroundStyle(sel ? tk.amberText : tk.fg2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10).padding(.vertical, 7)
                .background(sel ? tk.amberBg : .clear)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(sel ? tk.amberLine : .clear, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 5))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 6)
    }

    private var detail: some View {
        VStack(spacing: 0) {
            if let board = current {
                HStack(spacing: 8) {
                    Text(board.label).font(F.sans(13, .medium)).foregroundStyle(tk.fg)
                    Text("\(Int(board.w)) × \(Int(board.h))").font(F.mono(11)).foregroundStyle(tk.fg4)
                    Spacer()
                }
                .padding(.horizontal, 20).padding(.vertical, 12)
                .overlay(alignment: .bottom) { tk.line.frame(height: 1) }

                ScrollView([.horizontal, .vertical]) {
                    board.make()
                        .frame(width: board.w, height: board.h)
                        .padding(40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(canvasBackground)
    }

    private var canvasBackground: some View {
        (tk.isLight ? Color(hex: "e9e6df") : Color(hex: "08080b"))
            .overlay(
                RadialGradient(colors: [tk.fg.opacity(0.04), .clear], center: .top, startRadius: 0, endRadius: 600)
            )
    }
}
