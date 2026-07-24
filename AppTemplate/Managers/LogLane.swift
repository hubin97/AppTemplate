//
//  LogLane.swift
//  AppTemplate
//
//  业务日志线路；`rawValue` 即 LogTag 前缀。

import AppStart

enum LogLane: String, LogTagEnum {
    case ble = "BLE"
    case network = "Network"
}
