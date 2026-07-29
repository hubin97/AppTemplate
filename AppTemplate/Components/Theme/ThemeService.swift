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

/// 主题状态可从任意线程读取；写操作与 UIKit 同步在主线程完成。
final class ThemeService {
    static let shared = ThemeService()

    private let lock = NSLock()
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

    var current: AppTheme {
        lock.lock()
        defer { lock.unlock() }
        return storedCurrent
    }

    var isDark: Bool {
        current.isDark
    }

    /// 在窗口显示前调用一次：恢复持久化配置，并同步 UIKit 的显示模式。
    func attach(to window: UIWindow) {
        performOnMain { [weak self] in
            guard let self else { return }
            self.window = window
            let selection = self.loadSelection()
            self.lock.lock()
            self.selection = selection
            self.lock.unlock()
            self.applyInterfaceStyle()
            self.refresh(using: window.traitCollection, force: true)
        }
    }

    func update(mode: ThemeMode) {
        performOnMain { [weak self] in
            guard let self else { return }
            self.lock.lock()
            let changed = self.selection.mode != mode
            if changed {
                self.selection.mode = mode
            }
            let selection = self.selection
            self.lock.unlock()
            guard changed else { return }

            self.saveSelection(selection)
            self.applyInterfaceStyle()
            self.refresh(
                using: self.window?.traitCollection ?? UITraitCollection.current,
                force: true
            )
        }
    }

    func update(palette: ThemePalette) {
        performOnMain { [weak self] in
            guard let self else { return }
            self.lock.lock()
            let changed = self.selection.palette != palette
            if changed {
                self.selection.palette = palette
            }
            let selection = self.selection
            self.lock.unlock()
            guard changed else { return }

            self.saveSelection(selection)
            self.refresh(
                using: self.window?.traitCollection ?? UITraitCollection.current,
                force: true
            )
        }
    }

    func toggleMode() {
        update(mode: isDark ? .light : .dark)
    }

    /// Scene 的系统明暗外观发生变化时调用；非 `.system` 模式会自动忽略。
    func systemAppearanceDidChange(_ traits: UITraitCollection) {
        performOnMain { [weak self] in
            guard let self else { return }
            self.lock.lock()
            let mode = self.selection.mode
            self.lock.unlock()
            guard mode == .system else { return }
            self.refresh(using: traits)
        }
    }

    /// 每个订阅者先收到当前快照，随后收到主题变化。
    func updates() -> AsyncStream<AppTheme> {
        let id = UUID()
        let initialValue = current

        return AsyncStream { continuation in
            self.lock.lock()
            self.continuations[id] = continuation
            self.lock.unlock()

            continuation.yield(initialValue)
            continuation.onTermination = { [weak self] _ in
                guard let self else { return }
                self.lock.lock()
                self.continuations.removeValue(forKey: id)
                self.lock.unlock()
            }
        }
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
        lock.lock()
        let selection = self.selection
        let previous = storedCurrent
        lock.unlock()

        let newTheme = Self.resolve(selection: selection, traits: traits)
        guard force ||
                newTheme.palette != previous.palette ||
                newTheme.mode != previous.mode ||
                newTheme.appearance != previous.appearance else {
            return
        }

        lock.lock()
        storedCurrent = newTheme
        let listeners = Array(continuations.values)
        lock.unlock()

        listeners.forEach { $0.yield(newTheme) }
    }

    func applyInterfaceStyle() {
        assert(Thread.isMainThread)
        lock.lock()
        let mode = selection.mode
        lock.unlock()

        switch mode {
        case .system:
            window?.overrideUserInterfaceStyle = .unspecified
        case .light:
            window?.overrideUserInterfaceStyle = .light
        case .dark:
            window?.overrideUserInterfaceStyle = .dark
        }
    }

    func saveSelection(_ selection: ThemeSelection) {
        mmkv.set(selection.mode.rawValue, forKey: ThemeStorageKey.mode)
        mmkv.set(selection.palette.rawValue, forKey: ThemeStorageKey.palette)
    }

    func loadSelection() -> ThemeSelection {
        // 兼容旧版本只保存 light/dark 的 AppThemeType。
        let modeRawValue = mmkv.string(forKey: ThemeStorageKey.mode)
            ?? mmkv.string(forKey: ThemeStorageKey.legacyType)
        let mode = modeRawValue.flatMap(ThemeMode.init(rawValue:)) ?? .system

        let paletteRawValue = mmkv.string(forKey: ThemeStorageKey.palette)
        let palette = paletteRawValue.flatMap(ThemePalette.init(rawValue:)) ?? .black

        return ThemeSelection(mode: mode, palette: palette)
    }

    func performOnMain(_ work: @escaping () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.async(execute: work)
        }
    }
}

/// 面向业务层的简洁入口，隐藏 Service 单例和持久化实现。
/// 读写均非 MainActor 隔离，可在 ViewModel / Rx 回调中直接使用。
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

    static func attach(to window: UIWindow) {
        ThemeService.shared.attach(to: window)
    }

    static func systemAppearanceDidChange(_ traits: UITraitCollection) {
        ThemeService.shared.systemAppearanceDidChange(traits)
    }
}
