//
//  ConnectivityDemoController.swift
//  AppTemplate
//
//  ConnectivityCenter 网络连通性示例（L1/L2/L3 + 监听）。

import AppStart
import SnapKit
import UIKit

// MARK: - Main Class

/// 演示 `status()` / `status(.validated)` / `monitor()` / 蜂窝数据策略。
class ConnectivityDemoController: DefaultViewController {

    private enum Action: CaseIterable {
        case refreshPath
        case validate
        case validateForce
        case toggleMonitor
        case cellularPolicy

        var title: String {
            switch self {
            case .refreshPath: return "刷新路径状态 (L1+L2)"
            case .validate: return "L3 探测（debounce）"
            case .validateForce: return "强制 L3 探测"
            case .toggleMonitor: return "路径监听"
            case .cellularPolicy: return "蜂窝/WLAN 数据策略"
            }
        }

        var subtitle: String {
            switch self {
            case .refreshPath: return "同步，不发起 HTTP"
            case .validate: return "await status(.validated())"
            case .validateForce: return "await status(.validated(force: true))"
            case .toggleMonitor: return "Wi‑Fi/蜂窝切换时推送"
            case .cellularPolicy: return "设置 → 蜂窝网络 → 本 App"
            }
        }
    }

    private var isMonitoring = false
    private var monitorTask: Task<Void, Never>?
    private var latestSnapshot: ConnectivitySnapshot?
    private var cellularPolicyText = "—"

    private lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = """
        L1 链路 / L2 路径：`status()` 同步读取
        L3 互联网：仅点击探测行时发 HTTP（无后台轮询）
        开启监听后切换 Wi‑Fi/蜂窝可验证路径推送
        """
        return label
    }()

    private lazy var summaryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 0
        label.text = "—"
        return label
    }()

    private lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = "—"
        return label
    }()

    private lazy var tableView: TableView = {
        let listView = TableView(frame: .zero, style: .plain)
        listView.backgroundColor = .systemBackground
        listView.registerCell(DefaultTableViewCell.self)
        listView.tableFooterView = UIView(frame: .zero)
        listView.dataSource = self
        listView.delegate = self
        listView.rowHeight = 58
        return listView
    }()

    override func setupLayout() {
        super.setupLayout()
        naviBar.title = "网络连通性"

        view.addSubview(hintLabel)
        view.addSubview(summaryLabel)
        view.addSubview(detailLabel)
        view.addSubview(tableView)

        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(naviBar.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        summaryLabel.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(summaryLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(detailLabel.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshPathStatus()
        refreshCellularPolicy()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopMonitor()
    }

    @MainActor
    private func refreshPathStatus() {
        applySnapshot(ConnectivityCenter.shared.status())
    }

    @MainActor
    private func refreshValidated(force: Bool) async {
        summaryLabel.text = force ? "强制探测中…" : "探测中…"
        let snap = await ConnectivityCenter.shared.status(.validated(force: force))
        applySnapshot(snap)
    }

    @MainActor
    private func refreshCellularPolicy() {
        let policy = ConnectivityCenter.shared.cellularDataPolicy()
        switch policy {
        case .unrestricted:
            cellularPolicyText = "未受限"
        case .restricted:
            cellularPolicyText = "已受限"
        case .unknown:
            cellularPolicyText = "未知"
        }
        updateDetailLabel()
        tableView.reloadData()
    }

    @MainActor
    private func applySnapshot(_ snap: ConnectivitySnapshot) {
        latestSnapshot = snap
        summaryLabel.text = snap.summaryText
        updateDetailLabel()
    }

    @MainActor
    private func updateDetailLabel() {
        guard let snap = latestSnapshot else {
            detailLabel.text = "蜂窝策略：\(cellularPolicyText)"
            return
        }
        detailLabel.text = """
        canAttemptRequest: \(snap.canAttemptRequest)
        isInternetReady: \(snap.isInternetReady)
        validation: \(snap.validation.displayText)
        expensive: \(snap.isExpensive) · constrained: \(snap.isConstrained)
        蜂窝策略: \(cellularPolicyText)
        """
    }

    @MainActor
    private func toggleMonitor() {
        isMonitoring ? stopMonitor() : startMonitor()
        tableView.reloadRows(at: [IndexPath(row: Action.allCases.firstIndex(of: .toggleMonitor)!, section: 0)], with: .none)
    }

    @MainActor
    private func startMonitor() {
        guard monitorTask == nil else { return }
        isMonitoring = true
        monitorTask = Task { [weak self] in
            for await snap in ConnectivityCenter.shared.monitor() {
                guard !Task.isCancelled else { break }
                await MainActor.run {
                    self?.applySnapshot(snap)
                }
            }
        }
    }

    @MainActor
    private func stopMonitor() {
        monitorTask?.cancel()
        monitorTask = nil
        isMonitoring = false
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension ConnectivityDemoController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Action.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let action = Action.allCases[indexPath.row]
        let cell = tableView.getReusableCell(DefaultTableViewCell.self)
        if action == .toggleMonitor {
            cell.titleLabel.text = isMonitoring ? "停止路径监听" : "开始路径监听"
        } else {
            cell.titleLabel.text = action.title
        }
        cell.detailLabel.text = action.subtitle
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let action = Action.allCases[indexPath.row]
        switch action {
        case .refreshPath:
            refreshPathStatus()
        case .validate:
            Task { @MainActor in await refreshValidated(force: false) }
        case .validateForce:
            Task { @MainActor in await refreshValidated(force: true) }
        case .toggleMonitor:
            toggleMonitor()
        case .cellularPolicy:
            refreshCellularPolicy()
        }
    }
}
