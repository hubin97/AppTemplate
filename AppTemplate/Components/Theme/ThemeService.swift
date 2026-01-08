//
//  ThemeService.swift
//  AppTemplate
//
//  Created by hubin.h on 2025/12/11.
//  Copyright © 2025 hubin.h. All rights reserved.

import Foundation
import RxSwift
import RxCocoa

// MARK: - Global Variables & Functions (if necessary)

private let ThemeStorageKey = "AppThemeType"

// MARK: - Main Class
final class ThemeService {
    static let shared = ThemeService()
    
    private init() {
        // 从持久化存储中恢复主题
        loadSavedTheme()
    }

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
        return current.type == .dark
    }
    
    // 切换主题
    func toggle() {
        let newTheme: AppTheme = (current.type == .light) ? DarkTheme() : LightTheme()
        update(to: newTheme)
    }

    // 主动设置主题
    func update(to theme: AppTheme) {
        themeRelay.accept(theme)
        saveTheme(theme)
    }
    
    // 根据类型设置主题
    func update(to type: ThemeType) {
        let theme: AppTheme = (type == .light) ? LightTheme() : DarkTheme()
        update(to: theme)
    }
}

// MARK: - Private Methods
extension ThemeService {
    /// 保存主题到持久化存储
    private func saveTheme(_ theme: AppTheme) {
        mmkv.set(theme.type.rawValue, forKey: ThemeStorageKey)
    }
    
    /// 从持久化存储中加载主题
    /// 说明：
    /// - 可能在 App 启动早期 MMKV 还未完成初始化，因此允许多次调用，始终以存储值为准
    func loadSavedTheme() {
        if let savedTypeString = mmkv.string(forKey: ThemeStorageKey),
           let savedType = ThemeType(rawValue: savedTypeString) {
            let theme: AppTheme = (savedType == .light) ? LightTheme() : DarkTheme()
            themeRelay.accept(theme)
        } else {
            // 如果没有保存的主题，使用系统设置
            if #available(iOS 13.0, *) {
                let systemIsDark = UITraitCollection.current.userInterfaceStyle == .dark
                let theme: AppTheme = systemIsDark ? DarkTheme() : LightTheme()
                themeRelay.accept(theme)
            } else {
                themeRelay.accept(LightTheme())
            }
        }
    }
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
