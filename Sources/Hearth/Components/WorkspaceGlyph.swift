import SwiftUI

struct WorkspaceGlyph: View {
    let workspace: Workspace
    var size: CGFloat = 16
    @Environment(\.tk) private var tk

    var body: some View {
        switch workspace.kind {
        case .global:
            iconTile { HIcon(Ico.globe, size: round(size * 0.65)) }
        case .folder:
            iconTile { HIcon(Ico.folder, size: round(size * 0.6)) }
        case .repo:
            letterTile
        }
    }

    private func iconTile<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .foregroundStyle(tk.fg2)
            .frame(width: size, height: size)
            .background(tk.surface3)
            .overlay(RoundedRectangle(cornerRadius: round(size / 4)).stroke(tk.line2, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: round(size / 4)))
    }

    private var letterTile: some View {
        let tone = workspace.tone
        let bg = tone == .blue ? Sem.blueBg : tk.amberBg
        let line = tone == .blue ? Sem.blueLine : tk.amberLine
        let fg = tone == .blue ? Sem.blueFg : tk.amberText
        return Text(workspace.glyph)
            .font(F.mono(round(size * 0.65), .semibold))
            .foregroundStyle(fg)
            .frame(width: size, height: size)
            .background(bg)
            .overlay(RoundedRectangle(cornerRadius: round(size / 4)).stroke(line, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: round(size / 4)))
    }
}
