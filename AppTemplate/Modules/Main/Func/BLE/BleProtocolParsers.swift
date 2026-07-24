//
//  BleProtocolParsers.swift
//  AppTemplate
//
//  吸奶器 / 温度贴 / 光疗仪广播解析器（适配 BleAdvDataParser）。

import Foundation
import CoreBluetooth
import AppStart

// MARK: - GATT UUID

enum BleGattUUID {
    static let transportService = CBUUID(string: "AF00")
    static let transportWrite = CBUUID(string: "AF01")
    static let transportNotify = CBUUID(string: "AF02")
}

// MARK: - 协议解析结果

struct BleProtocolParseResult {
    var mac: String?
    var extraData: [String: Any] = [:]
}

// MARK: - 吸奶器（0xaa 协议 4.1）
//
// 广播格式：kCBAdvDataManufacturerData
//   [0]     = 0xAA
//   [1]     = 设备类型
//   [3...8] = MAC（倒序格式化为 AA:BB:CC:DD:EE:FF）
// GATT 默认：AF00 / AF01 / AF02

struct BlePumpProtocolParser: BleAdvDataParser {
    typealias ParsedData = BleProtocolParseResult

    func parse(advertisementData: [String: Any]) -> BleProtocolParseResult? {
        guard let bytes = advertisementData["kCBAdvDataManufacturerData"] as? Data,
              bytes.count > 8,
              bytes.starts(with: [0xaa]) else {
            return nil
        }

        var result = BleProtocolParseResult()

        let macData = bytes[3...8]
        result.mac = [UInt8](macData)
            .reversed()
            .map { String(format: "%02X", $0) }
            .joined(separator: ":")

        return result
    }
}

// MARK: - 温度贴（T31）
//
// 匹配：LocalName ∈ BleDeviceCatalog.tempPatchNames（如 "T31"）
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

// MARK: - 光疗仪（Lumi 1）
//
// 匹配：LocalName ∈ BleDeviceCatalog.phototherapyNames（如 "Lumi 1"）
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
