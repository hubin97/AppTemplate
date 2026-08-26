//
//  BlePumpPanelController.swift
//  AppTemplate
//
//  Pump 设备面板：当前按连接控制台样式落地。

import Foundation
import AppStart

class BlePumpPanelController: BleConnectionController {

    private let boundDevice: BleBoundDevice

    init(device: BleBoundDevice) {
        self.boundDevice = device
        super.init(viewModel: nil)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func bindViewModel() {
        BleSession.shared.activeConnection = boundDevice.liveConnection
        super.bindViewModel()
    }

    override func setupLayout() {
        super.setupLayout()
        naviBar.title = boundDevice.displayName
    }
}
