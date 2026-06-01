import SwiftUI

struct OnboardingStep2: View {
    @Environment(\.tk) private var tk

    private let perms: [(icon: IconSpec, t: String, d: String, s: String)] = [
        (Ico.file, "Full Disk Access", "Read files outside the current workspace", "granted"),
        (Ico.folder, "Files & Folders", "Read/write any path a skill targets", "granted"),
        (Ico.mail, "Mail", "For Mail skills like inbox digest", "prompt"),
        (Ico.calendar, "Calendar", "Read/write events", "skip"),
        (Ico.activity, "Accessibility", "Required for AppleScript bridge", "prompt"),
        (Ico.bell, "Notifications", "Show macOS banners on session complete", "granted"),
    ]

    var body: some View {
        OnboardingFrame(step: 2) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Grant permissions").font(F.sans(22, .semibold)).foregroundStyle(tk.fg)
                Text("Skills only run inside the permissions you grant. Each can be revoked from System Settings → Privacy at any time.")
                    .font(F.sans(13.5)).foregroundStyle(tk.fg2)
                    .frame(maxWidth: 440, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true).padding(.top, 8)

                VStack(spacing: 8) { ForEach(perms.indices, id: \.self) { permRow(perms[$0]) } }
                    .padding(.top, 22)
                Spacer()
                OnboardingFooter(step: 2, nextLabel: "Continue")
            }
        }
    }

    private func permRow(_ p: (icon: IconSpec, t: String, d: String, s: String)) -> some View {
        HStack(spacing: 12) {
            HIcon(p.icon, size: 14).foregroundStyle(tk.fg3).frame(width: 22)
            VStack(alignment: .leading, spacing: 1) {
                Text(p.t).font(F.sans(13, .medium)).foregroundStyle(tk.fg)
                Text(p.d).font(F.sans(11.5)).foregroundStyle(tk.fg3)
            }
            Spacer()
            switch p.s {
            case "granted": Chip(.ok) { HStack(spacing: 4) { HIcon(Ico.check, size: 10); Text("Granted") } }
            case "prompt": HButton(kind: .primary, hPad: 10, vPad: 4, fontSize: 11) { Text("Grant") }
            default: HButton(kind: .ghost, hPad: 10, vPad: 4, fontSize: 11) { Text("Skip") }
            }
        }
        .padding(.horizontal, 12).padding(.vertical, 9)
        .background(tk.surface)
        .overlay(RoundedRectangle(cornerRadius: 7).stroke(tk.line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 7))
    }
}
