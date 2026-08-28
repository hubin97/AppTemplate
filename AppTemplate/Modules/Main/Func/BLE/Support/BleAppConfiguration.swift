//
//  BleAppConfiguration.swift
//  AppTemplate
//
//  BLE 产品协议注册，App 入口执行一次。

import Foundation
import CoreBluetooth
import AppStart

// MARK: - 设备名录（原 IOTCloudConfigResolver 简化版）

enum BleDeviceCatalog {
    static let tempPatchNames: Set<String> = ["T31"]
    static let phototherapyNames: Set<String> = ["Lumi 1"]
}

// MARK: - 产品协议

enum BleProducts {

    static let pumpParser = BlePumpProtocolParser()
    static let tempPatchParser = BleTempPatchProtocolParser()
    static let phototherapyParser = BlePhototherapyProtocolParser()

    /// Pump demo：0xaa 厂商协议；注册时写入主 GATT 默认值（primary）。
    /// connect 时 `effectiveConfiguration` 按广播 `deviceType` merge：
    /// - 主 GATT（`BleProvidesGattProfile`）：0x08/0x09 → extended，其余保留 primary
    /// - 附加 GATT（`BleProvidesSupplementaryGattProfiles`）：0x07 → secondary，其余无附加
    static let pump = BleConfiguration(
        matching: BleParserValidatedMatchingStrategy(parser: pumpParser),
        gattProfile: BleGattUUID.primary.gattProfile,
        reconnect: .init(enabled: true, maxAttempts: 3, retryDelay: 5, attemptTimeout: 10), // 意外断开会自动重连；耗尽后库会 cancel 系统 connect
        writeQueue: .serialized(
            ackMatcher: BlePumpAckMatcher(),
            defaultTimeout: 3,
            order: .descending
        ),
        parser: pumpParser,
        debugLog: true,
        logTag: "[Ble/Pump]"
    )

    /// TempPatch：设备名 + FFFF serviceData
    static let tempPatch = BleConfiguration(
        matching: BleParserValidatedMatchingStrategy(
            names: BleDeviceCatalog.tempPatchNames,
            parser: tempPatchParser
        ),
        writeQueue: .direct,
        parser: tempPatchParser,
        debugLog: true,
        logTag: "[Ble/TempPatch]"
    )

    /// Phototherapy：设备名 + 39 字节 manufacturerData
    static let phototherapy = BleConfiguration(
        matching: BleParserValidatedMatchingStrategy(
            names: BleDeviceCatalog.phototherapyNames,
            parser: phototherapyParser
        ),
        writeQueue: .direct,
        parser: phototherapyParser,
        debugLog: true,
        logTag: "[Ble/Phototherapy]"
    )

    static let all: [BleConfiguration] = [pump, tempPatch, phototherapy]

    static let displayNames: [String: String] = [
        "[Ble/Pump]": "Pump",
        "[Ble/TempPatch]": "TempPatch",
        "[Ble/Phototherapy]": "Phototherapy"
    ]
}

// MARK: - App 入口

enum BleAppConfiguration {

    static func setup() {
        BleSession.shared.setRegisteredConfigurations(BleProducts.all)
    }
}

// MARK: - 格式化

enum BleStateFormatter {

    static func centralStateDescription(_ state: CBManagerState) -> String {
        switch state {
        case .unknown: return "未知"
        case .resetting: return "重置中"
        case .unsupported: return "不支持"
        case .unauthorized: return "未授权"
        case .poweredOff: return "已关闭"
        case .poweredOn: return "已开启"
        @unknown default: return "未知 (\(state.rawValue))"
        }
    }

    static func peripheralStateDescription(_ state: BlePeripheralState) -> String {
        switch state {
        case .connecting: return "连接中"
        case .reconnecting(let attempt, let maximumAttempts):
            return "自动重连中（\(attempt)/\(maximumAttempts)）"
        case .connected: return "已连接（发现服务中）"
        case .ready(let info):
            return "就绪 · \(info.peripheral.name ?? "未知") · \(info.service.uuid.uuidString)"
        case .disconnected(let reason):
            switch reason {
            case .userInitiated: return "已断开（用户主动）"
            case .unexpected(let error): return "意外断开 · \(error.localizedDescription)"
            }
        case .failed(let error):
            return "失败 · \(error?.localizedDescription ?? "未知错误")"
        case .timedOut: return "连接超时"
        }
    }

    /// 设备列表用：关联 `BlePeripheralState` 的简短摘要。
    static func boundDeviceConnectionSummary(_ state: BlePeripheralState?) -> String {
        guard let state else { return "未连接" }
        switch state {
        case .connecting: return "连接中"
        case .reconnecting(let attempt, let maximumAttempts):
            return "重连中 \(attempt)/\(maximumAttempts)"
        case .connected: return "发现服务中"
        case .ready: return "就绪"
        case .disconnected(let reason):
            switch reason {
            case .userInitiated: return "已断开"
            case .unexpected: return "意外断开"
            }
        case .failed: return "连接失败"
        case .timedOut: return "连接超时"
        }
    }

    static func dataHexDescription(_ data: Data) -> String {
        data.map { String(format: "%02X", $0) }.joined(separator: " ")
    }

    static func productDisplayName(for configuration: BleConfiguration?) -> String {
        guard let configuration else { return "未知产品" }
        return BleProducts.displayNames[configuration.logTag] ?? configuration.logTag
    }

    static func productDisplayName(for connection: BlePeripheralConnection) -> String {
        productDisplayName(for: connection.configurationSnapshot)
    }

    static func parsedDataDescription(for discovery: BleDiscovery) -> String {
        guard let result: BleProtocolParseResult = discovery.parsedData() else {
            if let text = discovery.parsedData as? String { return text }
            return "解析数据: --"
        }

        var parts: [String] = []
        if let mac = result.mac { parts.append("MAC: \(mac)") }
        if let deviceType = result.deviceType {
            parts.append(String(format: "Type: 0x%02X", deviceType))
        }
        if let deviceKey = result.extraData["deviceKey"] as? String {
            parts.append("deviceKey: \(deviceKey)")
        }
        if let productKey = result.extraData["productKey"] as? String {
            parts.append("productKey: \(productKey)")
        }
        return parts.isEmpty ? "解析数据: --" : parts.joined(separator: " · ")
    }
}
