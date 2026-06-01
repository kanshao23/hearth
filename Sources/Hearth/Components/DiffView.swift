import SwiftUI

struct DiffRow: Identifiable {
    let id = UUID()
    let gut: String
    enum Kind { case plain, add, del }
    let kind: Kind
    let src: String
}

struct DiffView: View {
    let rows: [DiffRow]
    @Environment(\.tk) private var tk

    var body: some View {
        VStack(spacing: 0) {
            ForEach(rows) { row in
                HStack(spacing: 0) {
                    Text(gutterText(row))
                        .font(F.mono(12))
                        .foregroundStyle(gutterColor(row))
                        .frame(width: 36, alignment: .trailing)
                        .padding(.trailing, 10)
                    Text(row.src.isEmpty ? " " : row.src)
                        .font(F.mono(12))
                        .foregroundStyle(srcColor(row))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.trailing, 12)
                }
                .lineSpacing(12 * 0.55)
                .background(bg(row))
            }
        }
        .padding(.vertical, 8)
    }

    private func gutterText(_ r: DiffRow) -> String {
        switch r.kind {
        case .add: return "+ \(r.gut)"
        case .del: return "− \(r.gut)"
        case .plain: return r.gut
        }
    }
    private func gutterColor(_ r: DiffRow) -> Color {
        switch r.kind {
        case .add: return tk.addFg
        case .del: return tk.delFg
        case .plain: return tk.fg4
        }
    }
    private func srcColor(_ r: DiffRow) -> Color {
        switch r.kind {
        case .add: return tk.addFg
        case .del: return tk.delFg
        case .plain: return tk.fg2
        }
    }
    private func bg(_ r: DiffRow) -> Color {
        switch r.kind {
        case .add: return tk.addBg
        case .del: return tk.delBg
        case .plain: return .clear
        }
    }
}
