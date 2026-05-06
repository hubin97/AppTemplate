//
//  SettingItemModel+Factories.swift
//  AppTemplate
//
//  Created by hubin.h on 2026/5/4.
//  Copyright © 2025 hubin.h. All rights reserved.

import Foundation

// MARK: - Global Variables & Functions (if necessary)

// MARK: - Utilities & Helpers
extension SettingItemModel {

    /// 开关行。
    static func toggle(
        id: String,
        title: String,
        subtitle: String? = nil,
        detail: String? = nil,
        isOn: Bool = false,
        enabled: Bool = true
    ) -> SettingItemModel {
        SettingItemModel(
            id: id,
            type: DynamicSettingItemType.toggle,
            title: title,
            subtitle: subtitle,
            detail: detail,
            enabled: enabled,
            payload: SettingPayloadModel(boolValue: isOn, routeName: nil, routeParams: nil)
        )
    }

    /// 纯展示。
    static func info(
        id: String,
        title: String,
        subtitle: String? = nil,
        detail: String? = nil,
        enabled: Bool = true
    ) -> SettingItemModel {
        SettingItemModel(
            id: id,
            type: DynamicSettingItemType.info,
            title: title,
            subtitle: subtitle,
            detail: detail,
            enabled: enabled,
            payload: SettingPayloadModel(boolValue: nil, routeName: nil, routeParams: nil)
        )
    }

    /// 导航 / 跳转占位（由 `DynamicSettingsViewController.handleNavigationItem(_:)` 处理）。
    static func navigation(
        id: String,
        title: String,
        subtitle: String? = nil,
        detail: String? = nil,
        routeName: String?,
        routeParams: [String: String]? = nil,
        enabled: Bool = true
    ) -> SettingItemModel {
        SettingItemModel(
            id: id,
            type: DynamicSettingItemType.navigation,
            title: title,
            subtitle: subtitle,
            detail: detail,
            enabled: enabled,
            payload: SettingPayloadModel(boolValue: nil, routeName: routeName, routeParams: routeParams)
        )
    }
}
