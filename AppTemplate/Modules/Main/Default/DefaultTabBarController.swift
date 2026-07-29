//
//  DefaultTabBarController.swift
//  AppTemplate
//
//  Created by hubin.h on 2025/12/12.
//  Copyright © 2025 hubin.h. All rights reserved.

import Foundation

// MARK: - Global Variables & Functions (if necessary)

// MARK: - Main Class
class DefaultTabBarController: TabBarController, Themeable {
    
    override func bindViewModel() {
        super.bindViewModel()
        startThemeUpdates()
    }

    func themeDidChange(_ theme: AppTheme) {
        setAppearance(
            barTintColor: theme.colors.background,
            normalColor: theme.colors.tabNormal,
            selectColor: theme.colors.tabSelected
        )
    }
}

// MARK: - Private Methods
extension DefaultTabBarController {
}

// MARK: - Callbacks
extension DefaultTabBarController {
}

// MARK: - Utilities & Helpers
extension DefaultTabBarController {
}

// MARK: - Delegate & Data Source
extension DefaultTabBarController {
}
