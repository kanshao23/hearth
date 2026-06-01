import SwiftUI

struct SkillSource: View {
    @Environment(\.tk) private var tk

    private static let frontmatter = """
    ---
    name: morning
    description: Daily 8am inbox digest → Notes
    triggers: [schedule, manual]
    schedule: "0 8 * * *"
    model_hint: claude-haiku-4-5
    tools_allow:
      - mac-bridge:mail
      - mac-bridge:notification
      - fs:write
      - fs:read
    tools_deny:
      - exec.network
    sandbox: workspace-write
    auto_approve: true
    ---
    """

    private static let body = """
    # Morning routine

    Read all unread Gmail messages, summarize each, append summaries to
    `~/Documents/Notes/$DATE.md`, then send a macOS notification.

    ## Steps

    1. Fetch unread Gmail via Mac bridge (max 10).
    2. For each message:
       - Summarize subject + body in **≤ 2 sentences**.
       - Note sender, time, link.
    3. Append to `~/Documents/Notes/$DATE.md` under heading `## Inbox · $DATE`.
    4. `notification.show("Inbox digest", "$N messages summarized")`

    ## Rules

    - Do **not** mark messages as read.
    - Skip newsletters tagged `promotions`.
    - If `$N == 0`, exit silently.
    """

    private struct Line: Identifiable { let id = UUID(); let src: String; let fm: Bool }

    private var lines: [Line] {
        var out = Self.frontmatter.components(separatedBy: "\n").map { Line(src: $0, fm: true) }
        out.append(Line(src: "", fm: false))
        out += Self.body.components(separatedBy: "\n").map { Line(src: $0, fm: false) }
        return out
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            let ls = lines
            ForEach(ls.indices, id: \.self) { i in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(i + 1)").font(F.mono(10.5)).foregroundStyle(tk.fg4)
                        .frame(width: 48, alignment: .trailing).padding(.top, 2)
                    paint(ls[i]).font(F.mono(12)).frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.trailing, 12).padding(.leading, 4)
                .background(ls[i].fm ? Color(oklch: 0.76, 0.135, 65, 0.04) : .clear)
            }
        }
        .padding(.vertical, 12)
    }

    private func paint(_ line: Line) -> Text {
        let s = line.src
        if line.fm {
            if s == "---" { return Text(s).foregroundColor(tk.amberText) }
            if let m = s.range(of: #"^(\s*-?\s*)([\w-]+):(.*)$"#, options: .regularExpression) {
                _ = m
                // split manually: leading, key, colon, value
                let nsr = s as NSString
                if let rx = try? NSRegularExpression(pattern: #"^(\s*-?\s*)([\w-]+):(.*)$"#),
                   let mm = rx.firstMatch(in: s, range: NSRange(location: 0, length: nsr.length)) {
                    let lead = nsr.substring(with: mm.range(at: 1))
                    let key = nsr.substring(with: mm.range(at: 2))
                    let val = nsr.substring(with: mm.range(at: 3))
                    return Text(lead).foregroundColor(tk.fg2)
                        + Text(key).foregroundColor(tk.amberText)
                        + Text(":").foregroundColor(tk.fg3)
                        + Text(val).foregroundColor(Color(oklch: 0.78, 0.14, 130))
                }
            }
            return Text(s).foregroundColor(tk.fg2)
        }
        if s.hasPrefix("#") { return Text(s).fontWeight(.semibold).foregroundColor(tk.fg) }
        return inline(s)
    }

    // Paint `code`, $VAR, **bold** inline tokens.
    private func inline(_ s: String) -> Text {
        var result = Text("")
        let chars = Array(s)
        var i = 0
        var plain = ""
        func flush() { if !plain.isEmpty { result = result + Text(plain).foregroundColor(tk.fg2); plain = "" } }
        while i < chars.count {
            if chars[i] == "`", let end = nextIndex(chars, after: i, of: "`") {
                flush()
                result = result + Text(String(chars[i...end])).foregroundColor(Color(oklch: 0.78, 0.14, 130))
                i = end + 1
            } else if chars[i] == "*", i + 1 < chars.count, chars[i + 1] == "*",
                      let end = nextDoubleStar(chars, after: i + 2) {
                flush()
                result = result + Text(String(chars[(i + 2)..<end])).fontWeight(.semibold).foregroundColor(tk.fg)
                i = end + 2
            } else if chars[i] == "$" {
                flush()
                var j = i + 1
                while j < chars.count, chars[j].isUppercase || chars[j] == "_" { j += 1 }
                result = result + Text(String(chars[i..<j])).foregroundColor(tk.amberText)
                i = j
            } else {
                plain.append(chars[i]); i += 1
            }
        }
        flush()
        return result
    }

    private func nextIndex(_ c: [Character], after: Int, of ch: Character) -> Int? {
        var i = after + 1
        while i < c.count { if c[i] == ch { return i }; i += 1 }
        return nil
    }
    private func nextDoubleStar(_ c: [Character], after: Int) -> Int? {
        var i = after
        while i + 1 < c.count { if c[i] == "*" && c[i + 1] == "*" { return i }; i += 1 }
        return nil
    }
}
