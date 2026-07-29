//
//  DefaultViewController.swift
//  AppTemplate
//
//  Created by hubin.h on 2025/12/12.
//  Copyright © 2025 hubin.h. All rights reserved.

import Foundation

// MARK: - Global Variables & Functions (if necessary)

// MARK: - Main Class
class DefaultViewController: ViewController, Themeable {

    /// 子类 override 返回需要跟随主题刷新的 TableView。
    var themeableTableViews: [UITableView] { [] }
    
    override func bindViewModel() {
        super.bindViewModel()
        startThemeUpdates()
    }

    func themeDidChange(_ theme: AppTheme) {
        applyPageTheme(theme)
        themeableTableViews.forEach {
            $0.backgroundColor = theme.colors.tableBackground
        }
    }
  
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
}

// MARK: - Private Methods
extension DefaultViewController {
}

// MARK: - Callbacks
extension DefaultViewController {
}

// MARK: - Utilities & Helpers
extension DefaultViewController {
}

// MARK: - Delegate & Data Source
extension DefaultViewController {
}
