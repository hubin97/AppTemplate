//
//  BlePumpProtocol.swift
//  AppTemplate
//
//  0xAA 0x55 帧解析（协议握手 Demo）。

import Foundation
import AppStart

// MARK: - ACK 匹配（泵 0xAA 0x55 协议，业务层实现 BleAckMatcher）

/// 帧头 + CT=ACK(0x01) + 同 CID；避免设备主动 REQ 形上报误判为写应答。
struct BlePumpAckMatcher: BleAckMatcher {
    func matches(command: Data, response: Data) -> Bool {
        guard command.count > 3, response.count > 3 else { return false }
        return response[0] == 0xAA
            && response[1] == 0x55
            && response[2] == 0x01
            && response[3] == command[3]
    }
}

// MARK: - 帧结构

enum BlePumpCT: UInt8 {
    case req = 0x00
    case ack = 0x01
    case device = 0x02
}

enum BlePumpCID: UInt8 {
    case f0 = 0xF0
    case fd = 0xFD
    case f7 = 0xF7
    case b0 = 0xB0
}

struct BlePumpFrame {
    let ct: BlePumpCT
    let cid: BlePumpCID
    let cab: Data

    var isAck: Bool { ct == .ack }

    static func parse(_ data: Data) -> BlePumpFrame? {
        guard data.count >= 6,
              data[0] == 0xAA,
              data[1] == 0x55,
              let ct = BlePumpCT(rawValue: data[2]),
              let cid = BlePumpCID(rawValue: data[3]) else {
            return nil
        }
        let cal = Int(data[4])
        let cabEnd = 5 + cal
        guard cabEnd <= data.count - 1 else { return nil }
        let cab = data.subdata(in: 5..<cabEnd)
        return BlePumpFrame(ct: ct, cid: cid, cab: cab)
    }
}

// MARK: - F0 设备信息（协议 CAB 字段顺序）

struct BlePumpF0Info {
    let productType: UInt8
    /// F0 CAB：加密状态 0x00 无加密 / 0x01 有加密（协议 byte13）
    let encryptionEnabled: Bool
    /// F0 CAB：加密 key，设备开机随机 1…127（协议 byte14）
    let encryptionKey: UInt8
    let softwareVersion: UInt8
    let rawCab: Data

    /// 协议约定：无加密且 key 有效 → 需发 FD；已加密则跳过。
    var needsFD: Bool {
        !encryptionEnabled && (1...127).contains(encryptionKey)
    }

    static func parse(from ack: BleWriteAck) throws -> BlePumpF0Info {
        guard let frame = BlePumpFrame.parse(ack.response),
              frame.cid == .f0,
              frame.isAck else {
            throw BleProvisionError.invalidAck(expected: "F0 ACK", received: ack.response)
        }
        return parse(cab: frame.cab)
    }

    static func parse(cab: Data) -> BlePumpF0Info {
        var index = 0
        func byte(_ defaultValue: UInt8 = 0) -> UInt8 {
            guard index < cab.count else { return defaultValue }
            defer { index += 1 }
            return cab[index]
        }

        let productType = byte()
        _ = byte() // hardware_platform
        _ = byte() // hardware_version
        let softwareVersion = byte()
        index += 4 // diyId
        index += 1 // fullMilkParam
        index += 1 // fullMilkFunc
        let snLength = productType == 0x01 ? 33 : 35
        index += snLength
        let encryptionEnabled = byte() == 0x01
        let encryptionKey = byte()

        return BlePumpF0Info(
            productType: productType,
            encryptionEnabled: encryptionEnabled,
            encryptionKey: encryptionKey,
            softwareVersion: softwareVersion,
            rawCab: cab
        )
    }
}

// MARK: - FD 加密信息（协议 3.1.6 ACK：CAL=0x02，CAB[0] 状态 + CAB[1] key）

struct BlePumpFDInfo {
    let encryptionEnabled: Bool
    let encryptionKey: UInt8

    static func parse(from ack: BleWriteAck) throws -> BlePumpFDInfo {
        guard let frame = BlePumpFrame.parse(ack.response),
              frame.cid == .fd,
              frame.isAck,
              frame.cab.count >= 2 else {
            throw BleProvisionError.invalidAck(expected: "FD ACK", received: ack.response)
        }
        return BlePumpFDInfo(
            encryptionEnabled: frame.cab[0] == 0x01,
            encryptionKey: frame.cab[1]
        )
    }
}

// MARK: - F7 三元组（Demo：解析 cab 为 ASCII 片段）

struct BlePumpTripletInfo {
    let rawCab: Data
    let productKey: String?
    let deviceKey: String?

    var isValid: Bool {
        (productKey?.isEmpty == false) || (deviceKey?.isEmpty == false)
    }

    static func parse(from ack: BleWriteAck) throws -> BlePumpTripletInfo {
        guard let frame = BlePumpFrame.parse(ack.response),
              frame.cid == .f7,
              frame.isAck else {
            throw BleProvisionError.invalidAck(expected: "F7 ACK", received: ack.response)
        }
        let productKey = frame.cab.count >= 6
            ? String(data: frame.cab.prefix(6), encoding: .ascii)
            : nil
        let deviceKey = frame.cab.count > 6
            ? String(data: frame.cab.dropFirst(6), encoding: .ascii)?.trimmingCharacters(in: .controlCharacters)
            : nil
        return BlePumpTripletInfo(rawCab: frame.cab, productKey: productKey, deviceKey: deviceKey)
    }
}

enum BleProvisionError: LocalizedError {
    case missingAck(String)
    case invalidAck(expected: String, received: Data)

    var errorDescription: String? {
        switch self {
        case .missingAck(let step):
            return "\(step) 未收到 ACK"
        case .invalidAck(let expected, let received):
            return "\(expected) 解析失败: \(BlePumpCommand.hexDescription(received))"
        }
    }
}
