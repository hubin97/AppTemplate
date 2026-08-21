//
//  PowerBatteryIconView.swift
//  AppTemplate
//
//  Created by hubin.h on 2026/8/21.
//  Copyright © 2026 hubin.h. All rights reserved.

import UIKit

// MARK: - PowerBatteryIconView

/// 电池图标（对齐 Figma `battery-indicator` 27.33×13.67pt）
/// - `0%` 且 `showsShutdownDisplay == true`：`icon_battery_low` + 内显数值
/// - `100%`：`icon_battery_panel` 主题色填充
/// - `1~99%`：壳体 + 进度填充
/// - 内显：数值居中；充电时为「数值 + 闪电」水平组合居中
final class PowerBatteryIconView: UIView {

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
        view.isHidden = true
        return view
    }()

    private let centerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private let flashImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.isHidden = true
        return view
    }()

    private lazy var overlayStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [centerLabel, flashImageView])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 0
        stack.isUserInteractionEnabled = false
        stack.isHidden = true
        return stack
    }()

    private var model = PowerBatteryDisplayModel(
        fillPercent: 0,
        realPercent: nil,
        levelSource: .thresholds(.default),
        isCharging: false
    )
    private var levelState: PowerBatteryLevelState = .normal
    private var displayMode: DisplayMode = .partial
    private var theme = PowerBatteryTheme(themeColor: UIColor(hexStr: "#84350E"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        [panelImageView, fillView, lowImageView, overlayStack].forEach(addSubview)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        PowerBatteryLayoutMetrics.designSize
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutContent()
    }

    func render(model: PowerBatteryDisplayModel, theme: PowerBatteryTheme) {
        self.model = model
        self.theme = theme
        self.levelState = model.resolvedLevelState()
        self.displayMode = resolvedDisplayMode(for: model.clampedFillPercent)
        applyDisplayMode(displayMode)
        applyOverlay()
        setNeedsLayout()
    }
}

// MARK: - Private
extension PowerBatteryIconView {

    private func resolvedDisplayMode(for percent: Int) -> DisplayMode {
        if percent == 0, model.showsShutdownDisplay {
            return .shutdown
        }
        if model.isCharging {
            return percent >= 100 ? .full : .partial
        }
        switch percent {
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

    private func applyOverlay() {
        let centerText = model.resolvedCenterText()
        let showsFlash = model.isCharging
        let showsText = centerText != nil
        let displayLevel = model.clampedRealPercent ?? model.clampedFillPercent

        let overlayFontSize = PowerBatteryLayoutMetrics.resolvedCenterFontSize(
            displayLevel: displayLevel,
            isCharging: showsFlash
        )
        let overlayColor = theme.centerOverlayColor(for: levelState)

        centerLabel.font = .systemFont(ofSize: overlayFontSize, weight: .medium)
        centerLabel.textColor = overlayColor
        centerLabel.text = centerText
        centerLabel.isHidden = !showsText

        flashImageView.isHidden = !showsFlash
        if showsFlash {
            flashImageView.image = Self.flashImage
            flashImageView.tintColor = overlayColor
        }

        overlayStack.isHidden = !showsText && !showsFlash
        if showsText && showsFlash {
            overlayStack.setCustomSpacing(
                PowerBatteryLayoutMetrics.centerOverlayFlashOverlap,
                after: centerLabel
            )
        }
    }

    private func layoutContent() {
        let bounds = self.bounds
        guard bounds.width > 0, bounds.height > 0 else { return }

        panelImageView.frame = bounds
        lowImageView.frame = bounds
        layoutFill(in: bounds)
        layoutOverlay(in: bounds)
        bringSubviewToFront(overlayStack)
    }

    private func layoutFill(in bounds: CGRect) {
        guard displayMode == .partial else {
            fillView.isHidden = true
            return
        }
        fillView.isHidden = false

        let insets = PowerBatteryLayoutMetrics.scaledInsets(for: bounds.size)
        let trackWidth = bounds.width - insets.left - insets.right
        let trackHeight = bounds.height - insets.top - insets.bottom
        let scale = bounds.width / PowerBatteryLayoutMetrics.designSize.width
        let cornerRadius = min(PowerBatteryLayoutMetrics.fillCornerRadius * scale, trackHeight / 2)
        let fillWidth = trackWidth * CGFloat(model.clampedFillPercent) / 100

        var maskedCorners: CACornerMask = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        if trackWidth - fillWidth <= cornerRadius {
            maskedCorners.formUnion([.layerMaxXMinYCorner, .layerMaxXMaxYCorner])
        }

        fillView.frame = CGRect(
            x: insets.left,
            y: insets.top,
            width: fillWidth,
            height: trackHeight
        )
        fillView.setBorder(cornerRadius: cornerRadius, makeToBounds: true)
        fillView.layer.maskedCorners = maskedCorners
        fillView.layer.cornerCurve = .continuous
    }

    private func layoutOverlay(in bounds: CGRect) {
        guard !overlayStack.isHidden else {
            overlayStack.frame = .zero
            return
        }

        let bodyRect = PowerBatteryLayoutMetrics.bodyRect(in: bounds)
        let size = overlayStack.systemLayoutSizeFitting(bodyRect.size)
        overlayStack.frame = CGRect(
            x: bodyRect.midX - size.width / 2,
            y: bodyRect.midY - size.height / 2,
            width: size.width,
            height: size.height
        )
    }
}
