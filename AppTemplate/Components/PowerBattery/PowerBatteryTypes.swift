//
//  PowerBatteryTypes.swift
//  AppTemplate
//
//  Created by hubin.h on 2026/8/21.
//  Copyright © 2026 hubin.h. All rights reserved.

import UIKit

// MARK: - PowerBatteryLevelState

/// 电池电量状态
enum PowerBatteryLevelState: Equatable {
    /// 即将关机
    case shutdown
    /// 超低电
    case critical
    /// 低电
    case low
    /// 正常
    case normal
    /// 满电
    case full
}

// MARK: - PowerBatteryThresholds

/// 电量区间阈值（闭区间上界，满电为下界）
struct PowerBatteryThresholds: Equatable {
    /// 即将关机：0% 及以下
    var shutdownMax: Int = 0
    /// 超低电：1% ~ criticalMax
    var criticalMax: Int
    /// 低电：criticalMax + 1 ~ lowMax
    var lowMax: Int
    /// 满电：fullMin 及以上
    var fullMin: Int = 100

    static let `default` = PowerBatteryThresholds(
        shutdownMax: 0,
        criticalMax: 10,
        lowMax: 20,
        fullMin: 100
    )

    func levelState(for percent: Int) -> PowerBatteryLevelState {
        let value = min(max(percent, 0), 100)
        if value <= shutdownMax { return .shutdown }
        if value <= criticalMax { return .critical }
        if value <= lowMax { return .low }
        if value >= fullMin { return .full }
        return .normal
    }
}

// MARK: - PowerBatteryReportStatus

/// 设备上报电量状态（如 M5 Ultra）：0 正常 / 1 低电 / 2 超低电。
enum PowerBatteryReportStatus: Int, Equatable {
    case normal = 0
    case low = 1
    case critical = 2

    var levelState: PowerBatteryLevelState {
        switch self {
        case .normal: return .normal
        case .low: return .low
        case .critical: return .critical
        }
    }

    static func from(raw: Int?) -> PowerBatteryReportStatus? {
        guard let raw, (0...2).contains(raw) else { return nil }
        return PowerBatteryReportStatus(rawValue: raw)
    }
}

// MARK: - PowerBatteryStyle

/// 电池展示样式（对齐 Figma「合成规则」）
enum PowerBatteryStyle: Equatable {
    /// 百分比：填充与内显同源
    case percent(PowerBatteryPercentContent)
    /// 格数分段：格数换算填充进度，真实电量独立内显（M5 Ultra 等）
    case segment(PowerBatterySegmentContent)
}

/// 百分比模式内容（色阶由 thresholds 推导，无 reportStatus）
struct PowerBatteryPercentContent: Equatable {
    /// 电量 0~100，同时驱动填充与内显
    var percent: Int
    var thresholds: PowerBatteryThresholds = .default
}

/// 格数模式填充进度：格数估算 or 已换算百分比
enum PowerBatterySegmentProgress: Equatable {
    /// 设备上报格数（filled / total → 填充比例）
    case segments(filled: Int, total: Int)
    /// 已换算的填充进度 0~100
    case progress(Int)

    var fillPercent: Int {
        switch self {
        case .segments(let filled, let total):
            guard total > 0 else { return 0 }
            let ratio = Int((Double(filled) / Double(total) * 100).rounded())
            return min(max(ratio, 0), 100)
        case .progress(let value):
            return min(max(value, 0), 100)
        }
    }
}

/// 格数分段模式内容
struct PowerBatterySegmentContent: Equatable {
    var progress: PowerBatterySegmentProgress
    /// 设备上报精确电量，用于内显
    var realPercent: Int
    var reportStatus: PowerBatteryReportStatus?
}

// MARK: - PowerBatteryConfiguration

/// 电池组件渲染配置（唯一推荐入口）
struct PowerBatteryConfiguration: Equatable {
    var style: PowerBatteryStyle
    var theme: PowerBatteryTheme
    var isCharging: Bool = false
    var showsCenterText: Bool = true
    /// 0% 时是否展示「即将关机」空电形态（`icon_battery_low`），默认 `false`
    var showsShutdownDisplay: Bool = false
}

extension PowerBatteryConfiguration {

    static func percent(
        percent: Int,
        theme: PowerBatteryTheme,
        isCharging: Bool = false,
        showsCenterText: Bool = true,
        showsShutdownDisplay: Bool = false,
        thresholds: PowerBatteryThresholds = .default
    ) -> PowerBatteryConfiguration {
        PowerBatteryConfiguration(
            style: .percent(PowerBatteryPercentContent(
                percent: percent,
                thresholds: thresholds
            )),
            theme: theme,
            isCharging: isCharging,
            showsCenterText: showsCenterText,
            showsShutdownDisplay: showsShutdownDisplay
        )
    }

    static func segment(
        progress: PowerBatterySegmentProgress,
        realPercent: Int,
        theme: PowerBatteryTheme,
        isCharging: Bool = false,
        reportStatus: PowerBatteryReportStatus? = nil,
        showsCenterText: Bool = true,
        showsShutdownDisplay: Bool = false
    ) -> PowerBatteryConfiguration {
        PowerBatteryConfiguration(
            style: .segment(PowerBatterySegmentContent(
                progress: progress,
                realPercent: realPercent,
                reportStatus: reportStatus
            )),
            theme: theme,
            isCharging: isCharging,
            showsCenterText: showsCenterText,
            showsShutdownDisplay: showsShutdownDisplay
        )
    }

}

// MARK: - PowerBatteryLevelSource

/// 色阶来源：percent 仅 thresholds，segment 仅 reportStatus。
enum PowerBatteryLevelSource: Equatable {
    case thresholds(PowerBatteryThresholds)
    case reportStatus(PowerBatteryReportStatus?)
}

// MARK: - PowerBatteryDisplayModel

/// 电池组件统一输入（业务层映射 RN payload 后传入；组件内不解析桥接字段）。
///
/// 字段职责（对齐 M5 Ultra 等新协议）：
/// - `fillPercent`：填充进度（格数换算 or 预换算百分比）
/// - `realPercent`：设备上报精确电量，用于电池内居中文案
/// - `levelSource`：percent → thresholds；segment → reportStatus
/// - `showsShutdownDisplay`：0% 时是否展示关机空电形态，默认 `false`
struct PowerBatteryDisplayModel: Equatable {
    /// 填充进度 0~100
    var fillPercent: Int
    /// 精确电量 0~100；`nil` 时文案回退为 `fillPercent`
    var realPercent: Int?
    var levelSource: PowerBatteryLevelSource = .thresholds(.default)
    var isCharging: Bool
    /// 是否在电池内部显示电量数值，默认 `true`
    var showsCenterText: Bool = true
    /// 0% 时是否展示「即将关机」空电形态，默认 `false`
    var showsShutdownDisplay: Bool = false

    var clampedFillPercent: Int {
        min(max(fillPercent, 0), 100)
    }

    var clampedRealPercent: Int? {
        guard let realPercent else { return nil }
        return min(max(realPercent, 0), 100)
    }

    /// 色阶解析：percent ↔ thresholds，segment ↔ reportStatus，互不混用。
    func resolvedLevelState() -> PowerBatteryLevelState {
        switch levelSource {
        case .thresholds(let thresholds):
            return thresholds.levelState(for: clampedFillPercent)
        case .reportStatus(let reportStatus):
            return reportStatus?.levelState ?? .normal
        }
    }

    /// 电池内居中文案：优先真实电量，否则回退填充进度
    func resolvedCenterText() -> String? {
        guard showsCenterText else { return nil }
        let level = clampedRealPercent ?? clampedFillPercent
        return "\(level)"
    }
}

extension PowerBatteryDisplayModel {

    init(configuration: PowerBatteryConfiguration) {
        switch configuration.style {
        case .percent(let content):
            self.init(
                fillPercent: content.percent,
                realPercent: nil,
                levelSource: .thresholds(content.thresholds),
                isCharging: configuration.isCharging,
                showsCenterText: configuration.showsCenterText,
                showsShutdownDisplay: configuration.showsShutdownDisplay
            )
        case .segment(let content):
            self.init(
                fillPercent: content.progress.fillPercent,
                realPercent: content.realPercent,
                levelSource: .reportStatus(content.reportStatus),
                isCharging: configuration.isCharging,
                showsCenterText: configuration.showsCenterText,
                showsShutdownDisplay: configuration.showsShutdownDisplay
            )
        }
    }
}

// MARK: - PowerBatteryPalette

/// Figma 语义色（node 27-21163 / variable defs）
enum PowerBatteryPalette {
    /// Accents/Red · 超低电填充
    static let criticalFill = UIColor(hexStr: "#FF383C")
    /// Colors/Yellow · 低电填充
    static let lowFill = UIColor(hexStr: "#FFCC00")
    /// Colors/Text/color-text-primary · 超低电/低电内显
    static let overlayDark = UIColor(hexStr: "#240F1B")
}

// MARK: - PowerBatteryTheme

/// 电池主题色配置
struct PowerBatteryTheme: Equatable {
    /// 正常 / 满电填充色
    var themeColor: UIColor
    /// 电池内槽底色（未充入部分）
    var backgroundColor: UIColor
    /// 超低电填充色
    var criticalColor: UIColor
    /// 低电填充色
    var lowColor: UIColor
    /// 百分比文字色（正常 / 满电）
    var accentTextColor: UIColor

    /// 正常 / 满电内显色（白色主题等浅填充需设为深色）
    var normalOverlayColor: UIColor

    init(
        themeColor: UIColor,
        backgroundColor: UIColor? = nil,
        criticalColor: UIColor = PowerBatteryPalette.criticalFill,
        lowColor: UIColor = PowerBatteryPalette.lowFill,
        accentTextColor: UIColor? = nil,
        normalOverlayColor: UIColor = .white
    ) {
        self.themeColor = themeColor
        self.backgroundColor = backgroundColor ?? themeColor.withAlphaComponent(0.3)
        self.criticalColor = criticalColor
        self.lowColor = lowColor
        self.accentTextColor = accentTextColor ?? themeColor.withAlphaComponent(0.7)
        self.normalOverlayColor = normalOverlayColor
    }

    func fillColor(for state: PowerBatteryLevelState) -> UIColor? {
        switch state {
        case .shutdown:
            return nil
        case .critical:
            return criticalColor
        case .low:
            return lowColor
        case .normal, .full:
            return themeColor
        }
    }

    func percentTextColor(for state: PowerBatteryLevelState) -> UIColor {
        switch state {
        case .critical, .shutdown:
            return criticalColor
        case .low:
            return lowColor
        case .normal, .full:
            return accentTextColor
        }
    }

    /// 电池内居中 overlay：超低电/低电/关机 → 黑色；正常/满电 → 白色（对齐 Figma 1/4/32 vs 80/100）
    func centerOverlayColor(for state: PowerBatteryLevelState) -> UIColor {
        switch state {
        case .shutdown, .critical, .low:
            return PowerBatteryPalette.overlayDark
        case .normal, .full:
            return normalOverlayColor
        }
    }
}

extension PowerBatteryTheme {
    static let centerOverlayDarkColor = PowerBatteryPalette.overlayDark
}

// MARK: - PowerBatteryThemePreset

/// Figma 六种电池主题色（node 27-21746）
enum PowerBatteryThemePreset: CaseIterable {
    case white
    case black
    case purple
    case red
    case yellow
    case green

    var displayName: String {
        switch self {
        case .white: return "白色"
        case .black: return "黑色"
        case .purple: return "紫色"
        case .red: return "红色"
        case .yellow: return "黄色"
        case .green: return "绿色"
        }
    }

    /// 填充色 opacity 1
    var fillColor: UIColor {
        switch self {
        case .white: return .white
        case .black: return UIColor(hexStr: "#240F1B")
        case .purple: return UIColor(hexStr: "#552C95")
        case .red: return UIColor(hexStr: "#770523")
        case .yellow: return UIColor(hexStr: "#7E451F")
        case .green: return UIColor(hexStr: "#1A5140")
        }
    }

    var theme: PowerBatteryTheme {
        PowerBatteryTheme(
            themeColor: fillColor,
            normalOverlayColor: self == .white ? PowerBatteryPalette.overlayDark : .white
        )
    }
}

// MARK: - PowerBatteryLayoutMetrics

/// 基于 Figma `battery-indicator`（27.33×13.67pt）标定的布局参数
enum PowerBatteryLayoutMetrics {
    static let designSize = CGSize(width: 27.33, height: 13.67)
    /// 右侧预留正极凸起（主体宽约 25pt）
    static let fillInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 2.33)
    static let fillCornerRadius: CGFloat = 3.4
    /// Figma typography/bodys-medium · 12px（node 27-21688 等默认内显）
    static let centerFontSize: CGFloat = 12
    /// Figma typography/captionm-medium · 10px（node 27-21172 · 100% + 充电）
    static let centerFontSizeCompact: CGFloat = 10
    /// 闪电向左叠进文字 side bearing，视觉 gap ≈ 1px
    static let centerOverlayFlashOverlap: CGFloat = -1

    /// 内显字号：默认 bodys-medium 12pt；满电 100% 且充电 captionm-medium 10pt
    static func resolvedCenterFontSize(displayLevel: Int, isCharging: Bool) -> CGFloat {
        displayLevel >= 100 && isCharging ? centerFontSizeCompact : centerFontSize
    }

    /// 电池主体宽度（排除右侧正极），用于居中 overlay
    static func bodyRect(in bounds: CGRect) -> CGRect {
        let insets = scaledInsets(for: bounds.size)
        let width = bounds.width - insets.left - insets.right
        return CGRect(x: bounds.minX + insets.left, y: bounds.minY, width: width, height: bounds.height)
    }

    static func scaledInsets(for size: CGSize) -> UIEdgeInsets {
        let scale = size.width / designSize.width
        return UIEdgeInsets(
            top: fillInsets.top * scale,
            left: fillInsets.left * scale,
            bottom: fillInsets.bottom * scale,
            right: fillInsets.right * scale
        )
    }

}
