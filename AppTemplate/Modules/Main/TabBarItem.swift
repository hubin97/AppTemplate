//
//  TabBarItem.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/3.
//  Copyright © 2025 Hubin_Huang. All rights reserved.

import Foundation

// 枚举定义了 TabBar 中的各个选项
enum TabBarItem: TabBarItemDataProvider {
    case home, me
    
    var image_n: UIImage? {
        switch self {
        case .home:
            return R.image.tabBar.icon_home_n()
        case .me:
            return R.image.tabBar.icon_me_n()
        }
    }
    
    var image_h: UIImage? {
        switch self {
        case .home:
            return R.image.tabBar.icon_home_h()
        case .me:
            return R.image.tabBar.icon_me_h()
        }
    }
    
    var title: String? {
        switch self {
        case .home:
            return "Example List"
        case .me:
            return "Web Preview"
        }
    }
    
    var viewModel: ViewModel {
        switch self {
        case .home:
            return ListViewModel()
//        case .test:
//            return UIKitTestViewModel()
//        case .web:
//            return WebPreviewViewModel()
        default:
            return ViewModel()
        }
    }

    // 根据枚举值返回对应的视图控制器
    func controller(with viewModel: ViewModel, navigator: Navigator) -> UIViewController {
        switch self {
        case .home:
            return NavigationController(rootVc: ListViewController(viewModel: viewModel, navigator: navigator))
        case .me:
            return NavigationController(rootVc: WebPreviewController(viewModel: viewModel, navigator: navigator))
        }
    }
}
