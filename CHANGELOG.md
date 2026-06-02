# Changelog

All notable changes to this project are documented here. Format loosely follows
[Keep a Changelog](https://keepachangelog.com/); the project is pre-1.0 and UI-only.

## [Unreleased]

### Added
- **Settings screen** (#5) — General (live theme toggle), Providers, Permissions, Sandbox
  default level, About; wired into the gallery as screen 09.
- **Command-line launch options** — `--screen <id>` opens directly to a screen; `--list`
  prints the screen registry and exits.
- **Gallery UX** (#3) — searchable sidebar, persisted selection, `⌘[` / `⌘]` to step screens.
- **Accessibility** (#4) — Reduce Motion support for the spinner/caret; VoiceOver labels and
  tooltips on icon-only controls.
- **Unit tests** (#2) — oklch→sRGB conversion, SVG path parsing, design tokens (swift-testing).
- **CI** (#1) — GitHub Actions builds and tests on macOS; `CONTRIBUTING.md`.

### Initial
- Native SwiftUI recreation of the Hearth design: all seven product surfaces, exact
  oklch→sRGB color conversion, a mini SVG-path renderer for the custom icon set, full
  dark/light token system with a persisted theme toggle, and a gallery navigator.
