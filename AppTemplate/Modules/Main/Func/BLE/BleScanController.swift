//
//  BleScanController.swift
//  AppTemplate
//
//  多产品混扫、按 productId 解析广播、连接并写入 BleSession.activeConnection。

import Foundation
import CoreBluetooth
import AppStart

// MARK: - Main Class
class BleScanController: DefaultViewController {

    private struct DeviceRow {
        let discovery: BleDiscovery
        var name: String { discovery.peripheral.name ?? "未知设备" }
        var productName: String { BleStateFormatter.productDisplayName(for: discovery.configuration) }
        var parsedDescription: String { BleStateFormatter.parsedDataDescription(for: discovery) }
        var rssi: Int { discovery.advertisement.rssi.intValue }
    }

    private var devices: [DeviceRow] = []
    private var scanTask: Task<Void, Never>?
    private var connectTask: Task<Void, Never>?

    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.text = "点击下方按钮开始扫描（20s 超时，混扫所有已注册产品）"
        return label
    }()

    private lazy var scanButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("开始扫描", for: .normal)
        button.addTarget(self, action: #selector(scanButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var stopButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("停止扫描", for: .normal)
        button.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var tableView: TableView = {
        let listView = TableView(frame: .zero, style: .plain)
        listView.registerCell(DefaultTableViewCell.self)
        listView.tableFooterView = UIView(frame: .zero)
        listView.dataSource = self
        listView.delegate = self
        listView.rowHeight = 72
        return listView
    }()

    override func setupLayout() {
        super.setupLayout()
        naviBar.title = "BLE 扫描"
        view.addSubview(statusLabel)
        view.addSubview(scanButton)
        view.addSubview(stopButton)
        view.addSubview(tableView)

        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(naviBar.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        scanButton.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
        }
        stopButton.snp.makeConstraints { make in
            make.centerY.equalTo(scanButton)
            make.leading.equalTo(scanButton.snp.trailing).offset(16)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(scanButton.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanning()
    }

    override var themeableTableViews: [UITableView] { [tableView] }

    @objc private func scanButtonTapped() {
        startScanning()
    }

    @objc private func stopButtonTapped() {
        stopScanning()
    }

    private func startScanning() {
        stopScanning()
        devices.removeAll()
        tableView.reloadData()
        statusLabel.text = "扫描中..."

        scanTask = Task { [weak self] in
            guard let self else { return }
            let stream = BleSession.shared.scanAllProducts(timeout: 20)
            for await discovery in stream {
                guard !Task.isCancelled else { break }
                await MainActor.run {
                    self.appendDiscovery(discovery)
                }
            }
            await MainActor.run {
                self.statusLabel.text = "扫描结束，共发现 \(self.devices.count) 台设备"
            }
        }
    }

    private func stopScanning() {
        scanTask?.cancel()
        scanTask = nil
        BleSession.shared.central.stopScanning()
    }

    private func appendDiscovery(_ discovery: BleDiscovery) {
        let id = discovery.peripheral.identifier
        if let index = devices.firstIndex(where: { $0.discovery.peripheral.identifier == id }) {
            devices[index] = DeviceRow(discovery: discovery)
        } else {
            devices.append(DeviceRow(discovery: discovery))
        }
        tableView.reloadData()
        statusLabel.text = "扫描中... 已发现 \(devices.count) 台设备"
    }

    private func connect(to row: DeviceRow, setAsActive: Bool) {
        connectTask?.cancel()
        connectTask = Task { [weak self] in
            guard let self else { return }
            await MainActor.run {
                ProgressHUD.animate(setAsActive ? "连接中..." : "追加连接...")
            }
            do {
                _ = try await BleSession.shared.connect(
                    discovery: row.discovery,
                    setAsActive: setAsActive
                )
                let count = BleSession.shared.activeConnections.count
                await MainActor.run {
                    ProgressHUD.succeed(setAsActive ? "已连接" : "已追加（共 \(count) 台）")
                    if setAsActive {
                        self.navigator.show(provider: AppScene.bleConnection, sender: self)
                    }
                }
            } catch BleError.connectionTimeout {
                await MainActor.run {
                    ProgressHUD.failed("连接超时")
                }
            } catch {
                await MainActor.run {
                    ProgressHUD.failed(error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension BleScanController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        devices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = devices[indexPath.row]
        let cell = tableView.getReusableCell(DefaultTableViewCell.self)
        cell.titleLabel.text = "\(row.productName) · \(row.name)"
        cell.detailLabel.text = "\(row.parsedDescription)  RSSI: \(row.rssi)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        stopScanning()
        connect(to: devices[indexPath.row], setAsActive: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let row = devices[indexPath.row]
        let append = UIContextualAction(style: .normal, title: "追加连接") { [weak self] _, _, completion in
            self?.connect(to: row, setAsActive: false)
            completion(true)
        }
        append.backgroundColor = .systemTeal
        return UISwipeActionsConfiguration(actions: [append])
    }
}
