//
//  LocalizedUtils.swift
//  LuteGo
//
//  Created by hubin.h on 2025/5/9.
//  Copyright © 2025 路特创新. All rights reserved.

import Foundation

// MARK: - Global Variables & Functions (if necessary)
// MARK: - Date Format
extension LocalizedUtils {

    /// 默认时间格式(云端支持格式) `"yyyy-MM-dd"`
    public static var dateFormat_standard: String {
        return "yyyy-MM-dd"
    }

//    /// 默认时间格式(云端支持格式) `"yyyy-MM-dd HH:mm"`
//    static var dateFormat_Cloud2: String {
//        return "yyyy-MM-dd HH:mm"
//    }
//
//    /// 默认时间格式(云端支持格式) `"yyyy-MM-dd HH:mm:ss"`
//    static var dateFormat_Cloud3: String {
//        return "yyyy-MM-dd HH:mm:ss"
//    }
//
//    /// 默认时间格式(云端支持格式) `"HH:mm"`
//    static var dateFormat_Cloud4: String {
//        return "HH:mm"
//    }

    /// 区分语言展示 时间格式 `yyyy/MM/dd`
    public static var dateFormat_YMD: String {
        return LocalizedUtils.isChina() || LocalizedUtils.isRTL() ? "yyyy/MM/dd": "MM/dd/yyyy"
    }

    /// 区分语言展示 时间格式 `yyyy/MM/dd HH:mm`
    public static var dateFormat_YMD_HM: String {
        if LocalizedUtils.isRTL() {
            return "HH:mm yyyy/MM/dd"
        }
        return LocalizedUtils.isChina() ? "yyyy/MM/dd HH:mm": "MM/dd/yyyy HH:mm"
    }

    /// 区分语言展示 时间格式 `yyyy/MM/dd HH:mm:ss`
    public static var dateFormat_YMD_HMS: String {
        if LocalizedUtils.isRTL() {
            return "HH:mm:ss yyyy/MM/dd"
        }
        return LocalizedUtils.isChina() ? "yyyy/MM/dd HH:mm:ss": "MM/dd/yyyy HH:mm:ss"
    }

    /// 时间格式 12 小时制 AP/PM `"hh:mm aa"`
    public static var dateFormat_hma: String {
        return "hh:mm aa"
    }
}
