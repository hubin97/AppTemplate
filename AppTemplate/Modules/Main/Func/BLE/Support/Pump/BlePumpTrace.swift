//
//  BlePumpTrace.swift
//  AppTemplate
//
//  Pump 0xAA 指令解析打印（发送 / 接收字段展开）。

import Foundation

// MARK: - 字段格式化

enum BlePumpTrace {

    /// `>>> 发送数据解析`：C0 展开控制字段；F0/FD/F7/B0 展开请求语义；其余打 CAB。
    static func describeSend(_ data: Data, device: String) -> String? {
        guard let frame = payload(data) else { return nil }
        switch frame.cid {
        case 0xC0:
            guard let control = BlePumpC0Info.parse(cab: frame.cab) else { return nil }
            return sendLine(
                device: device,
                cid: frame.cid,
                fields: [
                    "状态=\(stateName(control.state))",
                    "模式=\(modeName(control.mode))",
                    "档位=\(control.level)",
                    "自定义模式=\(diyModeName(control.diyMode))",
                    "自定义档位=\(control.diyLevel)",
                    "自定义频次=\(control.diyCycle)"
                ]
            )
        case 0xF0:
            return sendLine(device: device, cid: frame.cid, fields: ["auth=\(hex(frame.cab))"])
        case 0xFD:
            if frame.cab.isEmpty {
                return sendLine(device: device, cid: frame.cid, fields: ["查询加密"])
            }
            return sendLine(device: device, cid: frame.cid, fields: ["key=\(hex(frame.cab))"])
        case 0xF7:
            return sendLine(device: device, cid: frame.cid, fields: ["获取三元组"])
        case 0xB0:
            return sendLine(device: device, cid: frame.cid, fields: ["获取状态"])
        default:
            return sendLine(
                device: device,
                cid: frame.cid,
                fields: ["CAL=\(frame.cab.count)", "CAB=\(hex(frame.cab))"]
            )
        }
    }

    /// `<<< 接收数据解析`：F0 设备信息、B0/D0 状态；FD/F7 便于握手对照。
    static func describeReceive(_ data: Data, device: String) -> String? {
        guard let frame = payload(data) else { return nil }
        switch frame.cid {
        case 0xF0:
            let info = BlePumpF0Info.parse(cab: frame.cab)
            return receiveLine(
                device: device,
                cid: frame.cid,
                fields: [
                    "产品型号=\(String(format: "0x%02X", info.productType))",
                    "软件版本=\(info.softwareVersion)",
                    "SN码=\(info.sncode)",
                    "硬件平台型号=\(info.hardwarePlatform)",
                    "硬件版本=\(info.hardwareVersion)",
                    "满奶检测参数=\(info.fullMilkParam)",
                    "满奶检测开关=\(info.fullMilkFunc)",
                    "encrypted=\(info.encryptionEnabled)",
                    String(format: "key=0x%02X", info.encryptionKey)
                ]
            )
        case 0xB0, 0xD0:
            let state = BlePumpStateInfo.parse(cab: frame.cab)
            return receiveLine(
                device: device,
                cid: frame.cid,
                fields: [
                    "电量=\(state.battery)",
                    "状态=\(stateName(state.state))",
                    "左右=\(state.dirFlag == 0x00 ? "左" : "右")",
                    "模式=\(modeName(state.mode))",
                    "档位=\(state.level)",
                    "自定义模式=\(diyModeName(state.diyMode))",
                    "自定义档位=\(state.diyLevel)",
                    "自定义频次=\(state.diyCycle)",
                    "总运行时间=\(state.runtime)",
                    "模式时间=\(state.modeTime)",
                    "自定义时间=\(state.modelistTime)",
                    "储奶量=\(state.reserves)",
                    "异常标记=\(state.exceptStFlag)"
                ]
            )
        case 0xFD:
            return receiveLine(
                device: device,
                cid: frame.cid,
                fields: [
                    "encrypted=\(frame.ct == BlePumpCT.ack.rawValue)",
                    String(format: "key=0x%02X", frame.cab.last ?? 0)
                ]
            )
        case 0xF7:
            let productKey = frame.cab.count >= 6
                ? String(data: frame.cab.prefix(6), encoding: .ascii) ?? "-"
                : "-"
            let deviceKey = frame.cab.count > 6
                ? String(data: frame.cab.dropFirst(6), encoding: .ascii)?
                    .trimmingCharacters(in: .controlCharacters) ?? "-"
                : "-"
            return receiveLine(
                device: device,
                cid: frame.cid,
                fields: [
                    "productKey=\(productKey)",
                    "deviceKey=\(deviceKey)"
                ]
            )
        default:
            return nil
        }
    }

    // MARK: - Header

    /// 不依赖 `BlePumpCID` 枚举，避免未知指令整帧丢弃。
    private static func payload(_ data: Data) -> (ct: UInt8, cid: UInt8, cab: Data)? {
        guard data.count >= 6, data[0] == 0xAA, data[1] == 0x55 else { return nil }
        return (data[2], data[3], BlePumpFrame.cabPayload(in: data))
    }

    private static func sendLine(device: String, cid: UInt8, fields: [String]) -> String {
        ">>> 发送数据解析: (\(device)) | \(cidHex(cid)) | [\(fields.joined(separator: " "))]"
    }

    private static func receiveLine(device: String, cid: UInt8, fields: [String]) -> String {
        "<<< 接收数据解析: (\(device)) | \(cidHex(cid)) | [\(fields.joined(separator: " "))]"
    }

    private static func cidHex(_ cid: UInt8) -> String {
        String(format: "%02X", cid)
    }

    private static func hex(_ data: Data) -> String {
        data.map { String(format: "%02X", $0) }.joined(separator: " ")
    }

    private static func stateName(_ value: UInt8) -> String {
        switch value {
        case 0x00: return "停止"
        case 0x01: return "运行"
        case 0x02: return "退出体验"
        case 0x03: return "关机"
        case 0x04: return "体验运行"
        case 0x05: return "模式结束"
        default: return String(format: "0x%02X", value)
        }
    }

    private static func modeName(_ value: UInt8) -> String {
        switch value {
        case 0x01: return "按摩"
        case 0x02: return "吸乳"
        case 0x03: return "混合"
        case 0x04: return "自定义"
        case 0x05: return "自动"
        default: return String(format: "0x%02X", value)
        }
    }

    private static func diyModeName(_ value: UInt8) -> String {
        switch value {
        case 0x01: return "短吸"
        case 0x02: return "长吸"
        case 0x03: return "混合(5短1长)"
        case 0x04: return "混合(2短1长)"
        default: return String(format: "0x%02X", value)
        }
    }
}
