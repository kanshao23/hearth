import SwiftUI

struct MsgWrap<Content: View>: View {
    let role: String   // user | assistant
    var model: String? = nil
    let time: String
    @ViewBuilder var content: () -> Content
    @Environment(\.tk) private var tk

    private var isUser: Bool { role == "user" }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                avatar
                Text(isUser ? "Jen Lim" : "Hearth").font(F.sans(12, .semibold)).foregroundStyle(tk.fg)
                if let model { Text("· \(model)").font(F.mono(11)).foregroundStyle(tk.fg3) }
                Spacer()
                Text(time).font(F.mono(11)).foregroundStyle(tk.fg4)
            }
            content()
                .font(F.sans(13.5)).foregroundStyle(tk.fg)
                .lineSpacing(13.5 * 0.55)
                .padding(.leading, 26)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 24).padding(.bottom, 18)
    }

    private var avatar: some View {
        Group {
            if isUser {
                Text("JL").font(F.mono(10, .bold)).foregroundStyle(tk.fg2)
            } else {
                LogoMark(size: 11).foregroundStyle(tk.onAmber)
            }
        }
        .frame(width: 18, height: 18)
        .background(isUser ? tk.surface3 : tk.amber)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

struct ToolCall<Content: View>: View {
    let name: String
    let summary: AnyView
    let meta: AnyView
    let status: String   // done | active | approval | failed
    let isOpen: Bool
    let onToggle: () -> Void
    @ViewBuilder var content: () -> Content
    @Environment(\.tk) private var tk

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onToggle) {
                HStack(spacing: 10) {
                    HIcon(Ico.chevron, size: 10).foregroundStyle(tk.fg3)
                        .rotationEffect(.degrees(isOpen ? 90 : 0))
                    HStack(spacing: 8) {
                        Text(name).font(F.mono(12, .medium)).foregroundStyle(tk.amberText)
                        summary.font(F.sans(12.5)).foregroundStyle(tk.fg2).lineLimit(1)
                    }
                    Spacer()
                    meta.font(F.sans(11)).foregroundStyle(tk.fg3)
                    statusBit
                }
                .padding(.horizontal, 10).padding(.vertical, 7)
                .background(tk.surface)
                .overlay(RoundedRectangle(cornerRadius: Radius.r2).stroke(isOpen ? tk.lineStrong : tk.line, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: Radius.r2))
            }
            .buttonStyle(.plain)
            if isOpen { content().padding(.top, 10).padding(.leading, 22) }
        }
        .padding(.horizontal, 24).padding(.bottom, 12)
    }

    @ViewBuilder private var statusBit: some View {
        switch status {
        case "active": Spinner(size: 11)
        case "approval": Chip(.warn, hPad: 6) { Text("approval") }
        case "failed": Chip(.danger) { Text("failed") }
        default: HIcon(Ico.check, size: 11).foregroundStyle(tk.ok)
        }
    }
}

struct CheckInBubble: View {
    var answered = false
    var time: String = ""
    let question: AnyView
    var context: AnyView? = nil
    var options: [(label: String, primary: Bool)] = []
    var answer: String = ""
    @Environment(\.tk) private var tk

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Text("?").font(F.mono(11, .bold)).foregroundStyle(answered ? tk.fg3 : tk.onAmber)
                    .frame(width: 18, height: 18)
                    .background(answered ? tk.surface3 : tk.amber)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                Text("Hearth \(answered ? "needed" : "needs") a decision")
                    .font(F.sans(12, .semibold)).foregroundStyle(answered ? tk.fg2 : tk.amberText)
                if answered { Text("· resolved \(time)").font(F.sans(11)).foregroundStyle(tk.fg3) }
                Spacer()
                if !answered { Chip(.warn) { Text("session paused") } }
            }
            question.font(F.sans(13.5, answered ? .regular : .medium)).foregroundStyle(tk.fg)
                .padding(.leading, 26).padding(.top, 4).fixedSize(horizontal: false, vertical: true)
            if let context {
                context.font(F.sans(12.5)).foregroundStyle(tk.fg2)
                    .padding(.leading, 26).padding(.top, 6).fixedSize(horizontal: false, vertical: true)
            }
            if answered { answeredRow } else { optionsRow }
        }
        .padding(14)
        .background(answered ? tk.surface : tk.amberBg)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(answered ? tk.line : tk.amberLine, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 24).padding(.bottom, 18)
    }

    private var answeredRow: some View {
        HStack(spacing: 8) {
            HIcon(Ico.check, size: 11).foregroundStyle(tk.ok)
            Text("You chose").font(F.sans(12.5)).foregroundStyle(tk.fg3)
            Text(answer).font(F.sans(12.5, .medium)).foregroundStyle(tk.fg)
            Spacer()
            HButton(kind: .ghost, hPad: 8, vPad: 2, fontSize: 11) { HStack(spacing: 4) { HIcon(Ico.undo, size: 10); Text("Change") } }
        }
        .padding(.leading, 26).padding(.top, 10)
    }

    private var optionsRow: some View {
        HStack(spacing: 6) {
            ForEach(options.indices, id: \.self) { i in
                HButton(kind: options[i].primary ? .primary : .normal, fontSize: 12.5) { Text(options[i].label) }
            }
            Spacer()
            HButton(kind: .ghost, hPad: 10, fontSize: 12.5) { Text("Let me explain…") }
        }
        .padding(.leading, 26).padding(.top, 12)
    }
}

struct QueuedMessage: View {
    let text: String
    @Environment(\.tk) private var tk

    var body: some View {
        HStack(spacing: 10) {
            HIcon(Ico.bolt, size: 11).foregroundStyle(tk.amberText)
            VStack(alignment: .leading, spacing: 2) {
                Text("QUEUED · INJECTS AFTER CURRENT STEP").font(F.sans(10.5, .semibold)).tracking(0.5).foregroundStyle(tk.fg3)
                Text("\"\(text)\"").font(F.sans(12.5)).italic().foregroundStyle(tk.fg2)
            }
            Spacer()
            HButton(kind: .ghost, hPad: 8, vPad: 2, fontSize: 11) { HStack(spacing: 4) { HIcon(Ico.x, size: 10); Text("Cancel") } }
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .overlay(RoundedRectangle(cornerRadius: Radius.r2).strokeBorder(tk.lineStrong, style: StrokeStyle(lineWidth: 1, dash: [3, 3])))
        .clipShape(RoundedRectangle(cornerRadius: Radius.r2))
        .padding(.leading, 26).padding(.horizontal, 24).padding(.bottom, 16)
    }
}
