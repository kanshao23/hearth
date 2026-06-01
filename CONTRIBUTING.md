# Contributing to Hearth

Thanks for your interest. This repo is the **SwiftUI UI layer** of the Hearth design — a
faithful native recreation on mock data. Contributions that improve fidelity, interactivity,
accessibility, or move the project toward a real app are welcome.

## Getting set up

```bash
git clone https://github.com/kanshao23/hearth.git
cd hearth
swift build      # debug build — the source of truth for "does it compile"
swift test       # unit tests
swift run        # launch the gallery window
```

Requirements: macOS 14+, Swift 6 (Xcode 16 or standalone Command Line Tools). No third-party
dependencies — keep it that way unless there's a strong reason.

## Project conventions

- **Design tokens are the single source of truth.** Read colors/spacing from `\.tk`
  (the injected `Tokens`), never hard-code hex. Add new roles to `Theme/Tokens.swift` for
  both dark and light.
- **Colors authored in oklch** go through `Color(oklch:_:_:_:)` — don't approximate hex.
- **Icons** are SVG path data in `Components/Icon.swift`, rendered by `SVGPath`. Add new
  glyphs as path strings; don't reach for SF Symbols (they drift from the design).
- **View files stay under ~200 lines.** Split into subviews when they grow. Shared component
  libraries (`Primitives`, `SVGPath`) may be longer.
- **No force-unwraps** (`!`), no `try!`. Animations go through `TimelineView` or SwiftUI
  animation — never block the main thread.
- Match the existing style; new patterns should be discussed in an issue first.

## Workflow

1. Branch from `main`: `git checkout -b feat/your-thing` (prefixes: `feat/`, `fix/`,
   `docs/`, `ci/`, `refactor/`, `test/`).
2. Make the change. Keep commits focused; use [Conventional Commits](https://www.conventionalcommits.org/)
   (`feat:`, `fix:`, `docs:`, …).
3. `swift build` and `swift test` must pass with **zero warnings**.
4. Open a PR against `main`. CI builds and tests on macOS.

## Scope reminder

This is UI-only. There is intentionally no daemon, model client, sandbox, or persistence
beyond the theme toggle. Backend work belongs in a separate effort — see the roadmap in the
README.
