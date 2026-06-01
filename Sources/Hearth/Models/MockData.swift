import Foundation

// ── Workspace ──
enum WorkspaceKind { case repo, global, folder }
enum WorkspaceTone { case amber, blue }

struct Workspace: Identifiable {
    let id: String
    let kind: WorkspaceKind
    let label: String
    let sub: String
    var glyph: String = ""
    var tone: WorkspaceTone = .amber
}

// ── Session tree ──
enum SessionStatus { case active, paused, done, failed, pending }

struct ChildSession: Identifiable {
    let id: String
    let title: String
    let status: SessionStatus
    let meta: String
}

struct Session: Identifiable {
    let id: String
    let title: String
    let status: SessionStatus
    let workspace: String
    var worktree: String? = nil
    var wtPath: String? = nil
    var unread: Bool = false
    let meta: String
    var children: [ChildSession] = []
}

enum Mock {
    static let workspaces: [Workspace] = [
        Workspace(id: "orchid", kind: .repo, label: "orchid", sub: "~/code/orchid · main", glyph: "o", tone: .amber),
        Workspace(id: "marble", kind: .repo, label: "marble", sub: "~/code/marble · v2-cli", glyph: "m", tone: .blue),
        Workspace(id: "global", kind: .global, label: "global", sub: "no repo · personal Mac"),
        Workspace(id: "dl", kind: .folder, label: "~/Downloads", sub: "12 PDFs · 4 zips"),
    ]

    static let sessions: [Session] = [
        Session(id: "auth", title: "Refactor auth → JWT", status: .active, workspace: "orchid",
                worktree: "feat/auth-jwt", wtPath: "~/code/orchid-wt/auth-jwt",
                meta: "opus-4.7 · 1h 04m · $0.83", children: [
                    ChildSession(id: "auth.scan", title: "Scan repo for auth callsites", status: .done, meta: "sonnet · 4m"),
                    ChildSession(id: "auth.plan", title: "Draft migration plan", status: .done, meta: "opus · 6m"),
                    ChildSession(id: "auth.patch", title: "Apply patches", status: .active, meta: "opus · running"),
                    ChildSession(id: "auth.tests", title: "Run XCTest after patch", status: .pending, meta: "queued"),
                ]),
        Session(id: "cleanup", title: "Onboarding copy polish", status: .done, workspace: "orchid",
                worktree: "fix/onboarding-copy", wtPath: "~/code/orchid-wt/onboarding-copy",
                meta: "7 files · merged 2d ago"),
        Session(id: "cli", title: "Port `mb serve` to async-std", status: .active, workspace: "marble",
                worktree: "rfc/async-std", wtPath: "~/code/marble-wt/async-std", unread: true,
                meta: "sonnet · 22m · $0.11", children: [
                    ChildSession(id: "cli.audit", title: "Audit blocking calls", status: .done, meta: "sonnet · 3m"),
                    ChildSession(id: "cli.rfc", title: "Write migration RFC", status: .active, meta: "sonnet · drafting"),
                ]),
        Session(id: "morning", title: "Morning routine", status: .active, workspace: "global",
                meta: "haiku · daily 8:00 · 12m", children: [
                    ChildSession(id: "m.gmail", title: "Fetch unread Gmail", status: .done, meta: "mac-bridge · 3 hits"),
                    ChildSession(id: "m.sum", title: "Summarize each", status: .done, meta: "haiku"),
                    ChildSession(id: "m.notes", title: "Append to today.md", status: .active, meta: "fs · writing"),
                ]),
        Session(id: "invoice", title: "PDF invoice scan", status: .paused, workspace: "dl", unread: true,
                meta: "awaiting approval · 1 pending", children: [
                    ChildSession(id: "i.scan", title: "List PDFs in Downloads", status: .done, meta: "fs · 18 files"),
                    ChildSession(id: "i.extract", title: "Extract totals", status: .paused, meta: "needs Full Disk Access"),
                ]),
    ]

    // Canonical auth patch diff — reused by approval sheet, conversation, inspector.
    static let authDiff: [DiffRow] = [
        DiffRow(gut: "42", kind: .plain, src: "  func authenticate(_ creds: Credentials) async throws -> Session {"),
        DiffRow(gut: "43", kind: .del, src: "    let cookie = try await server.signInCookie(creds)"),
        DiffRow(gut: "44", kind: .del, src: "    persist(cookie: cookie, scope: .browser)"),
        DiffRow(gut: "45", kind: .del, src: "    return Session(cookie: cookie)"),
        DiffRow(gut: "43", kind: .add, src: "    let token = try await server.signInJWT(creds)"),
        DiffRow(gut: "44", kind: .add, src: "    try await keychain.store(.refresh, token.refresh)"),
        DiffRow(gut: "45", kind: .add, src: "    let access = AccessToken(jwt: token.access, exp: token.exp)"),
        DiffRow(gut: "46", kind: .add, src: "    return Session(access: access, refresh: .keychain)"),
        DiffRow(gut: "46", kind: .plain, src: "  }"),
        DiffRow(gut: "47", kind: .plain, src: ""),
        DiffRow(gut: "48", kind: .plain, src: "  func refresh(_ session: Session) async throws -> Session {"),
        DiffRow(gut: "49", kind: .del, src: "    return try await server.refreshCookie(session.cookie)"),
        DiffRow(gut: "48", kind: .add, src: "    let refresh = try await keychain.load(.refresh)"),
        DiffRow(gut: "49", kind: .add, src: "    return try await server.refreshJWT(refresh)"),
    ]
}
