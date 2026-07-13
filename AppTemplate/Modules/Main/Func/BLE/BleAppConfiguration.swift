//
//  BleAppConfiguration.swift
//  AppTemplate
//
//  BLE 产品协议注册，App 入口执行一次。

import Foundation
import CoreBluetooth
import AppStart

// MARK: - 广播解析器

struct BleSocketSerialParser: BleAdvDataParser {
    typealias ParsedData = String
    func parse(advertisementData: [String: Any]) -> String? {
        guard let data = advertisementData["kCBAdvDataManufacturerData"] as? Data,
              data.count >= 6 else { return nil }
        return data.prefix(6).map { String(format: "%02X", $0) }.joined()
    }
}

// MARK: - 产品协议

enum BleProducts {
    static let pump = BleProductProfile(
        id: "pump_x",
        displayName: "Pump",
        configuration: .init(
            matching: BleRegexMatchingStrategy(mode: .advertisementData([0xaa])),
            serviceUUIDs: [CBUUID(string: "AF00")],
            writeCharUUID: CBUUID(string: "AF01"),
            notifyCharUUID: CBUUID(string: "AF02"),
            reconnect: .init(enabled: true, maxAttempts: 3, interval: 5),
            writeQueue: .serialized(
                ackMatcher: BleByteAckMatcher(indices: [0, 1, 3]),
                defaultTimeout: 3,
                order: .descending
            ),
            debugLog: true
        ),
        parser: BleMACParser()
    )

    static let socket = BleProductProfile(
        id: "smart_socket",
        displayName: "智能插座",
        configuration: .init(
            matching: BleRegexMatchingStrategy(mode: .advertisementData([0xBB, 0x02])),
            serviceUUIDs: [CBUUID(string: "BF00")],
            writeCharUUID: CBUUID(string: "BF01"),
            notifyCharUUID: CBUUID(string: "BF02"),
            writeQueue: .direct,
            debugLog: true
        ),
        parser: BleSocketSerialParser()
    )

    static let all: [BleProductProfile] = [pump, socket]
}

// MARK: - App 入口

enum BleAppConfiguration {

    static func setup() {
        BleSession.shared.register(BleProducts.all)
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

    static func dataHexDescription(_ data: Data) -> String {
        data.map { String(format: "%02X", $0) }.joined(separator: " ")
    }

    static func productDisplayName(for productId: String?) -> String {
        guard let productId,
              let profile = BleSession.shared.profile(id: productId) else {
            return productId ?? "未知产品"
        }
        return profile.displayName
    }

    static func productDisplayName(for connection: BlePeripheralConnection) -> String {
        if case .ready(let info) = connection.currentState {
            let serviceUUID = info.service.uuid
            if let profile = BleSession.shared.registeredProfiles.first(where: {
                $0.configuration.serviceUUIDs.contains(serviceUUID)
            }) {
                return profile.displayName
            }
        }
        return "未知产品"
    }

    static func parsedDataDescription(for discovery: BleDiscovery) -> String {
        switch discovery.productId {
        case BleProducts.pump.id:
            if let mac = discovery.parsedData as? String { return "MAC: \(mac)" }
        case BleProducts.socket.id:
            if let serial = discovery.parsedData as? String { return "序列号: \(serial)" }
        default:
            if let text = discovery.parsedData as? String { return text }
        }
        return "解析数据: --"
    }
}
