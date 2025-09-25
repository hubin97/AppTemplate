//
//  Quota.swift
//  Momcozy
//
//  Created by hubin.h on 2025/9/9.
//  Copyright © 2025 路特创新. All rights reserved.

import Foundation

// MARK: - Global Variables & Functions (if necessary)

// MARK: - Main Class
struct Quota {

    // 每日重置
    struct Daily {
        static func get(for key: String) -> Bool { Quota.get(for: key, granularity: .day) }
        static func set(for key: String) { Quota.set(for: key) }
        static func reset(for key: String) { Quota.reset(for: key) }
        static func consume(_ key: String) -> Bool { Quota.consume(key, granularity: .day) }
    }

    // 每周重置
    struct Weekly {
        static func get(for key: String) -> Bool { Quota.get(for: key, granularity: .weekOfYear) }
        static func set(for key: String) { Quota.set(for: key) }
        static func reset(for key: String) { Quota.reset(for: key) }
        static func consume(_ key: String) -> Bool { Quota.consume(key, granularity: .weekOfYear) }
    }

    // 每月重置
    struct Monthly {
        static func get(for key: String) -> Bool { Quota.get(for: key, granularity: .month) }
        static func set(for key: String) { Quota.set(for: key) }
        static func reset(for key: String) { Quota.reset(for: key) }
        static func consume(_ key: String) -> Bool { Quota.consume(key, granularity: .month) }
    }
}

// MARK: - Private Methods
extension Quota {

    // 通用逻辑
    private static func get(for key: String, granularity: Calendar.Component) -> Bool {
        guard let savedDate = mmkv.date(forKey: key) else { return false }
        return Calendar.current.isDate(Date(), equalTo: savedDate, toGranularity: granularity)
    }

    private static func set(for key: String) {
        mmkv.set(Date(), forKey: key)
    }

    private static func reset(for key: String) {
        mmkv.removeValue(forKey: key)
    }

    @discardableResult
    private static func consume(_ key: String, granularity: Calendar.Component) -> Bool {
        if get(for: key, granularity: granularity) {
            return false
        } else {
            set(for: key)
            return true
        }
    }
}

// MARK: - Utilities & Helpers
extension Quota {
}

// MARK: - Delegate & Data Source
extension Quota {
}
