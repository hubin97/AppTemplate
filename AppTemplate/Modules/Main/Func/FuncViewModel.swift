//
//  FuncViewModel.swift
//  AppTemplate
//
//  Created by hubin.h on 2025/12/10.
//  Copyright © 2025 hubin.h. All rights reserved.

import Foundation

// MARK: - Global Variables & Functions (if necessary)

// MARK: - Main Class
class FuncViewModel: ViewModel {
    
    enum ItemType: String, CaseIterable {
        case jsTest = "Js交互"
        case webP   = "webP解析"
        case route  = "模块路由"
        case safari = "Safari场景"
        case AVPlayerViewController 
    }
    
    let items = ItemType.allCases
}

// MARK: - Private Methods
extension FuncViewModel {
}

// MARK: - Callbacks
extension FuncViewModel {
}

// MARK: - Utilities & Helpers
extension FuncViewModel {
}

// MARK: - Delegate & Data Source
extension FuncViewModel {
}
