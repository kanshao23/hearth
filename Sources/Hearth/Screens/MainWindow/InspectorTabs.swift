import SwiftUI

private func tabLabel(_ s: String) -> Text {
    Text(s.uppercased()).font(F.sans(10.5, .semibold)).tracking(0.5)
}

struct DiffTab: View {
    @Environment(\.tk) private var tk
    private let files: [(p: String, a: Int, d: Int, sel: Bool, sub: String?)] = [
        ("Sources/Auth/AuthService.swift", 8, 6, true, nil),
        ("Sources/Auth/AuthRouter.swift", 12, 3, false, nil),
        ("Sources/Net/HTTPClient.swift", 4, 4, false, "pending"),
    ]
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            (tabLabel("Shadow branch · ").foregroundColor(tk.fg3) + Text("hearth/refactor-auth-jwt").font(F.mono(10.5)).foregroundColor(tk.fg2))
                .padding(.horizontal, 6).padding(.top, 4).padding(.bottom, 8)
            ForEach(files.indices, id: \.self) { fileRow(files[$0]) }
            tabLabel("Selected · AuthService.swift").foregroundStyle(tk.fg3)
                .padding(.horizontal, 6).padding(.top, 12).padding(.bottom, 8)
            DiffView(rows: Mock.authDiff)
                .background(tk.bg2)
                .overlay(RoundedRectangle(cornerRadius: Radius.r2).stroke(tk.line, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: Radius.r2))
            HStack(spacing: 6) {
                HButton(hPad: 10, vPad: 5) { HStack(spacing: 4) { HIcon(Ico.undo, size: 11); Text("Revert hunk") } }.frame(maxWidth: .infinity)
                HButton(hPad: 10, vPad: 5) { Text("Open in editor") }.frame(maxWidth: .infinity)
            }
            .padding(.top, 10)
        }
        .padding(10)
    }
    private func fileRow(_ f: (p: String, a: Int, d: Int, sel: Bool, sub: String?)) -> some View {
        HStack(spacing: 8) {
            HIcon(Ico.file, size: 11).foregroundStyle(f.sel ? tk.amberText : tk.fg3)
            VStack(alignment: .leading, spacing: 0) {
                Text(f.p).font(F.mono(11.5)).foregroundStyle(f.sel ? tk.amberText : tk.fg).lineLimit(1).truncationMode(.head)
                if let sub = f.sub { Text(sub).font(F.sans(10.5)).foregroundStyle(tk.fg3) }
            }
            Spacer()
            (Text("+\(f.a)").foregroundColor(tk.addFg) + Text(" −\(f.d)").foregroundColor(tk.delFg)).font(F.mono(11))
        }
        .padding(.horizontal, 8).padding(.vertical, 7)
        .background(f.sel ? tk.amberBg : .clear)
        .overlay(RoundedRectangle(cornerRadius: 5).stroke(f.sel ? tk.amberLine : .clear, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .padding(.bottom, 2)
    }
}

struct ApprovalTab: View {
    @Environment(\.tk) private var tk
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            tabLabel("Pending · 1").foregroundStyle(tk.fg3).padding(.horizontal, 6).padding(.top, 4).padding(.bottom, 8)
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 6) {
                    HIcon(Ico.shield, size: 12).foregroundStyle(tk.amberText)
                    Text("apply_patch").font(F.mono(12)).foregroundStyle(tk.amberText)
                    Spacer()
                    Chip(.warn) { Text("blocking") }
                }
                (Text("Patch 2 files in ") + Text("Sources/Auth/").font(F.mono(12)) + Text(". Shadow branch is set."))
                    .font(F.sans(12)).foregroundStyle(tk.fg).padding(.vertical, 8)
                HStack(spacing: 6) {
                    HButton(kind: .primary, hPad: 8, vPad: 4, fontSize: 11) { Text("Allow once") }
                    HButton(hPad: 8, vPad: 4, fontSize: 11) { Text("Always in dir") }
                    HButton(kind: .ghost, hPad: 8, vPad: 4, fontSize: 11) { Text("Deny") }
                }
            }
            .padding(10)
            .background(tk.bg2)
            .overlay(RoundedRectangle(cornerRadius: Radius.r2).stroke(tk.amberLine, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: Radius.r2))

            tabLabel("Granted this session").foregroundStyle(tk.fg3).padding(.horizontal, 6).padding(.top, 14).padding(.bottom, 8)
            ForEach([("exec", "git checkout, git commit", "session"), ("grep", "all paths", "always · ~/code/orchid"), ("read_file", "all paths", "always · ~/code/orchid")], id: \.0) { g in
                HStack(spacing: 8) {
                    HIcon(Ico.check, size: 11).foregroundStyle(tk.ok)
                    (Text(g.0).font(F.mono(12)).foregroundColor(tk.fg) + Text("  \(g.1)").font(F.sans(11)).foregroundColor(tk.fg3))
                    Spacer()
                    Text(g.2).font(F.sans(10.5)).foregroundStyle(tk.fg3)
                }
                .padding(.horizontal, 8).padding(.vertical, 6)
            }
        }
        .padding(10)
    }
}

struct EventsTab: View {
    @Environment(\.tk) private var tk
    private let evts: [(t: String, l: String, c: String, m: String, amber: Bool)] = [
        ("13:32:14", "INFO", "tool/exec", "git status → clean", false),
        ("13:32:11", "INFO", "patch", "AuthService.swift: 2 hunks queued", true),
        ("13:32:09", "WARN", "approval", "apply_patch awaiting decision", true),
        ("13:31:58", "INFO", "model", "opus-4.7 · 412 tok in · 1.2s", false),
        ("13:31:57", "DEBUG", "sandbox", "seatbelt profile workspace-write loaded", false),
        ("13:31:55", "INFO", "tool/grep", "38 matches · 12 files · 240ms", false),
        ("13:31:42", "INFO", "session", "auth.patch forked from auth.plan", false),
        ("13:30:11", "INFO", "repo", "tree-sitter index · 488 defs / 1.2s", false),
        ("13:30:02", "INFO", "session", "started · Refactor auth → JWT", false),
    ]
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Text("filter…").font(F.sans(11.5)).foregroundStyle(tk.fg4)
                    .padding(.horizontal, 8).padding(.vertical, 4).frame(maxWidth: .infinity, alignment: .leading)
                    .background(tk.bg2)
                    .overlay(RoundedRectangle(cornerRadius: Radius.r2).stroke(tk.line2, lineWidth: 1))
                    .clipShape(RoundedRectangle(cornerRadius: Radius.r2))
                HButton(kind: .ghost, hPad: 8, vPad: 3, fontSize: 11) { Text("level: all") }
            }
            .padding(.bottom, 8)
            VStack(spacing: 0) {
                ForEach(evts.indices, id: \.self) { evtRow(evts[$0]) }
            }
        }
        .padding(10)
    }
    private func evtRow(_ e: (t: String, l: String, c: String, m: String, amber: Bool)) -> some View {
        HStack(spacing: 6) {
            Text(e.t).foregroundStyle(tk.fg4).frame(width: 58, alignment: .leading)
            Text(e.l).foregroundStyle(levelColor(e.l)).frame(width: 38, alignment: .leading)
            Text(e.c).foregroundStyle(tk.amberText).frame(width: 60, alignment: .leading)
            Text(e.m).foregroundStyle(e.amber ? tk.amberText : tk.fg2).frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(F.mono(11))
        .padding(.horizontal, 4).padding(.vertical, 3)
        .background(e.amber ? tk.amberBg : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 3))
    }
    private func levelColor(_ l: String) -> Color {
        switch l { case "WARN": return tk.warn; case "ERROR": return tk.danger; case "DEBUG": return tk.fg4; default: return tk.info }
    }
}

struct RepoMapTab: View {
    @Environment(\.tk) private var tk
    private let files: [(p: String, s: String, r: Double)] = [
        ("AuthService.swift", ".signInJWT  .refresh  .invalidate", 1.00),
        ("AuthRouter.swift", ".token       .session   .logout", 0.81),
        ("Keychain.swift", ".store       .load      .delete", 0.72),
        ("HTTPClient.swift", ".send        .authHeader", 0.64),
        ("Credentials.swift", ".refresh     .access", 0.51),
        ("SignInE2ETests.swift", ".testRefresh ×3", 0.42),
    ]
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            tabLabel("Top-ranked context · PageRank").foregroundStyle(tk.fg3)
                .padding(.horizontal, 6).padding(.top, 4).padding(.bottom, 8)
            (Text("488 defs / 712 refs indexed · budget ").foregroundColor(tk.fg3)
             + Text("32k tok").font(F.mono(11)).foregroundColor(tk.fg2)
             + Text(" · using ").foregroundColor(tk.fg3)
             + Text("11.4k").font(F.mono(11)).foregroundColor(tk.fg2))
                .font(F.sans(11)).padding(.horizontal, 6).padding(.bottom, 10)
            ForEach(files.indices, id: \.self) { fileRow(files[$0]) }
        }
        .padding(10)
    }
    private func fileRow(_ f: (p: String, s: String, r: Double)) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(f.p).font(F.mono(12)).foregroundStyle(tk.fg)
                Spacer()
                Text(String(format: "%.2f", f.r)).font(F.mono(10.5)).foregroundStyle(tk.fg3)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    tk.surface2
                    tk.amber.frame(width: geo.size.width * f.r)
                }
            }
            .frame(height: 3).clipShape(Capsule())
            Text(f.s).font(F.mono(10.5)).foregroundStyle(tk.fg3)
        }
        .padding(6)
    }
}
