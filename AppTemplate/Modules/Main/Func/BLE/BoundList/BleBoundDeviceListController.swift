//
//  BleBoundDeviceListController.swift
//  AppTemplate
//
//  已绑定设备列表：展示握手入库后的设备，点击进入对应品类面板。

import Foundation
import AppStart

class BleBoundDeviceListController: DefaultViewController {

    private var devices: [BleBoundDevice] = []

    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = BleUITokens.textSecondary
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "还没有绑定过设备。去「附近设备」点一台，握手成功就会出现在这里"
        return label
    }()

    private lazy var tableView: TableView = {
        let listView = TableView(frame: .zero, style: .plain)
        listView.registerCell(BleBoundDeviceCell.self)
        listView.tableFooterView = UIView(frame: .zero)
        listView.separatorStyle = .none
        listView.backgroundColor = BleUITokens.pageBackground
        listView.dataSource = self
        listView.delegate = self
        listView.rowHeight = UITableView.automaticDimension
        listView.estimatedRowHeight = 128
        return listView
    }()

    override func setupLayout() {
        super.setupLayout()
        naviBar.title = "我的设备"
        view.backgroundColor = BleUITokens.pageBackground
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(naviBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        emptyLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(naviBar.snp.bottom).offset(48)
            make.leading.trailing.equalToSuperview().inset(32)
        }
    }

    override func bindViewModel() {
        super.bindViewModel()
        BleDeviceManager.shared.onChange = { [weak self] in
            self?.reload()
        }
        reload()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }

    override var themeableTableViews: [UITableView] { [tableView] }

    private func reload() {
        devices = BleDeviceManager.shared.devices
        tableView.reloadData()
        emptyLabel.isHidden = !devices.isEmpty
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension BleBoundDeviceListController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        devices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.getReusableCell(BleBoundDeviceCell.self)
        cell.configure(devices[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigator.show(provider: AppScene.bleDevicePanel(uuid: devices[indexPath.row].uuid), sender: self)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let device = devices[indexPath.row]
        let remove = UIContextualAction(style: .destructive, title: "移除") { _, _, completion in
            BleDeviceManager.shared.remove(uuid: device.uuid)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [remove])
    }
}
