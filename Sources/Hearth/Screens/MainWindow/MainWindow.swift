import SwiftUI

enum InspectorTab { case diff, approval, events, repo }

// Holds all interactive state for the three-column main window.
final class MainWindowState: ObservableObject {
    @Published var selected: String
    @Published var expanded: [String: Bool]
    @Published var switcherOpen: Bool
    @Published var unread: Set<String>
    @Published var tab: InspectorTab = .diff
    @Published var inspectorOpen = false
    @Published var openTool: String? = "apply_patch"
    @Published var streamLen = 0
    @Published var streaming = true
    @Published var approvalOpen = false
    @Published var paletteOpen = false

    static let streamText =
        "Both AuthService and AuthRouter are migrated to JWT. " +
        "Refresh tokens are now stored in Keychain under the `auth.refresh` service. " +
        "I left a shim on the legacy cookie route so existing sessions don't break — " +
        "it expires in 14 days. Running XCTest next."

    init(initialSelected: String, showWorkspaceSwitcher: Bool) {
        selected = initialSelected
        switcherOpen = showWorkspaceSwitcher
        expanded = [
            "auth": true, "morning": false, "invoice": true, "cli": true,
            "ws:orchid": true, "ws:marble": true, "ws:global": true, "ws:dl": true,
        ]
        unread = Set(Mock.sessions.filter { $0.unread }.map { $0.id })
    }

    var activeRoot: Session {
        let rootID = selected.split(separator: ".").first.map(String.init) ?? selected
        return Mock.sessions.first { $0.id == rootID } ?? Mock.sessions[0]
    }
    var activeChild: ChildSession? {
        activeRoot.children.first { $0.id == selected }
    }
    var activeWs: Workspace {
        Mock.workspaces.first { $0.id == activeRoot.workspace } ?? Mock.workspaces[0]
    }
    var hasCheckIn: Bool { activeRoot.id == "cli" }

    func toggleUnread(_ id: String) {
        if unread.contains(id) { unread.remove(id) } else { unread.insert(id) }
    }
}

struct MainWindow: View {
    @StateObject private var st: MainWindowState
    @Environment(\.tk) private var tk

    init(initialSelected: String = "auth.patch", showWorkspaceSwitcher: Bool = false) {
        _st = StateObject(wrappedValue: MainWindowState(
            initialSelected: initialSelected, showWorkspaceSwitcher: showWorkspaceSwitcher))
    }

    var body: some View {
        VStack(spacing: 0) {
            titlebar
            ZStack {
                HStack(spacing: 0) {
                    SessionTreePane(st: st)
                    ConversationPane(st: st)
                    InspectorPane(st: st)
                }
                if st.approvalOpen { InlineApprovalSheet { st.approvalOpen = false } }
                if st.paletteOpen { InlinePalette { st.paletteOpen = false } }
            }
        }
        .frame(width: 1200, height: 800)
        .background(tk.bg)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(tk.line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: tk.shadowStrong, radius: 36, y: 28)
        .background(shortcuts)
        .task(id: st.selected) { await runStream() }
    }

    private func runStream() async {
        guard !st.hasCheckIn else { return }
        st.streamLen = 0
        st.streaming = true
        let total = MainWindowState.streamText.count
        while st.streamLen < total {
            try? await Task.sleep(nanoseconds: 28_000_000)
            if Task.isCancelled { return }
            st.streamLen = min(st.streamLen + 3, total)
        }
        st.streaming = false
    }

    private var shortcuts: some View {
        ZStack {
            Button("") { st.paletteOpen.toggle() }
                .keyboardShortcut("m", modifiers: [.command, .shift])
            Button("") { st.paletteOpen = false; st.approvalOpen = false }
                .keyboardShortcut(.cancelAction)
        }
        .opacity(0)
    }

    private var titlebar: some View {
        ZStack {
            HStack(spacing: 0) {
                TrafficLights()
                HStack(spacing: 7) {
                    LogoMark(size: 13).foregroundStyle(tk.amber)
                    Text("Hearth").font(F.sans(12, .semibold)).foregroundStyle(tk.fg)
                }
                .padding(.leading, 4)
                Spacer()
                HStack(spacing: 6) {
                    ThemeToggle()
                    HButton(kind: .ghost, hPad: 8, vPad: 3, action: { st.paletteOpen.toggle() }) {
                        HStack(spacing: 4) { HIcon(Ico.search, size: 11); Kbd("⌘⇧M", fontSize: 11) }
                    }
                }
                .padding(.trailing, 10)
            }
            Text(st.activeRoot.title).font(F.sans(12, .medium)).foregroundStyle(tk.fg2)
        }
        .frame(height: 36)
        .background(TitlebarBackground())
        .overlay(alignment: .bottom) { tk.line.frame(height: 1) }
    }
}
