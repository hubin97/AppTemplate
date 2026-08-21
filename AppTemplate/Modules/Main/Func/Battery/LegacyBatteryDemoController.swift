//
//  LegacyBatteryDemoController.swift
//  AppTemplate
//
//  Created by hubin.h on 2026/7/13.
//  Copyright © 2026 hubin.h. All rights reserved.

import UIKit
import SnapKit

// MARK: - BatteryDemoController

class LegacyBatteryDemoController: DefaultViewController {

    private struct DemoCase {
        let title: String
        let percent: Int
        let isCharging: Bool
        let showsPercent: Bool
    }

    private let themeColor = UIColor(hexStr: "#770523")
    private let backgroundColor = UIColor(hexStr: "#770523").withAlphaComponent(0.2)
//    private let themeColor = UIColor(hexStr: "#552C95")
//    private let backgroundColor = UIColor(hexStr: "#552C95").withAlphaComponent(0.2)

    private let batteryTrailingInset: CGFloat = 80
    private let batteryJson: [String: Any] = [
        "thresholds": [
            "W1": [
                "criticalMax": 0,
                "lowMax": 20,
            ],
            "M5P0": [
                "criticalMax": 0,
                "lowMax": 19,
            ],
            "Air1": [
                "criticalMax": 0,
                "lowMax": 19,
            ],
            "M9": [
                "criticalMax": 0,
                "lowMax": 30,
            ],
            "V3Pro": [
                "criticalMax": 0,
                "lowMax": 20,
            ]
        ]
    ]
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.register(BatteryDemoCell.self, forCellReuseIdentifier: BatteryDemoCell.reuseId)
        table.dataSource = self
        table.delegate = self
        table.rowHeight = 56
        return table
    }()

    private let cases: [DemoCase] = [
        DemoCase(title: "即将关机 0%", percent: 0, isCharging: false, showsPercent: true),
        DemoCase(title: "即将关机 0% · 充电中", percent: 0, isCharging: true, showsPercent: true),
        DemoCase(title: "超低电 5%", percent: 5, isCharging: false, showsPercent: true),
        DemoCase(title: "超低电 5% · 充电中", percent: 5, isCharging: true, showsPercent: true),
        DemoCase(title: "低电 15%", percent: 15, isCharging: false, showsPercent: true),
        DemoCase(title: "低电 15% · 充电中", percent: 15, isCharging: true, showsPercent: true),
        DemoCase(title: "正常 60%", percent: 60, isCharging: false, showsPercent: true),
        DemoCase(title: "正常 60% · 充电中", percent: 60, isCharging: true, showsPercent: true),
        DemoCase(title: "满电 100%", percent: 100, isCharging: false, showsPercent: true),
        DemoCase(title: "满电 100% · 充电中", percent: 100, isCharging: true, showsPercent: true),
        DemoCase(title: "仅图标 30%", percent: 30, isCharging: false, showsPercent: false)
    ]

    override func setupLayout() {
        super.setupLayout()
        naviBar.title = "Battery"
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(naviBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: - UITableViewDataSource & Delegate
extension LegacyBatteryDemoController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: BatteryDemoCell.reuseId,
            for: indexPath
        ) as? BatteryDemoCell else {
            return UITableViewCell()
        }
        let item = cases[indexPath.row]
        cell.configure(
            title: item.title,
            percent: item.percent,
            themeColor: themeColor,
            backgroundColor: backgroundColor,
            batteryTrailingInset: batteryTrailingInset,
            showsPercent: item.showsPercent,
            isCharging: item.isCharging
        )
        return cell
    }
}

// MARK: - BatteryDemoCell

private final class BatteryDemoCell: UITableViewCell {

    static let reuseId = "BatteryDemoCell"
    private enum Metrics {
        static let contentTrailingMargin: CGFloat = 16
    }

    private let titleLabel = UILabel()
    private let batteryView = BatteryView()
    private var batteryWidthConstraint: Constraint?

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
            make.trailing.equalToSuperview().inset(Metrics.contentTrailingMargin)
            make.centerY.equalToSuperview()
            batteryWidthConstraint = make.width.equalTo(56).constraint
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(
        title: String,
        percent: Int,
        themeColor: UIColor,
        backgroundColor: UIColor,
        batteryTrailingInset: CGFloat,
        showsPercent: Bool,
        isCharging: Bool
    ) {
        titleLabel.text = title
        batteryWidthConstraint?.update(offset: batteryTrailingInset)
        batteryView.render(
            percent: percent,
            themeColor: themeColor,
            backgroundColor: backgroundColor,
            showsPercent: showsPercent,
            isCharging: isCharging
        )
    }
}
