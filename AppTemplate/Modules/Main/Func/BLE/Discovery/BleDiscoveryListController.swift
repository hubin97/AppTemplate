//
//  BleDiscoveryListController.swift
//  AppTemplate
//
//  发现扫描：混扫已注册产品，点选设备握手并写入业务设备管理。
//  进入即扫；下拉刷新重扫；单次 30s。

import Foundation
import CoreBluetooth
import AppStart

class BleDiscoveryListController: DefaultViewController {

    private struct DeviceRow {
        let discovery: BleDiscovery
        var name: String { discovery.displayName ?? "未命名设备" }
        var mac: String {
            (discovery.parsedData as? BleProtocolParseResult)?.mac ?? "—"
        }
        var uuid: String { discovery.peripheral.identifier.uuidString }
        var rssi: Int { discovery.advertisement.rssi.intValue }
    }

    private enum SignalFilter: Int, CaseIterable {
        case all
        case stronger
        case nearby

        var title: String {
            switch self {
            case .all: return "全部"
            case .stronger: return "较强"
            case .nearby: return "极强"
            }
        }

        func matches(_ rssi: Int) -> Bool {
            switch self {
            case .all: return true
            case .stronger: return rssi >= -70
            case .nearby: return rssi >= -50
            }
        }
    }

    private var devices: [DeviceRow] = []
    private var nameQuery = ""
    private var signalFilter: SignalFilter = .all
    private var scanTask: Task<Void, Never>?
    private var bindTask: Task<Void, Never>?

    private var filteredDevices: [DeviceRow] {
        devices.filter { row in
            let nameOK = nameQuery.isEmpty || row.name.localizedCaseInsensitiveContains(nameQuery)
            return nameOK && signalFilter.matches(row.rssi)
        }
    }

    private lazy var nameField: UITextField = {
        let field = UITextField()
        field.placeholder = "按外设名筛选"
        field.borderStyle = .none
        field.backgroundColor = BleUITokens.cardBackground
        field.layer.cornerRadius = BleUITokens.radiusBadge
        field.layer.borderWidth = 0.5
        field.layer.borderColor = BleUITokens.border.cgColor
        field.font = .systemFont(ofSize: 14)
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 36))
        field.leftViewMode = .always
        field.clearButtonMode = .whileEditing
        field.addTarget(self, action: #selector(nameChanged), for: .editingChanged)
        return field
    }()

    private lazy var signalControl: UISegmentedControl = {
        let control = UISegmentedControl(items: SignalFilter.allCases.map(\.title))
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(signalChanged), for: .valueChanged)
        return control
    }()

    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = BleUITokens.textSecondary
        label.numberOfLines = 0
        label.text = "点某一台即可握手添加"
        return label
    }()

    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = BleUITokens.textSecondary
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private lazy var tableView: TableView = {
        let listView = TableView(frame: .zero, style: .plain)
        listView.registerCell(BleDiscoveryDeviceCell.self)
        listView.tableFooterView = UIView(frame: .zero)
        listView.separatorStyle = .none
        listView.backgroundColor = BleUITokens.pageBackground
        listView.dataSource = self
        listView.delegate = self
        listView.rowHeight = 64
        listView.contentInset = UIEdgeInsets(top: BleUITokens.space1, left: 0, bottom: 0, right: 0)
        listView.setHeaderRefresh { [weak self] in
            self?.startScanning()
        }
        return listView
    }()

    override func setupLayout() {
        super.setupLayout()
        naviBar.title = "附近设备"
        view.backgroundColor = BleUITokens.pageBackground

        view.addSubview(nameField)
        view.addSubview(signalControl)
        view.addSubview(statusLabel)
        view.addSubview(tableView)
        view.addSubview(emptyLabel)

        nameField.snp.makeConstraints { make in
            make.top.equalTo(naviBar.snp.bottom).offset(BleUITokens.space3)
            make.leading.equalToSuperview().offset(BleUITokens.space4)
            make.height.equalTo(36)
        }
        signalControl.snp.makeConstraints { make in
            make.centerY.equalTo(nameField)
            make.leading.equalTo(nameField.snp.trailing).offset(BleUITokens.space2)
            make.trailing.equalToSuperview().inset(BleUITokens.space4)
            make.width.equalTo(168)
        }
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(nameField.snp.bottom).offset(BleUITokens.space2)
            make.leading.trailing.equalToSuperview().inset(BleUITokens.space4)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(BleUITokens.space3)
            make.leading.trailing.bottom.equalToSuperview()
        }
        emptyLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(tableView).offset(48)
            make.leading.trailing.equalToSuperview().inset(32)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScanning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanning()
    }

    override var themeableTableViews: [UITableView] { [tableView] }

    @objc private func nameChanged() {
        nameQuery = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        reloadVisible()
    }

    @objc private func signalChanged() {
        signalFilter = SignalFilter(rawValue: signalControl.selectedSegmentIndex) ?? .all
        reloadVisible()
    }

    private func startScanning() {
        cancelScanTask()
        devices.removeAll()
        reloadVisible()
        statusLabel.text = "正在找附近的设备…"

        scanTask = Task { [weak self] in
            guard let self else { return }
            let stream = BleSession.shared.scanAllProducts(timeout: 30)
            for await discovery in stream {
                guard !Task.isCancelled else { break }
                await MainActor.run {
                    self.appendDiscovery(discovery)
                }
            }
            await MainActor.run {
                self.tableView.mj_header?.endRefreshing()
                guard !Task.isCancelled else { return }
                self.statusLabel.text = "扫描结束，共 \(self.devices.count) 台"
                self.reloadVisible()
            }
        }
    }

    private func cancelScanTask() {
        scanTask?.cancel()
        scanTask = nil
        BleSession.shared.central.stopScanning()
    }

    private func stopScanning() {
        cancelScanTask()
        tableView.mj_header?.endRefreshing()
    }

    private func appendDiscovery(_ discovery: BleDiscovery) {
        let id = discovery.peripheral.identifier
        let row = DeviceRow(discovery: discovery)
        if let index = devices.firstIndex(where: { $0.discovery.peripheral.identifier == id }) {
            devices[index] = row
        } else {
            devices.append(row)
        }
        statusLabel.text = "正在找附近的设备… 已发现 \(devices.count) 台"
        reloadVisible()
    }

    private func reloadVisible() {
        tableView.reloadData()
        if devices.isEmpty {
            emptyLabel.isHidden = false
            emptyLabel.text = "附近还没扫到设备。把设备开到可被发现，下拉刷新再试"
        } else if filteredDevices.isEmpty {
            emptyLabel.isHidden = false
            if !nameQuery.isEmpty {
                emptyLabel.text = "没找到叫「\(nameQuery)」的设备，换个词试试"
            } else {
                emptyLabel.text = "当前信号筛选下没有设备，试试「全部」"
            }
        } else {
            emptyLabel.isHidden = true
        }
    }

    private func bind(row: DeviceRow) {
        stopScanning()
        bindTask?.cancel()
        bindTask = Task { [weak self] in
            guard let self else { return }
            await MainActor.run {
                ProgressHUD.animate("正在握手…")
            }
            do {
                let device = try await BleDeviceBinder.bind(discovery: row.discovery)
                await MainActor.run {
                    ProgressHUD.succeed("已添加 \(device.displayName)")
                    self.navigator.show(provider: AppScene.bleBoundList, sender: self)
                }
            } catch BleError.connectionTimeout {
                await MainActor.run {
                    ProgressHUD.failed("连接超时，靠近设备再试一次")
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
extension BleDiscoveryListController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredDevices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = filteredDevices[indexPath.row]
        let cell = tableView.getReusableCell(BleDiscoveryDeviceCell.self)
        cell.configure(name: row.name, mac: row.mac, uuid: row.uuid, rssi: row.rssi)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        bind(row: filteredDevices[indexPath.row])
    }
}
