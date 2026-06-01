import SwiftUI

// Screen 3 — Approval sheet: native macOS sheet over the (dimmed) main window.
struct ApprovalScreen: View {
    @Environment(\.tk) private var tk

    var body: some View {
        ZStack(alignment: .top) {
            tk.bg2
            VStack(spacing: 0) {
                titlebar
                ZStack {
                    behindWindow
                    Color.black.opacity(0.5)
                }
            }
            sheet.padding(.horizontal, 60).padding(.top, 30)
        }
        .frame(width: 660, height: 760)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(tk.line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var titlebar: some View {
        ZStack {
            HStack { TrafficLights(); Spacer() }
            Text("Hearth — Refactor auth → JWT").font(F.sans(12, .medium)).foregroundStyle(tk.fg2)
        }
        .frame(height: 36)
        .background(TitlebarBackground())
        .overlay(alignment: .bottom) { tk.line.frame(height: 1) }
    }

    private var behindWindow: some View {
        HStack(spacing: 0) {
            tk.surface.frame(width: 160).overlay(alignment: .trailing) { tk.line.frame(width: 1) }
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4).fill(tk.surface2).frame(width: 120, height: 12)
                RoundedRectangle(cornerRadius: 4).fill(tk.surface2).frame(width: 260, height: 8)
                RoundedRectangle(cornerRadius: 4).fill(tk.surface2).frame(width: 200, height: 8)
                Spacer()
            }
            .padding(14).frame(maxWidth: .infinity, alignment: .topLeading)
            tk.surface.frame(width: 220).overlay(alignment: .leading) { tk.line.frame(width: 1) }
        }
        .opacity(0.45)
    }

    private var sheet: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            argsSection
            diffSection
            buttons
        }
        .background(tk.surface)
        .overlay(
            UnevenRoundedRectangle(bottomLeadingRadius: 12, bottomTrailingRadius: 12)
                .stroke(tk.line2, lineWidth: 1)
        )
        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 12, bottomTrailingRadius: 12))
        .shadow(color: .black.opacity(0.6), radius: 30, y: 24)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 14) {
            HIcon(Ico.shield, size: 18).foregroundStyle(tk.amberText)
                .frame(width: 38, height: 38)
                .background(tk.amberBg)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(tk.amberLine, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 4) {
                (Text("Hearth wants to run ").font(F.sans(15, .semibold))
                 + Text("patch").font(F.mono(15, .semibold))
                 + Text(" on 2 files").font(F.sans(15, .semibold)))
                    .foregroundStyle(tk.fg)
                (Text("session ").foregroundColor(tk.fg3) + Text("Refactor auth → JWT  ").foregroundColor(tk.fg2)
                 + Text("· sandbox ").foregroundColor(tk.fg3) + Text("workspace-write  ").foregroundColor(tk.fg2)
                 + Text("· tool ").foregroundColor(tk.fg3) + Text("builtin").foregroundColor(tk.fg2))
                    .font(F.sans(12.5))
            }
            Spacer()
            Chip(.warn) { Text("requires approval") }
        }
        .padding(.horizontal, 22).padding(.top, 20).padding(.bottom, 12)
    }

    private var argsSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionLabel("Arguments")
            CodeBlock(lines: argLines, fontSize: 11.5)
        }
        .padding(.horizontal, 22).padding(.bottom, 14)
    }

    private var argLines: [[CodeSpan]] {
        [
            [CodeSpan("{", .p)],
            [CodeSpan("  "), CodeSpan("\"files\"", .k), CodeSpan(": ", .p), CodeSpan("[", .p),
             CodeSpan("\"Sources/Auth/AuthService.swift\"", .s), CodeSpan(", ", .p),
             CodeSpan("\"Sources/Auth/AuthRouter.swift\"", .s), CodeSpan("],", .p)],
            [CodeSpan("  "), CodeSpan("\"strategy\"", .k), CodeSpan(": ", .p), CodeSpan("\"search-replace\",", .s)],
            [CodeSpan("  "), CodeSpan("\"reflection\"", .k), CodeSpan(": ", .p), CodeSpan("3", .n), CodeSpan(",", .p)],
            [CodeSpan("  "), CodeSpan("\"shadow_branch\"", .k), CodeSpan(": ", .p), CodeSpan("\"hearth/refactor-auth-jwt\"", .s)],
            [CodeSpan("}", .p)],
        ]
    }

    private var diffSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                (Text("DIFF PREVIEW · ").font(F.sans(10.5, .semibold)).tracking(0.5).foregroundColor(tk.fg3)
                 + Text("Sources/Auth/AuthService.swift").font(F.mono(10.5)).foregroundColor(tk.fg2))
                Spacer()
                (Text("+8").foregroundColor(tk.addFg) + Text(" −6").foregroundColor(tk.delFg)
                 + Text(" · 1 of 2 files").foregroundColor(tk.fg3)).font(F.sans(11))
            }
            ScrollView { DiffView(rows: Mock.authDiff) }
                .frame(maxHeight: 240)
                .background(tk.bg2)
                .overlay(RoundedRectangle(cornerRadius: Radius.r2).stroke(tk.line, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: Radius.r2))
        }
        .padding(.horizontal, 22).padding(.bottom, 16)
    }

    private var buttons: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 3).stroke(tk.lineStrong, lineWidth: 1)
                    .background(tk.bg).frame(width: 14, height: 14)
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                (Text("Remember decision for files under ").foregroundColor(tk.fg2)
                 + Text("~/code/orchid/Sources/Auth/").font(F.mono(12)).foregroundColor(tk.fg))
                    .font(F.sans(12))
            }
            Spacer()
            HButton { Text("Deny") }
            HButton { Text("Always allow in this dir") }
            HButton { Text("Allow for session") }
            HButton(kind: .primary, hPad: 14) { Text("Allow once") }
        }
        .padding(.horizontal, 22).padding(.vertical, 14)
        .background(tk.fg.opacity(0.015))
        .overlay(alignment: .top) { tk.line.frame(height: 1) }
    }

    private func sectionLabel(_ s: String) -> some View {
        Text(s.uppercased()).font(F.sans(10.5, .semibold)).tracking(0.5).foregroundStyle(tk.fg3)
    }
}
