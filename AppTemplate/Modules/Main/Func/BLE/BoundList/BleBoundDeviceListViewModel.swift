//
//  BleBoundDeviceListViewModel.swift
//  AppTemplate
//
//  已绑定设备列表：设备数据、下拉混扫 15s 并连接列表内设备。

import Foundation
import Combine
import AppStart

// MARK: - Main Class
@MainActor
final class BleBoundDeviceListViewModel: ViewModel {

    private static let scanTimeout: TimeInterval = 15

    @Published private(set) var devices: [BleBoundDevice] = []
    let scanFinished = PassthroughSubject<Void, Never>()

    private var scanTask: Task<Void, Never>?
    private var connectTasks: [UUID: Task<Void, Never>] = [:]

    required init() {
        super.init()
    }

    func viewWillAppear() {
        BleDeviceManager.shared.onChange = { [weak self] in
            self?.reload()
        }
        BleDeviceManager.shared.startObservingConnections()
        reload()
    }

    func viewWillDisappear() {
        BleDeviceManager.shared.onChange = nil
        stopScanning()
        BleDeviceManager.shared.stopObservingConnections()
    }

    func startScanningAndConnecting() {
        cancelScanTask()
        let targetUUIDs = Set(BleDeviceManager.shared.devices.compactMap(\.identifier))
        guard !targetUUIDs.isEmpty else {
            scanFinished.send()
            return
        }

        scanTask = Task { [weak self] in
            guard let self else { return }
            let stream = BleSession.shared.scanAllProducts(timeout: Self.scanTimeout)
            for await discovery in stream {
                guard !Task.isCancelled else { break }
                let id = discovery.peripheral.identifier
                guard targetUUIDs.contains(id) else { continue }
                self.updateRSSI(for: id, rssi: discovery.advertisement.rssi.intValue)
                self.connectIfNeeded(discovery: discovery)
            }
            self.scanFinished.send()
            guard !Task.isCancelled else { return }
            BleDeviceManager.shared.startObservingConnections()
        }
    }

    func removeDevice(uuid: String) {
        BleDeviceManager.shared.remove(uuid: uuid)
    }

    func reload() {
        devices = BleDeviceManager.shared.devices
    }
}

// MARK: - Scan & Connect
extension BleBoundDeviceListViewModel {

    private func updateRSSI(for id: UUID, rssi: Int) {
        guard var device = BleDeviceManager.shared.devices.first(where: { $0.identifier == id }) else { return }
        guard device.lastRSSI != rssi else { return }
        device.lastRSSI = rssi
        BleDeviceManager.shared.upsert(device)
    }

    private func connectIfNeeded(discovery: BleDiscovery) {
        let peripheral = discovery.peripheral
        if let existing = BleSession.shared.connection(for: peripheral) {
            switch existing.currentState {
            case .connecting, .reconnecting, .connected, .ready:
                return
            case .disconnected, .failed, .timedOut:
                break
            }
        }
        let id = peripheral.identifier
        guard connectTasks[id] == nil else { return }

        connectTasks[id] = Task { [weak self] in
            defer {
                self?.connectTasks.removeValue(forKey: id)
            }
            do {
                _ = try await BleSession.shared.connect(discovery: discovery, setAsActive: false)
                BleDeviceManager.shared.startObservingConnections()
            } catch {
                // 扫描窗口内连不上时静默失败，下次下拉再试
            }
        }
    }

    private func cancelScanTask() {
        scanTask?.cancel()
        scanTask = nil
        connectTasks.values.forEach { $0.cancel() }
        connectTasks.removeAll()
        BleSession.shared.stopScanning()
    }

    private func stopScanning() {
        cancelScanTask()
        scanFinished.send()
    }
}
