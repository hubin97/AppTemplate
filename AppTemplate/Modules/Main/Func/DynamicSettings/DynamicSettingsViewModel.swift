//
//  DynamicSettingsViewModel.swift
//  AppTemplate
//
//  Created by hubin.h on 2026/5/4.
//  Copyright © 2025 hubin.h. All rights reserved.

import Foundation
import RxSwift
import RxCocoa

// MARK: - Global Variables & Functions (if necessary)

// MARK: - Main Class

/// 动态设置列表逻辑层；通过 ``DynamicSettingsPanelSource`` 注入初始数据，业务可子类化并改写 `panel` 更新策略。
class DynamicSettingsViewModel: ViewModel {

    let panel: BehaviorRelay<SettingPanelModel>

    let bridgeSnapshot = BehaviorRelay<String>(value: "")

    /// - Parameter panelSource: 初始面板来源；默认使用模板内置演示数据。
    required init(panelSource: DynamicSettingsPanelSource = DynamicSettingsDefaultPanelSource()) {
        self.panel = BehaviorRelay<SettingPanelModel>(value: panelSource.makeInitialPanel())
        super.init()
        refreshBridgeSnapshot()
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    func setToggle(itemId: String, isOn: Bool) {
        var p = panel.value
        for s in 0..<p.sections.count {
            for i in 0..<p.sections[s].items.count where p.sections[s].items[i].id == itemId {
                p.sections[s].items[i].payload.boolValue = isOn
                panel.accept(p)
                refreshBridgeSnapshot()
                return
            }
        }
    }

    func item(at indexPath: IndexPath) -> SettingItemModel {
        let sec = panel.value.sections[indexPath.section]
        return sec.items[indexPath.row]
    }

    func numberOfSections() -> Int {
        return panel.value.sections.count
    }

    func numberOfRows(in section: Int) -> Int {
        return panel.value.sections[section].items.count
    }

    func titleForHeader(in section: Int) -> String? {
        return panel.value.sections[section].title
    }
}

// MARK: - Private Methods
extension DynamicSettingsViewModel {

    private func refreshBridgeSnapshot() {
        if let dict = try? panel.value.bridgeDictionary(),
           let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
           let str = String(data: data, encoding: .utf8) {
            bridgeSnapshot.accept(str)
        }
    }
}

// MARK: - Callbacks
extension DynamicSettingsViewModel {
}

// MARK: - Utilities & Helpers
extension DynamicSettingsViewModel {
}

// MARK: - Delegate & Data Source
extension DynamicSettingsViewModel {
}
