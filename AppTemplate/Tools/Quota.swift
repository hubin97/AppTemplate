//
//  Quota.swift
//  Momcozy
//
//  Created by hubin.h on 2025/9/9.
//  Copyright © 2025 路特创新. All rights reserved.

import Foundation

// MARK: - Global Variables & Functions (if necessary)

// 示例: 隔天可使用
// Quota.Daily.set(for: MMKVKeys.moment_post_task.rawValue)
// let isTaped = Quota.Daily.get(for: MMKVKeys.moment_post_task.rawValue)

// MARK: - Main Class
struct Quota {

    // 每日重置
    struct Daily {
        static func get(for key: String) async -> Bool { await Quota.get(for: key, granularity: .day) }
        static func set(for key: String) async { await Quota.set(for: key) }
        static func reset(for key: String) async { await Quota.reset(for: key) }
        static func consume(_ key: String) async -> Bool { await Quota.consume(key, granularity: .day) }
    }

    // 每周重置
    struct Weekly {
        static func get(for key: String) async -> Bool { await Quota.get(for: key, granularity: .weekOfYear) }
        static func set(for key: String) async { await Quota.set(for: key) }
        static func reset(for key: String) async { await Quota.reset(for: key) }
        static func consume(_ key: String) async -> Bool { await Quota.consume(key, granularity: .weekOfYear) }
    }

    // 每月重置
    struct Monthly {
        static func get(for key: String) async -> Bool { await Quota.get(for: key, granularity: .month) }
        static func set(for key: String) async { await Quota.set(for: key) }
        static func reset(for key: String) async { await Quota.reset(for: key) }
        static func consume(_ key: String) async -> Bool { await Quota.consume(key, granularity: .month) }
    }
}

// MARK: - Private Methods
extension Quota {

    // 通用逻辑
    private static func get(for key: String, granularity: Calendar.Component) async -> Bool {
        guard let savedDate = await MMKVManager.shared.date(forKey: key) else { return false }
        return Calendar.current.isDate(Date(), equalTo: savedDate, toGranularity: granularity)
    }

    private static func set(for key: String) async {
        await MMKVManager.shared.set(Date(), forKey: key)
    }

    private static func reset(for key: String) async {
        await MMKVManager.shared.removeValue(forKey: key)
    }

    @discardableResult
    private static func consume(_ key: String, granularity: Calendar.Component) async -> Bool {
        if await get(for: key, granularity: granularity) {
            return false
        } else {
            await set(for: key)
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
