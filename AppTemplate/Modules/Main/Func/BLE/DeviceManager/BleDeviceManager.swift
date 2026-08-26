//
//  BleDeviceManager.swift
//  AppTemplate
//
//  业务层已绑定设备列表：握手成功后入库，设备列表页订阅变更。

import Foundation
import AppStart

final class BleDeviceManager {

    static let shared = BleDeviceManager()

    private let defaultsKey = "ble.bound.devices"
    private(set) var devices: [BleBoundDevice] = []

    var onChange: (() -> Void)?

    private init() {
        load()
    }

    func device(uuid: String) -> BleBoundDevice? {
        devices.first { $0.uuid.caseInsensitiveCompare(uuid) == .orderedSame }
    }

    func upsert(_ device: BleBoundDevice) {
        if let index = devices.firstIndex(where: { $0.uuid.caseInsensitiveCompare(device.uuid) == .orderedSame }) {
            devices[index] = device
        } else {
            devices.insert(device, at: 0)
        }
        persist()
        onChange?()
    }

    func remove(uuid: String) {
        devices.removeAll { $0.uuid.caseInsensitiveCompare(uuid) == .orderedSame }
        persist()
        onChange?()
    }

    // MARK: - Persistence

    private func persist() {
        guard let data = try? JSONEncoder().encode(devices) else { return }
        UserDefaults.standard.set(data, forKey: defaultsKey)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey),
              let stored = try? JSONDecoder().decode([BleBoundDevice].self, from: data) else {
            devices = []
            return
        }
        devices = stored
    }
}

enum BleDeviceBinder {

    /// 点击发现设备：连接 → 握手（Pump 走 F0/FD/F7，其他品类以 GATT 就绪为准）→ 写入设备管理。
    static func bind(discovery: BleDiscovery) async throws -> BleBoundDevice {
        let connection = try await BleSession.shared.connect(discovery: discovery, setAsActive: true)
        var handshakeProfile: String?
        var productKey: String?

        if BleDeviceCategory.resolve(configuration: discovery.configuration) == .pump {
            let result = try await BlePumpHandshake.run(on: connection, log: { _ in })
            handshakeProfile = result.profile?.logName
            productKey = result.tripletInfo?.productKey
        }

        let device = BleBoundDevice.make(
            from: discovery,
            handshakeProfile: handshakeProfile,
            f0ProductKey: productKey
        )
        BleDeviceManager.shared.upsert(device)
        return device
    }
}
