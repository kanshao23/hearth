import SwiftUI

// Syntax span — mirrors the .code .k/.s/.n/.c/.p classes in tokens.css.
struct CodeSpan {
    enum Kind { case plain, k, s, n, c, p }
    let text: String
    var kind: Kind = .plain

    init(_ text: String, _ kind: Kind = .plain) { self.text = text; self.kind = kind }
}

struct CodeBlock: View {
    let lines: [[CodeSpan]]
    var fontSize: CGFloat = 12
    @Environment(\.tk) private var tk

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(lines.indices, id: \.self) { i in
                line(lines[i])
                    .lineSpacing(fontSize * 0.55)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(tk.bg2)
        .overlay(RoundedRectangle(cornerRadius: Radius.r2).stroke(tk.line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: Radius.r2))
    }

    private func line(_ spans: [CodeSpan]) -> some View {
        var text = Text("")
        for span in spans {
            var t = Text(span.text).font(F.mono(fontSize))
            switch span.kind {
            case .plain: t = t.foregroundColor(tk.fg2)
            case .k: t = t.foregroundColor(Sem.codeK)
            case .s: t = t.foregroundColor(Sem.codeS)
            case .n: t = t.foregroundColor(Sem.codeN)
            case .c: t = t.italic().foregroundColor(tk.fg3)
            case .p: t = t.foregroundColor(tk.fg3)
            }
            text = text + t
        }
        return text.frame(maxWidth: .infinity, alignment: .leading)
    }
}
