//
//  SettingSection.swift
//  AppTemplate
//
//  Created by hubin.h on 2025/12/11.
//  Copyright © 2025 hubin.h. All rights reserved.

import Foundation

// MARK: - Global Variables & Functions (if necessary)

enum SettingItem {
    case nightMode(Bool)
    case themeMode(String)
    case language(String)
    case clearCache
    case aboutUs

    var title: String {
        switch self {
        case .nightMode:   return "夜间模式"
        case .themeMode:   return "主题设置"
        case .language:    return "语言设置"
        case .clearCache:  return "清除缓存"
        case .aboutUs:     return "关于我们"
        }
    }
}
