//
//  Themeable.swift
//  AppTemplate
//
//  Created by hubin.h on 2025/12/11.
//  Copyright © 2025 hubin.h. All rights reserved.

import UIKit
import ObjectiveC

@MainActor
protocol Themeable: AnyObject {
    /// 页面只需覆写这个方法；订阅和生命周期由基础 UI 类统一管理。
    func themeDidChange(_ theme: AppTheme)
}

private final class ThemeObservation {
    var task: Task<Void, Never>?

    deinit {
        task?.cancel()
    }
}

// 仅作 associated object 地址，不读写键值本身。
private nonisolated(unsafe) var themeObservationKey: UInt8 = 0

@MainActor
extension Themeable where Self: NSObject {
    /// 供基础 UI 类启动监听，业务页面不需要调用。
    func startThemeUpdates() {
        let observation: ThemeObservation
        if let existing = objc_getAssociatedObject(self, &themeObservationKey) as? ThemeObservation {
            observation = existing
        } else {
            observation = ThemeObservation()
            objc_setAssociatedObject(
                self,
                &themeObservationKey,
                observation,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }

        observation.task?.cancel()
        observation.task = Task { @MainActor [weak self] in
            for await theme in Theme.updates {
                guard let self else { return }
                self.themeDidChange(theme)
            }
        }
    }
}

@MainActor
extension Themeable where Self: ViewController {
    /// 通用页面主题：背景、导航栏、状态栏。
    func applyPageTheme(_ theme: AppTheme) {
        view.backgroundColor = theme.colors.background
        naviBar.textColor = theme.colors.text
        naviBar.updateIcons(isDark: theme.isDark, textColor: theme.colors.tint)
        updateStatusBar(with: theme.statusBarStyle)
        
        if NaviBar.usesSystemBar {
            navigationController?.navigationBar.tintColor = theme.colors.tint
        } else {
            naviBar.backgroundColor = theme.colors.background
        }
    }
}

@MainActor
extension Themeable where Self: UITableViewCell {
    /// 通用 Cell 主题。
    func applyCellTheme(_ theme: AppTheme) {
        backgroundColor = theme.colors.background
        contentView.backgroundColor = theme.colors.background
    }
}
