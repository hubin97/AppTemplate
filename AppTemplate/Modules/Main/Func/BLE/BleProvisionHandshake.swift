//
//  BleProvisionHandshake.swift
//  AppTemplate
//
//  配网/协议握手 Demo：F0 解析 productType → Profile；F0 加密字段 → FD 是否实发。

import Foundation
import AppStart

/// 产品典型配网链（参考 Momcozy `IOTInteractionType` 命名；FD 实发以 F0 解析为准）。
enum BleProvisionProfile {
    /// CONNECT_F0 — M10 / W1
    case f0
    /// CONNECT_F0_FD — M9 / Air1 等
    case f0_fd
    /// CONNECT_F0_F7 — V3 / M9Pro / M8 等
    case f0_f7
    /// CONNECT_F0_FD_F7 — M5Pro
    case f0_fd_f7

    /// F0 CAB productType（= 广播 byte[1] / Momcozy `PType`）→ 配网链。
    static func resolve(productType: UInt8) -> BleProvisionProfile {
        switch productType {
        case 0x10, 0x11:
            return .f0
        case 0x01, 0x03, 0x04:
            return .f0_fd
        case 0x05, 0x06, 0x08, 0x09, 0x16:
            return .f0_f7
        case 0x07:
            return .f0_fd_f7
        default:
            return .f0_fd
        }
    }

    /// 该 profile 是否允许在 F0 之后尝试 FD（`f0` 纯鉴权机型跳过）。
    var allowsFD: Bool {
        switch self {
        case .f0: return false
        case .f0_fd, .f0_f7, .f0_fd_f7: return true
        }
    }

    var includesF7: Bool {
        switch self {
        case .f0_f7, .f0_fd_f7: return true
        case .f0, .f0_fd: return false
        }
    }

    var logName: String {
        switch self {
        case .f0: return "f0"
        case .f0_fd: return "f0 → (fd?)"
        case .f0_f7: return "f0 → (fd?) → f7"
        case .f0_fd_f7: return "f0 → (fd?) → f7"
        }
    }
}

struct BleProvisionResult {
    var profile: BleProvisionProfile?
    var f0Info: BlePumpF0Info?
    var fdInfo: BlePumpFDInfo?
    var tripletInfo: BlePumpTripletInfo?
    var sentFD: Bool
}

enum BleProvisionHandshake {

    /// F0 后按 productType 解析 Profile；FD 在 `allowsFD` 且 `needsFD` 时实发。
    static func run(
        on connection: BlePeripheralConnection,
        log: @escaping (String) -> Void
    ) async throws -> BleProvisionResult {
        var result = BleProvisionResult(sentFD: false)

        let f0Info = try await sendF0(connection, log: log)
        result.f0Info = f0Info

        let profile = BleProvisionProfile.resolve(productType: f0Info.productType)
        result.profile = profile
        log("握手 Profile · 0x\(String(format: "%02X", f0Info.productType)) → \(profile.logName)")

        if profile.allowsFD {
            if let fdInfo = try await sendFDIfNeeded(connection, f0Info: f0Info, log: log) {
                result.fdInfo = fdInfo
                result.sentFD = true
            }
        }

        if profile.includesF7 {
            result.tripletInfo = try await sendF7(connection, log: log)
        }

        log("握手完成")
        return result
    }

    // MARK: - Steps

    private static func sendF0(
        _ connection: BlePeripheralConnection,
        log: (String) -> Void
    ) async throws -> BlePumpF0Info {
        guard let ack = try await write(BlePumpCommand.f0Auth(), on: connection, log: log) else {
            throw BleProvisionError.missingAck("F0")
        }
        let info = try BlePumpF0Info.parse(from: ack)
        log("F0 · ACK · type=0x\(String(format: "%02X", info.productType)) encrypted=\(info.encryptionEnabled) key=0x\(String(format: "%02X", info.encryptionKey))")
        return info
    }

    /// F0 已加密或 key==0 则跳过；否则发 FD，回包只看是否 ACK。
    private static func sendFDIfNeeded(
        _ connection: BlePeripheralConnection,
        f0Info: BlePumpF0Info,
        log: (String) -> Void
    ) async throws -> BlePumpFDInfo? {
        guard f0Info.needsFD else {
            log("跳过 FD · encrypted=\(f0Info.encryptionEnabled) key=0x\(String(format: "%02X", f0Info.encryptionKey))")
            return nil
        }
        guard let ack = try await write(
            BlePumpCommand.fdOpenEncrypt(key: f0Info.encryptionKey),
            on: connection,
            log: log
        ) else {
            throw BleProvisionError.missingAck("FD")
        }
        let fdInfo = try BlePumpFDInfo.parse(from: ack)
        log("FD · encrypted=\(fdInfo.encryptionEnabled) key=0x\(String(format: "%02X", fdInfo.encryptionKey))")
        return fdInfo
    }

    private static func sendF7(
        _ connection: BlePeripheralConnection,
        log: (String) -> Void
    ) async throws -> BlePumpTripletInfo {
        guard let ack = try await write(BlePumpCommand.f7Triplet(), on: connection, log: log) else {
            throw BleProvisionError.missingAck("F7")
        }
        let triplet = try BlePumpTripletInfo.parse(from: ack)
        log("F7 · ACK · valid=\(triplet.isValid) productKey=\(triplet.productKey ?? "-") deviceKey=\(triplet.deviceKey ?? "-")")
        return triplet
    }

    private static func write(
        _ data: Data,
        on connection: BlePeripheralConnection,
        log: (String) -> Void
    ) async throws -> BleWriteAck? {
        let device = connection.peripheral.name ?? connection.peripheral.identifier.uuidString
        if let parsed = BlePumpTrace.describeSend(data, device: device) {
            log(parsed)
        }
        return try await connection.write(data)
    }
}
