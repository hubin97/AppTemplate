//
//  BleBoundDevice.swift
//  AppTemplate
//
//  已绑定设备快照（纯数据）。连接态见 `livePeripheralState`，不落库。

import Foundation
import AppStart

enum BleDeviceCategory: String, Codable, CaseIterable {
    case pump
    case tempPatch
    case phototherapy
    case unknown

    var displayName: String {
        switch self {
        case .pump: return "Pump"
        case .tempPatch: return "TempPatch"
        case .phototherapy: return "Phototherapy"
        case .unknown: return "未知品类"
        }
    }

    static func resolve(configuration: BleConfiguration?) -> BleDeviceCategory {
        guard let tag = configuration?.logTag else { return .unknown }
        switch tag {
        case BleProducts.pump.logTag: return .pump
        case BleProducts.tempPatch.logTag: return .tempPatch
        case BleProducts.phototherapy.logTag: return .phototherapy
        default: return .unknown
        }
    }
}

struct BleBoundDevice: Codable, Equatable {
    let uuid: String
    var peripheralName: String
    var mac: String?
    var productName: String
    var category: BleDeviceCategory
    var deviceType: UInt8?
    var productKey: String?
    var deviceKey: String?
    var lastRSSI: Int?
    var boundAt: Date

    var identifier: UUID? { UUID(uuidString: uuid) }

    var displayName: String {
        peripheralName.isEmpty ? "未命名设备" : peripheralName
    }
}

extension BleBoundDevice {

    /// 当前 Session 连接池里同 UUID 的外设连接。
    var liveConnection: BlePeripheralConnection? {
        guard let id = identifier else { return nil }
        return BleSession.shared.activeConnections.first {
            $0.peripheral.identifier == id
        }
    }

    /// 关联 `BlePeripheralConnection.currentState`；不在连接池时为 nil。
    var livePeripheralState: BlePeripheralState? {
        liveConnection?.currentState
    }

    var connectionDisplayName: String {
        BleStateFormatter.boundDeviceConnectionSummary(livePeripheralState)
    }

    static func make(from discovery: BleDiscovery) -> BleBoundDevice {
        let parsed = discovery.parsedData as? BleProtocolParseResult
        let extra = parsed?.extraData ?? [:]
        return BleBoundDevice(
            uuid: discovery.peripheral.identifier.uuidString,
            peripheralName: discovery.displayName ?? "",
            mac: parsed?.mac,
            productName: BleStateFormatter.productDisplayName(for: discovery.configuration),
            category: BleDeviceCategory.resolve(configuration: discovery.configuration),
            deviceType: parsed?.deviceType,
            productKey: extra["productKey"] as? String,
            deviceKey: extra["deviceKey"] as? String,
            lastRSSI: discovery.advertisement.rssi.intValue,
            boundAt: Date()
        )
    }
}
