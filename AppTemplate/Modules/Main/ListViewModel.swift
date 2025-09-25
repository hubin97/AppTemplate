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
        case test
        case mediaList
        case routeTest
        case demoTest
        case imageDecoder
        
        var title: String {
            switch self {
            case .test:
                return "临时测试"
            case .mediaList:
                return "媒体列表"
            case .routeTest:
                return "路由测试"
            case .demoTest:
                return "示例演示"
            case .imageDecoder:
                return "图片解码"
            }
        }
    }
    
    let items: [RowType] = RowType.allCases
}
