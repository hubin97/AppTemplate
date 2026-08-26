//
//  BlePumpProtocol.swift
//  AppTemplate
//
//  0xAA 0x55 帧解析（协议握手 Demo）。

import Foundation
import AppStart

// MARK: - ACK 匹配（泵 0xAA 0x55 协议，业务层实现 BleAckMatcher）

/// 帧头 + 同 CID + CT 为 ACK(0x01) 或 NACK(0x02)。
/// 真机 FD 可能回 NACK；不认 NACK 会导致写队列超时，但 Notify 仍会进调试页。
/// 排除 REQ(0x00) / Device(0x04) 主动上报。
struct BlePumpAckMatcher: BleAckMatcher {
    func matches(command: Data, response: Data) -> Bool {
        guard command.count > 3, response.count > 3 else { return false }
        let ct = response[2]
        return response[0] == 0xAA
            && response[1] == 0x55
            && (ct == BlePumpCT.ack.rawValue || ct == BlePumpCT.nack.rawValue)
            && response[3] == command[3]
    }
}

// MARK: - 帧结构

enum BlePumpCT: UInt8 {
    /// REQ：数据请求，需有ACK或者NACK应答；
    case req = 0x00
    /// ACK：数据接收后正确应答，返回REQ所需数据；
    case ack = 0x01
    /// NACK：数据接收否定应答，返回错误信息；
    case nack = 0x02
    /// Notify：用于设备自动反馈数据，不需要ACK或NACK应答。
    case notify = 0x03
    /// Device：用于设备硬件控制的上报数据。
    case device = 0x04
}

enum BlePumpCID: UInt8 {
    case f0 = 0xF0
    case fd = 0xFD
    case f7 = 0xF7
    case b0 = 0xB0
    case d0 = 0xD0
    case c0 = 0xC0
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
        return BlePumpFrame(ct: ct, cid: cid, cab: cabPayload(in: data))
    }

    /// CAL 超出实际长度时（NACK 短包 `AA 55 02 FD 12 chk`）截取 checksum 前字节；6 字节则 CAL 位当作 status。
    static func cabPayload(in data: Data) -> Data {
        let cal = Int(data[4])
        let cabEnd = 5 + cal
        if cabEnd <= data.count - 1 {
            return data.subdata(in: 5..<cabEnd)
        }
        let checksumIndex = data.count - 1
        if checksumIndex > 5 {
            return data.subdata(in: 5..<checksumIndex)
        }
        return Data([data[4]])
    }
}

// MARK: - F0 设备信息（协议 CAB 字段顺序）

struct BlePumpF0Info {
    let productType: UInt8
    let hardwarePlatform: UInt8
    let hardwareVersion: UInt8
    let softwareVersion: UInt8
    let fullMilkParam: UInt8
    let fullMilkFunc: Bool
    let sn: Data
    /// F0 CAB：加密状态 0x00 无加密 / 0x01 有加密（协议 byte13）
    let encryptionEnabled: Bool
    /// F0 CAB：加密 key，设备开机随机 1…127（协议 byte14）
    let encryptionKey: UInt8
    let rawCab: Data

    /// SN 区去掉 0x00 / 0xFF 后的可读串；解析窗口错位时仍能看到原始 ASCII。
    var sncode: String {
        let bytes = sn.filter { $0 != 0x00 && $0 != 0xFF }
        if let text = String(bytes: bytes, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines),
           !text.isEmpty {
            return text
        }
        return "—"
    }

    /// 已加密（F0 ACK）或 key==0 → 跳过 FD（对齐 Momcozy `openEncrypt`）。
    var needsFD: Bool {
        !encryptionEnabled && encryptionKey != 0
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
        let hardwarePlatform = byte()
        let hardwareVersion = byte()
        let softwareVersion = byte()
        index += 4 // diyId
        let fullMilkParam = byte()
        let fullMilkFunc = byte() == 0x01
        let snLength = productType == 0x01 ? 33 : 35
        let snStart = index
        index += snLength
        let snEnd = min(snStart + snLength, cab.count)
        let sn = snStart < cab.count ? cab.subdata(in: snStart..<snEnd) : Data()
        let encryptionEnabled = byte() == 0x01
        let encryptionKey = byte()

        return BlePumpF0Info(
            productType: productType,
            hardwarePlatform: hardwarePlatform,
            hardwareVersion: hardwareVersion,
            softwareVersion: softwareVersion,
            fullMilkParam: fullMilkParam,
            fullMilkFunc: fullMilkFunc,
            sn: sn,
            encryptionEnabled: encryptionEnabled,
            encryptionKey: encryptionKey,
            rawCab: cab
        )
    }
}

// MARK: - C0 控制（协议 CAB：state / mode / level / diyMode / diyLevel / diyCycle）

struct BlePumpC0Info {
    let state: UInt8
    let mode: UInt8
    let level: UInt8
    let diyMode: UInt8
    let diyLevel: UInt8
    let diyCycle: UInt8

    static func parse(cab: Data) -> BlePumpC0Info? {
        guard cab.count >= 6 else { return nil }
        return BlePumpC0Info(
            state: cab[0],
            mode: cab[1],
            level: cab[2],
            diyMode: cab[3],
            diyLevel: cab[4],
            diyCycle: cab[5]
        )
    }
}

// MARK: - B0 / D0 状态（协议 CAB 字段顺序，与 Momcozy `AckStateModal` 一致）

struct BlePumpStateInfo {
    let battery: UInt8
    let state: UInt8
    let dirFlag: UInt8
    let mode: UInt8
    let level: UInt8
    let diyMode: UInt8
    let diyLevel: UInt8
    let diyCycle: UInt8
    let runtime: UInt16
    let modeTime: UInt16
    let reserves: UInt8
    let exceptStFlag: UInt8
    let modelistTime: UInt16

    static func parse(cab: Data) -> BlePumpStateInfo {
        func byte(_ index: Int) -> UInt8 {
            index < cab.count ? cab[index] : 0
        }
        func uint16(_ index: Int) -> UInt16 {
            guard index + 1 < cab.count else { return 0 }
            return (UInt16(cab[index]) << 8) | UInt16(cab[index + 1])
        }
        return BlePumpStateInfo(
            battery: byte(0),
            state: byte(1),
            dirFlag: byte(2),
            mode: byte(3),
            level: byte(4),
            diyMode: byte(5),
            diyLevel: byte(6),
            diyCycle: byte(7),
            runtime: uint16(8),
            modeTime: uint16(10),
            reserves: byte(12),
            exceptStFlag: byte(13),
            modelistTime: uint16(14)
        )
    }
}

// MARK: - FD 加密信息（协议 3.1.6 ACK：CAL=0x02，CAB[0] 状态 + CAB[1] key）

struct BlePumpFDInfo {
    let encryptionEnabled: Bool
    let encryptionKey: UInt8

    /// 与 Momcozy `updateEncryptState` 一致：只看 CT 是否 ACK。
    static func parse(from ack: BleWriteAck) throws -> BlePumpFDInfo {
        guard let frame = BlePumpFrame.parse(ack.response),
              frame.cid == .fd else {
            throw BleProvisionError.invalidAck(expected: "FD ACK", received: ack.response)
        }
        return BlePumpFDInfo(
            encryptionEnabled: frame.isAck,
            encryptionKey: frame.cab.last ?? 0
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
