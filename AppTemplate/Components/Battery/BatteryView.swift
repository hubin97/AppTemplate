//
//  BatteryView.swift
//  AppTemplate
//
//  Created by hubin.h on 2026/7/13.
//  Copyright © 2026 hubin.h. All rights reserved.

import UIKit
import SnapKit

// MARK: - BatteryView

/// 电池组件：图标 + 可选百分比文字
final class BatteryView: UIView {

    private lazy var contentView = UIView()

    private lazy var iconView = BatteryIconView()

    private lazy var percentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(contentView)
        [iconView, percentLabel].forEach(contentView.addSubview)
        contentView.snp.makeConstraints { $0.edges.equalToSuperview() }
        applyLayout(showsPercent: true)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private
extension BatteryView {

    private func applyLayout(showsPercent: Bool) {
        percentLabel.isHidden = !showsPercent

        iconView.snp.remakeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.size.equalTo(CGSize(width: 20, height: 10))
        }

        percentLabel.snp.removeConstraints()
        guard showsPercent else { return }
        percentLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(6)
            make.trailing.equalToSuperview()
            make.centerY.equalTo(iconView)
        }
    }
}

// MARK: - Public
extension BatteryView {

    /// 渲染电池状态
    /// - Parameters:
    ///   - percent: 电量百分比 0~100
    ///   - themeColor: 主题色（正常 / 满电填充色）
    ///   - backgroundColor: 内槽底色，默认 `#C2B0B5`
    ///   - showsPercent: 是否显示百分比文字
    ///   - isCharging: 是否充电中（叠加闪电图标）
    ///   - thresholds: 状态区分阈值，默认 0% 关机 / 1~10% 超低电 / 11~20% 低电 / 21~99% 正常 / 100% 满电
    ///   - theme: 完整主题配置，传入后覆盖 themeColor / backgroundColor 以外的默认色值
    func render(
        percent: Int,
        themeColor: UIColor,
        backgroundColor: UIColor = UIColor(hexStr: "#C2B0B5"),
        showsPercent: Bool = true,
        isCharging: Bool = false,
        thresholds: BatteryThresholds = .default,
        theme: BatteryTheme? = nil
    ) {
        let value = min(max(percent, 0), 100)
        let batteryTheme = theme ?? BatteryTheme(themeColor: themeColor, backgroundColor: backgroundColor)
        //let state = thresholds.levelState(for: value)

        percentLabel.text = "\(value)%"
        percentLabel.textColor = themeColor //batteryTheme.percentTextColor(for: state)
        iconView.render(
            percent: value,
            theme: batteryTheme,
            thresholds: thresholds,
            isCharging: isCharging
        )
        applyLayout(showsPercent: showsPercent)
    }
}
