//
//  BleProtocolParsers.swift
//  AppTemplate
//
//  Pump / TempPatch / Phototherapy advertisement parsers (BleAdvDataParser).

import Foundation
import CoreBluetooth
import AppStart

// MARK: - GATT UUID

/// 本应用与设备端约定的 BLE GATT UUID（与固件一致；新设备在此扩展）。
enum BleGattUUID {

    struct Channel {
        let service: String
        let write: String
        let notify: String

        var serviceUUID: CBUUID { CBUUID(string: service) }
        var writeUUID: CBUUID { CBUUID(string: write) }
        var notifyUUID: CBUUID { CBUUID(string: notify) }
    }

    /// 短 UUID 主链路透传（AF00 / AF01 / AF02）
    static let primary = Channel(service: "AF00", write: "AF01", notify: "AF02")

    /// Ota / RCSP（AE00 / AE01 / AE02）
    static let ota = Channel(service: "AE00", write: "AE01", notify: "AE02")

    /// 128-bit 主链路透传（与 `primary` 同职责）
    static let extended = Channel(
        service: "524F4F54-9000-0080-0010-000000010001",
        write: "524F4F54-9000-0080-0010-000000010003",
        notify: "524F4F54-9000-0080-0010-000000010002"
    )

    /// 128-bit 次通道：设备侧埋点 / 数据上报
    static let secondary = Channel(
        service: "9F6B1A20-3C4D-4E5F-A601-7B8C9D0E1122",
        write: "9F6B1A21-3C4D-4E5F-A601-7B8C9D0E1122",
        notify: "9F6B1A22-3C4D-4E5F-A601-7B8C9D0E1122"
    )
}

extension BleGattUUID.Channel {
    var gattProfile: BleGattProfile {
        BleGattProfile(
            serviceUUIDs: [serviceUUID],
            writeCharUUID: writeUUID,
            notifyCharUUID: notifyUUID
        )
    }
}

// MARK: - 协议解析结果

struct BleProtocolParseResult {
    var mac: String?
    /// 0xAA 广播 byte[1] 设备类型
    var deviceType: UInt8?
    var extraData: [String: Any] = [:]
}

extension BleProtocolParseResult: BleProvidesGattProfile, BleProvidesSupplementaryGattProfiles {

    /// 主 GATT：按广播 deviceType 选取；connect 时由 `effectiveConfiguration` merge。
    var bleGattProfile: BleGattProfile {
        switch deviceType {
        case 0x08, 0x09:
            return BleGattUUID.extended.gattProfile
        default:
            return BleGattUUID.primary.gattProfile
        }
    }

    /// 附加 GATT：按 deviceType 注入（如 0x07 → secondary 埋点）。
    var supplementaryGattProfiles: [BleGattProfile] {
        guard deviceType == 0x07 else { return [] }
        return [BleGattUUID.secondary.gattProfile]
    }
}

// MARK: - 埋点 副通道 Notify payload

struct BlePumpAnalyticsEvent {
    let raw: Data
    var hex: String {
        raw.map { String(format: "%02X", $0) }.joined(separator: " ")
    }
}

enum BlePumpAnalyticsParser {

    /// Demo：透传 hex；固件格式明确后在此扩展字段解析。
    static func parse(_ data: Data) -> BlePumpAnalyticsEvent {
        BlePumpAnalyticsEvent(raw: data)
    }
}

// MARK: - Pump (0xaa protocol 4.1)
//
// 广播格式：kCBAdvDataManufacturerData
//   [0]     = 0xAA
//   [1]     = 设备类型
//   [3...8] = MAC（倒序格式化为 AA:BB:CC:DD:EE:FF）
// GATT 默认：primary（AF00 / AF01 / AF02）

struct BlePumpProtocolParser: BleAdvDataParser {
    typealias ParsedData = BleProtocolParseResult

    func parse(advertisementData: [String: Any]) -> BleProtocolParseResult? {
        guard let bytes = advertisementData["kCBAdvDataManufacturerData"] as? Data,
              bytes.count > 8,
              bytes.starts(with: [0xaa]) else {
            return nil
        }

        var result = BleProtocolParseResult()

        result.deviceType = bytes[1]

        let macData = bytes[3...8]
        result.mac = [UInt8](macData)
            .reversed()
            .map { String(format: "%02X", $0) }
            .joined(separator: ":")

        return result
    }
}

// MARK: - TempPatch
//
// 匹配：LocalName ∈ BleDeviceCatalog.tempPatchNames
// manufacturerData：productKey[0..6] + secretKey[6..14] + signType[14]
// serviceData[FFFF]：deviceKey[0..16] + MAC[16..22]

struct BleTempPatchProtocolParser: BleAdvDataParser {
    typealias ParsedData = BleProtocolParseResult

    private let supportedNames: Set<String>

    init(supportedNames: Set<String> = BleDeviceCatalog.tempPatchNames) {
        self.supportedNames = supportedNames
    }

    func parse(advertisementData: [String: Any]) -> BleProtocolParseResult? {
        let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        guard let name, supportedNames.contains(name) else { return nil }
        guard let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data,
              let (productKey, secretKey) = parseManufacturerData(from: manufacturerData),
              let (deviceKey, macAddress) = parseServiceData(from: advertisementData) else {
            return nil
        }

        var result = BleProtocolParseResult()
        result.mac = macAddress
        result.extraData["deviceKey"] = deviceKey
        result.extraData["productKey"] = productKey
        result.extraData["secretKey"] = secretKey
        result.extraData["signType"] = manufacturerData.count > 14 ? manufacturerData[14] : nil
        return result
    }

    private func parseServiceData(from advData: [String: Any]) -> (deviceKey: String, macAddress: String)? {
        guard let serviceDataDict = advData[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data],
              let ffffData = serviceDataDict[CBUUID(string: "FFFF")],
              ffffData.count >= 22,
              let deviceKey = String(data: ffffData.subdata(in: 0..<16), encoding: .ascii) else {
            return nil
        }
        let macData = ffffData.subdata(in: 16..<22)
        let macAddress = macData.map { String(format: "%02X", $0) }.joined(separator: ":")
        return (deviceKey, macAddress)
    }

    private func parseManufacturerData(from data: Data) -> (productKey: String, secretKey: String)? {
        guard data.count >= 14,
              let productKey = String(data: data.subdata(in: 0..<6), encoding: .ascii),
              productKey.count == 6 else {
            return nil
        }
        let secretKey = data.subdata(in: 6..<14).map { String(format: "%02x", $0) }.joined()
        return (productKey, secretKey)
    }
}

// MARK: - Phototherapy
//
// 匹配：LocalName ∈ BleDeviceCatalog.phototherapyNames
// manufacturerData 固定 39 字节：
//   productKey[0..6] + secretKey[6..14] + signType[14] + MAC[15..21] + deviceKey[23..39]

struct BlePhototherapyProtocolParser: BleAdvDataParser {
    typealias ParsedData = BleProtocolParseResult

    private let supportedNames: Set<String>

    init(supportedNames: Set<String> = BleDeviceCatalog.phototherapyNames) {
        self.supportedNames = supportedNames
    }

    func parse(advertisementData: [String: Any]) -> BleProtocolParseResult? {
        let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        guard let name, supportedNames.contains(name) else { return nil }
        guard let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data,
              manufacturerData.count == 39,
              let (productKey, secretKey, deviceKey, macAddress) = parseData(data: manufacturerData) else {
            return nil
        }

        var result = BleProtocolParseResult()
        result.extraData["deviceKey"] = deviceKey
        result.mac = macAddress
        result.extraData["productKey"] = productKey
        result.extraData["secretKey"] = secretKey
        result.extraData["signType"] = manufacturerData.count > 14 ? manufacturerData[14] : nil
        return result
    }

    private func parseData(data: Data) -> (productKey: String, secretKey: String, deviceKey: String, macAddress: String)? {
        guard let productKey = String(data: data.subdata(in: 0..<6), encoding: .ascii) else { return nil }
        let secretKey = data.subdata(in: 6..<14).map { String(format: "%02x", $0) }.joined()
        let macData = data.subdata(in: 15..<21)
        let macAddress = macData.map { String(format: "%02X", $0) }.joined(separator: ":")
        guard let deviceKey = String(data: data.subdata(in: 23..<39), encoding: .ascii) else { return nil }
        return (productKey, secretKey, deviceKey, macAddress)
    }
}
