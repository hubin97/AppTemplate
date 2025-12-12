//
//  TabBarItem.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/3.
//  Copyright © 2025 Hubin_Huang. All rights reserved.

import Foundation
import AppStart

// 枚举定义了 TabBar 中的各个选项
enum TabBarItem: TabBarItemDataProvider {
    case home, `func`, mine
    
    var image_n: UIImage? {
        switch self {
        case .home:
            return R.image.tabBar.icon_home_n()
        case .func:
            return R.image.tabBar.icon_func_n()
        case .mine:
            return R.image.tabBar.icon_mine_n()
        }
    }
    
    var image_h: UIImage? {
        switch self {
        case .home:
            return R.image.tabBar.icon_home_h()
        case .func:
            return R.image.tabBar.icon_func_h()
        case .mine:
            return R.image.tabBar.icon_mine_h()
        }
    }
    
    var title: String? {
        switch self {
        case .home:
            return "Examples"
        case .func:
            return "Fuctions"
        case .mine:
            return "Profile"
        }
    }
    
    var viewModel: ViewModel {
        switch self {
        case .home:
            return ListViewModel()
        case .func:
            return FuncViewModel()
        case .mine:
            return MineViewModel()
        }
    }

    // 根据枚举值返回对应的视图控制器
    func controller(with viewModel: ViewModel, navigator: Navigator) -> UIViewController {
        switch self {
        case .home:
            return NavigationController(rootVc: ListViewController(viewModel: viewModel, navigator: navigator))
        case .func:
            return NavigationController(rootVc: FuncViewController(viewModel: viewModel, navigator: navigator))
        case .mine:
            return NavigationController(rootVc: MineViewController(viewModel: viewModel, navigator: navigator))
        }
    }
}
