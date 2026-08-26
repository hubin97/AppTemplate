//
//  BleBoundDevice.swift
//  AppTemplate
//
//  业务层已绑定设备快照。握手成功后写入，供设备列表与面板使用。

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
    var handshakeProfile: String?
    var boundAt: Date

    var identifier: UUID? { UUID(uuidString: uuid) }

    var displayName: String {
        peripheralName.isEmpty ? "未命名设备" : peripheralName
    }
}

extension BleBoundDevice {

    static func make(
        from discovery: BleDiscovery,
        handshakeProfile: String? = nil,
        f0ProductKey: String? = nil
    ) -> BleBoundDevice {
        let parsed = discovery.parsedData as? BleProtocolParseResult
        let extra = parsed?.extraData ?? [:]
        let productKey = f0ProductKey
            ?? extra["productKey"] as? String
        return BleBoundDevice(
            uuid: discovery.peripheral.identifier.uuidString,
            peripheralName: discovery.displayName ?? "",
            mac: parsed?.mac,
            productName: BleStateFormatter.productDisplayName(for: discovery.configuration),
            category: BleDeviceCategory.resolve(configuration: discovery.configuration),
            deviceType: parsed?.deviceType,
            productKey: productKey,
            deviceKey: extra["deviceKey"] as? String,
            lastRSSI: discovery.advertisement.rssi.intValue,
            handshakeProfile: handshakeProfile,
            boundAt: Date()
        )
    }
}
