//
//  DynamicSettingsLocalPanelSource.swift
//  AppTemplate
//
//  Created by hubin.h on 2026/5/4.
//  Copyright © 2025 hubin.h. All rights reserved.

import Foundation

// MARK: - Global Variables & Functions (if necessary)

// MARK: - Main Class

/// 从业务 Bundle 内读取本地配置文件。
///
/// **资源名**：Xcode 同 Target 内资源 **文件名需全局唯一**，常用做法是与源码同目录维护 `panelA.json`、`biz_mine.json` 等，打进包后多在 **主 Bundle 根路径**，此时 `subdirectory` 传 `nil`（默认）即可。
/// 仅在使用蓝色文件夹引用等、拷贝后仍保留子目录结构时，才需要传入 `subdirectory`。
///
/// **格式选择**
/// - **JSON**：与 RN / 服务端最易对齐，推荐作为跨端单一事实来源。
/// - **Property List (`plist`)**：Xcode 表格编辑、少手写引号错误；仍通过同一套 ``SettingPanelModel`` `Codable` 解码。
///
/// **YAML**：系统不支持；可在构建脚本把 YAML 转成 JSON，或引入 Yams 先解析再转 `Data` 走 JSON 解码。
struct DynamicSettingsLocalPanelSource: DynamicSettingsPanelSource {

    enum Format {
        case json
        case propertyList
    }

    private let model: SettingPanelModel

    init(data: Data, format: Format) throws {
        switch format {
        case .json:
            model = try JSONDecoder().decode(SettingPanelModel.self, from: data)
        case .propertyList:
            model = try PropertyListDecoder().decode(SettingPanelModel.self, from: data)
        }
    }

    init(jsonString: String) throws {
        guard let data = jsonString.data(using: .utf8) else {
            throw NSError(domain: "DynamicSettingsLocalPanelSource", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid UTF-8 string"])
        }
        try self.init(data: data, format: .json)
    }

    /// - Parameters:
    ///   - resource: 文件名不含扩展名；多业务时用不同前缀避免重名（如 `panelA`、`settings_mine`）。
    ///   - format: `json` 或 `plist`。
    ///   - subdirectory: 一般为 `nil`；仅当资源落在 Bundle 内子目录时传入。
    init(resource: String = "panel", format: Format = .json, subdirectory: String? = nil) throws {
        let ext: String
        switch format {
        case .json: ext = "json"
        case .propertyList: ext = "plist"
        }
        guard let url = Bundle.main.url(forResource: resource, withExtension: ext, subdirectory: subdirectory) else {
            throw NSError(
                domain: "DynamicSettingsLocalPanelSource",
                code: -3,
                userInfo: [NSLocalizedDescriptionKey: "Missing \(resource).\(ext) in bundle, subdirectory: \(subdirectory ?? "(nil)")"]
            )
        }
        let data = try Data(contentsOf: url)
        try self.init(data: data, format: format)
    }

    func makeInitialPanel() -> SettingPanelModel {
        model
    }
}

// MARK: - Utilities & Helpers
extension DynamicSettingsLocalPanelSource {

    /// 尝试从 Bundle 加载本地配置；失败时返回 `fallback`（默认可用 ``DynamicSettingsDefaultPanelSource``）。
    ///
    /// 用于路由 / `AppScene` 等入口，避免各处重复 `do/catch`。
    static func resolvingOrFallback(
        resource: String,
        format: Format = .json,
        subdirectory: String? = nil,
        fallback: DynamicSettingsPanelSource = DynamicSettingsDefaultPanelSource()
    ) -> DynamicSettingsPanelSource {
        if let source = try? DynamicSettingsLocalPanelSource(resource: resource, format: format) {
            return source
        }
        return fallback
    }
}
