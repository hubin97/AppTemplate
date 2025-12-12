//
//  SettingCellViewModel.swift
//  AppTemplate
//
//  Created by hubin.h on 2025/12/11.
//  Copyright © 2025 hubin.h. All rights reserved.

import Foundation
import RxCocoa
// MARK: - Global Variables & Functions (if necessary)

// MARK: - Main Class
class SettingCellViewModel: DefaultTableViewCellViewModel {
    
    let itemType: SettingItem        // 固定类型，初始化后不变
    let hideNext: Bool               // 是否隐藏右箭头

    let switchChanged = BehaviorRelay<Bool>(value: false)  // 监听 switch 变化
    
    init(itemType: SettingItem, hideNext: Bool = false) {
        self.itemType = itemType
        self.hideNext = hideNext
        super.init()
        
        self.title.accept(itemType.title)
        
        switch itemType {
        case .nightMode(let isDark):
            self.switchChanged.accept(isDark)
        case .themeMode(let name):
            self.detail.accept(name)
        case .language(let lang):
            self.detail.accept(lang)
        case .clearCache:
            break
        case .aboutUs:
            break
        }
    }
}
