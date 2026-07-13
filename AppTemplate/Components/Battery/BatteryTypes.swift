//
//  BatteryTypes.swift
//  AppTemplate
//
//  Created by hubin.h on 2026/7/13.
//  Copyright © 2026 hubin.h. All rights reserved.

import UIKit

// MARK: - BatteryLevelState

/// 电池电量状态
enum BatteryLevelState: Equatable {
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

// MARK: - BatteryThresholds

/// 电量区间阈值（闭区间上界，满电为下界）
struct BatteryThresholds: Equatable {
    /// 即将关机：0% 及以下
    var shutdownMax: Int
    /// 超低电：1% ~ criticalMax
    var criticalMax: Int
    /// 低电：criticalMax + 1 ~ lowMax
    var lowMax: Int
    /// 满电：fullMin 及以上
    var fullMin: Int

    static let `default` = BatteryThresholds(
        shutdownMax: 0,
        criticalMax: 10,
        lowMax: 20,
        fullMin: 100
    )

    func levelState(for percent: Int) -> BatteryLevelState {
        let value = min(max(percent, 0), 100)
        if value <= shutdownMax { return .shutdown }
        if value <= criticalMax { return .critical }
        if value <= lowMax { return .low }
        if value >= fullMin { return .full }
        return .normal
    }
}

// MARK: - BatteryTheme

/// 电池主题色配置
struct BatteryTheme: Equatable {
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

    init(
        themeColor: UIColor,
        backgroundColor: UIColor? = nil,
        criticalColor: UIColor = UIColor(hexStr: "#D20307"),
        lowColor: UIColor = UIColor(hexStr: "#F38245"),
        accentTextColor: UIColor? = nil
    ) {
        self.themeColor = themeColor
        self.backgroundColor = backgroundColor ?? themeColor.withAlphaComponent(0.2)
        self.criticalColor = criticalColor
        self.lowColor = lowColor
        self.accentTextColor = accentTextColor ?? themeColor.withAlphaComponent(0.5)
    }

    func fillColor(for state: BatteryLevelState) -> UIColor? {
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

    func percentTextColor(for state: BatteryLevelState) -> UIColor {
        switch state {
        case .critical, .shutdown:
            return criticalColor
        case .low:
            return lowColor
        case .normal, .full:
            return accentTextColor
        }
    }
}

// MARK: - BatteryLayoutMetrics

/// 基于 `icon_battery_panel`（20×10pt）标定的布局参数
enum BatteryLayoutMetrics {
    static let designSize = CGSize(width: 20, height: 10)
    /// 电量条内边距：左 2 / 上 2 / 下 2 / 右 4（右侧预留正极凸起）
    static let fillInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 2)
    static let fillCornerRadius: CGFloat = 2.5
    static let flashSize = CGSize(width: 8, height: 8)

    static func scaledInsets(for size: CGSize) -> UIEdgeInsets {
        let scale = size.width / designSize.width
        return UIEdgeInsets(
            top: fillInsets.top * scale,
            left: fillInsets.left * scale,
            bottom: fillInsets.bottom * scale,
            right: fillInsets.right * scale
        )
    }

    static func scaledFlashSize(for size: CGSize) -> CGSize {
        let scale = size.width / designSize.width
        return CGSize(width: flashSize.width * scale, height: flashSize.height * scale)
    }
}
