//
//  ThemeService.swift
//  AppTemplate
//
//  Created by hubin.h on 2025/12/11.
//  Copyright © 2025 hubin.h. All rights reserved.

import UIKit

private enum ThemeStorageKey {
    static let mode = "AppThemeMode"
    static let palette = "AppThemePalette"
    static let legacyType = "AppThemeType"
}

/// 主题与窗口、trait、界面样式绑定，状态放在 MainActor，避免跨线程锁和 UIKit 跳转。
@MainActor
final class ThemeService {
    static let shared = ThemeService()

    private weak var window: UIWindow?
    private var selection = ThemeSelection.default
    private var continuations: [UUID: AsyncStream<AppTheme>.Continuation] = [:]
    private var storedCurrent: AppTheme

    private init() {
        storedCurrent = Self.resolve(
            selection: .default,
            traits: UITraitCollection.current
        )
    }

    var current: AppTheme { storedCurrent }

    var isDark: Bool { storedCurrent.isDark }

    /// 在窗口显示前调用一次：恢复持久化配置，并同步 UIKit 的显示模式。
    func attach(to window: UIWindow) async {
        self.window = window
        selection = await loadSelection()
        applyInterfaceStyle()
        refresh(using: window.traitCollection, force: true)
    }

    func update(mode: ThemeMode) {
        let changed = selection.mode != mode
        if changed {
            selection.mode = mode
        }
        guard changed else { return }

        saveSelection(selection)
        applyInterfaceStyle()
        refresh(
            using: window?.traitCollection ?? UITraitCollection.current,
            force: true
        )
    }

    func update(palette: ThemePalette) {
        let changed = selection.palette != palette
        if changed {
            selection.palette = palette
        }
        guard changed else { return }

        saveSelection(selection)
        refresh(
            using: window?.traitCollection ?? UITraitCollection.current,
            force: true
        )
    }

    func toggleMode() {
        update(mode: isDark ? .light : .dark)
    }

    /// Scene 的系统明暗外观发生变化时调用；非 `.system` 模式会自动忽略。
    func systemAppearanceDidChange(_ traits: UITraitCollection) {
        guard selection.mode == .system else { return }
        refresh(using: traits)
    }

    /// 每个订阅者先收到当前快照，随后收到主题变化。
    func updates() -> AsyncStream<AppTheme> {
        let id = UUID()
        let (stream, continuation) = AsyncStream.makeStream(of: AppTheme.self)
        continuations[id] = continuation
        continuation.yield(current)
        continuation.onTermination = { _ in
            Task { @MainActor in
                ThemeService.shared.removeContinuation(id)
            }
        }
        return stream
    }

    private func removeContinuation(_ id: UUID) {
        continuations.removeValue(forKey: id)
    }
}

private extension ThemeService {
    static func resolve(
        selection: ThemeSelection,
        traits: UITraitCollection
    ) -> AppTheme {
        let appearance: ThemeAppearance
        switch selection.mode {
        case .system:
            appearance = traits.userInterfaceStyle == .dark ? .dark : .light
        case .light:
            appearance = .light
        case .dark:
            appearance = .dark
        }

        return AppTheme(
            selection: selection,
            appearance: appearance,
            colors: selection.palette.resolveColors(for: appearance)
        )
    }

    func refresh(using traits: UITraitCollection, force: Bool = false) {
        let previous = storedCurrent
        let newTheme = Self.resolve(selection: selection, traits: traits)
        guard force ||
                newTheme.palette != previous.palette ||
                newTheme.mode != previous.mode ||
                newTheme.appearance != previous.appearance else {
            return
        }

        storedCurrent = newTheme
        continuations.values.forEach { $0.yield(newTheme) }
    }

    func applyInterfaceStyle() {
        assert(Thread.isMainThread)
        switch selection.mode {
        case .system:
            window?.overrideUserInterfaceStyle = .unspecified
        case .light:
            window?.overrideUserInterfaceStyle = .light
        case .dark:
            window?.overrideUserInterfaceStyle = .dark
        }
    }

    func saveSelection(_ selection: ThemeSelection) {
        Task {
            await MMKVManager.shared.set([
                ThemeStorageKey.mode: selection.mode.rawValue,
                ThemeStorageKey.palette: selection.palette.rawValue
            ])
        }
    }

    func loadSelection() async -> ThemeSelection {
        // 兼容旧版本只保存 light/dark 的 AppThemeType。
        var modeRawValue = await MMKVManager.shared.string(forKey: ThemeStorageKey.mode)
        if modeRawValue == nil {
            modeRawValue = await MMKVManager.shared.string(forKey: ThemeStorageKey.legacyType)
        }
        let mode = modeRawValue.flatMap(ThemeMode.init(rawValue:)) ?? .system

        let paletteRawValue = await MMKVManager.shared.string(forKey: ThemeStorageKey.palette)
        let palette = paletteRawValue.flatMap(ThemePalette.init(rawValue:)) ?? .black

        return ThemeSelection(mode: mode, palette: palette)
    }
}

/// 面向业务层的简洁入口，隐藏 Service 单例和持久化实现。
/// 与 ThemeService 同属 MainActor，页面 / 主线程 ViewModel 可直接同步读写。
@MainActor
enum Theme {
    static var current: AppTheme { ThemeService.shared.current }
    static var isDark: Bool { ThemeService.shared.isDark }
    static var updates: AsyncStream<AppTheme> { ThemeService.shared.updates() }

    static func set(mode: ThemeMode) {
        ThemeService.shared.update(mode: mode)
    }

    static func set(palette: ThemePalette) {
        ThemeService.shared.update(palette: palette)
    }

    static func toggleMode() {
        ThemeService.shared.toggleMode()
    }

    static func attach(to window: UIWindow) async {
        await ThemeService.shared.attach(to: window)
    }

    static func systemAppearanceDidChange(_ traits: UITraitCollection) {
        ThemeService.shared.systemAppearanceDidChange(traits)
    }
}
