import SwiftUI

enum BannerState { case question, approval, paused, done, failed, working, idle }

struct ActionBanner: View {
    let state: BannerState
    @ObservedObject var st: MainWindowState
    @Environment(\.tk) private var tk

    private func req() { st.approvalOpen = true }

    var body: some View {
        switch state {
        case .question:
            Banner(tone: .amber, icon: AnyView(Text("?").font(F.mono(14, .bold))),
                   title: AnyView(Text("Decision needed — keep ") + monoT("cancel()") + Text(" sync or break to async?")),
                   bodyView: AnyView(Text("Session paused mid-RFC. Hearth ran into a real ambiguity instead of guessing. Pick below or scroll to the bubble for full context.")),
                   sub: AnyView(Text("22 call-sites already audited · ") + monoT("sonnet-4.5") + Text(" · 22m so far")),
                   actions: AnyView(HStack(spacing: 8) {
                       HButton(kind: .primary, hPad: 14, fontSize: 13) { Text("Keep sync · compat") }
                       HButton(hPad: 14, fontSize: 13) { Text("Break to async") }
                       HButton(hPad: 14, fontSize: 13) { Text("Feature-gate both") }
                       HButton(kind: .ghost, hPad: 14, fontSize: 13) { HStack(spacing: 4) { HIcon(Ico.send, size: 11); Text("Reply with reasoning") } }
                   }))
        case .approval:
            Banner(tone: .amber, icon: AnyView(HIcon(Ico.shield, size: 16)),
                   title: AnyView(Text("Approve patch on ") + Text("2 files").bold()),
                   bodyView: AnyView(VStack(alignment: .leading, spacing: 0) {
                       fileLine("Sources/Auth/AuthService.swift", 8, 6)
                       fileLine("Sources/Auth/AuthRouter.swift", 12, 3)
                   }),
                   sub: AnyView(Text("workspace-write · shadow branch is set · revertable in one click")),
                   actions: AnyView(HStack(spacing: 8) {
                       HButton(kind: .primary, hPad: 14, fontSize: 13, action: req) { HStack(spacing: 4) { HIcon(Ico.check, size: 12); Text("Allow once") } }
                       HButton(hPad: 14, fontSize: 13) { Text("Always in dir") }
                       HButton(kind: .ghost, hPad: 14, fontSize: 13) { Text("Deny") }
                       Spacer()
                       HButton(kind: .ghost, hPad: 10, fontSize: 11.5, action: req) { Text("Review diff →") }
                   }))
        case .paused:
            Banner(tone: .warn, icon: AnyView(HIcon(Ico.pause, size: 16)),
                   title: AnyView(Text("Paused · needs Full Disk Access")),
                   bodyView: AnyView(Text("The ") + monoT("extract_pdf") + Text(" tool tried to read ") + monoT("~/Downloads") + Text(" but the sandbox profile doesn't grant it. Grant once, or revise the plan.")),
                   sub: nil,
                   actions: AnyView(HStack(spacing: 8) {
                       HButton(kind: .primary, hPad: 14, fontSize: 13) { Text("Grant Full Disk Access") }
                       HButton(hPad: 14, fontSize: 13) { Text("Revise plan") }
                       HButton(kind: .ghost, hPad: 14, fontSize: 13) { Text("Stop session") }
                   }))
        case .done:
            Banner(tone: .ok, icon: AnyView(HIcon(Ico.check, size: 16)),
                   title: AnyView(Text("Refactor auth → JWT ") + Text("complete").foregroundColor(tk.fg3)),
                   bodyView: AnyView(Text("12 files changed · 218 +/41 − · 4 tests passing · 1h 22m")),
                   sub: AnyView(Text("shadow branch ") + monoT("hearth/refactor-auth-jwt") + Text(" ready to merge")),
                   actions: AnyView(HStack(spacing: 8) {
                       HButton(kind: .primary, hPad: 14, fontSize: 13) { HStack(spacing: 4) { HIcon(Ico.branch, size: 12); Text("Merge to main") } }
                       HButton(hPad: 14, fontSize: 13) { Text("Review diff") }
                       HButton(kind: .ghost, hPad: 14, fontSize: 13) { Text("Keep shadow") }
                   }))
        case .failed:
            Banner(tone: .danger, icon: AnyView(HIcon(Ico.x, size: 16)),
                   title: AnyView(Text("Patch failed after 3 reflection rounds")),
                   bodyView: AnyView(monoT("AuthRouter.swift") + Text(" diverged from the model's expected pre-state. No partial writes — shadow branch is unchanged.")),
                   sub: nil,
                   actions: AnyView(HStack(spacing: 8) {
                       HButton(kind: .primary, hPad: 14, fontSize: 13) { Text("Open mismatch") }
                       HButton(hPad: 14, fontSize: 13) { Text("Retry with re-scan") }
                       HButton(kind: .ghost, hPad: 14, fontSize: 13) { Text("Edit prompt") }
                   }))
        default:
            Banner(tone: .neutral, icon: AnyView(Spinner(size: 14)), compact: true,
                   title: AnyView(Text("Applying patches… ") + Text("step 3 of 4").font(F.sans(14)).foregroundColor(tk.fg3)),
                   bodyView: AnyView(Text("Editing ") + monoT("Sources/Auth/AuthService.swift") + Text(" · est. ~40s left")),
                   sub: AnyView(monoT("opus-4.7") + Text(" · workspace-write · 12.4k / 200k ctx")),
                   actions: AnyView(HStack(spacing: 8) {
                       HButton(hPad: 14, fontSize: 13) { HStack(spacing: 4) { HIcon(Ico.pause, size: 11); Text("Pause") } }
                       HButton(kind: .ghost, hPad: 14, fontSize: 13) { HStack(spacing: 4) { HIcon(Ico.x, size: 11); Text("Stop") } }
                   }))
        }
    }

    private func monoT(_ s: String) -> Text { Text(s).font(F.mono(13)) }

    private func fileLine(_ path: String, _ add: Int, _ del: Int) -> some View {
        HStack(spacing: 8) {
            HIcon(Ico.file, size: 11).foregroundStyle(tk.fg3)
            Text(path).font(F.mono(12.5)).foregroundStyle(tk.fg).frame(maxWidth: .infinity, alignment: .leading)
            (Text("+\(add)").foregroundColor(tk.addFg) + Text(" −\(del)").foregroundColor(tk.delFg)).font(F.mono(11.5))
        }
        .padding(.vertical, 4)
    }
}

private struct Banner: View {
    enum Tone { case amber, ok, warn, danger, neutral }
    let tone: Tone
    let icon: AnyView
    var compact = false
    let title: AnyView
    var bodyView: AnyView? = nil
    var sub: AnyView? = nil
    let actions: AnyView
    @Environment(\.tk) private var tk

    var body0: (bg: Color, bd: Color, fg: Color) {
        switch tone {
        case .amber: return (tk.amberBg, tk.amberLine, tk.amberText)
        case .ok: return (Sem.okBannerBg, Sem.okChipLine, Sem.okChipFg)
        case .warn: return (Sem.warnBannerBg, Sem.warnChipLine, Sem.warnChipFg)
        case .danger: return (Sem.dangerBannerBg, Sem.dangerChipLine, Sem.dangerBannerFg)
        case .neutral: return (tk.bg2, tk.line, tk.fg2)
        }
    }

    var body: some View {
        let t = body0
        HStack(alignment: .top, spacing: 14) {
            icon.foregroundStyle(t.fg)
                .frame(width: 28, height: 28)
                .background(Color.black.opacity(0.25))
                .clipShape(RoundedRectangle(cornerRadius: 7))
            VStack(alignment: .leading, spacing: 0) {
                title.font(F.sans(15.5, .semibold)).foregroundStyle(tk.fg)
                    .fixedSize(horizontal: false, vertical: true)
                if let bodyView { bodyView.font(F.sans(13)).foregroundStyle(tk.fg2).padding(.top, 6)
                    .fixedSize(horizontal: false, vertical: true) }
                if let sub { sub.font(F.sans(11.5)).foregroundStyle(tk.fg3).padding(.top, compact ? 6 : 10) }
                actions.padding(.top, compact ? 10 : 14)
            }
        }
        .padding(.horizontal, compact ? 18 : 20).padding(.vertical, compact ? 14 : 18)
        .background(t.bg)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(t.bd, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 32).padding(.top, 20)
    }
}
