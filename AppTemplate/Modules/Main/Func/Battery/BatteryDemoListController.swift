//
//  BatteryDemoListController.swift
//  AppTemplate
//
//  Created by hubin.h on 2026/7/13.
//  Copyright © 2026 hubin.h. All rights reserved.

import UIKit
import SnapKit

// MARK: - BatteryDemoListController

/// 电池组件 Demo 入口：旧版 Battery / 新版 PowerBattery
class BatteryDemoListController: DefaultViewController {

    private enum Item: String, CaseIterable {
        case legacy = "Battery（旧版）"
        case power = "PowerBattery（新版）"

        var subtitle: String {
            switch self {
            case .legacy:
                return "外显百分比 · 20×10 · 充电闪电居中"
            case .power:
                return "Figma 内显 · 格数协议 · 六种主题"
            }
        }
    }

    private lazy var tableView: TableView = {
        let listView = TableView(frame: .zero, style: .insetGrouped)
        listView.registerCell(DefaultTableViewCell.self)
        listView.tableFooterView = UIView(frame: .zero)
        listView.dataSource = self
        listView.delegate = self
        listView.rowHeight = 60
        return listView
    }()

    override func setupLayout() {
        super.setupLayout()
        naviBar.title = "Battery"
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(naviBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    override var themeableTableViews: [UITableView] { [tableView] }
}

// MARK: - UITableViewDataSource & Delegate
extension BatteryDemoListController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Item.allCases.count
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        "两套组件独立维护，可按业务场景选用"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = Item.allCases[indexPath.row]
        let cell = tableView.getReusableCell(DefaultTableViewCell.self)
        cell.titleLabel.text = item.rawValue
        cell.detailLabel.text = item.subtitle
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch Item.allCases[indexPath.row] {
        case .legacy:
            navigator.show(provider: AppScene.batteryLegacy, sender: self)
        case .power:
            navigator.show(provider: AppScene.powerBattery, sender: self)
        }
    }
}
