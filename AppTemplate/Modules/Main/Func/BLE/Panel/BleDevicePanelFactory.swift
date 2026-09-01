//
//  BleDevicePanelFactory.swift
//  AppTemplate
//
//  按已绑定设备品类选择面板。Pump 先复用控制台样式，其他品类给占位说明。

import Foundation

@MainActor
enum BleDevicePanelFactory {

    static func make(uuid: String) -> DefaultViewController {
        guard let device = BleDeviceManager.shared.device(uuid: uuid) else {
            return BleGenericPanelController(device: nil)
        }
        switch device.category {
        case .pump:
            return BlePumpPanelController(device: device)
        case .tempPatch, .phototherapy, .unknown:
            return BleGenericPanelController(device: device)
        }
    }
}
