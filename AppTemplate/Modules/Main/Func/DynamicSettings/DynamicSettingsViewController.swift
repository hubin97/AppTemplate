//
//  DynamicSettingsViewController.swift
//  AppTemplate
//
//  Created by hubin.h on 2026/5/4.
//  Copyright © 2025 hubin.h. All rights reserved.

import Foundation
import UIKit

// MARK: - Global Variables & Functions (if necessary)

// MARK: - Main Class

/// 动态设置列表页基类：默认绑定 ``DynamicSettingsViewModel`` 与 ``DynamicSettingsCell``。
///
/// **扩展方式**
/// - **组合**：`DynamicSettingsViewModel(panelSource: 自定义 Source)` 传入路由。
/// - **子类**：覆盖 ``handleNavigationItem(_:)``、``dynamicSettingsNavigationTitle``、``showsBridgeJSONExportButton`` 等，接入业务路由或隐藏调试入口。
class DynamicSettingsViewController: DefaultViewController, ViewModelProvider {
    typealias ViewModelType = DynamicSettingsViewModel

    private lazy var jsonButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        button.setTitle("JSON", for: .normal)
        button.addTarget(self, action: #selector(onCopyBridgeJSON), for: .touchUpInside)
        return button
    }()

    lazy var tableView: TableView = {
        let listView = TableView(frame: CGRect.zero, style: .grouped)
        listView.backgroundColor = .white
        listView.registerCell(DynamicSettingsCell.self)
        listView.tableFooterView = UIView(frame: CGRect.zero)
        listView.rowHeight = 50
        listView.dataSource = self
        listView.delegate = self
        return listView
    }()

    /// 导航栏标题；子类可覆盖。
    open var dynamicSettingsNavigationTitle: String { "动态设置 Demo" }

    /// 是否展示右上角 JSON 导出（模板调试）；业务上线页可改为 `false`。
    open var showsBridgeJSONExportButton: Bool { true }

    open override func setupLayout() {
        super.setupLayout()
        view.addSubview(tableView)
        naviBar.title = dynamicSettingsNavigationTitle
        naviBar.setRightView(showsBridgeJSONExportButton ? jsonButton : nil) 

        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(naviBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    override func bindViewModel() {
        super.bindViewModel()
        withThemeUpdates { (self, theme) in
            self.tableView.backgroundColor = theme.tableViewColor
        }

        vm.panel
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: rx.disposeBag)
    }

    /// `navigation` 类型条目选中时调用；默认弹出路由信息 Alert，子类可改为 `navigator.show` 等。
    open func handleNavigationItem(_ item: SettingItemModel) {
        let route = item.payload.routeName ?? "(nil)"
        let params = item.payload.routeParams?.map { "\($0.key)=\($0.value)" }.joined(separator: ", ") ?? ""
        let msg = [route, params].filter { !$0.isEmpty }.joined(separator: "\n")
        let alert = UIAlertController(title: "Navigation 演示", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Private Methods
extension DynamicSettingsViewController {
}

// MARK: - Callbacks
extension DynamicSettingsViewController {

    @objc
    private func onCopyBridgeJSON() {
        UIPasteboard.general.string = vm.bridgeSnapshot.value
        let alert = UIAlertController(title: "Bridge 快照", message: "已复制到剪贴板（RN 可用同一结构）", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Utilities & Helpers
extension DynamicSettingsViewController {
}

// MARK: - Delegate & Data Source
extension DynamicSettingsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return vm.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.numberOfRows(in: section)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return vm.titleForHeader(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = vm.item(at: indexPath)
        let cell = tableView.getReusableCell(DynamicSettingsCell.self)
        cell.configure(item: item) { [weak self] isOn in
            self?.vm.setToggle(itemId: item.id, isOn: isOn)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = vm.item(at: indexPath)
        guard item.type == DynamicSettingItemType.navigation else { return }
        handleNavigationItem(item)
    }
}
