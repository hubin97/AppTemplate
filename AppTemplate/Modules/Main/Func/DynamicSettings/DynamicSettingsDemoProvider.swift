//
//  DynamicSettingsDemoProvider.swift
//  AppTemplate
//
//  Created by hubin.h on 2026/5/4.
//  Copyright © 2025 hubin.h. All rights reserved.

import Foundation

// MARK: - Global Variables & Functions (if necessary)

// MARK: - Main Class

/// 模板内置的默认面板数据（Functions → 动态设置 Demo 使用）。
///
/// 业务侧优先使用 ``DynamicSettingsLocalPanelSource`` + Target 内 **唯一文件名** 的 JSON（如 `panelA.json`），或使用 ``SettingItemModel`` 便捷工厂在代码中拼装。
struct DynamicSettingsDefaultPanelSource: DynamicSettingsPanelSource {

    func makeInitialPanel() -> SettingPanelModel {
        SettingPanelModel(
            schemaVersion: 1,
            panelId: "func.dynamic_settings.demo",
            sections: [
                SettingSectionModel(
                    id: "general",
                    title: "通用",
                    items: [
                        .toggle(
                            id: "demo.notifications",
                            title: "演示开关",
                            subtitle: "本地模型驱动",
                            isOn: false,
                            enabled: true
                        ),
                        .info(
                            id: "demo.theme_hint",
                            title: "主题",
                            subtitle: nil,
                            detail: "跟随系统",
                            enabled: true
                        )
                    ]
                ),
                SettingSectionModel(
                    id: "more",
                    title: "更多",
                    items: [
                        .navigation(
                            id: "demo.route_placeholder",
                            title: "路由占位",
                            subtitle: "点击弹出路由信息",
                            routeName: "demo.dynamic.route",
                            routeParams: ["from": "dynamic_settings"],
                            enabled: true
                        )
                    ]
                )
            ]
        )
    }
}

/// 兼容旧命名：等同于 ``DynamicSettingsDefaultPanelSource`` 生成结果。
enum DynamicSettingsDemoProvider {

    static func makeDemoPanel() -> SettingPanelModel {
        DynamicSettingsDefaultPanelSource().makeInitialPanel()
    }
}
