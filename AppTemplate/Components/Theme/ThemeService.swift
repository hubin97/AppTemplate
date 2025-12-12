//
//  ThemeService.swift
//  AppTemplate
//
//  Created by hubin.h on 2025/12/11.
//  Copyright © 2025 hubin.h. All rights reserved.

import Foundation

// MARK: - Global Variables & Functions (if necessary)

// MARK: - Main Class
final class ThemeService {
    static let shared = ThemeService()

    // 内部 BehaviorRelay 保存当前主题
    private let themeRelay = BehaviorRelay<AppTheme>(value: LightTheme())

    // Observable 供订阅
    var theme: Observable<AppTheme> {
        themeRelay.asObservable()
    }

    // 当前主题，只读
    var current: AppTheme {
        themeRelay.value
    }

    // 是否夜间模式
    var isDark: Bool {
       return current is DarkTheme
    }
    
    // 切换主题示例
    func toggle() {
        let newTheme: AppTheme = (current is LightTheme) ? DarkTheme() : LightTheme()
        themeRelay.accept(newTheme)
    }

    // 主动设置主题
    func update(to theme: AppTheme) {
        themeRelay.accept(theme)
    }
}

// MARK: - Private Methods
extension ThemeService {
}

// MARK: - Callbacks
extension ThemeService {
}

// MARK: - Utilities & Helpers
extension ThemeService {
}

// MARK: - Delegate & Data Source
extension ThemeService {
}
