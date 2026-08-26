//
//  BlePumpLinkCrypto.swift
//  AppTemplate
//
//  Pump 0xAA 帧 CAB 异或加解密；checksum 始终按明文 CAB。

import Foundation

enum BlePumpLinkCrypto {

    private static let sop: UInt8 = 0xAA
    private static let fcf: UInt8 = 0x55
    private static let ctREQ: UInt8 = 0x00

    /// 明文 REQ 帧 → 上链数据（仅 XOR CAB；F0 / FD / F7 豁免）。
    static func encryptOutbound(_ plain: Data, key: UInt8) -> Data {
        xorCab(in: plain, key: key)
    }

    static func decryptInbound(_ wire: Data, key: UInt8) -> Data {
        xorCab(in: wire, key: key)
    }

    private static func xorCab(in frame: Data, key: UInt8) -> Data {
        guard frame.count >= 6,
              frame[0] == sop, frame[1] == fcf else {
            return frame
        }
        let cid = frame[3]
        guard !isExemptFromEncryption(cid) else { return frame }

        let cal = Int(frame[4])
        guard cal > 0, 5 + cal <= frame.count - 1 else { return frame }

        var result = frame
        let cabStart = 5
        for index in 0..<cal {
            result[cabStart + index] = frame[cabStart + index] ^ key
        }
        return result
    }

    // 免于加密
    private static func isExemptFromEncryption(_ cid: UInt8) -> Bool {
        cid == 0xF0 || cid == 0xFD || cid == 0xF7
    }
}
