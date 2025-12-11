//
//  MineViewModel.swift
//  AppTemplate
//
//  Created by hubin.h on 2025/12/10.
//  Copyright © 2025 hubin.h. All rights reserved.

import Foundation

// MARK: - Global Variables & Functions (if necessary)

// MARK: - Main Class
class MineViewModel: ViewModel {
    
    enum ItemType: String, CaseIterable {
        case nightMode = "夜间模式"
        case themeMode = "主题模式"
    }
    
    let items = ItemType.allCases
}

// MARK: - Private Methods
extension MineViewModel {
}

// MARK: - Callbacks
extension MineViewModel {
}

// MARK: - Utilities & Helpers
extension MineViewModel {
}

// MARK: - Delegate & Data Source
extension MineViewModel {
}
