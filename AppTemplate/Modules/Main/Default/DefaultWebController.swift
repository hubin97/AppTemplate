//
//  DefaultWebController.swift
//  AppTemplate
//
//  Created by hubin.h on 2025/12/12.
//  Copyright © 2025 hubin.h. All rights reserved.

import Foundation

// MARK: - Global Variables & Functions (if necessary)

// MARK: - Main Class
class DefaultWebController: JSWebController, Themeable {
    
    override func bindViewModel() {
        super.bindViewModel()
        withThemeUpdates { (self, theme) in
            self.view.backgroundColor = theme.backgroundColor
            self.naviBar.backgroundColor = theme.backgroundColor
            self.naviBar.textColor = theme.textColor
            // 更新导航栏按钮图标以适配主题
            self.naviBar.updateIcons(isDark: theme.type == .dark, textColor: theme.textColor)
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeService.shared.current.statusBarStyle
    }
}

// MARK: - Private Methods
extension DefaultWebController {
}

// MARK: - Callbacks
extension DefaultWebController {
}

// MARK: - Utilities & Helpers
extension DefaultWebController {
}

// MARK: - Delegate & Data Source
extension DefaultWebController {
}
