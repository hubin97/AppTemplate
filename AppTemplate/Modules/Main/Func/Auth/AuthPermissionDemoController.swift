//
//  AuthPermissionDemoController.swift
//  AppTemplate
//
//  AuthorizationStatus async/await 权限校验示例。

import AppStart
import SnapKit
import UIKit

// MARK: - Main Class

/// 演示 `resolve(_:requestIfNeeded:)`：先系统服务、再 App 授权。
class AuthPermissionDemoController: DefaultViewController {

    struct Row: Equatable {
        let title: String
        let permission: AuthPermission

        static let all: [Row] = [
            Row(title: "推送 (APNs)", permission: .apns),
            Row(title: "相机", permission: .camera),
            Row(title: "相册", permission: .photoLibrary),
            Row(title: "麦克风", permission: .microphone),
            Row(title: "定位（使用期间）", permission: .location(.whenInUse)),
            Row(title: "定位（始终）", permission: .location(.always)),
            Row(title: "日历", permission: .calendar),
            Row(title: "提醒事项", permission: .reminder),
            Row(title: "Siri", permission: .siri),
            Row(title: "蓝牙", permission: .bluetooth),
            Row(title: "本地网络", permission: .localNetwork)
        ]
    }

    private var statusTexts: [Int: String] = [:]

    private lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = """
        先查系统服务，再查 App 授权（如蓝牙开关 → 蓝牙隐私）
        点击行：服务可用且未授权时请求授权
        长按行：仅刷新快照
        右上角按钮：打开系统设置
        """
        return label
    }()

    private lazy var tableView: TableView = {
        let listView = TableView(frame: .zero, style: .plain)
        listView.registerCell(DefaultTableViewCell.self)
        listView.tableFooterView = UIView(frame: .zero)
        listView.dataSource = self
        listView.delegate = self
        listView.rowHeight = 56
        return listView
    }()

    private lazy var settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("设置", for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        button.addTarget(self, action: #selector(openSettingsTapped), for: .touchUpInside)
        return button
    }()

    override func setupLayout() {
        super.setupLayout()
        naviBar.title = "权限校验"
        naviBar.setRightView(settingsButton)

        view.addSubview(hintLabel)
        view.addSubview(tableView)

        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(naviBar.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    override var themeableTableViews: [UITableView] { [tableView] }

    override func viewDidLoad() {
        super.viewDidLoad()
        // FIXME: 应该提前设置
        AuthStatus.configure {
            $0.isSiriCapabilityEnabled = true
            // 本地网络默认 grantConfirmationWait = 15s；误报已授权时可调大
            $0.localNetwork.grantConfirmationWait = 20
        }
        Task { await refreshAllStatuses() }
    }

    @objc private func openSettingsTapped() {
        AuthorizationStatus.shared.openSettings()
    }

    @MainActor
    private func refreshAllStatuses() async {
        for (index, _) in Row.all.enumerated() {
            await refreshRow(at: index, requestIfNeeded: false)
        }
    }

    @MainActor
    private func refreshRow(at index: Int, requestIfNeeded: Bool) async {
        let permission = Row.all[index].permission
        let snapshot = await AuthorizationStatus.resolve(permission, requestIfNeeded: requestIfNeeded)
        statusTexts[index] = snapshot.summaryText
        reloadRow(index)
    }

    @MainActor
    private func reloadRow(_ index: Int) {
        guard tableView.numberOfRows(inSection: 0) > index else { return }
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension AuthPermissionDemoController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Row.all.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = Row.all[indexPath.row]
        let cell = tableView.getReusableCell(DefaultTableViewCell.self)
        cell.titleLabel.text = row.title
        cell.detailLabel.text = statusTexts[indexPath.row] ?? "—"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        Task { @MainActor in
            await self.refreshRow(at: indexPath.row, requestIfNeeded: true)
        }
    }

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            UIMenu(children: [
                UIAction(title: "仅查询状态") { _ in
                    Task { @MainActor in
                        await self.refreshRow(at: indexPath.row, requestIfNeeded: false)
                    }
                }
            ])
        }
    }
}
