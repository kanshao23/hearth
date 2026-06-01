import SwiftUI

struct Messages: View {
    @ObservedObject var st: MainWindowState
    @Environment(\.tk) private var tk

    private func toolOpen(_ id: String) -> Bool { st.openTool == id }
    private func toggle(_ id: String) { st.openTool = st.openTool == id ? nil : id }
    private func mono(_ s: String) -> Text { Text(s).font(F.mono(13.5)) }

    var body: some View {
        if st.hasCheckIn { checkInScenario } else { authScenario }
    }

    // marble RFC — agent waiting on a decision
    private var checkInScenario: some View {
        VStack(alignment: .leading, spacing: 0) {
            MsgWrap(role: "user", time: "13:08") {
                Text("Port ") + mono("mb serve") + Text(" from blocking tokio sync to async-std. Document the migration as an RFC under ") + mono("docs/rfcs/") + Text(". Don't actually swap the deps until I sign off on the RFC.")
            }
            ToolCall(name: "grep",
                     summary: AnyView(Text("find blocking call sites — ") + mono12("tokio::sync::*::blocking") + Text(", ") + mono12(".lock()") + Text(", ") + mono12("spawn_blocking")),
                     meta: AnyView(Text("22 matches across 9 files · 180ms")),
                     status: "done", isOpen: false, onToggle: {}) { EmptyView() }
            MsgWrap(role: "assistant", model: "sonnet-4.5", time: "13:12") {
                Text("Audit done. 22 blocking call-sites across 9 files; 3 of them are in ") + mono("tests/") + Text(" and don't need migration. I started drafting the RFC and ran into a real ambiguity I'd rather you decide on before I write more.")
            }
            CheckInBubble(
                question: AnyView(Text("The current `mb serve` exposes a synchronous `cancel()` method on the handle returned to embedders. Should the new async-std version keep that API, or break it?")),
                context: AnyView(Text("Keeping it forces a hidden `block_on` inside the cancel path (mild perf hit, no behavior change). Breaking it means embedders need to `.await` the cancel — cleaner but every downstream crate touches it.")),
                options: [("Keep sync cancel (compat)", true), ("Break to async cancel", false), ("Both — feature-gate", false)])
                .padding(.horizontal, 0)
        }
    }

    // auth → JWT — streaming + foldable tool calls + queued steering
    private var authScenario: some View {
        VStack(alignment: .leading, spacing: 0) {
            MsgWrap(role: "user", time: "13:24") {
                Text("Migrate the auth module from cookie sessions to JWT. Refresh token in Keychain. Don't break in-flight sessions — leave a 14d shim on the old path. Commit each step to a shadow branch and run the test target after.")
            }
            ToolCall(name: "grep",
                     summary: AnyView(Text("scan repo for ") + mono12("\"cookie\"") + Text(", ") + mono12("\"Set-Cookie\"") + Text(", ") + mono12("\"refreshCookie\"")),
                     meta: AnyView(Text("3 patterns · 38 matches across 12 files · 240ms")),
                     status: "done", isOpen: toolOpen("grep"), onToggle: { toggle("grep") }) {
                CodeBlock(lines: grepLines)
            }
            MsgWrap(role: "assistant", model: "opus-4.7", time: "13:25") { planBody }
            CheckInBubble(answered: true, time: "3m ago",
                          question: AnyView(Text("The `/session` endpoint still has 3 client callers in the iOS app. Keep a compatibility shim for some window, or break it now?")),
                          answer: "Keep 14-day shim")
                .padding(.horizontal, 0)
            ToolCall(name: "apply_patch",
                     summary: AnyView(mono12("Sources/Auth/AuthService.swift") + Text(" · search-replace")),
                     meta: AnyView(Text("1 of 2 hunks · ") + Text("+8").foregroundColor(tk.addFg) + Text(" −6").foregroundColor(tk.delFg) + Text(" · awaiting approval")),
                     status: "approval", isOpen: toolOpen("apply_patch"), onToggle: { toggle("apply_patch") }) {
                ScrollView { DiffView(rows: Mock.authDiff) }
                    .frame(maxHeight: 260)
                    .background(tk.bg2)
                    .overlay(RoundedRectangle(cornerRadius: Radius.r2).stroke(tk.line, lineWidth: 1))
                    .clipShape(RoundedRectangle(cornerRadius: Radius.r2))
            }
            ToolCall(name: "exec",
                     summary: AnyView(mono12("git checkout -b hearth/refactor-auth-jwt")),
                     meta: AnyView(Text("exit 0 · 80ms · sandbox: workspace-write")),
                     status: "done", isOpen: toolOpen("exec"), onToggle: { toggle("exec") }) {
                CodeBlock(lines: execLines)
            }
            MsgWrap(role: "assistant", model: "opus-4.7", time: "now") {
                let shown = String(MainWindowState.streamText.prefix(st.streamLen))
                HStack(alignment: .bottom, spacing: 0) {
                    Text(shown)
                    if st.streaming { Caret() }
                }
            }
            QueuedMessage(text: "Skip the 14d shim actually — the iOS app already shipped the JWT route last week.")
        }
    }

    private func mono12(_ s: String) -> Text { Text(s).font(F.mono(12)).foregroundColor(tk.fg) }

    private var planBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            (Text("Here's the plan. Three patch steps + tests; shadow branch is ") + Text("hearth/refactor-auth-jwt").font(F.mono(12)))
                .fixedSize(horizontal: false, vertical: true)
            VStack(alignment: .leading, spacing: 6) {
                planItem("1.", AnyView(Text("AuthService").bold() + Text(" — swap ") + mono13("signInCookie") + Text(" → ") + mono13("signInJWT") + Text("; refresh tokens to Keychain.")))
                planItem("2.", AnyView(Text("AuthRouter").bold() + Text(" — new ") + mono13("/token/refresh") + Text("; old ") + mono13("/session") + Text(" returns JWT, deprecated header set, 14d cookie shim.")))
                planItem("3.", AnyView(Text("HTTPClient").bold() + Text(" — Bearer header replaces Cookie; legacy cookie still attached if scope-marked.")))
            }
            .padding(.vertical, 10)
        }
    }

    private func mono13(_ s: String) -> Text { Text(s).font(F.mono(13.5)) }

    private func planItem(_ n: String, _ body: AnyView) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(n).foregroundStyle(tk.fg2)
            body
        }
    }

    private var grepLines: [[CodeSpan]] {
        [
            [CodeSpan("// 38 matches", .c)],
            [CodeSpan("Sources/Auth/AuthService.swift  ", .p), CodeSpan("(11) "), CodeSpan("// includes signInCookie, persist", .c)],
            [CodeSpan("Sources/Auth/AuthRouter.swift   ", .p), CodeSpan("(7)  "), CodeSpan("// /session, /logout routes", .c)],
            [CodeSpan("Sources/Net/HTTPClient.swift    ", .p), CodeSpan("(4)  "), CodeSpan("// adds Cookie header", .c)],
            [CodeSpan("Tests/Auth/AuthServiceTests.swift", .p), CodeSpan("(8)")],
            [CodeSpan("Tests/E2E/SignInE2ETests.swift  ", .p), CodeSpan("(5)")],
            [CodeSpan("…", .p)],
        ]
    }

    private var execLines: [[CodeSpan]] {
        [
            [CodeSpan("$ git checkout -b hearth/refactor-auth-jwt", .c)],
            [CodeSpan("Switched to a new branch 'hearth/refactor-auth-jwt'")],
        ]
    }
}
