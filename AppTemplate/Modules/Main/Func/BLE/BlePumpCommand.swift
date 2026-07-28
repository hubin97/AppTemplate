//
//  BlePumpCommand.swift
//  AppTemplate
//
//  吸奶器 0xAA 0x55 协议帧（对齐 Momcozy LTBTData）。

import Foundation

enum BlePumpCommand {

    enum State: UInt8 {
        case stop = 0x00
        case running = 0x01
    }

    enum Mode: UInt8 {
        case massage = 0x01
        case pump = 0x02
        case mixing = 0x03
        case customize = 0x04
    }

    enum DIYMode: UInt8 {
        case short = 0x01
        case long = 0x02
    }

    private static let sop: UInt8 = 0xAA
    private static let fcf: UInt8 = 0x55
    private static let ctREQ: UInt8 = 0x00
    private static let cidC0: UInt8 = 0xC0
    private static let cidF0: UInt8 = 0xF0

    /// 连接后鉴权码（Momcozy `LT_BLE_AUTHVAL`）
    static let defaultAuthCodes: [UInt8] = [0xAA, 0x55, 0x11, 0x00]

    /// F0 获取设备信息 / 鉴权，连接后 5s 内需发送
    static func defaultF0Auth() -> Data {
        f0Auth(authCodes: defaultAuthCodes)
    }

    static func f0Auth(authCodes: [UInt8] = defaultAuthCodes) -> Data {
        encode(cid: cidF0, cal: 0x04, cab: authCodes)
    }

    /// C0 常规控制：运行 + 按摩 + 档位 4（Momcozy `ReqControlModel(normal:)` 默认）
    static func defaultC0Control() -> Data {
        c0Control(
            state: .running,
            mode: .massage,
            level: 0x04,
            diyMode: .short,
            diyLevel: 0x04,
            diyCycle: 0x01
        )
    }

    /// C0 控制指令 cab：state / mode / level / diyMode / diyLevel / diyCycle + 4 字节预留
    static func c0Control(
        state: State,
        mode: Mode,
        level: UInt8,
        diyMode: DIYMode,
        diyLevel: UInt8,
        diyCycle: UInt8
    ) -> Data {
        let cab: [UInt8] = [
            state.rawValue, mode.rawValue, level,
            diyMode.rawValue, diyLevel, diyCycle,
            0x00, 0x00, 0x00, 0x00
        ]
        return encode(cid: cidC0, cal: 0x0A, cab: cab)
    }

    static func hexDescription(_ data: Data) -> String {
        data.map { String(format: "%02X", $0) }.joined(separator: " ")
    }

    private static func encode(cid: UInt8, cal: UInt8, cab: [UInt8]) -> Data {
        var bytes: [UInt8] = [sop, fcf, ctREQ, cid, cal]
        bytes.append(contentsOf: cab)
        let sum = bytes.reduce(UInt16(0)) { $0 + UInt16($1) }
        bytes.append(0xFF ^ UInt8(truncatingIfNeeded: sum))
        return Data(bytes)
    }
}
