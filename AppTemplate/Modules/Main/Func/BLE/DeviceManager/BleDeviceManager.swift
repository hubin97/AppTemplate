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

    private var connectionStateTasks: [UUID: Task<Void, Never>] = [:]

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

    /// 订阅 Session 内各连接的 `states()`，驱动列表刷新连接态展示。
    func startObservingConnections() {
        syncConnectionStateObservers()
    }

    func stopObservingConnections() {
        connectionStateTasks.values.forEach { $0.cancel() }
        connectionStateTasks.removeAll()
    }

    // MARK: - Persistence

    private func persist() {
        guard let data = try? JSONEncoder().encode(devices) else { return }
        UserDefaults.standard.set(data, forKey: defaultsKey)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey) else {
            devices = []
            return
        }
        if let stored = try? JSONDecoder().decode([BleBoundDevice].self, from: data) {
            devices = stored
            return
        }
        devices = []
    }

    private func syncConnectionStateObservers() {
        let active = BleSession.shared.activeConnections
        let activeIDs = Set(active.map(\.peripheral.identifier))

        for (id, task) in connectionStateTasks where !activeIDs.contains(id) {
            task.cancel()
            connectionStateTasks.removeValue(forKey: id)
        }

        for connection in active {
            let id = connection.peripheral.identifier
            guard connectionStateTasks[id] == nil else { continue }
            connectionStateTasks[id] = Task { [weak self] in
                guard let self else { return }
                let stream = await connection.states()
                for await _ in stream {
                    guard !Task.isCancelled else { break }
                    await MainActor.run {
                        self.syncConnectionStateObservers()
                    }
                }
            }
        }
        onChange?()
    }
}

enum BleDeviceBinder {

    /// 点击发现设备：连接 → 握手（Pump 走 F0/FD/F7，其他品类以 GATT 就绪为准）→ 写入设备管理。
    static func bind(discovery: BleDiscovery) async throws -> BleBoundDevice {
        let connection = try await BleSession.shared.connect(discovery: discovery, setAsActive: true)
        var handshakeResult: BlePumpHandshakeResult?

        if BleDeviceCategory.resolve(configuration: discovery.configuration) == .pump {
            handshakeResult = try await BlePumpHandshake.run(on: connection, log: { _ in })
        }

        var device = BleBoundDevice.make(from: discovery)
        if let triplet = handshakeResult?.tripletInfo {
            if let productKey = triplet.productKey { device.productKey = productKey }
            if let deviceKey = triplet.deviceKey { device.deviceKey = deviceKey }
        }
        BleDeviceManager.shared.upsert(device)
        BleDeviceManager.shared.startObservingConnections()
        return device
    }
}
