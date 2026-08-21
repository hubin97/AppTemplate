//
//  PowerBatteryDemoController.swift
//  AppTemplate
//
//  Created by hubin.h on 2026/7/13.
//  Copyright © 2026 hubin.h. All rights reserved.

import UIKit
import SnapKit

// MARK: - PowerBatteryDemoController

/// 新版 PowerBattery 组件 Demo（Figma 内显 · 格数协议 · 六种主题）
class PowerBatteryDemoController: DefaultViewController {

    private struct DemoCase {
        let title: String
        let configuration: PowerBatteryConfiguration
    }

    private struct DemoSection {
        let title: String
        let footer: String?
        let cases: [DemoCase]
        /// 白色主题等浅填充色在默认 Cell 上对比不足时使用
        let cellBackgroundColor: UIColor?

        init(
            title: String,
            footer: String? = nil,
            cases: [DemoCase],
            cellBackgroundColor: UIColor? = nil
        ) {
            self.title = title
            self.footer = footer
            self.cases = cases
            self.cellBackgroundColor = cellBackgroundColor
        }
    }

    private enum Metrics {
        static let whiteThemeCellBackground = UIColor(hexStr: "#F0F0F0")
    }

    private let themeColor = UIColor(hexStr: "#770523")
    private let backgroundColor = UIColor(hexStr: "#770523").withAlphaComponent(0.3)
    private lazy var theme = PowerBatteryThemePreset.black.theme //PowerBatteryTheme(themeColor: themeColor, backgroundColor: backgroundColor)

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.register(PowerBatteryDemoCell.self, forCellReuseIdentifier: PowerBatteryDemoCell.reuseId)
        table.dataSource = self
        table.delegate = self
        table.rowHeight = 56
        return table
    }()

    private lazy var sections: [DemoSection] = {
        [
            //DemoSection(title: "基础状态", cases: basicCases),
            DemoSection(title: "格数协议", cases: segmentCases),
        ] + themeSections
    }()

//    private lazy var basicCases: [DemoCase] = [
//        DemoCase(title: "即将关机 0%", configuration: .percent(percent: 0, theme: theme, showsShutdownDisplay: true)),
//        DemoCase(title: "即将关机 0%", configuration: .percent(percent: 0, theme: theme)),
//        DemoCase(title: "即将关机 0% · 充电中", configuration: .percent(percent: 0, theme: theme, isCharging: true, showsShutdownDisplay: true)),
//        DemoCase(title: "超低电 5%", configuration: .percent(percent: 5, theme: theme)),
//        DemoCase(title: "超低电 4%", configuration: .percent(percent: 4, theme: theme)),
//        DemoCase(title: "超低电 5% · 充电中", configuration: .percent(percent: 5, theme: theme, isCharging: true)),
//        DemoCase(title: "低电 15%", configuration: .percent(percent: 15, theme: theme)),
//        DemoCase(title: "低电 15% · 充电中", configuration: .percent(percent: 15, theme: theme, isCharging: true)),
//        DemoCase(title: "正常 60%", configuration: .percent(percent: 60, theme: theme)),
//        DemoCase(title: "正常 60% · 充电中", configuration: .percent(percent: 60, theme: theme, isCharging: true)),
//        DemoCase(title: "满电 100%", configuration: .percent(percent: 100, theme: theme)),
//        DemoCase(title: "满电 100% · 充电中", configuration: .percent(percent: 100, theme: theme, isCharging: true)),
//        DemoCase(title: "仅图标 30%", configuration: .percent(percent: 30, theme: theme, showsCenterText: false)),
//        DemoCase(title: "自定义低电(35%) · 低电 30%", configuration: .percent(
//            percent: 30,
//            theme: theme,
//            thresholds: PowerBatteryThresholds(criticalMax: 10, lowMax: 35)
//        )),
//    ]

    private lazy var segmentCases: [DemoCase] = [
        DemoCase(
            title: "格数 0/4 · 真实 8 · 超低电",
            configuration: .segment(
                progress: .segments(filled: 0, total: 4),
                realPercent: 8,
                theme: theme,
                reportStatus: .critical
            )
        ),
        DemoCase(
            title: "格数 1/4 · 真实 20 · 超低电",
            configuration: .segment(
                progress: .segments(filled: 1, total: 4),
                realPercent: 20,
                theme: theme,
                reportStatus: .critical
            )
        ),
        DemoCase(
            title: "格数 1/4 · 真实 42 · 低电",
            configuration: .segment(
                progress: .segments(filled: 1, total: 4),
                realPercent: 42,
                theme: theme,
                reportStatus: .low
            )
        ),
        DemoCase(
            title: "格数 2/4 · 不显示真实电量",
            configuration: .segment(
                progress: .segments(filled: 2, total: 4),
                realPercent: 85,
                theme: theme,
                showsCenterText: false
            )
        ),
        DemoCase(
            title: "格数 2/4 · 不显示真实电量 · 充电",
            configuration: .segment(
                progress: .progress(50),//(filled: 2, total: 4),
                realPercent: 85,
                theme: theme,
                isCharging: true,
                showsCenterText: false
            )
        ),
        DemoCase(
            title: "格数 2/4 · 真实 85",
            configuration: .segment(
                progress: .segments(filled: 2, total: 4),
                realPercent: 85,
                theme: theme,
                reportStatus: .normal
            )
        ),
        DemoCase(
            title: "格数 3/4 · 真实 72 · 充电",
            configuration: .segment(
                progress: .segments(filled: 3, total: 4),
                realPercent: 72,
                theme: theme,
                isCharging: true,
                reportStatus: .normal
            )
        ),
        DemoCase(
            title: "格数 4/4 · 真实 100",
            configuration: .segment(
                progress: .segments(filled: 4, total: 4),
                realPercent: 100,
                theme: theme,
                reportStatus: .normal
            )
        ),
        DemoCase(
            title: "格数 4/4 · 真实 90 · 充电",
            configuration: .segment(
                progress: .progress(100),
                realPercent: 90,
                theme: theme,
                isCharging: true,
                reportStatus: .normal
            )
        ),
        DemoCase(
            title: "格数 4/4 · 真实 100 · 充电",
            configuration: .segment(
                progress: .progress(100),
                realPercent: 100,
                theme: theme,
                isCharging: true,
                reportStatus: .normal
            )
        )
    ]

    /// Figma 27-21746：六种主题 × 五档状态及充电样式
    private var themeSections: [DemoSection] {
        PowerBatteryThemePreset.allCases.map { preset in
            let theme = preset.theme
            let hex = preset.fillColor.hexString
            return DemoSection(
                title: "百分比·主题 · \(preset.displayName)",
                footer: "填充 \(hex) · 背景 \(hex) 30%",
                cases: themePresetCases(for: theme),
                cellBackgroundColor: preset == .white ? Metrics.whiteThemeCellBackground : .white
            )
        }
    }

    private func themePresetCases(for theme: PowerBatteryTheme) -> [DemoCase] {
        [
            DemoCase(title: "即将关机(空电形态) 0%", configuration: .percent(percent: 0, theme: theme, showsShutdownDisplay: true)),
            DemoCase(title: "即将关机(空电形态) 0% · 充电中", configuration: .percent(percent: 0, theme: theme, isCharging: true, showsShutdownDisplay: true)),
            DemoCase(title: "即将关机 0%", configuration: .percent(percent: 0, theme: theme)),
            DemoCase(title: "即将关机 0% · 充电中", configuration: .percent(percent: 0, theme: theme, isCharging: true)),
            DemoCase(title: "超低电 5%", configuration: .percent(percent: 5, theme: theme)),
            DemoCase(title: "超低电 5% · 充电中", configuration: .percent(percent: 5, theme: theme, isCharging: true)),
            DemoCase(title: "低电 15%", configuration: .percent(percent: 15, theme: theme)),
            DemoCase(title: "低电 15% · 充电中", configuration: .percent(percent: 15, theme: theme, isCharging: true)),
            DemoCase(title: "正常 60%", configuration: .percent(percent: 60, theme: theme)),
            DemoCase(title: "正常 60% · 充电中", configuration: .percent(percent: 60, theme: theme, isCharging: true)),
            DemoCase(title: "满电 100%", configuration: .percent(percent: 100, theme: theme)),
            DemoCase(title: "满电 100% · 充电中", configuration: .percent(percent: 100, theme: theme, isCharging: true)),
            DemoCase(title: "自定义低电(35%) · 低电 30%", configuration: .percent(
                percent: 30,
                theme: theme,
                thresholds: PowerBatteryThresholds(criticalMax: 10, lowMax: 35)
            )),
            DemoCase(title: "自定义超低电(25%) · 超低电 21%", configuration: .percent(
                percent: 21,
                theme: theme,
                thresholds: PowerBatteryThresholds(criticalMax: 25, lowMax: 35)
            )),
        ]
    }

    override func setupLayout() {
        super.setupLayout()
        naviBar.title = "PowerBattery"
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(naviBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: - UITableViewDataSource & Delegate
extension PowerBatteryDemoController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].cases.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        sections[section].footer
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: PowerBatteryDemoCell.reuseId,
            for: indexPath
        ) as? PowerBatteryDemoCell else {
            return UITableViewCell()
        }
        let item = sections[indexPath.section].cases[indexPath.row]
        let backgroundColor = sections[indexPath.section].cellBackgroundColor
        cell.configure(
            title: item.title,
            configuration: item.configuration,
            backgroundColor: backgroundColor
        )
        return cell
    }
}

// MARK: - PowerBatteryDemoCell

private final class PowerBatteryDemoCell: UITableViewCell {

    static let reuseId = "PowerBatteryDemoCell"

    private let titleLabel = UILabel()
    private let batteryView = PowerBatteryView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        [titleLabel, batteryView].forEach(contentView.addSubview)
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = UIColor(hexStr: "#333333")
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        batteryView.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.trailing.lessThanOrEqualTo(batteryView.snp.leading).offset(-12)
            make.centerY.equalToSuperview()
        }
        batteryView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(
        title: String,
        configuration: PowerBatteryConfiguration,
        backgroundColor: UIColor? = nil
    ) {
        titleLabel.text = title
        batteryView.render(configuration)
        let color = backgroundColor ?? .clear
        self.backgroundColor = .white
        contentView.backgroundColor = color
    }
}
