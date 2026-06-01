<div align="center">

# 🔥 Hearth

### Local-first, multi-agent workflow OS for macOS — SwiftUI design recreation

[![Platform](https://img.shields.io/badge/macOS-14%2B-555?labelColor=0b0b0e)](#requirements)
[![Swift](https://img.shields.io/badge/Swift-6.0-e8a34a?labelColor=0b0b0e)](#requirements)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-no%20Electron-e8a34a?labelColor=0b0b0e)](#architecture)
[![License](https://img.shields.io/badge/license-MIT-555?labelColor=0b0b0e)](#license)

A **pixel-faithful, native SwiftUI recreation** of the [Hearth](#what-is-hearth) design —
a dark-mode, amber-accented, local-first agent orchestration UI for macOS. All seven
product surfaces, the full design-token system, custom icon set, and the core
interactions of the main window, rebuilt as a runnable macOS app.

[What is Hearth](#what-is-hearth) · [Run it](#quick-start) · [Screens](#the-seven-screens) ·
[Architecture](#architecture) · [Project layout](#project-layout) · [Design fidelity](#design-fidelity) · [Status](#status--scope)

</div>

---

## What is Hearth

**Hearth** is a concept product: a local-first, multi-agent workflow OS for macOS. Compose
AI agents like plug-ins, give them markdown skills, and run long tasks from the menubar —
sessions, files, and API keys never leave the machine.

> The product positioning, in one line: an **orchestrator that owns the agent loop**.
> Where terminal multiplexers (Orca, Superset) wrap external CLI agents and see only
> stdout, and coding agents (Claude Code, Codex) are single-context terminal runtimes,
> Hearth is a third thing — it owns the loop, integrates natively with the Mac (Mail,
> Calendar, Finder, Notes), and delegates to stronger coding agents *as a tool* when a job
> calls for it.

This repository is **the UI**, not the daemon. It is a faithful SwiftUI reconstruction of
the interactive HTML/React design prototype that defines Hearth's product surface. It runs
on **mock data** — there is no Rust daemon, model client, or sandbox behind it yet. It
exists to lock the visual + interaction design in a real native runtime, and to serve as the
starting point for the actual app.

The original design was produced in [Claude Design](https://claude.ai/design) as an
HTML/CSS/JS prototype, then handed off for implementation. This project recreates the
design's visual output natively — it does **not** copy the prototype's internal structure.

---

## Quick start

### Requirements

| | |
|---|---|
| **OS** | macOS 14 (Sonoma) or newer |
| **Toolchain** | Swift 6 (Xcode 16 *or* the standalone Command Line Tools) |
| **Dependencies** | none — pure SwiftUI, no third-party packages |

Check your toolchain:

```bash
swift --version   # expect Apple Swift 6.x
```

### Build & run

```bash
git clone https://github.com/kanshao23/hearth.git
cd hearth
swift run            # builds, then opens the Hearth window
```

That's it. No Xcode project required — it's a Swift Package with an executable target using
the SwiftUI `App` lifecycle. To build without launching:

```bash
swift build          # debug build
swift build -c release
```

The app opens a **gallery navigator**: a sidebar lists all seven screens grouped exactly as
the design canvas does; the detail pane renders each screen at its native design size. The
moon/sun toggle (top-right of the sidebar) flips the whole app between **dark and light
themes**, persisted across launches.

To stop a backgrounded run:

```bash
pkill -f "debug/Hearth"
```

---

## The seven screens

All seven product surfaces from the design are implemented. Open the app and pick from the
sidebar.

| # | Screen | Size | What it shows |
|---|--------|------|---------------|
| **02** | **Menubar popover** | 280×470 | Faux macOS menubar strip + popover: new-task input, active sessions (with spinners / status dots / progress), recent skills, footer. |
| **03** | **Approval sheet** | 660×760 | Native-style sheet over a dimmed window: tool + args JSON (syntax-colored), scrollable diff preview, 4 approval scopes (Allow once / for session / always in dir / Deny). |
| **04a** | **Main window — steerable** | 1200×800 | Three columns: session tree · streaming conversation · inspector. The last assistant message types out token-by-token; tool-call cards fold/unfold; a queued steering message sits below. |
| **04b** | **Main window — agent check-in** | 1200×800 | Same window, the `marble` RFC session selected — the agent hit a real ambiguity and **paused to ask**, rendered as an amber check-in bubble with quick-reply options. |
| **04c** | **Main window — workspace switcher** | 1200×800 | The scope switcher dropdown open, filtering sessions by workspace (repo / global / folder). |
| **05** | **Skill editor** | 1200×800 | Three panes: skill library · markdown source with line numbers + frontmatter/body syntax highlighting · rendered preview, variables, tool plan, and dry-run. |
| **06** | **Command palette** | 640×480 | `⌘⇧M` fuzzy search across skills / sessions / files / actions, grouped, with keyboard hints. |
| **07** | **Notifications** | 380 wide | Three Notification Center cards — success, approval-needed, failure — with translucent overlay styling. |
| **08a–c** | **Onboarding** | 720×520 | Three-step first-run wizard: connect a provider (+ API key), grant permissions, pick a starter skill. |

### Interactions wired up (main window)

- **Click any session** in the tree → switches the conversation.
- **Tool-call cards fold** — click to expand the diff or stdout.
- **The last assistant message streams** token-by-token (async, off the main thread).
- **`⌘⇧M`** from anywhere → command palette; **`Esc`** dismisses overlays.
- **Review & approve** → inline approval sheet drops over the window.
- **Inspector** collapses to an icon rail and expands to four tabs: Files · Approvals · Events · Repo map.
- **Workspace scope switcher** dropdown.
- **Star / unread** toggles per session.
- **Theme toggle** — dark ↔ light, app-wide, persisted.

---

## Architecture

A Swift Package, executable target, SwiftUI `App` lifecycle. No storyboards, no XIBs, no
third-party dependencies. Three ideas carry the fidelity:

### 1. Exact `oklch()` → sRGB color conversion

The design tokens (`tokens.css`) are authored in **oklch**, which SwiftUI's `Color` does not
support. Rather than eyeballing hex equivalents, `Theme/OKLCH.swift` implements the full
conversion — OKLab → LMS → linear sRGB → gamma-encoded sRGB — so the amber accent, semantic
colors, and diff palette match the source mathematically.

```swift
Color(oklch: 0.76, 0.135, 65)        // --amber: oklch(76% 0.135 65)
Color(oklch: 0.70, 0.17, 25, 0.14)   // --danger at 14% alpha
```

### 2. A mini SVG-path renderer for the custom icon set

The design ships ~40 custom stroke icons (14×14 viewBox, 1.5 stroke, round caps) as SVG path
strings. Instead of substituting SF Symbols (which would drift from the design),
`Components/SVGPath.swift` is a small path parser — `M m L l H h V v C c S s Q q T t A a Z z`,
with elliptical arcs flattened to short segments — that renders every icon faithfully from
its original path data in `Components/Icon.swift`.

### 3. A single source of truth for design tokens

`Theme/Tokens.swift` ports the entire token system — surfaces, borders, text, the amber
accent, semantic colors, diff colors — for **both** dark and light themes. `ThemeManager`
(an `ObservableObject`, `UserDefaults`-backed) swaps the active `Tokens` value, injected
through the SwiftUI environment as `\.tk`, so every view reads live theme values.

```
SwiftUI App (HearthApp)
  └─ environmentObject(ThemeManager)        // light/dark, persisted
  └─ environment(\.tk, Tokens.from(theme))  // all color/spacing tokens
       └─ GalleryView                        // sidebar navigator + detail
            └─ <screen views>                // read \.tk, render at design size
```

Reusable primitives (`Components/Primitives.swift`) — buttons, chips, keyboard keys, status
dots, an animated spinner, a blinking caret, badges — map 1:1 to the `.btn` / `.chip` /
`.kbd` CSS classes. Animations (spinner rotation, streaming caret) are driven by
`TimelineView`, so nothing blocks the main thread.

---

## Project layout

```
hearth/
├── Package.swift                      # executable target, macOS v14, zero deps
├── Sources/Hearth/
│   ├── HearthApp.swift                # @main — WindowGroup → GalleryView
│   ├── Theme/
│   │   ├── OKLCH.swift                # oklch()/hex → Color conversion
│   │   ├── Tokens.swift               # all design tokens, dark + light
│   │   ├── ThemeManager.swift         # light/dark, UserDefaults-persisted
│   │   └── Typography.swift           # SF Pro / SF Mono helpers, type scale
│   ├── Components/
│   │   ├── SVGPath.swift              # mini SVG path Shape (incl. arcs)
│   │   ├── Icon.swift                 # ~40 icons as path data + LogoMark
│   │   ├── Primitives.swift           # HButton, Chip, Kbd, Dot, Spinner, Caret, Badge
│   │   ├── CodeBlock.swift            # mono code + token coloring
│   │   ├── DiffView.swift             # add/del/gutter diff rows
│   │   ├── WorkspaceGlyph.swift       # repo letter tile / global / folder
│   │   └── WindowChrome.swift         # traffic lights, titlebar, ThemeToggle
│   ├── Models/
│   │   └── MockData.swift             # workspaces, session tree, canonical diff
│   └── Screens/
│       ├── GalleryView.swift          # section/artboard navigator
│       ├── MenubarScreen.swift
│       ├── NotificationScreen.swift
│       ├── PaletteScreen.swift
│       ├── ApprovalScreen.swift
│       ├── MainWindow/                # MainWindow + tree, conversation,
│       │                              #   banner, messages, inspector, overlays
│       ├── SkillEditor/               # screen + library, source, preview, inspector
│       └── Onboarding/                # frame + 3 steps
└── tasks/                             # build todo (planning artifact)
```

37 Swift files. View files are kept under ~200 lines; the two slightly-larger files
(`SVGPath`, `Primitives`) are shared component libraries, not screens.

---

## Design fidelity

- **Colors** come from the oklch math, not approximated hex.
- **Icons** render from the original SVG path data, not SF Symbols.
- **Sizes, spacing, font sizes, radii** are transcribed from the source prototype
  (e.g. main window 1200×800, menubar 280, palette panel 560, radii 4/6/8).
- **Both themes** are implemented; the toggle is global and persisted.
- Dark is the primary surface, with a **single warm amber accent** — no gradients, no glow,
  no purple. Reference points: Linear, Raycast, Things.

What's intentionally **approximate**: a couple of inline markdown code-spans in the rendered
skill preview drop their bordered box (SwiftUI `Text` can't carry per-run backgrounds), and
the faux desktop behind the standalone approval sheet is a simple skeleton.

---

## Status & scope

This is **UI-layer only**, on mock data. There is deliberately **no**:

- Rust daemon / agent loop
- Model client (Anthropic / OpenAI / Ollama)
- Tool registry, MCP host, or AppleScript bridge
- Seatbelt sandbox or approval store
- Persistence (SQLite / config)

Everything you see is static or locally-stateful SwiftUI. The buttons are real controls but
don't call a backend.

### Roadmap (if taken further)

- [ ] Wrap as a proper `.app` bundle (menubar agent, Dock, notifications)
- [ ] Real session store + streaming model client behind a provider protocol
- [ ] Tree-session forking, git shadow-branch undo
- [ ] Markdown skill loader + frontmatter validation + schedule triggers
- [ ] MCP host + delegate-to-Claude-Code/Codex
- [ ] Seatbelt sandbox + approval persistence

---

## Why a Swift Package and not an Xcode project

The build environment had the Swift toolchain but no full Xcode, so an `.xcodeproj` couldn't
be built or verified here. A Swift Package executable target with the SwiftUI `App` lifecycle
builds and launches from the command line, has zero project-file churn, and ports cleanly
into an Xcode app target later. `swift build` is the source of truth for "does it compile."

---

## License

MIT. The Hearth product concept and original design are recreated here for implementation;
this repository is the SwiftUI code.

<div align="center">
<sub>Your machine. Your agents. Your rules.</sub>
</div>
