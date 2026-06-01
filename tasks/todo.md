# Hearth SwiftUI 还原 — todo

## 1. 脚手架 + 主题底座
- [x] Package.swift（executable, macOS v14）
- [x] HearthApp.swift（@main, WindowGroup）
- [x] Theme/OKLCH.swift（oklch→Color）
- [x] Theme/ThemeManager.swift（light/dark, UserDefaults）
- [x] Theme/Tokens.swift（全量颜色/半径/阴影 token）
- [x] Theme/Typography.swift（字体 + 字号）
- [x] 里程碑：swift build 通过

## 2. 基础组件
- [x] Components/SVGPath.swift（含弧 a/A）
- [x] Components/Icon.swift（全部 path）
- [x] Components/Primitives.swift（HButton/Chip/Kbd/Dot/Spinner/Caret/Badge）
- [x] Components/CodeBlock.swift
- [x] Components/DiffView.swift
- [x] Components/WorkspaceGlyph.swift
- [x] 里程碑：build 通过 + 组件验证页

## 3. 简单屏
- [x] Models/MockData.swift
- [x] MenubarScreen / NotificationScreen / PaletteScreen / ApprovalScreen
- [x] Onboarding（3 步）
- [x] 里程碑：build 通过，画廊可见

## 4. Main window
- [x] MainWindow + SessionTreePane + ConversationPane + ActionBanner + Messages + InspectorPane + Overlays
- [x] 流式打字 / 折叠 tool call / check-in / ⌘⇧M / inline sheet / 4 tab
- [x] 3 变体
- [x] 里程碑：交互可用

## 5. Skill editor
- [x] SkillEditorScreen + Library + Source + Preview + Inspector

## 6. GalleryView 收口 + 主题切换
- [x] 镜像 section/artboard，ThemeToggle 全局

## 7. 核对
- [x] 逐屏比对 jsx，清 orphan
