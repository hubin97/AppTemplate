//
//  AppTheme.swift
//  AppTemplate
//
//  Created by hubin.h on 2025/12/11.
//  Copyright © 2025 hubin.h. All rights reserved.

import UIKit

/// 显示模式与颜色主题是两个独立维度。
enum ThemeMode: String, Codable, CaseIterable {
    case system
    case light
    case dark

    var displayName: String {
        switch self {
        case .system: return "跟随系统"
        case .light: return "浅色"
        case .dark: return "深色"
        }
    }
}

/// App 提供的颜色主题。新增主题时在这里增加 case，并在 `resolveColors` 中配置色板。
enum ThemePalette: String, Codable, CaseIterable {
    case black
    case blue
    case green
    case purple
    case orange
    case red

    var displayName: String {
        switch self {
        case .black: return "黑色"
        case .blue: return "蓝色"
        case .green: return "绿色"
        case .purple: return "紫色"
        case .orange: return "橙色"
        case .red: return "红色"
        }
    }
}

enum ThemeAppearance: String, Codable {
    case light
    case dark
}

struct ThemeSelection: Codable, Equatable {
    var mode: ThemeMode
    var palette: ThemePalette

    static let `default` = ThemeSelection(mode: .system, palette: .black)
}

/// 已解析的语义色。业务层只消费语义，不自行判断明暗模式。
struct ThemeColors {
    let background: UIColor
    let tableBackground: UIColor
    let text: UIColor
    let secondaryText: UIColor
    let tint: UIColor
    let tabNormal: UIColor
    let tabSelected: UIColor
}

/// 当前最终生效的主题快照。
struct AppTheme {
    let selection: ThemeSelection
    let appearance: ThemeAppearance
    let colors: ThemeColors

    var mode: ThemeMode { selection.mode }
    var palette: ThemePalette { selection.palette }
    var isDark: Bool { appearance == .dark }
    var statusBarStyle: UIStatusBarStyle { isDark ? .lightContent : .darkContent }
}

extension ThemePalette {
    func resolveColors(for appearance: ThemeAppearance) -> ThemeColors {
        let isDark = appearance == .dark
        let accent = accentColor(for: appearance)
        return ThemeColors(
            background: isDark ? .black : .white,
            tableBackground: isDark ? UIColor(white: 0.08, alpha: 1) : SFColor.FlatUI.clouds,
            text: isDark ? .white : .black,
            secondaryText: isDark ? .lightGray : .darkGray,
            tint: accent,
            tabNormal: .lightGray,
            tabSelected: accent
        )
    }

    func accentColor(for appearance: ThemeAppearance) -> UIColor {
        let isDark = appearance == .dark
        switch self {
        case .black:
            return isDark ? .white : .black
        case .blue:
            return isDark ? UIColor(hexStr: "#64B5F6") : UIColor(hexStr: "#1976D2")
        case .green:
            return isDark ? UIColor(hexStr: "#81C784") : UIColor(hexStr: "#388E3C")
        case .purple:
            return isDark ? UIColor(hexStr: "#BA68C8") : UIColor(hexStr: "#7B1FA2")
        case .orange:
            return isDark ? UIColor(hexStr: "#FFB74D") : UIColor(hexStr: "#F57C00")
        case .red:
            return isDark ? UIColor(hexStr: "#E57373") : UIColor(hexStr: "#D32F2F")
        }
    }
}
