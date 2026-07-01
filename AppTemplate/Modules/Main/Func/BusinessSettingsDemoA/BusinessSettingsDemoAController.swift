//
//  BusinessSettingsDemoAController.swift
//  AppTemplate
//
//  Created by hubin.h on 2026/5/4.
//  Copyright © 2025 hubin.h. All rights reserved.

import Foundation
import RxSwift

// MARK: - Global Variables & Functions (if necessary)

// MARK: - Main Class

/// 业务动态设置页 **示例**：从本目录的 `panelA.json` 读取并展示。
///
/// 约定：
/// - 资源名必须在 Target 内唯一（当前使用 `panelA.json` / `panelB.json`）。
/// - 通过 `AppScene` 注入本页的 `anchorType`（用于 `Bundle(for:)` 定位所属模块）。
final class BusinessSettingsDemoAController: DynamicSettingsViewController {

    override var dynamicSettingsNavigationTitle: String { "业务 A · JSON" }

    override func bindViewModel() {
        super.bindViewModel()
        // 演示“业务运行态”动态更新：设备状态、时间、模式、固件版本。
        Observable<Int>.interval(.seconds(2), scheduler: MainScheduler.instance)
            .startWith(0)
            .subscribe(onNext: { [weak self] tick in
                guard let self else { return }
                let status = tick % 3 == 0 ? "在线" : (tick % 3 == 1 ? "离线" : "升级中")
                let mode = tick % 2 == 0 ? "舒缓" : "标准"
                let version = "5.7.6.2026\(420 + tick)"
                self.vm.applyRuntimeValues([
                    "deviceStatus": status,
                    "updatedAt": Self.currentTimeText(),
                    "soundMode": mode,
                    "firmwareVersion": version
                ])
            })
            .disposed(by: rx.disposeBag)
    }

    override func handleActionItem(_ item: SettingItemModel) {
        let style = item.viewStyle ?? DynamicSettingViewStyle.plain
        let isDanger = style == DynamicSettingViewStyle.dangerAction
        let alert = UIAlertController(
            title: item.title,
            message: item.subtitle ?? "请确认操作",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "确认", style: isDanger ? .destructive : .default))
        present(alert, animated: true)
    }
}

// MARK: - Private Methods
extension BusinessSettingsDemoAController {
    private static func currentTimeText() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }
}

// MARK: - Callbacks
extension BusinessSettingsDemoAController {
}

// MARK: - Utilities & Helpers
extension BusinessSettingsDemoAController {
}

// MARK: - Delegate & Data Source
extension BusinessSettingsDemoAController {
}
