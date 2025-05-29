//
//  ListViewModel.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/3.
//  Copyright © 2025 Hubin_Huang. All rights reserved.

import Foundation
// MARK: - global var and methods

// MARK: - main class
class ListViewModel: ViewModel {
    
    enum RowType: Int, CaseIterable {
        case mediaList
        case routerTest

        var title: String {
            switch self {
            case .mediaList:
                return "媒体列表"
            case .routerTest:
                return "路由测试"
            }
        }
    }
    
    let items: [RowType] = RowType.allCases
}
