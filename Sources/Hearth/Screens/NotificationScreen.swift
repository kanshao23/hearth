import SwiftUI

// Screen 7 — macOS Notification Center cards (success / approval / failure).
struct NotificationScreen: View {
    @Environment(\.tk) private var tk

    var body: some View {
        VStack(spacing: 10) {
            NotificationCard(
                leading: leadingTile(color: tk.ok, bg: Color(oklch: 0.74, 0.13, 155, 0.15),
                                     line: Color(oklch: 0.74, 0.13, 155, 0.35)) { HIcon(Ico.check, size: 18) },
                app: "Hearth", time: "now",
                title: "Refactor auth → JWT completed",
                message: "12 files changed · 218 +/41 − · 4 tests passing. Shadow branch hearth/refactor-auth-jwt.",
                actions: [.init("Review diff", .primary), .init("Merge…", .normal)])

            NotificationCard(
                leading: leadingTile(color: tk.amberText, bg: tk.amberBg, line: tk.amberLine) { HIcon(Ico.shield, size: 17) },
                app: "Hearth", time: "2m",
                title: "Approval needed · pdf:invoice",
                message: "exec(\"osascript -e ...\") wants Full Disk Access scope. Session paused.",
                actions: [.init("Allow once", .primary), .init("Deny", .danger)])

            NotificationCard(
                leading: leadingTile(color: tk.danger, bg: Color(oklch: 0.70, 0.17, 25, 0.14),
                                     line: Color(oklch: 0.70, 0.17, 25, 0.35)) { HIcon(Ico.x, size: 16) },
                app: "Hearth", time: "14:02",
                title: "Sandbox denied write outside workspace",
                message: "patch tried /Users/jen/Library. Session paused — open to grant scope or revise plan.",
                actions: [.init("Open session", .primary), .init("Dismiss", .normal)])
        }
        .padding(12)
        .frame(width: 380)
    }

    private func leadingTile<C: View>(color: Color, bg: Color, line: Color, @ViewBuilder _ content: () -> C) -> AnyView {
        AnyView(
            content()
                .foregroundStyle(color)
                .frame(width: 36, height: 36)
                .background(bg)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(line, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        )
    }
}

struct NotifAction {
    let label: String
    let kind: HButton<Text>.Kind
    init(_ label: String, _ kind: HButton<Text>.Kind) { self.label = label; self.kind = kind }
}

struct NotificationCard: View {
    let leading: AnyView
    let app: String
    let time: String
    let title: String
    let message: String
    let actions: [NotifAction]
    @Environment(\.tk) private var tk

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            leading
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 6) {
                    Text(app.uppercased()).font(F.sans(11, .semibold)).tracking(0.2).foregroundStyle(tk.fg2)
                    Text("· \(time)").font(F.sans(11)).foregroundStyle(tk.fg4)
                }
                Text(title).font(F.sans(13, .semibold)).foregroundStyle(tk.fg)
                    .fixedSize(horizontal: false, vertical: true).padding(.top, 2)
                Text(message).font(F.sans(12)).foregroundStyle(tk.fg2)
                    .fixedSize(horizontal: false, vertical: true).padding(.top, 3)
                HStack(spacing: 6) {
                    ForEach(actions.indices, id: \.self) { i in
                        HButton(kind: actions[i].kind, hPad: 10, vPad: 4, fontSize: 11.5) {
                            Text(actions[i].label)
                        }
                    }
                }
                .padding(.top, 10)
            }
            HIcon(Ico.x, size: 12).foregroundStyle(tk.fg4)
        }
        .padding(12)
        .background(tk.osOverlay)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(tk.osOverlayLine, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: tk.shadowStrong.opacity(0.7), radius: 12, y: 8)
    }
}
