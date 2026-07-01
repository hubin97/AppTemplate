//
//  DynamicSettingsContract.swift
//  AppTemplate
//
//  Created by hubin.h on 2026/5/4.
//  Copyright © 2025 hubin.h. All rights reserved.

import Foundation

// MARK: - Global Variables & Functions (if necessary)

// MARK: - Main Class

/// 动态设置页的跨端契约：纯模型描述 UI 区块与条目的语义。
///
/// 可用 Swift 拼装，或通过 ``DynamicSettingsLocalPanelSource`` 读取业务 Bundle 内 JSON / plist。
/// 序列化结构与 RN Bridge / 远端接口一致；YAML 需在构建期或运行时先转为 JSON。
///
/// 一页设置面板根模型。
struct SettingPanelModel: Codable, Equatable {
    /// 契约版本号，便于演进与 RN 端按版本兼容。
    var schemaVersion: Int
    /// 面板唯一标识（埋点、缓存键、与远端对齐）。
    var panelId: String
    /// 分组列表，自上而下展示。
    var sections: [SettingSectionModel]
}

/// 单个分组（UITableView section）。
struct SettingSectionModel: Codable, Equatable {
    /// 分组稳定 ID。
    var id: String
    /// 表头标题；为 nil 时不展示 section header。
    var title: String?
    /// 该分组下的条目。
    var items: [SettingItemModel]
}

/// 单条设置项：标题、类型与载荷均由模型驱动。
struct SettingItemModel: Codable, Equatable {
    /// 条目稳定 ID（切换状态、埋点、RN 回传均依赖此字段）。
    var id: String
    /// 控件类型，与原生注册表 / RN 映射表一致，取值见 `DynamicSettingItemType`。
    var type: String
    /// 主标题。
    var title: String
    /// 副标题；可与 detail 同时用于说明文案。
    var subtitle: String?
    /// 右侧或次要说明（如当前选中值摘要）。
    var detail: String?
    /// 视图样式；未指定时由 `type` 决定默认样式。
    var viewStyle: String?
    /// 是否可交互；为 false 时常用于置灰不可点。
    var enabled: Bool
    /// 按 `type` 解释：开关初值、路由名、路由参数等。
    var payload: SettingPayloadModel
}

/// 与 `type` 配套的弱类型载荷；未使用的字段为 nil。
struct SettingPayloadModel: Codable, Equatable {
    /// `toggle` 时：开关状态。
    var boolValue: Bool?
    /// `navigation` 时：逻辑路由名（由原生白名单解析）。
    var routeName: String?
    /// `navigation` 时：路由附加参数。
    var routeParams: [String: String]?
}

/// 条目 `type` 字段的约定取值，与接口、RN 注册表使用同一字符串。
enum DynamicSettingItemType {
    /// 开关。
    static let toggle = "toggle"
    /// 点击进入下一页或唤起原生路由。
    static let navigation = "navigation"
    /// 仅展示信息，无开关无跳转。
    static let info = "info"
}

/// 条目视图样式常量：用于同一 `type` 在 UI 上呈现不同形态。
enum DynamicSettingViewStyle {
    /// 标准设置行（标题 + 副信息 + 右箭头/开关）
    static let plain = "plain"
    /// 设备卡片样式（更高、两行文本）
    static let deviceCard = "deviceCard"
    /// 顶部主操作按钮（深色背景）
    static let primaryAction = "primaryAction"
    /// 危险操作按钮（浅红背景）
    static let dangerAction = "dangerAction"
}

// MARK: - Panel Source

/// 动态设置页的「面板数据来源」抽象。
///
/// 模板工程提供 ``DynamicSettingsDefaultPanelSource``；本地文件见 ``DynamicSettingsLocalPanelSource``（按业务目录加载）。
/// 业务可实现本协议接入远端或其它数据源。
protocol DynamicSettingsPanelSource {

    /// 进入页面时使用的初始 ``SettingPanelModel``。
    func makeInitialPanel() -> SettingPanelModel
}

// MARK: - Utilities & Helpers
extension SettingPanelModel {

    /// 转为 `[String: Any]`，供 RN 原生模块或其它 Bridge 直接传递。
    /// - Throws: 编码或 JSON 转换失败时抛出。
    /// - Returns: 与 Codable 编码结果一致的字典快照。
    func bridgeDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        let obj = try JSONSerialization.jsonObject(with: data)
        guard let dict = obj as? [String: Any] else {
            throw NSError(domain: "SettingPanelModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON object"])
        }
        return dict
    }
}
