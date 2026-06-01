import SwiftUI

struct SkillPreview: View {
    @Environment(\.tk) private var tk

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            metaCard
            Text("Morning routine").font(F.sans(22, .semibold)).foregroundStyle(tk.fg).padding(.bottom, 12)
            (Text("Read all unread Gmail messages, summarize each, append summaries to ")
             + code("~/Documents/Notes/$DATE.md") + Text(", then send a macOS notification."))
                .font(F.sans(14)).foregroundStyle(tk.fg2).lineSpacing(4).fixedSize(horizontal: false, vertical: true)

            h2("Steps")
            VStack(alignment: .leading, spacing: 5) {
                item("1.", Text("Fetch unread Gmail via Mac bridge (max 10)."))
                item("2.", Text("For each message:"))
                VStack(alignment: .leading, spacing: 3) {
                    bullet(Text("Summarize subject + body in ") + Text("≤ 2 sentences").bold().foregroundColor(tk.fg) + Text("."))
                    bullet(Text("Note sender, time, link."))
                }.padding(.leading, 18)
                item("3.", Text("Append to ") + code("~/Documents/Notes/$DATE.md") + Text(" under heading ") + code("## Inbox · $DATE") + Text("."))
                item("4.", code("notification.show(\"Inbox digest\", \"$N messages summarized\")"))
            }

            h2("Rules")
            VStack(alignment: .leading, spacing: 5) {
                bullet(Text("Do ") + Text("not").bold().foregroundColor(tk.fg) + Text(" mark messages as read."))
                bullet(Text("Skip newsletters tagged ") + code("promotions") + Text("."))
                bullet(Text("If ") + code("$N == 0") + Text(", exit silently."))
            }
        }
        .frame(maxWidth: 520, alignment: .leading)
    }

    private var metaCard: some View {
        let g = GridItem(.flexible(), alignment: .topLeading)
        return LazyVGrid(columns: [g, g], alignment: .leading, spacing: 8) {
            metaItem("name", AnyView(Text("morning").font(F.mono(13, .semibold)).foregroundColor(tk.amberText)))
            metaItem("triggers", AnyView(HStack(spacing: 4) { Chip(.plain, mono: true) { Text("schedule") }; Chip(.plain, mono: true) { Text("manual") } }))
            metaItem("schedule", AnyView(Text("0 8 * * *").font(F.mono(12)).foregroundColor(tk.fg) + Text(" · every day at 8:00").foregroundColor(tk.fg3)))
            metaItem("sandbox", AnyView(HStack(spacing: 4) { Text("workspace-write").font(F.mono(12)).foregroundColor(tk.fg); Chip(.ok) { Text("auto-approve") } }))
        }
        .padding(12)
        .background(tk.amberBg)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(tk.amberLine, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.bottom, 20)
    }

    private func metaItem(_ label: String, _ value: AnyView) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label).font(F.sans(11.5)).foregroundStyle(tk.fg3)
            value.font(F.sans(11.5))
        }
    }

    private func h2(_ s: String) -> some View {
        Text(s.uppercased()).font(F.sans(14, .semibold)).tracking(0.6).foregroundStyle(tk.fg)
            .padding(.top, 20).padding(.bottom, 10)
    }
    private func item(_ n: String, _ t: Text) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text(n).foregroundStyle(tk.fg2)
            t.foregroundColor(tk.fg2).fixedSize(horizontal: false, vertical: true)
        }
        .font(F.sans(13.5))
    }
    private func bullet(_ t: Text) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text("•").foregroundStyle(tk.fg3)
            t.foregroundColor(tk.fg2).fixedSize(horizontal: false, vertical: true)
        }
        .font(F.sans(13.5))
    }
    private func code(_ s: String) -> Text { Text(s).font(F.mono(12)).foregroundColor(tk.fg) }
}
