//
//  SettingSection.swift
//  AppTemplate
//
//  Created by hubin.h on 2025/12/11.
//  Copyright © 2025 hubin.h. All rights reserved.

import Foundation

// MARK: - Global Variables & Functions (if necessary)

enum SettingItem {
    case displayMode(ThemeMode)
    case themePalette(ThemePalette)
    case language(LocalizedUtils.LanguageCode)
    case clearCache
    case aboutUs

    var title: String {
        switch self {
        case .displayMode: return "显示模式"
        case .themePalette: return "主题设置"
        case .language:    return "语言设置"
        case .clearCache:  return "清除缓存"
        case .aboutUs:     return "关于我们"
        }
    }
}
