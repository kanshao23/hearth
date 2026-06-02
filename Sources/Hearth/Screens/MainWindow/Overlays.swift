import SwiftUI

// Approval sheet projected onto the main window (lighter copy from inspector.jsx).
struct InlineApprovalSheet: View {
    let onClose: () -> Void
    @Environment(\.tk) private var tk

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.opacity(0.5).onTapGesture(perform: onClose)
            sheet.frame(width: 540)
        }
    }

    private var sheet: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                HIcon(Ico.shield, size: 16).foregroundStyle(tk.amberText)
                    .frame(width: 34, height: 34)
                    .background(tk.amberBg)
                    .overlay(RoundedRectangle(cornerRadius: 7).stroke(tk.amberLine, lineWidth: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                VStack(alignment: .leading, spacing: 4) {
                    (Text("Approve ") + Text("apply_patch").font(F.mono(14)) + Text(" on 2 files"))
                        .font(F.sans(14, .semibold)).foregroundStyle(tk.fg)
                    Text("workspace-write · shadow branch active · session \"Refactor auth → JWT\"")
                        .font(F.sans(12)).foregroundStyle(tk.fg2)
                }
                Spacer()
                HButton(kind: .ghost, hPad: 4, vPad: 4, action: onClose) { HIcon(Ico.x, size: 12) }
                    .help("Close").accessibilityLabel("Close")
            }
            .padding(.horizontal, 22).padding(.top, 18).padding(.bottom, 12)

            ScrollView { DiffView(rows: Mock.authDiff) }
                .frame(maxHeight: 220)
                .background(tk.bg2)
                .overlay(RoundedRectangle(cornerRadius: Radius.r2).stroke(tk.line, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: Radius.r2))
                .padding(.horizontal, 22).padding(.bottom, 12)

            HStack(spacing: 8) {
                Spacer()
                HButton(action: onClose) { Text("Deny") }
                HButton { Text("Always in dir") }
                HButton { Text("Allow for session") }
                HButton(kind: .primary, action: onClose) { Text("Allow once") }
            }
            .padding(.horizontal, 22).padding(.vertical, 12)
            .overlay(alignment: .top) { tk.line.frame(height: 1) }
        }
        .background(tk.surface)
        .overlay(
            UnevenRoundedRectangle(bottomLeadingRadius: 12, bottomTrailingRadius: 12)
                .stroke(tk.line2, lineWidth: 1))
        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 12, bottomTrailingRadius: 12))
        .shadow(color: .black.opacity(0.6), radius: 40, y: 0)
    }
}

struct InlinePalette: View {
    let onClose: () -> Void
    var body: some View {
        ZStack(alignment: .top) {
            Color.black.opacity(0.55).onTapGesture(perform: onClose)
            PaletteScreen(onClose: onClose, chromeless: true)
                .padding(.top, 96)
        }
    }
}
