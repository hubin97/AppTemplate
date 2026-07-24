//
//  BleTestListController.swift
//  AppTemplate
//
//  BLE 测试场景入口。

import Foundation
import AppStart

// MARK: - Main Class
class BleTestListController: DefaultViewController {

    enum Item: String, CaseIterable {
        case centralState = "蓝牙状态监控"
        case scan = "扫描并连接"
        case connection = "连接控制台（复用 Session）"
    }

    private lazy var tableView: TableView = {
        let listView = TableView(frame: .zero, style: .plain)
        listView.backgroundColor = .white
        listView.registerCell(DefaultTableViewCell.self)
        listView.tableFooterView = UIView(frame: .zero)
        listView.dataSource = self
        listView.delegate = self
        listView.rowHeight = 50
        return listView
    }()

    private lazy var sessionInfoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    override func setupLayout() {
        super.setupLayout()
        naviBar.title = "BLE 测试"
        view.addSubview(sessionInfoLabel)
        view.addSubview(tableView)

        sessionInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(naviBar.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(sessionInfoLabel.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshSessionInfo()
    }

    private func refreshSessionInfo() {
        let names = BleSession.shared.registeredConfigurations
            .map { BleStateFormatter.productDisplayName(for: $0) }
            .joined(separator: "、")
        let profileLine = names.isEmpty ? "无" : names

        if let connection = BleSession.shared.activeConnection {
            let name = connection.peripheral.name ?? "未知设备"
            let state = BleStateFormatter.peripheralStateDescription(connection.currentState)
            sessionInfoLabel.text = """
            已注册产品：\(profileLine)
            当前会话：\(name)
            状态：\(state)
            """
        } else {
            sessionInfoLabel.text = """
            已注册产品：\(profileLine)
            当前会话：无活跃连接
            """
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension BleTestListController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Item.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = Item.allCases[indexPath.row]
        let cell = tableView.getReusableCell(DefaultTableViewCell.self)
        cell.titleLabel.text = item.rawValue
        cell.detailLabel.text = nil
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = Item.allCases[indexPath.row]
        switch item {
        case .centralState:
            navigator.show(provider: AppScene.bleCentralState, sender: self)
        case .scan:
            navigator.show(provider: AppScene.bleScan, sender: self)
        case .connection:
            navigator.show(provider: AppScene.bleConnection, sender: self)
        }
    }
}
