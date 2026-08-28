//
//  BleBoundDeviceListController.swift
//  AppTemplate
//
//  已绑定设备列表：展示握手入库后的设备，点击进入对应品类面板。
//  下拉刷新：混扫 15s，命中列表内 UUID 则尝试连接并刷新 RSSI。

import Foundation
import Combine
import AppStart

class BleBoundDeviceListController: DefaultViewController, ViewModelProvider {

    typealias ViewModelType = BleBoundDeviceListViewModel

    private var cancellables = Set<AnyCancellable>()

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
        listView.contentInset = UIEdgeInsets(top: BleUITokens.space1, left: 0, bottom: 0, right: 0)
        listView.rowHeight = UITableView.automaticDimension
        listView.estimatedRowHeight = 128
        listView.setHeaderRefresh { [weak self] in
            self?.vm.startScanningAndConnecting()
        }
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

        vm.$devices
            .receive(on: DispatchQueue.main)
            .sink { [weak self] devices in
                guard let self else { return }
                self.tableView.reloadData()
                self.emptyLabel.isHidden = !devices.isEmpty
            }
            .store(in: &cancellables)

        vm.scanFinished
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.tableView.mj_header?.endRefreshing()
            }
            .store(in: &cancellables)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vm.viewWillAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        vm.viewWillDisappear()
    }

    override var themeableTableViews: [UITableView] { [tableView] }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension BleBoundDeviceListController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.devices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.getReusableCell(BleBoundDeviceCell.self)
        cell.configure(vm.devices[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let device = vm.devices[indexPath.row]
        BleSession.shared.activeConnection = device.liveConnection
        navigator.show(provider: AppScene.bleDevicePanel(uuid: device.uuid), sender: self)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let device = vm.devices[indexPath.row]
        let remove = UIContextualAction(style: .destructive, title: "移除") { [weak self] _, _, completion in
            self?.vm.removeDevice(uuid: device.uuid)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [remove])
    }
}
