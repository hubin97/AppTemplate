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
        
        var title: String {
            switch self {
            case .test:
                return "临时测试"
            }
        }
    }
    
    let items: [RowType] = RowType.allCases
}
