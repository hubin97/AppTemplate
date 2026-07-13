//
//  BatteryIconView.swift
//  AppTemplate
//
//  Created by hubin.h on 2026/7/13.
//  Copyright © 2026 hubin.h. All rights reserved.

import UIKit

// MARK: - BatteryIconView

/// 电池图标
/// - `0%`：`icon_battery_low`
/// - `100%`：`icon_battery_panel` + 主题色 tint
/// - `1~99%`：`icon_battery_panel` + 底色 tint，再叠加百分比电量条
final class BatteryIconView: UIView {

    private enum DisplayMode {
        case shutdown
        case partial
        case full
    }

    private static let panelImage = R.image.icon_battery_panel()?.withRenderingMode(.alwaysTemplate)
    private static let flashImage = R.image.icon_battery_flash()?.withRenderingMode(.alwaysTemplate)

    private let panelImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()

    private let lowImageView: UIImageView = {
        let view = UIImageView(image: R.image.icon_battery_low())
        view.contentMode = .scaleAspectFit
        view.isHidden = true
        return view
    }()

    private let fillView: UIView = {
        let view = UIView()
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        view.isHidden = true
        return view
    }()

    private let flashImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.isHidden = true
        return view
    }()

    private var percent = 0
    private var levelState: BatteryLevelState = .normal
    private var theme = BatteryTheme(themeColor: UIColor(hexStr: "#84350E"))
    private var isCharging = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        [panelImageView, fillView, lowImageView, flashImageView].forEach(addSubview)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        BatteryLayoutMetrics.designSize
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutContent()
    }

    func render(
        percent: Int,
        theme: BatteryTheme,
        thresholds: BatteryThresholds = .default,
        isCharging: Bool = false
    ) {
        let value = min(max(percent, 0), 100)
        let mode = displayMode(for: value)
        self.percent = value
        self.theme = theme
        self.levelState = thresholds.levelState(for: value)
        self.isCharging = isCharging

        applyDisplayMode(mode)
        flashImageView.isHidden = !isCharging
        flashImageView.image = Self.flashImage
        flashImageView.tintColor = flashTintColor(for: mode)
        setNeedsLayout()
    }
}

// MARK: - Private
extension BatteryIconView {

    private func displayMode(for percent: Int) -> DisplayMode {
        switch percent {
        case 0: return .shutdown
        case 100: return .full
        default: return .partial
        }
    }

    private func applyDisplayMode(_ mode: DisplayMode) {
        switch mode {
        case .shutdown:
            panelImageView.isHidden = true
            fillView.isHidden = true
            lowImageView.isHidden = false
        case .full:
            lowImageView.isHidden = true
            fillView.isHidden = true
            panelImageView.isHidden = false
            panelImageView.image = Self.panelImage
            panelImageView.tintColor = theme.fillColor(for: levelState)
        case .partial:
            lowImageView.isHidden = true
            panelImageView.isHidden = false
            fillView.isHidden = false
            panelImageView.image = Self.panelImage
            panelImageView.tintColor = theme.backgroundColor
            fillView.backgroundColor = theme.fillColor(for: levelState)
        }
    }

    private func layoutContent() {
        let bounds = self.bounds
        guard bounds.width > 0, bounds.height > 0 else { return }

        panelImageView.frame = bounds
        lowImageView.frame = bounds

        let flashSize = BatteryLayoutMetrics.scaledFlashSize(for: bounds.size)
        flashImageView.frame = CGRect(
            x: bounds.midX - flashSize.width / 2,
            y: bounds.midY - flashSize.height / 2,
            width: flashSize.width,
            height: flashSize.height
        )

        guard displayMode(for: percent) == .partial else { return }

        let insets = BatteryLayoutMetrics.scaledInsets(for: bounds.size)
        let trackWidth = bounds.width - insets.left - insets.right
        let trackHeight = bounds.height - insets.top - insets.bottom
        let scale = bounds.width / BatteryLayoutMetrics.designSize.width
        let cornerRadius = min(BatteryLayoutMetrics.fillCornerRadius * scale, trackHeight / 2)

        fillView.layer.cornerRadius = cornerRadius
        fillView.frame = CGRect(
            x: insets.left,
            y: insets.top,
            width: trackWidth * CGFloat(percent) / 100,
            height: trackHeight
        )
    }

    private func flashTintColor(for mode: DisplayMode) -> UIColor {
        let dark = UIColor(hexStr: "#1B1821")
        switch mode {
        case .shutdown:
            return dark
        case .full:
            return .white
        case .partial:
            switch levelState {
            case .critical, .low:
                return dark
            case .normal:
                return .white
            case .shutdown, .full:
                return dark
            }
        }
    }
}
