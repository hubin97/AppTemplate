//
//  PowerBatteryView.swift
//  AppTemplate
//
//  Created by hubin.h on 2026/8/21.
//  Copyright © 2026 hubin.h. All rights reserved.

import UIKit
import SnapKit

// MARK: - PowerBatteryView

/// 电池组件：数值与充电图标内显于电池主体居中
///
/// ```swift
/// let theme = PowerBatteryThemePreset.red.theme
///
/// // 百分比（填充 + 内显同源）
/// powerBatteryView.render(.percent(percent: 60, theme: theme))
/// powerBatteryView.render(.percent(percent: 0, theme: theme, showsShutdownDisplay: true))
/// powerBatteryView.render(.percent(percent: 100, theme: theme, isCharging: true))
/// powerBatteryView.render(.percent(
///     percent: 30,
///     theme: theme,
///     thresholds: PowerBatteryThresholds(criticalMax: 10, lowMax: 35)
/// ))
///
/// // 格数
/// powerBatteryView.render(.segment(
///     progress: .segments(filled: 2, total: 4),
///     realPercent: 85,
///     theme: theme
/// ))
/// powerBatteryView.render(.segment(
///     progress: .segments(filled: 0, total: 4),
///     realPercent: 8,
///     theme: theme,
///     reportStatus: .critical
/// ))
/// powerBatteryView.render(.segment(
///     progress: .progress(50),
///     realPercent: 85,
///     theme: theme,
///     isCharging: true,
///     showsCenterText: false
/// ))
/// ```
final class PowerBatteryView: UIView {

    private lazy var iconView = PowerBatteryIconView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.size.equalTo(PowerBatteryLayoutMetrics.designSize)
        }
        setContentCompressionResistancePriority(.required, for: .horizontal)
        setContentHuggingPriority(.required, for: .horizontal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func render(_ configuration: PowerBatteryConfiguration) {
        let model = PowerBatteryDisplayModel(configuration: configuration)
        iconView.render(
            model: model,
            theme: configuration.theme
        )
    }
}
